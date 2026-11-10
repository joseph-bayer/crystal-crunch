"""The shiny chime: SFX_SHINE plays once, the first frame the player has control, when a wandering
mon on the map rolled shiny. wOverworldMonShinyPending holds one bit per slot (1 << slot).

* A slot that is emptied or overwritten after it rolled must take its bit with it, or the chime
  announces a shiny that isn't there. Three places do that: the spent slot after a swarm battle
  (RerollSwarmOverworldMons), a slot standing on the player after one (KeepSwarmClearOfPlayer),
  and a grass slot Raikou or Entei takes over (PlaceRoamingBeasts).
* A shiny Raikou or Entei never chimed: its placement doesn't go through the roll that notes a
  shiny.

These call the ROM's own routines directly (see harness.alt_shiny.call), with Rock Tunnel 1F's four
land wanderers to work on: a grass swarm map with room for all four map objects."""

from harness import alt_shiny as A
from harness import legendaries as L

ROUTE = "ROCK_TUNNEL_1F"
ROUTE_STAND = (15, 10)
ROUTE_SWARM = 13 # SWARM_GEODUDE_RB
SWARM_SEEDS = range(1, 200)

SPRITE_OW_MON = 0xc0
NUM_OW_MON_SLOTS = 4
OBJECTTYPE_WILDMON = 3 # constants/script_constants.asm

# constants/map_object_constants.asm
MAPOBJECT_SPRITE = 1
MAPOBJECT_Y_COORD = 2
MAPOBJECT_X_COORD = 3
MAPOBJECT_TYPE = 8
NUM_OBJECTS = 16

# constants/pokemon_data_constants.asm: wOverworldMonEncounters entries
OW_MON_ENCOUNTER_LENGTH = 10
OW_MON_FORM = 2


def on_route(game):
	game.warp(ROUTE, *ROUTE_STAND)


def encounter(game, slot, offset=0):
	return game.peek("wOverworldMonEncounters", slot * OW_MON_ENCOUNTER_LENGTH + offset)


def species(game, slot):
	return encounter(game, slot) | encounter(game, slot, 1) << 8


def make_shiny(game, slot):
	game.poke("wOverworldMonEncounters", encounter(game, slot, OW_MON_FORM) | A.SHINY_MASK,
		slot * OW_MON_ENCOUNTER_LENGTH + OW_MON_FORM)


def pending(game):
	return game.peek("wOverworldMonShinyPending")


def wanderer_objects(game):
	"""{slot: map object index} for the map's wandering mon."""
	_, first = game._address("wMapObjects")
	_, second = game._address("wMap1Object")
	length = second - first
	objects = {}
	for index in range(1, NUM_OBJECTS):
		sprite = game.peek("wMapObjects", index * length + MAPOBJECT_SPRITE)
		if SPRITE_OW_MON <= sprite < SPRITE_OW_MON + NUM_OW_MON_SLOTS:
			objects[sprite - SPRITE_OW_MON] = (index, index * length)
	return objects


def assert_pending_matches_the_map(game):
	"""Every bit still pending is a slot with a shiny standing in it."""
	for slot in range(NUM_OW_MON_SLOTS):
		if pending(game) & 1 << slot:
			assert species(game, slot), "slot %d is empty but still due a chime" % slot
			assert encounter(game, slot, OW_MON_FORM) & A.SHINY_MASK, \
				"slot %d isn't shiny but is due a chime" % slot


def test_spent_swarm_slot_is_not_announced(game):
	"""After a swarm battle every slot rerolls, and then the one just fought is emptied again. If
	that slot rolled shiny, the chime used to play for a mon that wasn't on the map."""
	game.poke("wActiveSwarms", ROUTE_SWARM)
	game.set_event_flag("EVENT_DEBUG_FORCE_SHINY_BEASTS") # every swarm mon rolls shiny
	on_route(game)
	saved = game.save_state()

	# A seed whose reroll makes two or more slots shiny. With the same seed, a plain roll shows
	# which: the swarm reroll only differs after the land slots, where the beasts go.
	for seed in SWARM_SEEDS:
		game.load_state(saved)
		game.seed_random(seed)
		A.call(game, "RollOverworldMons")
		rerolled_shiny = [slot for slot in range(NUM_OW_MON_SLOTS)
			if species(game, slot) and encounter(game, slot, OW_MON_FORM) & A.SHINY_MASK]
		if len(rerolled_shiny) >= 2:
			break
	else:
		raise AssertionError("no seed rerolled two swarm shinies")
	game.load_state(saved)
	game.seed_random(seed)

	fought = rerolled_shiny[0]
	index, _ = wanderer_objects(game)[fought]
	game.poke("wOverworldMonBattleObject", index)

	A.call(game, "RerollSwarmOverworldMons")

	assert not species(game, fought), "the mon just fought should sit out the reshuffle"
	assert not pending(game) & 1 << fought, "the spent slot is still due a chime"
	assert pending(game), "the other swarm shinies should still be due a chime"
	assert_pending_matches_the_map(game)


def test_slot_cleared_off_the_player_is_not_announced(game):
	on_route(game)
	slot = 2
	_, offset = wanderer_objects(game)[slot]
	assert game.peek("wMapObjects", offset + MAPOBJECT_TYPE) == OBJECTTYPE_WILDMON
	x, y = game.position()
	game.poke("wMapObjects", y + 4, offset + MAPOBJECT_Y_COORD)
	game.poke("wMapObjects", x + 4, offset + MAPOBJECT_X_COORD)
	assert species(game, slot), "the slot should have rolled a mon"
	make_shiny(game, slot)
	make_shiny(game, 1)
	game.poke("wOverworldMonShinyPending", 1 << slot | 1 << 1)

	A.call(game, "KeepSwarmClearOfPlayer")

	assert not species(game, slot), "the slot on the player's tile should be emptied"
	assert pending(game) == 1 << 1, "only the emptied slot should lose its chime"


def put_raikou_here(game, form):
	L.set_roam(game, 1, Species=A.species_id(game, "RAIKOU"), Level=40, Form=form)
	group, number = game.peek("wMapGroup"), game.peek("wMapNumber")
	L.set_roam(game, 1, MapGroup=group, MapNumber=number)
	L.set_roam(game, 2, Species=0)


def place_beasts(game):
	"""PlaceRoamingBeasts over Route 45's grass slots, 0 to 3, as RollOverworldMons calls it."""
	game.poke("wOverworldMonRerolling", 0)
	A.call(game, "PlaceRoamingBeasts", de=0, bc=NUM_OW_MON_SLOTS)
	slot = game.peek("wOverworldMonBeastSlots")
	assert slot, "Raikou should have taken a grass slot"
	return slot - 1


def test_plain_beast_takes_its_slots_chime_with_it(game):
	"""Raikou takes over a grass slot after the grass roll: a shiny that roll put there is gone."""
	on_route(game)
	for slot in range(NUM_OW_MON_SLOTS):
		assert species(game, slot), "every grass slot should have rolled a mon"
		make_shiny(game, slot)
	game.poke("wOverworldMonShinyPending", (1 << NUM_OW_MON_SLOTS) - 1)
	put_raikou_here(game, form=0)

	beast = place_beasts(game)

	assert pending(game) == ((1 << NUM_OW_MON_SLOTS) - 1) & ~(1 << beast), \
		"the slot Raikou took should lose its chime, and only that one"
	assert_pending_matches_the_map(game)


def test_shiny_beast_is_announced(game):
	on_route(game)
	game.poke("wOverworldMonShinyPending", 0)
	put_raikou_here(game, form=A.SHINY_MASK)

	beast = place_beasts(game)

	assert pending(game) == 1 << beast, "a shiny Raikou should be due a chime"
	assert_pending_matches_the_map(game)


def test_beast_put_back_after_a_swarm_battle_is_not_announced_again(game):
	"""A swarm reroll restores the beast rather than placing it: it was announced when it arrived."""
	on_route(game)
	put_raikou_here(game, form=A.SHINY_MASK)
	beast = place_beasts(game)
	A.call(game, "SaveRoamingBeasts")
	game.poke("wOverworldMonShinyPending", 0)

	game.poke("wOverworldMonRerolling", 1)
	A.call(game, "PlaceRoamingBeasts", de=0, bc=NUM_OW_MON_SLOTS)
	game.poke("wOverworldMonRerolling", 0)

	assert game.peek("wOverworldMonBeastSlots") == beast + 1, "Raikou should be back in its slot"
	assert not pending(game) & 1 << beast, "the restored Raikou shouldn't chime again"


def test_chime_plays_once_and_clears(game):
	on_route(game)
	game.poke("wOverworldMonShinyPending", 1 << 3)
	game.wait(10)
	assert pending(game) == 0, "the chime should have played and cleared every bit"
