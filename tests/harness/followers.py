"""Helpers for the follower and Pokémon NPC tests: the debug party, object structs, species IDs and
the follower's colors."""

from functools import lru_cache

from . import constants

# The debug radio in the bedroom (3, 1), read from (3, 2) facing up. It gives a full party:
# Mewtwo, Mew, Lanturn, a beta Kingdra, Ditto and Ampharos.
RADIO_SPOT = (3, 2)

# object_struct layout (constants/map_object_constants.asm)
OBJECT_LENGTH = 0x22
OBJECT_SPRITE = 0x00
OBJECT_SPRITE_TILE = 0x02
OBJECT_FLAGS1 = 0x04
OBJECT_MAP_X = 0x10
OBJECT_MAP_Y = 0x11
OBJECT_PAL_INDEX = 0x21
NUM_OBJECT_STRUCTS = 14
FIRST_VRAM1_OBJECT_STRUCT = 9
INVISIBLE = 1 << 0

FOLLOWER_STRUCT = 1
OW_MON_PAL_LENGTH = 4
TILE_SIZE = 16

# Palette indexes (constants/sprite_data_constants.asm): the follower's sits just past the 33
# overworld palettes, and the Pokémon NPCs' four come after it. tests check these against the
# follower's own object.
PAL_OW_FOLLOWER = 0x21
PAL_OW_MON = PAL_OW_FOLLOWER + 1

# party_struct
PARTYMON_STRUCT_LENGTH = 48
SHINY_MASK = 0x80


@lru_cache(maxsize=None)
def species():
	"""{SPECIES: 16-bit index} from constants/pokemon_constants.asm."""
	return constants._consts(constants.ROOT / "constants" / "pokemon_constants.asm")


@lru_cache(maxsize=None)
def sprites():
	"""{SPRITE_NAME: id} from constants/sprite_constants.asm."""
	return constants._consts(constants.ROOT / "constants" / "sprite_constants.asm")


def take_radio_items(game):
	"""Read the debug radio, saying NO to every nickname."""
	game.warp("PLAYERS_HOUSE_2F", *RADIO_SPOT)
	game.press("up")
	game.press("a")
	text = ""
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


def start_warp(game, map_name, x, y):
	"""Warp the way game.warp does, but without waiting: for maps whose entry scene moves the
	player, so the caller can watch every frame from the start."""
	group, number = constants.maps()[map_name]
	game.poke("wMapGroup", group)
	game.poke("wMapNumber", number)
	game.poke("wXCoord", x)
	game.poke("wYCoord", y)
	game.poke("wDefaultSpawnpoint", 0xff)
	game.poke("hMapEntryMethod", 0xf1)
	game.poke("wMapStatus", 1)


def script_done(game):
	return game.peek("wScriptRunning") == 0 and game.peek("wWindowStackSize") == 0


def talk(game, direction):
	"""Face `direction`, press A, and press through the text until it closes."""
	game.press(direction)
	game.press("a")
	for _ in range(60):
		if script_done(game):
			return
		game.press("a")
	raise AssertionError("the text never closed. The screen:\n" + game.screen_text())


# Species IDs: the 8-bit handles the party stores, through the 16-bit conversion table

def index_of_id(game, mon_id):
	low, high = game.peek("wPokemonIndexTableEntries", (mon_id - 1) * 2, 2)
	return low | high << 8


def id_of_index(game, index):
	"""The ID currently mapped to a species index, or None if it has none right now."""
	entries = game.peek("wPokemonIndexTableEntries", 0, 2 * 100)
	for slot in range(100):
		if entries[slot * 2] | entries[slot * 2 + 1] << 8 == index:
			return slot + 1
	return None


def party_species(game):
	count = game.peek("wPartyCount")
	return [index_of_id(game, mon_id) for mon_id in game.peek("wPartySpecies", 0, count)]


def set_party_species(game, slot, mon_id):
	"""Make party slot (1-based) this species ID, in both the species list and the struct."""
	game.poke("wPartySpecies", mon_id, slot - 1)
	game.poke("wPartyMon1Species", mon_id, (slot - 1) * PARTYMON_STRUCT_LENGTH)


def party_form(game, slot):
	return game.peek("wPartyMon1Form", (slot - 1) * PARTYMON_STRUCT_LENGTH)


def set_party_form(game, slot, form):
	game.poke("wPartyMon1Form", form, (slot - 1) * PARTYMON_STRUCT_LENGTH)


# Object structs

def object_field(game, struct, field):
	return game.peek("wObjectStructs", struct * OBJECT_LENGTH + field)


def objects_with_sprite(game, sprite_id):
	return [s for s in range(NUM_OBJECT_STRUCTS) if object_field(game, s, OBJECT_SPRITE) == sprite_id]


def object_standing_tiles(game, struct):
	"""The graphics of an object's first standing frame (four tiles), from its fixed VRAM slot."""
	bank = 0 if struct < FIRST_VRAM1_OBJECT_STRUCT else 1
	first = object_field(game, struct, OBJECT_SPRITE_TILE) & 0x7f # the field also carries the walking frames bit
	base = 0x8000 + first * TILE_SIZE
	return [game.pyboy.memory[bank, base + i] for i in range(4 * TILE_SIZE)]


def overworld_mon_colors(game, struct):
	"""The two colors (four bytes) an overworld Pokémon object is drawn with."""
	pal_index = object_field(game, struct, OBJECT_PAL_INDEX)
	entry = pal_index - pal_ow_mon()
	assert 0 <= entry < 4, "struct %d isn't drawn in a Pokémon palette (index %d)" % (struct, pal_index)
	return game.peek("wOverworldMonPals", entry * OW_MON_PAL_LENGTH, OW_MON_PAL_LENGTH)


def pal_ow_mon():
	return PAL_OW_MON


def follower_colors(game):
	return game.peek("wFollowerPalette", 0, 4)
