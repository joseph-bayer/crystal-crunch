"""A Mystery Gift item, received from another game at the main menu, is the item you collect.

The exchange itself is infrared, which the emulator doesn't do, so the test starts where it ends:
DoMysteryGift.SentItem, run at the main menu with the item the partner's game picked. It stores
the gift in the save. Then the game is continued and the gift collected the way the Pokémon Center
deliveryman hands it over (the GetMysteryGiftItem special)."""

import re

import pytest

from harness import Game, constants, rom_path
from harness import alt_shiny as A
from test_old_saves import SAVES, continue_game

PSNCUREBERRY_SLOT = 5 # its place in MysteryGiftItems, which is what the partner's game sends

SAVE = "1.1_cherrygrove.sav"


def to_main_menu(game):
	game.wait(400)
	for _ in range(30):
		if "CONTINUE" in game.screen_text():
			return
		game.press("a", after=30)
	raise AssertionError("no main menu:\n" + game.screen_text())


def sram(game, symbol):
	bank, address = game.pyboy.symbol_lookup(symbol)
	return game.pyboy.memory[bank, address]


def set_sram(game, symbol, value):
	bank, address = game.pyboy.symbol_lookup(symbol)
	game.pyboy.memory[bank, address] = value


def item_index(name):
	"""An item's 16-bit index from the comment beside its constant. The constant reader doesn't
	follow the const_align that starts the key items and balls, so it can't count them."""
	text = (constants.ROOT / "constants" / "item_constants.asm").read_text(encoding="utf-8")
	return int(re.search(r"\bconst %s\s*; ([0-9A-Fa-f]{4})" % name, text).group(1), 16)


def item_index_of_id(game, item_id):
	return game.peek("wItemIndexTableEntries", (item_id - 1) * 2) \
		| game.peek("wItemIndexTableEntries", (item_id - 1) * 2 + 1) << 8


@pytest.fixture
def saved_game():
	game = Game(rom_path(), save=SAVES / SAVE)
	yield game
	game.close()


def collect_from_deliveryman(game):
	"""Upstairs in a Pokémon Center, talk to the deliveryman and take the gift. Returns the screen
	if the game crashed on the way."""
	game.warp("POKECENTER_2F", 1, 3)
	game.wait(120)
	assert game.object_shown("Pokecenter2F", "POKECENTER2F_OFFICER"), "no deliveryman upstairs"
	game.step("up", 1)
	game.press("a", after=60)
	for presses in range(40):
		text = game.screen_text()
		if "Game Boy Color" in text:
			return text
		if "YES" in text and "NO" in text:
			game.choose("YES")
		else:
			game.press("a", after=30)
		if "Game Boy Color" in game.screen_text():
			return game.screen_text()
		if presses > 5 and game.peek("wScriptRunning") == 0 and game.peek("wWindowStackSize") == 0:
			game.wait(120) # a crash can clear those first and draw its screen after
			return game.screen_text() if "Game Boy Color" in game.screen_text() else None
	raise AssertionError("the deliveryman's script never finished:\n" + game.screen_text())


def bag_items(game):
	"""The Items pocket as {16-bit index: quantity}."""
	count = game.peek("wNumItems")
	raw = game.peek("wItems", 0, count * 3)
	return {raw[i] << 8 | raw[i + 1]: raw[i + 2] for i in range(0, len(raw), 3)}


def test_gift_from_the_main_menu_is_the_item_collected(saved_game):
	game = saved_game
	to_main_menu(game)
	main_menu = game.save_state()

	game.poke("wMysteryGiftPartnerWhichItem", PSNCUREBERRY_SLOT)
	# It ends on a text box the stub can't close, so run it for a while and read what it stored.
	A.call(game, "DoMysteryGift.SentItem", press_a_every=20, must_return=False, frames=600)
	stored = sram(game, "sBackupMysteryGiftItem")
	assert stored, "no gift was stored"

	# Back to the menu as it was, with only the stored gift carried over: everything else the call
	# touched belongs to a game the player doesn't go on with.
	game.load_state(main_menu)
	set_sram(game, "sBackupMysteryGiftItem", stored)
	continue_game(game)
	assert sram(game, "sMysteryGiftItem") == stored, "continuing should hand the gift over"
	before = bag_items(game).get(item_index("PSNCUREBERRY"), 0)

	crash = collect_from_deliveryman(game)
	assert crash is None, "collecting the gift crashed:\n" + crash
	assert sram(game, "sMysteryGiftItem") == 0
	assert bag_items(game).get(item_index("PSNCUREBERRY"), 0) == before + 1


# A gift already waiting in a save from before the fix holds an 8-bit item id. It is read as a
# list position plus one like any other: 1-37 give that place's item, anything past the list gives
# the fallback, a Great Ball. Nothing crashes and the gift is not lost.
OLD_PENDING = [(1, "BERRY"), (6, "PSNCUREBERRY"), (37, "MIRAGE_MAIL"), (38, "GREAT_BALL"),
	(100, "GREAT_BALL")]


@pytest.mark.parametrize("saved, item", OLD_PENDING)
def test_gift_waiting_in_an_old_save(saved_game, saved, item):
	game = saved_game
	continue_game(game)
	set_sram(game, "sMysteryGiftItem", saved)
	crash = collect_from_deliveryman(game)
	assert crash is None, "collecting the gift crashed:\n" + crash
	assert sram(game, "sMysteryGiftItem") == 0
	assert game.event_flag("EVENT_MYSTERY_GIFT_DELIVERY_GUY"), "the gift wasn't handed over"
	assert item_index_of_id(game, game.peek("wCurItem")) == item_index(item)


def test_fallback_for_a_place_past_the_list(saved_game):
	"""A partner's pick past the end of the list (a corrupt exchange, or another device) still
	saves a gift, which collects as the fallback."""
	game = saved_game
	to_main_menu(game)
	game.poke("wMysteryGiftPartnerWhichItem", 0xff)
	A.call(game, "DoMysteryGift.SentItem", press_a_every=20, must_return=False, frames=600)
	assert sram(game, "sBackupMysteryGiftItem") == 38


def mystery_gift_items(game):
	"""MysteryGiftItems, read from the ROM: the 16-bit index at each position."""
	bank, start = game.pyboy.symbol_lookup("MysteryGiftItems")
	_, end = game.pyboy.symbol_lookup("MysteryGiftItems.End")
	rom = game.rom.read_bytes()
	offset = bank * 0x4000 + start - 0x4000
	return [rom[offset + i] | rom[offset + i + 1] << 8 for i in range(0, end - start, 2)]


def test_gift_from_an_npc_is_saved_as_its_place(saved_game):
	"""The in-game NPC gift is saved the same way, as its place in the list plus one, and names the
	item at that place."""
	game = saved_game
	continue_game(game)
	A.call(game, "DoNPCMysteryGift.SentItem", press_a_every=20, must_return=False, frames=600)
	saved = sram(game, "sMysteryGiftItem")
	items = mystery_gift_items(game)
	assert 1 <= saved <= len(items)
	assert sram(game, "sBackupMysteryGiftItem") == saved
	assert item_index_of_id(game, game.peek("wNamedObjectIndex")) == items[saved - 1]


# The reported case: Carrie's gift in Goldenrod Dept. Store 5F, then a save, then the deliveryman.
# Her gift used to be saved as an 8-bit item ID, which the item ID collector didn't count as in
# use: once a few newer IDs had been claimed, the collection every save runs freed it, and the
# deliveryman handed over an emptied or reused slot.

CARRIE_SPOT = ("GOLDENROD_DEPT_STORE_5F", 9, 2) # below Carrie
# Items whose IDs the game claims as the player shops, uses the bag and so on: enough of them, all
# new to the table, to push the gift's ID out of the few most recent claims a collection spares.
CHURN = ["POTION", "SUPER_POTION", "HYPER_POTION", "ANTIDOTE", "BURN_HEAL", "ICE_HEAL",
	"AWAKENING", "PARLYZ_HEAL", "FULL_HEAL", "ESCAPE_ROPE", "REPEL", "SUPER_REPEL", "MAX_REPEL",
	"FRESH_WATER", "SODA_POP", "LEMONADE"]
MAX_SEEDS = 200


def idle(game):
	return (game.peek("wScriptRunning") == 0 and game.peek("wWindowStackSize") == 0
		and game.peek("wMapStatus") == 2)


def press_until_idle(game, presses=60):
	for _ in range(presses):
		if idle(game):
			return
		game.press("a", after=20)
	raise AssertionError("the script never finished:\n" + game.screen_text())


def open_carries_gift_screen(game):
	game.warp(*CARRIE_SPOT)
	game.press("up", after=20)
	game.press("a", after=20)
	for _ in range(40):
		if "MYSTERY GIFT" in game.screen_text() and "Press A to" in game.screen_text():
			game.wait(30)
			return
		game.press("a", after=20)
	raise AssertionError("Carrie's gift screen never opened:\n" + game.screen_text())


def carrie_gives(game, item):
	"""Take Carrie's gift, steering the test ROM's random sequence to the item branch and `item`."""
	screen = game.save_state()
	for seed in range(1, MAX_SEEDS):
		game.load_state(screen)
		game.seed_random(seed)
		game.press("a", after=10)
		for _ in range(60):
			if "sent" in game.screen_text() or "SENT" in game.screen_text():
				break
			game.wait(10)
		if sram(game, "sMysteryGiftItem") and \
				item_index_of_id(game, game.peek("wNamedObjectIndex")) == item_index(item):
			press_until_idle(game)
			return
	raise AssertionError("no seed below %d gives %s" % (MAX_SEEDS, item))


def claim_item_ids(game, names):
	"""Claim an ID for each item, as the game does when it meets them. Done by calling the game's
	own GetItemIDFromIndex, then carrying the resulting table back into the paused game."""
	paused = game.save_state()
	for name in names:
		A.call(game, "GetItemIDFromIndex", hl=item_index(name))
	bank, start = game.pyboy.symbol_lookup("wItemIndexTable")
	_, end = game.pyboy.symbol_lookup("wItemIndexTableEnd")
	table = [game.pyboy.memory[bank, address] for address in range(start, end)]
	game.load_state(paused)
	for offset, value in enumerate(table):
		game.pyboy.memory[bank, start + offset] = value


def test_carries_gift_survives_a_save(saved_game):
	from test_registered_item import save_game

	game = saved_game
	continue_game(game)
	before = bag_items(game).get(item_index("PSNCUREBERRY"), 0)
	open_carries_gift_screen(game)
	carrie_gives(game, "PSNCUREBERRY")

	claim_item_ids(game, CHURN)
	save_game(game) # runs the ID collector

	crash = collect_from_deliveryman(game)
	assert crash is None, "collecting the gift crashed:\n" + crash
	assert sram(game, "sMysteryGiftItem") == 0
	assert bag_items(game).get(item_index("PSNCUREBERRY"), 0) == before + 1


# Reported with Kim in Blackthorn City: after her gift, some of the map's blocks were wrong until
# the map was loaded again. The gift code keeps the partner's ID and name and the sent gift in the
# link version's buffers, which share their RAM with wOverworldMapBlocks; the link version only
# runs from the main menu, but the NPCs run it with a map loaded. The first fix rebuilt the blocks
# but left the ROM bank on a connected map's blocks, so talking to Kim crashed: Blackthorn City
# has connections, Goldenrod Dept. Store 5F doesn't. Both are tested.

KIM = 7 # Kim's map object in Blackthorn City
KIM_ROW = 25 # she walks left and right along it
OBJECT_MOVEMENT_TYPE = 0x03
SPRITEMOVEDATA_STANDING_DOWN = 0x06
MAP_BORDER = 4


def map_blocks(game):
	_, start = game._address("wOverworldMapBlocks")
	_, end = game._address("wOverworldMapBlocksEnd")
	return game.peek("wOverworldMapBlocks", 0, end - start)


def changed_blocks(before, after):
	return [i for i, (b, a) in enumerate(zip(before, after)) if b != a]


def talk_to_kim(game):
	"""Stop Kim where she is, walk under her and talk."""
	from harness import followers as F
	struct = next(s for s in range(F.NUM_OBJECT_STRUCTS) if F.object_field(game, s, 0)
		and F.object_field(game, s, 1) == KIM)
	game.poke("wObjectStructs", SPRITEMOVEDATA_STANDING_DOWN, struct * F.OBJECT_LENGTH + OBJECT_MOVEMENT_TYPE)
	game.wait(40) # let a step she is in finish
	kim_x = F.object_field(game, struct, F.OBJECT_MAP_X) - MAP_BORDER
	assert F.object_field(game, struct, F.OBJECT_MAP_Y) - MAP_BORDER == KIM_ROW
	x, _ = game.position()
	if kim_x != x:
		game.step("right" if kim_x > x else "left", abs(kim_x - x))
		game.wait(20)
	game.press("up", after=30) # turn to face her
	assert game.position()[0] == kim_x, "couldn't get under Kim"
	game.press("a", after=20)
	game.wait_for_text("│") # her text box


def open_kims_gift_screen(game):
	game.warp("BLACKTHORN_CITY", 9, KIM_ROW + 1)
	talk_to_kim(game)
	for _ in range(40):
		if "MYSTERY GIFT" in game.screen_text() and "Press A to" in game.screen_text():
			game.wait(30)
			return
		game.press("a", after=20)
	raise AssertionError("Kim's gift screen never opened:\n" + game.screen_text())


def talk_again(game, npc):
	if npc == "kim":
		talk_to_kim(game)
	else:
		game.press("a", after=20)


@pytest.mark.parametrize("npc", ["carrie", "kim"])
def test_npc_gift_leaves_the_map_blocks_alone(saved_game, npc):
	game = saved_game
	continue_game(game)
	spot = CARRIE_SPOT if npc == "carrie" else ("BLACKTHORN_CITY", 9, KIM_ROW + 1)
	game.warp(*spot)
	before = map_blocks(game)

	(open_carries_gift_screen if npc == "carrie" else open_kims_gift_screen)(game)
	carrie_gives(game, "PSNCUREBERRY") # any NPC's screen: it only takes the gift
	assert game.current_map() == constants.maps()[spot[0]], "the gift didn't come back to the map"
	changed = changed_blocks(before, map_blocks(game))
	assert not changed, "the gift changed the map's blocks at offsets %s" % changed

	# Talking again the same day only checks today's list, which writes the NPC's ID.
	talk_again(game, npc)
	game.wait_for_text("already")
	press_until_idle(game)
	changed = changed_blocks(before, map_blocks(game))
	assert not changed, "checking for today's gift changed the map's blocks at offsets %s" % changed
