"""Overworld shiny odds, and the shinies a route remembers.

A wandering mon from a route's roster is shiny at 1/2048: the 1/256 gate every shiny roll uses,
then 32 out of 256. A population's member and a swarm's stay at 1/512 (128 out of 256).

The last five shinies the route rosters roll are remembered (wRememberedShinies): each comes back
to its slot whenever its map is entered, until it is battled, and the list is saved in SRAM blocks
of its own. An entry keeps the map, a recipe byte (slot, grass or water, the time of day's roster,
the row, alternate shiny) and the DVs; the rest is rebuilt from the roster row on the way back."""

import tempfile
from pathlib import Path

import pytest

from harness import Game, constants, rom_path
from harness.alt_shiny import TestRandom as RandomSequence, call
from harness.dex_forms import save_game, sram

# constants/pokemon_data_constants.asm and constants/overworld_mon_constants.asm
SHINY_MASK = 0x80
OW_ROLL_FROM_POPULATION = 0x80
SWARM_ROW = 0x01 # any swarm row bit
ALT_SHINY_MASK = 0x40
ENCOUNTER_LENGTH = 10
OW_MON_FORM = 2
OW_MON_LEVEL = 3
OW_MON_DVS = 4
OW_MON_ITEM = 6
OW_MON_PERKS = 7
OW_MON_MOVE = 8
NUM_REMEMBERED = 5
ENTRY_LENGTH = 5
SLOT_MASK = 0b11
WATER_BIT = 1 << 2
ROW_SHIFT = 3
ROSTER_SHIFT = 5
ALT_BIT = 1 << 7
NUM_OW_WILDMON = 4
OW_WILDMON_LENGTH = 8
OW_WILDDATA_LENGTH = 2 + 1 + 1 + NUM_OW_WILDMON * OW_WILDMON_LENGTH * 3
MORN_F, DAY_F, NITE_F, EVE_F = range(4)

FORCE_SHINY = "EVENT_DEBUG_FORCE_SHINY_BEASTS" # the Scientist's BEASTS -> FORCE SHINY

# Route 30: slot 0 is Joey's and Mikey's Rattata, slots 1 and 2 roll from the grass roster (both
# out every time), slot 3 from the water one. Far enough from every wanderer that none walks on.
ROUTE_30 = ("ROUTE_30", 9, 20)
ROUTE_30_ROLLED = (1, 2, 3)
ELSEWHERE = ("NEW_BARK_TOWN", 5, 7)
MOUNT_MORTAR = ("MOUNT_MORTAR_1F_INSIDE", 11, 46) # its levels scale with the badges
# Route 32: slots 0 and 1 roll from the grass roster, slot 2 from the water one, whose rows carry
# extra moves and mix mon that ride on the surface (Tentacool, Tentacruel) with one that doesn't.
ROUTE_32 = ("ROUTE_32", 11, 74)
ROUTE_32_WATER_SLOT = 2
ROUTE_32_QUAGSIRE_ROW = 1
ROUTE_32_TENTACOOL_ROW = 0
NOT_SHINY_SEED = 0x0001


# The odds

def gate_seeds(low, high, count=20):
	"""Seeds whose first roll clears the 1/256 gate and whose second lands in low..high-1."""
	seeds = []
	for seed in range(1, 0x10000):
		rng = RandomSequence(seed)
		if rng.next() == 0 and low <= rng.next() < high:
			seeds.append(seed)
			if len(seeds) == count:
				break
	assert len(seeds) == count, "the test sequence ran out of seeds"
	return seeds


SOURCES = {"route": 0, "population": OW_ROLL_FROM_POPULATION, "swarm": SWARM_ROW}


def roll_form(game, source, seed):
	"""Run .RollForm on a plain mon from this source; the form byte it leaves."""
	game.poke("wOverworldMonRollBuffer", 0, OW_MON_FORM)
	game.poke("wOverworldMonRollBuffer", 0, OW_MON_PERKS)
	game.poke("wOverworldMonRollFromSwarm", SOURCES[source])
	game.poke("wOverworldMonRecordShiny", 0)
	game.seed_random(seed)
	call(game, "RollOverworldMons.RollForm")
	return game.peek("wOverworldMonRollBuffer", OW_MON_FORM)


@pytest.mark.parametrize("source, shiny", [("route", False), ("population", True), ("swarm", True)])
def test_rolls_between_the_numerators(game, source, shiny):
	"""Past the gate, a second roll of 32 to 127 is shiny at 1/512 and not at 1/2048."""
	for seed in gate_seeds(32, 128):
		assert bool(roll_form(game, source, seed) & SHINY_MASK) == shiny, "seed %d" % seed


@pytest.mark.parametrize("source", list(SOURCES))
def test_rolls_under_both_numerators(game, source):
	for seed in gate_seeds(0, 32, count=5):
		assert roll_form(game, source, seed) & SHINY_MASK, "seed %d" % seed


@pytest.mark.parametrize("source", list(SOURCES))
def test_only_the_routes_own_shinies_are_recorded(game, source):
	seed = gate_seeds(0, 32, count=1)[0]
	roll_form(game, source, seed)
	assert bool(game.peek("wOverworldMonRecordShiny")) == (source == "route")


@pytest.mark.parametrize("source, forced", [("route", True), ("swarm", True), ("population", False)])
def test_force_shiny_reaches_the_routes_own_mon(game, source, forced):
	"""The debug ROM's FORCE SHINY forces a swarm's and the route's wanderers, not a population's."""
	game.set_event_flag(FORCE_SHINY)
	seed = gate_seeds(128, 256, count=1)[0] # not shiny at any of the odds
	assert bool(roll_form(game, source, seed) & SHINY_MASK) == forced


# Remembering

def encounter(game, slot):
	return game.peek("wOverworldMonEncounters", slot * ENCOUNTER_LENGTH, ENCOUNTER_LENGTH)


def species(enc):
	return enc[0] | enc[1] << 8


def visible(enc):
	"""What a remembered shiny keeps: species, form, DVs."""
	return species(enc), enc[OW_MON_FORM], enc[OW_MON_DVS], enc[OW_MON_DVS + 1]


def all_but_the_item(enc):
	"""Everything an encounter rebuilt on a map with fixed levels should match: the item is rerolled."""
	return enc[:OW_MON_ITEM] + enc[OW_MON_ITEM + 1:]


def roster(time):
	"""The roster a time of day rolls from: evening shares the night's."""
	return NITE_F if time == EVE_F else time


def roster_row(game, terrain, map_name, which, row):
	"""One roster row's eight bytes, read from the ROM: weight, species (2), level, form, perks,
	move (2)."""
	table = {"grass": "OverworldWildMonsGrass", "water": "OverworldWildMonsWater"}[terrain]
	bank, address = game.pyboy.symbol_lookup(table)
	group, number = constants.maps()[map_name]
	memory = game.pyboy.memory
	while True:
		assert memory[bank, address] != 0xff, "%s has no %s table" % (map_name, terrain)
		if (memory[bank, address], memory[bank, address + 1]) == (group, number):
			start = address + 4 + (which * NUM_OW_WILDMON + row) * OW_WILDMON_LENGTH
			return [memory[bank, start + i] for i in range(OW_WILDMON_LENGTH)]
		address += OW_WILDDATA_LENGTH


def recipe(slot, row=0, which=0, water=False, alt=False):
	return slot | (WATER_BIT if water else 0) | row << ROW_SHIFT | which << ROSTER_SHIFT \
		| (ALT_BIT if alt else 0)


def remember(game, map_name, byte, dvs=(0xab, 0xcd), at=0):
	"""Write a remembered shiny by hand into entry `at`."""
	group, number = constants.maps()[map_name]
	for i, value in enumerate((group, number, byte) + tuple(dvs)):
		game.poke("wRememberedShinies", value, at * ENTRY_LENGTH + i)


def reroll(game, time=None, seed=NOT_SHINY_SEED):
	"""Roll the map the player stands on again, as entering it does, with FORCE SHINY off."""
	game.set_event_flag(FORCE_SHINY, False)
	if time is not None:
		game.poke("wTimeOfDay", time)
	game.seed_random(seed)
	call(game, "RollOverworldMons")


def remembered(game):
	raw = game.peek("wRememberedShinies", 0, NUM_REMEMBERED * ENTRY_LENGTH)
	return [raw[i * ENTRY_LENGTH:(i + 1) * ENTRY_LENGTH] for i in range(NUM_REMEMBERED)]


def on_map(game, map_name):
	group, number = constants.maps()[map_name]
	return [entry for entry in remembered(game) if (entry[0], entry[1]) == (group, number)]


def visit(game, place, force=False):
	game.set_event_flag(FORCE_SHINY, force)
	game.seed_random(NOT_SHINY_SEED)
	game.warp(*place)


def shinies_on_route_30(game):
	"""Visit Route 30 with FORCE SHINY on: every rolled slot comes up shiny. {slot: encounter}"""
	visit(game, ROUTE_30, force=True)
	rolled = {slot: encounter(game, slot) for slot in ROUTE_30_ROLLED}
	for slot, enc in rolled.items():
		assert species(enc), "slot %d rolled nothing" % slot
		assert enc[OW_MON_FORM] & SHINY_MASK, "slot %d should be forced shiny" % slot
	assert not encounter(game, 0)[OW_MON_FORM] & SHINY_MASK, "the static Rattata isn't a roll"
	return rolled


def test_shinies_are_remembered(game):
	rolled = shinies_on_route_30(game)
	entries = on_map(game, "ROUTE_30")
	assert sorted(entry[2] & SLOT_MASK for entry in entries) == list(ROUTE_30_ROLLED)
	for entry in entries:
		slot = entry[2] & SLOT_MASK
		assert bool(entry[2] & WATER_BIT) == (slot == 3), "slot 3 is the water slot"
		assert (entry[3], entry[4]) == tuple(rolled[slot][OW_MON_DVS:OW_MON_DVS + 2])


def test_shinies_come_back(game):
	rolled = shinies_on_route_30(game)
	visit(game, ELSEWHERE)
	game.set_event_flag(FORCE_SHINY, False)
	visit(game, ROUTE_30)
	for slot, enc in rolled.items():
		# Route 30's levels are fixed, so all but the rerolled item comes back as it was.
		assert all_but_the_item(encounter(game, slot)) == all_but_the_item(enc), "slot %d" % slot


@pytest.mark.parametrize("remember", [True, False])
def test_a_remembered_shiny_chimes(game, remember):
	shinies_on_route_30(game)
	if not remember:
		call(game, "ClearRememberedShinies")
	game.set_event_flag(FORCE_SHINY, False)
	game.seed_random(NOT_SHINY_SEED)
	call(game, "RollOverworldMons")
	assert bool(game.peek("wOverworldMonShinyPending")) == remember


def battle_water_slot(game):
	"""Surf onto Route 30's water wanderer (slot 3), as test_overworld_mons does."""
	from test_overworld_mons import PLAYER_SURF, ROUTE_30_POND, find_wanderer, pin_wanderer

	game.warp("ROUTE_30", *ROUTE_30_POND, settle=60)
	game.poke("wPlayerState", PLAYER_SURF)
	x, y = game.position()
	pin_wanderer(game, find_wanderer(game, "SPRITE_OW_MON_4", "SPRITE_OW_MON_4"), (x - 1, y))
	game.wait(20)
	game.pyboy.button_press("left")
	for _ in range(60):
		game.wait(5)
		if game.peek("wBattleMode"):
			break
	game.pyboy.button_release("left")
	assert game.peek("wBattleMode"), "surfing onto the water wanderer didn't start a battle"


@pytest.mark.parametrize("ending", ["run_away", "catch", "black_out"])
def test_a_battle_spends_a_remembered_shiny(game, ending):
	"""Run from, caught or blacked out against: any finished battle spends it."""
	from harness import legendaries

	legendaries.get_ready(game, badges=False) # the radio's party, Master Balls, room for a catch
	rolled = shinies_on_route_30(game)
	battle_water_slot(game)
	legendaries.answer_prompts(game, lambda: "FIGHT" in game.screen_text()) # past the sparkle
	party = game.peek("wPartyCount")
	getattr(legendaries, ending)(game)
	game.wait(120)
	assert (game.peek("wPartyCount") == party + 1) == (ending == "catch"), "the catch didn't happen"
	assert game.in_map("ROUTE_30") == (ending != "black_out"), "the black-out didn't happen"
	assert sorted(entry[2] & SLOT_MASK for entry in on_map(game, "ROUTE_30")) == [1, 2], \
		"the water slot's shiny should be forgotten, and only it"
	if ending != "run_away":
		return # the list is what matters; coming back is checked once, below
	game.poke("wPlayerState", 0) # back on foot for the warps
	visit(game, ELSEWHERE)
	visit(game, ROUTE_30)
	for slot in (1, 2):
		assert visible(encounter(game, slot)) == visible(rolled[slot]), "slot %d should stay" % slot
	assert not encounter(game, 3)[OW_MON_FORM] & SHINY_MASK, "the battled one is gone"


def test_the_oldest_falls_off(game):
	# Five made-up entries on another map, oldest last.
	for i in range(NUM_REMEMBERED):
		game.poke("wRememberedShinies", 0x7f, i * ENTRY_LENGTH)
		game.poke("wRememberedShinies", i + 1, i * ENTRY_LENGTH + 1)
	shinies_on_route_30(game)
	entries = remembered(game)
	new = len(ROUTE_30_ROLLED)
	group, number = constants.maps()["ROUTE_30"]
	assert all((e[0], e[1]) == (group, number) for e in entries[:new])
	assert [e[1] for e in entries[new:]] == list(range(1, NUM_REMEMBERED - new + 1)), \
		"the old entries move back in order and the oldest drop off"


def test_a_new_shiny_does_not_take_a_remembered_slot(game):
	"""Coming back with FORCE SHINY still on rolls new shinies in those slots, but the remembered
	ones are put back over them, and the list doesn't fill with copies."""
	rolled = shinies_on_route_30(game)
	before = remembered(game)
	visit(game, ELSEWHERE)
	visit(game, ROUTE_30, force=True)
	assert remembered(game) == before, "no copies, and each keeps its place in the list"
	for slot, enc in rolled.items():
		assert visible(encounter(game, slot)) == visible(enc)


def test_a_remembered_shiny_scales_to_the_badges(game):
	from test_level_scaling import possible, set_badges, time_of_day, NUM_OW_WILDMON

	set_badges(game, 4)
	visit(game, MOUNT_MORTAR, force=True)
	first = {slot: encounter(game, slot) for slot in range(4) if species(encounter(game, slot))}
	assert first, "nothing rolled on Mount Mortar"
	visit(game, ELSEWHERE)
	set_badges(game, 16)
	visit(game, MOUNT_MORTAR)
	expected = possible("wanderers", MOUNT_MORTAR[0], NUM_OW_WILDMON, time_of_day(game), 16)
	for slot, enc in first.items():
		back = encounter(game, slot)
		assert visible(back) == visible(enc)
		assert (back[OW_MON_LEVEL], species(back)) in expected, "slot %d" % slot


@pytest.mark.parametrize("time, expected", [(MORN_F, MORN_F), (DAY_F, DAY_F), (NITE_F, NITE_F),
	(EVE_F, NITE_F)])
def test_the_recipe_names_the_row_it_rolled(game, time, expected):
	"""Each entry's recipe points at the very roster row its slot rolled: the slot, grass or water,
	the time of day's roster (evening's is the night's) and the row."""
	visit(game, ROUTE_30)
	game.set_event_flag(FORCE_SHINY)
	game.poke("wTimeOfDay", time)
	game.seed_random(NOT_SHINY_SEED)
	call(game, "RollOverworldMons")
	entries = on_map(game, "ROUTE_30")
	assert sorted(entry[2] & SLOT_MASK for entry in entries) == list(ROUTE_30_ROLLED)
	for entry in entries:
		slot, byte = entry[2] & SLOT_MASK, entry[2]
		water = bool(byte & WATER_BIT)
		assert water == (slot == 3)
		assert (byte >> ROSTER_SHIFT) & 0b11 == expected, "slot %d" % slot
		row = roster_row(game, "water" if water else "grass", "ROUTE_30", expected,
			(byte >> ROW_SHIFT) & 0b11)
		assert species(encounter(game, slot)) == row[1] | row[2] << 8, \
			"slot %d's recipe names a row with another species" % slot


@pytest.mark.parametrize("place, slot, terrain", [(ROUTE_30, 2, "grass"),
	(ROUTE_32, ROUTE_32_WATER_SLOT, "water")])
def test_every_recipe_rebuilds_its_row(game, place, slot, terrain):
	"""A hand-written entry for each roster and row comes back as exactly that row, whatever the
	time of day now: species, level, form, perks and extra move from the row, shiny, its own DVs."""
	visit(game, place)
	saved = game.save_state()
	other_roster = 0
	for which in (MORN_F, DAY_F, NITE_F):
		for row in range(NUM_OW_WILDMON):
			game.load_state(saved)
			now = (which + 1) % 3 # another time of day's roster
			remember(game, place[0], recipe(slot, row, which, water=terrain == "water"))
			reroll(game, time=now)
			enc = encounter(game, slot)
			expected = roster_row(game, terrain, place[0], which, row)
			where = "roster %d row %d" % (which, row)
			assert species(enc) == expected[1] | expected[2] << 8, where
			assert enc[OW_MON_LEVEL] == expected[3], where
			assert enc[OW_MON_FORM] == expected[4] | SHINY_MASK, where
			assert enc[OW_MON_PERKS] == expected[5], where
			assert enc[OW_MON_MOVE:OW_MON_MOVE + 2] == expected[6:8], where
			assert enc[OW_MON_DVS:OW_MON_DVS + 2] == [0xab, 0xcd], where
			assert game.peek("wOverworldMonShinyPending") & 1 << slot, where + " should chime"
			other_roster += expected[1:3] != roster_row(game, terrain, place[0], now, row)[1:3]
	if place == ROUTE_30:
		assert other_roster, "Route 30's rosters differ by time of day, so this tells them apart"


def test_an_alternate_shiny_is_remembered_as_one(game):
	"""The recipe's alternate-shiny bit follows the form it rolled."""
	visit(game, ROUTE_30)
	saved = game.save_state()
	seen = set()
	for seed in range(1, 200):
		game.load_state(saved)
		game.set_event_flag(FORCE_SHINY)
		game.seed_random(seed)
		call(game, "RollOverworldMons")
		for entry in on_map(game, "ROUTE_30"):
			alt = bool(encounter(game, entry[2] & SLOT_MASK)[OW_MON_FORM] & ALT_SHINY_MASK)
			assert bool(entry[2] & ALT_BIT) == alt, "seed %d" % seed
			seen.add(alt)
		if seen == {True, False}:
			return
	raise AssertionError("no seed rolled both an alternate shiny and a plain one")


@pytest.mark.parametrize("alt", [True, False])
def test_an_alternate_shiny_comes_back_as_one(game, alt):
	visit(game, ROUTE_30)
	remember(game, "ROUTE_30", recipe(1, alt=alt))
	reroll(game)
	form = encounter(game, 1)[OW_MON_FORM]
	assert form & SHINY_MASK
	assert bool(form & ALT_SHINY_MASK) == alt


def surface_bit(game, slot):
	return bool(game.peek("wOverworldMonOnSurface") & 1 << slot)


def test_a_remembered_shiny_rides_the_surface_as_its_species_does(game):
	"""Route 32's water slot rolls a Tentacool (on the surface) or a Quagsire (not). A remembered one
	put back over the other must leave the slot's surface bit right for itself."""
	slot = ROUTE_32_WATER_SLOT
	visit(game, ROUTE_32)
	saved = game.save_state()
	rolled = {}
	for seed in range(1, 100):
		game.load_state(saved)
		reroll(game, seed=seed)
		rolled.setdefault(surface_bit(game, slot), seed)
		if len(rolled) == 2:
			break
	assert len(rolled) == 2, "no seed rolled both kinds into the water slot"
	for remembered_row, rides, over in ((ROUTE_32_QUAGSIRE_ROW, False, True),
			(ROUTE_32_TENTACOOL_ROW, True, False)):
		game.load_state(saved)
		which = roster(game.peek("wTimeOfDay"))
		remember(game, "ROUTE_32", recipe(slot, remembered_row, which, water=True))
		reroll(game, seed=rolled[over])
		assert surface_bit(game, slot) == rides, "row %d over a roll that rode=%s" % (remembered_row, over)


def test_a_remembered_shiny_takes_its_slot_back_from_a_beast(game):
	"""Raikou takes one of Route 30's grass slots, and both hold a remembered shiny: the shiny wins
	and Raikou sits this visit out."""
	from test_shiny_chime import put_raikou_here

	rolled = shinies_on_route_30(game)
	put_raikou_here(game, form=0)
	saved = game.save_state()
	call(game, "ClearRememberedShinies")
	reroll(game)
	assert game.peek("wOverworldMonBeastSlots"), "with nothing remembered, Raikou should be here"
	game.load_state(saved)
	reroll(game)
	assert game.peek("wOverworldMonBeastSlots", 0, 2) == [0, 0], "Raikou should have stepped aside"
	for slot in (1, 2):
		assert visible(encounter(game, slot)) == visible(rolled[slot]), "slot %d" % slot
		assert game.peek("wOverworldMonShinyPending") & 1 << slot, "slot %d should chime" % slot


def rock_tunnel_with_a_swarm(game):
	"""Rock Tunnel 1F with its Geodude swarm on, and a shiny remembered in slot 1. {slot: object}"""
	from test_shiny_chime import ROUTE, ROUTE_STAND, ROUTE_SWARM, wanderer_objects

	game.poke("wActiveSwarms", ROUTE_SWARM)
	visit(game, (ROUTE,) + ROUTE_STAND)
	which = roster(game.peek("wTimeOfDay"))
	remember(game, ROUTE, recipe(1, 0, which))
	reroll(game)
	row = roster_row(game, "grass", ROUTE, which, 0)
	enc = encounter(game, 1)
	assert species(enc) == row[1] | row[2] << 8, "the roster's own mon, not the swarm's"
	assert enc[OW_MON_FORM] & SHINY_MASK
	return {slot: index for slot, (index, _) in wanderer_objects(game).items()}


def test_a_remembered_shiny_survives_a_swarm_reroll(game):
	"""A battle against another of the swarm's mon rerolls the route: the remembered shiny is put
	back, and chimes again."""
	from test_shiny_chime import ROUTE

	objects = rock_tunnel_with_a_swarm(game)
	before = visible(encounter(game, 1))
	game.poke("wOverworldMonShinyPending", 0)
	game.poke("wOverworldMonBattleObject", objects[2])
	game.seed_random(NOT_SHINY_SEED)
	call(game, "RerollSwarmOverworldMons")
	assert visible(encounter(game, 1)) == before
	assert game.peek("wOverworldMonShinyPending") & 1 << 1, "it should chime again"
	assert len(on_map(game, ROUTE)) == 1


def test_a_swarm_battle_against_it_spends_it(game):
	from test_shiny_chime import ROUTE

	objects = rock_tunnel_with_a_swarm(game)
	game.poke("wOverworldMonBattleSlot", 1 + 1)
	game.poke("wOverworldMonBattleObject", objects[1])
	call(game, "EndOverworldMonBattle")
	assert not on_map(game, ROUTE), "the battle should have spent it"
	game.seed_random(NOT_SHINY_SEED)
	call(game, "RerollSwarmOverworldMons")
	assert not species(encounter(game, 1)), "the slot just fought sits the reshuffle out"


def test_forgetting_one_closes_the_gap(game):
	"""ForgetRememberedShiny drops the entry for one slot on this map, from anywhere in the list, and
	the ones behind it move up. The same slot on another map is left alone."""
	visit(game, ROUTE_30)
	entries = [("ROUTE_30", 1), ("ROUTE_31", 1), ("ROUTE_30", 2), ("ROUTE_31", 2), ("ROUTE_30", 3)]
	for at, (map_name, slot) in enumerate(entries):
		remember(game, map_name, recipe(slot), dvs=(at, at), at=at)
	raw = remembered(game)
	empty = [0] * ENTRY_LENGTH

	call(game, "ForgetRememberedShiny", a=3) # the last entry
	assert remembered(game) == raw[:4] + [empty]
	call(game, "ForgetRememberedShiny", a=1) # the first
	assert remembered(game) == raw[1:4] + [empty, empty]
	call(game, "ForgetRememberedShiny", a=0) # nothing remembered there
	assert remembered(game) == raw[1:4] + [empty, empty]
	call(game, "ForgetRememberedShiny", a=2) # the middle one now
	assert remembered(game) == [raw[1], raw[3], empty, empty, empty]


def test_new_game_forgets(game):
	shinies_on_route_30(game)
	call(game, "ClearRememberedShinies")
	assert not any(entry[0] for entry in remembered(game))


# Saving

def test_saved_and_loaded(game):
	shinies_on_route_30(game)
	before = remembered(game)
	save_game(game)
	for i in range(NUM_REMEMBERED * ENTRY_LENGTH):
		game.poke("wRememberedShinies", 0, i)
	call(game, "LoadRememberedShinies")
	assert remembered(game) == before


def test_the_backup_saves_and_loads(game):
	shinies_on_route_30(game)
	before = remembered(game)
	call(game, "SaveBackupRememberedShinies")
	call(game, "ClearRememberedShinies")
	call(game, "LoadBackupRememberedShinies")
	assert remembered(game) == before


def test_bad_checksum_loads_nothing(game):
	shinies_on_route_30(game)
	call(game, "SaveRememberedShinies")
	bank, address = game.pyboy.symbol_lookup("sRememberedShinies")
	game.pyboy.memory[bank, address + 3] = game.pyboy.memory[bank, address + 3] ^ 0x01 # one DV bit
	call(game, "LoadRememberedShinies")
	assert not any(entry[0] for entry in remembered(game))


def test_bad_magic_loads_nothing(game):
	shinies_on_route_30(game)
	call(game, "SaveRememberedShinies")
	bank, address = game.pyboy.symbol_lookup("sRememberedShiniesMagic")
	game.pyboy.memory[bank, address] = game.pyboy.memory[bank, address] ^ 0xff
	call(game, "LoadRememberedShinies")
	assert not any(entry[0] for entry in remembered(game))


def test_continue_brings_them_back(game):
	rolled = shinies_on_route_30(game)
	game.set_event_flag(FORCE_SHINY, False)
	save_game(game)
	with tempfile.TemporaryDirectory() as folder:
		path = Path(folder) / "remembered.sav"
		path.write_bytes(sram(game))
		continued = Game(rom_path(), save=path)
	try:
		from test_old_saves import continue_game
		continue_game(continued)
		assert continued.in_map("ROUTE_30")
		for slot, enc in rolled.items():
			assert visible(encounter(continued, slot)) == visible(enc), "slot %d" % slot
	finally:
		continued.close()


def test_an_old_save_remembers_nothing():
	from test_old_saves import continue_game, load

	game, _ = load("1.1_cherrygrove.sav")
	try:
		continue_game(game)
		assert not any(entry[0] for entry in remembered(game))
	finally:
		game.close()
