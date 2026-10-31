; Macros to verify assumptions about the data or code

MACRO _redef_current_label
	if DEF(\1)
		PURGE \1
	endc
	if _NARG == 3 + (\3)
		DEF \1 EQUS "\<_NARG>"
	elif DEF(..)
		if .. - @ == 0
			DEF \1 EQUS "{..}"
		endc
	elif DEF(.)
		if . - @ == 0
			DEF \1 EQUS "{.}"
		endc
	endc
	if !DEF(\1)
		DEF \1 EQUS \2
		{\1}:
	endc
ENDM

MACRO table_width
	DEF CURRENT_TABLE_WIDTH = \1
	_redef_current_label CURRENT_TABLE_START, "._table_width\@", 2, \#
ENDM

MACRO assert_table_length
	DEF x = \1
	assert x * CURRENT_TABLE_WIDTH == @ - {CURRENT_TABLE_START}, \
		"{CURRENT_TABLE_START}: expected {d:x} entries, each {d:CURRENT_TABLE_WIDTH} bytes"
ENDM

MACRO list_start
	DEF list_index = 0
	_redef_current_label CURRENT_LIST_START, "._list_start\@", 1, \#
ENDM

MACRO li
	assert STRFIND(\1, "@") == -1, "String terminator \"@\" in list entry: \1"
	db \1, "@"
	DEF list_index += 1
ENDM

MACRO assert_list_length
	DEF x = \1
	assert x == list_index, \
		"{CURRENT_LIST_START}: expected {d:x} entries, got {d:list_index}"
ENDM

MACRO def_ow_wildmons
;\1: map id
; Opens one area's roster of wandering Pokemon. Fixed width like the grass tables, so the reader
; can index a time of day rather than walk the list.
	REDEF CURRENT_OW_WILDMONS_LABEL EQUS "._def_ow_wildmons_\1"
	REDEF CURRENT_OW_WILDMONS_MAP EQUS "\1"
	{CURRENT_OW_WILDMONS_LABEL}:
	map_id \1
ENDM

MACRO ow_wildmon
;\1: weight, out of 100 within its time of day
;\2: species
;\3: level, or LEVEL_FROM_BADGES +/- n to scale with badges
;\4: form byte: a *_FORM constant, optionally | SHINY_MASK for one that is always shiny
;\5: OW_PERK_* flags, or 0
;\6: a move it always knows on top of its level-up set, or NO_MOVE
	db \1
	dw \2
	db \3, \4, \5
	dw \6
ENDM

MACRO end_ow_wildmons
	assert OW_WILDDATA_LENGTH == @ - {CURRENT_OW_WILDMONS_LABEL}, \
		"def_ow_wildmons {CURRENT_OW_WILDMONS_MAP}: expected {d:OW_WILDDATA_LENGTH} bytes"
ENDM

MACRO def_population
;\1: map id
;\2: POP_REROLL_SPECIES or POP_REROLL_STATS
;\3: how many are out at once -- one SPRITE_OW_MON_n object each, capped by NUM_OW_MON_SLOTS
; Opens one map's population. Fixed width like the area tables, so a row can be skipped by adding
; a constant rather than walked. spawn_area rows come first, then pop_mon rows, then
; end_population.
	REDEF CURRENT_POP_LABEL EQUS "._def_population_\1"
	REDEF CURRENT_POP_MAP EQUS "\1"
	REDEF CURRENT_POP_AREAS = 0
	REDEF CURRENT_POP_MONS = 0
	{CURRENT_POP_LABEL}:
	map_id \1
	db \2, \3
ENDM

MACRO spawn_area
;\1, \2: top-left x, y  \3, \4: bottom-right x, y -- map tiles, inclusive
	assert CURRENT_POP_MONS == 0, "def_population {CURRENT_POP_MAP}: spawn_area after pop_mon"
	assert CURRENT_POP_AREAS < MAX_SPAWN_AREAS, "def_population {CURRENT_POP_MAP}: more than {d:MAX_SPAWN_AREAS} spawn areas"
	assert \1 <= \3 && \2 <= \4, "def_population {CURRENT_POP_MAP}: spawn_area corners are the wrong way round"
	db \1, \2, \3, \4
	REDEF CURRENT_POP_AREAS = CURRENT_POP_AREAS + 1
ENDM

MACRO pop_mon
;\1: weight, out of 100
;\2: species
;\3, \4: level range, inclusive
;\5: form byte: a *_FORM constant, optionally | SHINY_MASK for one that is always shiny
;\6: OW_PERK_* flags, or 0
	if CURRENT_POP_MONS == 0
		ds (MAX_SPAWN_AREAS - CURRENT_POP_AREAS) * SPAWN_AREA_LENGTH, 0 ; unused areas are all zero
	endc
	assert \3 <= \4, "def_population {CURRENT_POP_MAP}: a level range with its max below its min"
	assert \1 > 0, "def_population {CURRENT_POP_MAP}: a weight of zero can never be picked"
	db \1
	dw \2
	db \3, \4, \5, \6
	REDEF CURRENT_POP_MONS = CURRENT_POP_MONS + 1
	assert CURRENT_POP_MONS <= NUM_POP_MON, "def_population {CURRENT_POP_MAP}: more than {d:NUM_POP_MON} entries"
ENDM

MACRO end_population
; Pads the roster out to NUM_POP_MON. The padding is species 0, which is what the reader stops on.
	assert CURRENT_POP_MONS > 0, "def_population {CURRENT_POP_MAP}: no pop_mon rows"
	ds POP_DATA_LENGTH - (@ - {CURRENT_POP_LABEL}), 0
	assert POP_DATA_LENGTH == @ - {CURRENT_POP_LABEL}, "def_population {CURRENT_POP_MAP}: wrong size"
ENDM

MACRO swarm_def
;\1: the species that swarms
;\2: its form byte -- a *_FORM constant, optionally | SHINY_MASK for one that is always shiny
;\3: the map it swarms on
;\4: SWARM_GRASS or SWARM_WATER, the encounters it replaces, optionally | SWARM_ROCKET and/or
;    | SWARM_ALT_SHINY
;\5: optional: an event flag that must be set before the radio offers it, or SWARM_NO_GATE
;\6: optional: a move every mon of this swarm knows on top of its level-up moves
	dw \1
	db \2
	map_id \3
	assert !((\4) & ~(SWARM_TERRAIN_MASK | SWARM_ROCKET | SWARM_ALT_SHINY)), "unknown bits in swarm terrain \4"
	db \4
	IF _NARG >= 5
		dw \5
	ELSE
		dw SWARM_NO_GATE
	ENDC
	IF _NARG >= 6
		dw \6
	ELSE
		dw NO_MOVE
	ENDC
ENDM
DEF SWARM_ENTRY_LENGTH EQU 2 + 1 + 2 + 1 + 2 + 2

MACRO def_grass_wildmons
;\1: map id
	REDEF CURRENT_GRASS_WILDMONS_MAP EQUS "\1"
	REDEF CURRENT_GRASS_WILDMONS_LABEL EQUS "._def_grass_wildmons_\1"
{CURRENT_GRASS_WILDMONS_LABEL}:
	map_id \1
ENDM

MACRO end_grass_wildmons
	assert GRASS_WILDDATA_LENGTH == @ - {CURRENT_GRASS_WILDMONS_LABEL}, \
		"def_grass_wildmons {CURRENT_GRASS_WILDMONS_MAP}: expected {d:GRASS_WILDDATA_LENGTH} bytes"
ENDM

MACRO def_water_wildmons
;\1: map id
	REDEF CURRENT_WATER_WILDMONS_MAP EQUS "\1"
	REDEF CURRENT_WATER_WILDMONS_LABEL EQUS "._def_water_wildmons_\1"
{CURRENT_WATER_WILDMONS_LABEL}:
	map_id \1
ENDM

MACRO end_water_wildmons
	assert WATER_WILDDATA_LENGTH == @ - {CURRENT_WATER_WILDMONS_LABEL}, \
		"def_water_wildmons {CURRENT_WATER_WILDMONS_MAP}: expected {d:WATER_WILDDATA_LENGTH} bytes"
ENDM

MACRO jmp
	jp \#
	assert warn, (\<_NARG>) - @ > 127 || (\<_NARG>) - @ < -129, "jp can be jr"
ENDM
