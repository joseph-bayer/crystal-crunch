"""Hidden Power: the type offset in the Hidden Power level byte's high nibble, Unown taking their
Hidden Power type, the Pokédex's ??? for Unown, and the GLYPH SHARD only working with an Unown in
the party.

Parties are written straight into memory and the routines are called directly (see
harness/alt_shiny.py's call)."""

from harness import alt_shiny as A
from harness import constants

TYPES = constants._consts(constants.ROOT / "constants" / "type_constants.asm")
# Hidden Power type indexes 0-15, in order: every type but Normal, Bird and the unused ones
HIDDEN_POWER_TYPES = [
	"FIGHTING", "FLYING", "POISON", "GROUND", "ROCK", "BUG", "DARK", "STEEL", "DRAGON",
	"FIRE", "WATER", "GRASS", "ELECTRIC", "PSYCHIC_TYPE", "ICE", "GHOST",
]
DEX_UNKNOWN_TYPE = 0xff
DEX_TYPE_UNKNOWN = 18 # the ??? row of the Pokédex type tiles

HP_LEVEL_MASK = 0x0f
CYCLES = 24


def field_offset(game, field):
	_, start = game._address("wPartyMon1")
	_, address = game._address("wPartyMon1" + field)
	return address - start


def set_party(game, mons):
	"""mons: (species, item or None, hp, hp level byte, (atk/def DV byte, spd/spc DV byte)) each."""
	_, first = game._address("wPartyMon1")
	_, second = game._address("wPartyMon2")
	length = second - first
	game.poke("wPartyCount", len(mons))
	for slot, (species, item, hp, hp_level, dvs) in enumerate(mons):
		species_id = A.species_id(game, species)
		game.poke("wPartySpecies", species_id, slot)
		base = slot * length
		game.poke("wPartyMon1", species_id, base + field_offset(game, "Species"))
		game.poke("wPartyMon1", A.item_id(game, item) if item else 0, base + field_offset(game, "Item"))
		game.poke("wPartyMon1", hp >> 8, base + field_offset(game, "HP"))
		game.poke("wPartyMon1", hp & 0xff, base + field_offset(game, "HP") + 1)
		game.poke("wPartyMon1", hp_level, base + field_offset(game, "HPLevel"))
		game.poke("wPartyMon1", dvs[0], base + field_offset(game, "DVs"))
		game.poke("wPartyMon1", dvs[1], base + field_offset(game, "DVs") + 1)
	game.poke("wPartySpecies", 0xff, len(mons))


def hp_level(game, slot):
	_, first = game._address("wPartyMon1")
	_, second = game._address("wPartyMon2")
	return game.peek("wPartyMon1HPLevel", slot * (second - first)) & HP_LEVEL_MASK


def run_cycles(game, cycles=CYCLES):
	for _ in range(cycles):
		A.call(game, "StepHiddenPower")


def dv_index(dvs):
	"""The Hidden Power type index the DVs give: Def & 3, plus (Atk & 3) << 2."""
	return (dvs[0] & 3) | (dvs[0] >> 4 & 3) << 2


# The GLYPH SHARD

def test_a_glyph_shard_does_nothing_without_an_unown(game):
	set_party(game, [("PIDGEY", "GLYPH_SHARD", 20, 0, (0xaa, 0xaa))])
	run_cycles(game)
	assert hp_level(game, 0) == 0


def test_a_fainted_unown_does_not_turn_the_glyph_shard_on(game):
	set_party(game, [
		("PIDGEY", "GLYPH_SHARD", 20, 0, (0xaa, 0xaa)),
		("UNOWN", None, 0, 0, (0xaa, 0xaa)),
	])
	run_cycles(game)
	assert hp_level(game, 0) == 0
	assert hp_level(game, 1) == 0


def test_a_glyph_shard_works_with_an_unown(game):
	set_party(game, [
		("PIDGEY", "GLYPH_SHARD", 20, 0, (0xaa, 0xaa)),
		("UNOWN", None, 20, 0, (0xaa, 0xaa)),
	])
	run_cycles(game)
	shard, unown = hp_level(game, 0), hp_level(game, 1)
	# Both gain from the shared roll; the holder also has its own roll.
	assert unown > 0
	assert shard > unown


# The type offset

def test_offset_zero_is_the_dvs_type(game):
	"""Every mon in an old save has 0 in the high nibble, so its type must still be its DVs'."""
	for atk_def in (0x00, 0x13, 0x2c, 0x3f, 0xa5, 0xff):
		dvs = (atk_def, 0xaa)
		set_party(game, [("PIDGEY", None, 20, 0x05, dvs)])
		_, mon = game._address("wPartyMon1")
		result = A.call(game, "GetMonStructHiddenPowerType", hl=mon)
		assert result["a"] == TYPES[HIDDEN_POWER_TYPES[dv_index(dvs)]], hex(atk_def)


def test_the_offset_picks_every_type(game):
	dvs = (0x2c, 0xaa)
	_, mon = game._address("wPartyMon1")
	seen = set()
	for offset in range(16):
		set_party(game, [("PIDGEY", None, 20, offset << 4 | 0x07, dvs)])
		result = A.call(game, "GetMonStructHiddenPowerType", hl=mon)
		assert result["a"] == TYPES[HIDDEN_POWER_TYPES[dv_index(dvs) ^ offset]], offset
		seen.add(result["a"])
	assert len(seen) == 16
	# the level is untouched
	assert hp_level(game, 0) == 0x07


# Unown take their Hidden Power type

def test_an_unown_is_its_hidden_power_type(game):
	dvs = (0x2c, 0xaa)
	offset = dv_index(dvs) ^ HIDDEN_POWER_TYPES.index("FIRE")
	set_party(game, [("UNOWN", None, 20, offset << 4, dvs)])
	game.poke("wBaseType1", TYPES["PSYCHIC_TYPE"])
	game.poke("wBaseType2", TYPES["PSYCHIC_TYPE"])
	_, mon = game._address("wPartyMon1")
	A.call(game, "SetMonStructUnownBaseTypes", hl=mon)
	assert game.peek("wBaseType1") == TYPES["FIRE"]
	assert game.peek("wBaseType2") == TYPES["FIRE"]


def test_other_species_keep_their_types(game):
	set_party(game, [("PIDGEY", None, 20, 0x30, (0x2c, 0xaa))])
	game.poke("wBaseType1", TYPES["NORMAL"])
	game.poke("wBaseType2", TYPES["FLYING"])
	_, mon = game._address("wPartyMon1")
	A.call(game, "SetMonStructUnownBaseTypes", hl=mon)
	assert game.peek("wBaseType1") == TYPES["NORMAL"]
	assert game.peek("wBaseType2") == TYPES["FLYING"]


def test_the_pokedex_shows_unown_as_unknown(game):
	game.poke("wCurSpecies", A.species_id(game, "UNOWN"))
	A.call(game, "SetUnownDexTypes")
	assert game.peek("wBaseType1") == DEX_UNKNOWN_TYPE
	assert game.peek("wBaseType2") == DEX_UNKNOWN_TYPE
	result = A.call(game, "GetMonTypeIndex", bc=DEX_UNKNOWN_TYPE)
	assert result["bc"] & 0xff == DEX_TYPE_UNKNOWN


def test_each_mon_rolls_for_itself(game):
	"""With an Unown in the party, every mon rolls its own 1/4 chance; one shared roll would keep
	two mons without a shard level with each other for ever."""
	set_party(game, [
		("PIDGEY", None, 20, 0, (0xaa, 0xaa)),
		("RATTATA", None, 20, 0, (0xaa, 0xaa)),
		("UNOWN", None, 20, 0, (0xaa, 0xaa)),
	])
	differed = False
	for _ in range(CYCLES):
		A.call(game, "StepHiddenPower")
		if hp_level(game, 0) != hp_level(game, 1):
			differed = True
	assert differed
	assert hp_level(game, 0) > 0 and hp_level(game, 1) > 0


# The Shaman

def open_hp_tools(game, item):
	game.warp("PLAYERS_HOUSE_2F", 2, 5)
	game.press("up")
	game.press("a")
	game.wait_for_text("HP TOOLS")
	game.choose("HP TOOLS")
	game.wait_for_text(item)
	game.choose(item)
	game.wait(90)


def test_hp_page_counts_as_her_first_talk(game):
	"""The debug HP PAGE sets her flags as if her first talk were done, shard included; with the
	page flag alone she handed a shard straight over, with no lead-in, the next time she was met."""
	open_hp_tools(game, "HP PAGE")
	assert game.event_flag("EVENT_HIDDEN_POWER_PAGE_UNLOCKED")
	assert game.event_flag("EVENT_GOT_GLYPH_SHARD_FROM_SHAMAN")


def test_her_first_talk_opens_with_her_greeting(game):
	game.set_event_flag("EVENT_MET_HIDDEN_POWER_SHAMAN")
	game.warp("RUINS_OF_ALPH_SHAMAN_CAVE", 2, 3)
	game.press("right")
	game.press("a")
	game.wait_for_text("So you came after")


# Unown's icon colors

def rgb(r, g, b):
	return r | g << 5 | b << 10


def icon_colors(game, species, form):
	address = A.scratch_address(game, 0)
	game.pyboy.memory[address] = form
	result = A.call(game, "GetArrangedMonIconColors", a=A.species_id(game, species), bc=address)
	return result["bc"], result["de"]


def test_unown_icons_draw_in_black_or_navy(game):
	"""Unown's icons (party, PC, overworld) are one ink round a white eye: black, or navy when
	shiny, whatever its pics' own colors are."""
	assert icon_colors(game, "UNOWN", 0) == (rgb(31, 31, 31), rgb(0, 0, 0))
	assert icon_colors(game, "UNOWN", A.SHINY_MASK | 5) == (rgb(31, 31, 31), rgb(0, 4, 18))


def test_other_icons_keep_their_own_colors(game):
	light, dark = icon_colors(game, "PIDGEY", 0)
	assert dark != rgb(0, 0, 0)


def test_overworld_shiny_unown_is_a_shade_darker(game):
	address = A.scratch_address(game, 0)
	for form, dark in ((0, rgb(0, 0, 0)), (A.SHINY_MASK | 5, rgb(0, 2, 14))):
		game.pyboy.memory[address] = form
		result = A.call(game, "GetArrangedOverworldMonColors", a=A.species_id(game, "UNOWN"), bc=address)
		assert result["de"] == dark
