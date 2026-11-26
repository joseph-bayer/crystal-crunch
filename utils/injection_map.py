#!/usr/bin/env python3
"""Write the starter injector's map of a built ROM: where every table's rows and every new species
slot's room are, and which bytes an injection may change.

usage: python utils/injection_map.py --rom pokecrystal.gbc --out inject.json [--rgbasm <path>]

The ROM's .sym sits beside it. Every address comes from the .sym and every size from rgbasm, and each
slot's rows are checked against the placeholder they point at in the plain build, so a table read
at the wrong offset fails here rather than in a player's game.
"""

import argparse
import hashlib
import json
import re
from pathlib import Path

from export_injector_data import ROOT, camel, read, values

FORMAT = 1
GLOBAL_CHECKSUM = 0x14E # two bytes, big-endian
EVO_ROW_LENGTH = 5 # the longest evolution row: method, item word, species word


def read_symbols(sym):
	out = {}
	for line in sym.read_text(encoding="utf-8").splitlines():
		m = re.match(r"^([0-9a-f]{2}):([0-9a-f]{4}) (\S+)$", line.strip())
		if m:
			out[m.group(3)] = (int(m.group(1), 16), int(m.group(2), 16))
	return out


def file_offset(bank, address):
	return address if address < 0x4000 else bank * 0x4000 + address - 0x4000


def charmap_bytes(text):
	charmap = {}
	for key, val in re.findall(r'charmap\s+"([^"]+)",\s*\$([0-9a-fA-F]{2})', read("constants/charmap.asm").split("newcharmap")[0]):
		charmap.setdefault(key, int(val, 16))
	return bytes(charmap[c] for c in text)


def gbc_colors(rgb_text):
	out = b""
	for r, g, b in re.findall(r"RGB (\d+), (\d+), (\d+)", rgb_text):
		out += (int(r) | int(g) << 5 | int(b) << 10).to_bytes(2, "little")
	return out


# Each species table: its label, the species index its first row is for, and its row width.
# Evolutions and egg moves are split into a Kanto and a Johto block (indirect tables).
TABLES = {
	"names": [("PokemonNames", 1, "NAME_LENGTH - 1")],
	"baseData": [("BaseData1", 1, "BASE_DATA_SIZE")],
	"evosAttacks": [("EvosAttacksPointers1", 1, "2"), ("EvosAttacksPointers2", "NUM_KANTO_POKEMON + 1", "2")],
	"eggMoves": [("EggMovePointers1", 1, "2"), ("EggMovePointers2", "NUM_KANTO_POKEMON + 1", "2")],
	"dexEntries": [("PokedexDataPointerTable", 1, "3")],
	"pics": [("PokemonPicPointers", 0, "6")],
	"palettes": [("PokemonPalettes", 0, "8")],
	"cries": [("PokemonCries", 1, "MON_CRY_LENGTH")],
	"icons": [("IconPointers", 0, "2")],
	"iconPaletteOrders": [("IconPaletteOrders", 1, "1")],
	"footprints": [("Footprints", 1, "TILE_1BPP_SIZE * 4")],
	"firstStages": [("FirstEvoStages", 1, "2")],
	"anims": [("AnimationPointers", 1, "2")],
	"idles": [("AnimationIdlePointers", 1, "2")],
	"bitmasks": [("BitmasksPointers", 1, "2")],
	"frames": [("FramesPointers", 1, "3")],
}

# Each slot's room: its label and the size of one slot's share.
ROOMS = {
	"front": ("InjectorFrontpicRoom", "INJECTOR_FRONT_ROOM"),
	"back": ("InjectorBackpicRoom", "INJECTOR_BACK_ROOM"),
	"evosAttacks": ("InjectorEvosAttacksRoom", "INJECTOR_EVOS_ROOM"),
	"eggMoves": ("InjectorEggMovesRoom", "INJECTOR_EGG_MOVES_ROOM"),
	"anim": ("InjectorAnimRoom", "INJECTOR_ANIM_ROOM"),
	"idle": ("InjectorIdleRoom", "INJECTOR_IDLE_ROOM"),
	"bitmask": ("InjectorBitmaskRoom", "INJECTOR_BITMASK_ROOM"),
	"frames": ("InjectorFramesRoom", "INJECTOR_FRAMES_ROOM"),
	"dexEntry": ("InjectorDexEntryRoom", "INJECTOR_DEX_ENTRY_ROOM"),
	"icon": ("InjectorIconRoom", "INJECTOR_ICON_ROOM"),
	"cry": ("InjectorCryRoom", "INJECTOR_CRY_ROOM"),
}

STARTER = ["InjectedStarterSpecies", "InjectedStarterForm", "InjectedStarterItem", "InjectedStarterDVs",
	"InjectedStarterMoves", "InjectedStarterNickname", "InjectedStarterRival", "InjectedStarterBall", "InjectedStarterEnd"]

BASE_FIELDS = ["BASE_STATS", "BASE_EVS", "BASE_TYPES", "BASE_CATCH_RATE", "BASE_EXP", "BASE_ITEMS", "BASE_GENDER",
	"BASE_EGG_STEPS", "BASE_PIC_SIZE", "BASE_FRONTPIC", "BASE_BACKPIC", "BASE_GROWTH_RATE", "BASE_EGG_GROUPS", "BASE_TMHM"]

LIMITS = ["INJECTOR_FRONT_TILES", "INJECTOR_FRONT_FRAMES", "INJECTOR_EVOLUTIONS", "INJECTOR_LEVEL_UP_MOVES",
	"INJECTOR_EGG_MOVES", "INJECTOR_ANIM_ROOM", "INJECTOR_IDLE_ROOM", "INJECTOR_CRY_ROOM"]


def build_map(rom_path, rgbasm):
	rom = rom_path.read_bytes()
	sym = read_symbols(rom_path.with_suffix(".sym"))
	mon_text = read("constants/pokemon_constants.asm")
	new_slots = [n for n in re.findall(r"^\tconst (NEW_MON_\d+)", mon_text, re.M)]
	species_names = re.findall(r"^\tconst (\w+)", mon_text.split("\tconst_def 1", 1)[1], re.M)
	exprs = sorted({e for blocks in TABLES.values() for _, first, width in blocks for e in (str(first), width)}
		| {size for _, size in ROOMS.values()} | set(BASE_FIELDS) | set(LIMITS))
	names = {e: "_x%d" % i for i, e in enumerate(exprs)}
	extra = (["EVOLVE_LEVEL", "EVOLVE_HAPPINESS", "NUM_NEW_MONS", "NUM_ORIGINAL_POKEMON", "INJECTOR_EXTENSION_EVOS_ROOM", "CRY_NEW_MON_1", "CRY_PIDGEY",
		"ICON_PAL_NORMAL", "MON_NAME_LENGTH", "NUM_MOVES"] + new_slots)
	v = values(extra, rgbasm, defs={names[e]: e for e in exprs})
	value = lambda e: v[names[e]]

	def at(label):
		bank, address = sym[label]
		return {"bank": bank, "address": address, "offset": file_offset(bank, address)}

	def word(offset):
		return rom[offset] | rom[offset + 1] << 8

	tables = {}
	for name, blocks in TABLES.items():
		tables[name] = [at(label) | {"first": value(str(first)), "width": value(width)} for label, first, width in blocks]

	def row(table, index):
		block = [b for b in tables[table] if b["first"] <= index][-1]
		return block["offset"] + (index - block["first"]) * block["width"]

	# The plain build's slots point at the shared placeholder: check every table against it.
	placeholder_dba = lambda label: bytes([sym[label][0]]) + sym[label][1].to_bytes(2, "little")
	placeholder_dw = lambda label: sym[label][1].to_bytes(2, "little")
	gbcpal = (ROOT / "gfx/pokemon/new_mon/normal.gbcpal").read_bytes()[2:6]
	expect = {
		"names": charmap_bytes("?????@@@@@"),
		"evosAttacks": placeholder_dw("NewMonEvosAttacks"),
		"eggMoves": placeholder_dw("NoEggMoves2"),
		"dexEntries": placeholder_dba("NewMonPokedexEntry"),
		"pics": placeholder_dba("NewMonFrontpic") + placeholder_dba("NewMonBackpic"),
		"palettes": gbcpal + gbc_colors(read("gfx/pokemon/new_mon/shiny.pal")),
		"cries": bytes(b for x in (v["CRY_PIDGEY"], 255, 383) for b in x.to_bytes(2, "little")),
		"icons": placeholder_dw("NewMonIcon"),
		"iconPaletteOrders": bytes([v["ICON_PAL_NORMAL"]]),
		"footprints": (ROOT / "gfx/footprints/new_mon.1bpp").read_bytes(),
		"anims": placeholder_dw("NewMonAnimation"),
		"idles": placeholder_dw("NewMonAnimationIdle"),
		"bitmasks": placeholder_dw("NewMonBitmasks"),
		"frames": placeholder_dba("NewMonFrames"),
	}
	for slot in new_slots:
		index = v[slot]
		for table, want in expect.items():
			got = rom[row(table, index):row(table, index) + len(want)]
			assert got == want, (slot, table, got.hex(), want.hex())
		assert word(row("firstStages", index)) == index, slot
		stats = rom[row("baseData", index) + value("BASE_STATS"):][:6]
		assert stats == bytes([50] * 6), (slot, stats.hex())
	assert rom[row("names", 1):row("names", 1) + 10] == charmap_bytes("BULBASAUR@")

	rooms = {}
	for name, (label, size) in ROOMS.items():
		room = at(label) | {"size": value(size)}
		end = room["offset"] + room["size"] * len(new_slots)
		assert not any(rom[room["offset"]:end]), name + " room isn't empty"
		rooms[name] = room

	# Each block of the evos table has an extension room in its bank, big enough for any species
	# there with a new evolution into every slot added.
	original = range(1, v["NUM_ORIGINAL_POKEMON"] + 1)
	extension_rooms = [at(label) | {"size": v["INJECTOR_EXTENSION_EVOS_ROOM"]}
		for label in ("InjectorExtensionEvosRoom1", "InjectorExtensionEvosRoom2")]
	for index in original:
		species = species_names[index - 1]
		block = [b for b in tables["evosAttacks"] if b["first"] <= index][-1]
		room = next(r for r in extension_rooms if r["bank"] == block["bank"])
		start = file_offset(block["bank"], word(row("evosAttacks", index)))
		end = start
		while rom[end]: # the evolutions
			end += 4 if rom[end] in (v["EVOLVE_LEVEL"], v["EVOLVE_HAPPINESS"]) else EVO_ROW_LENGTH
		end += 1
		while rom[end]: # the moves
			end += 3
		end += 1
		need = end - start + len(new_slots) * EVO_ROW_LENGTH
		assert need <= room["size"], (species, need, room["size"])

	# A new first stage is the breeding row of every species in the line it starts: each line, by
	# its first stage.
	lines = {}
	for i in original:
		lines.setdefault(species_names[word(row("firstStages", i)) - 1], []).append(i)

	starter = {label.removeprefix("InjectedStarter").lower(): at(label) for label in STARTER}

	# Every byte an injection may change
	writable = []
	for name, blocks in tables.items():
		for slot in new_slots:
			writable.append((row(name, v[slot]), [b for b in blocks if b["first"] <= v[slot]][-1]["width"]))
	for room in rooms.values():
		writable.append((room["offset"], room["size"] * len(new_slots)))
	for room in extension_rooms:
		writable.append((room["offset"], room["size"]))
	for i in original:
		writable.append((row("evosAttacks", i), 2))
	for members in lines.values():
		for i in members:
			writable.append((row("firstStages", i), 2))
	writable.append((starter["species"]["offset"], starter["end"]["offset"] - starter["species"]["offset"]))
	writable = sorted(set(writable))

	outside = bytearray(rom)
	for offset, length in writable:
		outside[offset:offset + length] = bytes(length)
	outside[GLOBAL_CHECKSUM:GLOBAL_CHECKSUM + 2] = bytes(2)

	return {
		"format": FORMAT,
		"rom": rom_path.name,
		"size": len(rom),
		"sha1": hashlib.sha1(rom).hexdigest(),
		"sha1Outside": hashlib.sha1(outside).hexdigest(),
		"slots": [{"id": s, "index": v[s]} for s in new_slots],
		"tables": tables,
		"rooms": rooms,
		"extensionRooms": extension_rooms,
		"firstStageLines": lines,
		"starter": starter,
		"baseData": {camel(f.removeprefix("BASE_")): value(f) for f in BASE_FIELDS} | {"size": value("BASE_DATA_SIZE")},
		"cryNewMon1": v["CRY_NEW_MON_1"],
		"limits": {camel(f.removeprefix("INJECTOR_")): value(f) for f in LIMITS},
		"writable": [{"offset": o, "length": n} for o, n in writable],
	}


def main():
	ap = argparse.ArgumentParser()
	ap.add_argument("--rom", default="pokecrystal.gbc")
	ap.add_argument("--out", required=True)
	ap.add_argument("--rgbasm", default="rgbasm")
	args = ap.parse_args()
	rom = Path(args.rom)
	if not rom.is_absolute():
		rom = ROOT / rom
	out = Path(args.out)
	out.parent.mkdir(parents=True, exist_ok=True)
	out.write_text(json.dumps(build_map(rom, args.rgbasm), indent="\t") + "\n", encoding="utf-8")
	print("wrote", out)


if __name__ == "__main__":
	main()
