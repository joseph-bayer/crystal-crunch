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
	dw 0 ; end
.End:
