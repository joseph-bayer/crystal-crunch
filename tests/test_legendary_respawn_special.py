"""What each legendary's respawn brings back beyond the Pokemon itself: Ho-Oh's Tin Tower, Suicune's
rematch, Celebi's shrine, Mew's truck, the second Sudowoodo and Route 37's twins, the Route 11
Snorlax and the Poke Flute, the Red Gyarados without Lance or a second Red Scale, the Rocket Base
Electrodes without Lance or a second HM, and the Elite Four win running it all before the save."""

import re

import pytest

from harness import constants
from harness import legendaries as L
from harness.forms import answer_prompts, wait_for_battle_menu
from harness.overworld import struct_for_object, struct_position

TIN_TOWER_1F_NOOP = 1


def key_item_owned(game, name):
	text = (constants.ROOT / "constants" / "item_constants.asm").read_text(encoding="utf-8")
	index = int(re.search(r"const %s\s*; ([0-9A-Fa-f]{4})" % name, text).group(1), 16)
	bit = index & 0xff # key items are numbered from FIRST_KEY_ITEM, which is $100-aligned
	return bool(game.peek("wKeyItemFlags", bit // 8) & (1 << (bit % 8)))


def talk(game, facing):
	game.press(facing, after=10)
	game.press("a")


def screen_lines_until_idle(game, timeout=200):
	"""Press through text until the game is idle, keeping every line that showed."""
	seen = []
	for _ in range(timeout):
		box = [line for line in game.screen_lines()[12:] if line.startswith("│")]
		for line in (line.strip("│ ") for line in box):
			if line and (not seen or seen[-1] != line):
				seen.append(line)
		if L.idle(game):
			return seen
		game.press("a", after=20)
	raise AssertionError("still busy. The screen:\n" + game.screen_text())


# Ho-Oh: Tin Tower 1F goes back to how it was before Ho-Oh

def tin_tower_after_suicune(game):
	"""Tin Tower 1F as it is once Suicune's scene is done and the sages have given the Rainbow
	Wing."""
	L.get_ready(game, radio=False)
	for flag in ("EVENT_FOUGHT_SUICUNE", "EVENT_CAUGHT_SUICUNE", "EVENT_TIN_TOWER_1F_SUICUNE",
			"EVENT_TIN_TOWER_1F_EUSINE", "EVENT_GOT_RAINBOW_WING", "EVENT_TIN_TOWER_1F_WISE_TRIO_1"):
		game.set_event_flag(flag)
	game.set_event_flag("EVENT_TIN_TOWER_1F_WISE_TRIO_2", False)
	game.poke("wTinTower1FSceneID", TIN_TOWER_1F_NOOP)


def eusine_shown(game):
	L.enter(game, "TIN_TOWER_1F", 9, 15)
	return game.object_shown("TinTower1F", "TINTOWER1F_EUSINE")


def sage5_says(game):
	"""What the sage at (9, 1) says, talked to from below."""
	L.enter(game, "TIN_TOWER_1F", 9, 2)
	talk(game, "up")
	return screen_lines_until_idle(game)


def test_ho_oh_respawn_restores_the_sages(game):
	tin_tower_after_suicune(game)
	sage_before = sage5_says(game)

	game.set_event_flag("EVENT_FOUGHT_HO_OH") # Ho-Oh knocked out
	assert sage5_says(game) != sage_before, "the sage should talk about Ho-Oh after it"

	L.respawn(game)
	assert not game.event_flag("EVENT_FOUGHT_HO_OH")
	assert sage5_says(game) == sage_before, "the sage should be back to his before-Ho-Oh words"


def test_ho_oh_respawn_sends_eusine_away(game):
	"""Tin Tower 1F's callback shows Eusine with `appear` once Ho-Oh has been fought, which clears his
	object flag; the respawn used to clear EVENT_FOUGHT_HO_OH without hiding him again."""
	tin_tower_after_suicune(game)
	assert not eusine_shown(game), "Eusine shouldn't be in Tin Tower 1F before Ho-Oh"

	game.set_event_flag("EVENT_FOUGHT_HO_OH") # Ho-Oh knocked out
	assert eusine_shown(game), "Eusine should be in Tin Tower 1F after Ho-Oh"

	L.respawn(game)
	assert not eusine_shown(game), "Eusine should be gone again, as before Ho-Oh"


# Suicune: back where its scene left it, for a level 40 rematch

def suicune_knocked_out(game):
	L.get_ready(game)
	for flag in ("EVENT_FOUGHT_SUICUNE", "EVENT_TIN_TOWER_1F_SUICUNE"):
		game.set_event_flag(flag)
	game.poke("wTinTower1FSceneID", TIN_TOWER_1F_NOOP)


def test_suicune_rematch(game):
	suicune_knocked_out(game)
	L.respawn(game)

	L.enter(game, "TIN_TOWER_1F", 9, 11)
	struct = struct_for_object(game, "TinTower1F", "TINTOWER1F_SUICUNE")
	assert struct is not None, "Suicune should be in Tin Tower 1F"
	assert struct_position(game, struct) == (9, 9)

	L.meet(game, "TIN_TOWER_1F", (9, 10), "up")
	assert L.enemy_species(game) == L.species_index("SUICUNE")
	assert L.enemy_level(game) == 40
	L.knock_out(game) # this battle can't be run from
	assert not game.event_flag("EVENT_CAUGHT_SUICUNE")


def test_suicune_rematch_forced_shiny(game):
	suicune_knocked_out(game)
	game.set_event_flag("EVENT_DEBUG_FORCE_SHINY_BEASTS")
	game.poke("wRoamMon3Form", 0)
	L.respawn(game)

	L.enter(game, "TIN_TOWER_1F", 9, 15)
	assert game.peek("wRoamMon3Form") & L.SHINY_MASK, "its sprite's form should be shiny"
	L.meet(game, "TIN_TOWER_1F", (9, 10), "up")
	assert game.peek("wEnemyMonForm") & L.SHINY_MASK, "the battle should be shiny too"


# Celebi: the shrine offers a rematch, without the GS Ball, until it's fought again

SHRINE_SPOT = ("ILEX_FOREST", (8, 23), "up")


def test_celebi_returns_to_the_shrine(game):
	L.get_ready(game)
	game.set_event_flag("EVENT_FOUGHT_CELEBI") # knocked out or run from
	L.respawn(game)
	assert game.event_flag("EVENT_CELEBI_RETURNS")
	assert not key_item_owned(game, "GS_BALL")

	L.enter(game, "ILEX_FOREST", 8, 23)
	talk(game, "up")
	game.wait_for_text("SHRINE…")
	game.press("a")
	game.wait_for_text("warm…")
	answer_prompts(game, lambda: game.peek("wBattleMode") == 1)
	wait_for_battle_menu(game)
	assert L.enemy_species(game) == L.species_index("CELEBI")
	assert L.enemy_level(game) == 30

	L.knock_out(game) # this battle can't be run from
	assert not game.event_flag("EVENT_CELEBI_RETURNS"), "the shrine should be plain again"


def test_caught_celebi_stays_gone(game):
	L.get_ready(game, radio=False)
	game.set_event_flag("EVENT_FOUGHT_CELEBI")
	game.set_event_flag("EVENT_CAUGHT_CELEBI")
	L.respawn(game)
	assert not game.event_flag("EVENT_CELEBI_RETURNS")


# Mew: the truck gives it again on the fifth read

TRUCK_SPOT = ("VERMILION_PORT", (14, 11), "up")
DEX_CAUGHT_FOR_MEW = 250


def read_truck(game, times):
	"""Read the truck `times` times; whether a battle started."""
	L.enter(game, "VERMILION_PORT", 14, 11)
	for _ in range(times):
		talk(game, "up")
		answer_prompts(game, lambda: L.idle(game) or game.peek("wBattleMode") == 1)
		if game.peek("wBattleMode") == 1:
			return True
	return False


def fill_pokedex(game, caught):
	for byte in range(caught // 8):
		game.poke("wPokedexCaught", 0xff, byte)
	game.poke("wPokedexCaught", (1 << (caught % 8)) - 1, caught // 8)


def test_mew_comes_back_to_the_truck(game):
	L.get_ready(game)
	fill_pokedex(game, DEX_CAUGHT_FOR_MEW)
	game.set_event_flag("EVENT_FOUGHT_MEW")
	assert not read_truck(game, 5), "Mew shouldn't be in the truck before the respawn"

	L.respawn(game)
	assert read_truck(game, 5), "Mew should be in the truck after the respawn"
	wait_for_battle_menu(game)
	assert L.enemy_species(game) == L.species_index("MEW")
	assert L.enemy_level(game) == 60


def test_caught_mew_stays_gone(game):
	L.get_ready(game)
	fill_pokedex(game, DEX_CAUGHT_FOR_MEW)
	game.set_event_flag("EVENT_FOUGHT_MEW")
	game.set_event_flag("EVENT_CAUGHT_MEW")
	L.respawn(game)
	assert not read_truck(game, 5)


# Sudowoodo: a second one on Route 36, and Route 37's twins still twins

def weird_tree_slot():
	"""SPRITE_WEIRD_TREE's place in wVariableSprites."""
	text = (constants.ROOT / "constants" / "sprite_constants.asm").read_text(encoding="utf-8")
	names = re.findall(r"^\s*const (SPRITE_\w+)", text.split("DEF SPRITE_VARS EQU const_value")[1], re.M)
	return names.index("SPRITE_WEIRD_TREE")


def sprite_constant(name):
	return constants._consts(constants.ROOT / "constants" / "sprite_constants.asm")[name]


def test_second_sudowoodo_leaves_the_twins_alone(game):
	L.get_ready(game)
	for flag in ("EVENT_FOUGHT_SUDOWOODO", "EVENT_ROUTE_36_SUDOWOODO"):
		game.set_event_flag(flag)
	# what the first Sudowoodo's battle leaves, so Route 37's twins look like twins
	game.poke("wVariableSprites", sprite_constant("SPRITE_TWIN"), weird_tree_slot())
	L.respawn(game)

	L.meet(game, "ROUTE_36", (34, 9), "right")
	assert L.enemy_species(game) == L.species_index("SUDOWOODO")
	L.knock_out(game)
	assert game.peek("wVariableSprites", weird_tree_slot()) == sprite_constant("SPRITE_TWIN"), \
		"Route 37's twins should still be drawn as twins"


# The Route 11 Snorlax: asleep, until the Poke Flute channel plays

def test_route_11_snorlax_wakes_to_the_poke_flute(game):
	L.get_ready(game)
	game.set_event_flag("EVENT_FOUGHT_SNORLAX")
	L.respawn(game)

	L.enter(game, "ROUTE_11", 30, 13)
	struct = struct_for_object(game, "Route11", "ROUTE11_BIG_SNORLAX")
	assert struct is not None and struct_position(game, struct) == (31, 13)

	talk(game, "right")
	answer_prompts(game, lambda: L.idle(game) or game.peek("wBattleMode") != 0)
	assert game.peek("wBattleMode") == 0, "asleep, it shouldn't battle"

	game.poke("wMapMusic", L.music_constant("MUSIC_POKE_FLUTE_CHANNEL"))
	talk(game, "right")
	answer_prompts(game, lambda: game.peek("wBattleMode") == 1)
	assert L.enemy_species(game) == L.species_index("SNORLAX")
	assert L.enemy_level(game) == 50


# The Red Gyarados: a rematch gives no second Red Scale, and Lance stays away

def test_red_gyarados_rematch(game):
	L.get_ready(game)
	for flag in ("EVENT_LAKE_OF_RAGE_RED_GYARADOS", "EVENT_CLEARED_ROCKET_HIDEOUT",
			"EVENT_LAKE_OF_RAGE_LANCE"):
		game.set_event_flag(flag)
	L.respawn(game)

	# Surf beside it, out on the lake
	game.warp("LAKE_OF_RAGE", 18, 23)
	game.poke("wPlayerState", 4) # PLAYER_SURF
	game.wait(30)
	talk(game, "up")
	answer_prompts(game, lambda: game.peek("wBattleMode") == 1)
	wait_for_battle_menu(game)
	assert L.enemy_species(game) == L.species_index("GYARADOS")
	L.knock_out(game)
	screen_lines_until_idle(game)

	assert not key_item_owned(game, "RED_SCALE"), "a rematch shouldn't give another Red Scale"
	assert game.event_flag("EVENT_LAKE_OF_RAGE_LANCE"), "Lance shouldn't come back"
	assert not game.object_shown("LakeOfRage", "LAKEOFRAGE_LANCE")


# The Rocket Base Electrodes: no Lance and no HM after the last one

ELECTRODE_SPOTS = [(6, 5), (6, 7), (6, 9)] # left of each, facing right


def test_electrodes_rematch_has_no_lance_scene(game):
	L.get_ready(game)
	for flag in ["EVENT_CLEARED_ROCKET_HIDEOUT", "EVENT_GOT_HM06_WHIRLPOOL",
			"EVENT_TEAM_ROCKET_BASE_B2F_LANCE"] + \
			["EVENT_TEAM_ROCKET_BASE_B2F_ELECTRODE_%d" % n for n in (1, 2, 3)]:
		game.set_event_flag(flag)
	L.respawn(game)

	for spot in ELECTRODE_SPOTS:
		L.meet(game, "TEAM_ROCKET_BASE_B2F", spot, "right")
		assert L.enemy_species(game) == L.species_index("ELECTRODE")
		L.knock_out(game)
		screen_lines_until_idle(game)
		# Lance's scene (and his HM06) starts by walking the player away from the last Electrode
		assert game.position() == spot, "no Lance scene after the Electrodes come back"
	assert not game.object_shown("TeamRocketBaseB2F", "TEAMROCKETBASEB2F_LANCE"), "no Lance"
	assert not game.event_flag("EVENT_CAUGHT_ROCKET_ELECTRODE")


def test_caught_electrode_keeps_them_all_away(game):
	L.get_ready(game)
	for flag in ["EVENT_CLEARED_ROCKET_HIDEOUT", "EVENT_GOT_HM06_WHIRLPOOL",
			"EVENT_TEAM_ROCKET_BASE_B2F_LANCE"] + \
			["EVENT_TEAM_ROCKET_BASE_B2F_ELECTRODE_%d" % n for n in (1, 2, 3)]:
		game.set_event_flag(flag)
	L.respawn(game)
	L.meet(game, "TEAM_ROCKET_BASE_B2F", ELECTRODE_SPOTS[0], "right")
	L.catch(game)
	screen_lines_until_idle(game)
	assert game.event_flag("EVENT_CAUGHT_ROCKET_ELECTRODE")

	# the other two, knocked out, and the next respawn
	for n in (2, 3):
		game.set_event_flag("EVENT_TEAM_ROCKET_BASE_B2F_ELECTRODE_%d" % n)
	L.respawn(game)
	L.enter(game, "TEAM_ROCKET_BASE_B2F", 3, 14)
	assert not any(game.object_shown("TeamRocketBaseB2F", "TEAMROCKETBASEB2F_ELECTRODE%d" % n)
		for n in range(1, 7)), "none should come back once one is caught"


# The real trigger: winning the Elite Four runs the respawn before the Hall of Fame saves

def test_elite_four_win_respawns_before_the_save(game):
	L.get_ready(game, radio=False)
	for flag in ("EVENT_FOUGHT_MEWTWO", "EVENT_CERULEAN_CAVE_B1F_MEWTWO"): # knocked out
		game.set_event_flag(flag)

	# Into the Hall of Fame with Lance, as after beating him
	L.warp_into_scene(game, "HALL_OF_FAME", 5, 13)
	for _ in range(400):
		if L.saved_event_flag(game, "EVENT_BEAT_ELITE_FOUR"):
			break
		game.press("a", after=20)
	assert L.saved_event_flag(game, "EVENT_BEAT_ELITE_FOUR"), "the Hall of Fame should have saved"

	assert not game.event_flag("EVENT_FOUGHT_MEWTWO"), "the win should run the respawn"
	assert not L.saved_event_flag(game, "EVENT_FOUGHT_MEWTWO"), \
		"the save should already have Mewtwo back, so a reset during the credits keeps it"
