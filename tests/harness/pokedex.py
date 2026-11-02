"""Opening the Pokédex and its entry pages, for the Pokédex tests."""

from . import constants
from .forms import wait_until

DEXMODE_ABC = 2 # constants/ram_constants.asm


def species_index(name):
	"""A species' 16-bit index by its const name, e.g. BULBASAUR."""
	return constants._consts(constants.ROOT / "constants" / "pokemon_constants.asm")[name]


def set_dex_bit(game, symbol, index, value=True):
	byte, bit = divmod(index - 1, 8)
	old = game.peek(symbol, byte)
	game.poke(symbol, old | 1 << bit if value else old & ~(1 << bit), byte)


def mark(game, name, caught=True):
	"""Mark a species seen, and caught unless told otherwise."""
	index = species_index(name)
	set_dex_bit(game, "wPokedexSeen", index)
	set_dex_bit(game, "wPokedexCaught", index, caught)


# DEXSTATE_* in engine/pokedex/pokedex.asm
DEXSTATE_UPDATE_MAIN_SCR = 1
DEXSTATE_UPDATE_DEX_ENTRY_SCR = 3


def in_entry(game):
	return game.peek("wJumptableIndex") == DEXSTATE_UPDATE_DEX_ENTRY_SCR


def open_pokedex(game):
	"""Open the Pokédex list from the START menu, in A-to-Z mode, which lists only seen species."""
	game.poke("wStatusFlags", game.peek("wStatusFlags") | 1) # STATUSFLAGS_POKEDEX_F
	if not game.peek("wPartyCount"):
		game.poke("wPartyCount", 1) # the START menu opens the Pokédex only with a party
	game.poke("wLastDexMode", DEXMODE_ABC)
	game.press("start", after=40)
	game.choose("POKéDEX")
	wait_until(game, lambda: "PACK" not in game.screen_text()
		and game.peek("wJumptableIndex") == DEXSTATE_UPDATE_MAIN_SCR, "the Pokédex list", timeout=600)
	game.wait(30)


def open_pokedex_entry(game, name, caught=True, others=()):
	"""Open the entry screen of species `name`, marked seen (and caught), with `others` marked seen
	and caught too. The A-to-Z list holds only seen species, so the cursor moves down past the ones
	before it alphabetically (the species here are named as their constants)."""
	for other in others:
		mark(game, other)
	mark(game, name, caught)
	open_pokedex(game)
	for _ in range(sorted(set(others) | {name}).index(name)):
		game.press("down", hold=6, after=30)
	game.press("a", after=120)
	wait_until(game, lambda: in_entry(game), "the entry screen", timeout=300)
	game.wait(60)


# The entry screen's tabs, left to right
TABS = ["INFO", "STAT", "MOVES", "AREA", "EVO", "PICS"]


def open_tab(game, tab):
	"""From the INFO tab, move the cursor to `tab` and press A."""
	for _ in range(TABS.index(tab)):
		game.press("right", after=20)
	next_page(game)


def next_page(game, frames=250):
	"""Press A: the tab's next page."""
	game.press("a", after=frames)


def page_text(game):
	"""The page's text, below the header."""
	return "\n".join(game.screen_lines()[5:17])
