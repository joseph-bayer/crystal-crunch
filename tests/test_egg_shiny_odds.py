"""An egg's shiny odds by how many of its parents are shiny.

Bug: with one shiny parent the roll compared against the two-parent numerator, so one shiny parent
gave 1/32 like two, not the 1/64 the comment and README promise. Each case runs the egg's own roll
from a thousand seeds and checks every result against the test ROM's fixed random sequence."""

import pytest

from harness.alt_shiny import TestRandom as RandomSequence, call

SHINY = 0x80
SEEDS = range(1, 1001)

# The numerators in constants/pokemon_data_constants.asm
SHINY_EGG_NUMERATOR = 16 # after a 1/256 gate: 16/65536 = 1/4096
SHINY_EGG_ONE_SHINY_PARENT_NUMERATOR = 4 # 4/256 = 1/64
SHINY_EGG_TWO_SHINY_PARENTS_NUMERATOR = 8 # 8/256 = 1/32


def expected_shiny(seed, shiny_parents):
	rng = RandomSequence(seed)
	if shiny_parents == 2:
		return rng.next() < SHINY_EGG_TWO_SHINY_PARENTS_NUMERATOR
	if shiny_parents == 1:
		return rng.next() < SHINY_EGG_ONE_SHINY_PARENT_NUMERATOR
	return rng.next() == 0 and rng.next() < SHINY_EGG_NUMERATOR


@pytest.mark.parametrize("shiny_parents", [0, 1, 2])
def test_egg_shiny_odds(game, shiny_parents):
	mismatches = []
	shinies = 0
	for seed in SEEDS:
		game.poke("wBreedMon1Form", SHINY if shiny_parents >= 1 else 0)
		game.poke("wBreedMon2Form", SHINY if shiny_parents == 2 else 0)
		game.poke("wEggMonForm", 0)
		game.seed_random(seed)
		call(game, "DayCare_InitBreeding.Shininess")
		shiny = bool(game.peek("wEggMonForm") & SHINY)
		shinies += shiny
		if shiny != expected_shiny(seed, shiny_parents):
			mismatches.append(seed)
	assert not mismatches, "%d seeds disagree with the odds, e.g. %s" % (len(mismatches), mismatches[:5])
	# The fixed sequence gives some shinies wherever the odds are this generous
	if shiny_parents:
		assert shinies, "no shiny egg in a thousand seeds"
