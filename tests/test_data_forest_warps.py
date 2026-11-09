"""Every warp in the forest-tileset maps stands on a tile you can warp from.

Apricorn Forest's makeover painted a tree wall over the entrance to the clearing, so its two warps
sat inside the wall and the clearing (and its Snorlax) couldn't be reached. This reads each map's
blocks and the forest collision table and checks the tile under every warp_event."""

import re

import pytest

from harness import data

COLLISION = "data/tilesets/forest_collision.asm"
WARP_TILE = re.compile(r"WARP|DOOR|CAVE|STAIR|LADDER|PIT")

# Warps that are only ever arrived at, never stepped on: the clearing's shore pad warp is the
# landing spot for the way out, set up by script.
ARRIVAL_ONLY = {
	("ApricornForestClearing", 12, 6),
}


def collision():
	"""[[top left, top right, bottom left, bottom right] for each block id]."""
	rows = []
	for line in data.read(COLLISION).splitlines():
		line = data.code(line)
		if line.startswith("tilecoll"):
			rows.append(re.findall(r"\w+", line[len("tilecoll"):]))
	return rows


def forest_maps():
	"""(map name, width in blocks, block bytes) for every map on TILESET_FOREST."""
	constants = {m[0]: int(m[1]) for m in re.findall(
		r"map_const (\w+),\s*(\d+),\s*\d+", data.read("constants/map_constants.asm"))}
	attributes = dict(re.findall(r"map_attributes (\w+), (\w+),", data.read("data/maps/attributes.asm")))
	blocks = dict(re.findall(r'^(\w+)_Blocks:\n\tINCBIN "(.+?)"', data.read("data/maps/blocks.asm"), re.M))
	for name in re.findall(r"^\tmap (\w+), TILESET_FOREST,", data.read("data/maps/maps.asm"), re.M):
		with open(data.ROOT / blocks[name], "rb") as f:
			yield name, constants[attributes[name]], f.read()


def warps():
	tiles = collision()
	for name, width, blocks in forest_maps():
		for x, y in re.findall(r"^\twarp_event\s+(\d+),\s*(\d+),", data.read(f"maps/{name}.asm"), re.M):
			x, y = int(x), int(y)
			if (name, x, y) in ARRIVAL_ONLY:
				continue
			block = blocks[(y // 2) * width + x // 2]
			yield pytest.param(name, x, y, block, tiles[block][(y % 2) * 2 + x % 2], id=f"{name}-{x}-{y}")


@pytest.mark.parametrize("name, x, y, block, tile", list(warps()))
def test_warp_stands_on_a_warp_tile(name, x, y, block, tile):
	assert WARP_TILE.search(tile), f"{name} warp at ({x}, {y}) is on block ${block:02x}, a {tile} tile"


def test_apricorn_forest_opens_into_the_clearing():
	tiles = collision()
	for name, width, blocks in forest_maps():
		if name == "ApricornForest":
			assert [blocks[2 * width + 6], blocks[2 * width + 7]] == [0x3D, 0x3E]
			assert tiles[0x3D][3] == tiles[0x3E][2] == "CAVE"
			return
	pytest.fail("ApricornForest isn't on TILESET_FOREST")
