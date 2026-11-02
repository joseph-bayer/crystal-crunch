"""Forms and alternate shinies in the Pokédex: the record of the ones met (set where a species is
marked seen or caught), the PICS page showing only those, and the record's own copy in the save.
Every check reads the record, wTilemap or the dex's variables."""


import pytest

from harness import Game, rom_path
from harness import alt_shiny as A
from harness import dex_forms as D
from harness.data import global_constants
from harness.forms import (EGG, answer_prompts, out_of_battle, party_field, set_party_field,
	shorten_party, super_nerd_menu, take_radio_items, throw_ball, wait_for_battle_menu, wait_until)
from harness.pokedex import open_pokedex_entry, open_tab
from test_old_saves import SAVES, continue_game

SCYTHER_FOREST_GREEN = D.form_constant("SCYTHER_FOREST_GREEN_FORM")
SCYTHER_TEAL = D.form_constant("SCYTHER_TEAL_FORM")
GYARADOS_XS = D.form_constant("GYARADOS_XS_FORM")
GYARADOS_RB = D.form_constant("GYARADOS_RB_FORM")

SCIZOR_DUSTY_ROSE = D.form_constant("SCIZOR_DUSTY_ROSE_FORM")

# Eggs count down one cycle every 256 steps, on the step that brings the counter to $80
# (tests/test_hatching.py).
STEP_BEFORE_EGG_CYCLE = 0x7f
EVOLUTION_FRAMES = 3000

SCYTHER_TEAL_PAL = "gfx/pokemon/scyther_teal/normal.pal"
SCYTHER_SHINY_PAL = "gfx/pokemon/scyther/shiny.pal"
SCYTHER_ALT_PAL = "gfx/pokemon/scyther/alt_shiny.pal"

# Frames for the PICS page to draw and run its pic's animation before it takes a button
PICS_SETTLE = 400


def bg_palette_pairs(game):
	"""Colors 1 and 2 of each of the eight background palettes, as last applied."""
	data = game.peek("wBGPals2", 0, 64)
	return [[data[p * 8 + 2] | data[p * 8 + 3] << 8, data[p * 8 + 4] | data[p * 8 + 5] << 8]
		for p in range(8)]


def wild_battle(game, species, form, room=False):
	"""The debug Super Nerd's WILD MEW, turned into `species` with form byte `form` (not 0) before
	the enemy loads, as tests/test_alt_shiny.py does. The debug radio gives the party first."""
	take_radio_items(game)
	if room:
		shorten_party(game, 5) # room for a catch
	D.clear_record(game) # the radio's debug PC fill has met nearly everything
	super_nerd_menu(game, "HP BATTLES", "WILD MEW")
	assert game.peek("wBattleMode") == 0, "the battle shouldn't have loaded its enemy yet"
	species_id = A.species_id(game, species)
	for symbol in ("wTempWildMonSpecies", "wTempEnemyMonSpecies", "wCurPartySpecies"):
		game.poke(symbol, species_id)
	game.poke("wTempWildMonForm", form)
	wait_until(game, lambda: game.peek("wBattleMode") == 1, "the wild battle")
	wait_for_battle_menu(game)
	assert game.peek("wEnemyMonForm") == form


def open_pics(game, species, **kwargs):
	open_pokedex_entry(game, species, **kwargs)
	open_tab(game, "PICS")
	game.wait(PICS_SETTLE)


def press(game, button):
	game.press(button, after=PICS_SETTLE)


X_FLIP = 1 << 5


def form_label(game):
	"""The PICS page's form label, right of the icon box. Its ◀ is a ▶ the attrmap flips."""
	label = game.screen_lines()[D.PICS_FORM_LABEL_ROW][6:].strip()
	flipped = game.peek("wAttrmap", D.PICS_FORM_LABEL_ROW * D.SCREEN_WIDTH + 11) & X_FLIP
	if label and flipped and label[5] == "▶":
		label = label[:5] + "◀" + label[6:]
	return label


# Recording

def test_wild_form_is_recorded_seen(game):
	wild_battle(game, "SCYTHER", SCYTHER_TEAL)
	assert D.set_flags(game) == [("wDexFormsSeen", D.form_flag("SCYTHER", SCYTHER_TEAL))]


def test_caught_form_is_recorded_caught(game):
	wild_battle(game, "SCYTHER", SCYTHER_TEAL, room=True)
	throw_ball(game, "MASTER BALL")
	answer_prompts(game, lambda: out_of_battle(game), timeout=400)
	teal = D.form_flag("SCYTHER", SCYTHER_TEAL)
	assert D.set_flags(game) == [("wDexFormsSeen", teal), ("wDexFormsCaught", teal)]


def test_alternate_shiny_is_recorded_seen(game):
	wild_battle(game, "SCYTHER", D.SHINY_MASK | D.ALT_SHINY_MASK)
	assert D.set_flags(game) == [("wDexAltShiniesSeen", D.alt_flag("SCYTHER"))]


def test_alternate_shiny_form_records_both(game):
	wild_battle(game, "SCYTHER", D.SHINY_MASK | D.ALT_SHINY_MASK | SCYTHER_FOREST_GREEN)
	assert D.set_flags(game) == [("wDexFormsSeen", D.form_flag("SCYTHER", SCYTHER_FOREST_GREEN)),
		("wDexAltShiniesSeen", D.alt_flag("SCYTHER"))]


@pytest.mark.parametrize("species, form", [
	("SCYTHER", D.SHINY_MASK), # an ordinary shiny
	("SCYTHER", D.ALT_SHINY_MASK), # the alternate bit without the shiny one draws plain
	("MEW", D.SHINY_MASK | D.ALT_SHINY_MASK), # a species without an alternate
])
def test_nothing_else_is_recorded(game, species, form):
	wild_battle(game, species, form)
	assert D.set_flags(game) == []


def test_an_egg_given_by_script_records_nothing(game):
	"""GiveEgg adds the egg's Pokémon to the party as if met, then takes the species flags back; the
	forms record mustn't keep it either."""
	shorten_party(game, 5)
	game.poke("wCurPartySpecies", A.species_id(game, "SCYTHER"))
	game.poke("wCurPartyLevel", 5)
	game.poke("wEnemyMonForm", SCYTHER_TEAL)
	A.call(game, "GiveEgg")
	assert game.peek("wPartyCount") == 6, "the egg should have joined"
	assert D.set_flags(game) == []


def test_hatched_form_is_recorded_caught(game):
	take_radio_items(game)
	D.clear_record(game)
	scyther = A.species_id(game, "SCYTHER")
	# Party slot 1 an egg one cycle from hatching, a Teal Scyther inside
	game.poke("wPartySpecies", EGG, 0)
	set_party_field(game, 0, "Species", scyther)
	set_party_field(game, 0, "Form", SCYTHER_TEAL)
	set_party_field(game, 0, "Happiness", 1)
	game.poke("wStepCount", STEP_BEFORE_EGG_CYCLE)
	game.step("down")
	answer_prompts(game, lambda: game.peek("wPartySpecies", 0) != EGG
		and game.peek("wScriptRunning") == 0 and game.peek("wWindowStackSize") == 0)
	assert game.peek("wPartySpecies", 0) == scyther
	teal = D.form_flag("SCYTHER", SCYTHER_TEAL)
	assert D.set_flags(game) == [("wDexFormsSeen", teal), ("wDexFormsCaught", teal)]


def test_evolved_form_is_recorded_caught(game):
	take_radio_items(game)
	D.clear_record(game)
	scyther = A.species_id(game, "SCYTHER")
	game.poke("wPartySpecies", scyther)
	set_party_field(game, 0, "Species", scyther)
	set_party_field(game, 0, "Form", SCYTHER_TEAL)
	game.poke("wCurItem", A.item_id(game, "METAL_COAT"))
	game.poke("wForceEvolution", 1)
	game.poke("wCurPartyMon", 0)
	A.call(game, "EvolvePokemon", press_a_every=30, must_return=False, frames=EVOLUTION_FRAMES)
	assert party_field(game, 0, "Species") == A.species_id(game, "SCIZOR"), "Scyther should have evolved"
	dusty_rose = D.form_flag("SCIZOR", SCIZOR_DUSTY_ROSE)
	assert D.set_flags(game) == [("wDexFormsSeen", dusty_rose), ("wDexFormsCaught", dusty_rose)]


def test_traded_form_is_recorded_caught(game):
	"""A link trade puts the received mon in the party with AddTempmonToParty."""
	take_radio_items(game)
	shorten_party(game, 5)
	D.clear_record(game)
	scyther = A.species_id(game, "SCYTHER")
	form = D.SHINY_MASK | D.ALT_SHINY_MASK | SCYTHER_FOREST_GREEN
	game.poke("wCurPartySpecies", scyther)
	game.poke("wTempMonSpecies", scyther)
	game.poke("wTempMonForm", form)
	game.poke("wCurPartyMon", 0)
	A.call(game, "AddTempmonToParty")
	assert game.peek("wPartyCount") == 6
	green = D.form_flag("SCYTHER", SCYTHER_FOREST_GREEN)
	alt = D.alt_flag("SCYTHER")
	assert D.set_flags(game) == [("wDexFormsSeen", green), ("wDexFormsCaught", green),
		("wDexAltShiniesSeen", alt), ("wDexAltShiniesCaught", alt)]


# The PICS page

def test_unseen_forms_and_alternates_stay_hidden(game):
	open_pics(game, "SCYTHER")
	for button in ("right", "left"):
		press(game, button)
		assert game.peek("wPokedexViewForm") == 0
		assert "FORM" not in form_label(game)
	# Select: shiny, then straight back to off without an alternate
	press(game, "select")
	assert game.peek("wPokedexShinyToggle") == 1
	assert game.peek("wPokedexDisplayForm") == D.SHINY_MASK
	press(game, "select")
	assert game.peek("wPokedexShinyToggle") == 0
	assert game.peek("wPokedexDisplayForm") == 0


def test_pics_page_steps_through_the_seen_forms(game):
	D.see_form(game, "SCYTHER", SCYTHER_TEAL) # Forest Green stays unseen
	open_pics(game, "SCYTHER")
	assert form_label(game) == "FORM ◀1/2▶"
	press(game, "right")
	assert game.peek("wPokedexViewForm") == SCYTHER_TEAL, "Forest Green hasn't been seen"
	assert game.peek("wPokedexDisplayForm") == SCYTHER_TEAL
	assert game.peek("wForm") == SCYTHER_TEAL, "the pics should load in that form"
	assert form_label(game) == "FORM ◀2/2▶"
	assert A.pal_colors(SCYTHER_TEAL_PAL) in bg_palette_pairs(game), "its pic should be teal"
	press(game, "right")
	assert game.peek("wPokedexViewForm") == 0, "round to the plain form"
	assert form_label(game) == "FORM ◀1/2▶"
	press(game, "left")
	assert game.peek("wPokedexViewForm") == SCYTHER_TEAL


def test_shiny_toggle_colors_the_form_shown(game):
	D.see_form(game, "SCYTHER", SCYTHER_TEAL)
	open_pics(game, "SCYTHER")
	press(game, "right")
	press(game, "select")
	assert game.peek("wPokedexDisplayForm") == D.SHINY_MASK | SCYTHER_TEAL
	assert A.pal_colors(SCYTHER_SHINY_PAL) in bg_palette_pairs(game)
	assert D.tile_at(game, *D.PICS_SHINY_GLYPH) == D.DEX_SHINY_GLYPH


def test_forms_that_look_plain_are_never_offered(game):
	D.see_form(game, "GYARADOS", GYARADOS_XS)
	D.see_form(game, "GYARADOS", GYARADOS_RB)
	open_pics(game, "GYARADOS")
	assert form_label(game) == "FORM ◀1/2▶"
	press(game, "right")
	assert game.peek("wPokedexViewForm") == GYARADOS_RB


def test_neutral_shuckie_is_never_offered(game):
	D.see_form(game, "SHUCKLE", D.form_constant("SHUCKLE_SHUCKIE_NEUTRAL_FORM"))
	D.see_form(game, "SHUCKLE", D.form_constant("SHUCKLE_SHUCKIE_HAPPY_FORM"))
	open_pics(game, "SHUCKLE")
	assert form_label(game) == "FORM ◀1/2▶"
	press(game, "right")
	assert game.peek("wPokedexViewForm") == D.form_constant("SHUCKLE_SHUCKIE_HAPPY_FORM")


def test_alternate_shiny_once_seen(game):
	D.see_alt(game, "SCYTHER")
	D.see_form(game, "SCYTHER", SCYTHER_TEAL)
	open_pics(game, "SCYTHER")
	press(game, "select")
	assert game.peek("wPokedexDisplayForm") == D.SHINY_MASK
	assert D.tile_at(game, *D.PICS_SHINY_GLYPH) == D.DEX_SHINY_GLYPH
	press(game, "select")
	assert game.peek("wPokedexShinyToggle") == 3
	assert game.peek("wPokedexDisplayForm") == D.SHINY_MASK | D.ALT_SHINY_MASK
	assert D.tile_at(game, *D.PICS_SHINY_GLYPH) == D.ALT_SHINY_GLYPH
	assert A.pal_colors(SCYTHER_ALT_PAL) in bg_palette_pairs(game), "its pic should be red"
	# The alternate colors go with any form shown
	press(game, "right")
	assert game.peek("wPokedexDisplayForm") == D.SHINY_MASK | D.ALT_SHINY_MASK | SCYTHER_TEAL
	assert A.pal_colors(SCYTHER_ALT_PAL) in bg_palette_pairs(game)
	press(game, "select")
	assert game.peek("wPokedexShinyToggle") == 0
	assert game.peek("wPokedexDisplayForm") == SCYTHER_TEAL


def test_alternate_toggle_on_the_entry_screen(game):
	D.see_alt(game, "MAGIKARP")
	open_pokedex_entry(game, "MAGIKARP")
	game.press("select", after=120)
	game.press("select", after=120)
	assert game.peek("wPokedexDisplayForm") == D.SHINY_MASK | D.ALT_SHINY_MASK
	assert D.tile_at(game, 8, 1) == D.ALT_SHINY_GLYPH


def test_alternate_is_only_shown_for_a_species_whose_alternate_was_seen(game):
	"""The saved toggle stays on "alternate", but a species without one seen shows ordinary shiny."""
	D.see_alt(game, "SCYTHER")
	game.poke("wPokedexShinyToggle", 3)
	open_pics(game, "SCIZOR", others=["SCYTHER"])
	assert game.peek("wPokedexDisplayForm") == D.SHINY_MASK
	assert D.tile_at(game, *D.PICS_SHINY_GLYPH) == D.DEX_SHINY_GLYPH


def test_caught_ball_follows_the_look_shown(game):
	D.see_form(game, "SCYTHER", SCYTHER_FOREST_GREEN, caught=True)
	D.see_form(game, "SCYTHER", SCYTHER_TEAL)
	open_pics(game, "SCYTHER")
	assert D.tile_at(game, *D.PICS_CAUGHT_BALL) == D.CAUGHT_BALL, "the species is caught"
	press(game, "right")
	assert game.peek("wPokedexViewForm") == SCYTHER_FOREST_GREEN
	assert D.tile_at(game, *D.PICS_CAUGHT_BALL) == D.CAUGHT_BALL
	press(game, "right")
	assert game.peek("wPokedexViewForm") == SCYTHER_TEAL
	assert D.tile_at(game, *D.PICS_CAUGHT_BALL) != D.CAUGHT_BALL, "Teal was only seen"


def test_leaving_pics_goes_back_to_the_plain_form(game):
	D.see_form(game, "SCYTHER", SCYTHER_TEAL)
	open_pics(game, "SCYTHER")
	press(game, "right")
	assert game.peek("wPokedexViewForm") == SCYTHER_TEAL
	game.press("b", after=200)
	assert game.peek("wPokedexViewForm") == 0
	assert game.peek("wPokedexDisplayForm") == 0


# EVO icons

def evo_icon_colors(game, count):
	"""Colors 1 and 2 of OBJ palettes 0 to count - 1, which the EVO tab's icons take by slot."""
	data = game.peek("wOBPals2", 0, 8 * count)
	return [[data[p * 8 + 2] | data[p * 8 + 3] << 8, data[p * 8 + 4] | data[p * 8 + 5] << 8]
		for p in range(count)]


def icon_colors(game, species, form):
	"""The two colors the game gives `species`' icon with form byte `form`."""
	form_byte = A.scratch_address(game, 0)
	game.pyboy.memory[form_byte] = form
	out = A.call(game, "GetArrangedMonIconColors", a=A.species_id(game, species), bc=form_byte)
	return [out["bc"], out["de"]]


def open_scyther_evos(game, toggle):
	game.poke("wPokedexShinyToggle", toggle)
	open_pokedex_entry(game, "SCYTHER", others=["SCIZOR"])
	open_tab(game, "EVO")
	game.wait(120)
	return evo_icon_colors(game, 2)


def test_evo_icons_take_their_own_colors(game):
	"""Regression: the EVO tab drew each icon in one of the eight shared menu-icon colors."""
	shown = open_scyther_evos(game, 0)
	assert shown == [icon_colors(game, "SCYTHER", 0), icon_colors(game, "SCIZOR", 0)]


def test_evo_icons_follow_the_shiny_toggle(game):
	shown = open_scyther_evos(game, 1)
	assert shown == [icon_colors(game, "SCYTHER", D.SHINY_MASK), icon_colors(game, "SCIZOR", D.SHINY_MASK)]
	assert shown[0] != icon_colors(game, "SCYTHER", 0)


def test_evo_icons_show_only_seen_alternates(game):
	"""With the toggle on "alternate", an icon takes its alternate shiny colors only if that
	species' alternate has been seen, and its ordinary shiny colors otherwise."""
	D.see_alt(game, "SCYTHER")
	shown = open_scyther_evos(game, 3)
	alternate = D.SHINY_MASK | D.ALT_SHINY_MASK
	assert shown == [icon_colors(game, "SCYTHER", alternate), icon_colors(game, "SCIZOR", D.SHINY_MASK)]
	assert shown[0] != icon_colors(game, "SCYTHER", D.SHINY_MASK)


# Drawing the PICS page

def vram1_tiles(game, first, count):
	"""Tiles first to first + count - 1 ($80 and up) from VRAM bank 1."""
	return [game.pyboy.memory[1, 0x8000 + first * 16 + i] for i in range(count * 16)]


def rom_tiles(game, label, first, count):
	bank, address = game.pyboy.symbol_lookup(label)
	start = bank * 0x4000 + address - 0x4000 + first * 16
	return list(game.rom.read_bytes()[start:start + count * 16])


@pytest.mark.parametrize("species", ["RAICHU", "MOLTRES"])
def test_pics_page_tiles_survive_a_big_front_pic(game, species):
	"""Regression: a front pic with more than 110 tiles of animation frames loaded over the page's
	frame and CRY tiles, and past 127 over the back pic."""
	consts = global_constants().values
	open_pics(game, species)
	assert vram1_tiles(game, consts["DEXPICS_FRAME_TILE"], 8) == rom_tiles(game, "Pokedex_ExtraTiles", 21, 8)
	assert vram1_tiles(game, consts["DEXPICS_CRY_TILE"], 2) == rom_tiles(game, "Pokedex_ExtraTiles", 19, 2)


def test_icon_keeps_its_colors_through_the_shine(game):
	"""Regression: the shiny toggle reset the OBJ palettes and colored the icon only after the
	sound effect, so it showed the default colors for that long."""
	slot = global_constants().values["MENU_MON_ICON_PAL"]
	open_pics(game, "SCYTHER")
	game.press("select", after=3)
	shown = []
	for _ in range(40):
		game.wait(1)
		shown.append(evo_icon_colors(game, slot + 1)[slot])
	assert shown == [icon_colors(game, "SCYTHER", D.SHINY_MASK)] * len(shown)


def bg_black(game):
	return not any(game.peek("wBGPals2", 0, 8 * 8))


def front_pic_drawn(game):
	return any(D.tile_at(game, x, y) != 0x7f for x in range(1, 8) for y in range(1, 8))


def test_species_step_stays_black_until_the_page_is_drawn(game):
	"""Regression: stepping to another species showed the page's colors over blank pics while they
	loaded."""
	open_pics(game, "SCYTHER", others=["SCIZOR"])
	game.press("up", after=0)
	went_black = False
	for _ in range(300):
		game.wait(1)
		if bg_black(game):
			went_black = True
		elif went_black:
			assert front_pic_drawn(game), "colors came back before the pics were drawn"
			return
	raise AssertionError("the page never came back from black")


def test_form_step_swaps_the_pics_in_place(game):
	"""A form step changes the pics, icon, colors, label and marks without blacking out the page."""
	D.see_form(game, "SCYTHER", SCYTHER_TEAL)
	open_pics(game, "SCYTHER")
	game.press("right", after=0)
	for _ in range(PICS_SETTLE):
		game.wait(1)
		assert not bg_black(game), "the page went black"
		assert "SCYTHER" in game.screen_lines()[11], "the name should stay"
	assert game.peek("wForm") == SCYTHER_TEAL
	assert form_label(game) == "FORM ◀2/2▶"
	assert A.pal_colors(SCYTHER_TEAL_PAL) in bg_palette_pairs(game)


def test_select_on_pics_doesnt_wait_for_its_sound(game):
	"""The shiny toggle's sound plays on while the page takes the next press."""
	open_pics(game, "BULBASAUR")
	game.press("select", after=10)
	game.press("select", after=10)
	assert game.peek("wPokedexShinyToggle") == 0, "the second Select should step it back off"


POKEDEX_SCX = 5 # engine/pokedex/pokedex.asm
START_TILE = 0x41 # the PICS page's START ▶ CRY banner, at (11, 17)


@pytest.mark.parametrize("species", ["BULBASAUR", "SCYTHER", "GYARADOS", "RAICHU", "MEW", "CHIKORITA"])
def test_start_plays_the_cry_and_stays_on_pics(game, species):
	"""Regression: playing the cry clobbered the register the next button checks read, so Start
	could act as B and leave the page."""
	open_pics(game, species)
	game.press("start", after=60)
	assert D.tile_at(game, 11, 17) == START_TILE, "Start left the PICS page"


def test_new_entry_shows_the_caught_form(game):
	"""Regression: the screen after catching a new species drew the caught form's pic in the plain
	form's colors."""
	from harness.pokedex import set_dex_bit, species_index
	wild_battle(game, "SCYTHER", SCYTHER_TEAL, room=True)
	set_dex_bit(game, "wPokedexSeen", species_index("SCYTHER"), False)
	set_dex_bit(game, "wPokedexCaught", species_index("SCYTHER"), False)
	throw_ball(game, "MASTER BALL")
	for tick in range(300): # through the catch's text to the dex's
		if "data" in game.screen_text():
			break
		game.wait(10)
		if tick % 15 == 14:
			game.press("a", after=2)
	else:
		raise AssertionError("no new dex entry. The screen:\n" + game.screen_text())
	for _ in range(10): # to the dex entry itself, which scrolls the screen over
		if game.peek("hSCX") == POKEDEX_SCX:
			break
		game.press("a", after=60)
	game.wait(60)
	assert game.peek("hSCX") == POKEDEX_SCX, "the new entry never opened"
	assert game.peek("wPokedexDisplayForm") == SCYTHER_TEAL
	assert A.pal_colors(SCYTHER_TEAL_PAL) in bg_palette_pairs(game), "the pic should be teal"
	answer_prompts(game, lambda: out_of_battle(game), timeout=400)
	assert game.peek("wPokedexViewForm") == 0


# Saving

def test_record_survives_saving_and_continuing(game, tmp_path):
	D.see_form(game, "SCYTHER", SCYTHER_TEAL, caught=True)
	D.see_form(game, "UNOWN", D.form_constant("UNOWN_K"))
	D.see_alt(game, "GYARADOS", caught=True)
	recorded = D.record(game)
	D.save_game(game)
	path = tmp_path / "dex_forms.sav"
	path.write_bytes(D.sram(game))

	loaded = Game(rom_path(), save=path)
	try:
		continue_game(loaded)
		assert D.record(loaded) == recorded
	finally:
		loaded.close()


@pytest.mark.parametrize("name", ["v1.0_cherrygrove.sav", "1.1_cherrygrove.sav", "v1.0_before_starter.sav"])
def test_old_saves_load_with_nothing_recorded(name):
	game = Game(rom_path(), save=SAVES / name)
	try:
		game.wait(200)
		# Whatever the record held before, a save without its copy loads as nothing met
		D.clear_record(game, 0xff)
		continue_game(game)
		assert D.record(game) == [0] * D.record_length(game)
	finally:
		game.close()
