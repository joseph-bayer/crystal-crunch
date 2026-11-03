"""Talking to the Copycat leaves the follower's colors alone.

Her script wrote wObject1Palette to color her disguises, as in the original game, where object
struct 1 was hers. Here struct 1 is the follower, so it was the follower's OAM palette that changed,
and the dynamic palettes only fix a palette when they load one: the follower kept the Copycat's
slot (slot 0 after the "got the pass" talk) until the map reloaded."""

import pytest

from harness import legendaries as L
from harness import followers as F

OBJECT_PALETTE = 0x06
OAM_PALETTE = 0b111
COPYCAT_STRUCT = 2 # the first object struct after the player and the follower
STAND = (3, 3) # left of the Copycat, who stands at (4, 3)

# How far through her story: (flags to set, what that talk is)
TALKS = {
	"first talk": [],
	"got the pass": ["EVENT_RETURNED_LOST_ITEM_TO_COPYCAT", "EVENT_GOT_PASS_FROM_COPYCAT"],
}


def palette_byte(game, struct):
	return F.object_field(game, struct, OBJECT_PALETTE)


def slot_color(game, struct):
	"""The color loaded in the OAM palette slot an object is drawn with."""
	return game.peek("wLoadedObjPal0", palette_byte(game, struct) & OAM_PALETTE)


PLAYERGENDER_FEMALE = 1 << 0


@pytest.mark.parametrize("player", ["boy", "girl"])
@pytest.mark.parametrize("talk", list(TALKS))
def test_follower_keeps_its_colors(game, talk, player):
	"""For a girl the house shows the other Copycat object, so both copies are covered."""
	L.get_ready(game, radio=True, badges=False)
	if player == "girl":
		game.poke("wPlayerGender", game.peek("wPlayerGender") | PLAYERGENDER_FEMALE)
	for flag in TALKS[talk]:
		game.set_event_flag(flag)
	game.warp("COPYCATS_HOUSE_2F", *STAND)
	game.press("right", after=30)
	assert F.object_field(game, F.FOLLOWER_STRUCT, F.OBJECT_SPRITE), "the follower isn't out"
	follower_before = palette_byte(game, F.FOLLOWER_STRUCT)
	copycat_color = F.object_field(game, COPYCAT_STRUCT, F.OBJECT_PAL_INDEX)
	assert slot_color(game, F.FOLLOWER_STRUCT) == F.object_field(game, F.FOLLOWER_STRUCT, F.OBJECT_PAL_INDEX)

	game.press("a", after=10)
	changed = set()
	for frame in range(3000):
		game.wait(1)
		changed.add(palette_byte(game, F.FOLLOWER_STRUCT))
		if any(c.isalpha() for c in "".join(game.screen_lines()[12:18])) and frame % 30 == 0:
			game.pyboy.button("a", 3)
		if frame > 100 and game.peek("wScriptRunning") == 0:
			break
	else:
		raise AssertionError("the Copycat's script never finished:\n" + game.screen_text())

	assert changed == {follower_before}, "the follower's palette byte changed: %s" % sorted(changed)
	assert slot_color(game, F.FOLLOWER_STRUCT) == F.object_field(game, F.FOLLOWER_STRUCT, F.OBJECT_PAL_INDEX)
	# Her own colors are her map object's, as they always were here.
	assert F.object_field(game, COPYCAT_STRUCT, F.OBJECT_PAL_INDEX) == copycat_color
	assert slot_color(game, COPYCAT_STRUCT) == copycat_color
