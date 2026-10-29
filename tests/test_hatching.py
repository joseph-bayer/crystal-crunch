"""A hatched mon's caught ball is a Poke Ball, whichever party slot the egg is in.

The bug this guards against (22ffd2e88): the hatch set the ball on the last party slot instead of
the egg's, so an egg anywhere but last hatched with its ball byte still 0, a Master Ball, and the
last mon's ball was overwritten."""

import pytest

from harness.forms import (CAUGHT_BALL_MASK, CAUGHT_MASTER_BALL, CAUGHT_POKE_BALL, EGG,
	answer_prompts, party_field, set_party_field, take_radio_items)

# Eggs count down one cycle every 256 steps, on the step that brings the counter to $80.
STEP_BEFORE_EGG_CYCLE = 0x7f

# A ball that isn't a Poke Ball, to see whether the last slot's ball gets overwritten
OTHER_BALL = 1


@pytest.mark.parametrize("egg_slot", [0, 2])
def test_hatched_mon_gets_a_poke_ball(game, egg_slot):
	take_radio_items(game)
	count = game.peek("wPartyCount")
	last = count - 1
	assert egg_slot != last, "the egg must not be last, or the bug can't show"

	# An egg one cycle from hatching, its ball byte as a new egg's: 0
	game.poke("wPartySpecies", EGG, egg_slot)
	set_party_field(game, egg_slot, "Happiness", 1)
	set_party_field(game, egg_slot, "CaughtBall", CAUGHT_MASTER_BALL)
	set_party_field(game, last, "CaughtBall", OTHER_BALL)
	game.poke("wStepCount", STEP_BEFORE_EGG_CYCLE)

	game.step("down")
	answer_prompts(game, lambda: game.peek("wPartySpecies", egg_slot) != EGG
		and game.peek("wScriptRunning") == 0 and game.peek("wWindowStackSize") == 0)

	assert game.peek("wPartySpecies", egg_slot) == party_field(game, egg_slot, "Species"), (
		"the egg should have hatched into the mon inside it")
	assert party_field(game, egg_slot, "CaughtBall") & CAUGHT_BALL_MASK == CAUGHT_POKE_BALL, (
		"the hatched mon should come in a Poke Ball")
	assert party_field(game, last, "CaughtBall") == OTHER_BALL, (
		"the last party mon's ball shouldn't change")
