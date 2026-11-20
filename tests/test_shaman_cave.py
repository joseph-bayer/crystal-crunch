"""The Hidden Power Shaman's cave in the Ruins of Alph: its mouth outside takes the player in, its
exit takes them back out, and she, her campfire and her Xatu are home only once she's been met."""

OUTSIDE = "RUINS_OF_ALPH_OUTSIDE"
CAVE = "RUINS_OF_ALPH_SHAMAN_CAVE"
MOUTH = (4, 7) # the cave mouth outside
CAVE_OBJECTS = ("RUINSOFALPHSHAMANCAVE_SHAMAN", "RUINSOFALPHSHAMANCAVE_CAMPFIRE", "RUINSOFALPHSHAMANCAVE_XATU")


def walk_in(game):
	game.warp(OUTSIDE, MOUTH[0], MOUTH[1] + 1)
	game.step("up")
	game.wait(120)
	assert game.in_map(CAVE), "the cave mouth didn't lead into the cave"


def test_the_cave_mouth_leads_in_and_out(game):
	walk_in(game)
	game.step("down")
	game.wait(120)
	assert game.in_map(OUTSIDE), "the cave's exit didn't lead back out"
	assert game.position()[0] == MOUTH[0]


def test_the_cave_is_empty_until_she_is_met(game):
	walk_in(game)
	for name in CAVE_OBJECTS:
		assert not game.object_shown("RuinsOfAlphShamanCave", name), name


def test_she_is_home_once_met(game):
	game.set_event_flag("EVENT_MET_HIDDEN_POWER_SHAMAN")
	walk_in(game)
	for name in CAVE_OBJECTS:
		assert game.object_shown("RuinsOfAlphShamanCave", name), name
