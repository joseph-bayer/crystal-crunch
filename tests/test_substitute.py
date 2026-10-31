"""Substitute fails when the user's HP is too low, instead of underflowing it, reported after v1.0.

An optimization had rewritten the HP subtraction's `ld a, [hl] / sbc 0` as `sbc a / add [hl]`. The
high byte came out the same, but the carry no longer meant the HP ran out: with under 256 HP and
less than a quarter of the max left, the HP wrapped to about 65,000 and the substitute went up, and
with 256 HP or more, a substitute that should have worked failed.

Each case is one turn of a wild battle (WILD MEW from the debug Super Nerd) in which both sides know
only Substitute, with both sides' HP set by hand, so the turn checks the player and the enemy."""

import pytest

from harness import constants
from harness.alt_shiny import _table_id
from harness.forms import (press_until, super_nerd_menu, take_radio_items, wait_for_battle_menu,
	wait_until)

SUBSTATUS_SUBSTITUTE = 1 << 4 # wPlayerSubStatus4 / wEnemySubStatus4
NUM_MOVES = 4

SIDES = {
	"player": ("wBattleMon", "wPlayerSubStatus4", "wPlayerSubstituteHP"),
	"enemy": ("wEnemyMon", "wEnemySubStatus4", "wEnemySubstituteHP"),
}


def word(game, symbol):
	high, low = game.peek(symbol, 0, 2)
	return high << 8 | low


def set_word(game, symbol, value):
	game.poke(symbol, value >> 8)
	game.poke(symbol, value & 0xff, 1)


def substitute_turn(game, hp, max_hp):
	"""Give both sides this HP and only Substitute, play one turn, and return each side's HP after,
	whether it has a substitute, and the substitute's HP."""
	take_radio_items(game)
	super_nerd_menu(game, "HP BATTLES", "WILD MEW")
	wait_until(game, lambda: game.peek("wBattleMode") == 1, "the wild battle")
	wait_for_battle_menu(game)

	index = constants._consts(constants.ROOT / "constants" / "move_constants.asm")["SUBSTITUTE"]
	substitute = _table_id(game, "wMoveIndexTable", index)
	for mon, _, _ in SIDES.values():
		for slot in range(NUM_MOVES):
			game.poke(mon + "Moves", substitute if slot == 0 else 0, slot)
			game.poke(mon + "PP", 10 if slot == 0 else 0, slot)
		set_word(game, mon + "MaxHP", max_hp)
		set_word(game, mon + "HP", hp)

	game.choose("FIGHT")
	game.wait(30)
	game.choose("SUBSTITUTE")
	game.wait(60)
	# Through both sides' turns, to the next menu
	press_until(game, lambda: "FIGHT" in game.screen_text(), "the next turn's menu", timeout=80)

	return {side: (word(game, mon + "HP"), bool(game.peek(substatus) & SUBSTATUS_SUBSTITUTE),
			game.peek(sub_hp))
		for side, (mon, substatus, sub_hp) in SIDES.items()}


def test_too_little_hp_fails(game):
	# A quarter of 200 is 50; 30 HP can't pay it.
	for side, (hp, has_sub, _) in substitute_turn(game, 30, 200).items():
		assert hp == 30, "the %s's HP should be untouched, not wrapped around" % side
		assert not has_sub, "no substitute should go up for the %s" % side


def test_exactly_a_quarter_fails(game):
	# Paying all 50 of 50 HP would faint the user, so it fails too.
	for side, (hp, has_sub, _) in substitute_turn(game, 50, 200).items():
		assert hp == 50, side
		assert not has_sub, side


def test_enough_hp_over_256_works(game):
	# A quarter of 300 is 75. 260 HP has a high byte of 1 and a low byte under 75: the subtraction
	# borrows from the high byte, and still leaves 185.
	for side, (hp, has_sub, sub_hp) in substitute_turn(game, 260, 300).items():
		assert hp == 185, side
		assert has_sub, side
		assert sub_hp == 75, side


@pytest.mark.parametrize("hp, max_hp, left, sub", [(120, 200, 70, 50)])
def test_enough_hp_under_256_works(game, hp, max_hp, left, sub):
	for side, (after, has_sub, sub_hp) in substitute_turn(game, hp, max_hp).items():
		assert after == left, side
		assert has_sub, side
		assert sub_hp == sub, side
