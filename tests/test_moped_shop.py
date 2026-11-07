"""The Cerulean Moped Shop: Cerulean's closed bike shop, open again as a copy of the Goldenrod Bike
Shop whose clerk sells the MOPED for ¥100,000."""

from harness.overworld import collision
from test_moped import has_key_item, give_key_items
from test_player_color import money, set_money, idle, press_until

PRICE = 100000
SHOP = "CERULEAN_MOPED_SHOP"
# In front of the clerk, who stands at (7, 2) facing left.
CLERK_SPOT = (6, 2)
# Outside the door at (14, 29), and the notice at (11, 29).
OUTSIDE = ("CERULEAN_CITY", 14, 30)
BELOW_SIGN = ("CERULEAN_CITY", 11, 30)


def offer(game):
	"""Talk to the clerk up to the yes-or-no."""
	game.warp(SHOP, *CLERK_SPOT)
	game.press("right")
	game.press("a")
	press_until(game, lambda: "YES" in game.screen_text(), "the clerk's offer")
	assert "¥100,000?" in game.screen_text()
	game.wait(20)


def finish(game):
	press_until(game, lambda: idle(game), "back on the map")


def test_buys_the_moped(game):
	set_money(game, PRICE + 5000)
	offer(game)
	game.press("a", after=30) # YES
	finish(game)
	assert has_key_item(game, "MOPED")
	assert money(game) == 5000


def test_exact_money_is_enough(game):
	set_money(game, PRICE)
	offer(game)
	game.press("a", after=30)
	finish(game)
	assert has_key_item(game, "MOPED")
	assert money(game) == 0


def test_not_enough_money(game):
	set_money(game, PRICE - 1)
	offer(game)
	game.press("a", after=30)
	finish(game)
	assert not has_key_item(game, "MOPED")
	assert money(game) == PRICE - 1


def test_saying_no_keeps_the_money(game):
	set_money(game, PRICE + 5000)
	offer(game)
	game.press("b", after=30) # NO
	finish(game)
	assert not has_key_item(game, "MOPED")
	assert money(game) == PRICE + 5000


def test_never_sells_a_second(game):
	give_key_items(game, "MOPED")
	set_money(game, PRICE + 5000)
	game.warp(SHOP, *CLERK_SPOT)
	game.press("right")
	game.press("a")
	for _ in range(20):
		assert "YES" not in game.screen_text(), "offered a second MOPED"
		if idle(game):
			break
		game.press("a", after=30)
	assert idle(game)
	assert money(game) == PRICE + 5000


def test_door_goes_in_and_out(game):
	game.warp(*OUTSIDE)
	game.step("up")
	game.wait(60)
	assert game.in_map(SHOP), "the old bike shop door leads in"
	assert game.position() in ((2, 7), (3, 7))
	game.step("down")
	game.wait(60)
	assert game.in_map("CERULEAN_CITY")
	assert game.position() == OUTSIDE[1:]


def test_notice_names_the_shop(game):
	game.warp(*BELOW_SIGN)
	game.press("up")
	game.press("a")
	game.wait(30)
	text = game.screen_text()
	assert "CERULEAN MOPED" in text, text
	assert "GOLDENROD" not in text
	finish(game)


def test_route_7_and_8_doors_stay_locked():
	"""They share Cerulean's old locked-door block ($66), which stays solid; the shop door is its
	own block ($81)."""
	from harness import constants
	for name in ("Route7", "Route8"):
		blocks = (constants.ROOT / "maps" / (name + ".ablk")).read_bytes()
		assert blocks.count(0x66) == 1 and 0x81 not in blocks, name
	steps = collision("Route7")
	assert "DOOR" not in {steps[xy] for xy in steps}, "Route 7 has no door"
	assert collision("CeruleanCity")[(14, 29)] == "DOOR"
