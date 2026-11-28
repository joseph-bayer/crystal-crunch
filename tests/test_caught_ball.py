"""Caught balls: each ball's own picture on the stats screen, in its two colours, and changing a
party Pokémon's ball by USEing a ball from the Bag outside battle.

The caught ball is the low four bits of MON_CAUGHTBALL, 0-11 in ball item order from the Master
Ball. Using a ball asks first, uses it up, keeps the byte's other bits, and refuses an Egg or a
Pokémon already in that ball without using anything."""

import re
from pathlib import Path

import pytest

from harness import forms as F
from harness.forms import party_field, set_party_field

ROOT = Path(__file__).resolve().parent.parent
BALLS = ["MASTER BALL", "ULTRA BALL", "GREAT BALL", "POKé BALL", "HEAVY BALL", "LEVEL BALL", "LURE BALL",
	"FAST BALL", "FRIEND BALL", "MOON BALL", "LOVE BALL", "PARK BALL"]
CAUGHT_BALL_MASK = 0x0f
CAUGHT_POKE_BALL = 3
BALL_TILE = 0x32 # the stats screen's caught ball, at (8, 6)
BALL_PALETTE = 6
MEWTWO_SLOT = 0 # take_radio_items' party: Mewtwo, Mew, Lanturn, a beta Kingdra, Ditto, Ampharos


def ball_count(game, ball):
	"""How many of a ball the Bag holds: the balls pocket lists each ball's index's low byte, then
	its count."""
	index = BALLS.index(ball)
	for i in range(game.peek("wNumBalls")):
		low, count = game.peek("wBalls", i * 2, 2)
		if low == index:
			return count
	return 0


def ball_pictures():
	return (ROOT / "gfx" / "stats" / "caught_balls.2bpp").read_bytes()


def ball_palettes():
	"""Each ball's four colours, as bytes, from ball_colors.pal."""
	text = (ROOT / "gfx" / "stats" / "ball_colors.pal").read_text(encoding="utf-8")
	pals = []
	for line in re.findall(r"^\tRGB ([^\n;]+)", text, re.M):
		values = [int(v) for v in line.split(",")]
		words = [values[i] | values[i + 1] << 5 | values[i + 2] << 10 for i in range(0, 12, 3)]
		pals.append(b"".join(bytes([w & 0xff, w >> 8]) for w in words))
	return pals


def to_the_town(game):
	F.take_radio_items(game)
	game.warp("NEW_BARK_TOWN", 5, 7)


def open_stats(game, mon="MEWTWO"):
	game.press("start")
	game.wait(30)
	game.choose("POKéMON")
	game.wait(60)
	game.choose(mon)
	game.wait(30)
	game.choose("STATS")
	game.wait(90)


def use_ball(game, ball, mon="MEWTWO"):
	"""From the field: START, PACK, the ball, USE, then the Pokémon in the party menu."""
	game.press("start")
	game.wait(30)
	game.choose("PACK")
	game.wait(40)
	for _ in range(6):
		if ball in game.screen_text():
			break
		game.press("right", after=40)
	game.choose(ball)
	game.wait(20)
	game.choose("USE")
	game.wait(60)
	game.choose(mon)
	game.wait(40)


def read_until(game, text, limit=40):
	"""Press A through the messages until `text` shows; returns everything seen."""
	seen = []
	for _ in range(limit):
		screen = game.screen_text()
		seen.append(screen)
		if text in screen:
			return "\n".join(seen)
		game.press("a", after=20)
	raise AssertionError("never saw %r. The screen:\n%s" % (text, game.screen_text()))


@pytest.mark.parametrize("ball", [0, 2, 8, 11])
def test_the_stats_screen_shows_each_balls_picture_and_colours(game, ball):
	to_the_town(game)
	set_party_field(game, MEWTWO_SLOT, "CaughtBall", ball)
	open_stats(game)
	assert game.peek("wTilemap", 6 * 20 + 8) == BALL_TILE
	vram = bytes(game.pyboy.memory[0, 0x9000 + BALL_TILE * 16 + i] for i in range(16))
	assert vram == ball_pictures()[ball * 16:ball * 16 + 16], "the ball's own picture"
	assert game.peek("wAttrmap", 6 * 20 + 8) & 7 == BALL_PALETTE
	assert bytes(game.peek("wBGPals1", BALL_PALETTE * 8, 8)) == ball_palettes()[ball], "its two colours"


def test_a_ball_number_past_the_last_shows_the_poke_ball(game):
	to_the_town(game)
	set_party_field(game, MEWTWO_SLOT, "CaughtBall", 12)
	open_stats(game)
	vram = bytes(game.pyboy.memory[0, 0x9000 + BALL_TILE * 16 + i] for i in range(16))
	assert vram == ball_pictures()[CAUGHT_POKE_BALL * 16:CAUGHT_POKE_BALL * 16 + 16]
	assert game.peek("wAttrmap", 6 * 20 + 8) & 7 == 0, "the default palette, as before"


def test_every_ball_has_two_colours():
	for ball, pal in zip(BALLS, ball_palettes()):
		assert pal[2:4] != b"\xff\x7f", "%s's second colour is still white" % ball
	assert len(ball_palettes()) == len(BALLS)
	assert len(ball_pictures()) == len(BALLS) * 16


def test_using_a_ball_places_the_pokemon_in_it(game):
	to_the_town(game)
	set_party_field(game, MEWTWO_SLOT, "CaughtBall", 0x50 | CAUGHT_POKE_BALL) # other bits to keep
	before = ball_count(game, "ULTRA BALL")
	use_ball(game, "ULTRA BALL")
	seen = read_until(game, "YES")
	assert "Place MEWTWO" in seen and "in ULTRA BALL?" in seen
	game.choose("YES")
	read_until(game, "is now in")
	assert "the ULTRA BALL!" in game.screen_text()
	game.press("a", after=60) # the ball is taken once the message is read
	assert party_field(game, MEWTWO_SLOT, "CaughtBall") == 0x50 | 1, "the ball changed, the other bits kept"
	assert ball_count(game, "ULTRA BALL") == before - 1, "the ball is used up"


def test_no_keeps_the_ball(game):
	to_the_town(game)
	set_party_field(game, MEWTWO_SLOT, "CaughtBall", CAUGHT_POKE_BALL)
	before = ball_count(game, "MASTER BALL")
	use_ball(game, "MASTER BALL")
	read_until(game, "YES")
	game.choose("NO")
	game.wait(60)
	assert party_field(game, MEWTWO_SLOT, "CaughtBall") == CAUGHT_POKE_BALL
	assert ball_count(game, "MASTER BALL") == before


@pytest.mark.parametrize("ball, number, article", [("GREAT BALL", 2, "a"), ("ULTRA BALL", 1, "an")])
def test_the_same_ball_is_refused(game, ball, number, article):
	to_the_town(game)
	set_party_field(game, MEWTWO_SLOT, "CaughtBall", number)
	before = ball_count(game, ball)
	use_ball(game, ball)
	seen = read_until(game, "already in")
	assert "already in %s│" % article.ljust(3) in seen or "already in %s " % article in seen # "It's", 's one tile
	assert ball in game.screen_text()
	assert "YES" not in game.screen_text(), "no question"
	assert party_field(game, MEWTWO_SLOT, "CaughtBall") == number
	assert ball_count(game, ball) == before, "nothing used"


def test_an_egg_is_refused(game):
	to_the_town(game)
	egg = 0xfd # the EGG id
	game.poke("wPartySpecies", egg, 1)
	set_party_field(game, 1, "CaughtBall", CAUGHT_POKE_BALL)
	before = ball_count(game, "GREAT BALL")
	use_ball(game, "GREAT BALL", mon="MEW") # an Egg keeps its slot's nickname in the party menu
	read_until(game, "EGG")
	assert "can" in game.screen_text() and "EGG" in game.screen_text()
	assert "YES" not in game.screen_text(), "no question"
	game.wait(60)
	assert party_field(game, 1, "CaughtBall") == CAUGHT_POKE_BALL
	assert ball_count(game, "GREAT BALL") == before


def test_the_debug_radio_gives_every_ball(game):
	F.take_radio_items(game)
	for ball in BALLS:
		assert ball_count(game, ball) >= 10, ball
