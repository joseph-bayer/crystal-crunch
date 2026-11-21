; Red/Blue forms, and the Spaceworld beta forms that count as them. Each has one Special stat
; (its Sp.Atk and Sp.Def are both this base) and no gender.

MACRO rb_form
; species, form, Special base (0: its Red/Blue Special, from KantoMonSpecials)
	if \3 == 0
		assert \1 <= NUM_KANTO_POKEMON, "\1 has no Red/Blue Special; give it one"
	endc
	dw \1
	db \2, \3
	DEF NUM_RB_FORM_ROWS += 1
ENDM

	DEF NUM_RB_FORM_ROWS = 0
RBFormTable:
	rb_form PICHU,      PICHU_BETA_FORM,      35
	rb_form PIKACHU,    PIKACHU_RB_FORM,      0
	rb_form RAICHU,     RAICHU_RB_FORM,       0
	rb_form NIDORAN_F,  NIDORAN_F_RB_FORM,    0
	rb_form NIDORINA,   NIDORINA_RB_FORM,     0
	rb_form NIDOQUEEN,  NIDOQUEEN_RB_FORM,    0
	rb_form NIDORAN_M,  NIDORAN_M_RB_FORM,    0
	rb_form NIDORINO,   NIDORINO_RB_FORM,     0
	rb_form NIDOKING,   NIDOKING_RB_FORM,     0
	rb_form IGGLYBUFF,  IGGLYBUFF_BETA_FORM,  21
	rb_form JIGGLYPUFF, JIGGLYPUFF_RB_FORM,   0
	rb_form WIGGLYTUFF, WIGGLYTUFF_RB_FORM,   0
	rb_form ZUBAT,      ZUBAT_RB_FORM,        0
	rb_form GOLBAT,     GOLBAT_RB_FORM,       0
	rb_form CROBAT,     CROBAT_BETA_FORM,     80
	rb_form PSYDUCK,    PSYDUCK_RB_FORM,      0
	rb_form GOLDUCK,    GOLDUCK_RB_FORM,      0
	rb_form MACHOP,     MACHOP_RB_FORM,       0
	rb_form MACHOKE,    MACHOKE_RB_FORM,      0
	rb_form MACHAMP,    MACHAMP_RB_FORM,      0
	rb_form TENTACOOL,  TENTACOOL_RB_FORM,    0
	rb_form TENTACRUEL, TENTACRUEL_RB_FORM,   0
	rb_form GEODUDE,    GEODUDE_RB_FORM,      0
	rb_form GRAVELER,   GRAVELER_RB_FORM,     0
	rb_form GOLEM,      GOLEM_RB_FORM,        0
	rb_form SHELLDER,   SHELLDER_RB_FORM,     0
	rb_form CLOYSTER,   CLOYSTER_RB_FORM,     0
	rb_form GASTLY,     GASTLY_RB_FORM,       0
	rb_form HAUNTER,    HAUNTER_RB_FORM,      0
	rb_form GENGAR,     GENGAR_RB_FORM,       0
	rb_form KOFFING,    KOFFING_RB_FORM,      0
	rb_form WEEZING,    WEEZING_RB_FORM,      0
	rb_form HORSEA,     HORSEA_RB_FORM,       0
	rb_form SEADRA,     SEADRA_RB_FORM,       0
	rb_form KINGDRA,    KINGDRA_BETA_FORM,    95
	rb_form STARYU,     STARYU_RB_FORM,       0
	rb_form STARMIE,    STARMIE_RB_FORM,      0
	rb_form MAGIKARP,   MAGIKARP_RB_FORM,     0
	rb_form GYARADOS,   GYARADOS_RB_FORM,     0
	rb_form AERODACTYL, AERODACTYL_RB_FORM,   0
	assert NUM_RB_FORM_ROWS == 40, "RBFormTable should hold 36 RB forms and 4 beta forms"
