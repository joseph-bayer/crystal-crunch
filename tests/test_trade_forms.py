"""NPC trades and forms: the trade screen shows both mons' forms, and the mon you get has the trade's
own form, not the last battle's.

The bugs this guards against (b86322c52):
* the trade screen didn't know either mon's form, so it drew them plain;
* the mon you got took its form from wEnemyMonForm, which still held whatever the last battle left.

The debug Super Nerd's TRADE takes any party mon and offers a shiny Surfing Pikachu."""

from harness.forms import (SHINY_MASK, answer_prompts, form_constant, party_field, set_party_field,
	super_nerd_menu, take_radio_items)

# What the last battle would leave behind: plain, not shiny, unlike the trade's Pikachu.
LEFTOVER_FORM = 0


def test_npc_trade_forms(game):
	take_radio_items(game)
	offered = SHINY_MASK # the first party mon, which the trade takes
	set_party_field(game, 0, "Form", offered)
	game.poke("wEnemyMonForm", LEFTOVER_FORM)
	traded_form = form_constant("PIKACHU_SURF_FORM") | SHINY_MASK

	super_nerd_menu(game, "TRADE")
	# YES to the trade, and the party menu's cursor starts on the first mon
	answer_yes = True
	for _ in range(200):
		text = game.screen_text()
		if game.peek("wScriptRunning") == 0 and game.peek("wWindowStackSize") == 0:
			break
		if "YES" in text and "NO" in text and answer_yes:
			game.choose("YES")
			answer_yes = False
			continue
		game.press("a", after=40)
	else:
		raise AssertionError("the trade never finished. The screen:\n" + game.screen_text())

	assert game.peek("wPlayerTrademonForm") == offered, "the trade screen should show your mon's form"
	assert game.peek("wOTTrademonForm") == traded_form, "the trade screen should show the Pikachu's form"
	last = game.peek("wPartyCount") - 1
	assert party_field(game, last, "Form") == traded_form, (
		"the traded Pikachu should have the trade's form, not the last battle's")
