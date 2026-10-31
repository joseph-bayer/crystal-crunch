"""The Pokégear phone's contact menu (CALL / DELETE / CANCEL) lets the cursor move down, so a contact
can be deleted, reported after v1.0.

Moving down reads the menu's item count through de, and the call that draws the menu with the VS
icon's colors (PokegearPhone_ApplyTilemap) clobbered it, so the cursor never left CALL.

The delete question's YES/NO box covers the VS icons of the 3rd and 4th contacts, and a menu
redraws tiles alone, so the box kept the icons' red where it covered them (reported 2026-10-31)."""

from harness.forms import wait_until

POKEGEAR_FLAGS = 1 << 2 | 1 << 7 # the phone card, and the Pokégear itself
PHONE_SCHOOLBOY_JACK = 5 # constants/phone_constants.asm; contact n is bit n - 1 of wPhoneList
CURSOR = "▶"


def has_jack(game):
	return bool(game.peek("wPhoneList") & 1 << (PHONE_SCHOOLBOY_JACK - 1))


def open_jacks_menu(game):
	"""Open the Pokégear's phone with Jack as the only contact, and his CALL / DELETE / CANCEL
	menu."""
	game.poke("wPokegearFlags", POKEGEAR_FLAGS)
	game.poke("wPhoneList", 1 << (PHONE_SCHOOLBOY_JACK - 1))
	game.press("start", after=40)
	game.choose("GEAR")
	wait_until(game, lambda: "EXIT" not in game.screen_text(), "the Pokégear", timeout=300)
	for _ in range(4):
		if "JACK" in game.screen_text():
			break
		game.press("right", after=60)
	assert "JACK" in game.screen_text(), "the phone tab never showed:\n" + game.screen_text()
	game.press("a", after=60)
	wait_until(game, lambda: "DELETE" in game.screen_text(), "Jack's menu", timeout=120)


def cursor_on(game, item):
	return any(CURSOR + item in line for line in game.screen_lines())


def test_cursor_moves_down_and_up(game):
	open_jacks_menu(game)
	assert game.peek("wPokegearPhoneSubmenuCursor") == 0
	game.press("down", hold=6, after=30)
	assert game.peek("wPokegearPhoneSubmenuCursor") == 1
	assert cursor_on(game, "DELETE"), game.screen_text()
	game.press("down", hold=6, after=30)
	assert game.peek("wPokegearPhoneSubmenuCursor") == 2
	assert cursor_on(game, "CANCEL"), game.screen_text()
	game.press("down", hold=6, after=30)
	assert game.peek("wPokegearPhoneSubmenuCursor") == 2, "the cursor should stop at the last item"
	game.press("up", hold=6, after=30)
	assert game.peek("wPokegearPhoneSubmenuCursor") == 1


def test_delete_a_contact(game):
	open_jacks_menu(game)
	assert has_jack(game)
	game.press("down", hold=6, after=30)
	game.press("a", after=60)
	game.wait_for_text("YES")
	# The box starts on YES; up makes sure. Not choose(): the list's own cursor beside JACK comes
	# first on screen.
	game.press("up", hold=6, after=30)
	assert cursor_on(game, "YES"), game.screen_text()
	game.press("a")
	wait_until(game, lambda: not has_jack(game), "Jack's deletion", timeout=300)


# Two contacts with a rematch on each weekday (data/phone/rematch_days.asm), both after Mom and Elm,
# so with those two first they fill the 3rd and 4th rows, under the YES/NO box.
PHONE_MOM = 1
PHONE_ELM = 4
REMATCH_PAIRS = { # weekday (SUNDAY = 0): two contacts
	0: (14, 21), # Reena, Gina
	1: (5, 15),  # Jack, Joey
	2: (16, 23), # Wade, Arnie
	3: (7, 17),  # Huey, Ralph
	4: (11, 18), # Gaven, Liz
	5: (12, 19), # Beth, Anthony
	6: (13, 20), # Jose, Todd
}
PHONE_REMATCH_ICON_TILE = 0x5e
VS_CELLS = [(17, 8), (18, 8), (17, 10), (18, 10)] # the 3rd and 4th rows' icons
BOX_CELL = (15, 9) # inside the YES/NO box, where no icon is


def set_contacts(game, contacts):
	flags = [0] * 8
	for contact in contacts:
		flags[(contact - 1) // 8] |= 1 << ((contact - 1) % 8)
	for i, byte in enumerate(flags):
		game.poke("wPhoneList", byte, i)


def bg_attribute(game, cell):
	col, row = cell
	bgmap = game.peek("hBGMapAddress") | game.peek("hBGMapAddress", 1) << 8
	return game.pyboy.memory[1, bgmap + row * 32 + col] & 7


def open_delete_box_over_vs_icons(game):
	"""Mom, Elm and two contacts with a rematch today, so the YES/NO box of the 3rd one's delete
	question goes over both their VS icons. Returns the icons' colors."""
	weekday = game.peek("wCurDay") % 7
	third, fourth = REMATCH_PAIRS[weekday]
	game.poke("wPokegearFlags", POKEGEAR_FLAGS)
	set_contacts(game, (PHONE_MOM, PHONE_ELM, third, fourth))
	game.press("start", after=40)
	game.choose("GEAR")
	wait_until(game, lambda: "EXIT" not in game.screen_text(), "the Pokégear", timeout=300)
	for _ in range(4):
		if "MOM" in game.screen_text():
			break
		game.press("right", after=60)
	assert "MOM" in game.screen_text(), "the phone tab never showed:\n" + game.screen_text()
	tiles = [game.peek("wTilemap", row * 20 + col) for col, row in VS_CELLS]
	assert tiles == [PHONE_REMATCH_ICON_TILE, PHONE_REMATCH_ICON_TILE + 1] * 2, "no VS icons to cover"
	icon_colors = [bg_attribute(game, cell) for cell in VS_CELLS]
	game.press("down", hold=6, after=30)
	game.press("down", hold=6, after=30)
	game.press("a", after=60)
	wait_until(game, lambda: "DELETE" in game.screen_text(), "the contact's menu", timeout=120)
	game.press("down", hold=6, after=30)
	game.press("a", after=60)
	game.wait_for_text("YES")
	game.wait(10)
	return icon_colors


def test_delete_box_covers_the_vs_icons(game):
	icon_colors = open_delete_box_over_vs_icons(game)
	box_color = bg_attribute(game, BOX_CELL)
	assert box_color not in icon_colors
	assert [bg_attribute(game, cell) for cell in VS_CELLS] == [box_color] * 4, 		"the YES/NO box kept the VS icons' colors"


def test_vs_icons_get_their_colors_back(game):
	"""NO: the box goes and both icons are colored again. YES: the 4th contact moves up into the 3rd
	row, its icon colored."""
	icon_colors = open_delete_box_over_vs_icons(game)
	game.press("down", hold=6, after=30) # NO
	game.press("a", after=60)
	wait_until(game, lambda: "YES" not in game.screen_text(), "the box closing", timeout=120)
	game.wait(10)
	assert [bg_attribute(game, cell) for cell in VS_CELLS] == icon_colors

	game.press("a", after=60)
	wait_until(game, lambda: "DELETE" in game.screen_text(), "the contact's menu", timeout=120)
	game.press("down", hold=6, after=30)
	game.press("a", after=60)
	game.wait_for_text("YES")
	game.wait(10)
	game.press("a", after=60) # YES
	wait_until(game, lambda: "YES" not in game.screen_text(), "the box closing", timeout=120)
	game.wait(10)
	assert [bg_attribute(game, cell) for cell in VS_CELLS[:2]] == icon_colors[:2]
