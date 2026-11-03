"""Slowpoke Well B1F: the wandering mon wait for the Rockets to leave, and the Rockets stay until
the well is cleared.

The wandering-mon objects there carry EVENT_SLOWPOKE_WELL_ROCKETS, read inverted: they appear only
once it is set. The check lost its result, so they showed with the Rockets still there, and a
battle against one ran `disappear`, which set that flag -- the Rockets' own. Leave the well (to
heal, say) and come back, and the Rockets were gone with the well never cleared."""


ROCKETS = ["SLOWPOKEWELLB1F_ROCKET1", "SLOWPOKEWELLB1F_ROCKET2", "SLOWPOKEWELLB1F_ROCKET3",
	"SLOWPOKEWELLB1F_ROCKET_GIRL"]
WILD_MONS = ["SLOWPOKEWELLB1F_WILD_MON_%d" % n for n in range(1, 5)]
ENTRANCE = ("SLOWPOKE_WELL_B1F", 17, 15)
TOWN_SPOT = ("AZALEA_TOWN", 31, 8) # in front of the well


def shown(game, objects):
	return [game.object_shown("SlowpokeWellB1F", name) for name in objects]


def kurt_has_gone_in(game):
	game.set_event_flag("EVENT_AZALEA_TOWN_SLOWPOKETAIL_ROCKET")


def test_no_wandering_mon_while_the_rockets_are_there(game):
	kurt_has_gone_in(game)
	game.warp(*ENTRANCE)
	assert all(shown(game, ROCKETS))
	assert not any(shown(game, WILD_MONS)), "wandering mon are out with the Rockets still there"


def test_wandering_mon_once_the_well_is_cleared(game):
	kurt_has_gone_in(game)
	game.set_event_flag("EVENT_SLOWPOKE_WELL_ROCKETS")
	game.set_event_flag("EVENT_CLEARED_SLOWPOKE_WELL")
	game.warp(*ENTRANCE)
	assert not any(shown(game, ROCKETS))
	assert any(shown(game, WILD_MONS)), "no wandering mon after the Rockets left"


def test_rockets_come_back_to_a_save_that_lost_them(game):
	"""A save from before the fix: a wandering-mon battle set the Rockets' flag, the well not
	cleared. Entering the well puts them back, and leaving and coming back keeps them."""
	kurt_has_gone_in(game)
	game.set_event_flag("EVENT_BEAT_ROCKET_GRUNTM_29") # partway through
	game.set_event_flag("EVENT_SLOWPOKE_WELL_ROCKETS")
	game.warp(*ENTRANCE)
	assert not game.event_flag("EVENT_SLOWPOKE_WELL_ROCKETS")
	assert all(shown(game, ROCKETS))
	assert not game.event_flag("EVENT_CLEARED_SLOWPOKE_WELL")

	game.warp(*TOWN_SPOT)
	game.warp(*ENTRANCE)
	assert all(shown(game, ROCKETS))
	assert game.event_flag("EVENT_BEAT_ROCKET_GRUNTM_29")


def test_cleared_well_stays_cleared(game):
	kurt_has_gone_in(game)
	game.set_event_flag("EVENT_SLOWPOKE_WELL_ROCKETS")
	game.set_event_flag("EVENT_CLEARED_SLOWPOKE_WELL")
	game.warp(*ENTRANCE)
	assert game.event_flag("EVENT_SLOWPOKE_WELL_ROCKETS")
	assert not any(shown(game, ROCKETS))
