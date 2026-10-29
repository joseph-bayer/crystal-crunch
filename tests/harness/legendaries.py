"""Helpers for the legendary respawn tests: getting a new game ready to meet the legendaries, the
debug Scientist's LEGENDS menu, starting each legendary's battle and ending it each of the four ways
(knocked out, run from, blacked out to, caught), and reading the roaming beasts' structs.

The respawn itself only changes event flags; what a test checks is what those flags make the maps
show afterwards, and what each battle leaves behind for the respawn to read."""

from . import constants
from .forms import (answer_prompts, out_of_battle, shorten_party, take_radio_items, throw_ball,
	wait_for_battle_menu, wait_until)

# The debug Scientist stands at (0, 4) in the bedroom; from (0, 5), facing up, A talks to him.
SCIENTIST_SPOT = (0, 5)

ALL_BADGES = 0xff
SHINY_MASK = 0x80


def species_index(name):
	"""A species' 16-bit index by its const name, e.g. RAIKOU."""
	return constants._consts(constants.ROOT / "constants" / "pokemon_constants.asm")[name]


def music_constant(name):
	return constants._consts(constants.ROOT / "constants" / "music_constants.asm")[name]


def index_of_id(game, mon_id):
	"""The 16-bit species index behind an 8-bit species ID, read from the game's conversion table."""
	assert 0 < mon_id < 0xfd, "species ID $%02x isn't a table entry" % mon_id
	low = game.peek("wPokemonIndexTableEntries", (mon_id - 1) * 2)
	high = game.peek("wPokemonIndexTableEntries", (mon_id - 1) * 2 + 1)
	return low | high << 8


def get_ready(game, radio=True, badges=True, wings=False):
	"""The debug radio's party and items (Master Balls among them) with room in the party for a
	catch, all sixteen badges for the birds, and the wings for Lugia and Ho-Oh. Tests that only set
	flags skip the radio, which is the slow part."""
	if radio:
		take_radio_items(game)
		shorten_party(game, 5)
	if badges:
		game.poke("wJohtoBadges", ALL_BADGES)
		game.poke("wKantoBadges", ALL_BADGES)
	if wings:
		legends_menu(game, "GIVE WINGS")
		answer_prompts(game, lambda: idle(game))


def idle(game):
	return (out_of_battle(game) and game.peek("wWindowStackSize") == 0
		and game.peek("wMapStatus") == 2)


def legends_menu(game, item):
	"""The debug Scientist's STORY -> LEGENDS menu."""
	game.warp("PLAYERS_HOUSE_2F", *SCIENTIST_SPOT)
	game.press("up")
	game.press("a")
	game.wait_for_text("LEGENDS")
	game.choose("LEGENDS")
	game.wait_for_text(item)
	game.choose(item)


def respawn(game):
	"""STORY -> LEGENDS -> RESPAWN NOW: the same script the Hall of Fame runs."""
	legends_menu(game, "RESPAWN NOW")
	game.wait_for_text("respawned.")
	game.press("a")
	wait_until(game, lambda: idle(game), "the menu closing")


def enter(game, map_name, x, y):
	"""Warp onto a map, so its callbacks and object flags decide what shows."""
	game.warp(map_name, x, y)
	wait_until(game, lambda: idle(game), "the map settling")


def meet(game, map_name, spot, facing):
	"""Walk up to a legendary and talk to it, through its text, into the battle menu."""
	enter(game, map_name, *spot)
	game.press(facing, after=10)
	game.press("a")
	answer_prompts(game, lambda: game.peek("wBattleMode") == 1)
	wait_for_battle_menu(game)


def enemy_level(game):
	return game.peek("wEnemyMonLevel")


def enemy_species(game):
	return index_of_id(game, game.peek("wEnemyMonSpecies"))


# The four ways a battle with a legendary can end

def knock_out(game):
	"""Leave the legendary on 1 HP, then attack until the battle ends."""
	for _ in range(6):
		if out_of_battle(game):
			return
		if "FIGHT" in game.screen_text():
			game.poke("wEnemyMonHP", 0)
			game.poke("wEnemyMonHP", 1, 1)
			battle_menu_choose(game, "FIGHT")
			game.wait(30)
			game.press("a") # the first move
		answer_prompts(game, lambda: out_of_battle(game) or "FIGHT" in game.screen_text())
	assert out_of_battle(game), "the battle didn't end. The screen:\n" + game.screen_text()


# The battle menu is two by two: FIGHT and PKMN above PACK and RUN. PKMN's label is hidden behind
# the cursor when it's there.
BATTLE_MENU = {"FIGHT": (0, 0), "PKMN": (0, 1), "PACK": (1, 0), "RUN": (1, 1)}


def battle_menu_cursor(game):
	text = game.screen_text()
	for marker, place in (("▶FIGHT", (0, 0)), ("FIGHT▶", (0, 1)), ("▶PACK", (1, 0)), ("▶RUN", (1, 1))):
		if marker in text:
			return place
	return None


def battle_menu_choose(game, item):
	"""Move the battle menu's cursor to `item` and press A. The menu ignores buttons until its
	cursor shows, so wait for that first."""
	row, column = BATTLE_MENU[item]
	for _ in range(30):
		cursor = battle_menu_cursor(game)
		if cursor is None:
			game.wait(10)
		elif cursor == (row, column):
			game.press("a")
			return
		elif cursor[0] != row:
			game.press("down" if cursor[0] < row else "up")
		else:
			game.press("right" if cursor[1] < column else "left")
	raise AssertionError("couldn't choose %s. The screen:\n%s" % (item, game.screen_text()))


def run_away(game):
	"""RUN, until it works."""
	for _ in range(10):
		if out_of_battle(game):
			return
		if "FIGHT" in game.screen_text():
			battle_menu_choose(game, "RUN")
		answer_prompts(game, lambda: out_of_battle(game) or "FIGHT" in game.screen_text())
	assert out_of_battle(game), "couldn't run. The screen:\n" + game.screen_text()


def catch(game):
	"""Throw a Master Ball, and say NO to a nickname."""
	throw_ball(game, "MASTER BALL")
	answer_prompts(game, lambda: out_of_battle(game))


def black_out(game):
	"""Leave the lead mon on 1 HP and the rest fainted, and use a move that does no damage until the
	legendary attacks. The lead is the radio's Mewtwo, whose AMNESIA is that move."""
	length = game._address("wPartyMon2")[1] - game._address("wPartyMon1")[1]
	for slot in range(game.peek("wPartyCount")):
		game.poke("wPartyMon1HP", 0, slot * length)
		game.poke("wPartyMon1HP", 0, slot * length + 1)
	game.poke("wPartyMon1HP", 1, 1)
	game.poke("wBattleMonHP", 0)
	game.poke("wBattleMonHP", 1, 1)
	for _ in range(20):
		if out_of_battle(game):
			break
		if "FIGHT" in game.screen_text():
			battle_menu_choose(game, "FIGHT")
			game.wait(30)
			game.choose("AMNESIA")
		answer_prompts(game, lambda: out_of_battle(game) or "FIGHT" in game.screen_text())
	assert out_of_battle(game), "didn't black out. The screen:\n" + game.screen_text()
	assert game.peek("wEnemyMonHP", 0, 2) != [0, 0], "the legendary fainted instead"


def saved_event_flag(game, name):
	"""An event flag as the save file holds it: the player data's copy in cartridge RAM."""
	save_bank, save_address = game._address("sPlayerData")
	player_data = game._address("wPlayerData")[1]
	event_flags = game._address("wEventFlags")[1]
	number = constants.event_flags()[name]
	byte = game.pyboy.memory[save_bank, save_address + (event_flags - player_data) + number // 8]
	return bool(byte & (1 << (number % 8)))


def warp_into_scene(game, map_name, x, y):
	"""Warp the way the warp command does, without waiting for the player to stand still: a map
	whose scene starts on entry moves the player straight away."""
	group, number = constants.maps()[map_name]
	for symbol, value in (("wMapGroup", group), ("wMapNumber", number), ("wXCoord", x),
			("wYCoord", y), ("wDefaultSpawnpoint", 0xff), ("hMapEntryMethod", 0xf1),
			("wMapStatus", 1)):
		game.poke(symbol, value)
	game.wait(60)


# The roaming beasts' structs

ROAM_FIELDS = ("Species", "Level", "MapGroup", "MapNumber", "HP", "DVs", "Form")


def roam(game, number):
	"""wRoamMon<number>'s fields, the DVs as two bytes."""
	prefix = "wRoamMon%d" % number
	result = {field: game.peek(prefix + field) for field in ROAM_FIELDS}
	result["DVs"] = tuple(game.peek(prefix + "DVs", 0, 2))
	return result


def set_roam(game, number, **fields):
	prefix = "wRoamMon%d" % number
	for field, value in fields.items():
		if field == "DVs":
			game.poke(prefix + "DVs", value[0])
			game.poke(prefix + "DVs", value[1], 1)
		else:
			game.poke(prefix + field, value)
