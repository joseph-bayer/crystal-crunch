"""Helpers for the alternate shiny tests: calling the ROM's own routines directly, 8-bit ids for
species and items by their 16-bit index, palettes from the .pal files, and the test ROM's random
sequence worked out in Python.

Calling a routine: a three-instruction stub (switch to the routine's bank, call it, then loop on the
spot) is written into WRAM bank 1's free space past its last variable, where nothing draws over it,
and the CPU is pointed at it. The game's main loop is abandoned, so a test that does this restores a
saved state before it plays on."""

import re

from . import constants

SHINY_MASK = 0x80
ALT_SHINY_MASK = 0x40

SWARM_GRASS = 0
SWARM_ALT_SHINY = 0x40

ALT_SHINY_DENOMINATOR = 5
ALT_SHINY_RANGE = 256 - 256 % ALT_SHINY_DENOMINATOR

# The shiny icon and the alternate shiny icon
SHINY_ICON = 0xc0
ALT_SHINY_ICON = 0xc1

# Past wOverworldMonShinyPending, the last variable in WRAM bank 1
STUB_BANK = 1
STUB_ADDRESS = 0xdf80
RSVBK = 0xff70
SCRATCH_SYMBOL = "wTilemap"
MAX_CALL_FRAMES = 2000


def pokemon_index(name):
	"""A species' 16-bit index by its constant, e.g. SCYTHER."""
	return constants._consts(constants.ROOT / "constants" / "pokemon_constants.asm")[name]


def item_index(name):
	return constants._consts(constants.ROOT / "constants" / "item_constants.asm")[name]


def _table_id(game, table, index):
	"""The 8-bit id the game uses for a 16-bit index, claiming a free slot the way the game does
	when the index has none yet."""
	entries = table + "Entries"
	used = table + "UsedSlots"
	_, start = game._address(entries)
	_, end = game._address(table + "EntriesEnd")
	count = (end - start) // 2
	free = None
	for slot in range(count):
		value = game.peek(entries, slot * 2) | game.peek(entries, slot * 2 + 1) << 8
		if value == index:
			return slot + 1
		if value == 0 and free is None:
			free = slot
	assert free is not None, "no free slot in %s" % table
	game.poke(entries, index & 0xff, free * 2)
	game.poke(entries, index >> 8, free * 2 + 1)
	game.poke(used, game.peek(used) + 1)
	return free + 1


def species_id(game, name):
	return _table_id(game, "wPokemonIndexTable", pokemon_index(name))


def item_id(game, name):
	return _table_id(game, "wItemIndexTable", item_index(name))


def pal_colors(path):
	"""The colors of an RGB-line .pal file, as the 15-bit values the game stores."""
	text = (constants.ROOT / path).read_text()
	return [int(r) | int(g) << 5 | int(b) << 10 for r, g, b in re.findall(r"RGB (\d+), (\d+), (\d+)", text)]


def call(game, routine, a=0, bc=0, de=0, hl=0, press_a_every=0, must_return=True,
		frames=MAX_CALL_FRAMES):
	"""Call a routine by its symbol with these registers, and return the registers it returned.
	A routine that ends somewhere else (one that reloads the map, say) is run for `frames` frames
	with must_return=False instead, and its results are read from memory."""
	bank, address = game.pyboy.symbol_lookup(routine)
	_, bankswitch = game.pyboy.symbol_lookup("Bankswitch")
	stub = STUB_ADDRESS
	code = [
		0x3e, bank,                                    # ld a, bank
		0xcd, bankswitch & 0xff, bankswitch >> 8,      # call Bankswitch
		0x3e, a,                                       # ld a, a's value
		0xcd, address & 0xff, address >> 8,            # call routine
		0x18, 0xfe,                                    # jr @
	]
	for i, byte in enumerate(code):
		game.pyboy.memory[STUB_BANK, stub + i] = byte
	loop = stub + len(code) - 2
	game.pyboy.memory[RSVBK] = STUB_BANK # so the CPU sees the stub where it was written
	registers = game.pyboy.register_file
	registers.B, registers.C = bc >> 8, bc & 0xff
	registers.D, registers.E = de >> 8, de & 0xff
	registers.HL = hl
	registers.PC = stub
	for frame in range(frames):
		game.pyboy.tick(1, False)
		if registers.PC in (loop, loop + 1):
			break
		if press_a_every and frame % press_a_every == 0:
			game.pyboy.button("a", 2)
	else:
		if must_return:
			raise AssertionError("%s never returned" % routine)
	return {
		"a": registers.A, "f": registers.F,
		"bc": registers.B << 8 | registers.C,
		"de": registers.D << 8 | registers.E,
		"hl": registers.HL,
	}


def scratch_address(game, offset):
	"""A byte of WRAM0 (in wTilemap) for a routine to read, free while the main loop is set aside."""
	_, tilemap = game._address(SCRATCH_SYMBOL)
	return tilemap + 0x40 + offset


class TestRandom:
	"""The test ROM's Random: a 16-bit xorshift over hRandomAdd (low) and hRandomSub (high)."""

	def __init__(self, seed):
		self.x = seed or 0x5eed

	def next(self):
		x = self.x
		x ^= (x << 7) & 0xffff
		x ^= x >> 9
		x ^= (x << 8) & 0xffff
		self.x = x
		return x >> 8


def expected_alt(seed, threshold):
	"""Whether RollAltShiny (or its swarm twin) makes a shiny an alternate from this seed."""
	rng = TestRandom(seed)
	while True:
		value = rng.next()
		if value < ALT_SHINY_RANGE:
			return value < threshold


def threshold(numerator):
	return numerator * ALT_SHINY_RANGE // ALT_SHINY_DENOMINATOR
