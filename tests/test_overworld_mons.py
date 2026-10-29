"""Pokémon standing or wandering in the overworld.

* 211809bc7: a Pokémon NPC in a SPRITE_OW_MON_* slot (scenery, or a script NPC) could be walked
  onto, because walking through was decided by the sprite rather than by the object's type. Only
  wandering wild Pokémon (OBJECTTYPE_WILDMON) are meant to be walked onto.
* ecd6fd4f6: a wanderer that starts on a side-wall tile (such as the UP_WALL row along a cave's
  back wall) never moved. CanObjectLeaveTile looked up its wall mask instead of its direction."""

from harness import overworld

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
