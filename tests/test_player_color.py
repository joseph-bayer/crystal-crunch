"""The player's color: picked after Boy/Girl, kept in wPlayerGender bits 1-4 (0 = the gender's
default, red boy or blue girl), and shown everywhere the player is drawn.

Code that read the whole of wPlayerGender as the gender would see a color as part of it: the caught
data's location, the PC's bag icon and the byte the link partner gets all have to keep to bit 0."""

import re

import pytest

from harness import Game, constants, overworld, rom_path
from harness import alt_shiny as A

FEMALE = 1
PLAYER_COLOR_SHIFT = 1


def player_colors():
	"""{PLAYER_COLOR_NAME: value} from constants/ram_constants.asm, which numbers them from 1."""
	text = (constants.ROOT / "constants" / "ram_constants.asm").read_text(encoding="utf-8")
	names = re.findall(r"^\tconst (PLAYER_COLOR_\w+)", text, re.MULTILINE)
	return {name: i + 1 for i, name in enumerate(names)}


def gender_byte(color, female):
	return player_colors()["PLAYER_COLOR_" + color] << PLAYER_COLOR_SHIFT | (FEMALE if female else 0)


# A color that isn't either gender's default
OTHER_COLOR = "TEAL"


def test_new_game_keeps_the_default(game):
	assert game.peek("wPlayerGender") == 0, "pressing A through the intro should give a boy in his default"


# Whole-byte readers

@pytest.mark.parametrize("female", [False, True])
def test_caught_data_keeps_only_the_gender(game, female):
	results = []
	for value in (FEMALE if female else 0, gender_byte(OTHER_COLOR, female)):
		game.poke("wPlayerGender", value)
		address = A.scratch_address(game, 0)
		A.call(game, "SetBoxmonOrEggmonCaughtData", hl=address)
		results.append(game.pyboy.memory[address + 1])
	plain, colored = results
	assert bool(plain & 0x80) == female, "the OT gender bit should follow the gender"
	assert colored == plain, "the color leaked into the caught location byte (%02x, not %02x)" % (colored, plain)


@pytest.mark.parametrize("female", [False, True])
def test_pc_bag_icon_keeps_only_the_gender(game, female):
	tile_id_offset = 3 # SPRITEANIMSTRUCT_TILE_ID
	game.poke("wPlayerGender", gender_byte(OTHER_COLOR, female))
	struct = A.scratch_address(game, 0x20)
	A.call(game, "SpriteAnimFunc_PcPack", bc=struct)
	assert game.pyboy.memory[struct + tile_id_offset] == (4 if female else 0), "the bag icon tile is wrong"


@pytest.mark.parametrize("female", [False, True])
def test_link_partner_gets_only_the_gender(game, female):
	"""What CheckOtherPlayerGender sends: Link_EnsureSync is called with the byte in a."""
	game.poke("wPlayerGender", gender_byte(OTHER_COLOR, female))
	sent = []
	bank, address = game.pyboy.symbol_lookup("Link_EnsureSync")
	game.pyboy.hook_register(bank, address, lambda _: sent.append(game.pyboy.register_file.A), None)
	A.call(game, "CheckOtherPlayerGender", must_return=False, frames=5)
	assert sent, "CheckOtherPlayerGender never reached Link_EnsureSync"
	assert sent[0] == (1 if female else 0), "the partner would get %02x" % sent[0]


# Saving

SRAM_BANKS = 4
SRAM_BANK_SIZE = 0x2000
SRAM_START = 0xa000


def cartridge_ram(game):
	return bytes(game.pyboy.memory[bank, SRAM_START + i]
		for bank in range(SRAM_BANKS) for i in range(SRAM_BANK_SIZE))


def save_from_start_menu(game):
	game.press("start", after=40)
	game.choose("SAVE")
	for _ in range(60):
		text = game.screen_text()
		if "saved the game" in text or "SAVED" in text.upper() and "YES" not in text:
			break
		if "YES" in text and "NO" in text:
			game.choose("YES")
			continue
		game.press("a", after=30)
	game.wait(120)
	for _ in range(10):
		if game.peek("wWindowStackSize") == 0 and game.peek("wScriptRunning") == 0:
			break
		game.press("b", after=30)


def continue_from(ram, tmp_path):
	path = tmp_path / "game.sav"
	path.write_bytes(ram)
	from test_old_saves import continue_game
	game = Game(rom_path(), save=path)
	try:
		continue_game(game)
	except Exception:
		game.close()
		raise
	return game


def test_a_changed_color_is_saved(game, tmp_path):
	save_from_start_menu(game) # a new game's first save writes the whole of wPlayerGender anyway
	game.poke("wPlayerGender", gender_byte(OTHER_COLOR, False))
	save_from_start_menu(game)
	bank, address = game._address("sCrystalData")
	assert game.pyboy.memory[bank, address] == gender_byte(OTHER_COLOR, False), "the save kept the old color"
	resumed = continue_from(cartridge_ram(game), tmp_path)
	try:
		assert resumed.peek("wPlayerGender") == gender_byte(OTHER_COLOR, False)
	finally:
		resumed.close()


def test_v1_0_girl_loads_in_blue(tmp_path):
	"""A v1.0 save holds only the gender bit: a girl comes back in her default blue."""
	game = Game(rom_path())
	try:
		bank, address = game._address("sCrystalData")
	finally:
		game.close()
	ram = bytearray((constants.ROOT / "tests" / "fixtures" / "saves" / "v1.0_cherrygrove.sav").read_bytes())
	ram[bank * SRAM_BANK_SIZE + address - SRAM_START] = FEMALE
	resumed = continue_from(bytes(ram), tmp_path)
	try:
		assert resumed.peek("wPlayerGender") == FEMALE
		color = A.call(resumed, "GetPlayerColor")["a"]
		assert color == player_colors()["PLAYER_COLOR_BLUE"]
	finally:
		resumed.close()


# The overworld sprite and its icons (the colors are the NPC set's, gfx/overworld/npc_sprites.pal)

PALETTE_SIZE = 8
PAL_OW_WHITE = 0x0b
DAY = 1
OBJECT_PALETTE = 0x06
OBJECT_PAL_INDEX = 0x21
OBJECT_LENGTH = 0x22
NUM_OBJECT_STRUCTS = 14
OAM_PALETTE = 0x07
PLAYER_NORMAL, PLAYER_BIKE, PLAYER_SURF = 0, 1, 4
ALL_COLORS = ["RED", "BLUE", "GREEN", "BROWN", "PURPLE", "GRAY", "PINK", "TEAL", "YELLOW", "ORANGE",
	"AZURE", "BLACK"]


def ow_pal(color):
	"""PAL_OW_* for a PLAYER_COLOR_* name: the same order, with white skipped."""
	value = player_colors()["PLAYER_COLOR_" + color] - 1
	return value + 1 if value >= PAL_OW_WHITE else value


def npc_colors(pal, time):
	"""The four 15-bit colors of PAL_OW_* `pal` at daytime `time` (morn, day, nite, eve)."""
	text = (constants.ROOT / "gfx" / "overworld" / "npc_sprites.pal").read_text(encoding="utf-8")
	sections = re.split(r"^; \w+\s*$", text, flags=re.MULTILINE)[1:]
	rows = re.findall(r"RGB ([\d, ]+)", sections[time])
	values = [int(v) for v in rows[pal].replace(" ", "").strip(",").split(",")]
	return [values[i] | values[i + 1] << 5 | values[i + 2] << 10 for i in range(0, 12, 3)]


def palette(game, symbol, slot):
	data = game.peek(symbol, slot * PALETTE_SIZE, PALETTE_SIZE)
	return [data[i] | data[i + 1] << 8 for i in range(0, PALETTE_SIZE, 2)]


def set_color(game, color, female):
	game.poke("wPlayerGender", gender_byte(color, female))


def player_field(game, field):
	return game.peek("wObjectStructs", field)


def assert_player_wears(game, color):
	pal = ow_pal(color)
	assert game.peek("wPlayerObjectPalette") == pal + 1, "the player's map object palette"
	assert player_field(game, OBJECT_PAL_INDEX) == pal, "the color the player's struct asks for"
	slot = player_field(game, OBJECT_PALETTE) & OAM_PALETTE
	time = game.peek("wTimeOfDayPal") & 3
	assert palette(game, "wOBPals1", slot) == npc_colors(pal, time), \
		"OBJ palette %d doesn't hold %s's colors" % (slot, color)


def test_default_start_is_red(game):
	assert_player_wears(game, "RED")


@pytest.mark.parametrize("female", [False, True], ids=["boy", "girl"])
@pytest.mark.parametrize("color", ALL_COLORS)
def test_overworld_sprite_color(game, color, female):
	set_color(game, color, female)
	game.warp("PLAYERS_HOUSE_2F", 3, 3)
	assert_player_wears(game, color)


@pytest.mark.parametrize("state", [PLAYER_BIKE, PLAYER_SURF], ids=["bike", "surf"])
def test_bike_and_surf_keep_the_color(game, state):
	set_color(game, OTHER_COLOR, True)
	game.poke("wPlayerState", state)
	game.warp("NEW_BARK_TOWN", 6, 4)
	assert_player_wears(game, OTHER_COLOR)


@pytest.mark.parametrize("female", [False, True], ids=["boy", "girl"])
def test_default_color_by_gender(game, female):
	game.poke("wPlayerGender", FEMALE if female else 0)
	game.warp("PLAYERS_HOUSE_2F", 3, 3)
	assert_player_wears(game, "BLUE" if female else "RED")


def test_intro_sprite_color(game):
	set_color(game, OTHER_COLOR, False)
	A.call(game, "Intro_PlacePlayerSprite")
	assert palette(game, "wOBPals1", 0) == npc_colors(ow_pal(OTHER_COLOR), DAY)


def daytime_icon_colors(color):
	return npc_colors(ow_pal(color), DAY)


@pytest.mark.parametrize("female", [False, True], ids=["boy", "girl"])
def test_pokegear_map_icon(game, female):
	set_color(game, OTHER_COLOR, female)
	game.poke("wPokegearFlags", 1 << 0 | 1 << 7) # the map card, and the Pokégear itself
	game.press("start", after=40)
	game.choose("GEAR")
	game.wait(120)
	for _ in range(4):
		if icon_attributes(game, range(0x10, 0x18)):
			break
		game.press("right", after=60)
	attributes = icon_attributes(game, range(0x10, 0x18))
	assert attributes == {1}, "the player's icon should use OB 1, not %s" % attributes
	assert palette(game, "wOBPals1", 1) == daytime_icon_colors(OTHER_COLOR)
	assert palette(game, "wOBPals2", 1) == daytime_icon_colors(OTHER_COLOR), "OB 1 wasn't applied"


def icon_attributes(game, tiles):
	"""The OBJ palettes of the shadow OAM entries showing these tiles."""
	result = set()
	for entry in range(40):
		y, x, tile, attributes = game.peek("wShadowOAM", entry * 4, 4)
		if tile in tiles and 0 < y < 160:
			result.add(attributes & OAM_PALETTE)
	return result


def frameset(game, anim_obj_constant):
	return constants._consts(constants.ROOT / "constants" / "sprite_anim_constants.asm")[anim_obj_constant]


def test_fly_map_icon(game):
	set_color(game, OTHER_COLOR, False)
	struct = A.call(game, "TownMapPlayerIcon", a=1)["bc"] # LANDMARK_NEW_BARK_TOWN
	_, base = game._address("wSpriteAnimationStructs")
	assert struct >= base
	assert game.pyboy.memory[struct + 1] == frameset(game, "SPRITE_ANIM_FRAMESET_BLUE_WALK"), \
		"the Fly map's icon should use OB 1's walking frames"


def test_pokedex_area_icon(game):
	set_color(game, OTHER_COLOR, False)
	game.poke("wTownMapPlayerIconLandmark", 1)
	seen = set()
	A.call(game, "Pokedex_GetArea", de=1, must_return=False, frames=120)
	game.pyboy.button_press("select") # the area map shows the player while SELECT is held
	for _ in range(60):
		game.wait(1)
		seen |= icon_attributes(game, range(0x78, 0x7c))
	game.pyboy.button_release("select")
	assert seen == {1}, "the area map's player icon should use OB 1, not %s" % seen


def test_naming_screen_icon(game):
	set_color(game, OTHER_COLOR, True)
	_, buffer = game._address("wStringBuffer1")
	A.call(game, "NamingScreen", bc=1 << 8, de=buffer, must_return=False, frames=120) # NAME_PLAYER
	assert palette(game, "wOBPals1", 1) == daytime_icon_colors(OTHER_COLOR)
	assert frameset(game, "SPRITE_ANIM_FRAMESET_BLUE_WALK") in game.peek("wSpriteAnimationStructs", 0, 0xa0)[1::0x10]


@pytest.mark.parametrize("female", [False, True], ids=["boy", "girl"])
def test_copycat_copies_the_color(game, female):
	set_color(game, OTHER_COLOR, female)
	game.warp("COPYCATS_HOUSE_2F", 3, 1)
	copycat = constants._consts(constants.ROOT / "constants" / "sprite_constants.asm")["SPRITE_COPYCAT"]
	structs = [s for s in range(NUM_OBJECT_STRUCTS) if game.peek("wObjectStructs", s * OBJECT_LENGTH) == copycat]
	assert len(structs) == 1, "one Copycat should be out"
	assert game.peek("wObjectStructs", structs[0] * OBJECT_LENGTH + OBJECT_PAL_INDEX) == ow_pal(OTHER_COLOR)


# The pics: battle back pic, intro and Hall of Fame front pic, trainer card

SKIN = {False: (25, 18, 12), True: (27, 17, 14)}
# The agreed clothes colors, the same for both genders
PIC_CLOTHES = {
	"RED": (22, 9, 5), "BLUE": (10, 9, 31), "GREEN": (5, 17, 2),
	"BROWN": (15, 10, 3), "PURPLE": (18, 4, 18), "GRAY": (13, 13, 13), "PINK": (26, 8, 16),
	"TEAL": (2, 16, 15), "YELLOW": (13, 13, 0), "ORANGE": (22, 14, 0),
	"AZURE": (3, 15, 28), "BLACK": (7, 7, 8),
}


def rgb15(rgb):
	return rgb[0] | rgb[1] << 5 | rgb[2] << 10


def pic_colors(color, female):
	clothes = PIC_CLOTHES[color]
	if isinstance(clothes[0], tuple):
		clothes = clothes[female]
	return [rgb15(SKIN[female]), rgb15(clothes)]


def rom_colors(game, symbol):
	"""The two colors at a ROM label (a TrainerPalettes entry)."""
	bank, address = game.pyboy.symbol_lookup(symbol)
	data = [game.pyboy.memory[bank, address + i] for i in range(4)]
	return [data[0] | data[1] << 8, data[2] | data[3] << 8]


def global_constant(name):
	from harness import data
	return data.global_constants().values[name]


def load_layout(game, name):
	A.call(game, "LoadSGBLayoutCGB", bc=global_constant(name) << 8)


def middle(game, symbol, slot):
	return palette(game, symbol, slot)[1:3]


def test_default_pics_are_unchanged(game):
	"""Red Chris is Cal's colors, byte for byte, and red Kris wears Cal's clothes."""
	assert pic_colors("RED", False) == rom_colors(game, "PlayerPalette")
	assert pic_colors("RED", True)[1] == rom_colors(game, "PlayerPalette")[1]


@pytest.mark.parametrize("female", [False, True], ids=["boy", "girl"])
@pytest.mark.parametrize("color", ALL_COLORS)
def test_battle_back_pic_colors(game, color, female):
	set_color(game, color, female)
	game.poke("wTempBattleMonSpecies", 0)
	load_layout(game, "SCGB_BATTLE_COLORS")
	assert middle(game, "wBGPals1", 0) == pic_colors(color, female), "the back pic's BG palette"
	assert middle(game, "wOBPals1", global_constant("PAL_BATTLE_OB_PLAYER")) == pic_colors(color, female)


@pytest.mark.parametrize("female", [False, True], ids=["boy", "girl"])
def test_front_pic_colors(game, female):
	"""The intro's and the Hall of Fame's front pic."""
	set_color(game, OTHER_COLOR, female)
	game.poke("wCurPartySpecies", 0)
	load_layout(game, "SCGB_PLAYER_OR_MON_FRONTPIC_PALS")
	assert middle(game, "wBGPals1", 0) == pic_colors(OTHER_COLOR, female)


@pytest.mark.parametrize("female", [False, True], ids=["boy", "girl"])
@pytest.mark.parametrize("color", ["RED", "BLUE", OTHER_COLOR])
def test_tutorial_dude_wears_cals_colors(game, color, female):
	set_color(game, color, female)
	game.poke("wBattleType", global_constant("BATTLETYPE_TUTORIAL"))
	game.poke("wTempBattleMonSpecies", 0)
	load_layout(game, "SCGB_BATTLE_COLORS")
	assert middle(game, "wBGPals1", 0) == rom_colors(game, "PlayerPalette")


def attr_at(game, x, y):
	return game.peek("wAttrmap", y * 20 + x) & 7


@pytest.mark.parametrize("female", [False, True], ids=["boy", "girl"])
def test_johto_trainer_card(game, female):
	set_color(game, OTHER_COLOR, female)
	load_layout(game, "SCGB_TRAINER_CARD")
	player = pic_colors(OTHER_COLOR, female)
	for x, y in ((14, 1), (18, 1), (18, 7), (0, 0), (19, 17)): # the pic box, its corner, the border
		assert attr_at(game, x, y) == 0, "(%d, %d) should be in the player's palette" % (x, y)
	assert middle(game, "wBGPals1", 0) == player
	for x, y in ((3, 10), (15, 13)): # Falkner's and Clair's faces
		assert attr_at(game, x, y) == 1
	assert middle(game, "wBGPals1", 1) == rom_colors(game, "FalknerPalette")


@pytest.mark.parametrize("female", [False, True], ids=["boy", "girl"])
def test_kanto_trainer_card(game, female):
	set_color(game, OTHER_COLOR, female)
	load_layout(game, "SCGB_TRAINER_CARD_KANTO")
	for x, y in ((14, 1), (18, 1), (0, 0), (19, 17)):
		assert attr_at(game, x, y) == 1, "(%d, %d) should be in the player's palette" % (x, y)
	assert middle(game, "wBGPals1", 1) == pic_colors(OTHER_COLOR, female)
	assert attr_at(game, 7, 10) == 0, "Misty's face"
	assert middle(game, "wBGPals1", 0) == rom_colors(game, "PlayerPalette")


# The new game's color screen, after Boy/Girl

PICKER_TEXT = "you like to wear?"


def reach_picker(female=False):
	"""A fresh game from power-on, on the color screen once its question is printed."""
	game = Game(rom_path())
	game.wait(400)
	for _ in range(200):
		text = game.screen_text()
		if PICKER_TEXT in text:
			game.wait(30)
			return game
		if "Girl" in text and "Boy" in text and female:
			game.choose("Girl")
			continue
		game.press("a")
	game.close()
	raise AssertionError("the color screen never showed")


def assert_picker_shows(game, color, female):
	assert game.peek("wPlayerGender") & 1 == (1 if female else 0)
	stored = (game.peek("wPlayerGender") >> 1) & 0xf
	default = "BLUE" if female else "RED"
	assert stored == (0 if color == default else player_colors()["PLAYER_COLOR_" + color]), \
		"wPlayerGender = %02x" % game.peek("wPlayerGender")
	assert middle(game, "wBGPals2", 0) == pic_colors(color, female), "the pic's colors on screen"
	assert palette(game, "wOBPals2", 0) == npc_colors(ow_pal(color), DAY), "the sprite's colors on screen"
	assert color in game.screen_text(), "the color's name"


def test_picker_offers_the_starting_colors(close_after):
	game = reach_picker()
	close_after(game)
	assert_picker_shows(game, "RED", False)
	for color in ("BLUE", "GREEN", "RED"):
		game.press("right", after=30)
		assert_picker_shows(game, color, False)
	game.press("left", after=30)
	assert_picker_shows(game, "GREEN", False)


def test_picker_background_is_white(close_after):
	"""Blank tiles behind the boxes, not the Boy/Girl screen's light-blue tile ($00)."""
	game = reach_picker()
	close_after(game)
	tiles = game.peek("wTilemap", 0, 20 * 18)
	assert 0 not in tiles, "the light-blue tile is on the color screen"
	assert tiles[0] == 0x7f, "a blank corner"


def test_change_style_background_is_white(game):
	open_change_style(game)
	tiles = game.peek("wTilemap", 0, 20 * 18)
	assert 0 not in tiles, "the light-blue tile is on the color screen"
	close_picker(game, "b")


def test_picker_starts_a_girl_in_blue(close_after):
	game = reach_picker(female=True)
	close_after(game)
	assert_picker_shows(game, "BLUE", True)
	game.press("right", after=30)
	assert_picker_shows(game, "GREEN", True)


def test_picker_b_goes_back_to_boy_or_girl(close_after):
	game = reach_picker()
	close_after(game)
	game.press("right", after=30)
	game.press("b", after=60)
	game.wait_for_text("Girl")
	assert PICKER_TEXT not in game.screen_text()
	game.choose("Girl")
	game.wait_for_text(PICKER_TEXT)
	game.wait(30)
	assert_picker_shows(game, "BLUE", True)


def test_picked_color_starts_the_game(close_after):
	game = reach_picker()
	close_after(game)
	game.press("right", after=30)
	game.press("right", after=30)
	from harness.new_game import play_intro
	play_intro(game)
	assert game.peek("wPlayerGender") == gender_byte("GREEN", False)
	assert_player_wears(game, "GREEN")


@pytest.fixture
def close_after():
	games = []
	yield games.append
	for game in games:
		game.close()


# The Goldenrod stylist and mirror (the PP Speech House)

STORE_COLORS = ALL_COLORS[3:]
STYLIST_MAP = "GOLDENROD_UNDERGROUND"
STYLIST_SPOT = (5, 20) # across the bitter stall's counter from the stylist, facing right
PRICE = 50000


def own(game, color, value=True):
	game.set_event_flag("EVENT_OWNS_PLAYER_COLOR_" + color, value)


def on_sale(game):
	return [c for c in STORE_COLORS if game.event_flag("EVENT_STYLIST_SELLS_" + c)]


def money(game):
	high, mid, low = game.peek("wMoney", 0, 3)
	return high << 16 | mid << 8 | low


def set_money(game, value):
	for i, byte in enumerate((value >> 16 & 0xff, value >> 8 & 0xff, value & 0xff)):
		game.poke("wMoney", byte, i)


def idle(game):
	return (game.peek("wMapStatus") == 2 and game.peek("wScriptRunning") == 0
		and game.peek("wWindowStackSize") == 0)


def press_until(game, condition, what, presses=40):
	for _ in range(presses):
		if condition():
			return
		game.press("a", after=30)
	raise AssertionError("never got %s. The screen:\n%s" % (what, game.screen_text()))


def talk_to_stylist(game):
	game.warp(STYLIST_MAP, *STYLIST_SPOT)
	game.press("right")
	game.press("a")
	press_until(game, lambda: "CHANGE STYLE" in game.screen_text(), "the stylist's menu")
	game.wait(30)


def open_change_style(game):
	talk_to_stylist(game)
	game.choose("CHANGE STYLE")
	game.wait_for_text(PICKER_TEXT)
	game.wait(30)


def close_picker(game, button="a"):
	game.press(button, after=60)
	press_until(game, lambda: idle(game), "back on the map")
	game.wait(30)


def test_change_style_switches_to_an_owned_color(game):
	own(game, "TEAL")
	open_change_style(game)
	assert_picker_shows(game, "RED", False)
	for color in ("BLUE", "GREEN", "TEAL", "RED"):
		game.press("right", after=30)
		assert_picker_shows(game, color, False)
	game.press("left", after=30)
	assert_picker_shows(game, "TEAL", False)
	close_picker(game)
	assert game.in_map(STYLIST_MAP) and game.position() == STYLIST_SPOT, "no warp"
	assert game.peek("wPlayerGender") == gender_byte("TEAL", False)
	assert_player_wears(game, "TEAL")


def test_debug_radio_unlocks_every_color(game):
	from test_fishing import take_radio_items
	take_radio_items(game)
	assert all(game.event_flag("EVENT_OWNS_PLAYER_COLOR_" + c) for c in STORE_COLORS)
	open_change_style(game)
	for color in ALL_COLORS[1:] + ALL_COLORS[:1]:
		game.press("right", after=30)
		assert_picker_shows(game, color, False)
	close_picker(game, "b")


def test_change_style_b_keeps_the_color(game):
	set_color(game, "GREEN", True)
	game.warp("PLAYERS_HOUSE_2F", 3, 3)
	open_change_style(game)
	assert_picker_shows(game, "GREEN", True)
	game.press("right", after=30)
	assert_picker_shows(game, "RED", True)
	close_picker(game, "b")
	assert game.peek("wPlayerGender") == gender_byte("GREEN", True)
	assert_player_wears(game, "GREEN")


def open_buy_menu(game):
	"""Talk to the stylist and pick BUY; wait for today's colors."""
	talk_to_stylist(game)
	game.choose("BUY")
	game.wait(60)
	press_until(game, lambda: "CANCEL" in game.screen_text() and "CHANGE STYLE" not in game.screen_text(),
		"the stylist's colors")
	game.wait(30)


def buy(game, color):
	game.choose(color)
	game.wait_for_text("Dye them " + color)
	game.wait_for_text("YES")
	game.choose("YES")
	game.wait(60)
	press_until(game, lambda: "put this on?" in game.screen_text(), "the offer to put it on")
	game.wait_for_text("YES")


def test_stylist_sells_three_colors(game):
	set_money(game, PRICE + 5)
	open_buy_menu(game)
	stock = on_sale(game)
	assert len(stock) == 3
	text = game.screen_text()
	assert "¥50,000 each." in text, "the price"
	for color in stock:
		assert color in text, "%s should be on the menu" % color
	buy(game, stock[1])
	game.choose("NO")
	game.wait_for_text("anytime")
	press_until(game, lambda: idle(game), "the end of the sale")
	assert game.event_flag("EVENT_OWNS_PLAYER_COLOR_" + stock[1])
	assert money(game) == 5
	assert on_sale(game) == [stock[0], stock[2]], "the sold color should leave today's stock"
	assert game.peek("wPlayerGender") == 0, "NO keeps the clothes on"
	assert_player_wears(game, "RED")


def test_stylist_puts_the_new_color_on(game):
	set_money(game, PRICE)
	open_buy_menu(game)
	color = on_sale(game)[0]
	buy(game, color)
	game.choose("YES")
	press_until(game, lambda: idle(game), "the end of the sale")
	assert game.event_flag("EVENT_OWNS_PLAYER_COLOR_" + color)
	assert game.in_map(STYLIST_MAP) and game.position() == STYLIST_SPOT, "no warp"
	assert game.peek("wPlayerGender") == gender_byte(color, False)
	game.wait(30)
	assert_player_wears(game, color)


def money_box(game):
	"""The top-left box's middle row, or None when the box isn't there."""
	lines = game.screen_lines()
	if not lines[0].startswith("┌") or "┐" not in lines[0][:9]:
		return None
	return lines[1][1:8].strip()


def test_stylist_shows_the_money(game):
	set_money(game, 54321)
	talk_to_stylist(game)
	assert money_box(game) is None, "no money on her first menu"
	game.choose("BUY")
	game.wait(60)
	press_until(game, lambda: "¥54321" in game.screen_text(), "the money")
	assert money_box(game) == "¥54321", game.screen_text()
	game.choose(on_sale(game)[0])
	game.wait_for_text("Dye them")
	assert money_box(game) is None, "the money closes with her menu"


def test_stylist_needs_the_money(game):
	set_money(game, PRICE - 1)
	open_buy_menu(game)
	stock = on_sale(game)
	game.choose(stock[0])
	game.wait_for_text("YES")
	game.choose("YES")
	game.wait_for_text("enough money")
	press_until(game, lambda: idle(game), "the end")
	assert not game.event_flag("EVENT_OWNS_PLAYER_COLOR_" + stock[0])
	assert money(game) == PRICE - 1
	assert on_sale(game) == stock


def stock_today(game):
	game.poke("wDailyFlags3", game.peek("wDailyFlags3") & ~(1 << 6)) # DAILYFLAGS3_STYLIST_STOCKED_F
	A.call(game, "StylistStockToday")
	return on_sale(game)


def test_stock_starts_with_the_day(game):
	start = game.peek("wCurDay") % len(STORE_COLORS)
	expected = [STORE_COLORS[(start + i) % 9] for i in range(3)]
	assert sorted(stock_today(game)) == sorted(expected)


def test_stock_changes_every_day(game):
	first = stock_today(game)
	second = stock_today(game) # the next day, the same weekday counter
	assert not set(first) & set(second), "a new day should put up other colors while there are enough"
	third = stock_today(game)
	assert not set(second) & set(third)


def test_stock_skips_owned_colors(game):
	for color in STORE_COLORS[:7]:
		own(game, color)
	stock = stock_today(game)
	assert sorted(stock) == sorted(STORE_COLORS[7:]), "only the two unowned colors"
	stock = stock_today(game)
	assert sorted(stock) == sorted(STORE_COLORS[7:]), "the same two again: there's nothing else"


@pytest.mark.parametrize("case, answer", [("all owned", "color I sell!"), ("sold out", "for today.")])
def test_stylist_skips_the_price_with_nothing_to_buy(game, case, answer):
	if case == "all owned":
		for color in STORE_COLORS:
			own(game, color)
	else:
		for color in STORE_COLORS:
			game.set_event_flag("EVENT_STYLIST_SELLS_" + color, False)
		game.poke("wDailyFlags3", game.peek("wDailyFlags3") | 1 << 6) # DAILYFLAGS3_STYLIST_STOCKED_F
	talk_to_stylist(game)
	game.choose("BUY")
	for _ in range(40):
		text = game.screen_text()
		assert "dye clothes" not in text, "the price before saying there's nothing to buy"
		if answer in text:
			break
		game.press("a", after=30)
	else:
		raise AssertionError("never said there's nothing to buy. The screen:\n%s" % game.screen_text())
	press_until(game, lambda: idle(game), "the end")


def test_stylist_sold_out_and_all_owned(game):
	for color in STORE_COLORS:
		game.set_event_flag("EVENT_STYLIST_SELLS_" + color, False)
	game.poke("wDailyFlags3", game.peek("wDailyFlags3") | 1 << 6)
	A.call(game, "StylistColorMenu")
	assert game.peek("wScriptVar") == 0xfe, "nothing left on sale today"
	for color in STORE_COLORS:
		own(game, color)
	A.call(game, "StylistColorMenu")
	assert game.peek("wScriptVar") == 0xff, "every color owned"


def test_stylist_menu_text_fits(game):
	"""The longest names, with CANCEL, fit the menu box."""
	for color in STORE_COLORS:
		if color not in ("PURPLE", "YELLOW", "ORANGE"):
			own(game, color)
	set_money(game, 0)
	open_buy_menu(game)
	text = game.screen_text()
	for color in ("PURPLE", "YELLOW", "ORANGE", "CANCEL"):
		assert color in text


INTRO_STEPS = [((3, 2), "down", "right"), ((3, 2), "right", "down"), ((3, 2), "left", "down"),
	((3, 2), "up", "right"), ((3, 34), "up", "right"), ((3, 34), "right", "up"),
	((3, 34), "left", "up"), ((3, 34), "down", "right")]
FACING = {"down": 0, "up": 1, "left": 2, "right": 3}


def stylist_position(game):
	struct = overworld.struct_for_object(game, "GoldenrodUnderground", "GOLDENRODUNDERGROUND_STYLIST")
	return None if struct is None else overworld.struct_position(game, struct)


@pytest.mark.parametrize("ladder, step, faces", INTRO_STEPS)
def test_stylist_introduces_herself_once(game, ladder, step, faces):
	"""The first step off either ladder: she walks up, talks, walks off, and is back in her booth."""
	from test_fishing import take_radio_items
	take_radio_items(game) # a follower out
	game.warp(STYLIST_MAP, *ladder)
	game.wait(30)
	game.step(step)
	closest = None
	for _ in range(200):
		game.wait(5)
		text = game.screen_text()
		if "look new" in text and closest is None:
			closest = stylist_position(game)
			assert game.peek("wPlayerDirection") >> 2 == FACING[faces], "the player turns to her"
		if "▼" in text or "booth any time!" in text:
			game.press("a", after=10)
		if closest and game.peek("wScriptRunning") == 0:
			break
	assert closest, "she never came"
	where = game.position()
	assert abs(closest[0] - where[0]) + abs(closest[1] - where[1]) == 1, "she stops next to the player"
	game.wait(60)
	assert game.event_flag("EVENT_MET_GOLDENROD_UNDERGROUND_STYLIST")
	assert stylist_position(game) is None, "she walks off screen"
	game.warp(STYLIST_MAP, *ladder) # down the ladder again
	game.wait(30)
	game.step(step)
	game.wait(90)
	assert "look new" not in game.screen_text(), "only once"
	assert game.position() == where
	game.warp(STYLIST_MAP, *STYLIST_SPOT)
	game.wait(30)
	assert stylist_position(game) == (7, 20), "back in her booth"
