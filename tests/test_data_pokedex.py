"""Data the Pokédex's pages read, checked against the tables it mirrors."""

import re

from harness.data import asm_files, read

FLOOR = re.compile(r"(?:^|_)(B?\d+F)(?=_|$)")
WILD_MAP_TABLES = [
	"data/wild/johto_grass.asm",
	"data/wild/kanto_grass.asm",
	"data/wild/johto_water.asm",
	"data/wild/kanto_water.asm",
	"data/wild/overworld_mons.asm",
	"data/wild/mon_populations.asm",
	"data/wild/treemon_maps.asm",
]
NAME_SLOT = 17 # the AREA page prints a place from column 2 to the frame at column 19


def wild_maps():
	maps = []
	for path in WILD_MAP_TABLES:
		for name in re.findall(r"^\s*(?:def_\w+|treemon_map)\s+(\w+)", read(path), re.M):
			if name not in maps:
				maps.append(name)
	return maps


def map_landmarks():
	"""{map constant: landmark constant}, pairing map_constants.asm with maps.asm in order."""
	constants = re.findall(r"^\s*map_const (\w+),", read("constants/map_constants.asm"), re.M)
	landmarks = re.findall(r"^\s*map \w+, \w+, \w+, (\w+),", read("data/maps/maps.asm"), re.M)
	assert len(constants) == len(landmarks)
	return dict(zip(constants, landmarks))


def landmark_names():
	"""{landmark constant: its name}."""
	order = re.findall(r"^\s*const (LANDMARK_\w+)", read("constants/landmark_constants.asm"), re.M)
	text = read("data/maps/landmarks.asm")
	labels = re.findall(r"^\s*landmark\s+[^,]+,\s*[^,]+,\s*(\w+)", text, re.M)
	strings = dict(re.findall(r'^(\w+):\s*db "([^"]*)@"', text, re.M))
	return {const: strings.get(label, "") for const, label in zip(order, labels)}


def width(text):
	return len(re.sub(r"<[^>]+>", "x", text))


def floor_rows():
	return re.findall(r'^\s*dex_floor (\w+),\s*"([^"]+)"', read("data/maps/dex_floor_names.asm"), re.M)


def test_every_floor_map_has_its_floor():
	expected = [(m, FLOOR.findall(m)[-1]) for m in wild_maps() if FLOOR.findall(m)]
	assert sorted(floor_rows()) == sorted(expected)


def test_place_names_fit_the_area_page():
	landmarks, names = map_landmarks(), landmark_names()
	floors = dict(floor_rows())
	assert names["LANDMARK_ICE_PATH"] == "ICE PATH"
	too_long = []
	for m in wild_maps():
		name = names.get(landmarks[m], "")
		if m in floors:
			name += " " + floors[m]
		if width(name) > NAME_SLOT:
			too_long.append((m, name))
	assert not too_long


def test_field_list_matches_the_field_move_menu():
	menu = re.findall(r"dbbw MONMENU_FIELD_MOVE, \w+,\s*(\w+)", read("data/mon_menu.asm"))
	listed = re.findall(r"^\s*field_move (\w+)", read("engine/pokedex/pokedex_moves_page.asm"), re.M)
	assert sorted(listed) == sorted(menu)


def item_constants():
	return set(re.findall(r"^\s*const (\w+)", read("constants/item_constants.asm"), re.M))


def test_evolution_items_are_items():
	items = item_constants()
	text = read("data/pokemon/evos_attacks_johto.asm") + read("data/pokemon/evos_attacks_kanto.asm")
	params = re.findall(r"dbww EVOLVE_(?:ITEM|TRADE), (\w+),", text)
	assert params
	assert [p for p in params if p not in items and p != "-1"] == []


def test_wild_held_items_are_items():
	items = item_constants() | {"NO_ITEM"}
	bad = []
	paths = asm_files("data/pokemon/base_stats/*.asm")
	assert len(paths) > 250
	for path in paths:
		for pair in re.findall(r"^\s*dw (\w+), (\w+) ; items", read(path), re.M):
			bad += [(path, item) for item in pair if item not in items]
	assert bad == []
