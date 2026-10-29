"""Raikou and Entei after the Elite Four.

A released beast that was knocked out, and not caught, roams again from its release route as a new
beast: level 50, HP 0 so its first battle rolls new stats, and a fresh shiny roll instead of its old
form. One that was only run from is still roaming and is left as it was; a caught one never comes
back. A battle that knocks a beast out or catches it clears its species and map, and a catch also
sets its caught flag; running only saves its HP."""

import pytest

from harness import constants
from harness import legendaries as L

GONE = 0xff # GROUP_N_A / MAP_N_A

# beast: (its struct, release route, caught flag)
BEASTS = {
	"RAIKOU": (1, "ROUTE_42", "EVENT_CAUGHT_RAIKOU"),
	"ENTEI": (2, "ROUTE_37", "EVENT_CAUGHT_ENTEI"),
}

# A roll that isn't shiny
NOT_SHINY_SEED = 0x0001


def released(game):
	L.get_ready(game, radio=False)
	game.set_event_flag("EVENT_RELEASED_THE_BEASTS")


def knocked_out(game, beast, form=0):
	"""What a battle that knocks the beast out leaves in its struct."""
	struct = BEASTS[beast][0]
	L.set_roam(game, struct, Species=0, Level=40, MapGroup=GONE, MapNumber=GONE, HP=0,
		DVs=(0x12, 0x34), Form=form)


@pytest.mark.parametrize("beast", list(BEASTS))
def test_knocked_out_beast_roams_again_at_50(game, beast):
	struct, route, _ = BEASTS[beast]
	released(game)
	knocked_out(game, beast, form=L.SHINY_MASK) # it was shiny before
	game.seed_random(NOT_SHINY_SEED)

	L.respawn(game)
	roamer = L.roam(game, struct)
	assert roamer["Species"], "%s should be roaming again" % beast
	assert L.index_of_id(game, roamer["Species"]) == L.species_index(beast)
	assert roamer["Level"] == 50
	assert (roamer["MapGroup"], roamer["MapNumber"]) == constants.maps()[route], \
		"it should start from its release route"
	assert roamer["HP"] == 0, "HP 0 makes its next battle roll new stats"
	assert not roamer["Form"] & L.SHINY_MASK, "its shininess should be rolled again, not kept"


@pytest.mark.parametrize("beast", list(BEASTS))
def test_respawned_beast_gets_a_shiny_roll(game, beast):
	struct = BEASTS[beast][0]
	released(game)
	knocked_out(game, beast)
	game.set_event_flag("EVENT_DEBUG_FORCE_SHINY_BEASTS") # the debug ROM's roll that always hits

	L.respawn(game)
	assert L.roam(game, struct)["Form"] & L.SHINY_MASK, "the respawn should roll its shininess"


@pytest.mark.parametrize("beast", list(BEASTS))
def test_beast_run_from_is_left_as_it_was(game, beast):
	struct, _, _ = BEASTS[beast]
	released(game)
	still_roaming = dict(Species=0x42, Level=44, MapGroup=10, MapNumber=3, HP=77,
		DVs=(0xab, 0xcd), Form=L.SHINY_MASK)
	L.set_roam(game, struct, **still_roaming)

	L.respawn(game)
	assert L.roam(game, struct) == still_roaming


@pytest.mark.parametrize("beast", list(BEASTS))
def test_caught_beast_stays_gone(game, beast):
	struct, _, caught = BEASTS[beast]
	released(game)
	knocked_out(game, beast)
	game.set_event_flag(caught)

	L.respawn(game)
	assert L.roam(game, struct)["Species"] == 0, "a caught %s should not come back" % beast


def test_beasts_not_yet_released_stay_unreleased(game):
	L.get_ready(game, radio=False)
	for beast in BEASTS:
		knocked_out(game, beast)

	L.respawn(game)
	for beast, (struct, _, _) in BEASTS.items():
		assert L.roam(game, struct)["Species"] == 0, \
			"%s shouldn't roam before the Burned Tower releases it" % beast
