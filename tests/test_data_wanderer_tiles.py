"""Wandering Pokémon placed on the wrong kind of tile.

A wanderer's slot number picks its roster: a map's grass slots come before its water ones, and
the object's movement type has to match (SWIM_WANDER for a water slot). Route 30's water slot was
placed in tall grass halfway up the route, so a level 20 Poliwhirl could be walked into on the way
to Mr. Pokémon; Route 27's first water slot was in tall grass too, and one of Slowpoke Well B2F's
land slots stood on water. So a swimming wanderer has to start on water, and a walking one off it."""

import re

import pytest

from harness import data, overworld

OBJECT = re.compile(r"object_event\s+(\d+),\s*(\d+),\s*(SPRITE_OW_MON_\d),\s*(SPRITEMOVEDATA_\w+),"
	r".*OBJECTTYPE_WILDMON")


def wanderers():
	for path in sorted((data.ROOT / "maps").glob("*.asm")):
		for match in OBJECT.finditer(path.read_text(encoding="utf-8")):
			x, y, sprite, movement = match.groups()
			yield pytest.param(path.stem, (int(x), int(y)), movement, id="%s-%s" % (path.stem, sprite))


@pytest.mark.parametrize("map_file, spot, movement", list(wanderers()))
def test_wanderer_starts_on_its_kind_of_tile(map_file, spot, movement):
	tile = overworld.collision(map_file).get(spot)
	assert tile is not None, "%s is off the map" % (spot,)
	on_water = "WATER" in tile
	if "SWIM" in movement:
		assert on_water, "a swimming wanderer starts on %s at %s" % (tile, spot)
	else:
		assert not on_water, "a walking wanderer starts on %s at %s" % (tile, spot)
