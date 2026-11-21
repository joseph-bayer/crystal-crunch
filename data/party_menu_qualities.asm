MACRO partymenuqualities
	rept _NARG
		db PARTYMENUQUALITY_\1
		shift
	endr
	db -1 ; end
ENDM

PartyMenuQualityPointers:
; entries correspond to PARTYMENUACTION_* constants
	table_width 2
	dw .Default  ; PARTYMENUACTION_CHOOSE_POKEMON
	dw .Default  ; PARTYMENUACTION_HEALING_ITEM
	dw .Default  ; PARTYMENUACTION_SWITCH
	dw .TMHM     ; PARTYMENUACTION_TEACH_TMHM
	dw .Default  ; PARTYMENUACTION_MOVE
	dw .EvoStone ; PARTYMENUACTION_EVO_STONE
	dw .Gender   ; PARTYMENUACTION_GIVE_MON
	dw .Gender   ; PARTYMENUACTION_GIVE_MON_FEMALE
	dw .Default  ; PARTYMENUACTION_GIVE_ITEM
	dw .Gen1Tutor ; PARTYMENUACTION_GEN1_TUTOR
	assert_table_length NUM_PARTYMENUACTIONS

.Default:  partymenuqualities NICKNAMES, HP_BAR, HP_DIGITS, LEVEL, STATUS, FOLLOWER
.TMHM:     partymenuqualities NICKNAMES, TMHM_COMPAT,       LEVEL, STATUS
.EvoStone: partymenuqualities NICKNAMES, EVO_STONE_COMPAT,  LEVEL, STATUS
.Gender:   partymenuqualities NICKNAMES, GENDER,            LEVEL, STATUS
.Gen1Tutor: partymenuqualities NICKNAMES, GEN1_TUTOR_COMPAT, LEVEL, STATUS
