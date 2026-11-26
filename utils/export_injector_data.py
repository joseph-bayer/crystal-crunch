#!/usr/bin/env python3
"""Export the game data the Crystal Crunch Starter Injector checks a pack against.

usage: python utils/export_injector_data.py --release 2.0 --out <dir> [--rom pokecrystal.gbc] [--rgbasm <path>]

Writes <dir>/game.json: the release's types, moves, TMs/HMs/tutor moves, items, growth rates,
gender ratios, egg groups, evolution methods, cries, the name characters and every species with
its forms (and which are genderless), what it evolves into and whether it has an alternate
shiny, with its base stats, moves and icon colors, and its art under <dir>/art/ for the page's
previews. With --rom, also <dir>/inject.json: that built ROM's injection map (utils/injection_map.py).
Names come from the source files; every number
comes from rgbasm itself, so the export can't drift from what the build assembles.
"""

import argparse
import json
import re
import struct
import subprocess
import sys
import tempfile
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FORMAT = 1

# Species whose forms the injector never offers.
UNOFFERED_FORM_SPECIES = ["SHUCKLE"]

# Forms that hang on a move: the game gives the form to a Pikachu that knows the move and takes it
# away when the move is forgotten (engine/pokemon/learn.asm, engine/events/move_deleter.asm), so a
# starter in one of these forms has to know its move.
FORM_MOVES = {"PIKACHU_SURF_FORM": "SURF", "PIKACHU_FLY_FORM": "FLY"}

# The music commands a custom cry may use, by the names of their command bytes.
CRY_COMMANDS = ["duty_cycle_pattern", "duty_cycle", "pitch_sweep", "pitch_offset", "sound_loop", "sound_call",
	"sound_jump", "sound_ret"]

# The room each new species slot has (constants/injector_constants.asm), as the validator's limits.
ROOM_LIMITS = ["INJECTOR_FRONT_TILES", "INJECTOR_FRONT_FRAMES", "INJECTOR_EVOLUTIONS", "INJECTOR_LEVEL_UP_MOVES",
	"INJECTOR_EGG_MOVES", "INJECTOR_ANIM_ROOM", "INJECTOR_IDLE_ROOM", "INJECTOR_CRY_ROOM"]

# Characters a species name may use beyond a nickname's: the box naming screen's extras.
APOSTROPHE = "'"


def camel(name):
	first, *rest = name.lower().split("_")
	return first + "".join(w.title() for w in rest)


def read(path):
	return (ROOT / path).read_text(encoding="utf-8")


def consts_between(text, start=None, end=None):
	"""The `const NAME` names in text, from the first line matching start to the first matching end."""
	lines = text.splitlines()
	names, on = [], start is None
	for line in lines:
		if not on:
			on = re.search(start, line) is not None
			continue
		if end and re.search(end, line):
			break
		m = re.match(r"\s*const\s+(\w+)", line)
		if m:
			names.append(m.group(1))
	return names


def strings_of(text, pattern):
	return [m.group(1) for m in re.finditer(pattern, text, re.M)]


def values(names, rgbasm, defs=None):
	"""Every name's value, as rgbasm evaluates it with the build's preincludes. `defs` names
	expressions to evaluate too: {name: expression}."""
	defs = defs or {}
	names = list(names) + list(defs)
	with tempfile.TemporaryDirectory() as tmp:
		probe = Path(tmp) / "probe.asm"
		probe.write_text("".join("DEF %s EQU %s\n" % kv for kv in defs.items())
			+ "".join('PRINTLN "%s={d:%s}"\n' % (n, n) for n in names))
		out = subprocess.run([rgbasm, "-Q8", "-P", "includes.asm", "-o", str(Path(tmp) / "probe.o"), str(probe)],
			cwd=ROOT, capture_output=True, text=True)
	if out.returncode:
		sys.exit("rgbasm failed:\n" + out.stderr)
	got = dict(line.split("=", 1) for line in out.stdout.split())
	return {n: int(got[n]) for n in names}


def text_of(s):
	"""A db/li string as the game shows it: padding @s dropped."""
	return s.rstrip("@")


def blank_png(width, height):
	"""An all-white PNG: 1-bit grayscale, every pixel 1."""
	def chunk(kind, data):
		return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data) & 0xffffffff)
	row = b"\x00" + b"\xff" * ((width + 7) // 8)
	return (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 1, 0, 0, 0, 0))
		+ chunk(b"IDAT", zlib.compress(row * height)) + chunk(b"IEND", b""))


def main():
	ap = argparse.ArgumentParser()
	ap.add_argument("--release", required=True)
	ap.add_argument("--out", required=True)
	ap.add_argument("--rgbasm", default="rgbasm")
	ap.add_argument("--rom", help="also write inject.json, the injection map of this built ROM (its .sym beside it)")
	args = ap.parse_args()

	# Types: the 17 real ones, without BIRD and CURSE_TYPE.
	type_consts = [n for n in consts_between(read("constants/type_constants.asm"), r"const_def")
		if n not in ("BIRD", "CURSE_TYPE")]
	type_label_names = dict(re.findall(r'^(\w+):\s+db "([^"]*)"', read("data/types/names.asm"), re.M))
	# Each type's TypeNames label is its constant in title case (PSYCHIC_TYPE: Psychic).
	type_rows = [n.removesuffix("_TYPE").title() for n in type_consts]

	move_consts = consts_between(read("constants/move_constants.asm"), r"const_def", r"DEF NUM_ATTACKS")[1:]
	move_names = strings_of(read("data/moves/names.asm"), r'^\tli "([^"]*)"')

	item_text = read("constants/item_constants.asm")
	item_consts = [n for n in consts_between(item_text, r"const_def", r"DEF NUM_ITEMS EQU") if n != "NO_ITEM"]
	item_names = {}
	for m in re.finditer(r'^\tli "([^"]*)"\s*;\s*([0-9A-Fa-f]{4})', read("data/items/names.asm"), re.M):
		item_names[int(m.group(2), 16)] = m.group(1)
	teach = [(m.group(1).upper(), m.group(2)) for m in re.finditer(r"^\tadd_(tm|hm|mt)\s+(\w+)", item_text, re.M)]

	pdc = read("constants/pokemon_data_constants.asm")
	growth = re.findall(r"const (GROWTH_\w+)", pdc)
	genders = re.findall(r"DEF (GENDER_\w+)\s+EQU", pdc)
	eggs = re.findall(r"const (EGG_\w+)", pdc)
	methods = re.findall(r"const (EVOLVE_\w+)", pdc)
	happiness = re.findall(r"const (TR_\w+)", pdc)
	stat = re.findall(r"const (ATK_\w+_DEF)", pdc)
	# The new species slots' cries hold what the starter injector writes, not a base cry to pick
	cries = [c for c in consts_between(read("constants/cry_constants.asm"), r"const_def") if not c.startswith("CRY_NEW_MON_")]
	icon_text = read("constants/icon_constants.asm")
	icon_pals = re.findall(r"const (PAL_ICON_\w+)", icon_text)
	icon_orders = ["ICON_PAL_SWAP", "ICON_PAL_OFFWHITE", "ICON_PAL_INK"]

	mon_text = read("constants/pokemon_constants.asm")
	species = consts_between(mon_text, r"const_def 1", r"DEF NUM_POKEMON")
	species_names = [text_of(s) for s in strings_of(read("data/pokemon/names.asm").split("PokemonNames::")[1], r'^\tdb "([^"]*)"')]
	forms = {}
	for block in re.finditer(r"const_def 0[^\n]*\n(.*?)DEF NUM_(\w+)_FORMS EQU", mon_text, re.S):
		forms[block.group(2)] = re.findall(r"^\s*const (\w+)", block.group(1), re.M)
	# Unown's letters are its forms, listed as UNOWN_A onward up to NUM_UNOWN
	forms["UNOWN"] = re.findall(r"^\s*const (UNOWN_\w+)", mon_text.split("; Unown forms")[1].split("DEF NUM_UNOWN EQU")[0], re.M)
	# Offered: not a form that changes nothing ("looks plain" by its constant: one a species evolves
	# into from a form of its own, or a number kept unused), nor any of an unoffered species'. Their
	# numbers stay theirs; they're only left out of the list.
	looks_plain = set(re.findall(r"^\s*const (\w+)\s*;[^\n]*looks plain", mon_text, re.M))
	forms = {n: [f for f in fs if f not in looks_plain] for n, fs in forms.items() if n not in UNOFFERED_FORM_SPECIES}
	assert set(FORM_MOVES) <= {f for fs in forms.values() for f in fs}, FORM_MOVES
	alt_shiny = set(re.findall(r"^\tdw (\w+)", read("data/pokemon/alt_shiny_palettes.asm"), re.M)) - {"0"}
	rb_forms = set(re.findall(r"^\trb_form\s+\w+,\s*(\w+),", read("data/pokemon/rb_forms.asm"), re.M))
	evos_text = read("data/pokemon/evos_attacks_kanto.asm") + read("data/pokemon/evos_attacks_johto.asm")
	evos_labels = re.findall(r"^\tdw (\w+EvosAttacks)[ \t]*(?:;.*)?$", evos_text, re.M)
	evolves_into = {}
	for label, block in re.findall(r"^[ \t]*(\w+EvosAttacks):\n(.*?)^\s*db 0 ; no more evolutions", evos_text, re.M | re.S):
		evolves_into[label] = re.findall(r"^\s*db\w*\s+EVOLVE_\w+,.*?(\w+)\s*(?:;.*)?$", block, re.M)
	base_files = re.findall(r'INCLUDE "(data/pokemon/base_stats/\w+\.asm)"', read("data/pokemon/base_stats.asm"))
	gender_of = [re.search(r"db (GENDER_\w+)", read(f)).group(1) for f in base_files]

	charmap_text = read("constants/charmap.asm").split("newcharmap")[0]
	charmap = {}
	for key, val in re.findall(r'charmap\s+"([^"]+)",\s*\$([0-9a-fA-F]{2})', charmap_text):
		charmap.setdefault(key, int(val, 16))
	inputs = read("data/text/name_input_chars.asm")

	def input_chars(label):
		block = inputs.split(label + ":")[1].split("\n\n")[0]
		chars = set()
		for row in strings_of(block, r'^\tdb "([^"]*)"'):
			chars.update(t for t in row.split(" ") if len(t) == 1)
		return chars

	nickname_chars = input_chars("NameInputLower") | input_chars("NameInputUpper") | {" "}
	name_chars = nickname_chars | input_chars("BoxNameInputLower") | input_chars("BoxNameInputUpper") | {APOSTROPHE}

	# Every number, from rgbasm.
	wanted = (type_consts + move_consts + item_consts + growth + genders + eggs + methods + happiness
		+ stat + cries + icon_pals + icon_orders + species + [f for fs in forms.values() for f in fs]
		+ [move + "_TMNUM" for _, move in teach]
		+ ["FIRST_KEY_ITEM", "FIRST_BALL_ITEM", "NUM_BALL_ITEM_POCKET", "NUM_POKEMON", "NUM_ATTACKS",
			"NUM_ORIGINAL_POKEMON", "NUM_NEW_MONS",
			"MON_NAME_LENGTH", "NAME_LENGTH", "SHINY_MASK", "ALT_SHINY_MASK", "FORM_MASK"]
		+ [c + "_cmd" for c in CRY_COMMANDS] + ROOM_LIMITS)
	v = values(wanted, args.rgbasm)

	assert len(move_names) == v["NUM_ATTACKS"] == len(move_consts), (len(move_names), len(move_consts))
	assert len(species_names) == v["NUM_POKEMON"] == len(species) == len(gender_of) == len(evos_labels)
	assert rb_forms <= {f for fs in forms.values() for f in fs}, rb_forms

	def ball(value):
		return v["FIRST_BALL_ITEM"] <= value < v["FIRST_BALL_ITEM"] + v["NUM_BALL_ITEM_POCKET"]

	def holdable(value):
		return value < v["FIRST_KEY_ITEM"] or ball(value)

	items = []
	for n in item_consts:
		name = item_names.get(v[n])
		if name is None or name == "TERU-SAMA":
			continue
		# ball: one a Pokémon can be caught in, the starter's included
		items.append({"id": n, "name": name, "value": v[n], "holdable": holdable(v[n]), "ball": ball(v[n])})

	tm_count = {"TM": 0, "HM": 0, "MT": 0}
	teachable = []
	for kind, move in teach:
		tm_count[kind] += 1
		teachable.append({"move": move, "kind": {"TM": "tm", "HM": "hm", "MT": "tutor"}[kind], "number": tm_count[kind],
			"bit": v[move + "_TMNUM"] - 1}) # its bit in the base data's TM/HM/tutor flags

	def enum(names):
		return [{"id": n, "value": v[n]} for n in names]

	# The new slots hold a placeholder in the plain build: they are listed apart, not as species.
	new_slots = [n for n in species if v[n] > v["NUM_ORIGINAL_POKEMON"]]
	assert len(new_slots) == v["NUM_NEW_MONS"], new_slots
	mons = []
	for n, name, gender, evos in zip(species, species_names, gender_of, evos_labels):
		if n in new_slots:
			continue
		entry = {"id": n, "name": name, "value": v[n], "gender": gender, "altShiny": n in alt_shiny,
			"evolvesInto": evolves_into[evos]}
		if n in forms:
			entry["forms"] = [{"id": f, "value": v[f]} | ({"genderless": True} if f in rb_forms else {})
				| ({"move": FORM_MOVES[f]} if f in FORM_MOVES else {}) for f in forms[n]]
		mons.append(entry)
	# What the page shows of each: stats, moves, icon colors, and its art copied beside the data
	out = Path(args.out)
	out.mkdir(parents=True, exist_ok=True)
	from injector_species import details
	shown = details(species, forms, {f: v[f] for fs in forms.values() for f in fs}, base_files, evos_labels, set(new_slots), out)
	# A new custom species starts with a blank footprint
	(out / "art/default").mkdir(parents=True, exist_ok=True)
	(out / "art/default/footprint.png").write_bytes(blank_png(16, 16))
	for m in mons:
		m.update(shown[m["id"]])
	known = {m["id"] for m in mons}
	for m in mons:
		assert set(m["evolvesInto"]) <= known, (m["id"], m["evolvesInto"])

	game = {
		"format": FORMAT,
		"release": args.release,
		"commit": subprocess.run(["git", "rev-parse", "HEAD"], cwd=ROOT, capture_output=True, text=True).stdout.strip(),
		"limits": {
			"speciesNameLength": v["NAME_LENGTH"] - 1,
			"nicknameLength": v["MON_NAME_LENGTH"] - 1,
			"newSpeciesSlots": v["NUM_NEW_MONS"],
			"starterLevel": 5,
			# Each new species slot's room: what one custom Pokémon can have
			"room": {camel(n.removeprefix("INJECTOR_")): v[n] for n in ROOM_LIMITS},
		},
		"formMasks": {"shiny": v["SHINY_MASK"], "altShiny": v["ALT_SHINY_MASK"], "form": v["FORM_MASK"]},
		"cryCommands": {c: v[c + "_cmd"] for c in CRY_COMMANDS},
		"nameChars": {c: charmap[c] for c in sorted(name_chars) if c in charmap or c == " "} | {" ": 0x7F},
		"nicknameChars": "".join(sorted(nickname_chars)),
		# The game's characters, for the text the injector writes (the Pokédex entry): "#" is POKé,
		# "'s" and the like are one character each, "<NEXT>" breaks a line and "@" ends a page
		"charmap": {c: b for c, b in charmap.items() if not c.startswith("<") or c == "<NEXT>"},
		"types": [{"id": n, "name": text_of(type_label_names[l]), "value": v[n]} for n, l in zip(type_consts, type_rows)],
		"moves": [{"id": n, "name": name, "value": v[n]} for n, name in zip(move_consts, move_names)],
		"teachable": teachable,
		"items": items,
		"growthRates": enum(growth),
		"genderRatios": enum(genders),
		"eggGroups": enum(eggs),
		"evolutionMethods": enum(methods),
		"happinessTriggers": enum(happiness),
		"statTriggers": enum(stat),
		"cries": enum(cries),
		"iconPalettes": enum(icon_pals),
		"iconPaletteOrderFlags": enum(icon_orders),
		"species": mons,
		"newSpecies": enum(new_slots),
		# Art a new custom species starts with, beside the data
		"defaultArt": {"footprint": "art/default/footprint.png"},
	}
	missing = sorted(name_chars - set(game["nameChars"]))
	assert not missing, missing
	out = Path(args.out)
	out.mkdir(parents=True, exist_ok=True)
	(out / "game.json").write_text(json.dumps(game, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")
	print("wrote", out / "game.json")
	if args.rom:
		from injection_map import build_map
		rom = Path(args.rom) if Path(args.rom).is_absolute() else ROOT / args.rom
		(out / "inject.json").write_text(json.dumps(build_map(rom, args.rgbasm), indent="\t") + "\n", encoding="utf-8")
		print("wrote", out / "inject.json")


if __name__ == "__main__":
	main()
