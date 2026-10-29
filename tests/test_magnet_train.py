"""The Magnet Train ride's scene (0cc5d5957).

* The background was drawn only on its first row: GetMagnetTrainBGTiles overwrote DrawMagnetTrain's
  row counter, so rows 1-17 kept the station's tiles.
* The player's sprite was invisible: the map palettes leave every OBJ palette blank for the dynamic
  palette system, and nothing filled OBJ palette 0, which the ride's player frames use."""

from harness import constants
from test_fishing import take_radio_items

STATION_OFFICER_SPOT = (9, 10) # below the officer at (9, 9)

VBGMAP0 = 0x9800
TILEMAP_WIDTH = 32
SCREEN_WIDTH = 20
SCREEN_HEIGHT = 18
TRAIN_ROWS = range(6, 10)

PAL_OW_RED = 0
PALETTE_SIZE = 8

MAX_PRESSES = 80
SETTLE_FRAMES = 30


def bg_row(game, row):
	return [game.pyboy.memory[0, VBGMAP0 + row * TILEMAP_WIDTH + i] for i in range(TILEMAP_WIDTH)]


def expected_rows():
	"""What DrawMagnetTrain should leave in the background map: each row's pair of tiles repeated
	across all 32 columns, with the train over columns 0-19 of rows 6-9."""
	strips = (constants.ROOT / "gfx" / "overworld" / "magnet_train_bg.tilemap").read_bytes()
	train = (constants.ROOT / "gfx" / "overworld" / "magnet_train_fg.tilemap").read_bytes()
	rows = []
	for row in range(SCREEN_HEIGHT):
		line = [strips[row * 2], strips[row * 2 + 1]] * (TILEMAP_WIDTH // 2)
		if row in TRAIN_ROWS:
			start = (row - TRAIN_ROWS.start) * SCREEN_WIDTH
			line[:SCREEN_WIDTH] = train[start:start + SCREEN_WIDTH]
		rows.append(line)
	return rows


def board_the_train(game):
	"""Talk to the Goldenrod officer with the PASS and the power back on, until the ride is drawn."""
	take_radio_items(game)
	game.set_event_flag("EVENT_RESTORED_POWER_TO_KANTO")
	game.warp("GOLDENROD_MAGNET_TRAIN_STATION", *STATION_OFFICER_SPOT)
	game.press("up")
	game.press("a")
	train_row = expected_rows()[TRAIN_ROWS.start][:SCREEN_WIDTH]
	for _ in range(MAX_PRESSES):
		if "YES" in game.screen_text() and "NO" in game.screen_text():
			game.choose("YES")
			continue
		if bg_row(game, TRAIN_ROWS.start)[:SCREEN_WIDTH] == train_row:
			game.wait(SETTLE_FRAMES)
			return
		game.press("a", after=10)
	raise AssertionError("the ride never started. The screen:\n" + game.screen_text())


def test_magnet_train_scene(game):
	board_the_train(game)

	for row, expected in enumerate(expected_rows()):
		assert bg_row(game, row) == expected, "background row %d isn't the ride's scene" % row

	palette = [game.peek("wOBPals1", PAL_OW_RED * PALETTE_SIZE + i) for i in range(PALETTE_SIZE)]
	assert palette != [0xff] * PALETTE_SIZE, "the player's OBJ palette was left blank"
