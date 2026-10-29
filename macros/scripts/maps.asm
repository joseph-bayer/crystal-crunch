MACRO map_id
;\1: map id
	assert DEF(GROUP_\1) && DEF(MAP_\1), \
		"Missing 'map_const \1' in constants/map_constants.asm"
	db GROUP_\1, MAP_\1
ENDM

MACRO object_const_def
	const_def 2
ENDM

MACRO def_scene_scripts
	REDEF _NUM_SCENE_SCRIPTS EQUS "_NUM_SCENE_SCRIPTS_\@"
	db {_NUM_SCENE_SCRIPTS}
	const_def
	DEF {_NUM_SCENE_SCRIPTS} = 0
ENDM

MACRO scene_const
;\1: scene id constant
	const \1
	EXPORT \1
ENDM

MACRO scene_script
;\1: script pointer
;\2: scene id constant
	dw \1
	dw 0 ; filler
	if _NARG == 2
		scene_const \2
	else
		const_skip
	endc
	DEF {_NUM_SCENE_SCRIPTS} += 1
ENDM

MACRO def_callbacks
	REDEF _NUM_CALLBACKS EQUS "_NUM_CALLBACKS_\@"
	db {_NUM_CALLBACKS}
	DEF {_NUM_CALLBACKS} = 0
ENDM

MACRO callback
;\1: type: a MAPCALLBACK_* constant
;\2: script pointer
	dbw \1, \2
	DEF {_NUM_CALLBACKS} += 1
ENDM

MACRO def_warp_events
	REDEF _NUM_WARP_EVENTS EQUS "_NUM_WARP_EVENTS_\@"
	db {_NUM_WARP_EVENTS}
	DEF {_NUM_WARP_EVENTS} = 0
ENDM

MACRO warp_event
;\1: x: left to right, starts at 0
;\2: y: top to bottom, starts at 0
;\3: map id: from constants/map_constants.asm
;\4: warp destination: starts at 1
	db \2, \1, \4
	map_id \3
	DEF {_NUM_WARP_EVENTS} += 1
ENDM

MACRO def_coord_events
	REDEF _NUM_COORD_EVENTS EQUS "_NUM_COORD_EVENTS_\@"
	db {_NUM_COORD_EVENTS}
	DEF {_NUM_COORD_EVENTS} = 0
ENDM

MACRO coord_event
;\1: x: left to right, starts at 0
;\2: y: top to bottom, starts at 0
;\3: scene id: a SCENE_* constant; controlled by setscene/setmapscene
;\4: script pointer
	db \3, \2, \1
	db 0 ; filler
	dw \4
	dw 0 ; filler
	DEF {_NUM_COORD_EVENTS} += 1
ENDM

MACRO def_bg_events
	REDEF _NUM_BG_EVENTS EQUS "_NUM_BG_EVENTS_\@"
	db {_NUM_BG_EVENTS}
	DEF {_NUM_BG_EVENTS} = 0
ENDM

MACRO bg_event
;\1: x: left to right, starts at 0
;\2: y: top to bottom, starts at 0
;\3: function: a BGEVENT_* constant
;\4: script pointer
	db \2, \1, \3
	dw \4
	DEF {_NUM_BG_EVENTS} += 1
ENDM

MACRO def_object_events
	REDEF _NUM_OBJECT_EVENTS EQUS "_NUM_OBJECT_EVENTS_\@"
	db {_NUM_OBJECT_EVENTS}
	DEF {_NUM_OBJECT_EVENTS} = 0
	; how many distinct Pokemon-colored sprites this map's objects show; see object_event
	REDEF _MON_PALS EQUS "_MON_PALS_\@"
	DEF {_MON_PALS} = 0
ENDM

MACRO ow_mon_map
;\1: map id
; Opens one map's list of runtime Pokemon. The entries that follow fill SPRITE_OW_MON_1, _2, ...
; in order, so they are positional -- do not reorder them without editing that map's objects.
	REDEF _NUM_OW_MONS EQUS "_NUM_OW_MONS_\@"
	map_id \1
	db {_NUM_OW_MONS}
	DEF {_NUM_OW_MONS} = 0
ENDM

MACRO ow_mon
;\1: species
;\2: form byte: a *_FORM constant, optionally combined with SHINY_MASK
	dw \1
	db \2
	DEF {_NUM_OW_MONS} += 1
	assert {_NUM_OW_MONS} <= NUM_OW_MON_SLOTS, \
		"a map declares more overworld mon than there are SPRITE_OW_MON_* slots"
ENDM

MACRO object_event
; TODO: Remove unused argument \7 (Old HOUR_1)
;\1: x: left to right, starts at 0
;\2: y: top to bottom, starts at 0
;\3: sprite: a SPRITE_* constant
;\4: movement function: a SPRITEMOVEDATA_* constant
;\5, \6: movement radius: x, y
;\7, \8: hour limits: h1, h2 (0-23)
;  * if h1 < h2, the object_event will only appear from h1 to h2
;  * if h1 > h2, the object_event will not appear from h2 to h1
;  * if h1 == h2, the object_event will always appear
;  * if h1 == -1, h2 is treated as a time-of-day value:
;    a combo of MORN, DAY, and/or NITE, or -1 to always appear
;\9: palette: a PAL_NPC_* constant, or 0 for sprite default
;\<10>: function: a OBJECTTYPE_* constant
;\<11>: sight range: applies to OBJECTTYPE_TRAINER
;\<12>: script pointer
;\<13>: event flag: an EVENT_* constant, or -1 to always appear
	db \3, \2 + 4, \1 + 4, \4
	dn \6, \5
	db \9, \8
	db \<10>
	db \<11>
	dw \<12>, \<13>
	; the dummy PlayerObjectTemplate object_event has no def_object_events
	if DEF(_NUM_OBJECT_EVENTS)
		DEF {_NUM_OBJECT_EVENTS} += 1
		assert {_NUM_OBJECT_EVENTS} <= NUM_OBJECTS - 2, \
			"a map has more object_events than NUM_OBJECTS - 2 (the player and the follower take two)"
		; Every sprite GetMonSprite draws as a Pokemon, with palette 0, takes its colors from one of
		; NUM_OW_MON_PALS entries, and one past them is drawn in palette 0, flat red. The entries
		; reset only when the map loads, so every such object on the map counts, not only those on
		; screen together. Repeats of one sprite id share an entry; each SPRITE_OW_MON_n is one slot,
		; so it counts once too. Variable sprites (dolls) can't be resolved here and are left out.
		if (\9) == 0 && ((\3) >= SPRITE_POKEMON && (\3) < SPRITE_OW_MON + NUM_OW_MON_SLOTS \
			|| (\3) == SPRITE_DAY_CARE_MON_1 || (\3) == SPRITE_DAY_CARE_MON_2 \
			|| (\3) == SPRITE_SUICUNE || (\3) == SPRITE_ENTEI || (\3) == SPRITE_RAIKOU)
			if !DEF({_MON_PALS}_{d:\3})
				DEF {_MON_PALS}_{d:\3} EQU 1
				DEF {_MON_PALS} += 1
				assert {_MON_PALS} <= NUM_OW_MON_PALS, \
					"a map shows more distinct Pokemon sprites than NUM_OW_MON_PALS; the extra is drawn red"
			endc
		endc
	endc
ENDM

MACRO trainer
;\1: trainer group
;\2: trainer id
;\3: flag: an EVENT_BEAT_* constant
;\4: seen text
;\5: win text
;\6: loss text
;\7: after-battle text
	dw \3
	db \1, \2
	dw \4, \5, \6, \7
ENDM

MACRO itemball
;\1: item: from constants/item_constants.asm
;\2: quantity: default 1
	if _NARG == 1
		itemball \1, 1
	else
		dw \1
		db \2
	endc
ENDM

MACRO hiddenitem
;\1: item: from constants/item_constants.asm
;\2: flag: an EVENT_* constant
	dw \2, \1
ENDM

MACRO elevfloor
;\1: floor: a FLOOR_* constant
;\2: warp destination: starts at 1
;\3: map id
	db \1, \2
	map_id \3
ENDM

MACRO conditional_event
;\1: flag: an EVENT_* constant
;\2: script pointer
	dw \1, \2
ENDM

MACRO cmdqueue
;\1: type: a CMDQUEUE_* constant
;\2: data pointer
	dbw \1, \2
	dw 0 ; filler
ENDM

MACRO stonetable
;\1: warp id
;\2: object_event id
;\3: script pointer
	db \1, \2
	dw \3
ENDM
