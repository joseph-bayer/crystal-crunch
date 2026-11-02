"""Nayru's Pokédex: the entry screen's STAT, MOVES, EVO, AREA and PICS tabs, its options, and the
Pokégear clock card's map line. Every check reads wTilemap or the dex's variables."""

import re

from harness import constants
from harness.data import read
from harness.forms import wait_until
from harness.pokedex import mark, next_page, open_pokedex, open_pokedex_entry, open_tab, page_text

GRASS_ODDS = [30, 30, 20, 10, 5, 4, 1] # data/wild/probabilities.asm
DEXSTATE_UPDATE_OPTION_SCR = 8 # engine/pokedex/pokedex.asm
VBLANK_SERIAL = 4 # constants/ram_constants.asm
DEXCOLOR_BLUE = 1 # constants/ram_constants.asm


def rows(game):
	return [line.strip() for line in game.screen_lines()[9:16]]


def all_pages(game, presses=12):
	"""Each page the tab shows over `presses` presses of A, as text."""
	pages = []
	for _ in range(presses):
		pages.append(page_text(game))
		next_page(game)
	return pages


def move_name(const):
	return const.replace("_", " ").replace("PSYCHIC M", "PSYCHIC").replace("MUD SLAP", "MUD-SLAP") \
		.replace("DOUBLESLAP", "DOUBLESLAP")


def learnset(species):
	"""[(level, move)] from the evos_attacks files."""
	text = read("data/pokemon/evos_attacks_johto.asm") + read("data/pokemon/evos_attacks_kanto.asm")
	block = text.split("%sEvosAttacks:" % species.capitalize())[1]
	block = block.split("db 0 ; no more evolutions")[1].split("db 0 ; no more level-up moves")[0]
	return [(int(l), m) for l, m in re.findall(r"dbw (\d+), (\w+)", block)]


# STAT

def test_stat_page_shows_base_stats_and_total(game):
	open_pokedex_entry(game, "BULBASAUR")
	open_tab(game, "STAT")
	text = page_text(game)
	for stat in ["HP  45", "SPE  45", "ATK  49", "DEF  49", "SPA  65", "SPD  65", "Base Total:  318"]:
		assert stat in text, text


def test_stat_pages_ev_yield_and_gender_ratio(game):
	open_pokedex_entry(game, "BULBASAUR")
	open_tab(game, "STAT")
	pages = all_pages(game, 4)
	assert "SPA 1" in pages[1], pages[1]
	# GENDER_F12_5: one in eight is female, so seven males to one female (Nayru's had 8:1)
	assert "7♂:1♀" in pages[3], pages[3]


def test_wild_held_items_read_as_words(game):
	# Chansey's base data: dw LUCKY_PUNCH, LUCKY_EGG
	open_pokedex_entry(game, "CHANSEY")
	open_tab(game, "STAT")
	text = page_text(game)
	assert "LUCKY PUNCH" in text and "LUCKY EGG" in text, text


# MOVES

def test_level_up_moves_match_the_learnset(game):
	open_pokedex_entry(game, "PIKACHU")
	open_tab(game, "MOVES")
	shown = rows(game)
	for (level, move), row in zip(learnset("PIKACHU")[:7], shown):
		assert row.endswith(move_name(move)) and row.startswith(str(level)), (row, level, move)


def test_egg_moves_come_from_the_first_stage(game):
	text = read("data/pokemon/egg_moves_johto.asm")
	pichu = re.findall(r"dw (\w+)", text.split("PichuEggMoves:")[1].split("dw -1")[0])
	open_pokedex_entry(game, "PIKACHU")
	open_tab(game, "MOVES")
	for _ in range(4):
		if "EGG" in game.screen_lines()[6]:
			break
		next_page(game)
	assert "EGG" in game.screen_lines()[6], game.screen_text()
	assert [r for r in rows(game) if r] == [move_name(m) for m in pichu[:7]]


def machines():
	"""{move: (kind, number)} for the TMs, HMs and tutors, in flag order."""
	text = read("constants/item_constants.asm")
	found, tm, hm, mt = {}, 0, 0, 0
	for kind, move in re.findall(r"^\s*add_(tm|hm|mt) (\w+)", text, re.M):
		if kind == "tm":
			tm += 1
			found[move] = ("TM", tm)
		elif kind == "hm":
			hm += 1
			found[move] = ("HM", hm)
		else:
			mt += 1
			found[move] = ("MT", mt)
	return found


def tmhm_learnset(species):
	text = read("data/pokemon/base_stats/%s.asm" % species.lower())
	return re.search(r"tmhm (.*)", text).group(1).replace(" ", "").split(",")


def test_tm_rows_match_the_learnset(game):
	learnable = set(tmhm_learnset("PIKACHU"))
	expected = ["%s%02d %s" % (k, n, move_name(m)) for m, (k, n) in machines().items()
		if m in learnable and k != "MT"]
	open_pokedex_entry(game, "PIKACHU")
	open_tab(game, "MOVES")
	shown = []
	for _ in range(12):
		if "TECHNICAL" in game.screen_lines()[6]:
			shown += [r for r in rows(game) if r]
		elif shown:
			break
		next_page(game)
	assert shown == expected


FIELD_MOVES = ["TELEPORT", "SOFTBOILED", "MILK_DRINK", "HEADBUTT", "ROCK_SMASH", "SWEET_SCENT", "DIG",
	"CUT", "FLY", "SURF", "STRENGTH", "FLASH", "WATERFALL", "WHIRLPOOL"]


def field_rows(species):
	levels = {m: l for l, m in learnset(species)}
	learnable = set(tmhm_learnset(species))
	expected = []
	for move in FIELD_MOVES:
		if move in levels:
			expected.append("%d %s" % (levels[move], move_name(move)))
		if move in learnable:
			kind, n = machines()[move]
			source = kind if kind == "MT" else "%s%02d" % (kind, n)
			expected.append("%s %s" % (source, move_name(move)))
	return expected


def test_field_moves_page_through_with_their_sources(game):
	"""Regression: Nayru's FIELD list looked up the address of each move rather than the move,
	and gave Waterfall HM06 and Whirlpool HM07. Dragonite has more field rows than a page holds."""
	species = "DRAGONITE"
	expected = field_rows(species)
	assert len(expected) > 7
	open_pokedex_entry(game, species)
	open_tab(game, "MOVES")
	shown = []
	for _ in range(8):
		if "FIELD" in game.screen_lines()[6]:
			shown += [re.sub(r"\s+", " ", r) for r in rows(game) if r]
		elif shown:
			break
		next_page(game)
	assert shown == expected
	assert "HM06 WHIRLPOOL" in shown and "HM07 WATERFALL" in shown


# EVO

def test_evo_page_reads_levels_and_item_words(game):
	"""Regression: the item of an EVOLVE_ITEM row is a word here; read as a byte, it named the
	wrong item and misread every row after it."""
	open_pokedex_entry(game, "SLOWPOKE", others=["SLOWBRO", "SLOWKING"])
	open_tab(game, "EVO")
	text = game.screen_text()
	assert "SLOWBRO" in text and "37" in text, text
	assert "SLOWKING" in text and "KING'S ROCK" in text, text


def test_evo_page_kadabra_level(game):
	open_pokedex_entry(game, "KADABRA", others=["ABRA", "ALAKAZAM"])
	open_tab(game, "EVO")
	text = game.screen_text()
	assert "ALAKAZAM" in text and "42" in text, text


def test_evo_page_hides_unseen_species(game):
	open_pokedex_entry(game, "SLOWPOKE")
	open_tab(game, "EVO")
	text = game.screen_text()
	assert "SLOWBRO" not in text and "SLOWKING" not in text, text
	assert text.count("?????") == 2, text


def test_evo_page_eevee_pages_to_its_last_branches(game):
	open_pokedex_entry(game, "EEVEE", others=["UMBREON"])
	open_tab(game, "EVO")
	assert "UMBREON" not in game.screen_text()
	next_page(game)
	assert "UMBREON" in game.screen_text(), game.screen_text()


# AREA

def grass_odds(map_const, species):
	text = read("data/wild/johto_grass.asm")
	block = text.split("def_grass_wildmons %s\n" % map_const)[1].split("def_grass_wildmons")[0]
	slots = re.findall(r"dbw \d+, (\w+)", block)
	return [sum(o for o, s in zip(GRASS_ODDS, slots[t * 7:t * 7 + 7]) if s == species) for t in range(3)]


def test_area_lists_grass_with_its_odds(game):
	open_pokedex_entry(game, "SENTRET")
	open_tab(game, "AREA")
	lines = game.screen_lines()
	assert "WALKING" in lines[7], game.screen_text()
	row = next(i for i, line in enumerate(lines) if "ROUTE 29" in line)
	assert [int(n) for n in re.findall(r"\d+", lines[row + 1])] == grass_odds("ROUTE_29", "SENTRET")


def test_area_lists_fishing_groups(game):
	open_pokedex_entry(game, "MAGIKARP")
	open_tab(game, "AREA")
	pages = all_pages(game, 10)
	assert any("FISHING" in p and "SHORE" in p for p in pages), pages


def only_wandering():
	"""A species found only in the wanderer tables and populations."""
	elsewhere = ""
	for path in ["data/wild/johto_grass.asm", "data/wild/kanto_grass.asm", "data/wild/johto_water.asm",
			"data/wild/kanto_water.asm", "data/wild/fish.asm", "data/wild/treemons.asm",
			"data/wild/bug_contest_mons.asm"]:
		elsewhere += read(path)
	found = set(re.findall(r"\b([A-Z][A-Z0-9_]+)\b", elsewhere))
	wanderers = re.findall(r"ow_wildmon\s+\d+,\s*(\w+)", read("data/wild/overworld_mons.asm"))
	return next(w for w in wanderers if w not in found)


def test_area_lists_wandering_species(game):
	species = only_wandering()
	open_pokedex_entry(game, species)
	open_tab(game, "AREA")
	assert "WANDERING" in game.screen_lines()[6], (species, game.screen_text())


def test_area_hides_secret_places(game):
	# Bulbasaur's population is on the Hidden Grove, a Mystery Island
	open_pokedex_entry(game, "BULBASAUR")
	open_tab(game, "AREA")
	pages = all_pages(game, 6)
	assert not any("GROVE" in p or "SPECIAL" in p for p in pages), pages


LOCKED_MON_ID_DEX_SELECTED = constants._consts(constants.ROOT / "constants" / "16_bit_locking_constants.asm")[
	"LOCKED_MON_ID_DEX_SELECTED"]


def locked_ids(game):
	"""The species each locked slot holds, but the one the Pokédex locks for its selected mon."""
	count = symbol("wPokemonIndexTableLastAllocated") - symbol("wPokemonIndexTableLockedEntries")
	locked = game.peek("wPokemonIndexTableLockedEntries", 0, count)
	return [(slot, i, game.peek("wPokemonIndexTableEntries", (i - 1) * 2, 2))
		for slot, i in enumerate(locked) if i and slot != LOCKED_MON_ID_DEX_SELECTED]


def test_area_pages_allocate_no_ids(game):
	"""The AREA page compares 16-bit indexes rather than converting every table entry to an ID,
	which filled the ID table and evicted IDs held elsewhere."""
	open_pokedex_entry(game, "MAGIKARP")
	open_tab(game, "AREA")
	used = game.peek("wPokemonIndexTableUsedSlots")
	locked = locked_ids(game)
	all_pages(game, 25)
	assert game.peek("wPokemonIndexTableUsedSlots") == used
	assert locked_ids(game) == locked


# PICS, options and saving

def test_shiny_toggle_is_kept(game):
	open_pokedex_entry(game, "BULBASAUR")
	game.press("select", after=120)
	assert game.peek("wPokedexShinyToggle") == 1
	assert game.peek("wPokedexDisplayForm") & 0x80 # SHINY_MASK
	for _ in range(2):
		game.press("b", after=200)
	wait_until(game, lambda: "PACK" in game.screen_text(), "the START menu", timeout=600)
	assert game.peek("wPokedexShinyToggle") == 1


def symbol(name):
	for line in open(str(constants.ROOT / "pokecrystal_test.sym"), encoding="utf-8"):
		parts = line.split()
		if len(parts) == 2 and parts[1] == name:
			return int(parts[0].split(":")[1], 16)
	raise KeyError(name)


def test_shiny_toggle_and_color_are_saved_options():
	start, end = symbol("wOptions"), symbol("wOptionsEnd")
	for name in ("wPokedexShinyToggle", "wCurPokedexColor"):
		assert start <= symbol(name) < end, name


def open_options(game):
	open_pokedex(game)
	game.press("select", after=120)
	wait_until(game, lambda: game.peek("wJumptableIndex") == DEXSTATE_UPDATE_OPTION_SCR,
		"the Pokédex options", timeout=300)


def test_color_picker(game):
	mark(game, "BULBASAUR")
	open_options(game)
	game.choose("COLOR")
	game.wait_for_text("BLUE")
	game.choose("BLUE")
	game.wait(120)
	assert game.peek("wCurPokedexColor") == DEXCOLOR_BLUE


def test_print_row_reaches_the_printer(game):
	mark(game, "BULBASAUR")
	open_options(game)
	game.choose("PRINT ENTRY")
	wait_until(game, lambda: game.peek("hVBlank") == VBLANK_SERIAL, "the printer's serial VBlank",
		timeout=600)


def test_pics_page_shiny_toggle(game):
	open_pokedex_entry(game, "BULBASAUR")
	open_tab(game, "PICS")
	game.wait(300)
	game.press("select", after=200)
	assert game.peek("wPokedexShinyToggle") == 1
	assert game.peek("wPokedexDisplayForm") == 0x80


# Tab wrap, and buttons that don't wait for the cry or animation

def tab(game):
	return game.peek("wDexArrowCursorPosIndex")


def test_tab_cursor_wraps_between_info_and_pics(game):
	open_pokedex_entry(game, "BULBASAUR")
	assert tab(game) == 0
	game.press("left", after=20)
	assert tab(game) == 5 # PICS
	game.press("right", after=20)
	assert tab(game) == 0 # INFO
	game.press("right", after=20)
	assert tab(game) == 1


def test_option_cursor_stops_at_its_ends(game):
	mark(game, "BULBASAUR")
	open_options(game)
	assert tab(game) == 0
	game.press("up", after=20)
	assert tab(game) == 0


def pics_animating(game):
	return game.peek("wPokedexPageFlags") & 1 << 6


def pics_loop_animating(game):
	"""The PICS page's loop is running its animation: bit 6 stays set until the last step, and the
	first step clears bit 5."""
	return game.peek("wPokedexPageFlags") & (1 << 6 | 1 << 5) == 1 << 6


def test_pics_page_reads_buttons_while_animating(game):
	open_pokedex_entry(game, "BULBASAUR")
	game.press("left", after=20)
	game.press("a", after=1)
	wait_until(game, lambda: pics_loop_animating(game), "the front pic's animation", timeout=120)
	game.press("select", after=10)
	assert game.peek("wPokedexShinyToggle") == 1
	assert pics_animating(game)
	wait_until(game, lambda: not pics_animating(game), "the animation's end", timeout=600)


def crying(game):
	return game.peek("wChannel5Flags1") & 1 # SOUND_CHANNEL_ON


def test_entry_screen_reads_buttons_during_the_cry(game):
	open_pokedex_entry(game, "BULBASAUR", others=["IVYSAUR"])
	game.press("down", after=30)
	assert "IVYSAUR" in game.screen_text()
	assert crying(game)
	game.press("right", after=10)
	assert tab(game) == 1

def test_clock_card_shows_place_fish_group_and_time(game):
	game.warp("ROUTE_30", 9, 20)
	game.poke("wPokegearFlags", 1 << 7)
	game.press("start", after=40)
	game.choose("GEAR")
	game.wait_for_text("ROUTE 30")
	text = game.screen_text()
	assert "FISH: POND" in text, text # data/maps/maps.asm: Route 30 fishes FISHGROUP_POND
	assert ("MORN", "DAY", "NITE", "EVE")[game.peek("wTimeOfDay")] in text, text


# Seen versus caught

def test_seen_species_shows_everything_but_the_flavor_text(game):
	open_pokedex_entry(game, "BULBASAUR", caught=False)
	assert "While it is young" not in game.screen_text(), game.screen_text()
	open_tab(game, "STAT")
	assert "HP  45" in page_text(game), page_text(game)
