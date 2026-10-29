"""The follower and the Pokémon NPCs: which mon they show and in which colors.

The debug radio's party is Mewtwo, Mew, Lanturn, a beta Kingdra, Ditto and Ampharos; the follower is
picked by wFollowerPartySlot (1-based, 0 for nobody)."""

from harness import followers as F

# Blackthorn's Dragon Speech House: a Dratini NPC at (5, 5), talked to from (5, 6) facing up.
DRAGON_HOUSE = "BLACKTHORN_DRAGON_SPEECH_HOUSE"
DRAGON_HOUSE_SPOT = (5, 6)

# Azalea Gym: a teal Scyther NPC at (4, 7); objects only load near the player.
AZALEA_GYM_SPOT = (4, 8)

# A map with no Pokémon NPCs, for the follower alone.
PLAIN_MAP = "NEW_BARK_TOWN"
PLAIN_SPOT = (10, 12)

MEWTWO_SLOT = 1
LANTURN_SLOT = 3


def follow(game, slot, map_name, spot):
	"""Pick the follower and load a map, which works its colors out from scratch."""
	game.poke("wFollowerPartySlot", slot)
	game.warp(map_name, *spot)
	assert F.object_field(game, F.FOLLOWER_STRUCT, F.OBJECT_PAL_INDEX) == F.PAL_OW_FOLLOWER, (
		"the follower should be drawn in its own palette")


def the_one_npc(game, sprite):
	structs = F.objects_with_sprite(game, F.sprites()[sprite])
	assert len(structs) == 1, "expected one %s object, found %d" % (sprite, len(structs))
	return structs[0]


def test_follower_colors_change_with_the_follower_without_a_map_load(game):
	"""The Day-Care bug (c3129bd15): the follower changed while its object stayed out, and closing
	the text redrew it as the new mon in the old mon's colors. Changing the follower slot and then
	closing a text box does the same thing as the deposit."""
	F.take_radio_items(game)
	follow(game, MEWTWO_SLOT, DRAGON_HOUSE, DRAGON_HOUSE_SPOT)
	mewtwo_colors = F.follower_colors(game)
	mon_palettes = game.peek("wNumOverworldMonPals")

	game.poke("wFollowerPartySlot", LANTURN_SLOT)
	F.talk(game, "up") # the Dratini

	after_text = F.follower_colors(game)
	# The follower changing must not use up one of the map's four Pokémon colors
	assert game.peek("wNumOverworldMonPals") == mon_palettes

	follow(game, LANTURN_SLOT, DRAGON_HOUSE, DRAGON_HOUSE_SPOT)
	lanturn_colors = F.follower_colors(game)
	assert lanturn_colors != mewtwo_colors, "the test needs two mon with different colors"
	assert after_text == lanturn_colors, (
		"after the text closed the follower kept %s, not the new follower's %s"
		% (after_text, lanturn_colors))


def test_each_follower_has_its_own_colors(game):
	"""Every follower was drawn in one palette: the form lookup returned the form in the register
	that held the species, so the color lookup got the form (usually 0) as the species. Different
	species, and a shiny, must each get their own colors."""
	F.take_radio_items(game)
	follow(game, MEWTWO_SLOT, PLAIN_MAP, PLAIN_SPOT)
	mewtwo = F.follower_colors(game)
	follow(game, LANTURN_SLOT, PLAIN_MAP, PLAIN_SPOT)
	lanturn = F.follower_colors(game)
	assert mewtwo != lanturn, "Mewtwo and Lanturn followed in the same colors %s" % mewtwo

	F.set_party_form(game, LANTURN_SLOT, F.party_form(game, LANTURN_SLOT) | F.SHINY_MASK)
	follow(game, LANTURN_SLOT, PLAIN_MAP, PLAIN_SPOT)
	assert F.follower_colors(game) != lanturn, "a shiny Lanturn followed in the plain colors"


def test_nobody_following_means_no_follower_object(game):
	"""With nobody chosen to follow, an NPC sprite used to walk behind the player (cf216782a):
	the follower object got a placeholder sprite. Both with an empty party and with the choice
	cleared, the follower's object must have no sprite."""
	game.warp(PLAIN_MAP, *PLAIN_SPOT)
	assert game.peek("wPartyCount") == 0
	assert F.object_field(game, F.FOLLOWER_STRUCT, F.OBJECT_SPRITE) == 0, "something follows an empty party"

	F.take_radio_items(game)
	game.poke("wFollowerPartySlot", 0)
	game.warp(PLAIN_MAP, *PLAIN_SPOT)
	assert F.object_field(game, F.FOLLOWER_STRUCT, F.OBJECT_SPRITE) == 0, "something follows with nobody chosen"


def test_pokemon_npc_shows_its_own_species(game):
	"""Pokémon NPCs showed the wrong mon, such as Blackthorn's Dratini drawn as an Ekans
	(c1380be19). The Dratini NPC must look and be colored exactly like a Dratini follower."""
	F.take_radio_items(game)
	follow(game, MEWTWO_SLOT, DRAGON_HOUSE, DRAGON_HOUSE_SPOT)
	npc = the_one_npc(game, "SPRITE_OW_MON_1")
	npc_tiles = F.object_standing_tiles(game, npc)
	npc_colors = F.overworld_mon_colors(game, npc)

	# Make the follower a plain Dratini, using the ID the NPC's map gave the species
	dratini = F.id_of_index(game, F.species()["DRATINI"])
	assert dratini is not None, "the house loaded no Dratini at all, so its NPC isn't one"
	F.set_party_species(game, MEWTWO_SLOT, dratini)
	F.set_party_form(game, MEWTWO_SLOT, 0)
	follow(game, MEWTWO_SLOT, DRAGON_HOUSE, DRAGON_HOUSE_SPOT)

	assert F.object_standing_tiles(game, F.FOLLOWER_STRUCT) == npc_tiles, "the NPC isn't drawn as a Dratini"
	assert F.follower_colors(game) == npc_colors, "the NPC isn't colored as a Dratini"


def test_follower_form_leaves_pokemon_npcs_alone(game):
	"""A follower with a form changed the form of overworld mon of the same species (c1380be19).
	A plain Scyther following into Azalea Gym must leave the gym's teal Scyther teal."""
	F.take_radio_items(game)
	follow(game, MEWTWO_SLOT, "AZALEA_GYM", AZALEA_GYM_SPOT)
	npc = the_one_npc(game, "SPRITE_OW_MON_1")
	teal = F.overworld_mon_colors(game, npc)

	scyther = F.id_of_index(game, F.species()["SCYTHER"])
	assert scyther is not None, "the gym should have loaded Scyther"
	F.set_party_species(game, MEWTWO_SLOT, scyther)
	F.set_party_form(game, MEWTWO_SLOT, 0)
	follow(game, MEWTWO_SLOT, "AZALEA_GYM", AZALEA_GYM_SPOT)

	npc = the_one_npc(game, "SPRITE_OW_MON_1")
	assert F.overworld_mon_colors(game, npc) != F.follower_colors(game), (
		"the gym's Scyther took the plain follower's form")
	assert F.overworld_mon_colors(game, npc) == teal, "the gym's Scyther changed colors"
