AltShinyPalettes:
; Species with an alternate shiny. A mon that is shiny with ALT_SHINY_MASK set draws in these two
; colors instead of its shiny ones, whatever its form. Ends with 0.
	dw SCYTHER ; red, as Pokémon Stadium 2's shiny
INCLUDE "gfx/pokemon/scyther/alt_shiny.pal"
	dw SCIZOR ; gold, as Pokémon Colosseum's shiny
INCLUDE "gfx/pokemon/scizor/alt_shiny.pal"
	dw DRATINI ; Dragonite's orange
INCLUDE "gfx/pokemon/dratini/alt_shiny.pal"
	dw DRAGONAIR ; Dragonite's orange
INCLUDE "gfx/pokemon/dragonair/alt_shiny.pal"
	dw DRAGONITE ; Dragonair's blue
INCLUDE "gfx/pokemon/dragonite/alt_shiny.pal"
	dw MAGIKARP ; Gyarados's blue
INCLUDE "gfx/pokemon/magikarp/alt_shiny.pal"
	dw GYARADOS ; Shenron's green
INCLUDE "gfx/pokemon/gyarados/alt_shiny.pal"
	dw MARILL ; teal, as Pokémon Stadium 2's shiny
INCLUDE "gfx/pokemon/marill/alt_shiny.pal"
	dw AZUMARILL ; Marill's green shiny
INCLUDE "gfx/pokemon/azumarill/alt_shiny.pal"
	dw ARTICUNO
INCLUDE "gfx/pokemon/articuno/alt_shiny.pal"
	dw CHARIZARD ; Modern shiny
INCLUDE "gfx/pokemon/charizard/alt_shiny.pal"
	dw CHARMELEON
INCLUDE "gfx/pokemon/charmeleon/alt_shiny.pal"
	dw CHARMANDER
INCLUDE "gfx/pokemon/charmander/alt_shiny.pal"
	dw KAKUNA ; Stadium minigame harden/husk
INCLUDE "gfx/pokemon/kakuna/alt_shiny.pal"
	dw BEEDRILL ; Stadium 2 shiny
INCLUDE "gfx/pokemon/beedrill/alt_shiny.pal"
	dw WEEDLE
INCLUDE "gfx/pokemon/weedle/alt_shiny.pal"
	dw UMBREON
INCLUDE "gfx/pokemon/umbreon/alt_shiny.pal"
	dw ESPEON
INCLUDE "gfx/pokemon/espeon/alt_shiny.pal"
	dw FLAREON
INCLUDE "gfx/pokemon/flareon/alt_shiny.pal"
	dw JOLTEON
INCLUDE "gfx/pokemon/jolteon/alt_shiny.pal"
	dw VAPOREON
INCLUDE "gfx/pokemon/vaporeon/alt_shiny.pal"
	dw EEVEE
INCLUDE "gfx/pokemon/eevee/alt_shiny.pal"
	dw VENUSAUR
INCLUDE "gfx/pokemon/venusaur/alt_shiny.pal"
	dw IVYSAUR
INCLUDE "gfx/pokemon/ivysaur/alt_shiny.pal"
	dw BULBASAUR
INCLUDE "gfx/pokemon/bulbasaur/alt_shiny.pal"
	dw BLASTOISE
INCLUDE "gfx/pokemon/blastoise/alt_shiny.pal"
	dw WARTORTLE
INCLUDE "gfx/pokemon/wartortle/alt_shiny.pal"
	dw SQUIRTLE
INCLUDE "gfx/pokemon/squirtle/alt_shiny.pal"
	dw 0 ; end
.End:
	assert (.End - AltShinyPalettes - 2) / (2 + 2 * COLOR_SIZE) <= DEX_ALT_SHINY_CAPACITY, \
		"AltShinyPalettes has more rows than DEX_ALT_SHINY_CAPACITY Pokédex flags"
