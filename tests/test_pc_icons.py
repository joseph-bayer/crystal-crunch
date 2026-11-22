"""Bill's PC keeps showing the right icons while a held mon is carried through the boxes.

The bug this guards against: the PC keeps the 8-bit species IDs of the icons on screen and of the
held mon, and redraws from them, but the species ID table's garbage collector didn't count them as
in use. Paging through a full PC freed those IDs and handed them to other species, so the held mon
was dropped as another species' icon (its palette, copied as bytes, stayed right), and a box's
icons could point at freed IDs while it was being drawn."""

import re

import pytest

from harness import alt_shiny as A
from harness import constants
from harness.forms import set_party_field, take_radio_items, wait_until

# Bill's PC in the Cherrygrove Pokemon Center, used from (9, 2) facing up.
PC_SPOT = (9, 2)

# The radio's PC fill stores the dex in order, with species that have an alternate shiny moved to
# the end, so those turn up again in the last boxes.
ALT_SHINY_PALETTES = "data/pokemon/alt_shiny_palettes.asm"

# Far enough that the boxes in between hold more species than the ID table has free slots.
LAST_BOX = 16 # 0-based: box 17

SWAP_MODE = 1
# wBillsPC_CursorPos is $yx: row 0 is the box name, rows 1-5 the box.
FIRST_BOX_ROW = 0x10
FIRST_BOX_SLOT = FIRST_BOX_ROW + 2 # the box's columns are 2-5

# Party slot 1: the party is columns 0-1 of rows 3-5
PARTY_MON_1_POS = 0x30
# Where the hovered mon's shiny icon goes, beside its gender
SHINY_ICON_COORD = (5, 8)
SCREEN_WIDTH = 20

# IDs from here up are reserved values (EGG and the like) that never go through the table.
MON_TABLE_MINIMUM_RESERVED_INDEX = 0xfd


def species_index(name):
	return constants._consts(constants.ROOT / "constants" / "pokemon_constants.asm")[name]


def index_of_id(game, mon_id):
	"""The 16-bit species index an 8-bit ID stands for right now, or 0 if its slot is free."""
	low, high = game.peek("wPokemonIndexTableEntries", 2 * (mon_id - 1), 2)
	return low | high << 8


def box_slot(cursor_pos):
	"""The 0-based box slot under the cursor: rows 1-5 are $10-$50, the box's columns are 2-5."""
	pos = cursor_pos - FIRST_BOX_ROW
	return (pos >> 4) * 4 + (pos & 0xf) - 2


def open_bills_pc(game):
	game.warp("CHERRYGROVE_POKECENTER_1F", *PC_SPOT)
	game.press("up")
	game.press("a")
	for _ in range(20):
		if "BOX 1" in game.screen_text():
			break
		game.press("a", after=40)
	wait_until(game, lambda: game.peek("wBillsPC_BoxList") != 0, "box 1's icons")
	game.wait(30)


def assert_box_ids_in_use(game):
	box = game.peek("wCurBox") + 1
	for slot, mon_id in enumerate(game.peek("wBillsPC_BoxList", 0, 20)):
		if mon_id and mon_id < MON_TABLE_MINIMUM_RESERVED_INDEX:
			assert index_of_id(game, mon_id), \
				"box %d slot %d shows ID %d, which the table has freed" % (box, slot + 1, mon_id)


def alt_shiny_species():
	text = (constants.ROOT / ALT_SHINY_PALETTES).read_text(encoding="utf-8")
	return {species_index(name) for name in re.findall(r"^\tdw ([A-Z]\w*)", text, re.M)} # not the 0 at the end


def pick_held_species(game, top_row):
	"""A mon in box 1's top row whose ID nothing else keeps in use: not a party species (the party's
	IDs are always in use) and not one with an alternate shiny (those come again in the last boxes,
	which would put its ID back in use there). Otherwise the bug could slip by unseen."""
	party = {index_of_id(game, mon_id) for mon_id in game.peek("wPartySpecies", 0, game.peek("wPartyCount"))}
	later = alt_shiny_species()
	for species in top_row:
		if species and species not in party and species not in later:
			return species
	raise AssertionError("no mon in box 1's top row is free of the party and the alternate shinies: %s" % top_row)


def test_held_mon_keeps_its_icon_across_boxes(game):
	take_radio_items(game)
	open_bills_pc(game)

	top_row = [index_of_id(game, mon_id) for mon_id in game.peek("wBillsPC_BoxList", 0, 4)]
	held = pick_held_species(game, top_row)
	assert game.peek("wBillsPC_CursorPos") == FIRST_BOX_SLOT, "the cursor should start on box 1's first slot"
	for column in range(top_row.index(held)):
		move_cursor(game, "right", FIRST_BOX_SLOT + column + 1)
	for _ in range(3):
		if game.peek("wBillsPC_CursorMode") == SWAP_MODE:
			break
		game.press("select", after=20)
	assert game.peek("wBillsPC_CursorMode") == SWAP_MODE, "the PC never went into swap mode"

	game.press("a", after=30)
	assert index_of_id(game, game.peek("wBillsPC_HeldIcon")) == held, \
		"the held icon should be species %d" % held

	game.press("up", after=20)
	assert game.peek("wBillsPC_CursorPos") < FIRST_BOX_ROW, "the cursor should be on the box name"
	while game.peek("wCurBox") < LAST_BOX:
		box = game.peek("wCurBox")
		# A press can land while the last box is still being drawn and go unread.
		for _ in range(5):
			game.press("right", hold=6, after=60)
			if game.peek("wCurBox") != box:
				break
		assert game.peek("wCurBox") == box + 1, "the PC didn't move on from box %d" % (box + 1)
		assert_box_ids_in_use(game)
		assert index_of_id(game, game.peek("wBillsPC_HeldIcon")) == held, \
			"in box %d the held icon is no longer species %d" % (box + 2, held)

	for _ in range(5):
		game.press("down", hold=6, after=40)
		if game.peek("wBillsPC_CursorPos") >= FIRST_BOX_ROW:
			break
	assert game.peek("wBillsPC_CursorPos") >= FIRST_BOX_ROW, "the cursor should be in the box"
	slot = box_slot(game.peek("wBillsPC_CursorPos"))
	# The drop can go unread the same way, while the box is still settling
	for _ in range(5):
		game.press("a", after=60)
		if game.peek("wBillsPC_CursorHeldSlot") == 0:
			break
	assert game.peek("wBillsPC_CursorHeldSlot") == 0, "the held mon wasn't dropped"
	dropped = game.peek("wBillsPC_BoxList", slot)
	assert index_of_id(game, dropped) == held, \
		"the mon dropped in box %d slot %d shows as species %d, not %d" % (
			LAST_BOX + 1, slot + 1, index_of_id(game, dropped), held)


def move_cursor(game, button, pos):
	# A press can land while the box is still being drawn and go unread.
	for _ in range(5):
		game.press(button, hold=6, after=30)
		if game.peek("wBillsPC_CursorPos") == pos:
			return
	raise AssertionError("pressing %s never took the cursor to $%02x" % (button, pos))


@pytest.mark.parametrize("form, icon", [
	(A.SHINY_MASK | A.ALT_SHINY_MASK, A.ALT_SHINY_ICON),
	(A.SHINY_MASK, A.SHINY_ICON),
])
def test_hovered_mon_shows_its_shiny_icon(game, form, icon):
	take_radio_items(game)
	scyther = A.species_id(game, "SCYTHER")
	game.poke("wPartySpecies", scyther)
	set_party_field(game, 0, "Species", scyther)
	set_party_field(game, 0, "Form", form)
	open_bills_pc(game)

	for button, pos in (("down", 0x22), ("down", 0x32), ("left", 0x31), ("left", 0x30)):
		move_cursor(game, button, pos)
	assert game.peek("wBillsPC_CursorPos") == PARTY_MON_1_POS, "the cursor should be on party mon 1"
	game.wait(30)
	x, y = SHINY_ICON_COORD
	assert game.peek("wTilemap", y * SCREEN_WIDTH + x) == icon
