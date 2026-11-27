"""The RB Lapras swarm on Route 21 waits until the player has met the Union Cave Lapras.

Talking to the Lapras (Union Cave B2F, Fridays) sets EVENT_MET_UNION_CAVE_LAPRAS before its battle,
so catching it, beating it and running from it all count. The radio offers the swarm only with
that flag and, as a Kanto row, only after the Elite Four."""

from harness import overworld as O

from test_alt_shiny import swarm_ids
from test_swarm_radio import picks_over_seeds

MET_LAPRAS = "EVENT_MET_UNION_CAVE_LAPRAS"
FRIDAY = 5 # SUNDAY is 0
PLAYER_SURF = 4
LAPRAS_HOME = (11, 31)
BELOW_LAPRAS = (11, 32) # on the water, facing up


def make_it_friday(game):
	"""Shift the clock's start day so today is a Friday; the game rereads the clock each frame."""
	game.poke("wStartDay", (game.peek("wStartDay") + FRIDAY - game.peek("wCurDay") % 7) % 7)
	game.wait(10)
	assert game.peek("wCurDay") % 7 == FRIDAY


def lapras_swarm():
	return swarm_ids()["SWARM_LAPRAS_RB"]


def test_talking_to_the_lapras_marks_it_met(game):
	make_it_friday(game)
	game.warp("UNION_CAVE_B2F", *BELOW_LAPRAS)
	game.poke("wPlayerState", PLAYER_SURF)
	game.wait(30)
	lapras = O.struct_for_object(game, "UnionCaveB2F", "UNIONCAVEB2F_LAPRAS")
	assert lapras is not None and O.struct_position(game, lapras) == LAPRAS_HOME
	assert not game.event_flag(MET_LAPRAS)
	game.press("up", after=10)
	game.press("a")
	for _ in range(20):
		game.wait(10)
		if game.event_flag(MET_LAPRAS):
			break
	assert game.event_flag(MET_LAPRAS), "talking to it sets the flag, before its battle"
	assert game.peek("wScriptRunning"), "and its script goes on into the battle"


def test_the_radio_offers_rb_lapras_only_once_met(game):
	game.set_event_flag("EVENT_BEAT_ELITE_FOUR")
	assert lapras_swarm() not in picks_over_seeds(game)
	game.set_event_flag(MET_LAPRAS)
	assert lapras_swarm() in picks_over_seeds(game)


def test_meeting_the_lapras_is_not_enough_before_the_elite_four(game):
	game.set_event_flag(MET_LAPRAS)
	assert lapras_swarm() not in picks_over_seeds(game)
