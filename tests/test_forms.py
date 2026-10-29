"""Forms on battle mon: a trainer's mon don't inherit the last battle's form, and a caught mon keeps
its own.

Two bugs this guards against:
* 060b8a294: a trainer whose party data has no forms got the form (and shiny bit) the last battle
  left in wEnemyMonForm, because adding a mon to a party seeds its form from there.
* 7e02834eb: catching a wild mon rolled its form again instead of keeping the one it was shown with,
  because the "already caught" check tested the wrong register."""

from harness.forms import (SHINY_MASK, answer_prompts, ot_party_field, out_of_battle,
	party_field, press_until, shorten_party, super_nerd_menu, take_radio_items, throw_ball,
	wait_for_battle_menu, wait_until)

# Any form byte a previous battle could have left behind: a shiny form 1.
LEFTOVER_FORM = SHINY_MASK | 1

# The roll the caught mon would get if its form were rolled again: not shiny.
SEED = 0x0001


def test_trainer_mon_dont_inherit_the_last_form(game):
	take_radio_items(game)
	# What the last wild battle would leave behind
	game.poke("wEnemyMonForm", LEFTOVER_FORM)

	# Brock's party has no forms in its data
	super_nerd_menu(game, "BROCK PIC")
	press_until(game, lambda: "YES" in game.screen_text(), "the battle's yes/no")
	game.choose("YES")
	wait_until(game, lambda: game.peek("wBattleMode") == 2 and game.peek("wOTPartyCount") > 0,
		"Brock's battle")
	wait_for_battle_menu(game)

	count = game.peek("wOTPartyCount")
	forms = [ot_party_field(game, slot, "Form") for slot in range(count)]
	assert forms == [0] * count, "Brock's mon should all be plain, not %s" % forms
	assert game.peek("wEnemyMonForm") == 0, "the mon Brock sent out should be plain"


def test_caught_mon_keeps_its_form(game):
	take_radio_items(game)
	shorten_party(game, 5) # room for the catch

	super_nerd_menu(game, "HP BATTLES", "WILD MEW")
	wait_until(game, lambda: game.peek("wBattleMode") == 1, "the wild battle")
	wait_for_battle_menu(game)

	# The form the wild Mew is shown with
	game.poke("wEnemyMonForm", SHINY_MASK)
	game.seed_random(SEED)
	throw_ball(game, "MASTER BALL")
	answer_prompts(game, lambda: out_of_battle(game))

	assert game.peek("wPartyCount") == 6, "the caught Mew should be in the party"
	assert party_field(game, 5, "Form") == SHINY_MASK, "the caught Mew should still be shiny"
