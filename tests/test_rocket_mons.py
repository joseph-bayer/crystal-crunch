"""Team Rocket's wild mon: a Rocket swarm's mon (grass and wandering) know Thief and Frustration and
have happiness ROCKET_MON_HAPPINESS (0); the Rocket Base Electrodes have that happiness but their
usual moves. A caught one keeps its happiness, and a Friend Ball raises it only to
FRIEND_BALL_ROCKET_HAPPINESS. Ordinary wild mon and other swarms are unchanged.

Also a regression test for GetSwarmSpeciesForMap reading the next row's form byte as the swarm's
terrain, which kept an alternate-shiny swarm's wanderers off their alternate-shiny odds."""

import re

import pytest

from harness import constants
from harness.alt_shiny import call, pokemon_index, species_id
from harness.data import global_constants

C = global_constants().values
OW_MON_ENCOUNTER_LENGTH = 10
OW_MON_PERKS = 7
NUM_MOVES = 4
CARRY = 0x10
TRAINER_BATTLE = 2
WILD_BATTLE = 1
ROCKET_MON_SWARM = C["ROCKET_MON_UNHAPPY"] | C["ROCKET_MON_MOVES"]
OW_PERK_ROCKET = 1 << 2 # shift_const, which the constants reader doesn't follow

ROUTE_42 = ("ROUTE_42", 0, 8)
SEEDS = range(1, 40)


def swarm_id(name):
	from test_alt_shiny import swarm_ids
	return swarm_ids()[name]


def move_index(name):
	return constants._consts(constants.ROOT / "constants" / "move_constants.asm")[name]


def move_indexes(game, ids):
	"""The 16-bit move indexes behind 8-bit move ids, 0 for an empty slot."""
	result = []
	for move_id in ids:
		if not move_id:
			result.append(0)
			continue
		low, high = game.peek("wMoveIndexTableEntries", (move_id - 1) * 2, 2)
		result.append(low | high << 8)
	return result


def move_id(game, name):
	"""The 8-bit id for a move, claiming one through the game's own routine."""
	return call(game, "GetMoveIDFromIndex", hl=move_index(name))["a"]


def enemy_moves(game):
	return move_indexes(game, game.peek("wEnemyMonMoves", 0, NUM_MOVES))


def set_enemy_moves(game, names):
	names = list(names) + [None] * (NUM_MOVES - len(names))
	for i, name in enumerate(names):
		game.poke("wEnemyMonMoves", move_id(game, name) if name else 0, i)


# Which wild mon are Team Rocket's

def run_swarm(game, name):
	game.poke("wActiveSwarms", swarm_id(name))
	for slot in range(1, C["MAX_ACTIVE_SWARMS"]):
		game.poke("wActiveSwarms", 0, slot)


def swarm_lookup(game, map_name, terrain):
	group, number = constants.maps()[map_name]
	game.poke("wOverworldMonSwarmAltShiny", 0xff)
	game.poke("wOverworldMonSwarmPerks", 0xff)
	out = call(game, "GetSwarmSpeciesForMap", de=group << 8 | number, bc=terrain << 8)
	assert out["f"] & CARRY, "no swarm found on %s" % map_name
	return out


@pytest.mark.parametrize("swarm, map_name, alt, perks", [
	("SWARM_SCYTHER_ALT_SHINY", "NATIONAL_PARK", True, 0),
	("SWARM_GOLBAT_ROCKET", "ROUTE_42", False, OW_PERK_ROCKET),
	("SWARM_GEODUDE_RB", "ROCK_TUNNEL_1F", False, 0),
])
def test_wandering_roll_reads_its_own_rows_terrain(game, swarm, map_name, alt, perks):
	"""GetSwarmSpeciesForMap takes the alternate-shiny and Rocket bits from the swarm's own row (it
	used to read the next row's form byte, so an alternate-shiny swarm's wanderers never got their
	odds)."""
	run_swarm(game, swarm)
	out = swarm_lookup(game, map_name, C["SWARM_GRASS"])
	assert game.peek("wOverworldMonSwarmAltShiny") == (C["SWARM_ALT_SHINY"] if alt else 0)
	assert game.peek("wOverworldMonSwarmPerks") == perks
	assert out["bc"] == C["NO_MOVE"], "no swarm names a move of its own now"


def test_rocket_rows_name_no_move():
	"""Thief comes from the Rocket marker, not the swarm's move column, which stays for other rows."""
	text = (constants.ROOT / "data" / "wild" / "swarms.asm").read_text(encoding="utf-8")
	rows = re.findall(r"^\tswarm_def (.+)$", text, re.M)
	rocket = [row for row in rows if "SWARM_ROCKET" in row]
	assert len(rocket) == 4
	for row in rocket:
		assert len([arg for arg in row.split(";")[0].split(",") if arg.strip()]) == 5, row


def test_grass_marks_only_a_rocket_swarms_mon(game):
	"""On Route 42 with the Rocket Golbat swarm on, ChooseWildEncounter marks each Golbat
	ROCKET_MON_SWARM and nothing else; Rock Tunnel's Geodude swarm marks nothing."""
	group, number = constants.maps()["ROUTE_42"]
	game.poke("wMapGroup", group)
	game.poke("wMapNumber", number)
	run_swarm(game, "SWARM_GOLBAT_ROCKET")
	golbat = species_id(game, "GOLBAT")
	met = {True: 0, False: 0}
	for seed in SEEDS:
		game.seed_random(seed)
		call(game, "ChooseWildEncounter")
		is_golbat = game.peek("wTempWildMonSpecies") == golbat
		met[is_golbat] += 1
		assert game.peek("wTempWildMonRocket") == (ROCKET_MON_SWARM if is_golbat else 0)
	assert met[True] and met[False], met

	group, number = constants.maps()["ROCK_TUNNEL_1F"]
	game.poke("wMapGroup", group)
	game.poke("wMapNumber", number)
	run_swarm(game, "SWARM_GEODUDE_RB")
	for seed in SEEDS:
		game.seed_random(seed)
		call(game, "ChooseWildEncounter")
		assert game.peek("wTempWildMonRocket") == 0


def test_wanderers_of_a_rocket_swarm_carry_the_perk(game):
	"""Route 42's wandering slot, rolled with the Rocket Golbat swarm on: a Golbat has
	OW_PERK_ROCKET, the route's own mon doesn't."""
	run_swarm(game, "SWARM_GOLBAT_ROCKET")
	game.warp(*ROUTE_42)
	golbat = pokemon_index("GOLBAT")
	met = {True: 0, False: 0}
	for seed in SEEDS:
		game.seed_random(seed)
		call(game, "RollOverworldMons")
		enc = game.peek("wOverworldMonEncounters", 0, OW_MON_ENCOUNTER_LENGTH)
		if not enc[0] | enc[1]:
			continue
		is_golbat = (enc[0] | enc[1] << 8) == golbat
		met[is_golbat] += 1
		assert bool(enc[OW_MON_PERKS] & OW_PERK_ROCKET) == is_golbat, enc
	assert met[True] and met[False], met


def test_a_remembered_rocket_shiny_keeps_the_perk(game):
	"""A Rocket swarm's remembered shiny, rebuilt from its row, is still Team Rocket's."""
	from test_remembered_shinies import remember, swarm_entry

	run_swarm(game, "SWARM_GOLBAT_ROCKET")
	game.warp(*ROUTE_42)
	remember(game, "ROUTE_42", swarm_entry(0, swarm_id("SWARM_GOLBAT_ROCKET")))
	game.seed_random(1)
	call(game, "RollOverworldMons")
	enc = game.peek("wOverworldMonEncounters", 0, OW_MON_ENCOUNTER_LENGTH)
	assert (enc[0] | enc[1] << 8) == pokemon_index("GOLBAT")
	assert enc[OW_MON_PERKS] & OW_PERK_ROCKET


# What being Team Rocket's does in the battle

def apply(game, rocket=0, battle_slot=0, perks=0, moves=("TACKLE",)):
	set_enemy_moves(game, moves)
	game.poke("wEnemyMonHappiness", C["BASE_HAPPINESS"])
	game.poke("wTempWildMonMove", 0)
	game.poke("wTempWildMonMove", 0, 1)
	game.poke("wTempWildMonRocket", rocket)
	game.poke("wOverworldMonBattleSlot", battle_slot)
	if battle_slot:
		base = (battle_slot - 1) * OW_MON_ENCOUNTER_LENGTH
		game.poke("wOverworldMonEncounters", perks, base + OW_MON_PERKS)
		game.poke("wOverworldMonEncounters", 0, base + OW_MON_PERKS + 1)
		game.poke("wOverworldMonEncounters", 0, base + OW_MON_PERKS + 2)
	call(game, "ApplyWildMonMove")
	assert game.peek("wTempWildMonRocket") == 0, "the marker should be used up"
	return enemy_moves(game), game.peek("wEnemyMonHappiness")


FOUR = ("TACKLE", "GROWL", "LEER", "EMBER")


@pytest.mark.parametrize("moves, expected", [
	(FOUR, ("THIEF", "FRUSTRATION", "LEER", "EMBER")), # four: the first two go
	(("TACKLE",), ("TACKLE", "THIEF", "FRUSTRATION", None)), # empty slots first
	(("THIEF", "GROWL", "LEER", "EMBER"), ("THIEF", "FRUSTRATION", "LEER", "EMBER")), # known: skipped
])
def test_rocket_swarm_mon_get_thief_and_frustration(game, moves, expected):
	got, happiness = apply(game, rocket=ROCKET_MON_SWARM, moves=moves)
	assert got == [move_index(name) if name else 0 for name in expected]
	assert happiness == C["ROCKET_MON_HAPPINESS"]


def test_a_rocket_wanderer_gets_them_from_its_perk(game):
	got, happiness = apply(game, battle_slot=1, perks=OW_PERK_ROCKET, moves=FOUR)
	assert got == [move_index(name) for name in ("THIEF", "FRUSTRATION", "LEER", "EMBER")]
	assert happiness == C["ROCKET_MON_HAPPINESS"]


@pytest.mark.parametrize("rocket, battle_slot, perks", [(0, 0, 0), (0, 1, 0),
	(0, 1, 1 << 0)]) # an ordinary wanderer, one with OW_PERK_ALWAYS_ITEM
def test_other_wild_mon_are_unchanged(game, rocket, battle_slot, perks):
	got, happiness = apply(game, rocket=rocket, battle_slot=battle_slot, perks=perks, moves=FOUR)
	assert got == [move_index(name) for name in FOUR]
	assert happiness == C["BASE_HAPPINESS"]


def test_unhappy_only_keeps_the_moves(game):
	"""The Rocket Base Electrodes' marker: happiness 0, no Thief or Frustration."""
	got, happiness = apply(game, rocket=C["ROCKET_MON_UNHAPPY"], moves=FOUR)
	assert got == [move_index(name) for name in FOUR]
	assert happiness == C["ROCKET_MON_HAPPINESS"]


def load_enemy(game, species, level, rocket):
	game.poke("wBattleMode", WILD_BATTLE)
	game.poke("wBattleType", 0)
	game.poke("wOverworldMonBattleSlot", 0)
	game.poke("wTempWildMonForm", 0)
	game.poke("wTempWildMonRocket", rocket)
	game.poke("wTempEnemyMonSpecies", species_id(game, species))
	game.poke("wCurPartyLevel", level)
	call(game, "LoadEnemyMon")


def test_rocket_base_electrode_battle(game):
	"""LoadEnemyMon on a level-23 Electrode with the scripts' marker: happiness 0, its level-up moves."""
	load_enemy(game, "ELECTRODE", 23, 0)
	plain = enemy_moves(game)
	assert game.peek("wEnemyMonHappiness") == C["BASE_HAPPINESS"]
	load_enemy(game, "ELECTRODE", 23, C["ROCKET_MON_UNHAPPY"])
	assert enemy_moves(game) == plain
	assert game.peek("wEnemyMonHappiness") == C["ROCKET_MON_HAPPINESS"]
	assert game.peek("wTempWildMonRocket") == 0


def test_rocket_base_electrode_scripts_mark_the_battle():
	text = (constants.ROOT / "maps" / "TeamRocketBaseB2F.asm").read_text(encoding="utf-8")
	lines = text.splitlines()
	loads = [i for i, line in enumerate(lines) if "loadwildmon ELECTRODE" in line]
	assert len(loads) == 3
	for i in loads:
		assert re.match(r"\tloadmem wTempWildMonRocket, ROCKET_MON_UNHAPPY\b", lines[i + 1]), lines[i + 1]


# Catching one

def test_a_caught_rocket_mon_keeps_its_happiness(game):
	"""TryAddMonToParty copies the wild mon's happiness: 0 for Team Rocket's, 70 otherwise."""
	for happiness in (C["ROCKET_MON_HAPPINESS"], C["BASE_HAPPINESS"]):
		load_enemy(game, "GOLBAT", 20, 0)
		game.poke("wEnemyMonHappiness", happiness)
		game.poke("wCurPartySpecies", species_id(game, "GOLBAT"))
		game.poke("wMonType", 0) # PARTYMON
		count = game.peek("wPartyCount")
		call(game, "TryAddMonToParty")
		assert game.peek("wPartyCount") == count + 1
		length = game._address("wPartyMon2Happiness")[1] - game._address("wPartyMon1Happiness")[1]
		assert game.peek("wPartyMon1Happiness", count * length) == happiness


def test_a_rocket_mon_boxed_keeps_its_happiness(game):
	"""SendMonIntoBox builds the box mon in wBufferMon from the wild mon, happiness included."""
	load_enemy(game, "GOLBAT", 20, C["ROCKET_MON_UNHAPPY"])
	game.poke("wCurPartySpecies", species_id(game, "GOLBAT"))
	call(game, "SendMonIntoBox")
	assert game.peek("wBufferMonHappiness") == C["ROCKET_MON_HAPPINESS"]


@pytest.mark.parametrize("happiness, expected", [("ROCKET_MON_HAPPINESS", "FRIEND_BALL_ROCKET_HAPPINESS"),
	("BASE_HAPPINESS", "FRIEND_BALL_HAPPINESS")])
def test_friend_ball(game, happiness, expected):
	game.poke("wEnemyMonHappiness", C[happiness])
	assert call(game, "GetFriendBallHappiness")["a"] == C[expected]


SCREEN_WIDTH = 20
CHAR_A = 0x80
CHAR_0 = 0xf6


def tile_text(game, x, y, length):
	"""Letters and digits off wTilemap; anything else as '?'."""
	tiles = game.peek("wTilemap", y * SCREEN_WIDTH + x, length)
	return "".join(chr(ord("A") + t - CHAR_A) if CHAR_A <= t < CHAR_A + 26
		else chr(ord("0") + t - CHAR_0) if CHAR_0 <= t < CHAR_0 + 10
		else "?" for t in tiles)


@pytest.mark.parametrize("happiness", [0, 70, 255])
def test_debug_stats_screen_shows_happiness(game, happiness):
	# The debug build's blue stats page shows happiness under the OT name
	from harness.forms import take_radio_items
	take_radio_items(game)
	game.poke("wCurPartyMon", 0)
	game.poke("wMonType", 0)
	call(game, "CopyMonToTempMon")
	game.poke("wTempMonHappiness", happiness)
	call(game, "LoadBluePage")
	assert tile_text(game, 0, 15, 9) == "HAPPINESS"
	assert tile_text(game, 2, 16, 3).lstrip("?") == str(happiness)


@pytest.mark.parametrize("rocket, ball, expected", [
	(C["ROCKET_MON_UNHAPPY"], "MASTER BALL", C["ROCKET_MON_HAPPINESS"]),
	(C["ROCKET_MON_UNHAPPY"], "FRIEND BALL", C["FRIEND_BALL_ROCKET_HAPPINESS"]),
	(0, "MASTER BALL", C["BASE_HAPPINESS"]),
	(0, "FRIEND BALL", C["FRIEND_BALL_HAPPINESS"]),
])
def test_a_real_catch_keeps_a_rocket_mons_happiness(game, rocket, ball, expected):
	"""A ball reloads the wild mon before adding it, which reset its happiness to BASE_HAPPINESS
	after the battle's own load had used up the Rocket marker: the Rocket Base Electrodes came out
	at 70, and a grass Rocket mon in a Friend Ball at 200."""
	from harness.forms import (answer_prompts, out_of_battle, party_field, shorten_party,
		super_nerd_menu, take_radio_items, throw_ball, wait_for_battle_menu, wait_until)
	take_radio_items(game)
	shorten_party(game, 5) # room for the catch
	game.poke("wTempWildMonRocket", rocket) # what the Electrode scripts' loadmem does
	super_nerd_menu(game, "HP BATTLES", "WILD MEW")
	wait_until(game, lambda: game.peek("wBattleMode") == WILD_BATTLE, "the wild battle")
	wait_for_battle_menu(game)
	assert game.peek("wEnemyMonHappiness") == (expected if ball == "MASTER BALL"
		else C["ROCKET_MON_HAPPINESS"] if rocket else C["BASE_HAPPINESS"])

	# Sure to catch, so the Friend Ball doesn't miss: it has no bonus against Mew
	game.poke("wEnemyMonCatchRate", 255)
	game.poke("wEnemyMonHP", 0)
	game.poke("wEnemyMonHP", 1, 1)
	throw_ball(game, ball)
	answer_prompts(game, lambda: out_of_battle(game))

	assert game.peek("wPartyCount") == 6, "the caught Mew should be in the party"
	assert party_field(game, 5, "Happiness") == expected
