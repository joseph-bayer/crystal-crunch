"""The enemy HUD in a wild battle: the form symbol sits beside the caught-ball symbol, not on it.

The bug this guards against (763b36b25): the form symbol was drawn at (1, 1), where the ball that
marks an already-caught species goes, so a caught species with a form showed no ball."""

from harness.forms import (form_constant, party_field, party_species, super_nerd_menu,
	take_radio_items, wait_for_battle_menu, wait_until)

SCREEN_WIDTH = 20

# The ball marking a caught species, and the beta Kingdra's form symbol ("<CARTRIDGE>")
CAUGHT_BALL_TILE = 0x5d
CARTRIDGE_TILE = 0xc4


def tilemap_at(game, x, y):
	return game.peek("wTilemap", y * SCREEN_WIDTH + x)


def test_form_symbol_beside_caught_ball(game):
	take_radio_items(game)
	# The radio's beta Kingdra: its species is caught, and its 8-bit id is in use
	beta = form_constant("KINGDRA_BETA_FORM")
	slot = next(i for i in range(game.peek("wPartyCount")) if party_field(game, i, "Form") == beta)
	kingdra = party_species(game)[slot]

	# WILD MEW, turned into a wild beta Kingdra. Starting the battle copies the scripted species
	# into the battle's own at once, but the enemy is only loaded once the transition is over.
	super_nerd_menu(game, "HP BATTLES", "WILD MEW")
	assert game.peek("wBattleMode") == 0, "the battle shouldn't have loaded its enemy yet"
	for symbol in ("wTempWildMonSpecies", "wTempEnemyMonSpecies", "wCurPartySpecies"):
		game.poke(symbol, kingdra)
	game.poke("wTempWildMonForm", beta)
	wait_until(game, lambda: game.peek("wBattleMode") == 1, "the wild battle")
	wait_for_battle_menu(game)
	assert game.peek("wEnemyMonSpecies") == kingdra, "the wild mon should be the Kingdra"
	assert game.peek("wEnemyMonForm") == beta, "the wild Kingdra should be in its beta form"

	assert tilemap_at(game, 1, 1) == CAUGHT_BALL_TILE, "the caught ball should be at (1, 1)"
	assert tilemap_at(game, 2, 1) == CARTRIDGE_TILE, "the form symbol should be at (2, 1)"
