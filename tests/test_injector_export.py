"""The starter injector's data export (utils/export_injector_data.py and utils/injector_species.py):
what it copies of the game's own species for the page's previews."""

import sys

from harness import constants

sys.path.insert(0, str(constants.ROOT / "utils"))
from export_injector_data import FORM_MOVES, UNOFFERED_FORM_SPECIES  # noqa: E402
from injector_species import form_palettes, icon_names  # noqa: E402


def test_every_species_icon_is_its_own():
	"""Pikachu's and Unown's rows of the icon table are 0 (their icons are in their forms' table), and
	Piloswine's label has no Icon suffix; a row skipped there once gave every later species the next
	one's icon."""
	names = icon_names()
	index = constants._consts(constants.ROOT / "constants" / "pokemon_constants.asm")
	assert names[index["ARBOK"]] == "arbok"
	assert names[index["PIKACHU"]] == "pikachu"
	assert names[index["RAICHU"]] == "raichu"
	assert names[index["MR__MIME"]] == "mr_mime"
	assert names[index["UNOWN"]] == "unown_a"
	assert names[index["WOBBUFFET"]] == "wobbuffet"
	assert names[index["PILOSWINE"]] == "piloswine" # labelled Piloswine::, without Icon
	assert names[index["CORSOLA"]] == "corsola"
	assert names[index["CELEBI"]] == "celebi"
	for i in range(1, index["CELEBI"] + 1):
		assert (constants.ROOT / "gfx" / "icons" / (names[i] + ".png")).exists(), i


def test_form_palettes_are_the_games_own():
	"""Surf and Fly Pikachu are drawn in grays and take Pikachu's colors from the forms' palette table,
	not from a palette in their own folders."""
	pikachu = form_palettes()["PIKACHU"]
	index = constants._consts(constants.ROOT / "constants" / "pokemon_constants.asm")
	plain = pikachu[index["PIKACHU_PLAIN_FORM"]]
	assert pikachu[index["PIKACHU_SURF_FORM"]] == plain
	assert pikachu[index["PIKACHU_FLY_FORM"]] == plain
	assert plain[0] != [[21, 21, 21], [10, 10, 10]]


def test_the_move_forms_are_the_ones_the_game_gives_for_a_move():
	learn = (constants.ROOT / "engine/pokemon/learn.asm").read_text(encoding="utf-8")
	for form, move in FORM_MOVES.items():
		assert form in learn and ("ld hl, %s" % move) in learn, (form, move)


def test_unoffered_species_exist():
	index = constants._consts(constants.ROOT / "constants" / "pokemon_constants.asm")
	for species in UNOFFERED_FORM_SPECIES:
		assert species in index, species
