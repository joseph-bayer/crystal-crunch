"""Fishing again after "Not even a nibble!": the recast after YES.

Two bugs this guards against:
* the text after YES printed with sprite tiles, because closing the box reloads the sprites over the
  font and the recast never loaded it again;
* the rod tip (tiles $fc/$fd, which share VRAM with the font) stayed on screen while the font was
  reloaded, so for a moment it showed font tiles, mirrored when facing left.

The recast puts the rod away first, so the tip disappears for a moment and the cast shows again."""

import pytest

# The debug radio in the bedroom (3, 1) gives the Good Rod, read from (3, 2) facing up.
RADIO_SPOT = (3, 2)

# Floor tiles in Cherrygrove City with water on one side.
FISHING_SPOTS = {
	"up": (35, 2),
	"left": (10, 6),
	"down": (10, 9),
	"right": (7, 12),
}

ROD_TIP_TILES = (0xfc, 0xfd)
OAM = 0xfe00
OAM_ENTRIES = 40
TILE_SIZE = 16

# How long to watch after YES for the next text box.
MAX_FRAMES = 800

SCREEN_WIDTH = 20
SCREEN_HEIGHT = 18
TEXT_BOX_TOP = 12
FRAME_TILES = set(range(0xba, 0xc0)) # "┌" to "┘"

# A seed whose first roll is no bite with the Good Rod here, whichever way the player faces.
NO_BITE_SEED = 0x0001


def take_radio_items(game):
	"""Read the debug radio, saying NO to every nickname."""
	game.warp("PLAYERS_HOUSE_2F", *RADIO_SPOT)
	game.press("up")
	game.press("a")
	for _ in range(300):
		text = game.screen_text()
		if "NICKNAME?" in text and "lower" in text:
			game.press("start")
		elif "YES" in text and "NO" in text:
			game.choose("NO")
		elif game.peek("wScriptRunning") == 0 and game.peek("wWindowStackSize") == 0:
			return
		else:
			game.press("a")
	raise AssertionError("the radio's script never finished. The screen:\n" + text)


def cast_good_rod(game, seed):
	game.press("start")
	game.wait(30)
	game.choose("PACK")
	game.wait(30)
	for _ in range(6):
		if "GOOD ROD" in game.screen_text():
			break
		game.press("right", after=40)
	game.choose("GOOD ROD")
	game.seed_random(seed)
	game.choose("USE")


def tile_data(game, tile):
	return [game.pyboy.memory[0, 0x8000 + tile * TILE_SIZE + i] for i in range(TILE_SIZE)]


def bg_tile_data(game, tile):
	"""A background tile's graphics, as the screen addresses them ($00-$7f at $9000, $80-$ff at
	$8800), in VRAM bank 0, where the font is."""
	base = 0x9000 + tile * TILE_SIZE if tile < 0x80 else 0x8800 + (tile - 0x80) * TILE_SIZE
	return [game.pyboy.memory[0, base + i] for i in range(TILE_SIZE)]


def text_box_tiles(game):
	"""The tile numbers in the text box at the bottom of the screen."""
	tiles = game.peek("wTilemap", 0, SCREEN_WIDTH * SCREEN_HEIGHT)
	return set(tiles[TEXT_BOX_TOP * SCREEN_WIDTH:])


def rod_tip_entries(game):
	"""The rod tip tiles the OAM is drawing right now."""
	tiles = set()
	for entry in range(OAM_ENTRIES):
		y, x, tile = (game.pyboy.memory[OAM + entry * 4 + i] for i in range(3))
		if tile in ROD_TIP_TILES and 0 < y < 160 and 0 < x < 168:
			tiles.add(tile)
	return tiles


@pytest.mark.parametrize("direction", ["left", "right", "up", "down"])
def test_fish_again_recast(game, direction):
	take_radio_items(game)
	game.warp("CHERRYGROVE_CITY", *FISHING_SPOTS[direction])
	game.press(direction, after=10)
	cast_good_rod(game, NO_BITE_SEED)
	game.wait_for_text("Fish again?")

	# The rod tip as the first cast drew it, and the font as the bag left it: both are right here
	rod_tip = {tile: tile_data(game, tile) for tile in ROD_TIP_TILES}
	font = {tile: bg_tile_data(game, tile) for tile in text_box_tiles(game)}
	assert rod_tip_entries(game), "the first cast should be showing the rod tip"

	# The cursor starts on YES. Press it without the menu helper's wait, to watch every frame.
	assert "▶YES" in game.screen_text()
	game.press("a", after=0)

	put_away = False
	box_closed = False
	for frame in range(MAX_FRAMES):
		game.wait(1)
		shown = rod_tip_entries(game)
		if not shown:
			put_away = True
		for tile in shown:
			assert tile_data(game, tile) == rod_tip[tile], (
				"frame %d after YES: the rod tip's tile $%02x is drawn while it holds other graphics"
				% (frame, tile))
		text = game.screen_text()
		if "Fish again?" in text:
			if box_closed:
				# The prompt again: the recast didn't bite either. Its text is the next text.
				break
			continue
		box_closed = True
		if "Not even a nibble!" in text or "A bite!" in text:
			break
	else:
		raise AssertionError("no text after the recast. The screen:\n" + game.screen_text())

	# wTilemap holds the right letters even when VRAM doesn't, so check the letters' graphics too.
	# Not the box frame: PyBoy starts LoadFrame's HDMA copy where the font's last one ended, so in
	# PyBoy every box's frame tiles hold leftover letters, an ordinary sign's included.
	for tile in (text_box_tiles(game) & font.keys()) - FRAME_TILES:
		assert bg_tile_data(game, tile) == font[tile], (
			"the text after the recast draws tile $%02x with other graphics than the font's" % tile)

	assert put_away, "the rod should be put away before the recast"
