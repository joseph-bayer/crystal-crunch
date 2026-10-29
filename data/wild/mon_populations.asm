; Which maps carry a population of wandering mon, and what it draws from.
; See docs/overworld_pokemon.md. pop_mon is weight, species, level range, form, perks.

MonPopulations:

; Hidden Grove: one rare species per visit, four of them out, every one with better shiny odds.
; Uniform in intent; 100 does not split eight ways, so the first four take the remainder.
	def_population HIDDEN_GROVE, POP_REROLL_STATS, 4
; The island's land is the square of tiles 6..23 both ways, split into a north and a south half for testing.
	spawn_area  6,  6, 23, 14
	spawn_area  6, 15, 23, 23
	pop_mon 13, BULBASAUR,  12, 16, PLAIN_FORM,      OW_PERK_EXTRA_SHINY
	pop_mon 13, CHARMANDER, 12, 16, PLAIN_FORM,      OW_PERK_EXTRA_SHINY
	pop_mon 13, SQUIRTLE,   12, 16, PLAIN_FORM,      OW_PERK_EXTRA_SHINY
	pop_mon 13, CHIKORITA,  12, 16, PLAIN_FORM,      OW_PERK_EXTRA_SHINY
	pop_mon 12, CYNDAQUIL,  12, 16, PLAIN_FORM,      OW_PERK_EXTRA_SHINY
	pop_mon 12, TOTODILE,   12, 16, PLAIN_FORM,      OW_PERK_EXTRA_SHINY
	pop_mon 12, PIKACHU,    12, 16, PIKACHU_RB_FORM, OW_PERK_EXTRA_SHINY
	pop_mon 12, EEVEE,      12, 16, PLAIN_FORM,      OW_PERK_EXTRA_SHINY
	end_population

; The Bug Catching Contest, on the park as it is during the contest. The contest's own roster,
; weights and level ranges, line for line; Scyther and Pinsir take a random wild colour the way a
; grass encounter of theirs does. Species mode: every battle reshuffles what is out.
	def_population NATIONAL_PARK_BUG_CONTEST, POP_REROLL_SPECIES, 4
	spawn_area 5,  3,  12, 4  ; top really tall grass 1
	spawn_area 4,  10, 31, 17 ; top really tall grass 2
	spawn_area 4,  20, 31, 27 ; bottom tall grass 1
	spawn_area 10, 28, 25, 31 ; bottom tall grass 2
	pop_mon 20, CATERPIE,    7, 18, PLAIN_FORM,    0
	pop_mon 20, WEEDLE,      7, 18, PLAIN_FORM,    0
	pop_mon 10, METAPOD,     9, 18, PLAIN_FORM,    0
	pop_mon 10, KAKUNA,      9, 18, PLAIN_FORM,    0
	pop_mon  5, BUTTERFREE, 12, 15, PLAIN_FORM,    0
	pop_mon  5, BEEDRILL,   12, 15, PLAIN_FORM,    0
	pop_mon 10, VENONAT,    10, 16, PLAIN_FORM,    0
	pop_mon 10, PARAS,      10, 17, PLAIN_FORM,    0
	pop_mon  5, SCYTHER,    13, 14, POP_WILD_FORM, 0
	pop_mon  5, PINSIR,     13, 14, POP_WILD_FORM, 0
	end_population

; The Ruins of Alph Inner Chamber: Unown, once a puzzle is solved. Each takes a random unlocked
; letter, whatever the form column says, and none appear before (RollOverworldMons.RollUnownLetter).
; Every battle reshuffles all four, letters included. No spawn areas: anywhere on the floor.
	def_population RUINS_OF_ALPH_INNER_CHAMBER, POP_REROLL_STATS, 4
	pop_mon 100, UNOWN, 5, 5, PLAIN_FORM, 0
	end_population

	db -1 ; end
