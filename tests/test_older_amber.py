"""The Older Amber and the Gen 1 tutor: Old Amber Guy in the Pewter Museum gives the Older Amber
once; the fossil scientist in the Ruins of Alph revives it as a level-50 RB Aerodactyl; showing
him an RB Aerodactyl unlocks his tutoring for good, and he teaches Red/Blue and beta forms the
Gen 1 TM moves their species learned in Red/Blue, for ¥10000 a move, charged only once learned."""

import re

import pytest

from harness import alt_shiny as A
from harness import constants
from harness.forms import form_constant, party_field
from test_moped import has_key_item, give_key_items
from test_rb_forms import party_stat

MUSEUM = "MUSEUM_1F"
OLD_AMBER_GUY = (15, 3) # below him, facing up
LAB = "RUINS_OF_ALPH_RESEARCH_CENTER"
FOSSIL_SCIENTIST = (7, 3)
PRICE = 10000
NUM_MOVES = 4


def script_done(game):
	return game.peek("wScriptRunning") == 0 and game.peek("wWindowStackSize") == 0


def read_through(game, button="a", limit=80):
	"""Press `button` until the script ends; returns everything the screen showed. B also answers
	NO to a yes/no question."""
	seen = []
	for _ in range(limit):
		game.wait(20)
		seen.append(game.screen_text())
		if script_done(game):
			return "\n".join(seen)
		game.press(button)
	raise AssertionError("the script never ended. The screen:\n" + game.screen_text())


def press_until(game, text, limit=40):
	"""Press A through the text until `text` shows."""
	for _ in range(limit):
		game.wait(20)
		if text in game.screen_text():
			game.wait(30)
			return
		game.press("a")
	raise AssertionError("%r never showed. The screen:\n%s" % (text, game.screen_text()))


def talk_to(game, map_name, spot):
	game.warp(map_name, *spot)
	game.press("up")
	game.press("a")


def flag(game, name):
	return game.event_flag(name)


def money(game):
	return game.peek("wMoney") << 16 | game.peek("wMoney", 1) << 8 | game.peek("wMoney", 2)


def set_money(game, value):
	for i in range(3):
		game.poke("wMoney", value >> (16 - 8 * i) & 0xff, i)


def give_mon(game, species, form, name, level=50):
	"""GivePoke with a one-letter nickname and OT, so it asks nothing. Returns the party slot."""
	_, tilemap = game._address("wTilemap")
	base = tilemap + 0x200
	text = base + 4
	letter = 0x80 + ord(name) - ord("A")
	for i, byte in enumerate([text & 0xff, text >> 8, text & 0xff, text >> 8, letter, 0x50, 0]):
		game.poke("wTilemap", byte, 0x200 + i)
	game.poke("wScriptBank", 1)
	game.poke("wCurPartySpecies", A.species_id(game, species))
	game.poke("wCurPartyLevel", level)
	game.poke("wCurItem", 0)
	game.poke("wForm", form)
	# A.call leaves the CPU parked, so it runs on a copy: the new party and the 16-bit ID tables
	# (WRAM bank 2) are carried back into the game, which then goes on as before.
	state = game.save_state()
	A.call(game, "GivePoke", bc=0x0100, de=base)
	bank, start = game._address("wPartyCount")
	_, end = game._address("wPartyMonNicknamesEnd")
	party = [game.pyboy.memory[bank, a] for a in range(start, end)]
	tables = [game.pyboy.memory[2, a] for a in range(0xd000, 0xe000)]
	game.load_state(state)
	for i, byte in enumerate(party):
		game.pyboy.memory[bank, start + i] = byte
	for i, byte in enumerate(tables):
		game.pyboy.memory[2, 0xd000 + i] = byte
	return game.peek("wPartyCount") - 1


def move_id(game, name):
	return A._table_id(game, "wMoveIndexTable", move_index(name))


def move_index(name):
	return constants._consts(constants.ROOT / "constants" / "move_constants.asm")[name]


def set_moves(game, slot, *names):
	ids = [move_id(game, name) for name in names] + [0] * (NUM_MOVES - len(names))
	for i, value in enumerate(ids):
		set_party_field_at(game, slot, "Moves", i, value)


def set_party_field_at(game, slot, field, offset, value):
	length = game._address("wPartyMon2")[1] - game._address("wPartyMon1")[1]
	game.poke("wPartyMon1" + field, value, slot * length + offset)


def party_moves(game, slot):
	length = game._address("wPartyMon2")[1] - game._address("wPartyMon1")[1]
	ids = game.peek("wPartyMon1Moves", slot * length, NUM_MOVES)
	entries = game.peek("wMoveIndexTableEntries", 0, 2 * 230)
	return [entries[(i - 1) * 2] | entries[(i - 1) * 2 + 1] << 8 if i else 0 for i in ids]


def gen1_tutor_moves():
	text = (constants.ROOT / "data" / "pokemon" / "rb_tutor_moves.asm").read_text(encoding="utf-8")
	return re.findall(r"^\tgen1_tutor_move (\w+)", text, re.M)


def gen1_learnset(species):
	text = (constants.ROOT / "data" / "pokemon" / "rb_tutor_moves.asm").read_text(encoding="utf-8")
	row = re.search(r"^\tgen1_tutor_learnset %s((?:, \w+)*)\s*$" % species, text, re.M)
	return [m.strip() for m in row.group(1).split(",") if m.strip()]


def tutor_list(game):
	count = game.peek("wGen1TutorMoveCount")
	return game.peek("wGen1TutorMoves", 0, count) if count else []


# The Older Amber

def test_old_amber_guy_gives_the_older_amber_once(game):
	assert not has_key_item(game, "OLDER_AMBER")
	talk_to(game, MUSEUM, OLD_AMBER_GUY)
	said = read_through(game)
	assert "AMBER is older" in said
	assert has_key_item(game, "OLDER_AMBER")
	assert flag(game, "EVENT_GOT_OLDER_AMBER")

	talk_to(game, MUSEUM, OLD_AMBER_GUY)
	said = read_through(game)
	assert "resurrected from" in said and "the OLDER AMBER" in said, "with no RB Aerodactyl to show, he waits"
	assert "AMBER is older" not in said, "he gives it once"
	assert not flag(game, "EVENT_SHOWED_RB_AERODACTYL")


def test_the_amber_on_show_goes_with_the_older_amber(game):
	# The amber on the pedestal beside him is the Older Amber, so it goes when he hands it over
	from harness.overworld import struct_for_object
	game.warp(MUSEUM, *OLD_AMBER_GUY)
	assert game.object_shown("Museum1F", "MUSEUM1F_OLD_AMBER")
	assert struct_for_object(game, "Museum1F", "MUSEUM1F_OLD_AMBER") is not None
	talk_to(game, MUSEUM, OLD_AMBER_GUY)
	read_through(game)
	assert has_key_item(game, "OLDER_AMBER")
	assert not game.object_shown("Museum1F", "MUSEUM1F_OLD_AMBER")
	assert struct_for_object(game, "Museum1F", "MUSEUM1F_OLD_AMBER") is None, "it should leave the pedestal at once"

	game.warp("PEWTER_CITY", 15, 8)
	game.warp(MUSEUM, *OLD_AMBER_GUY)
	assert not game.object_shown("Museum1F", "MUSEUM1F_OLD_AMBER"), "it stays gone"


def test_scientist_revives_the_older_amber_as_a_level_50_rb_aerodactyl(game):
	give_key_items(game, "OLDER_AMBER")
	game.set_event_flag("EVENT_GOT_OLDER_AMBER")
	game.set_event_flag("EVENT_MET_HIDDEN_POWER_SHAMAN") # her first-visit scene
	count = game.peek("wPartyCount")
	talk_to(game, LAB, FOSSIL_SCIENTIST)
	press_until(game, "fossil for me?")
	game.press("a")
	game.choose("OLDER AMBER")
	read_through(game)
	assert not has_key_item(game, "OLDER_AMBER"), "he takes the amber"
	assert flag(game, "EVENT_GAVE_SCIENTIST_OLDER_AMBER")

	game.warp("RUINS_OF_ALPH_OUTSIDE", 17, 16) # the revival takes a map reload
	talk_to(game, LAB, FOSSIL_SCIENTIST)
	read_through(game, "b") # B: no nickname
	assert game.peek("wPartyCount") == count + 1
	slot = count
	assert game.peek("wPartySpecies", slot) == A.species_id(game, "AERODACTYL")
	assert party_field(game, slot, "Form") & 0x1f == form_constant("AERODACTYL_RB_FORM")
	assert party_field(game, slot, "Level") == 50
	assert party_stat(game, slot, "SpclAtk") == party_stat(game, slot, "SpclDef"), "one Special"
	assert not flag(game, "EVENT_GAVE_SCIENTIST_OLDER_AMBER")


def test_scientist_keeps_the_older_amber_a_surprise(game):
	game.set_event_flag("EVENT_MET_HIDDEN_POWER_SHAMAN")
	talk_to(game, LAB, FOSSIL_SCIENTIST)
	press_until(game, "fossil for me?")
	game.press("a")
	game.wait_for_text("CANCEL")
	assert "OLDER AMBER" not in game.screen_text(), "not before Old Amber Guy gives it"
	assert "HELIX FOSSIL" in game.screen_text()
	game.choose("CANCEL")
	said = read_through(game)
	assert "bad!" in said, "CANCEL, the 4th entry here, still cancels" # "No? That's too bad!"
	assert not flag(game, "EVENT_GAVE_SCIENTIST_OLDER_AMBER")


# Unlocking the tutor

def test_showing_rb_aerodactyl_unlocks_the_tutor_for_good(game):
	game.set_event_flag("EVENT_GOT_OLDER_AMBER")
	count = game.peek("wPartyCount")
	give_mon(game, "AERODACTYL", 0, "P")
	talk_to(game, MUSEUM, OLD_AMBER_GUY)
	said = read_through(game, "b")
	assert "the OLDER AMBER" in said, "a plain Aerodactyl doesn't count"
	assert not flag(game, "EVENT_SHOWED_RB_AERODACTYL")

	give_mon(game, "AERODACTYL", form_constant("AERODACTYL_RB_FORM"), "R")
	talk_to(game, MUSEUM, OLD_AMBER_GUY)
	said = read_through(game, "b") # B: no to the offer
	assert "That AERODACTYL!" in said
	assert "lost moves to" in said
	assert "change your mind" in said
	assert flag(game, "EVENT_SHOWED_RB_AERODACTYL")

	game.poke("wPartyCount", count) # it's gone; the unlock stays
	game.poke("wPartySpecies", 0xff, count)
	talk_to(game, MUSEUM, OLD_AMBER_GUY)
	said = read_through(game, "b")
	assert "That AERODACTYL!" not in said
	assert "lost moves to" in said


# The tutor

def open_tutor(game):
	game.set_event_flag("EVENT_GOT_OLDER_AMBER")
	game.set_event_flag("EVENT_SHOWED_RB_AERODACTYL")
	talk_to(game, MUSEUM, OLD_AMBER_GUY)
	press_until(game, "teach one?")
	game.choose("YES")
	game.wait_for_text("Teach which")


def tutor_party(game):
	plain = give_mon(game, "GENGAR", 0, "P")
	rb = give_mon(game, "GENGAR", form_constant("GENGAR_RB_FORM"), "R")
	set_moves(game, rb, "LICK")
	return plain, rb


def test_tutor_teaches_an_rb_mon_and_charges_once_its_learned(game):
	plain, rb = tutor_party(game)
	set_money(game, 12345)
	open_tutor(game)
	lines = game.screen_lines()
	row = next(i for i, line in enumerate(lines) if re.search(r"(?<![A-Za-z])P(?![A-Za-z])", line))
	assert "NOT ABLE" in lines[row + 1], "the plain Gengar isn't able" # under its name
	row = next(i for i, line in enumerate(lines) if re.search(r"(?<![A-Za-z])R(?![A-Za-z])", line))
	assert "ABLE" in lines[row + 1] and "NOT ABLE" not in lines[row + 1], "the RB Gengar is able"

	game.choose("P")
	game.wait_for_text("RED/BLUE-era")
	press_until(game, "Teach which")

	game.choose("R")
	game.wait_for_text("Teach which move?")
	names = gen1_tutor_moves()
	expected = [i for i, name in enumerate(names) if name in gen1_learnset("GENGAR")]
	assert tutor_list(game) == expected, "Gengar's Red/Blue TM moves, none of them known"
	first = names[expected[0]]
	game.press("a")
	game.wait_for_text("for ")
	game.choose("YES")
	read_through(game)
	assert move_index(first) in party_moves(game, rb)
	assert money(game) == 12345 - PRICE


def test_tutor_hides_known_moves(game):
	plain, rb = tutor_party(game)
	names = gen1_tutor_moves()
	learnset = gen1_learnset("GENGAR")
	set_moves(game, rb, "LICK", learnset[0], learnset[1])
	A.call(game, "CountGen1TutorMoves", a=rb)
	assert [names[i] for i in tutor_list(game)] == learnset[2:]


FRAME_TILES = range(0xba, 0xc0) # a text box's corners and edges


def tilemap_rows(game, first, last):
	return [list(game.peek("wTilemap", row * 20, 20)) for row in range(first, last + 1)]


def test_tutor_move_list_leaves_no_frame_behind(game):
	# The list's frame is drawn a tile outside its menu box. With the box at the screen's right
	# edge it wrapped onto column 0, and closing the list left the frame over the party menu.
	plain, rb = tutor_party(game)
	set_money(game, 50000)
	open_tutor(game)
	party = tilemap_rows(game, 0, 6)
	game.choose("R")
	game.wait_for_text("Teach which move?")
	game.wait(30)
	for row, tiles in enumerate(tilemap_rows(game, 0, 14)):
		assert tiles[0] not in FRAME_TILES, "the list's frame wrapped onto column 0, row %d" % row
	game.press("a")
	game.wait_for_text("for ")
	game.wait(30)
	for row, (before, after) in enumerate(zip(party, tilemap_rows(game, 0, 6))):
		assert after[1:] == before[1:], "row %d should be the party menu again" % row


def test_tutor_cancel_costs_nothing(game):
	plain, rb = tutor_party(game)
	set_money(game, 12345)
	open_tutor(game)
	game.choose("R")
	game.wait_for_text("Teach which move?")
	game.press("b") # out of the move list
	game.wait_for_text("Teach which")
	said = read_through(game, "b") # out of the party menu
	assert "change your mind" in said
	assert money(game) == 12345
	assert party_moves(game, rb) == [move_index("LICK"), 0, 0, 0]


def test_tutor_needs_the_money_first(game):
	plain, rb = tutor_party(game)
	set_money(game, PRICE - 1)
	open_tutor(game)
	game.choose("R")
	game.wait_for_text("Teach which move?")
	game.press("a")
	game.wait_for_text("for ")
	game.choose("YES")
	said = read_through(game)
	assert "enough money" in said
	assert money(game) == PRICE - 1
	assert party_moves(game, rb) == [move_index("LICK"), 0, 0, 0]


@pytest.mark.parametrize("species, form, relative", [
	("CROBAT", "CROBAT_BETA_FORM", "GOLBAT"),
	("KINGDRA", "KINGDRA_BETA_FORM", "SEADRA"),
	("PICHU", "PICHU_BETA_FORM", "PIKACHU"),
	("IGGLYBUFF", "IGGLYBUFF_BETA_FORM", "JIGGLYPUFF"),
])
def test_beta_forms_use_their_relatives_list(game, species, form, relative):
	names = gen1_tutor_moves()
	beta = give_mon(game, species, form_constant(form), "B")
	set_moves(game, beta)
	assert A.call(game, "CountGen1TutorMoves", a=beta)["a"] == len(gen1_learnset(relative))
	assert [names[i] for i in tutor_list(game)] == [m for m in names if m in gen1_learnset(relative)]
	plain = give_mon(game, species, 0, "P")
	assert A.call(game, "CountGen1TutorMoves", a=plain)["a"] == 0, "a plain form can't learn them"


def test_rb_aerodactyl_has_a_tutor_list(game):
	assert gen1_learnset("AERODACTYL"), "RB Aerodactyl should have Gen 1 tutor moves"
	slot = give_mon(game, "AERODACTYL", form_constant("AERODACTYL_RB_FORM"), "R")
	set_moves(game, slot)
	assert A.call(game, "CountGen1TutorMoves", a=slot)["a"] == len(gen1_learnset("AERODACTYL"))
