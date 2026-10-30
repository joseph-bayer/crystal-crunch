"""Pokémon standing or wandering in the overworld.

* 211809bc7: a Pokémon NPC in a SPRITE_OW_MON_* slot (scenery, or a script NPC) could be walked
  onto, because walking through was decided by the sprite rather than by the object's type. Only
  wandering wild Pokémon (OBJECTTYPE_WILDMON) are meant to be walked onto.
* ecd6fd4f6: a wanderer that starts on a side-wall tile (such as the UP_WALL row along a cave's
  back wall) never moved. CanObjectLeaveTile looked up its wall mask instead of its direction.
* Facing a wanderer and pressing A started the battle too, so a water wanderer by the shore could
  be fought from land before Surf. Now only walking onto one does."""

from harness import followers, overworld

# Kurt's front room: the Sunkern at (2, 2) stands left of Kurt until the Slowpoke Well is cleared.
KURTS_HOUSE_SUNKERN = ("KurtsHouse", "KURTSHOUSE_SUNKERN1", (2, 2))

# Silver Cave Room 1: the second wanderer starts at (8, 2), on the UP_WALL row under the back wall.
BACK_WALL_WANDERER = ("SilverCaveRoom1", "SILVERCAVEROOM1_WILD_MON_2", (8, 2))
BACK_WALL_STAND = (8, 5)

# How long to give the wanderer, and a seed so its steps are the same every run.
WANDER_FRAMES = 900
WANDER_SEED = 0x0001


def test_static_pokemon_is_solid(game):
	map_file, const, (x, y) = KURTS_HOUSE_SUNKERN
	game.warp("KURTS_HOUSE", x, y + 1)
	assert game.object_shown(map_file, const), "the Sunkern should be standing in the front room"
	assert overworld.collision(map_file)[(x, y)] == "FLOOR"

	game.step("up")
	game.wait(30)

	assert game.position() == (x, y + 1), "the player walked onto the Sunkern"


def test_wanderer_leaves_a_back_wall_tile(game):
	map_file, const, start = BACK_WALL_WANDERER
	assert overworld.collision(map_file)[start] == "UP_WALL", "the wanderer should start on a wall-edge tile"
	game.seed_random(WANDER_SEED)
	game.warp("SILVER_CAVE_ROOM_1", *BACK_WALL_STAND)

	struct = overworld.struct_for_object(game, map_file, const)
	assert struct is not None, "the wanderer should be out (its slot rolled a Pokémon)"
	init = (overworld.struct_field(game, struct, overworld.OBJECT_INIT_X) - overworld.MAP_BORDER,
		overworld.struct_field(game, struct, overworld.OBJECT_INIT_Y) - overworld.MAP_BORDER)
	assert init == start, "that should be the wanderer that starts on the back wall"

	positions = {overworld.struct_position(game, struct)}
	for _ in range(0, WANDER_FRAMES, 10):
		game.wait(10)
		positions.add(overworld.struct_position(game, struct))

	assert positions - {start}, "the wanderer never left its back-wall tile"


# Burned Tower 1F, where the follower tests also meet a wanderer; the scene ID skips Eusine.
BURNED_TOWER_STAND = (10, 12)
OW_RIGHT = 3 << 2
OBJECT_LAST_MAP_X = 0x12
OBJECT_LAST_MAP_Y = 0x13


def find_wanderer(game, sprite="SPRITE_OW_MON_1", last="SPRITE_OW_MON_4"):
	sprites = followers.sprites()
	return next(s for s in range(overworld.NUM_OBJECT_STRUCTS)
		if sprites[sprite] <= overworld.struct_field(game, s, overworld.OBJECT_SPRITE) <= sprites[last])


def pin_wanderer(game, wanderer, spot):
	"""Hold a wanderer still on `spot`: it rewrites its position each step, so this runs twice."""
	for _ in range(2):
		base = wanderer * overworld.OBJECT_LENGTH
		for field, value in ((overworld.OBJECT_MAP_X, spot[0] + overworld.MAP_BORDER),
				(overworld.OBJECT_MAP_Y, spot[1] + overworld.MAP_BORDER),
				(OBJECT_LAST_MAP_X, spot[0] + overworld.MAP_BORDER),
				(OBJECT_LAST_MAP_Y, spot[1] + overworld.MAP_BORDER),
				(overworld.OBJECT_MOVEMENT_TYPE, 1)):
			game.poke("wObjectStructs", value, base + field)
		game.wait(2)


def test_pressing_a_on_a_wanderer_does_nothing(game):
	game.poke("wBurnedTower1FSceneID", 2)
	game.warp("BURNED_TOWER_1F", *BURNED_TOWER_STAND)
	x, y = game.position()
	pin_wanderer(game, find_wanderer(game), (x + 1, y))
	game.poke("wPlayerDirection", OW_RIGHT)
	game.wait(2)

	game.press("a")
	for _ in range(30):
		game.wait(2)
		assert not game.peek("wBattleMode"), "pressing A on a wanderer started a battle"
		assert not game.peek("wScriptRunning"), "pressing A on a wanderer started a script"
	assert game.position() == (x, y)


# Route 30's south pond, and its water wanderer (the map's fourth slot)
ROUTE_30_POND = (17, 39)
PLAYER_SURF = 4


def test_surfing_onto_a_water_wanderer_starts_a_battle(game):
	"""With pressing A gone, Surf is the only way to reach a water wanderer, so walking onto one
	on the water has to work."""
	followers.take_radio_items(game)
	game.warp("ROUTE_30", *ROUTE_30_POND, settle=60)
	game.poke("wPlayerState", PLAYER_SURF)
	x, y = game.position()
	pin_wanderer(game, find_wanderer(game, "SPRITE_OW_MON_4", "SPRITE_OW_MON_4"), (x - 1, y))
	game.wait(20)
	assert not game.peek("wBattleMode"), "the battle started before the player moved"

	game.pyboy.button_press("left")
	for _ in range(60):
		game.wait(5)
		if game.peek("wBattleMode"):
			break
	game.pyboy.button_release("left")
	assert game.peek("wBattleMode"), "surfing onto the water wanderer didn't start a battle"
