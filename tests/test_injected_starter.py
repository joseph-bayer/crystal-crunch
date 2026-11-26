"""A ROM with a starter injected: the new game starts with it, Elm's lab runs its other scene, the
rival takes the line it names, and the cable club turns it away. The starter injector (a separate
tool) writes the record these tests write by hand into a copy of the test ROM, at the same labels.

Also the new species slots themselves (the Pokédex flags and completion), and the stones that
evolve only one gender."""

import os
import re
import shutil

import pytest

from harness import Game, new_game_state
from harness import alt_shiny as A
from harness import constants
from harness.followers import FOLLOWER_STRUCT, INVISIBLE, OBJECT_FLAGS1, OBJECT_MAP_X, OBJECT_MAP_Y, index_of_id, object_field, objects_with_sprite, sprites
from harness.game import MAPSETUP_WARP, MAPSTATUS_ENTER, SPAWN_N_A
from harness.new_game import CACHE, MAPSTATUS_HANDLE

SHINY_MASK = 0x80
MON_NAME_LENGTH = 11
NUM_ORIGINAL_POKEMON = 251
LANDMARK_MASK = 0x7f
EVOLUTION_FRAMES = 3000
WORKER = os.environ.get("PYTEST_XDIST_WORKER", "main") # this test process, when tests run in parallel

# What the injected tests give the player
DVS = (0x6a, 0xce) # Attack 6, Defense 10, Speed 12, Special 14
NICKNAME = "PAL"
MOVES = ["GROWL", "EMBER"]


def move_index(name):
	return constants._consts(constants.ROOT / "constants" / "move_constants.asm")[name]


def encode(text, length):
	"""Text in the game's characters, padded with "@" to `length`."""
	chars = {c: b for b, c in constants.charmap().items() if len(c) == 1}
	out = [chars[c] for c in text]
	return out + [chars["@"]] * (length - len(out))


def symbol_offset(rom, symbol):
	"""Where a ROM label's bytes are in the file, by the .sym."""
	for line in rom.with_suffix(".sym").read_text(encoding="utf-8").splitlines():
		parts = line.split()
		if len(parts) == 2 and parts[1] == symbol:
			bank, address = (int(x, 16) for x in parts[0].split(":"))
			return address if address < 0x4000 else bank * 0x4000 + address - 0x4000
	raise KeyError(symbol)


def patched_rom(rom, name, patches):
	"""A copy of the test ROM with these {symbol: bytes} written in, beside a copy of its .sym. Each
	parallel worker has its own folder, so none reads a copy another is writing."""
	folder = CACHE / "injected" / WORKER
	folder.mkdir(parents=True, exist_ok=True)
	path = folder / (name + ".gbc")
	data = bytearray(rom.read_bytes())
	for symbol, values in patches.items():
		at = symbol_offset(rom, symbol)
		data[at:at + len(values)] = bytes(values)
	path.write_bytes(data)
	shutil.copyfile(rom.with_suffix(".sym"), path.with_suffix(".sym"))
	return path


def word(value):
	return [value & 0xff, value >> 8]


def starter_record(species, form=0, item="BERRY", dvs=DVS, moves=(), nickname="", rival="TOTODILE", ball=None):
	"""ball: an item; None leaves the build's own, a POKé BALL"""
	move_words = [m for name in moves for m in word(move_index(name))]
	record = {
		"InjectedStarterSpecies": word(A.pokemon_index(species)),
		"InjectedStarterForm": [form],
		"InjectedStarterItem": word(A.item_index(item)),
		"InjectedStarterDVs": list(dvs),
		"InjectedStarterMoves": move_words + [0] * (8 - len(move_words)),
		"InjectedStarterNickname": encode(nickname, MON_NAME_LENGTH), # all "@": the species name
		"InjectedStarterRival": word(A.pokemon_index(rival)),
	}
	if ball:
		record["InjectedStarterBall"] = word(A.item_index(ball))
	return record


def caught_ball(name):
	"""A CAUGHT_<ball> value, as the stats screen reads it from MON_CAUGHTBALL"""
	text = (constants.ROOT / "constants" / "pokemon_data_constants.asm").read_text(encoding="utf-8")
	return int(re.search(r"DEF CAUGHT_%s\s+EQU (\d+)" % name, text).group(1))


@pytest.fixture(scope="module")
def injected_rom(rom):
	record = starter_record("NEW_MON_1", form=SHINY_MASK, moves=MOVES, nickname=NICKNAME)
	return patched_rom(rom, "new_mon_1", record)


@pytest.fixture
def injected(injected_rom):
	"""An injected game standing in the bedroom of a new game."""
	game = Game(injected_rom)
	game.load_state(new_game_state(injected_rom))
	yield game
	game.close()


def idle(game):
	return (game.peek("wMapStatus") == MAPSTATUS_HANDLE and game.peek("wScriptRunning") == 0
		and game.peek("wWindowStackSize") == 0)


def press_until_idle(game, presses=200):
	for _ in range(presses):
		if idle(game):
			game.wait(30)
			if idle(game):
				return
		game.press("a")
	raise AssertionError("the script never finished. The screen:\n" + game.screen_text())


def text_seen(game, text, presses=200):
	"""Press A through a script until `text` is on screen."""
	for _ in range(presses):
		if text in game.screen_text():
			return
		game.press("a")
	raise AssertionError("%r never appeared. The screen:\n%s" % (text, game.screen_text()))


def enter_moving(game, map_name, x, y):
	"""Warp in, for a map whose scene moves the player at once (Game.warp checks where they land)."""
	group, number = constants.maps()[map_name]
	game.poke("wMapGroup", group)
	game.poke("wMapNumber", number)
	game.poke("wXCoord", x)
	game.poke("wYCoord", y)
	game.poke("wDefaultSpawnpoint", SPAWN_N_A)
	game.poke("hMapEntryMethod", MAPSETUP_WARP)
	game.poke("wMapStatus", MAPSTATUS_ENTER)
	game.wait(200)
	assert game.in_map(map_name)


def nickname(game, slot=0):
	chars = constants.charmap()
	raw = game.peek("wPartyMonNicknames", slot * MON_NAME_LENGTH, MON_NAME_LENGTH)
	return "".join(chars[b] for b in raw).split("@")[0]


# The new game

def test_the_new_game_starts_with_the_injected_starter(injected):
	game = injected
	assert game.peek("wPartyCount") == 1
	assert index_of_id(game, game.peek("wPartyMon1Species")) == A.pokemon_index("NEW_MON_1")
	assert game.peek("wPartyMon1Level") == 5
	assert game.peek("wFollowerPartySlot") == 1, "the starter follows from the first step"
	assert game.peek("wPartyMon1Form") == SHINY_MASK
	assert game.peek("wPartyMon1Item") == A.item_id(game, "BERRY")
	assert tuple(game.peek("wPartyMon1DVs", 0, 2)) == DVS
	assert nickname(game) == NICKNAME


FOLLOWER_INVISIBLE_FLAGS = 0b11 # FOLLOWER_INVISIBLE_F and FOLLOWER_INVISIBLE_ONE_STEP_F
FOLLOWER_BESIDE = 1 << 7


def player_and_follower(game):
	return [(object_field(game, s, OBJECT_MAP_X), object_field(game, s, OBJECT_MAP_Y)) for s in (0, FOLLOWER_STRUCT)]


def test_it_starts_beside_you_in_sight_and_follows(injected):
	"""Not hidden under you until your first step, as after a warp: one tile to your left."""
	game = injected
	(px, py), (fx, fy) = player_and_follower(game)
	assert (fx, fy) == (px - 1, py)
	assert not object_field(game, FOLLOWER_STRUCT, OBJECT_FLAGS1) & INVISIBLE
	assert game.peek("wFollowerFlags") & (FOLLOWER_INVISIBLE_FLAGS | FOLLOWER_BESIDE) == 0
	# A step away: it takes the tile you left
	game.step("right")
	(qx, qy), follower = player_and_follower(game)
	assert (qx, qy) == (px + 1, py) and follower == (px, py)


def test_a_later_warp_hides_it_under_you_as_before(injected):
	game = injected
	game.warp("PLAYERS_HOUSE_1F", 4, 4)
	player, follower = player_and_follower(game)
	assert follower == player


LAB_STARTER_SPRITES = {"CYNDAQUIL": "SPRITE_OW_MON_1", "TOTODILE": "SPRITE_OW_MON_2", "CHIKORITA": "SPRITE_OW_MON_3"}
LEFTOVER_HOME = (7, 4) # in front of the table
INJECTED_EXTRA_HOME = (7, 9) # the room below
MAP_OBJECT_OFFSET = 4 # object structs count map coordinates from -4
SCENE_ELMSLAB_NOOP = 2 # maps/ElmsLab.asm's scene list: MEET_ELM, CANT_LEAVE, NOOP, ...


def lab_starters(game):
	"""Where each Johto starter stands in Elm's lab, by its sprite: a list per species, empty if not shown"""
	ids = sprites()
	return {species: [(object_field(game, s, OBJECT_MAP_X) - MAP_OBJECT_OFFSET, object_field(game, s, OBJECT_MAP_Y) - MAP_OBJECT_OFFSET)
		for s in objects_with_sprite(game, ids[sprite])] for species, sprite in LAB_STARTER_SPRITES.items()}


def near(spot, home):
	return abs(spot[0] - home[0]) <= 1 and abs(spot[1] - home[1]) <= 1


def after_the_theft(game, yours_taken):
	"""Elm's lab once SILVER has stolen his: you're marked as having Cyndaquil (as an injected
	starter with TOTODILE for the rival's line marks you), so he took Totodile and Chikorita is left"""
	game.set_event_flag("EVENT_GOT_A_POKEMON_FROM_ELM")
	game.set_event_flag("EVENT_GOT_CYNDAQUIL_FROM_ELM")
	game.set_event_flag("EVENT_CYNDAQUIL_POKEBALL_IN_ELMS_LAB", yours_taken)
	game.set_event_flag("EVENT_TOTODILE_POKEBALL_IN_ELMS_LAB") # stolen
	game.poke("wElmsLabSceneID", SCENE_ELMSLAB_NOOP) # past meeting ELM, so no scene walks you to him
	game.warp("ELMS_LAB", 4, 6) # the middle of the lab, where the table and the room below are both on screen
	return lab_starters(game)


def test_with_a_starter_injected_both_starters_left_wander_the_lab(injected):
	"""Not one wandering and the one marked as yours, never taken, standing on the table"""
	starters = after_the_theft(injected, yours_taken=False)
	assert starters["TOTODILE"] == [], "SILVER took it"
	[chikorita] = starters["CHIKORITA"]
	[cyndaquil] = starters["CYNDAQUIL"]
	assert near(chikorita, LEFTOVER_HOME), chikorita
	assert near(cyndaquil, INJECTED_EXTRA_HOME), cyndaquil


def test_without_one_only_the_leftover_wanders(game):
	starters = after_the_theft(game, yours_taken=True)
	assert starters["TOTODILE"] == [] and starters["CYNDAQUIL"] == [], "yours and SILVER's are gone"
	[chikorita] = starters["CHIKORITA"]
	assert near(chikorita, LEFTOVER_HOME), chikorita


def test_its_moves_are_the_ones_given_with_their_pp(injected):
	game = injected
	moves = game.peek("wPartyMon1Moves", 0, 4)
	indexes = []
	for move_id in moves[:2]:
		low, high = game.peek("wMoveIndexTableEntries", (move_id - 1) * 2, 2)
		indexes.append(low | high << 8)
	assert indexes == [move_index(m) for m in MOVES]
	assert moves[2:] == [0, 0]
	pp = game.peek("wPartyMon1PP", 0, 4)
	assert pp[0] and pp[1] and pp[2:] == [0, 0], "each move it knows has its PP, the empty slots none"


def test_its_stats_come_from_its_dvs_at_full_hp(injected):
	game = injected
	# The placeholder species' base stats are 50 each, with no EVs yet: Gen 2's formula at level 5
	attack, defense = DVS[0] >> 4, DVS[0] & 15
	speed, special = DVS[1] >> 4, DVS[1] & 15
	hp_dv = (attack & 1) << 3 | (defense & 1) << 2 | (speed & 1) << 1 | special & 1
	stat = lambda dv: (50 + dv) * 2 * 5 // 100 + 5
	expected_hp = (50 + hp_dv) * 2 * 5 // 100 + 5 + 10
	read = lambda symbol: game.peek(symbol) << 8 | game.peek(symbol, 1)
	assert read("wPartyMon1MaxHP") == expected_hp
	assert read("wPartyMon1HP") == expected_hp
	assert read("wPartyMon1Attack") == stat(attack)
	assert read("wPartyMon1Defense") == stat(defense)
	assert read("wPartyMon1Speed") == stat(speed)
	assert read("wPartyMon1SpclAtk") == stat(special)
	assert read("wPartyMon1SpclDef") == stat(special)


def test_it_was_met_in_new_bark_town_and_is_in_the_pokedex(injected):
	game = injected
	landmarks = constants._consts(constants.ROOT / "constants" / "landmark_constants.asm")
	assert game.peek("wPartyMon1CaughtLocation") & LANDMARK_MASK == landmarks["LANDMARK_NEW_BARK_TOWN"]
	byte, bit = divmod(A.pokemon_index("NEW_MON_1") - 1, 8)
	assert game.peek("wPokedexCaught", byte) & 1 << bit
	assert game.peek("wPokedexSeen", byte) & 1 << bit


def test_a_blank_nickname_keeps_the_species_name(rom):
	path = patched_rom(rom, "plain_name", starter_record("PIKACHU"))
	game = Game(path)
	try:
		game.load_state(new_game_state(path))
		assert nickname(game) == "PIKACHU"
		assert game.peek("wPartyMon1Form") == 0
	finally:
		game.close()


CAUGHT_BALL_MASK = 0x0f


@pytest.mark.parametrize("ball", [None, "GREAT_BALL", "MASTER_BALL", "PARK_BALL"])
def test_it_was_caught_in_the_injected_ball(rom, ball):
	"""Left as built, a POKé BALL. The MASTER BALL is stored as 0, which the caught data also reads as
	no ball set yet, so it's worth its own case."""
	path = patched_rom(rom, "ball_%s" % (ball or "default").lower(), starter_record("PIKACHU", ball=ball))
	game = Game(path)
	try:
		game.load_state(new_game_state(path))
		assert game.peek("wPartyMon1CaughtBall") & CAUGHT_BALL_MASK == caught_ball(ball or "POKE_BALL")
	finally:
		game.close()


def test_the_plain_test_rom_has_no_starter_injected(game):
	A.call(game, "CheckInjectedStarter")
	assert game.peek("wScriptVar") == 0


# Elm's lab

def test_elm_sees_your_partner_and_the_rival_takes_his_lines_starter(injected):
	game = injected
	enter_moving(game, "ELMS_LAB", 4, 11) # Elm's scene walks you up to him as you arrive
	text_seen(game, "You already have")
	press_until_idle(game)
	assert game.event_flag("EVENT_GOT_A_POKEMON_FROM_ELM")
	# The rival's line is Totodile, so it is as if you took Cyndaquil, which Totodile beats
	assert game.event_flag("EVENT_GOT_CYNDAQUIL_FROM_ELM")
	assert not game.event_flag("EVENT_GOT_TOTODILE_FROM_ELM")
	assert not game.event_flag("EVENT_GOT_CHIKORITA_FROM_ELM")
	assert game.peek("wPartyCount") == 1, "Elm gives no starter of his own"

	# None of the three on the table can be taken
	for x in (6, 7, 8):
		game.warp("ELMS_LAB", x, 4)
		game.press("up")
		text_seen(game, "PROF.ELM caught")
		press_until_idle(game)
		assert game.peek("wPartyCount") == 1


@pytest.mark.parametrize("rival, event", [
	("CHIKORITA", "EVENT_GOT_TOTODILE_FROM_ELM"),
	("CYNDAQUIL", "EVENT_GOT_CHIKORITA_FROM_ELM"),
	("TOTODILE", "EVENT_GOT_CYNDAQUIL_FROM_ELM"),
])
def test_each_rival_line_marks_the_starter_it_beats(rom, rival, event):
	record = starter_record("PIKACHU", rival=rival)
	path = patched_rom(rom, "rival_" + rival.lower(), record)
	game = Game(path)
	try:
		game.load_state(new_game_state(path))
		A.call(game, "SetInjectedStarterRival")
		for name in ("EVENT_GOT_TOTODILE_FROM_ELM", "EVENT_GOT_CHIKORITA_FROM_ELM", "EVENT_GOT_CYNDAQUIL_FROM_ELM"):
			assert game.event_flag(name) == (name == event), name
	finally:
		game.close()


# The cable club

def test_the_cable_club_turns_away_a_party_with_a_new_species(injected):
	game = injected
	state = game.save_state() # a direct call leaves the CPU parked: play on from before it
	A.call(game, "CheckPartyForNewMons")
	assert game.peek("wScriptVar") == 1
	chars = constants.charmap()
	name = "".join(chars[b] for b in game.peek("wStringBuffer1", 0, MON_NAME_LENGTH)).split("@")[0]
	assert name == "?????", "the message names the species it turns away"
	game.load_state(state)
	game.warp("POKECENTER_2F", 5, 3)
	game.press("up")
	text_seen(game, "TRADE CENTER")
	text_seen(game, "travel by link")
	press_until_idle(game)
	assert game.in_map("POKECENTER_2F"), "the player stays outside the trade room"


def test_the_cable_club_lets_in_a_party_of_the_games_own(game):
	A.call(game, "CheckPartyForNewMons")
	assert game.peek("wScriptVar") == 0


# The new slots

def test_the_saved_pokedex_flags_keep_their_size():
	# 256 species fill the 32 bytes exactly, so nothing saved after them moves
	assert A.pokemon_index("NEW_MON_5") == 256


@pytest.mark.parametrize("species, icon", [
	("BULBASAUR", "BulbasaurIcon"),
	("MAGIKARP", "MagikarpIcon"),
	("CELEBI", "CelebiIcon"),
	("EGG", "EggIcon"),
	("NEW_MON_1", "NewMonIcon"),
	("NEW_MON_5", "NewMonIcon"), # index 256 once read its icon from the wrong bank
])
def test_each_species_icon_is_read_from_its_own_bank(game, species, icon):
	game.poke("wCurIcon", 0xfd if species == "EGG" else A.species_id(game, species)) # EGG is -3
	out = A.call(game, "GetIconBank")
	assert out["bc"] >> 8 == game.pyboy.symbol_lookup(icon)[0]


def test_completion_counts_only_the_games_own_species(game):
	# Every species caught, the new slots included: only the game's own count
	for byte in range(32):
		game.poke("wPokedexCaught", 0xff, byte)
		game.poke("wPokedexSeen", 0xff, byte)
	out = A.call(game, "CountOriginalDexFlags", hl=game._address("wPokedexCaught")[1])
	assert out["bc"] == NUM_ORIGINAL_POKEMON
	# Only the new slots caught: none of the game's own counts
	for byte in range(32):
		game.poke("wPokedexCaught", 0, byte)
	game.poke("wPokedexCaught", 0xf8, 31) # indexes 252-256
	out = A.call(game, "CountOriginalDexFlags", hl=game._address("wPokedexCaught")[1])
	assert out["bc"] == 0


# Stones for one gender

def give_eevee(game, dvs):
	eevee = A.species_id(game, "EEVEE")
	game.poke("wPartyCount", 1)
	game.poke("wPartySpecies", eevee)
	game.poke("wPartySpecies", 0xff, 1)
	game.poke("wPartyMon1Species", eevee)
	game.poke("wPartyMon1DVs", dvs[0])
	game.poke("wPartyMon1DVs", dvs[1], 1)
	game.poke("wPartyMon1Item", 0)
	game.poke("wPartyMon1Form", 0)


@pytest.fixture(scope="module")
def gendered_eevee_rom(rom):
	"""Eevee's first two evolutions made gendered, in place: a stone evolution and these have the same
	layout, so only the method bytes change. Thunderstone for a male, Water Stone for a female."""
	methods = constants._consts(constants.ROOT / "constants" / "pokemon_data_constants.asm")
	at = symbol_offset(rom, "EeveeEvosAttacks")
	data = bytearray(rom.read_bytes())
	assert data[at] == methods["EVOLVE_ITEM"] and data[at + 5] == methods["EVOLVE_ITEM"]
	data[at] = methods["EVOLVE_ITEM_MALE"]
	data[at + 5] = methods["EVOLVE_ITEM_FEMALE"]
	folder = CACHE / "injected" / WORKER
	folder.mkdir(parents=True, exist_ok=True)
	path = folder / "gendered_eevee.gbc"
	path.write_bytes(data)
	shutil.copyfile(rom.with_suffix(".sym"), path.with_suffix(".sym"))
	return path


MALE_DVS = (0xff, 0xff) # Attack and Speed DVs 15: above Eevee's ratio
FEMALE_DVS = (0x0f, 0x0f) # Attack and Speed DVs 0


@pytest.mark.parametrize("dvs, stone, evolves_into", [
	(MALE_DVS, "THUNDERSTONE", "JOLTEON"),
	(FEMALE_DVS, "THUNDERSTONE", None),
	(FEMALE_DVS, "WATER_STONE", "VAPOREON"),
	(MALE_DVS, "WATER_STONE", None),
])
def test_a_gendered_stone_evolves_only_that_gender(gendered_eevee_rom, dvs, stone, evolves_into):
	game = Game(gendered_eevee_rom)
	try:
		game.load_state(new_game_state(gendered_eevee_rom))
		give_eevee(game, dvs)
		game.poke("wCurItem", A.item_id(game, stone))
		game.poke("wCurPartyMon", 0)
		state = game.save_state() # a direct call leaves the CPU parked: evolve from before it

		# The party menu's ABLE / NOT ABLE
		bank, pointer = game.pyboy.symbol_lookup("EeveeEvosAttacks")
		out = A.call(game, "DeterminePartyMonEvolutionItemResults", bc=bank << 8, de=pointer)
		assert (out["de"] != 0) == (evolves_into is not None)
		# The species question (the Moon Ball's) ignores gender
		out = A.call(game, "DetermineEvolutionItemResults", bc=bank << 8, de=pointer)
		assert out["de"] != 0

		game.load_state(state)
		game.poke("wForceEvolution", 1)
		A.call(game, "EvolvePokemon", press_a_every=30, must_return=False, frames=EVOLUTION_FRAMES,
			from_main_loop=True)
		expected = evolves_into or "EEVEE"
		assert index_of_id(game, game.peek("wPartyMon1Species")) == A.pokemon_index(expected)
	finally:
		game.close()
