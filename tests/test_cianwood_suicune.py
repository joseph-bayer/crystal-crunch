"""Suicune at Cianwood City after a trip to the Mystery Island.

Seeing Suicune at the Burned Tower (or on Route 36) leaves it standing in Cianwood, with the scene
whose trigger tile makes it run off. Sailing back from the island replaced that scene with the
one for stepping off the boat, which then cleared it. Suicune stood there for good, and talking to
it gave the default "Object event" text. Now stepping off the boat puts the Suicune scene back,
and entering Cianwood repairs a save that was left without it."""

from harness import constants
from harness.game import MAPSETUP_WARP, MAPSTATUS_ENTER, SPAWN_N_A

# Cianwood's scenes, in the order of its scene_scripts
NOOP, SUICUNE_AND_EUSINE, ARRIVE_FROM_ISLAND = 0, 1, 2

DOCK = (29, 36) # where the boat sets the player down
TRIGGER = (11, 16) # the tile that sets Suicune running
SUICUNE = ("CianwoodCity", "CIANWOODCITY_SUICUNE")


def suicune_waiting(game):
	"""Suicune stands in Cianwood, and Eusine has been fought so no battle follows it."""
	game.set_event_flag("EVENT_SAW_SUICUNE_AT_CIANWOOD_CITY", False)
	game.set_event_flag("EVENT_FOUGHT_EUSINE")


def sail_back(game):
	"""The sailor's warp to the dock. Not game.warp, which expects the player to stay put: the
	scene for stepping off the boat moves them."""
	group, number = constants.maps()["CIANWOOD_CITY"]
	game.poke("wMapGroup", group)
	game.poke("wMapNumber", number)
	game.poke("wXCoord", DOCK[0])
	game.poke("wYCoord", DOCK[1])
	game.poke("wDefaultSpawnpoint", SPAWN_N_A)
	game.poke("hMapEntryMethod", MAPSETUP_WARP)
	game.poke("wMapStatus", MAPSTATUS_ENTER)


def walk_onto_the_trigger(game):
	game.warp("CIANWOOD_CITY", TRIGGER[0], TRIGGER[1] + 1)
	assert game.object_shown(*SUICUNE), "Suicune should be standing in Cianwood"
	game.step("up")
	game.wait(600) # the shock emote, then Suicune's two runs


def test_suicune_runs_off_after_an_island_trip(game):
	suicune_waiting(game)
	game.poke("wCianwoodCitySceneID", ARRIVE_FROM_ISLAND)
	sail_back(game)
	game.wait(300)
	assert game.position() == (DOCK[0], DOCK[1] - 1), "the player should have stepped onto the dock"
	assert game.peek("wCianwoodCitySceneID") == SUICUNE_AND_EUSINE

	walk_onto_the_trigger(game)
	assert game.event_flag("EVENT_SAW_SUICUNE_AT_CIANWOOD_CITY"), "Suicune should have run off"


def test_a_stuck_save_gets_the_suicune_scene_back(game):
	suicune_waiting(game)
	game.poke("wCianwoodCitySceneID", NOOP)
	walk_onto_the_trigger(game)
	assert game.event_flag("EVENT_SAW_SUICUNE_AT_CIANWOOD_CITY"), "Suicune should have run off"


def test_the_island_trip_still_ends_quietly_once_suicune_is_gone(game):
	game.set_event_flag("EVENT_SAW_SUICUNE_AT_CIANWOOD_CITY")
	game.poke("wCianwoodCitySceneID", NOOP)
	game.warp("CIANWOOD_CITY", TRIGGER[0], TRIGGER[1] + 1)
	assert game.peek("wCianwoodCitySceneID") == NOOP
	assert not game.object_shown(*SUICUNE)
