"""Held items after the Hall of Fame.

Saving wrote the item conversion table with the Pokémon table's SRAM bank still open, so instead
of its own place in bank 0 it landed inside the Hall of Fame records in bank 1. Loading made the
same mistake, so it round-tripped, until a Hall of Fame entry shifted the records down to make
room and shifted the table with them. After the credits' reset every held item read as index 0:
names that took seconds to find and read as garbage ("SMOG"), and a crash on taking one off.

Saves from before the fix never wrote the table's own place, so loading falls back on the backup
copy, which every save writes alongside it."""

import pytest

from harness import Game, constants, rom_path
from harness import alt_shiny as A
from harness.forms import take_radio_items
from test_mystery_gift import item_index, item_index_of_id
from test_old_saves import continue_game

HELD = ["LEFTOVERS", "KINGS_ROCK", "MIRACLEBERRY", "QUICK_CLAW", "BRIGHTPOWDER", "SCOPE_LENS"]
SAVES = constants.ROOT / "tests" / "fixtures" / "saves"
SRAM_BANK_SIZE = 0x2000
SRAM_START = 0xa000


def symbol_size(game, start, end):
	return game.pyboy.symbol_lookup(end)[1] - game.pyboy.symbol_lookup(start)[1]


def sram_bytes(game, start, end):
	bank, address = game.pyboy.symbol_lookup(start)
	return [game.pyboy.memory[bank, address + i] for i in range(symbol_size(game, start, end))]


def fill_sram(game, start, end, value):
	bank, address = game.pyboy.symbol_lookup(start)
	for i in range(symbol_size(game, start, end)):
		game.pyboy.memory[bank, address + i] = value


def hold_items(game):
	"""The debug radio's party, each holding an item; return what each should hold."""
	take_radio_items(game)
	count = game.peek("wPartyCount")
	held = HELD[:count]
	for slot, name in enumerate(held):
		game.poke("wPartyMon%dItem" % (slot + 1), A.item_id(game, name))
	return held


def reload_item_table(game):
	"""Forget the item table in WRAM, then read it back from the save."""
	size = symbol_size(game, "wItemIndexTable", "wItemIndexTableEnd")
	for i in range(size):
		game.poke("wItemIndexTable", 0, offset=i)
	A.call(game, "LoadIndexTables")


def assert_still_held(game, held):
	for slot, name in enumerate(held):
		item_id = game.peek("wPartyMon%dItem" % (slot + 1))
		assert item_index_of_id(game, item_id) == item_index(name), \
			"party slot %d should still hold %s" % (slot + 1, name)


def test_a_hall_of_fame_entry_keeps_the_held_items(game):
	held = hold_items(game)
	A.call(game, "SaveGameData")
	A.call(game, "GetHallOfFameParty")
	A.call(game, "AddHallOfFameEntry")
	reload_item_table(game)
	assert_still_held(game, held)


def test_saving_leaves_the_hall_of_fame_alone(game):
	hold_items(game)
	fill_sram(game, "sHallOfFame", "sHallOfFameEnd", 0x5a)
	A.call(game, "SaveGameData")
	assert set(sram_bytes(game, "sHallOfFame", "sHallOfFameEnd")) == {0x5a}


def test_a_save_from_before_the_fix_loads_its_items(game):
	"""Such a save has its table in the Hall of Fame and the backup, and never wrote its own
	place, which holds whatever the SRAM started as: $ff here."""
	held = hold_items(game)
	A.call(game, "SaveGameData")
	fill_sram(game, "sItemIndexTable", "sBackupItemIndexTable", 0xff)
	reload_item_table(game)
	assert_still_held(game, held)


@pytest.mark.parametrize("save", ["v1.0_cherrygrove.sav", "1.1_cherrygrove.sav"])
def test_old_saves_load_the_same_item_table(save):
	"""The released saves' table, where they wrote it (inside the Hall of Fame), is what loads."""
	path = SAVES / save
	data = path.read_bytes()
	game = Game(rom_path(), save=path)
	try:
		assert game.pyboy.symbol_lookup("sHallOfFame")[0] == 1
		size = symbol_size(game, "wItemIndexTable", "wItemIndexTableEnd")
		old_place = SRAM_BANK_SIZE + game.pyboy.symbol_lookup("sItemIndexTable")[1] - SRAM_START
		saved = list(data[old_place:old_place + size])
		assert any(saved), "the save should have items in its table"
		continue_game(game)
		assert game.peek("wItemIndexTable", count=size) == saved
	finally:
		game.close()
