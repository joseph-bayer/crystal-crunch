"""The legendaries' battles played for real, before and after the respawn.

test_legendary_respawn.py sets the flags a battle leaves behind; these play the battles, so the
map scripts' own fought and caught checks are what the respawn reads. Also: a respawn on a new game
changes nothing, a bird stays hidden below sixteen badges, Vermilion's Snorlax stays off Diglett's
Cave, and the Burned Tower's release still puts both beasts out at level 40."""

import re

from harness import constants
from harness import legendaries as L
from harness.forms import answer_prompts, wait_for_battle_menu

TIN_TOWER_1F_NOOP = 1
PLAYER_SURF = 4


def talk(game, facing):
	game.press(facing, after=10)
	game.press("a")


def key_item_bit(name):
	text = (constants.ROOT / "constants" / "item_constants.asm").read_text(encoding="utf-8")
	return int(re.search(r"const %s\s*; ([0-9A-Fa-f]{4})" % name, text).group(1), 16) & 0xff


def give_key_item(game, name):
	bit = key_item_bit(name)
	game.poke("wKeyItemFlags", game.peek("wKeyItemFlags", bit // 8) | 1 << (bit % 8), bit // 8)


def key_item_owned(game, name):
	bit = key_item_bit(name)
	return bool(game.peek("wKeyItemFlags", bit // 8) & 1 << (bit % 8))


def say_yes_into_battle(game):
	"""Press through text, answering YES, until a battle starts."""
	for _ in range(200):
		if game.peek("wBattleMode") == 1:
			break
		if "YES" in game.screen_text() and "NO" in game.screen_text():
			game.choose("YES")
		else:
			game.press("a", after=30)
	wait_for_battle_menu(game)


def settle(game):
	"""Press through whatever the script says after the battle, until the player can move."""
	answer_prompts(game, lambda: L.idle(game))


def shown(game, map_name, spot, map_file, obj):
	L.enter(game, map_name, *spot)
	return game.object_shown(map_file, obj)


def flute_playing(game):
	game.poke("wMapMusic", L.music_constant("MUSIC_POKE_FLUTE_CHANNEL"))


# Sudowoodo: the weird tree's own battle, then the second one the respawn puts there

TREE = ("ROUTE_36", (34, 9))


def water_the_tree(game):
	L.get_ready(game)
	give_key_item(game, "SQUIRTBOTTLE")
	L.enter(game, TREE[0], *TREE[1])
	talk(game, "right")
	say_yes_into_battle(game)
	assert L.enemy_species(game) == L.species_index("SUDOWOODO")


def respawned_sudowoodo_shown(game):
	return shown(game, "ROUTE_36", TREE[1], "Route36", "ROUTE36_SUDOWOODO_RESPAWN")


def test_sudowoodo_knocked_out_then_caught_on_its_return(game):
	water_the_tree(game)
	L.knock_out(game)
	settle(game)
	assert game.event_flag("EVENT_FOUGHT_SUDOWOODO")
	assert not game.event_flag("EVENT_CAUGHT_SUDOWOODO")
	assert not respawned_sudowoodo_shown(game), "no second Sudowoodo before the respawn"
	assert not game.object_shown("Route36", "ROUTE36_WEIRD_TREE")

	L.respawn(game)
	assert respawned_sudowoodo_shown(game)
	assert not game.object_shown("Route36", "ROUTE36_WEIRD_TREE"), "the first one stays gone"
	L.meet(game, "ROUTE_36", TREE[1], "right")
	L.catch(game)
	settle(game)
	assert game.event_flag("EVENT_CAUGHT_SUDOWOODO")

	L.respawn(game)
	assert not respawned_sudowoodo_shown(game), "a caught Sudowoodo should not come back"


def test_sudowoodo_caught_the_first_time_never_returns(game):
	water_the_tree(game)
	L.catch(game)
	settle(game)
	assert game.event_flag("EVENT_CAUGHT_SUDOWOODO")

	L.respawn(game)
	assert not respawned_sudowoodo_shown(game)


def test_sudowoodo_run_from_comes_back(game):
	water_the_tree(game)
	L.run_away(game)
	settle(game)
	assert game.event_flag("EVENT_FOUGHT_SUDOWOODO")

	L.respawn(game)
	assert respawned_sudowoodo_shown(game)


# Vermilion's Snorlax: knocked out there, back on Route 11, and Diglett's Cave stays open

VERMILION_SNORLAX_SPOT = (33, 8) # left of it, one of SnorlaxAwake's tiles
ROUTE_11_SNORLAX_SPOT = (30, 13)


def vermilion_snorlax_shown(game):
	return shown(game, "VERMILION_CITY", VERMILION_SNORLAX_SPOT, "VermilionCity",
		"VERMILIONCITY_BIG_SNORLAX")


def route_11_snorlax_shown(game):
	return shown(game, "ROUTE_11", ROUTE_11_SNORLAX_SPOT, "Route11", "ROUTE11_BIG_SNORLAX")


def wake_and_meet(game, map_name, spot, facing):
	L.enter(game, map_name, *spot)
	flute_playing(game)
	talk(game, facing)
	answer_prompts(game, lambda: game.peek("wBattleMode") == 1)
	wait_for_battle_menu(game)
	assert L.enemy_species(game) == L.species_index("SNORLAX")


def test_vermilion_snorlax_returns_on_route_11(game):
	L.get_ready(game)
	assert not route_11_snorlax_shown(game), "Route 11's Snorlax waits for a respawn"
	wake_and_meet(game, "VERMILION_CITY", VERMILION_SNORLAX_SPOT, "right")
	L.knock_out(game)
	settle(game)
	assert game.event_flag("EVENT_FOUGHT_SNORLAX")
	assert not game.event_flag("EVENT_CAUGHT_SNORLAX")

	L.respawn(game)
	assert route_11_snorlax_shown(game)
	assert not vermilion_snorlax_shown(game), "Diglett's Cave should stay open"

	wake_and_meet(game, "ROUTE_11", ROUTE_11_SNORLAX_SPOT, "right")
	L.catch(game)
	settle(game)
	assert game.event_flag("EVENT_CAUGHT_SNORLAX")
	L.respawn(game)
	assert not route_11_snorlax_shown(game), "a caught Snorlax should not come back"
	assert not vermilion_snorlax_shown(game)


def test_vermilion_snorlax_caught_never_returns(game):
	L.get_ready(game)
	wake_and_meet(game, "VERMILION_CITY", VERMILION_SNORLAX_SPOT, "right")
	L.catch(game)
	settle(game)
	assert game.event_flag("EVENT_CAUGHT_SNORLAX")

	L.respawn(game)
	assert not route_11_snorlax_shown(game)
	assert not vermilion_snorlax_shown(game)


# The Apricorn Forest's Snorlax

APRICORN_SNORLAX_SPOT = (8, 4)


def apricorn_snorlax_shown(game):
	return shown(game, "APRICORN_FOREST_CLEARING", APRICORN_SNORLAX_SPOT, "ApricornForestClearing",
		"APRICORNFORESTCLEARING_BIG_SNORLAX")


def test_apricorn_snorlax_knocked_out_comes_back_and_caught_stays_gone(game):
	L.get_ready(game)
	wake_and_meet(game, "APRICORN_FOREST_CLEARING", APRICORN_SNORLAX_SPOT, "up")
	L.knock_out(game)
	settle(game)
	assert not apricorn_snorlax_shown(game)

	L.respawn(game)
	assert apricorn_snorlax_shown(game)
	wake_and_meet(game, "APRICORN_FOREST_CLEARING", APRICORN_SNORLAX_SPOT, "up")
	L.catch(game)
	settle(game)
	assert game.event_flag("EVENT_CAUGHT_APRICORN_SNORLAX")

	L.respawn(game)
	assert not apricorn_snorlax_shown(game)


# The Red Gyarados: the first battle, caught, gives the Red Scale and never comes back

def meet_red_gyarados(game):
	game.warp("LAKE_OF_RAGE", 18, 23)
	game.poke("wPlayerState", PLAYER_SURF)
	game.wait(30)
	talk(game, "up")
	answer_prompts(game, lambda: game.peek("wBattleMode") == 1)
	wait_for_battle_menu(game)
	assert L.enemy_species(game) == L.species_index("GYARADOS")


def red_gyarados_shown(game):
	return shown(game, "LAKE_OF_RAGE", (20, 26), "LakeOfRage", "LAKEOFRAGE_GYARADOS")


def test_red_gyarados_caught_in_its_first_battle(game):
	L.get_ready(game)
	meet_red_gyarados(game)
	L.catch(game)
	settle(game)
	assert game.event_flag("EVENT_CAUGHT_RED_GYARADOS")
	assert key_item_owned(game, "RED_SCALE"), "the first battle still gives the Red Scale"

	game.set_event_flag("EVENT_CLEARED_ROCKET_HIDEOUT")
	L.respawn(game)
	assert not red_gyarados_shown(game), "a caught Red Gyarados should not come back"


def test_red_gyarados_caught_in_its_rematch(game):
	L.get_ready(game)
	for flag in ("EVENT_LAKE_OF_RAGE_RED_GYARADOS", "EVENT_CLEARED_ROCKET_HIDEOUT",
			"EVENT_LAKE_OF_RAGE_LANCE"):
		game.set_event_flag(flag)
	L.respawn(game)
	meet_red_gyarados(game)
	L.catch(game)
	settle(game)
	assert game.event_flag("EVENT_CAUGHT_RED_GYARADOS")

	L.respawn(game)
	assert not red_gyarados_shown(game)


# Suicune's and Celebi's rematches, caught

def test_suicune_caught_in_its_rematch(game):
	L.get_ready(game)
	for flag in ("EVENT_FOUGHT_SUICUNE", "EVENT_TIN_TOWER_1F_SUICUNE"):
		game.set_event_flag(flag)
	game.poke("wTinTower1FSceneID", TIN_TOWER_1F_NOOP)
	L.respawn(game)

	L.meet(game, "TIN_TOWER_1F", (9, 10), "up")
	assert L.enemy_species(game) == L.species_index("SUICUNE")
	L.catch(game)
	settle(game)
	assert game.event_flag("EVENT_CAUGHT_SUICUNE")
	assert not shown(game, "TIN_TOWER_1F", (9, 15), "TinTower1F", "TINTOWER1F_SUICUNE")

	L.respawn(game)
	assert not shown(game, "TIN_TOWER_1F", (9, 15), "TinTower1F", "TINTOWER1F_SUICUNE")


def test_celebi_caught_in_its_rematch(game):
	L.get_ready(game)
	game.set_event_flag("EVENT_FOUGHT_CELEBI")
	L.respawn(game)

	L.enter(game, "ILEX_FOREST", 8, 23)
	talk(game, "up")
	answer_prompts(game, lambda: game.peek("wBattleMode") == 1)
	wait_for_battle_menu(game)
	assert L.enemy_species(game) == L.species_index("CELEBI")
	L.catch(game)
	settle(game)
	assert game.event_flag("EVENT_CAUGHT_CELEBI")
	assert not game.event_flag("EVENT_CELEBI_RETURNS")

	L.respawn(game)
	assert not game.event_flag("EVENT_CELEBI_RETURNS"), "a caught Celebi should not come back"


# What a respawn leaves alone

# Flags a respawn may only change on a save that has fought something
RESPAWN_TOUCHES = ("EVENT_LAKE_OF_RAGE_RED_GYARADOS", "EVENT_APRICORN_FOREST_CLEARING_SNORLAX",
	"EVENT_CERULEAN_CAVE_B1F_MEWTWO")


def test_respawn_on_a_new_game_changes_nothing(game):
	L.get_ready(game, radio=False)
	before = game.peek("wEventFlags", 0, 256)
	roamers = [L.roam(game, n) for n in (1, 2)]

	L.respawn(game)
	after = game.peek("wEventFlags", 0, 256)
	names = {number: name for name, number in constants.event_flags().items()}
	changed = [names.get(byte * 8 + bit, "flag %d" % (byte * 8 + bit))
		for byte in range(256) for bit in range(8)
		if (before[byte] ^ after[byte]) & 1 << bit]
	assert not changed, "a respawn with nothing fought changed: %s" % ", ".join(changed)
	assert [L.roam(game, n) for n in (1, 2)] == roamers
	for flag in RESPAWN_TOUCHES:
		assert not game.event_flag(flag), "%s starts clear, so clearing it changes nothing" % flag


def test_respawned_bird_still_waits_for_sixteen_badges(game):
	L.get_ready(game, radio=False)
	game.set_event_flag("EVENT_FOUGHT_ZAPDOS")
	L.respawn(game)
	game.poke("wJohtoBadges", 0)
	game.poke("wKantoBadges", 0)
	assert not shown(game, "ROUTE_10_NORTH", (4, 10), "Route10North", "ROUTE10NORTH_ZAPDOS")


def test_second_respawn_changes_nothing(game):
	L.get_ready(game, radio=False)
	for flag in ("EVENT_FOUGHT_MEWTWO", "EVENT_CERULEAN_CAVE_B1F_MEWTWO", "EVENT_FOUGHT_CELEBI",
			"EVENT_FOUGHT_SUDOWOODO", "EVENT_ROUTE_36_SUDOWOODO", "EVENT_FOUGHT_SNORLAX"):
		game.set_event_flag(flag)
	game.set_event_flag("EVENT_RELEASED_THE_BEASTS")
	L.set_roam(game, 1, Species=0, Level=40, MapGroup=0xff, MapNumber=0xff, HP=0, DVs=(1, 2), Form=0)
	L.respawn(game)
	flags = game.peek("wEventFlags", 0, 256)
	roamers = [L.roam(game, n) for n in (1, 2)]

	L.respawn(game)
	assert game.peek("wEventFlags", 0, 256) == flags
	assert [L.roam(game, n) for n in (1, 2)] == roamers, "a beast already back should be left alone"


# The Burned Tower's release, which now goes through InitRoamRaikou and InitRoamEntei

def test_release_puts_both_beasts_out_at_40(game):
	L.get_ready(game, radio=False)
	# STORY -> BEASTS -> POST-RELEASE runs the same special the Burned Tower does
	game.warp("PLAYERS_HOUSE_2F", *L.SCIENTIST_SPOT)
	game.press("up")
	game.press("a")
	game.wait_for_text("BEASTS")
	game.choose("BEASTS")
	game.wait_for_text("POST-RELEASE")
	game.choose("POST-RELEASE")
	answer_prompts(game, lambda: L.idle(game))

	for number, beast, route in ((1, "RAIKOU", "ROUTE_42"), (2, "ENTEI", "ROUTE_37")):
		roamer = L.roam(game, number)
		assert L.index_of_id(game, roamer["Species"]) == L.species_index(beast)
		assert roamer["Level"] == 40
		assert (roamer["MapGroup"], roamer["MapNumber"]) == constants.maps()[route]
		assert roamer["HP"] == 0
