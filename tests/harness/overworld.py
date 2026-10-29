"""Overworld helpers: the object structs the engine keeps for what's on screen, and each map's
collision, read from the source tree."""

import re
from functools import lru_cache

from . import constants

# constants/map_object_constants.asm
OBJECT_LENGTH = 0x22
NUM_OBJECT_STRUCTS = 14
OBJECT_SPRITE = 0x00
OBJECT_MAP_OBJECT_INDEX = 0x01
OBJECT_MOVEMENT_TYPE = 0x03
OBJECT_WALKING = 0x07
OBJECT_DIRECTION = 0x08
OBJECT_MAP_X = 0x10
OBJECT_MAP_Y = 0x11
OBJECT_INIT_X = 0x14
OBJECT_INIT_Y = 0x15

# Object struct coordinates count from 4 tiles before the map's edge.
MAP_BORDER = 4


def struct_field(game, struct, field):
	return game.peek("wObjectStructs", struct * OBJECT_LENGTH + field)


def struct_for_object(game, map_file, object_const):
	"""The object struct showing a map object, by its object_const_def name, or None if it isn't on
	screen."""
	index = constants.map_objects(map_file)[object_const]
	for struct in range(NUM_OBJECT_STRUCTS):
		if struct_field(game, struct, OBJECT_SPRITE) and struct_field(game, struct, OBJECT_MAP_OBJECT_INDEX) == index:
			return struct
	return None


def struct_position(game, struct):
	"""A struct's map coordinates, in the same steps as wXCoord/wYCoord."""
	return (struct_field(game, struct, OBJECT_MAP_X) - MAP_BORDER,
		struct_field(game, struct, OBJECT_MAP_Y) - MAP_BORDER)


def _read(path):
	return (constants.ROOT / path).read_text(encoding="utf-8")


@lru_cache(maxsize=None)
def collision(map_file):
	"""{(x, y): collision name} for every step of a map, from its blocks and its tileset's
	collision table."""
	attrs = _read("data/maps/attributes.asm")
	const = re.search(r"map_attributes %s, (\w+)," % map_file, attrs).group(1)
	width, height = (int(n) for n in re.search(
		r"map_const %s,\s+(\d+),\s+(\d+)" % const, _read("constants/map_constants.asm")).groups())
	tileset = re.search(r"map %s, TILESET_(\w+)" % map_file, _read("data/maps/maps.asm")).group(1).lower()
	blocks_file = re.search(r"%s_Blocks:\s*\n\s*INCBIN \"([^\"]+)\"" % map_file,
		_read("data/maps/blocks.asm")).group(1)
	table = [re.findall(r"[A-Z_0-9]+", line.split("tilecoll")[1].split(";")[0])
		for line in _read("data/tilesets/%s_collision.asm" % tileset).splitlines()
		if line.strip().startswith("tilecoll")]
	blocks = (constants.ROOT / blocks_file).read_bytes()
	steps = {}
	for by in range(height):
		for bx in range(width):
			quarters = table[blocks[by * width + bx]]
			for i, name in enumerate(quarters):
				steps[(bx * 2 + i % 2, by * 2 + i // 2)] = name
	return steps
