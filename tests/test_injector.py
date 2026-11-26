"""The starter injector on the test ROM. Its command line (Crystal Crunch Starter Injector, a separate
repository beside this one, or STARTER_INJECTOR_DIR) writes its test packs into copies of the test
ROM, by the map utils/injection_map.py makes of this build: the Ralts line (a new line of four, with
a gendered stone), Mamoswine (a new last stage after Piloswine), Sylveon (Eevee's line split) and
Azurill (a new first stage before Marill). The copies change only where the map allows, and play as
the packs say. Skipped where the injector or Node isn't on this computer."""

import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import pytest

from harness import Game, new_game_state
from harness import alt_shiny as A
from harness import constants
from harness.followers import index_of_id
from harness.new_game import CACHE
from harness.pokedex import open_pokedex_entry, page_text
from test_dex_forms import wild_battle
from test_injected_starter import CAUGHT_BALL_MASK, EVOLUTION_FRAMES, MON_NAME_LENGTH, SHINY_MASK, caught_ball, nickname

INJECTOR = Path(os.environ.get("STARTER_INJECTOR_DIR", constants.ROOT.parent.parent / "crystal-crunch-starter-injector"))
NODE = shutil.which("node")
RGBASM = os.environ.get("RGBASM") or shutil.which("rgbasm") or "rgbasm"
GLOBAL_CHECKSUM = 0x14e
# Each parallel worker writes its own ROMs, so none reads one another is writing
OUT = CACHE / "injector" / os.environ.get("PYTEST_XDIST_WORKER", "main")
OUT.mkdir(parents=True, exist_ok=True)

pytestmark = pytest.mark.skipif(not NODE or not (INJECTOR / "src/cli/main.ts").exists(),
	reason="the starter injector (and Node) aren't on this computer")


@pytest.fixture(scope="module")
def injection_map(rom):
	"""This worker's map of the test ROM, also copied whole to tests/.cache/injector/inject.json, where
	the injector's own tests read it"""
	out = OUT / "inject.json"
	subprocess.run([sys.executable, str(constants.ROOT / "utils/injection_map.py"), "--rom", str(rom), "--out", str(out),
		"--rgbasm", RGBASM], check=True, capture_output=True, text=True)
	fd, temp = tempfile.mkstemp(dir=OUT.parent, suffix=".tmp")
	with os.fdopen(fd, "wb") as f:
		f.write(out.read_bytes())
	try:
		os.replace(temp, OUT.parent / "inject.json")
	except PermissionError: # another worker's copy, the same map, stands
		os.remove(temp)
	return out


def run_injector(pack, rom, injection_map, out):
	return subprocess.run([NODE, str(INJECTOR / "src/cli/main.ts"), "inject", str(INJECTOR / "fixtures" / pack),
		"--rom", str(rom), "--map", str(injection_map), "-o", str(out)], capture_output=True, encoding="utf-8")


def injected_rom(pack, rom, injection_map):
	out = OUT / (pack + ".gbc")
	result = run_injector(pack, rom, injection_map, out)
	assert result.returncode == 0, result.stdout + result.stderr
	shutil.copyfile(rom.with_suffix(".sym"), out.with_suffix(".sym"))
	return out


@pytest.fixture(scope="module")
def ralts_rom(rom, injection_map):
	return injected_rom("ralts-line", rom, injection_map)


@pytest.fixture(scope="module")
def mamoswine_rom(rom, injection_map):
	return injected_rom("mamoswine", rom, injection_map)


@pytest.fixture(scope="module")
def eevee_rom(rom, injection_map):
	return injected_rom("eevee-branch", rom, injection_map)


@pytest.fixture(scope="module")
def azurill_rom(rom, injection_map):
	return injected_rom("azurill-baby", rom, injection_map)


def play(path):
	game = Game(path)
	game.load_state(new_game_state(path))
	return game


def species_json(pack, species):
	return json.loads((INJECTOR / "fixtures" / pack / "species" / (species + ".json")).read_text(encoding="utf-8"))


# The bytes

@pytest.mark.parametrize("pack", ["ralts-line", "mamoswine"])
def test_an_injection_changes_only_the_bytes_the_map_allows(rom, injection_map, pack):
	out = injected_rom(pack, rom, injection_map)
	allowed = set(range(GLOBAL_CHECKSUM, GLOBAL_CHECKSUM + 2))
	for w in json.loads(injection_map.read_text())["writable"]:
		allowed.update(range(w["offset"], w["offset"] + w["length"]))
	before, after = rom.read_bytes(), out.read_bytes()
	assert len(before) == len(after)
	changed = [i for i, (a, b) in enumerate(zip(before, after)) if a != b]
	assert changed, "the injection changed nothing"
	assert not [i for i in changed if i not in allowed]
	total = sum(after) - after[GLOBAL_CHECKSUM] - after[GLOBAL_CHECKSUM + 1]
	assert after[GLOBAL_CHECKSUM] << 8 | after[GLOBAL_CHECKSUM + 1] == total & 0xffff, "the global checksum is right"


def test_an_injected_rom_or_an_unknown_one_is_refused(rom, injection_map, ralts_rom):
	again = run_injector("ralts-line", ralts_rom, injection_map, OUT / "again.gbc")
	assert again.returncode == 1 and "already has a starter injected" in again.stderr
	other = OUT / "other.gbc"
	data = bytearray(rom.read_bytes())
	data[0x150] ^= 0xff # outside anything the injector writes
	other.write_bytes(data)
	refused = run_injector("ralts-line", other, injection_map, OUT / "never.gbc")
	assert refused.returncode == 1 and "patch your Pokémon Crystal ROM" in refused.stderr


# The Ralts line, a new line

def test_the_new_game_starts_with_the_packs_ralts(ralts_rom):
	game = play(ralts_rom)
	try:
		assert index_of_id(game, game.peek("wPartyMon1Species")) == A.pokemon_index("NEW_MON_1")
		assert game.peek("wPartyMon1Level") == 5
		assert game.peek("wPartyMon1Form") == SHINY_MASK
		assert game.peek("wPartyMon1Item") == A.item_id(game, "BERRY")
		assert tuple(game.peek("wPartyMon1DVs", 0, 2)) == (0x6a, 0xce) # 6, 10, 12, 14
		assert nickname(game) == "Feeler"
		assert game.peek("wPartyMon1CaughtBall") & CAUGHT_BALL_MASK == caught_ball("LOVE_BALL")
		moves = game.peek("wPartyMon1Moves", 0, 4)
		names = {v: k for k, v in constants._consts(constants.ROOT / "constants" / "move_constants.asm").items()}
		indexes = []
		for move_id in moves[:3]:
			low, high = game.peek("wMoveIndexTableEntries", (move_id - 1) * 2, 2)
			indexes.append(names[low | high << 8])
		assert indexes == ["GROWL", "CONFUSION", "DISABLE"] and moves[3] == 0

		# Its stats, from Ralts's base stats and the DVs at level 5
		base = species_json("ralts-line", "ralts")["base"]
		hp_dv = (6 & 1) << 3 | (10 & 1) << 2 | (12 & 1) << 1 | 14 & 1
		stat = lambda b, dv: (b + dv) * 2 * 5 // 100 + 5
		read = lambda symbol: game.peek(symbol) << 8 | game.peek(symbol, 1)
		assert read("wPartyMon1MaxHP") == (base["hp"] + hp_dv) * 2 * 5 // 100 + 5 + 10
		assert read("wPartyMon1Attack") == stat(base["attack"], 6)
		assert read("wPartyMon1Speed") == stat(base["speed"], 12)
		assert read("wPartyMon1SpclAtk") == stat(base["sp_attack"], 14)

		# The rival takes Totodile's line: as if you took Cyndaquil
		A.call(game, "SetInjectedStarterRival")
		assert game.event_flag("EVENT_GOT_CYNDAQUIL_FROM_ELM")
	finally:
		game.close()


def species_name(game, species):
	game.poke("wNamedObjectIndex", A.species_id(game, species))
	A.call(game, "GetPokemonName")
	chars = constants.charmap()
	return "".join(chars[b] for b in game.peek("wStringBuffer1", 0, MON_NAME_LENGTH)).split("@")[0]


def test_each_species_of_the_line_has_its_name(ralts_rom):
	game = play(ralts_rom)
	try:
		for slot, name in zip(["NEW_MON_1", "NEW_MON_2", "NEW_MON_3", "NEW_MON_4"], ["RALTS", "KIRLIA", "GARDEVOIR", "GALLADE"]):
			assert species_name(game, slot) == name
		assert species_name(game, "NEW_MON_5") == "?????", "the slot the pack leaves is still the placeholder"
	finally:
		game.close()


def evolve(game, species, level, dvs, item=None):
	"""Party slot 1 made `species` at `level` with these DVs, then evolved: by the item if given,
	else by level, as after a battle."""
	game.poke("wPartyCount", 1)
	game.poke("wPartySpecies", A.species_id(game, species))
	game.poke("wPartySpecies", 0xff, 1)
	game.poke("wPartyMon1Species", A.species_id(game, species))
	game.poke("wPartyMon1Level", level)
	game.poke("wPartyMon1DVs", dvs[0])
	game.poke("wPartyMon1DVs", dvs[1], 1)
	game.poke("wPartyMon1Item", 0)
	game.poke("wPartyMon1Form", 0)
	game.poke("wCurPartyMon", 0)
	game.poke("wForceEvolution", 1 if item else 0)
	if item:
		game.poke("wCurItem", A.item_id(game, item))
	A.call(game, "EvolvePokemon", press_a_every=30, must_return=False, frames=EVOLUTION_FRAMES, from_main_loop=True)
	return index_of_id(game, game.peek("wPartyMon1Species"))


@pytest.mark.parametrize("species, level, dvs, item, into", [
	("NEW_MON_1", 20, (0xff, 0xff), None, "NEW_MON_2"), # Ralts at 20: Kirlia
	("NEW_MON_1", 19, (0xff, 0xff), None, "NEW_MON_1"),
	("NEW_MON_2", 30, (0xff, 0xff), None, "NEW_MON_3"), # Kirlia at 30: Gardevoir
	("NEW_MON_2", 10, (0xff, 0xff), "SUN_STONE", "NEW_MON_4"), # a male Kirlia and a Sun Stone: Gallade
	("NEW_MON_2", 10, (0x0f, 0x0f), "SUN_STONE", "NEW_MON_2"), # not a female
])
def test_the_line_evolves_as_the_pack_says(ralts_rom, species, level, dvs, item, into):
	game = play(ralts_rom)
	try:
		assert evolve(game, species, level, dvs, item) == A.pokemon_index(into)
	finally:
		game.close()


# Mamoswine, Piloswine's line extended

def evos_and_moves(data, injection_map, species):
	"""A species' evolution rows and its level-up moves block, read through its evos pointer."""
	methods = constants._consts(constants.ROOT / "constants" / "pokemon_data_constants.asm")
	short = (methods["EVOLVE_LEVEL"], methods["EVOLVE_HAPPINESS"])
	index = A.pokemon_index(species)
	block = [b for b in json.loads(injection_map.read_text())["tables"]["evosAttacks"] if b["first"] <= index][-1]
	pointer = block["offset"] + (index - block["first"]) * 2
	start = block["bank"] * 0x4000 + (data[pointer] | data[pointer + 1] << 8) - 0x4000
	at = start
	while data[at]:
		at += 4 if data[at] in short else 5
	end = at + 1
	while data[end]:
		end += 3
	return bytes(data[start:at]), bytes(data[at + 1:end + 1])


def test_piloswine_keeps_its_moves_and_now_evolves_into_mamoswine(mamoswine_rom, rom, injection_map):
	plain_evos, plain_moves = evos_and_moves(rom.read_bytes(), injection_map, "PILOSWINE")
	evos, moves = evos_and_moves(mamoswine_rom.read_bytes(), injection_map, "PILOSWINE")
	assert moves == plain_moves
	assert evos.startswith(plain_evos) and len(evos) == len(plain_evos) + 4, "one EVOLVE_LEVEL row added"
	for level, into in ((39, "PILOSWINE"), (40, "NEW_MON_1")):
		game = play(mamoswine_rom)
		try:
			state = game.save_state() # a direct call leaves the CPU parked: evolve from before it
			assert species_name(game, "NEW_MON_1") == "MAMOSWINE"
			game.load_state(state)
			assert evolve(game, "PILOSWINE", level, (0xff, 0xff)) == A.pokemon_index(into)
		finally:
			game.close()


# Eevee's line split: a new level evolution beside its stones and happiness

@pytest.mark.parametrize("level, item, into", [
	(5, None, "EEVEE"),
	(6, None, "NEW_MON_1"), # the pack's, whose front has 4 frames (a garbled one is caught by the front test)
	(5, "THUNDERSTONE", "JOLTEON"), # its own evolutions still work
	(5, "WATER_STONE", "VAPOREON"),
	(5, "FIRE_STONE", "FLAREON"),
])
def test_eevee_gains_an_evolution_and_keeps_its_own(eevee_rom, level, item, into):
	game = play(eevee_rom)
	try:
		assert evolve(game, "EEVEE", level, (0xff, 0xff), item) == A.pokemon_index(into)
	finally:
		game.close()


def test_eevees_other_evolutions_are_kept_in_its_evolutions_block(eevee_rom, rom, injection_map):
	plain_evos, plain_moves = evos_and_moves(rom.read_bytes(), injection_map, "EEVEE")
	evos, moves = evos_and_moves(eevee_rom.read_bytes(), injection_map, "EEVEE")
	assert moves == plain_moves
	assert evos.startswith(plain_evos) and len(evos) == len(plain_evos) + 4, "one EVOLVE_LEVEL row added"


# Azurill, a new first stage before Marill's line

def egg_from(game, mother):
	"""The egg the day-care makes from `mother` and a Ditto, by the game's own breeding routine"""
	game.poke("wBreedMon1Species", A.species_id(game, mother))
	game.poke("wBreedMon2Species", A.species_id(game, "DITTO"))
	for mon in ("wBreedMon1", "wBreedMon2"):
		game.poke(mon + "DVs", 0)
		game.poke(mon + "DVs", 0, 1)
		game.poke(mon + "Form", 0)
	A.call(game, "DayCare_InitBreeding.UselessJump")
	return index_of_id(game, game.peek("wEggMonSpecies"))


def test_marills_line_lays_azurill_eggs_and_other_lines_their_own(azurill_rom):
	game = play(azurill_rom)
	try:
		assert egg_from(game, "MARILL") == A.pokemon_index("NEW_MON_1")
		assert egg_from(game, "AZUMARILL") == A.pokemon_index("NEW_MON_1")
		assert egg_from(game, "PIKACHU") == A.pokemon_index("PICHU")
	finally:
		game.close()


@pytest.mark.parametrize("level, into", [(9, "NEW_MON_1"), (10, "MARILL")])
def test_azurill_evolves_into_marill(azurill_rom, level, into):
	game = play(azurill_rom)
	try:
		assert evolve(game, "NEW_MON_1", level, (0xff, 0xff)) == A.pokemon_index(into)
	finally:
		game.close()


def test_the_starter_of_an_extension_is_the_existing_species_it_names(mamoswine_rom):
	game = play(mamoswine_rom)
	try:
		assert index_of_id(game, game.peek("wPartyMon1Species")) == A.pokemon_index("SWINUB")
		assert game.peek("wPartyMon1Form") == 0
	finally:
		game.close()


# In the game's own screens

def test_the_pokedex_shows_the_packs_entry(ralts_rom):
	game = play(ralts_rom)
	try:
		open_pokedex_entry(game, "NEW_MON_1")
		text = page_text(game)
		assert "FEELING" in text, text
		assert "RALTS" in game.screen_text()
	finally:
		game.close()


PIC_TILES_SCRIPT = """
import { readFileSync } from "node:fs";
import { pathToFileURL } from "node:url";
const [root, art] = process.argv.slice(1);
const core = (f) => import(pathToFileURL(root + "/src/core/" + f).href);
const { decodePng } = await core("png.ts");
const { front, backTiles, picPalette } = await core("gfx.ts");
const read = (f) => decodePng(new Uint8Array(readFileSync(art + "/" + f)));
const [fr, bk] = [read("front.png"), read("back.png")];
const palette = picPalette([fr, bk]);
console.log(Buffer.from(front(fr, palette).graphics).toString("hex"));
console.log(Buffer.from(backTiles(bk, palette)).toString("hex"));
"""


def pic_tiles(pack, species):
	"""The front's tiles (every frame's) and the back's, as the injector makes them from the pack's art"""
	result = subprocess.run([NODE, "--input-type=module", "-e", PIC_TILES_SCRIPT, str(INJECTOR),
		str(INJECTOR / "fixtures" / pack / "art" / species)], check=True, capture_output=True, encoding="utf-8")
	return [bytes.fromhex(line) for line in result.stdout.split()]


TILE_SIZE = 16


def battle_front(game, slot, length):
	"""The slot's front as the game decompresses it to start a wild battle against it: what
	wDecompressScratch holds when PadFrontpic is about to read it, and the tile count _PrepareFrontpic
	recorded from where decompression stopped"""
	index = A.pokemon_index(slot)
	seen = []

	def capture(_):
		if not seen and index_of_id(game, game.peek("wCurSpecies")) == index:
			count = game.pyboy.memory[0, game.pyboy.symbol_lookup("sEnemyFrontPicTileCount")[1]]
			seen.append((bytes(game.peek("wDecompressScratch", 0, length)), count))

	bank, address = game.pyboy.symbol_lookup("PadFrontpic")
	game.pyboy.hook_register(bank, address, capture, None)
	try:
		wild_battle(game, slot, SHINY_MASK)
	finally:
		game.pyboy.hook_deregister(bank, address)
	assert seen, "the battle never loaded the front"
	return seen[0]


@pytest.mark.parametrize("pack, species, slot, over_512", [
	("ralts-line", "gardevoir", "NEW_MON_3", True), # a new line: 2 frames, 912 bytes
	("mamoswine", "mamoswine", "NEW_MON_1", True), # a line's new last stage: 2 frames, 1120 bytes
	("eevee-branch", "sylveon", "NEW_MON_1", True), # a line split: 4 frames, the case that crashed
	("azurill-baby", "azurill", "NEW_MON_1", False), # a new first stage: 1 frame of 40x40, 400 bytes
])
def test_the_game_loads_each_front_as_the_injector_made_it(rom, injection_map, pack, species, slot, over_512):
	"""The game's decompressor reads at most 512 bytes in one long command. The injector once wrote
	1024, so every pic over 512 bytes (every back pic, every front with frames) came out garbled, and
	a front of three frames ran its pixels as commands and crashed the evolution into it. (The back
	goes through the same decompressor; the injector's own tests read it as the game does.)"""
	out = injected_rom(pack, rom, injection_map)
	front, _ = pic_tiles(pack, species)
	assert (len(front) > 512) == over_512, len(front)
	game = play(out)
	try:
		got, tiles = battle_front(game, slot, len(front))
		assert tiles == len(front) // TILE_SIZE
		assert got == front
	finally:
		game.close()


def test_a_wild_one_battles_with_its_pics_and_stats(ralts_rom):
	game = play(ralts_rom)
	try:
		wild_battle(game, "NEW_MON_3", SHINY_MASK)
		assert index_of_id(game, game.peek("wEnemyMonSpecies")) == A.pokemon_index("NEW_MON_3")
		assert "GARDEVOIR" in game.screen_text()
		base = species_json("ralts-line", "gardevoir")["base"]
		assert list(game.peek("wEnemyMonBaseStats", 0, 4)) == [base[k] for k in ("hp", "attack", "defense", "speed")]
	finally:
		game.close()


def test_a_custom_cry_plays_through_its_slots_own_cry(mamoswine_rom, injection_map):
	m = json.loads(injection_map.read_text())
	data = mamoswine_rom.read_bytes()
	block = m["tables"]["cries"][0]
	row = block["offset"] + (A.pokemon_index("NEW_MON_1") - block["first"]) * block["width"]
	cry, pitch, length = (data[row + i] | data[row + i + 1] << 8 for i in (0, 2, 4))
	assert (cry, pitch, length) == (m["cryNewMon1"], 0, 0x100), "its own cry, at the pitch and length written"
	# The cry's header: three channels, the first being channel 5
	room = m["rooms"]["cry"]
	assert data[room["offset"]] == (3 - 1) << 6 | (5 - 1)


def cry_frames(game, species):
	"""How many frames the species' cry plays: PlayMonCry returns once it's over. (The harness
	doesn't emulate the sound chip, so its output can't be read.)"""
	state = game.save_state()
	before = game.pyboy.frame_count
	A.call(game, "PlayMonCry", a=A.species_id(game, species), from_main_loop=True, frames=600)
	frames = game.pyboy.frame_count - before
	game.load_state(state)
	return frames


def test_a_silent_cry_ends_at_once(ralts_rom):
	game = play(ralts_rom)
	try:
		assert cry_frames(game, "NEW_MON_1") >= 20, "Ralts cries"
		assert cry_frames(game, "NEW_MON_2") <= 3, "Kirlia's cry is silent"
	finally:
		game.close()
