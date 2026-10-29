"""Helpers for the tests of forms, trades, hatching and the battle HUD: the debug radio's party and
items, the debug Super Nerd's menus, party slots by field name, and battles driven by their
on-screen text.

A form byte is the cosmetic form in its low bits plus SHINY_MASK; these tests set it directly by
symbol and check that it ends up where it should."""

from . import constants

SHINY_MASK = 0x80
CAUGHT_BALL_MASK = 0x0f
CAUGHT_MASTER_BALL = 0
CAUGHT_POKE_BALL = 3

# The species list's value for an egg: EGG is -3, kept as a byte.
EGG = 0xfd

# The debug radio in the bedroom (3, 1), read from (3, 2) facing up.
RADIO_SPOT = (3, 2)

# The debug Super Nerd stands at (1, 4) in the bedroom; from (1, 5), facing up, A talks to him.
SUPER_NERD_SPOT = (1, 5)


def form_constant(name):
	"""A species' form number by its const name, e.g. PIKACHU_SURF_FORM."""
	return constants._consts(constants.ROOT / "constants" / "pokemon_constants.asm")[name]


def take_radio_items(game):
	"""Read the debug radio, saying NO to every nickname: six Pokemon (Mewtwo, Mew, Lanturn, a beta
	Kingdra, Ditto, Ampharos), Master Balls and the rest."""
	game.warp("PLAYERS_HOUSE_2F", *RADIO_SPOT)
	game.press("up")
	game.press("a")
	for _ in range(300):
		text = game.screen_text()
		if "NICKNAME?" in text and "lower" in text:
			game.press("start")
		elif "YES" in text and "NO" in text:
			game.choose("NO")
		elif game.peek("wScriptRunning") == 0 and game.peek("wWindowStackSize") == 0:
			return
		else:
			game.press("a")
	raise AssertionError("the radio's script never finished. The screen:\n" + text)


def super_nerd_menu(game, *items):
	"""Talk to the debug Super Nerd and pick each menu item in turn."""
	game.warp("PLAYERS_HOUSE_2F", *SUPER_NERD_SPOT)
	game.press("up")
	game.press("a")
	for item in items:
		game.wait_for_text(item)
		game.choose(item)


def party_struct_length(game):
	return game._address("wPartyMon2")[1] - game._address("wPartyMon1")[1]


def party_field(game, slot, field):
	"""A byte of party mon `slot` (0-based), by its label: party_field(game, 2, "Form")."""
	return game.peek("wPartyMon1" + field, slot * party_struct_length(game))


def set_party_field(game, slot, field, value):
	game.poke("wPartyMon1" + field, value, slot * party_struct_length(game))


def ot_party_field(game, slot, field):
	"""A byte of the other side's party mon `slot` (0-based), by its label."""
	length = game._address("wOTPartyMon2")[1] - game._address("wOTPartyMon1")[1]
	return game.peek("wOTPartyMon1" + field, slot * length)


def party_species(game):
	count = game.peek("wPartyCount")
	return game.peek("wPartySpecies", 0, count) if count else []


def shorten_party(game, count):
	"""Keep only the first `count` party mon, so a new one has a party slot to land in."""
	game.poke("wPartyCount", count)
	game.poke("wPartySpecies", 0xff, count)


def wait_until(game, condition, what, timeout=3000, step=1):
	for _ in range(0, timeout, step):
		if condition():
			return
		game.wait(step)
	raise AssertionError("%s never happened. The screen:\n%s" % (what, game.screen_text()))


def press_until(game, condition, what, timeout=60):
	"""Press A through text until `condition()` holds."""
	for _ in range(timeout):
		if condition():
			return
		game.press("a")
	raise AssertionError("%s never appeared. The screen:\n%s" % (what, game.screen_text()))


def answer_prompts(game, until, timeout=200):
	"""Press through text, saying NO to yes/no questions and leaving the naming screen unchanged,
	until `until()` holds."""
	for _ in range(timeout):
		if until():
			return
		text = game.screen_text()
		if "lower" in text and "END" in text:
			game.press("start")
		elif "YES" in text and "NO" in text:
			game.choose("NO")
		else:
			game.press("a", after=30)
	raise AssertionError("the prompts never ended. The screen:\n" + game.screen_text())


def wait_for_battle_menu(game):
	"""Press through the battle's opening text until FIGHT shows."""
	for _ in range(60):
		if "FIGHT" in game.screen_text():
			return
		game.press("a")
	raise AssertionError("the battle menu never appeared. The screen:\n" + game.screen_text())


def throw_ball(game, ball="MASTER BALL"):
	"""From the battle menu, throw a ball from the PACK."""
	game.choose("PACK")
	game.wait(60)
	for _ in range(6):
		if ball in game.screen_text():
			break
		game.press("right", after=40)
	game.choose(ball)


def out_of_battle(game):
	return game.peek("wBattleMode") == 0 and game.peek("wScriptRunning") == 0
