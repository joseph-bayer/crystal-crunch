"""A key item registered to SELECT survives saving and reloading.

The registered item is kept as an 8-bit item id. Every save garbage-collects the id table, and the
collector didn't count the registered item as a use, so the save freed its id: after reloading,
SELECT used whatever that id had become -- nothing at all for an emptied slot, which read as item 0
and matched the Bicycle's low byte, so Oak said it wasn't the time to use it."""

import tempfile
from pathlib import Path

from harness import Game, constants, rom_path
from harness import alt_shiny as A
from test_old_saves import continue_game

PLAYER_NORMAL = 0
PLAYER_BIKE = 1
KEY_ITEM_POCKET = 2
REGISTERED_KEY_ITEM_1 = KEY_ITEM_POCKET << 6 | 1 # the pocket in the top bits, then position + 1

SRAM_START = 0xa000
SRAM_BANK_SIZE = 0x2000
SRAM_BANKS = 4

ROUTE_SPOT = ("ROUTE_30", 4, 33)


def key_item_index(name):
	"""A key item's 16-bit index. Key items start at 0100 (a const_align the constant reader
	doesn't follow), so count from the Bicycle."""
	return 0x100 + A.item_index(name) - A.item_index("BICYCLE")


def give_key_item(game, name):
	"""The key item's flag, and the pocket's list as RefreshKeyItemsList would rebuild it (low
	bytes of the indexes, ended by -1) for a bag holding just this one."""
	bit = key_item_index(name) & 0xff
	byte = game.peek("wKeyItemFlags", bit // 8)
	game.poke("wKeyItemFlags", byte | 1 << bit % 8, bit // 8)
	game.poke("wNumKeyItems", 1)
	game.poke("wKeyItems", bit)
	game.poke("wKeyItems", 0xff, 1)


def register(game, name):
	"""What RegisterItem leaves behind for the first key item. The id comes from the table the way
	the game claims one, but not among the last few claimed, which a collection always spares: the
	Bicycle is usually got long before the save that loses it."""
	game.poke("wWhichRegisteredItem", REGISTERED_KEY_ITEM_1)
	game.poke("wRegisteredItem", A._table_id(game, "wItemIndexTable", key_item_index(name)))


def idle(game):
	return (game.peek("wScriptRunning") == 0 and game.peek("wWindowStackSize") == 0
		and game.peek("wMapStatus") == 2)


def save_game(game):
	"""SAVE from the START menu, as a player would."""
	game.press("start", after=40)
	game.choose("SAVE")
	game.wait_for_text("save the game?")
	game.choose("YES")
	game.wait_for_text("saved")
	for _ in range(60):
		game.wait(20)
		if idle(game):
			return
	raise AssertionError("never got back to the map. The screen:\n" + game.screen_text())


def battery_ram(game):
	return bytes(game.pyboy.memory[bank, SRAM_START + i]
		for bank in range(SRAM_BANKS) for i in range(SRAM_BANK_SIZE))


def test_registered_bicycle_after_save_and_reload(game):
	game.warp(*ROUTE_SPOT)
	give_key_item(game, "BICYCLE")
	register(game, "BICYCLE")
	save_game(game)

	with tempfile.TemporaryDirectory() as folder:
		path = Path(folder) / "save.sav"
		path.write_bytes(battery_ram(game))
		reloaded = Game(rom_path(), save=path)
	try:
		continue_game(reloaded)
		assert reloaded.in_map("ROUTE_30")
		assert reloaded.peek("wPlayerState") == PLAYER_NORMAL
		reloaded.press("select", after=120)
		assert reloaded.peek("wPlayerState") == PLAYER_BIKE, \
			"SELECT didn't get on the Bicycle. The screen:\n" + reloaded.screen_text()
	finally:
		reloaded.close()


def test_stale_id_of_a_non_key_item_is_not_used(game):
	"""A save that already lost the id: when it now names an item outside the key items whose
	low byte matches a key item in the bag (Brightpowder, 0001, and the Coin Case, 0101), SELECT
	forgets the registration instead of using that item."""
	assert A.item_index("BRIGHTPOWDER") == 1
	give_key_item(game, "COIN_CASE")
	game.poke("wWhichRegisteredItem", REGISTERED_KEY_ITEM_1)
	game.poke("wRegisteredItem", A.item_id(game, "BRIGHTPOWDER"))
	A.call(game, "CheckRegisteredItem")
	assert game.peek("wRegisteredItem") == 0
	assert game.peek("wWhichRegisteredItem") == 0


def empty_item_slot(game):
	_, start = game.pyboy.symbol_lookup("wItemIndexTableEntries")
	_, end = game.pyboy.symbol_lookup("wItemIndexTableEntriesEnd")
	entries = game.peek("wItemIndexTableEntries", 0, end - start)
	return next(n for n in range(len(entries) // 2) if entries[2 * n] == entries[2 * n + 1] == 0) + 1


def test_save_that_lost_the_bicycle(game):
	"""A save from before the fix, as players have them: the Bicycle registered, its id freed by a
	save. SELECT forgets the registration and says to register an item (Oak's "not the time" was
	the old symptom); registering the Bicycle again then works."""
	game.warp(*ROUTE_SPOT)
	give_key_item(game, "BICYCLE")
	game.poke("wWhichRegisteredItem", REGISTERED_KEY_ITEM_1)
	game.poke("wRegisteredItem", empty_item_slot(game))

	game.press("select", after=20)
	game.wait_for_text("PACK may be") # "An item in your PACK may be registered for use on SELECT."
	assert "time" not in game.screen_text(), "Oak's message, as before the fix:\n" + game.screen_text()
	assert game.peek("wPlayerState") == PLAYER_NORMAL
	assert game.peek("wRegisteredItem") == 0
	assert game.peek("wWhichRegisteredItem") == 0
	for _ in range(10):
		game.press("a", after=30)
		if idle(game):
			break

	register(game, "BICYCLE")
	game.press("select", after=120)
	assert game.peek("wPlayerState") == PLAYER_BIKE, \
		"SELECT didn't get on the Bicycle. The screen:\n" + game.screen_text()
