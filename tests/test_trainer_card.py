"""The trainer card's Kanto page: Brock's face had grey skin.

The card colors each leader's small face with a palette. Brock's was his battle pic's palette A,
and since his pic was split into three palettes (5462644af), A holds his clothes, grey and brown.
The card now has its own palette for his face (reported 2026-10-31)."""

from harness import data
from harness.alt_shiny import call

BROCK_FACE_PAL = 2 # the card's palette for Brock's face, at (3, 10)
BROCK_FACE = (3, 10)
SKIN = (30, 18, 14)
DARK = (14, 7, 10)


def rgb(word):
	return word & 31, word >> 5 & 31, word >> 10 & 31


def test_brocks_face_has_skin_colors(game):
	layout = data.global_constants().values["SCGB_TRAINER_CARD_KANTO"]
	call(game, "LoadSGBLayoutCGB", bc=layout << 8)
	col, row = BROCK_FACE
	assert game.peek("wAttrmap", row * 20 + col) & 7 == BROCK_FACE_PAL
	colors = game.peek("wBGPals1", BROCK_FACE_PAL * 8, 8)
	middle = [rgb(colors[i] | colors[i + 1] << 8) for i in (2, 4)]
	assert middle == [SKIN, DARK], "Brock's face colors: %s" % middle
