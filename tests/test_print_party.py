"""The Photo Studio's printout of a party mon shows its Pokédex number.

The first page printed the species' 8-bit ID, which the 16-bit species tables hand out as species
are met, so a Mew in the party printed as No. 002 or the like. It now prints the species index,
as the stats screen does."""

from harness import alt_shiny as A
from harness.forms import set_party_field

MEW = 151
NUMBER_ROW = 0
NUMBER_COLUMN = 10 # after "№." at column 8


def test_printout_shows_the_dex_number(game):
	mew = A.species_id(game, "MEW")
	assert mew != MEW, "Mew's ID matches its number, so this proves nothing"
	game.poke("wPartySpecies", mew, 0)
	set_party_field(game, 0, "Species", mew)
	set_party_field(game, 0, "Form", 0)
	game.poke("wCurPartyMon", 0)
	game.poke("wCurPartySpecies", mew)
	# It waits on frames (graphics requests, WaitBGMap), so it starts from the main loop
	A.call(game, "PrintPartyMonPage1", must_return=False, frames=120, from_main_loop=True)
	line = game.screen_lines()[NUMBER_ROW]
	assert line[NUMBER_COLUMN:NUMBER_COLUMN + 3] == "%03d" % MEW, line
