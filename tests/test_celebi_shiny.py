"""A shiny Celebi looks shiny before its battle too.

Celebi's shininess used to be rolled when the battle started, after the shrine's animation, so the
Celebi flying in was always the overworld green. Now it's rolled (at the legendary 1/512) before
Celebi appears, kept in a flag, drawn in its shiny colors in the animation, and used by the battle.
Both the first shrine scene (with the GS Ball) and a respawned Celebi roll it this way."""

import re

import pytest

from harness import constants
from harness.forms import take_radio_items

# Standing below the shrine (8, 22), facing up, where the debug warp puts you.
SHRINE_SPOT = (8, 23)

GS_BALL_KEY_ITEM = 0x0c # its index is $010C; key item flags are numbered by the low byte

# The animation's Celebi tiles: SPECIALCELEBIEVENT_CELEBI ($84) and its other three frames.
CELEBI_TILES = range(0x84, 0x94)
OAM = 0xfe00
OAM_ENTRIES = 40

# A seed whose first legendary roll isn't shiny.
NOT_SHINY_SEED = 0x0001

MAX_FRAMES = 3000
PALETTE_SIZE = 8
WHITE = 0x7fff


def rgb15(red, green, blue):
	return red | green << 5 | blue << 10


def celebi_shiny_colors():
	"""Celebi's shiny pic colors, light then dark, from its own palette file."""
	text = (constants.ROOT / "gfx" / "pokemon" / "celebi" / "shiny.pal").read_text()
	return [rgb15(*map(int, values)) for values in re.findall(r"RGB (\d+), (\d+), (\d+)", text)]


def obj_palette_7(game):
	"""The four colors of OBJ palette 7, as the game last applied them."""
	data = game.peek("wOBPals2", 7 * PALETTE_SIZE, PALETTE_SIZE)
	return [data[i] | data[i + 1] << 8 for i in range(0, PALETTE_SIZE, 2)]


def celebi_drawn(game):
	for entry in range(OAM_ENTRIES):
		y, x, tile = (game.pyboy.memory[OAM + entry * 4 + i] for i in range(3))
		if tile in CELEBI_TILES and 0 < y < 160 and 0 < x < 168:
			return True
	return False


def in_battle(game):
	return game.peek("wBattleMode") != 0


def advance_text(game, frame):
	"""Every so often, press A while a text box is open, to get through the scene's text."""
	if frame % 20 == 0 and "┌" in game.screen_text():
		game.press("a", after=0)


def set_force_shiny(game, shiny):
	take_radio_items(game) # a party, so there's a battle
	game.set_event_flag("EVENT_DEBUG_FORCE_SHINY_BEASTS", shiny)
	if not shiny:
		game.seed_random(NOT_SHINY_SEED)


def run_shrine_scene(game):
	"""Put the GS Ball in the shrine and return the colors Celebi flew in with and the battle's form."""
	flags = game.peek("wKeyItemFlags", GS_BALL_KEY_ITEM // 8)
	game.poke("wKeyItemFlags", flags | 1 << (GS_BALL_KEY_ITEM % 8), GS_BALL_KEY_ITEM // 8)
	game.set_event_flag("EVENT_FOREST_IS_RESTLESS")
	game.warp("ILEX_FOREST", *SHRINE_SPOT)
	game.press("up")
	game.press("a")
	for _ in range(20):
		if "YES" in game.screen_text():
			break
		game.press("a")
	game.choose("YES")

	colors = None
	for frame in range(MAX_FRAMES):
		if in_battle(game):
			break
		if celebi_drawn(game):
			colors = obj_palette_7(game)[1:3]
		advance_text(game, frame)
		game.wait(1)
	else:
		raise AssertionError("the battle never started. The screen:\n" + game.screen_text())
	game.wait(30)
	return colors, game.peek("wEnemyMonForm")


@pytest.mark.parametrize("shiny", [True, False])
def test_shrine_celebi_matches_its_battle(game, shiny):
	set_force_shiny(game, shiny)
	colors, form = run_shrine_scene(game)

	assert colors is not None, "Celebi never flew in"
	assert bool(form & 0x80) == shiny, "the battle's Celebi should be %s" % ("shiny" if shiny else "plain")
	assert game.event_flag("EVENT_CELEBI_SHINY") == shiny
	if shiny:
		# the leaf sprite takes white where the pic's dark color would go, then the pic's light color
		assert colors == [WHITE, celebi_shiny_colors()[0]], "a shiny Celebi should fly in its shiny colors"
	else:
		assert colors != celebi_shiny_colors(), "a plain Celebi should keep the overworld green"


@pytest.mark.parametrize("shiny", [True, False])
def test_respawned_celebi_uses_the_roll(game, shiny):
	set_force_shiny(game, shiny)
	game.set_event_flag("EVENT_CELEBI_RETURNS")
	game.set_event_flag("EVENT_CELEBI_SHINY", not shiny) # a stale result from an earlier roll
	game.warp("ILEX_FOREST", *SHRINE_SPOT)
	game.press("up")
	game.press("a")
	for frame in range(MAX_FRAMES):
		if in_battle(game):
			break
		advance_text(game, frame)
		game.wait(1)
	else:
		raise AssertionError("the battle never started. The screen:\n" + game.screen_text())
	game.wait(30)

	assert game.event_flag("EVENT_CELEBI_SHINY") == shiny, "the respawn should roll again"
	assert bool(game.peek("wEnemyMonForm") & 0x80) == shiny
