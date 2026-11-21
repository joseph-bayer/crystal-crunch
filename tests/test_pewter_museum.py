"""The Pewter Museum, ported from Yellow: Pewter City's front door leads to the museum's front
entrance and its side door to the side entrance, as in Gen 1, and each way out leads back."""

import re

import pytest

from harness.constants import ROOT
from harness.data import read
from harness.game import SCREEN_WIDTH
from harness.overworld import struct_field, struct_for_object, struct_position
from test_viridian_forest import into, walk

MUSEUM = "MUSEUM_1F"


@pytest.mark.parametrize("door, outside, inside", [
	("front", (15, 8), ((10, 9), (11, 9))),
	("side", (19, 6), ((16, 9), (17, 9))),
])
def test_pewter_door_to_the_museum_and_back(game, door, outside, inside):
	game.warp("PEWTER_CITY", *outside)
	walk(game, "up", into(game, MUSEUM))
	assert game.position() in inside, "the %s door" % door
	walk(game, "down", into(game, "PEWTER_CITY"))
	game.wait(60)
	door_x, door_y = outside[0], outside[1] - 1
	assert game.position() in ((door_x, door_y), outside), "out of the %s entrance" % door


def test_stairs_up_and_back_down(game):
	# Both floors' stairs are on the bottom row, at (7, 9) on 1F and (7, 7) on 2F. They were exit
	# mats once, which only
	# warp on a step down; then STAIRCASE, which steps the arriving player down, off the map.
	game.warp(MUSEUM, 7, 8)
	walk(game, "down", into(game, "MUSEUM_2F"))
	game.wait(120)
	assert game.in_map("MUSEUM_2F") and game.position() == (7, 7), "should stand on 2F's stairs"
	game.step("up")
	walk(game, "down", into(game, MUSEUM))
	game.wait(120)
	assert game.in_map(MUSEUM) and game.position() == (7, 9), "should stand on 1F's stairs"


FOSSIL_PIC_TILE = 0x80 # vTiles1, like pokepic
VTILES1 = 0x8800
PAL_BG_GRAY = 0
TILE_SIZE = 16
FRAME_TILE, FRAME_TILES = 0xba, 6 # the textbox frame's tiles, which sit among objects' walking frames
BOX_LEFT, BOX_TOP = 6, 4


def vram(game, tile, count):
	"""Tiles from VRAM bank 0's vTiles1."""
	start = VTILES1 + (tile - 0x80) * TILE_SIZE
	return bytes(game.pyboy.memory[0, start + i] for i in range(count * TILE_SIZE))


def fossil_description(name):
	"""The lines of an exhibit's description, the paragraph after its name, from Museum1F.asm."""
	text = read("maps/Museum1F.asm")
	label = "Museum1F%sFossilText:" % name.title()
	body = text[text.index(label):].split("\tdone", 1)[0]
	paragraph = body[body.index("\tpara "):]
	return re.findall(r'^\t(?:para|line|cont) "(.*)"', paragraph, re.M)


def read_fossil_sign(game, name):
	"""Read an exhibit's sign, from facing it to the pic being up. Returns the frame tiles as the
	sign text had them."""
	description = fossil_description(name)
	first, last = description[1], description[-1] # the second line, as the first has a #
	game.press("a")
	game.wait_for_text(name + " Fossil")
	game.wait(30)
	assert first not in game.screen_text(), "the name should have its own paragraph"
	game.press("a")
	game.wait_for_text(first)
	assert name + " Fossil" not in game.screen_text(), "the description should start a new paragraph"
	for _ in range(5): # a cont line waits for a button
		game.wait(30)
		if last in game.screen_text():
			break
		game.press("a")
	assert last in game.screen_text(), "the description should end with %r" % last
	game.wait(30)
	frame = vram(game, FRAME_TILE, FRAME_TILES)
	game.press("a") # the text goes and the pic opens
	game.wait(60)
	return frame


@pytest.mark.parametrize("x, y, name, size", [(2, 3, "AERODACTYL", 7), (2, 7, "KABUTOPS", 6)])
def test_fossil_signs_show_their_text_then_their_pic(game, x, y, name, size):
	# Yellow shows each exhibit's skeleton pic. Here the sign text comes first, then the pic in
	# pokepic's box, since pokepic's pic goes over the font.
	game.warp(MUSEUM, x, y + 1)
	game.step("up") # face the case; it blocks the way
	room = screen(game)
	frame = read_fossil_sign(game, name)
	assert fossil_description(name)[-1] not in game.screen_text(), "the text should go before the pic"
	assert screen(game)[BOX_TOP + 10:] == room[BOX_TOP + 10:], "the text box should be off the screen"

	pic = (ROOT / ("gfx/museum/fossil_%s.2bpp" % name.lower())).read_bytes()
	assert len(pic) == size * size * TILE_SIZE
	assert vram(game, FOSSIL_PIC_TILE, size * size) == pic, "the pic should be in vTiles1, as pokepic loads one"

	# The frame is the textbox's. With no text box open those tiles are walking frames, and the
	# border showed bits of sprites.
	assert game.peek("wTilemap", BOX_TOP * SCREEN_WIDTH + BOX_LEFT) == FRAME_TILE, "the box's top left corner"
	assert vram(game, FRAME_TILE, FRAME_TILES) == frame, "the box frame should be the textbox's"

	# bottom right in the 7x7 area inside the box at (6, 4), placed column by column
	left, top = 7 + 7 - size, 5 + 7 - size
	tilemap = game.peek("wTilemap", 0, SCREEN_WIDTH * 18)
	attrmap = game.peek("wAttrmap", 0, SCREEN_WIDTH * 18)
	for col in range(size):
		for row in range(size):
			at = (top + row) * SCREEN_WIDTH + left + col
			assert tilemap[at] == FOSSIL_PIC_TILE + col * size + row, (col, row)
			assert attrmap[at] & 0x0f == PAL_BG_GRAY, (col, row)

	game.press("a")
	game.wait(60)
	assert screen(game)[BOX_TOP:] == room[BOX_TOP:], "closing should bring the room back as it was"

	# the pic went over the font; the next text has to bring the font back
	game.press("a")
	game.wait_for_text(name + " Fossil")
	font = (ROOT / "gfx/font/font.1bpp").read_bytes()[:TILE_SIZE // 2] # "A"
	assert vram(game, FOSSIL_PIC_TILE, 1) == bytes(b for byte in font for b in (byte, byte)), "the font should be back"


def test_fossil_pic_leaves_the_overworld_as_it_found_it(game):
	# closepokepic left the BG map copy on, so vblank kept redrawing the screen in place once the
	# map scrolled: a step after the pic, the palettes stayed put while the tiles moved. And the pic
	# covered objects' walking frames with nothing to load them back (a follower's frame broke).
	refreshed = []
	bank, address = game.pyboy.symbol_lookup("RefreshSprites")
	game.pyboy.hook_register(bank, address, lambda _: refreshed.append(True), None)
	try:
		game.warp(MUSEUM, 2, 4)
		game.step("up")
		read_fossil_sign(game, "AERODACTYL")
		refreshed.clear()
		game.press("a")
		game.wait(60)
		assert refreshed, "the walking frames under the pic should be loaded again"
	finally:
		game.pyboy.hook_deregister(bank, address)
	assert game.peek("hBGMapMode") == 0, "the BG map copy should be off"

	game.step("right")
	game.wait(30)
	assert game.position() == (3, 4)
	scx, scy = game.pyboy.memory[0xff43], game.pyboy.memory[0xff42]
	assert (scx, scy) != (0, 0), "the step should scroll the map"
	tilemap = game.peek("wTilemap", 0, SCREEN_WIDTH * 18)
	attrmap = game.peek("wAttrmap", 0, SCREEN_WIDTH * 18)
	for row in range(18):
		for col in range(SCREEN_WIDTH):
			at = 0x9800 + ((scy // 8 + row) % 32) * 32 + (scx // 8 + col) % 32
			assert game.pyboy.memory[0, at] == tilemap[row * SCREEN_WIDTH + col], ("tile", col, row)
			assert game.pyboy.memory[1, at] == attrmap[row * SCREEN_WIDTH + col], ("attributes", col, row)


def screen(game):
	"""The tilemap and attributes, row by row. The map name sign can be up in the top rows."""
	return [(game.peek("wTilemap", row * SCREEN_WIDTH, SCREEN_WIDTH), game.peek("wAttrmap", row * SCREEN_WIDTH, SCREEN_WIDTH))
		for row in range(18)]


def test_old_amber_has_no_skin_color():
	# The NPC palettes' light color is skin; the yellow BG slot's is a light yellow
	text = read("maps/Museum1F.asm")
	assert re.search(r"object_event 16,  2, SPRITE_OLD_AMBER, .*PAL_NPC_COPY_BG_YELLOW,", text)
	assert re.search(r"object_event 15,  2, SPRITE_OLD_AMBER_GUY,", text)


OBJECT_DIRECTION = 0x08
OW_UP, OW_LEFT, OW_RIGHT = 4, 8, 12
STEPS = {"down": (0, 1), "up": (0, -1), "left": (-1, 0), "right": (1, 0)}
FACING_BACK = {"down": OW_UP, "left": OW_RIGHT, "right": OW_LEFT}


@pytest.mark.parametrize("map_name, npc, toward", [
	(MUSEUM, "MUSEUM1F_GAMBLER", "left"),
	(MUSEUM, "MUSEUM1F_SCIENTIST3", "down"),
	("MUSEUM_2F", "MUSEUM2F_BRUNETTE_GIRL", "down"),
])
def test_npcs_turn_to_talk(game, map_name, npc, toward):
	# The porter gave Yellow's "STAY, NONE" people SPRITEMOVEDATA_STILL, whose facing is fixed, so
	# they talked with their backs turned. Each is talked to from a side it doesn't face at first.
	map_file = map_name.title().replace("_", "")
	x, y = object_position(map_file, npc)
	dx, dy = STEPS[toward]
	game.warp(map_name, x - dx, y - dy)
	game.step(toward) # face them; they block the way
	struct = struct_for_object(game, map_file, npc)
	assert struct is not None and struct_position(game, struct) == (x, y)
	game.press("a")
	game.wait(30)
	assert struct_field(game, struct, OBJECT_DIRECTION) == FACING_BACK[toward], "%s should face the player" % npc


def object_position(map_file, npc):
	"""An object's (x, y) from its object_event, matched to its object_const_def name by order."""
	text = read("maps/%s.asm" % map_file)
	names = re.findall(r"^	const (\w+)", text.split("_MapScripts:")[0], re.M)
	events = re.findall(r"object_event +(\d+), +(\d+),", text)
	assert len(names) == len(events)
	return tuple(int(v) for v in dict(zip(names, events))[npc])


def test_only_the_old_amber_stands_still():
	# SPRITEMOVEDATA_STILL never turns, so a person who has it can't face the player
	for name in ("Museum1F", "Museum2F"):
		for line in read("maps/%s.asm" % name).splitlines():
			if "SPRITEMOVEDATA_STILL," in line:
				assert "SPRITE_OLD_AMBER," in line, line


# The ticket desk. The harness reads ¥ and 's oddly, so these match the words around them.

TICKET_PRICE = 60
TICKET_FLAG = "EVENT_BOUGHT_MUSEUM_TICKET"


def walk_up_to_the_desk(game, x, cash):
	from test_older_amber import set_money
	set_money(game, cash)
	game.warp(MUSEUM, x, 7)
	game.step("up")


@pytest.mark.parametrize("x", [9, 10])
def test_no_ticket_turns_you_back(game, x):
	from test_older_amber import money, read_through
	walk_up_to_the_desk(game, x, 1000)
	said = read_through(game, "b") # B: no
	assert "ticket." in said and "come in?" in said
	assert "Come again!" in said
	assert game.position() == (x, 7), "NO should step the player back down"
	assert money(game) == 1000
	assert not game.event_flag(TICKET_FLAG)


def test_buying_a_ticket_lets_you_in(game):
	from test_older_amber import money, read_through
	walk_up_to_the_desk(game, 10, 1000)
	game.wait(20)
	assert game.peek("wPlayerDirection") == OW_RIGHT, "the player should face the desk"
	said = read_through(game, "a")
	assert "Thank you!" in said
	assert money(game) == 1000 - TICKET_PRICE
	assert game.event_flag(TICKET_FLAG)
	assert game.position() == (10, 6)

	game.step("up")
	game.step("down") # back onto the trigger
	game.wait(30)
	assert game.peek("wScriptRunning") == 0 and "ticket." not in game.screen_text(), "a ticket holder walks on by"
	assert money(game) == 1000 - TICKET_PRICE


def test_too_little_money_turns_you_back(game):
	from test_older_amber import money, read_through
	walk_up_to_the_desk(game, 10, TICKET_PRICE - 1)
	said = read_through(game, "a")
	assert "enough money." in said and "Come again!" in said
	assert game.position() == (10, 7)
	assert money(game) == TICKET_PRICE - 1
	assert not game.event_flag(TICKET_FLAG)


@pytest.mark.parametrize("spot, toward", [((13, 6), "left"), ((12, 5), "down")])
@pytest.mark.parametrize("button, answer", [("a", "to resurrect"), ("b", "ized tree sap.")])
def test_behind_the_counter_he_talks_amber(game, spot, toward, button, answer):
	from test_older_amber import read_through
	game.warp(MUSEUM, *spot)
	game.step(toward) # he blocks the way
	game.press("a")
	said = read_through(game, button)
	assert "in the back way!" in said and "AMBER is?" in said
	assert answer in said
	assert "ticket." not in said


@pytest.mark.parametrize("ticket, spot, toward, line", [
	(True, (10, 6), "right", "time to look!"), # across the counter
	(False, (10, 6), "right", "ticket."),
	(True, (12, 8), "up", "time to look!"), # across the counter below him
	(False, (12, 8), "up", "other side!"),
])
def test_talking_to_the_desk(game, ticket, spot, toward, line):
	from test_older_amber import read_through
	game.set_event_flag(TICKET_FLAG, ticket)
	game.warp(MUSEUM, *spot)
	game.step(toward) # the counter blocks the way
	game.press("a")
	said = read_through(game, "b")
	assert line in said


TEXT_WIDTH = 18


def text_tiles(line):
	"""How many tiles a text line takes in the box: # is POKé (4), 's and the like are one."""
	line = line.replace("<PLAYER>", "1234567").replace("<RIVAL>", "1234567").replace("#", "1234")
	return len(re.sub(r"'[dlmrstv]", "1", line))


@pytest.mark.parametrize("path", ["maps/Museum1F.asm", "maps/Museum2F.asm", "engine/events/gen1_tutor.asm"])
def test_museum_text_fits_the_box(path):
	# A 19-tile line printed its last letter over the box's right border, where it stayed
	for number, line in enumerate(read(path).splitlines(), 1):
		m = re.match(r'\s*(?:text|line|cont|para|next)\s+"(.*)"', line)
		if m:
			assert text_tiles(m.group(1)) <= TEXT_WIDTH, "%s:%d is too wide: %s" % (path, number, m.group(1))
