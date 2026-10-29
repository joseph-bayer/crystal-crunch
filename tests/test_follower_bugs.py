"""Follower bugs fixed in October 2026 (035e131b5 and later): each test sets up the situation the bug
showed in and checks the follower's state in memory.

The debug radio's party is Mewtwo, Mew, Lanturn, a beta Kingdra (level 50), Ditto and Ampharos."""

from harness import followers as F

# wFollowerFlags bits (constants/ram_constants.asm)
FOLLOWER_INVISIBLE = 1 << 0
FOLLOWER_INVISIBLE_ONE_STEP = 1 << 1
FOLLOWER_IN_POKEBALL = 1 << 3
# Surf recalls the follower: hidden and in its ball
RECALLED = FOLLOWER_INVISIBLE | FOLLOWER_IN_POKEBALL

TEXT_STATE = 1 << 6 # wStateFlags: the font is loaded over the walking frames

# The follower's object struct gets VRAM bank 0 tiles $0c-$17 standing and $8c-$97 walking.
FOLLOWER_WALKING_TILES = range(0x8c, 0x98)

OAM = 0xfe00
OAM_ENTRIES = 40
STAR = "★"

KINGDRA_SLOT = 4


def recall_follower(game):
	"""What Surf leaves behind: the follower in its ball and its object hidden."""
	game.poke("wFollowerFlags", RECALLED)
	set_follower_invisible(game, True)


def follower_invisible(game):
	return bool(F.object_field(game, F.FOLLOWER_STRUCT, F.OBJECT_FLAGS1) & F.INVISIBLE)


def set_follower_invisible(game, invisible):
	offset = F.FOLLOWER_STRUCT * F.OBJECT_LENGTH + F.OBJECT_FLAGS1
	flags = game.peek("wObjectStructs", offset)
	game.poke("wObjectStructs", (flags | F.INVISIBLE) if invisible else (flags & ~F.INVISIBLE), offset)


def follower_position(game):
	# Object structs keep map coordinates 4 tiles in, for the border
	return (F.object_field(game, F.FOLLOWER_STRUCT, F.OBJECT_MAP_X) - 4,
		F.object_field(game, F.FOLLOWER_STRUCT, F.OBJECT_MAP_Y) - 4)


def drawn_tiles(game):
	tiles = []
	for entry in range(OAM_ENTRIES):
		y = game.pyboy.memory[OAM + entry * 4]
		if 0 < y < 160:
			tiles.append(game.pyboy.memory[OAM + entry * 4 + 2])
	return tiles


def vram_tile(game, tile):
	return [game.pyboy.memory[0, 0x8000 + tile * 16 + i] for i in range(16)]


def a_script_starts(game, frames=60):
	for _ in range(frames):
		game.wait(1)
		if game.peek("wScriptRunning"):
			return True
	return False


def test_battle_with_a_wandering_mon_keeps_a_recalled_follower_hidden(game):
	"""B1: after a battle with an overworld Pokémon while surfing, the follower stood on the water.
	The battle's ending always showed the follower again, even when Surf had it recalled."""
	F.take_radio_items(game)
	game.poke("wBurnedTower1FSceneID", 2) # skip Eusine's first-visit scene
	game.warp("BURNED_TOWER_1F", 10, 12)
	wanderer = next(s for s in range(F.NUM_OBJECT_STRUCTS)
		if F.sprites()["SPRITE_OW_MON_1"] <= F.object_field(game, s, F.OBJECT_SPRITE) <= F.sprites()["SPRITE_OW_MON_4"])
	recall_follower(game)

	# Put the wanderer right of the player and keep it there, then walk onto it
	x, y = game.position()
	def hold_wanderer():
		base = wanderer * F.OBJECT_LENGTH
		for offset, value in ((F.OBJECT_MAP_X, x + 1 + 4), (F.OBJECT_MAP_Y, y + 4),
				(F.OBJECT_MAP_X + 2, x + 1 + 4), (F.OBJECT_MAP_Y + 2, y + 4), (0x03, 1)):
			game.poke("wObjectStructs", value, base + offset)
	hold_wanderer()
	game.wait(2)
	hold_wanderer()
	game.seed_random(1)
	game.pyboy.button_press("right")
	for _ in range(60):
		game.wait(5)
		if game.peek("wBattleMode"):
			break
	game.pyboy.button_release("right")
	assert game.peek("wBattleMode"), "walking onto the wandering mon should start a battle"

	# Mewtwo knocks it out with its first move
	for _ in range(150):
		game.press("a", after=10)
		if game.peek("wBattleMode") == 0 and F.script_done(game):
			break
	game.wait(60)
	assert game.peek("wBattleMode") == 0, "the battle didn't end"

	assert game.peek("wFollowerFlags") == RECALLED
	assert follower_invisible(game), "the recalled follower is showing after the battle"


def test_recalled_follower_cannot_be_talked_to(game):
	"""B2: while surfing, the recalled follower could still be talked to."""
	F.take_radio_items(game)
	game.warp("NEW_BARK_TOWN", 5, 7)
	game.step("right")
	game.wait(30)
	assert follower_position(game) == (5, 7), "the follower should be just left of the player"
	game.press("left") # turn to face it

	game.press("a", after=0)
	assert a_script_starts(game), "talking to the visible follower should do something"
	for _ in range(20):
		if F.script_done(game):
			break
		game.press("a")

	recall_follower(game)
	game.press("a", after=0)
	assert not a_script_starts(game), "the recalled follower answered"


def test_follower_never_draws_font_tiles_while_text_is_up(game):
	"""B3: when an Elite Four door closed behind the player, the follower's idle animation drew
	its walking frames, which the font had replaced, so it showed font tiles until the text closed."""
	F.take_radio_items(game)
	game.warp("NEW_BARK_TOWN", 5, 7)
	F.start_warp(game, "WILLS_ROOM", 5, 16) # the door locks behind you as you walk in

	reference = None
	text_frames = 0
	for frame in range(400):
		game.wait(1)
		if reference is None:
			# The room is loaded once the scene starts walking the player in
			if game.in_map("WILLS_ROOM") and game.position() != (5, 16):
				reference = {tile: vram_tile(game, tile) for tile in FOLLOWER_WALKING_TILES}
			continue
		if game.peek("wStateFlags") & TEXT_STATE:
			text_frames += 1
		for tile in set(drawn_tiles(game)) & set(FOLLOWER_WALKING_TILES):
			assert vram_tile(game, tile) == reference[tile], (
				"frame %d: the follower draws tile $%02x while it holds other graphics" % (frame, tile))
	assert text_frames, "the door scene should load the font"
	assert F.script_done(game)


def test_follower_comes_out_after_a_fall(game):
	"""B4: falling into a map (the Ruins of Alph puzzle, Burned Tower's hole), the follower
	appeared on the landing tile, the player landed on it, and from then on it trailed along
	invisible in its ball."""
	F.take_radio_items(game)
	game.poke("wBurnedTower1FSceneID", 2)
	game.set_event_flag("EVENT_HOLE_IN_BURNED_TOWER")
	game.warp("BURNED_TOWER_1F", 10, 10)

	game.pyboy.button_press("up") # into the hole at (10, 9)
	game.wait(16)
	game.pyboy.button_release("up")
	landed = False
	for frame in range(400):
		game.wait(1)
		if not game.in_map("BURNED_TOWER_B1F"):
			continue
		landed = True
		assert follower_invisible(game) or follower_position(game) != game.position(), (
			"frame %d: the follower shows on the player's tile during the fall" % frame)
		if F.script_done(game):
			break
	assert landed, "the hole should drop the player to B1F"
	flags = game.peek("wFollowerFlags")
	assert flags & FOLLOWER_IN_POKEBALL, "the follower should be recalled through the fall"
	assert flags & FOLLOWER_INVISIBLE_ONE_STEP, "the follower should be set to come out on the first step"

	landing = game.position()
	game.step("down")
	game.wait(20)
	assert game.peek("wFollowerFlags") == 0, "the follower should be out after one step"
	assert not follower_invisible(game)
	assert follower_position(game) == landing, "the follower should stand where the player was"
	previous = game.position()
	game.step("down")
	game.wait(20)
	assert follower_position(game) == previous, "the follower should keep following"


def test_rare_candy_box_colors_reach_the_screen(game):
	"""B5: Rare Candy's level-up stats box set its colors in the attribute map but never sent them
	to VRAM, so the party menu's colors (the follower star's red) showed through."""
	F.take_radio_items(game)
	game.warp("NEW_BARK_TOWN", 5, 7)
	game.poke("wFollowerPartySlot", KINGDRA_SLOT)
	game.press("start")
	game.wait(30)
	game.choose("PACK")
	game.wait(40)
	for _ in range(6):
		if "RARE CANDY" in game.screen_text():
			break
		game.press("left", after=40)
	game.choose("RARE CANDY")
	game.wait(20)
	game.choose("USE")
	game.wait(60)
	game.choose("KINGDRA")
	for _ in range(60):
		game.wait(10)
		text = game.screen_text()
		if "ATTACK" in text and "SPEED" in text:
			break
		if "grew to" in text:
			game.press("a")
	else:
		raise AssertionError("the stats box never showed. The screen:\n" + game.screen_text())
	game.wait(20)

	bgmap = game.peek("hBGMapAddress") | game.peek("hBGMapAddress", 1) << 8
	attrmap = game.peek("wAttrmap", 0, 20 * 18)
	wrong = [(col, row) for row in range(18) for col in range(20)
		if game.pyboy.memory[1, bgmap + row * 32 + col] != attrmap[row * 20 + col]]
	assert not wrong, "while the stats box waits, these cells' colors never reached VRAM: %s" % wrong


def test_follower_star_leaves_a_long_nickname_whole(game):
	"""B6: the party menu's follower star covered the 9th letter of a nickname (CYNDAQUIL read
	CYNDAQUI★). It now sits under the name's first letter."""
	F.take_radio_items(game)
	game.warp("NEW_BARK_TOWN", 5, 7)
	name = "ABCDEFGHIJ" # the longest a nickname can be
	slot = 2
	for i, letter in enumerate(name):
		game.poke("wPartyMonNicknames", 0x80 + ord(letter) - ord("A"), (slot - 1) * 11 + i)
	game.poke("wPartyMonNicknames", 0x50, (slot - 1) * 11 + len(name)) # "@"
	game.poke("wFollowerPartySlot", slot)

	game.press("start")
	game.wait(30)
	game.choose("POKéMON")
	game.wait(60)
	lines = game.screen_lines()
	name_row = next((row for row, line in enumerate(lines) if name in line), None)
	assert name_row is not None, "the nickname isn't shown whole:\n" + game.screen_text()
	column = lines[name_row].index(name)
	assert lines[name_row + 1][column] == STAR, "the star should sit under the name's first letter"
	assert sum(line.count(STAR) for line in lines) == 1, "only the follower should have a star"
