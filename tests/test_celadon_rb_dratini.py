"""The Celadon Game Corner's Red/Blue Dratini prize: 9900 coins for a Lv 25 RB Dratini.

The Pokémon menu holds five rows, too tall to leave room for the coin box at the top of the screen,
so the menu shows the balance in its own top row. A prize new to the Pokédex shows its entry in
the form it's given in: the RB Dratini's in its RB form, the others plain."""

import re

from harness import alt_shiny as A
from harness.forms import form_constant, party_field
from test_blackjack import coins, give_coin_case, set_coins
from test_older_amber import press_until, script_done
from test_rb_forms import party_stat

PRIZE_ROOM = "CELADON_GAME_CORNER_PRIZE_ROOM"
BELOW_POKEMON_VENDOR = (4, 2) # the Pokémon counter is at (4, 1)
MAX_COINS = 9999


def prize_coins(name):
	"""A prize's price, from the map's CELADONGAMECORNERPRIZEROOM_<name>_COINS."""
	from harness import data
	text = data.read("maps/CeladonGameCornerPrizeRoom.asm")
	return int(re.search(r"^DEF CELADONGAMECORNERPRIZEROOM_%s_COINS\s+EQU (\d+)" % name, text, re.M).group(1))


RB_DRATINI_COINS = prize_coins("RB_DRATINI")
PIKACHU_COINS = prize_coins("PIKACHU")


def open_pokemon_menu(game, amount):
	give_coin_case(game)
	set_coins(game, amount)
	game.warp(PRIZE_ROOM, *BELOW_POKEMON_VENDOR)
	game.press("up")
	game.press("a")
	press_until(game, "RB DRATINI")


def buy(game, row):
	"""Buy the prize on `row`, say NO to a nickname, then leave the menu. Returns every
	wPokedexViewForm seen while the script ran."""
	game.choose(row)
	press_until(game, "YES")
	game.choose("YES")
	views = set()
	for _ in range(120):
		game.wait(20)
		views.add(game.peek("wPokedexViewForm"))
		if script_done(game):
			return views
		game.press("b") # B: past the text and the Pokédex entry, NO to a nickname, then out of the menu
	raise AssertionError("the purchase never ended. The screen:\n" + game.screen_text())


def test_menu_lists_five_rows_and_the_balance(game):
	open_pokemon_menu(game, 1234)
	text = game.screen_text()
	for row in ("PIKACHU", "WOBBUFFET", "LARVITAR", "RB DRATINI", "CANCEL"):
		assert row in text, row
	assert "COIN 1234" in text, "the balance, inside the menu:\n" + text


def test_rb_dratini_costs_its_price(game):
	count = game.peek("wPartyCount")
	open_pokemon_menu(game, MAX_COINS)
	views = buy(game, "RB DRATINI")
	assert coins(game) == MAX_COINS - RB_DRATINI_COINS
	assert game.peek("wPartyCount") == count + 1
	slot = count
	assert game.peek("wPartySpecies", slot) == A.species_id(game, "DRATINI")
	assert party_field(game, slot, "Form") & 0x1f == form_constant("DRATINI_RB_FORM")
	assert party_field(game, slot, "Level") == 25
	assert party_stat(game, slot, "SpclAtk") == party_stat(game, slot, "SpclDef"), "one Special"
	assert form_constant("DRATINI_RB_FORM") in views, "its new Pokédex entry shows the RB form"


def test_rb_dratini_needs_its_whole_price(game):
	count = game.peek("wPartyCount")
	open_pokemon_menu(game, RB_DRATINI_COINS - 1)
	game.choose("RB DRATINI")
	for _ in range(60):
		game.wait(20)
		if script_done(game):
			break
		game.press("b")
	assert coins(game) == RB_DRATINI_COINS - 1
	assert game.peek("wPartyCount") == count


def test_pikachu_is_still_the_first_row_and_plain(game):
	count = game.peek("wPartyCount")
	open_pokemon_menu(game, MAX_COINS)
	views = buy(game, "PIKACHU")
	assert coins(game) == MAX_COINS - PIKACHU_COINS
	assert game.peek("wPartySpecies", count) == A.species_id(game, "PIKACHU")
	assert party_field(game, count, "Form") & 0x1f == 0
	assert views == {0}, "its new Pokédex entry shows the plain form"


def prize_menu_rows(text):
	"""[(menu row as shown, room it has)] for every static menu in a Game Corner map's text: a row
	starts two tiles in from the left border (the border, then the cursor) and must end before the
	right one."""
	import re
	values = {name: int(value) for name, value in re.findall(r"^DEF (\w+)\s+EQU (\d+)", text, re.M)}
	rows, coords, in_items = [], None, False
	for line in text.splitlines():
		code = line.split(";")[0].strip()
		m = re.match(r"menu_coords (\d+), \w+, (\d+),", code)
		if m:
			coords, in_items = (int(m.group(1)), int(m.group(2))), False
			continue
		if re.match(r"db \d+$", code) and coords and "items" in line:
			in_items = True
			continue
		m = re.match(r'db "([^"]*)@"$', code)
		if in_items and m:
			shown = re.sub(r"\{d:(\w+)\}", lambda d: str(values[d.group(1)]), m.group(1))
			rows.append((shown, coords[1] - coords[0] - 2))
		elif in_items and not code.startswith("db"):
			in_items = False
	return rows


def test_every_prize_row_fits_its_menu():
	"""Celadon's WOBBUFFET row once ran two tiles past the border, and Goldenrod's PORYGON and
	DRATINI rows one tile onto it."""
	from harness import data
	rows = []
	for map_file in ("CeladonGameCornerPrizeRoom", "GoldenrodGameCorner"):
		rows += prize_menu_rows(data.read("maps/%s.asm" % map_file))
	assert len(rows) >= 12, rows
	assert [(shown, room) for shown, room in rows if len(shown) > room] == []


def test_wobbuffets_price_lines_up(game):
	open_pokemon_menu(game, 1234)
	lines = game.screen_lines()
	columns = {row: next(line.index(price) for line in lines if row in line)
		for row, price in (("PIKACHU", str(PIKACHU_COINS)), ("WOBBUFFET", str(prize_coins("WOBBUFFET"))),
			("LARVITAR", str(prize_coins("LARVITAR"))), ("RB DRATINI", str(RB_DRATINI_COINS)))}
	assert len(set(columns.values())) == 1, columns
