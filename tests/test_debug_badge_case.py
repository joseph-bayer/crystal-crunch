"""The debug ROM's BADGE CASE key item: it sets how many badges the player has, 0 to 16, the first
that many in order (Johto's, then Kanto's), clearing the rest. Spec: plans/debug_badge_item_spec.md.

DebugBadgeCase is called directly, with the picker driven by real button presses."""

import pytest

from harness import data
from harness.alt_shiny import call

NUM_JOHTO_BADGES = 8


def set_badges(game, count):
	johto = min(count, NUM_JOHTO_BADGES)
	game.poke("wJohtoBadges", (1 << johto) - 1)
	game.poke("wKantoBadges", (1 << (count - johto)) - 1)


def badges(game):
	return game.peek("wJohtoBadges"), game.peek("wKantoBadges")


def expected(count):
	johto = min(count, NUM_JOHTO_BADGES)
	return (1 << johto) - 1, (1 << (count - johto)) - 1


def use_badge_case(game, *buttons):
	"""Open the picker, press each button in turn, then press A for "You now have N badges." if it
	shows."""
	call(game, "DebugBadgeCase", must_return=False, frames=60)
	game.wait_for_text("How many badges?")
	for button in buttons:
		game.press(button, hold=4, after=10)
	if "You now have" in game.screen_text() or buttons[-1] == "a":
		game.wait_for_text("badges.")
		game.press("a", after=30)


@pytest.mark.parametrize("count", [4, 8, 9, 16])
def test_sets_the_first_badges(game, count):
	set_badges(game, 0)
	use_badge_case(game, *(["up"] * count + ["a"]))
	assert badges(game) == expected(count)


def test_shows_the_new_count(game):
	set_badges(game, 2)
	call(game, "DebugBadgeCase", must_return=False, frames=60)
	game.wait_for_text("How many badges?")
	game.press("up", hold=4, after=10)
	game.press("a", hold=4, after=10)
	game.wait_for_text("badges.")
	assert "3 badges." in game.screen_text()


def test_lowering_clears_the_rest(game):
	set_badges(game, 16)
	use_badge_case(game, *(["down"] * 13 + ["a"]))
	assert badges(game) == expected(3)


def test_wraps_round(game):
	set_badges(game, 0)
	use_badge_case(game, "down", "a")
	assert badges(game) == expected(16)
	use_badge_case(game, "up", "a")
	assert badges(game) == expected(0)


def test_b_changes_nothing(game):
	set_badges(game, 5)
	call(game, "DebugBadgeCase", must_return=False, frames=60)
	game.wait_for_text("How many badges?")
	game.press("up", hold=4, after=10)
	game.press("b", hold=4, after=30)
	assert badges(game) == expected(5)
	assert "You now have" not in game.screen_text()


def test_the_debug_script_gives_it():
	assert "\tgiveitem BADGE_CASE" in data.read("maps/PlayersHouse2F.asm")


BADGE_CASE_FLAG = 0x19 # its item index is $0119; key item flags go by the low byte


def test_used_from_the_bag(game):
	"""The whole way: the Key Items pocket, BADGE CASE, USE, then the picker."""
	game.poke("wKeyItemFlags", game.peek("wKeyItemFlags", BADGE_CASE_FLAG // 8) | 1 << BADGE_CASE_FLAG % 8,
		BADGE_CASE_FLAG // 8)
	# The bag's list, as RefreshKeyItemsList would rebuild it (the new game holds no key items)
	game.poke("wNumKeyItems", 1)
	game.poke("wKeyItems", BADGE_CASE_FLAG)
	game.poke("wKeyItems", 0xff, 1)
	set_badges(game, 0)
	game.press("start", after=30)
	game.choose("PACK")
	game.wait(40)
	for _ in range(6):
		if "BADGE CASE" in game.screen_text():
			break
		game.press("left", after=40)
	game.choose("BADGE CASE")
	game.wait(20)
	game.choose("USE")
	game.wait_for_text("How many badges?")
	for _ in range(7):
		game.press("up", hold=4, after=10)
	game.press("a", hold=4, after=10)
	game.wait_for_text("badges.")
	assert "7 badges." in game.screen_text()
	game.press("a", after=30)
	assert badges(game) == expected(7)


def shown_count(game):
	"""The count after "Badges:" on the picker's second line."""
	line = next(line for line in game.screen_lines() if "Badges:" in line)
	return line.split("Badges:")[1].strip(" │")


def test_the_shown_count_follows_every_press(game):
	"""The number on screen is the count, with no digit left over from a longer one: 16 then up is
	0, not "10"; 10 then down is 9, not "19"."""
	set_badges(game, 15)
	call(game, "DebugBadgeCase", must_return=False, frames=60)
	game.wait_for_text("Badges:")
	count = 15
	for button in ["up", "up", "down"] + ["down"] * 7 + ["down"]:
		game.press(button, hold=4, after=10)
		count = (count + (1 if button == "up" else -1)) % 17
		assert shown_count(game) == str(count), "after %s: %r" % (button, shown_count(game))
	game.press("b", after=30)
