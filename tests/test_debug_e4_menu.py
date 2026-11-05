"""The debug Scientist's STORY -> E4 LINEUP menu.

Its lineup and picker texts ended with `done` right after text_ram, a character where the text
engine expected a command, so they printed the texts after them in ROM over the edge of the box,
and the picker never showed who was on offer. The lineup also put two names on a line, which two
seven-letter names overflow. (test_data_text_commands.py looks for the same mistake everywhere.)"""

import re

from harness.legendaries import SCIENTIST_SPOT

STRAY = ("PICK", "DEBUG", "the seat")


def box_lines(game):
	"""The text box's two lines of text, without the border."""
	lines = game.screen_lines()
	return [lines[14].strip("│ ").strip(), lines[16].strip("│ ").strip()]


def open_lineup(game):
	game.warp("PLAYERS_HOUSE_2F", *SCIENTIST_SPOT)
	game.press("up")
	game.press("a")
	game.wait_for_text("E4 LINEUP")
	game.choose("E4 LINEUP")
	game.wait(120)


def read_lineup(game):
	"""The three pages of the lineup, then the menu after them; returns the five names."""
	pages = []
	for _ in range(3):
		lines = box_lines(game)
		assert not any(word in " ".join(lines) for word in STRAY), "stray text: %s" % lines
		pages.append(lines)
		game.press("a", after=90)
	labels = [pages[0][0], pages[0][1], pages[1][0], pages[1][1], pages[2][0]]
	names = []
	for label, prefix in zip(labels, ["1 ", "2 ", "3 ", "4 ", "CHAMP "]):
		assert re.fullmatch(re.escape(prefix) + r"[A-Z.']+", label), "lineup line %r" % label
		names.append(label[len(prefix):])
	assert pages[2][1] == ""
	return names


def test_the_lineup_shows_one_name_a_line(game):
	open_lineup(game)
	read_lineup(game)
	game.wait_for_text("SET SEAT")


def test_the_picker_shows_who_is_on_offer(game):
	open_lineup(game)
	seat_1 = read_lineup(game)[0]
	game.choose("SET SEAT")
	game.wait_for_text("SEAT 1")
	game.choose("SEAT 1")
	game.wait(90)
	assert box_lines(game) == ["PICK: " + seat_1, ""]

	game.choose("NEXT")
	game.wait(90)
	offered = box_lines(game)[0]
	assert re.fullmatch(r"PICK: [A-Z.']+", offered) and offered != "PICK: " + seat_1

	game.choose("SET")
	game.wait(120)
	assert read_lineup(game)[0] == offered[len("PICK: "):]
