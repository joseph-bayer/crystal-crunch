"""Viridian Forest, back between Viridian City and Pewter City as in Gen 1: two gates off Route 2's
west side, Red and Blue's wild Pokemon, a landmark of its own, and a brown/green palette in the
water slot on this map alone that follows the time of day."""

import re

import pytest

from harness import constants
from harness.data import read
from test_player_color import palette, global_constant

FOREST = "VIRIDIAN_FOREST"
SOUTH_GATE = "VIRIDIAN_FOREST_SOUTH_GATE"
NORTH_GATE = "VIRIDIAN_FOREST_NORTH_GATE"
MAP_FILES = {"ROUTE_2": "Route2", FOREST: "ViridianForest",
	SOUTH_GATE: "ViridianForestSouthGate", NORTH_GATE: "ViridianForestNorthGate"}
NITE = 2 # wTimeOfDayPal on a PALETTE_NITE map
PAL_BG_WATER = 3
COLOR_SIZE = 2


def warps(map_const):
	"""[(x, y, map, warp)] from a map's warp_events, 1-based as the events number them."""
	text = read("maps/%s.asm" % MAP_FILES[map_const])
	return [(int(x), int(y), m, int(w)) for x, y, m, w in
		re.findall(r"^\s*warp_event\s+(\d+),\s*(\d+),\s*(\w+),\s*(\d+)", text, re.M)]


def map_size(map_const):
	m = re.search(r"map_const %s,\s*(\d+),\s*(\d+)" % map_const, read("constants/map_constants.asm"))
	return int(m.group(1)), int(m.group(2))


def walk(game, direction, until, limit=12):
	"""Step until a condition holds (a warp can take a step or two to fire)."""
	for _ in range(limit):
		if until():
			return
		game.step(direction)
	game.wait(60)
	assert until(), "never got there walking %s; at %s on %s" % (direction, game.position(), game.current_map())


def into(game, map_const):
	return lambda: game.in_map(map_const)


# Data

@pytest.mark.parametrize("name", [FOREST, SOUTH_GATE, NORTH_GATE])
def test_blocks_match_the_map_size(name):
	label = MAP_FILES[name] + "_Blocks:"
	blocks = read("data/maps/blocks.asm").split("\n")
	i = next(i for i, line in enumerate(blocks) if line.strip() == label)
	path = next(re.search(r'INCBIN "(.+)"', line).group(1) for line in blocks[i:] if "INCBIN" in line)
	w, h = map_size(name)
	assert len((constants.ROOT / path).read_bytes()) == w * h


@pytest.mark.parametrize("name", [FOREST, SOUTH_GATE, NORTH_GATE])
def test_every_warp_has_a_way_back(name):
	"""Each warp lands on a warp that leads back to this map."""
	for x, y, dest, number in warps(name):
		back = warps(dest)
		assert 1 <= number <= len(back), (name, x, y, dest, number)
		assert back[number - 1][2] == name, (name, x, y, "lands on", back[number - 1])


def test_route_2_has_both_gate_doors():
	route = warps("ROUTE_2")
	assert (1, 9, NORTH_GATE, 1) in route and (2, 9, NORTH_GATE, 2) in route
	assert (3, 33, SOUTH_GATE, 3) in route


def grass_table(name):
	text = read("data/wild/kanto_grass.asm")
	block = re.search(r"def_grass_wildmons %s\n(.*?)end_grass_wildmons" % name, text, re.S).group(1)
	rates = re.search(r"db (.+?) ; encounter rates", block).group(1)
	mons = [(int(lv), sp) for lv, sp in re.findall(r"dbw (\d+), (\w+)", block)]
	return rates, mons


def test_grass_is_red_and_blues_with_yellows_pidgeotto():
	rates, mons = grass_table(FOREST)
	assert rates == "1 percent, 1 percent, 1 percent"
	day = [(4, "CATERPIE"), (4, "WEEDLE"), (5, "METAPOD"), (5, "KAKUNA"), (6, "KAKUNA"),
		(3, "PIKACHU"), (9, "PIDGEOTTO")]
	assert mons == day * 3, "the same table morning, day and night"


def test_no_water_table():
	for path in ("data/wild/kanto_water.asm", "data/wild/johto_water.asm"):
		assert "def_water_wildmons %s\n" % FOREST not in read(path)


def test_four_wanderers_and_four_objects():
	text = read("data/wild/overworld_mons.asm")
	block = re.search(r"def_ow_wildmons %s\n(.*?)end_ow_wildmons" % FOREST, text, re.S).group(1)
	assert re.search(r"db 4 ; how many", block)
	assert text.count("def_ow_wildmons %s\n" % FOREST) == 1, "grass only"
	objects = re.findall(r"SPRITE_OW_MON_(\d)", read("maps/ViridianForest.asm"))
	assert objects == ["1", "2", "3", "4"]


def test_landmark_follows_route_2():
	"""The Town Map cursor walks the landmarks in number order, so the forest comes after Route 2."""
	text = read("constants/landmark_constants.asm")
	order = re.findall(r"^\s*const (LANDMARK_\w+)", text, re.M)
	assert order[order.index("LANDMARK_ROUTE_2") + 1] == "LANDMARK_VIRIDIAN_FOREST"
	rows = re.findall(r"^\s*landmark\s+\d+,\s*\d+,\s*(\w+)Name", read("data/maps/landmarks.asm"), re.M)
	assert rows[rows.index("Route2") + 1] == "ViridianForest", "its Town Map row in the same order"


def test_landmark_numbers():
	route_2 = global_constant("LANDMARK_ROUTE_2")
	assert global_constant("LANDMARK_VIRIDIAN_FOREST") == route_2 + 1
	assert global_constant("LANDMARK_PEWTER_CITY") == route_2 + 2


# In game

def test_route_2_south_through_the_gate_into_the_forest(game):
	game.warp("ROUTE_2", 3, 34)
	walk(game, "up", into(game, SOUTH_GATE))
	assert game.position() == (4, 7)
	walk(game, "up", into(game, FOREST))
	assert game.position() == (18, 49)
	assert game.peek("wCurLandmark") == global_constant("LANDMARK_VIRIDIAN_FOREST")


def test_forest_south_exit_back_to_route_2(game):
	game.warp(FOREST, 18, 48)
	walk(game, "down", into(game, SOUTH_GATE))
	assert game.position() in ((4, 0), (5, 0))
	walk(game, "down", into(game, "ROUTE_2"))
	game.wait(60)
	assert game.position() in ((3, 33), (3, 34))


def test_forest_north_exit_to_route_2(game):
	game.warp(FOREST, 3, 3)
	walk(game, "up", into(game, NORTH_GATE))
	assert game.position() == (4, 7)
	walk(game, "up", into(game, "ROUTE_2"))
	assert game.position() in ((1, 9), (1, 8))


def test_route_2_north_through_the_gate_into_the_forest(game):
	game.warp("ROUTE_2", 1, 8)
	walk(game, "down", into(game, NORTH_GATE))
	assert game.position() == (4, 0)
	walk(game, "down", into(game, FOREST))
	assert game.position() == (3, 2)


def test_entering_shows_the_forests_name(game):
	"""The sign draws its name from wStringBuffer1 into tiles of its own, which the tilemap text
	doesn't show, so this reads the name it was given."""
	game.warp(SOUTH_GATE, 4, 1)
	walk(game, "up", into(game, FOREST))
	game.wait(20)
	assert game.peek("wLandmarkSignTimer") or game.peek("wLandmarkSignTimer", 1), "the sign is up"
	chars = constants.charmap()
	name = "".join(chars.get(b, "?") for b in game.peek("wStringBuffer1", 0, 20)).split("@")[0]
	assert name.replace("<BSP>", " ") == "VIRIDIAN FOREST", name


def rom_palette(game, symbol, index):
	bank, address = game.pyboy.symbol_lookup(symbol)
	data = [game.pyboy.memory[bank, address + index * 8 + i] for i in range(8)]
	return [data[i] | data[i + 1] << 8 for i in range(0, 8, COLOR_SIZE)]


def test_water_slot_is_the_forests_own_for_the_time_of_day(game):
	"""The test ROM's clock reads day, which a map pinned to night would ignore. A warp resets the
	time from the clock, so other times of day can't be poked in."""
	game.warp(FOREST, 18, 48)
	time = game.peek("wTimeOfDayPal") & 3
	assert time == game.peek("wTimeOfDay") != NITE, "the forest follows the clock"
	assert palette(game, "wBGPals1", PAL_BG_WATER) == rom_palette(game, "ViridianForestPals", time)


def test_ilex_forest_keeps_its_water(game):
	game.warp("ILEX_FOREST", 3, 42)
	water = palette(game, "wBGPals1", PAL_BG_WATER)
	assert water != rom_palette(game, "ViridianForestPals", NITE)
	# DungeonColors' nite water row in bg_tiles.pal
	assert water == rom_palette(game, "TilesetBGPalette", 0x13)


@pytest.mark.parametrize("name,x,y", [(FOREST, 18, 48), ("ILEX_FOREST", 3, 42)])
def test_both_forests_play_tcg_club_2(game, name, x, y):
	game.warp(name, x, y)
	game.wait(30)
	club_2 = global_constant("MUSIC_TCG_CLUB_2")
	assert game.peek("wMapMusic") == club_2
	assert game.peek("wMusicID") == club_2, "the song actually playing"


def test_item_balls_wait_for_a_player_who_owns_every_color(game):
	"""The forest's item flags once took the numbers of the stylist's color flags, so a save that
	owned those colors found the balls already taken."""
	colors = [name for name in constants.event_flags() if name.startswith("EVENT_OWNS_PLAYER_COLOR_")]
	assert colors
	for name in colors:
		game.set_event_flag(name)
	game.warp(FOREST, 18, 48)
	for ball in ("VIRIDIANFOREST_MAX_POTION", "VIRIDIANFOREST_MAX_ETHER", "VIRIDIANFOREST_REVIVE"):
		assert game.object_shown("ViridianForest", ball), ball


ROUTE_2_ITEMS = {"MAX_POTION": "EVENT_ROUTE_2_MAX_POTION", "MAX_ETHER": "EVENT_ROUTE_2_HIDDEN_MAX_ETHER",
	"REVIVE": "EVENT_ROUTE_2_HIDDEN_REVIVE", "FULL_RESTORE": "EVENT_ROUTE_2_HIDDEN_FULL_RESTORE",
	"FULL_HEAL": "EVENT_ROUTE_2_HIDDEN_FULL_HEAL"}


def test_route_2s_items_moved_here_on_their_own_flags():
	"""Route 2's items (all but the Dire Hit) moved into the forest, keeping their flags."""
	text = read("maps/ViridianForest.asm")
	balls = dict(re.findall(r"^(\w+):\n\titemball (\w+)", text, re.M))
	hidden = re.findall(r"^\thiddenitem (\w+), (\w+)", text, re.M)
	objects = re.findall(r"OBJECTTYPE_ITEMBALL, 0, (\w+), (\w+)", text)
	found = {balls[label]: flag for label, flag in objects}
	found.update(dict(hidden))
	assert found == ROUTE_2_ITEMS


def test_route_2s_items_are_found_in_the_forest(game):
	game.warp(FOREST, 18, 48)
	for ball in ("VIRIDIANFOREST_MAX_POTION", "VIRIDIANFOREST_MAX_ETHER", "VIRIDIANFOREST_REVIVE"):
		assert game.object_shown("ViridianForest", ball), ball
	game.set_event_flag("EVENT_ROUTE_2_MAX_POTION")
	game.warp(FOREST, 18, 47)
	assert not game.object_shown("ViridianForest", "VIRIDIANFOREST_MAX_POTION"), 		"picked up on Route 2 already"


# The RB Pikachu swarm

def test_rb_pikachu_swarm_row():
	"""Appended last, since a swarm's id is what the save holds."""
	ids = re.findall(r"const (SWARM_\w+)\s*; (\d+)", read("constants/swarm_constants.asm"))
	assert ids[-1] == ("SWARM_PIKACHU_RB", "25")
	rows = re.findall(r"^\tswarm_def (.+)$", read("data/wild/swarms.asm"), re.M)
	assert [c.strip() for c in rows[-1].split(",")] == ["PIKACHU", "PIKACHU_RB_FORM", FOREST, "SWARM_GRASS"]


def test_rb_pikachu_swarms_the_forests_grass(game):
	from harness import alt_shiny as A
	from test_alt_shiny import swarm_ids
	game.poke("wActiveSwarms", swarm_ids()["SWARM_PIKACHU_RB"])
	group, number = constants.maps()[FOREST]
	out = A.call(game, "GetSwarmSpeciesForMap", bc=global_constant("SWARM_GRASS") << 8, de=group << 8 | number)
	assert out["f"] & 0x10, "the forest is swarming"
	assert out["de"] == A.pokemon_index("PIKACHU")
	assert out["a"] == global_constant("PIKACHU_RB_FORM")
	out = A.call(game, "GetSwarmSpeciesForMap", bc=global_constant("SWARM_WATER") << 8, de=group << 8 | number)
	assert not out["f"] & 0x10, "grass only"


def test_hidden_grove_has_no_rb_pikachu():
	text = read("data/wild/mon_populations.asm")
	block = re.search(r"def_population HIDDEN_GROVE,(.*?)end_population", text, re.S).group(1)
	mons = re.findall(r"pop_mon\s+(\d+),\s*(\w+)", block)
	assert "PIKACHU" not in [m for _, m in mons]
	assert [int(w) for w, _ in mons] == [15, 15, 14, 14, 14, 14, 14]
