"""The Pokédex's forms record (engine/pokedex/dex_forms.asm): every non-plain form has exactly one
flag, the forms it never shows are the ones drawn as the plain form, and the save has room."""

import re

from harness import constants
from harness import dex_forms as D
from harness.data import global_constants, read


def capacity(name):
	return int(re.search(r"DEF %s EQU (\d+)" % name, read("constants/pokemon_data_constants.asm")).group(1))


def form_counts():
	"""{species: number of forms} for every species with forms, Unown's letters included."""
	text = read("constants/pokemon_constants.asm")
	counts = {species: int(count) for species, count in
		re.findall(r"DEF NUM_(\w+)_FORMS EQU const_value\s*; (\d+)", text)}
	counts["UNOWN"] = int(re.search(r"DEF NUM_UNOWN EQU const_value ; (\d+)", text).group(1))
	return counts


def test_every_form_has_one_flag():
	covered = {}
	for species, first, count in D.form_rows():
		for form in range(first, first + count):
			assert (species, form) not in covered, "%s form %d has two flags" % (species, form)
			covered[species, form] = True
	expected = {(species, form) for species, count in form_counts().items() for form in range(1, count)}
	assert set(covered) == expected


def test_flags_fit_the_save():
	assert sum(count for _, _, count in D.form_rows()) <= capacity("DEX_FORM_FLAG_CAPACITY")
	assert len(D.alt_species()) <= capacity("DEX_ALT_SHINY_CAPACITY")


def test_the_forms_never_shown_are_the_ones_drawn_plain():
	consts = constants._consts(constants.ROOT / "constants" / "pokemon_constants.asm")
	text = read("constants/pokemon_constants.asm")
	looks_plain = set(re.findall(r"const (\w+_FORM)\s*; \d+ -- looks plain", text))
	assert looks_plain and looks_plain <= set(consts)
	block = read("engine/pokedex/dex_forms.asm").split("DexFormsLookPlain:")[1].split("dw 0 ; end")[0]
	listed = set(re.findall(r"1 << (\w+_FORM)", block))
	assert listed == looks_plain


def test_front_pics_fit_the_pics_page():
	"""The PICS page keeps its own tiles in VRAM bank 1 above the front pic's animation frames; a
	sprite with more tiles would load over them."""
	limit = global_constants().values["DEXPICS_MAX_FRONTPIC_TILES"]
	sizes = {path.parent.name: path.stat().st_size // 16
		for path in (constants.ROOT / "gfx" / "pokemon").glob("*/front.animated.2bpp")}
	assert sizes, "build the ROM first: the animated front pics are generated"
	assert {name: tiles for name, tiles in sizes.items() if tiles > limit} == {}
