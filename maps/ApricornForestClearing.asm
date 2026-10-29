	object_const_def
	const APRICORNFORESTCLEARING_FRUIT_TREE_RED
	const APRICORNFORESTCLEARING_FRUIT_TREE_BLU
	const APRICORNFORESTCLEARING_FRUIT_TREE_BLK
	const APRICORNFORESTCLEARING_FRUIT_TREE_WHT
	const APRICORNFORESTCLEARING_FRUIT_TREE_PNK
	const APRICORNFORESTCLEARING_FRUIT_TREE_GRN
	const APRICORNFORESTCLEARING_FRUIT_TREE_YLW
	const APRICORNFORESTCLEARING_BIG_SNORLAX

ApricornForestClearing_MapScripts:
	def_scene_scripts

	def_callbacks

ApricornForestClearingFruitTreeRed:
	fruittree FRUITTREE_APRICORN_FOREST_CLEARING_RED

ApricornForestClearingFruitTreeBlu:
	fruittree FRUITTREE_APRICORN_FOREST_CLEARING_BLU

ApricornForestClearingFruitTreeBlk:
	fruittree FRUITTREE_APRICORN_FOREST_CLEARING_BLK

ApricornForestClearingFruitTreeWht:
	fruittree FRUITTREE_APRICORN_FOREST_CLEARING_WHT

ApricornForestClearingFruitTreePnk:
	fruittree FRUITTREE_APRICORN_FOREST_CLEARING_PNK

ApricornForestClearingFruitTreeGrn:
	fruittree FRUITTREE_APRICORN_FOREST_CLEARING_GRN

ApricornForestClearingFruitTreeYlw:
	fruittree FRUITTREE_APRICORN_FOREST_CLEARING_YLW

ApricornForestClearingSnorlax:
; Wakes to the Poke Flute radio channel, the way Vermilion's does. Vermilion's SnorlaxAwake special
; also tests five hard-coded tiles beside its Snorlax; there is no proximity test here, because
; talking to this one already means standing beside it.
	opentext
	readmem wMapMusic
	ifequal MUSIC_POKE_FLUTE_CHANNEL, .Awake
	writetext ApricornForestClearingSnorlaxSleepingText
	waitbutton
	closetext
	end

.Awake:
	writetext ApricornForestClearingRadioNearSnorlaxText
	pause 15
	cry SNORLAX
	closetext
	loadvar VAR_BATTLETYPE, BATTLETYPE_FORCEITEM ; it holds its Leftovers, like Vermilion's
	loadwildmon SNORLAX, 50, SNORLAX_APRICORN_FORM
	startbattle
	disappear APRICORNFORESTCLEARING_BIG_SNORLAX
	setevent EVENT_APRICORN_FOREST_CLEARING_SNORLAX
	reloadmapafterbattle
	special CheckBattleCaughtResult
	iffalse .NotCaught
	setevent EVENT_CAUGHT_APRICORN_SNORLAX
.NotCaught:
	end

ApricornForestClearingSnorlaxSleepingText:
	text "SNORLAX is snoring"
	line "peacefully…"
	done

ApricornForestClearingRadioNearSnorlaxText:
	text "The #GEAR was"
	line "placed near the"
	cont "sleeping SNORLAX…"

	para "…"

	para "SNORLAX woke up!"
	done

ApricornForestClearing_MapEvents:
	db 0, 0 ; filler

	def_warp_events
; Right-edge carpets: the upper pair back into the forest, the lower one straight outside.
	warp_event  8, 19, APRICORN_FOREST, 3
	warp_event  9, 19, APRICORN_FOREST, 4
	warp_event 12,  6, APRICORN_FOREST_OUTSIDE, 3 ; the shore pad, which appears on the way out

	def_coord_events

	def_bg_events

	def_object_events
; One apricorn tree of each colour (data/items/fruit_trees.asm).
	object_event  6, 13, SPRITE_FRUIT_TREE, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ApricornForestClearingFruitTreeRed, -1
	object_event  6, 10, SPRITE_FRUIT_TREE, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ApricornForestClearingFruitTreeBlu, -1
	object_event 11, 10, SPRITE_FRUIT_TREE, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ApricornForestClearingFruitTreeBlk, -1
	object_event 11, 13, SPRITE_FRUIT_TREE, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ApricornForestClearingFruitTreeWht, -1
	object_event  7,  9, SPRITE_FRUIT_TREE, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ApricornForestClearingFruitTreePnk, -1
	object_event 10,  9, SPRITE_FRUIT_TREE, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ApricornForestClearingFruitTreeGrn, -1
	object_event 10, 14, SPRITE_FRUIT_TREE, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ApricornForestClearingFruitTreeYlw, -1
; Big sprite: this is its top-left tile, it covers 2x2.
	object_event  8,  2, SPRITE_BIG_SNORLAX_APRICORN, SPRITEMOVEDATA_BIGDOLLSYM, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ApricornForestClearingSnorlax, EVENT_APRICORN_FOREST_CLEARING_SNORLAX
