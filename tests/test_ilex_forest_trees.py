"""Ilex Forest's trees sway cleanly while the forest is restless (the Celebi event).

GetForestTreeFrame returned 0 or 1 where its callers expected 0 or 2, so the tree tiles were read
from half a tile (8 bytes) into the frame graphics: the trees showed rows of both frames mixed
together instead of switching between the two frames."""

from harness import constants

# Inside the forest, next to the shrine.
FOREST_SPOT = (8, 23)

CELEBIEVENT_FOREST_IS_RESTLESS_F = 2

VTILES2 = 0x9000
TILE_SIZE = 16
LEFT_TREE_TILE = 0x0c
RIGHT_TREE_TILE = 0x0f

SAMPLE_FRAMES = 240


def frame_tile(number):
	return (constants.ROOT / "gfx" / "tilesets" / "forest-tree" / ("%d.2bpp" % number)).read_bytes()


def vram_tile(game, tile):
	address = VTILES2 + tile * TILE_SIZE
	return bytes(game.pyboy.memory[0, address + i] for i in range(TILE_SIZE))


def sample_tiles(game):
	"""Each frame's left and right tree tiles, over a few seconds."""
	left, right = [], []
	for _ in range(SAMPLE_FRAMES):
		game.wait(1)
		left.append(vram_tile(game, LEFT_TREE_TILE))
		right.append(vram_tile(game, RIGHT_TREE_TILE))
	return left, right


def set_restless(game, restless):
	flags = game.peek("wCelebiEvent")
	if restless:
		flags |= 1 << CELEBIEVENT_FOREST_IS_RESTLESS_F
	else:
		flags &= ~(1 << CELEBIEVENT_FOREST_IS_RESTLESS_F) & 0xff
	game.poke("wCelebiEvent", flags)


def test_trees_stand_still_when_forest_is_calm(game):
	game.warp("ILEX_FOREST", *FOREST_SPOT)
	set_restless(game, False)

	left, right = sample_tiles(game)

	assert set(left) == {frame_tile(1)}
	assert set(right) == {frame_tile(3)}


def test_trees_sway_when_forest_is_restless(game):
	game.warp("ILEX_FOREST", *FOREST_SPOT)
	set_restless(game, True)

	left, right = sample_tiles(game)

	left_frames = {frame_tile(1), frame_tile(2)}
	right_frames = {frame_tile(3), frame_tile(4)}
	assert set(left) <= left_frames, "the left tree tile isn't one of its two frames"
	assert set(right) <= right_frames, "the right tree tile isn't one of its two frames"
	assert set(left) == left_frames, "the left tree tile never switched frames"
	assert set(right) == right_frames, "the right tree tile never switched frames"
