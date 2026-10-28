; Each normal.gbcpal is generated from the corresponding .png, and
; only the middle two colors are included, not black or white.
; Shiny palettes are defined directly, not generated.

EggPalettes:
; indexed by egg pattern (EGG_*_PATTERN), not by form. Eggs have no back sprite, so the normal
; colors come from front.gbcpal.
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/egg/front.gbcpal", middle_colors
INCLUDE "gfx/pokemon/egg/shiny.pal"
INCBIN	"gfx/pokemon/egg_elekid/front.gbcpal", middle_colors
INCLUDE "gfx/pokemon/egg_elekid/shiny.pal"
	assert_table_length NUM_EGG_PATTERNS

PikachuPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/pikachu/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/pikachu/shiny.pal"
; Surf and Fly Pikachu are drawn in greys (21,21,21 and 10,10,10) rather than in their own
; colors, so they take Pikachu's yellow and brown. Their generated normal.gbcpal files are
; luminance-ordered the same way, so the light and dark slots line up.
INCBIN	"gfx/pokemon/pikachu/normal.gbcpal", middle_colors ; Surf: greyscale art, Pikachu's colors
INCLUDE "gfx/pokemon/pikachu/shiny.pal"
INCBIN	"gfx/pokemon/pikachu/normal.gbcpal", middle_colors ; Fly: greyscale art, Pikachu's colors
INCLUDE "gfx/pokemon/pikachu/shiny.pal"
INCBIN	"gfx/pokemon/pikachu_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_PIKACHU_FORMS

CharmeleonPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/charmeleon/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/charmeleon/shiny.pal"
INCBIN	"gfx/pokemon/charmeleon_rocket/normal.gbcpal", middle_colors ; built from the front alone, see the Makefile
; A shiny Rocket Charmeleon takes the ordinary shiny Charmeleon colours, by design.
INCLUDE "gfx/pokemon/charmeleon/shiny.pal"
	assert_table_length NUM_CHARMELEON_FORMS

CharizardPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/charizard/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/charizard/shiny.pal"
INCBIN	"gfx/pokemon/charizard_rocket/normal.gbcpal", middle_colors ; built from the front alone, see the Makefile
; A shiny Rocket Charizard takes the ordinary shiny Charizard colours, by design.
INCLUDE "gfx/pokemon/charizard/shiny.pal"
	assert_table_length NUM_CHARIZARD_FORMS

CrobatPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/crobat/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/crobat/shiny.pal"
INCBIN	"gfx/pokemon/crobat_rocket/normal.gbcpal", middle_colors ; built from the front alone, see the Makefile
; A shiny Rocket Crobat takes the ordinary shiny Crobat colours, by design.
INCLUDE "gfx/pokemon/crobat/shiny.pal"
INCBIN	"gfx/pokemon/crobat_beta/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_CROBAT_FORMS

ElectrodePalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/electrode/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/electrode/shiny.pal"
INCBIN	"gfx/pokemon/electrode_rocket/normal.gbcpal", middle_colors ; built from the front alone, see the Makefile
; A shiny Rocket Electrode takes the ordinary shiny Electrode colours, by design.
INCLUDE "gfx/pokemon/electrode/shiny.pal"
	assert_table_length NUM_ELECTRODE_FORMS

ArbokPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/arbok/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/arbok/shiny.pal"
INCBIN	"gfx/pokemon/arbok_rocket/normal.gbcpal", middle_colors ; built from the front alone, see the Makefile
; A shiny Rocket Arbok takes the ordinary shiny Arbok colours, by design.
INCLUDE "gfx/pokemon/arbok/shiny.pal"
	assert_table_length NUM_ARBOK_FORMS

GolbatPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/golbat/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/golbat/shiny.pal"
INCBIN	"gfx/pokemon/golbat/normal.gbcpal", middle_colors ; the Rocket form is drawn in Golbat's colours
INCLUDE "gfx/pokemon/golbat_rocket/shiny.pal"
INCBIN	"gfx/pokemon/golbat_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_GOLBAT_FORMS

SnorlaxPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/snorlax/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/snorlax/shiny.pal"
INCBIN	"gfx/pokemon/snorlax_apricorn/normal.gbcpal", middle_colors ; built from the front alone, see the Makefile
INCLUDE "gfx/pokemon/snorlax/shiny.pal"
	assert_table_length NUM_SNORLAX_FORMS

SmearglePalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN "gfx/pokemon/smeargle/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/smeargle/shiny.pal"
INCLUDE "gfx/pokemon/smeargle_blue/normal.pal"
INCLUDE "gfx/pokemon/smeargle/shiny.pal"
INCLUDE "gfx/pokemon/smeargle_yellow/normal.pal"
INCLUDE "gfx/pokemon/smeargle/shiny.pal"
INCLUDE "gfx/pokemon/smeargle_purple/normal.pal"
INCLUDE "gfx/pokemon/smeargle/shiny.pal"
INCLUDE "gfx/pokemon/smeargle_green/normal.pal"
INCLUDE "gfx/pokemon/smeargle/shiny.pal"
INCLUDE "gfx/pokemon/smeargle_orange/normal.pal"
INCLUDE "gfx/pokemon/smeargle/shiny.pal"
	assert_table_length NUM_SMEARGLE_FORMS

ScytherPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN "gfx/pokemon/scyther/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/scyther/shiny.pal"
INCLUDE "gfx/pokemon/scyther_forest_green/normal.pal"
INCLUDE "gfx/pokemon/scyther/shiny.pal"
INCLUDE "gfx/pokemon/scyther_teal/normal.pal"
INCLUDE "gfx/pokemon/scyther/shiny.pal"
	assert_table_length NUM_SCYTHER_FORMS

ScizorPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN "gfx/pokemon/scizor/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/scizor/shiny.pal"
INCLUDE "gfx/pokemon/scizor_crimson/normal.pal"
INCLUDE "gfx/pokemon/scizor/shiny.pal"
INCLUDE "gfx/pokemon/scizor_dusty_rose/normal.pal"
INCLUDE "gfx/pokemon/scizor/shiny.pal"
	assert_table_length NUM_SCIZOR_FORMS

PinsirPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN "gfx/pokemon/pinsir/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/pinsir/shiny.pal"
INCLUDE "gfx/pokemon/pinsir_vine/normal.pal"
INCLUDE "gfx/pokemon/pinsir/shiny.pal"
INCLUDE "gfx/pokemon/pinsir_slate/normal.pal"
INCLUDE "gfx/pokemon/pinsir/shiny.pal"
	assert_table_length NUM_PINSIR_FORMS

MachopPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/machop/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/machop/shiny.pal"
INCBIN	"gfx/pokemon/machop_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_MACHOP_FORMS

MachokePalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/machoke/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/machoke/shiny.pal"
INCBIN	"gfx/pokemon/machoke_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_MACHOKE_FORMS

MachampPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/machamp/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/machamp/shiny.pal"
INCBIN	"gfx/pokemon/machamp_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_MACHAMP_FORMS

TentacoolPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/tentacool/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/tentacool/shiny.pal"
INCBIN	"gfx/pokemon/tentacool_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_TENTACOOL_FORMS

TentacruelPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/tentacruel/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/tentacruel/shiny.pal"
INCBIN	"gfx/pokemon/tentacruel_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_TENTACRUEL_FORMS

IgglybuffPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/igglybuff/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/igglybuff/shiny.pal"
INCBIN	"gfx/pokemon/igglybuff_beta/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_IGGLYBUFF_FORMS

JigglypuffPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/jigglypuff/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/jigglypuff/shiny.pal"
INCBIN	"gfx/pokemon/jigglypuff_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_JIGGLYPUFF_FORMS

WigglytuffPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/wigglytuff/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/wigglytuff/shiny.pal"
INCBIN	"gfx/pokemon/wigglytuff_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_WIGGLYTUFF_FORMS

NidoranMPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/nidoran_m/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/nidoran_m/shiny.pal"
INCBIN	"gfx/pokemon/nidoran_m_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_NIDORAN_M_FORMS

NidorinoPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/nidorino/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/nidorino/shiny.pal"
INCBIN	"gfx/pokemon/nidorino_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_NIDORINO_FORMS

NidokingPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/nidoking/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/nidoking/shiny.pal"
INCBIN	"gfx/pokemon/nidoking_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_NIDOKING_FORMS

NidoranFPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/nidoran_f/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/nidoran_f/shiny.pal"
INCBIN	"gfx/pokemon/nidoran_f_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_NIDORAN_F_FORMS

NidorinaPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/nidorina/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/nidorina/shiny.pal"
INCBIN	"gfx/pokemon/nidorina_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_NIDORINA_FORMS

NidoqueenPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/nidoqueen/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/nidoqueen/shiny.pal"
INCBIN	"gfx/pokemon/nidoqueen_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_NIDOQUEEN_FORMS

ZubatPalettes:
	; 3 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/zubat/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/zubat/shiny.pal"
INCBIN	"gfx/pokemon/zubat/normal.gbcpal", middle_colors ; looks plain
INCLUDE "gfx/pokemon/zubat/shiny.pal"
INCBIN	"gfx/pokemon/zubat_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_ZUBAT_FORMS

GeodudePalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/geodude/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/geodude/shiny.pal"
INCBIN	"gfx/pokemon/geodude_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_GEODUDE_FORMS

GravelerPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/graveler/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/graveler/shiny.pal"
INCBIN	"gfx/pokemon/graveler_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_GRAVELER_FORMS

GolemPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/golem/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/golem/shiny.pal"
INCBIN	"gfx/pokemon/golem_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_GOLEM_FORMS

ShellderPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/shellder/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/shellder/shiny.pal"
INCBIN	"gfx/pokemon/shellder_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_SHELLDER_FORMS

CloysterPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/cloyster/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/cloyster/shiny.pal"
INCBIN	"gfx/pokemon/cloyster_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_CLOYSTER_FORMS

GastlyPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/gastly/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/gastly/shiny.pal"
INCBIN	"gfx/pokemon/gastly_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_GASTLY_FORMS

HaunterPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/haunter/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/haunter/shiny.pal"
INCBIN	"gfx/pokemon/haunter_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_HAUNTER_FORMS

GengarPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/gengar/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/gengar/shiny.pal"
INCBIN	"gfx/pokemon/gengar_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_GENGAR_FORMS

KoffingPalettes:
	; 3 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/koffing/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/koffing/shiny.pal"
INCBIN	"gfx/pokemon/koffing/normal.gbcpal", middle_colors ; looks plain
INCLUDE "gfx/pokemon/koffing/shiny.pal"
INCBIN	"gfx/pokemon/koffing_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_KOFFING_FORMS

WeezingPalettes:
	; 3 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/weezing/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/weezing/shiny.pal"
INCBIN	"gfx/pokemon/weezing/normal.gbcpal", middle_colors ; the Rocket form is drawn in Weezing's colours
INCLUDE "gfx/pokemon/weezing/shiny.pal"
INCBIN	"gfx/pokemon/weezing_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_WEEZING_FORMS

HorseaPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/horsea/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/horsea/shiny.pal"
INCBIN	"gfx/pokemon/horsea_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_HORSEA_FORMS

SeadraPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/seadra/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/seadra/shiny.pal"
INCBIN	"gfx/pokemon/seadra_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_SEADRA_FORMS

KingdraPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/kingdra/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/kingdra/shiny.pal"
INCBIN	"gfx/pokemon/kingdra_beta/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_KINGDRA_FORMS

PsyduckPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/psyduck/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/psyduck/shiny.pal"
INCBIN	"gfx/pokemon/psyduck_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_PSYDUCK_FORMS

GolduckPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/golduck/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/golduck/shiny.pal"
INCBIN	"gfx/pokemon/golduck_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_GOLDUCK_FORMS

MagikarpPalettes:
	; 4 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/magikarp/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/magikarp/shiny.pal"
INCBIN	"gfx/pokemon/magikarp/normal.gbcpal", middle_colors ; the XS form is drawn in Magikarp's colours
INCLUDE "gfx/pokemon/magikarp/shiny.pal"
INCBIN	"gfx/pokemon/magikarp/normal.gbcpal", middle_colors ; the XL form is drawn in Magikarp's colours
INCLUDE "gfx/pokemon/magikarp/shiny.pal"
INCBIN	"gfx/pokemon/magikarp_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_MAGIKARP_FORMS

GyaradosPalettes:
	; 4 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/gyarados/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/gyarados/shiny.pal"
INCBIN	"gfx/pokemon/gyarados/normal.gbcpal", middle_colors ; looks plain
INCLUDE "gfx/pokemon/gyarados/shiny.pal"
INCBIN	"gfx/pokemon/gyarados/normal.gbcpal", middle_colors ; looks plain
INCLUDE "gfx/pokemon/gyarados/shiny.pal"
INCBIN	"gfx/pokemon/gyarados_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_GYARADOS_FORMS

StaryuPalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/staryu/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/staryu/shiny.pal"
INCBIN	"gfx/pokemon/staryu_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_STARYU_FORMS

StarmiePalettes:
	; 2 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/starmie/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/starmie/shiny.pal"
INCBIN	"gfx/pokemon/starmie_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_STARMIE_FORMS

PichuPalettes:
	; 4 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/pichu/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/pichu/shiny.pal"
INCBIN	"gfx/pokemon/pichu/normal.gbcpal", middle_colors ; looks plain
INCLUDE "gfx/pokemon/pichu/shiny.pal"
INCBIN	"gfx/pokemon/pichu/normal.gbcpal", middle_colors ; looks plain
INCLUDE "gfx/pokemon/pichu/shiny.pal"
INCBIN	"gfx/pokemon/pichu_beta/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_PICHU_FORMS

RaichuPalettes:
	; 4 middle palettes, normal and shiny, with 2 colors each
	table_width COLOR_SIZE * 2 * 2
INCBIN	"gfx/pokemon/raichu/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/raichu/shiny.pal"
INCBIN	"gfx/pokemon/raichu/normal.gbcpal", middle_colors ; looks plain
INCLUDE "gfx/pokemon/raichu/shiny.pal"
INCBIN	"gfx/pokemon/raichu/normal.gbcpal", middle_colors ; looks plain
INCLUDE "gfx/pokemon/raichu/shiny.pal"
INCBIN	"gfx/pokemon/raichu_rb/normal.gbcpal", middle_colors
INCLUDE "gfx/pokemon/dmg_shiny.pal"
	assert_table_length NUM_RAICHU_FORMS
