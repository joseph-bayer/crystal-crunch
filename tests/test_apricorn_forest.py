"""Apricorn Forest's clearing follows the time of day; the forest itself stays dark."""

from test_player_color import global_constant

NITE = 2 # wTimeOfDayPal on a PALETTE_NITE map


def test_clearing_follows_the_clock(game):
	"""The test ROM's clock reads day, which a map pinned to night would ignore."""
	game.warp("APRICORN_FOREST_CLEARING", 8, 17)
	assert game.peek("wTimeOfDayPal") & 3 == game.peek("wTimeOfDay") != NITE


def test_forest_stays_at_night(game):
	game.warp("APRICORN_FOREST", 13, 6)
	assert game.peek("wTimeOfDayPal") & 3 == NITE


def test_clearing_plays_tcg_club_2(game):
	"""The same forest music as Viridian and Ilex Forest."""
	game.warp("APRICORN_FOREST_CLEARING", 8, 17)
	game.wait(30)
	club_2 = global_constant("MUSIC_TCG_CLUB_2")
	assert game.peek("wMapMusic") == club_2
	assert game.peek("wMusicID") == club_2, "the song actually playing"
