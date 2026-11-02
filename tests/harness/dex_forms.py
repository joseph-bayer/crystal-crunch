"""The Pokédex's record of forms and alternate shinies (engine/pokedex/dex_forms.asm): each flag's
number worked out from the ROM's sources, reading and setting the flags, and saving the game to a
.sav file that a new Game can continue."""

import re

from . import constants
from .data import read

SHINY_MASK = 0x80
ALT_SHINY_MASK = 0x40

SRAM_BANKS = 4
SRAM_BANK_SIZE = 0x2000
SRAM_START = 0xa000

# The tiles the dex uses for the shiny glyphs and the caught ball
DEX_SHINY_GLYPH = 0x64 # "<DEX_⁂>"
ALT_SHINY_GLYPH = 0xc1 # "<ALT_SHINY>"
CAUGHT_BALL = 0x4f

# Where the PICS page puts its marks and its form label: (x, y)
PICS_SHINY_GLYPH = (3, 11)
PICS_CAUGHT_BALL = (5, 11)
PICS_FORM_LABEL_ROW = 14
SCREEN_WIDTH = 20


def _consts():
	return constants._consts(constants.ROOT / "constants" / "pokemon_constants.asm")


def form_rows():
	"""DexFormFlagRows as [(species, first form, count)], in order."""
	text = read("engine/pokedex/dex_forms.asm")
	return [(species, int(first), int(count)) for species, first, count in
		re.findall(r"^\tdex_form_flags (\w+),\s*(\d+),\s*(\d+)", text, re.M)]


def form_flag(species, form):
	"""The flag number of a non-plain form, e.g. ("SCYTHER", 2)."""
	flag = 0
	for name, first, count in form_rows():
		if name == species and first <= form < first + count:
			return flag + form - first
		flag += count
	raise KeyError((species, form))


def alt_species():
	"""The species in AltShinyPalettes, in row order."""
	return re.findall(r"^\tdw (\w+)", read("data/pokemon/alt_shiny_palettes.asm"), re.M)[:-1]


def alt_flag(species):
	return alt_species().index(species)


def flag(game, symbol, number):
	byte, bit = divmod(number, 8)
	return bool(game.peek(symbol, byte) >> bit & 1)


def set_flag(game, symbol, number, value=True):
	byte, bit = divmod(number, 8)
	old = game.peek(symbol, byte)
	game.poke(symbol, old | 1 << bit if value else old & ~(1 << bit), byte)


def form_seen(game, species, form):
	return flag(game, "wDexFormsSeen", form_flag(species, form))


def form_caught(game, species, form):
	return flag(game, "wDexFormsCaught", form_flag(species, form))


def alt_seen(game, species):
	return flag(game, "wDexAltShiniesSeen", alt_flag(species))


def alt_caught(game, species):
	return flag(game, "wDexAltShiniesCaught", alt_flag(species))


def see_form(game, species, form, caught=False):
	set_flag(game, "wDexFormsSeen", form_flag(species, form))
	if caught:
		set_flag(game, "wDexFormsCaught", form_flag(species, form))


def see_alt(game, species, caught=False):
	set_flag(game, "wDexAltShiniesSeen", alt_flag(species))
	if caught:
		set_flag(game, "wDexAltShiniesCaught", alt_flag(species))


def record_length(game):
	return game._address("wDexFormsEnd")[1] - game._address("wDexForms")[1]


def record(game):
	"""The whole record, as bytes."""
	return game.peek("wDexForms", 0, record_length(game))


def clear_record(game, value=0):
	for i in range(record_length(game)):
		game.poke("wDexForms", value, i)


def set_flags(game):
	"""Every set flag, as (array, number)."""
	found = []
	for symbol, end in [("wDexFormsSeen", "wDexFormsCaught"), ("wDexFormsCaught", "wDexAltShiniesSeen"),
			("wDexAltShiniesSeen", "wDexAltShiniesCaught"), ("wDexAltShiniesCaught", "wDexFormsEnd")]:
		length = game._address(end)[1] - game._address(symbol)[1]
		for i, value in enumerate(game.peek(symbol, 0, length)):
			found += [(symbol, i * 8 + bit) for bit in range(8) if value >> bit & 1]
	return found


def form_constant(name):
	return _consts()[name]


def save_game(game):
	"""SAVE from the START menu, answering YES until the game says it saved."""
	game.press("start", after=40)
	game.choose("SAVE")
	for _ in range(60):
		text = game.screen_text()
		if "saved" in text:
			break
		if "YES" in text:
			game.choose("YES")
		else:
			game.press("a", after=30)
	else:
		raise AssertionError("the game never saved:\n" + game.screen_text())
	game.press("a", after=60)


def sram(game):
	"""The cartridge's battery-backed RAM, as a .sav file's bytes."""
	return bytes(game.pyboy.memory[bank, SRAM_START + i]
		for bank in range(SRAM_BANKS) for i in range(SRAM_BANK_SIZE))


def tile_at(game, x, y):
	return game.peek("wTilemap", y * SCREEN_WIDTH + x)
