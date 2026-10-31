"""Battle Tower trainers' lines, from BattleTowerText.

Its section moved from bank $47 to $22 to make room for the wandering mon's rosters. Everything
reaches it by farcall, so the move shouldn't matter; this prints each kind of line to show it
still works from its new bank."""

import re

import pytest

from harness import data
from harness.alt_shiny import call

BATTLETOWERTEXT_INTRO = 1
BATTLETOWERTEXT_LOSS = 2
BATTLETOWERTEXT_WIN = 3


def letters(line):
	"""A line's letters alone. 'm, 's and the like are one tile each, which the screen reader
	doesn't spell out, so they're dropped too."""
	return re.sub(r"[^A-Za-z]", "", re.sub(r"'[a-z]+|<[^>]*>", "", line))


def battle_tower_lines():
	"""Every line of the Battle Tower trainers' text, as letters."""
	text = data.read("data/battle_tower/trainer_text.asm")
	return {letters(line) for line in re.findall(r'^\s*(?:text|line|cont|para)\s+"([^"]*)"', text, re.M)}


@pytest.mark.parametrize("trainer_class", [1, 2])
@pytest.mark.parametrize("kind", [BATTLETOWERTEXT_INTRO, BATTLETOWERTEXT_LOSS, BATTLETOWERTEXT_WIN])
def test_battle_tower_text_prints(game, trainer_class, kind):
	game.poke("wBT_OTTrainerClass", trainer_class)
	call(game, "BattleTowerText", bc=kind)
	first_line = game.screen_lines()[-4].strip()
	assert letters(first_line) and letters(first_line) in battle_tower_lines(), \
		"not a Battle Tower line: %r" % first_line
