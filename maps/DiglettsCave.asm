	object_const_def
	const DIGLETTSCAVE_POKEFAN_M
	const DIGLETTSCAVE_WILD_MON_1
	const DIGLETTSCAVE_WILD_MON_2
	const DIGLETTSCAVE_WILD_MON_3
	const DIGLETTSCAVE_WILD_MON_4

DiglettsCave_MapScripts:
	def_scene_scripts

	def_callbacks

DiglettsCavePokefanMScript:
	jumptextfaceplayer DiglettsCavePokefanMText

DiglettsCaveHiddenMaxRevive:
	hiddenitem MAX_REVIVE, EVENT_DIGLETTS_CAVE_HIDDEN_MAX_REVIVE

DiglettsCavePokefanMText:
	text "A bunch of DIGLETT"
	line "popped out of the"

	para "ground! That was"
	line "shocking."
	done

DiglettsCave_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  3, 33, VERMILION_CITY, 10
	warp_event  5, 31, DIGLETTS_CAVE, 5
	warp_event 15,  5, ROUTE_2, 5
	warp_event 17,  3, DIGLETTS_CAVE, 6
	warp_event 17, 33, DIGLETTS_CAVE, 2
	warp_event  3,  3, DIGLETTS_CAVE, 4

	def_coord_events

	def_bg_events
	bg_event  6, 11, BGEVENT_ITEM, DiglettsCaveHiddenMaxRevive

	def_object_events
	object_event  3, 31, SPRITE_POKEFAN_M, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, DiglettsCavePokefanMScript, -1
; Wandering Pokemon. The species, form, shininess, level, DVs and held item are all rolled by
; RollOverworldMons when the map is entered; the sprite id only names which rolled slot this is.
; Palette 0 so they take the mon's own colors. Slots run static, then grass, then water -- the
; order RollOverworldMons fills them in -- so these have to stay numbered that way.
; The event flag is -1: whether one is standing here is decided by whether its slot holds a
; rolled mon, not by a flag.
	object_event 15, 22, SPRITE_OW_MON_1, SPRITEMOVEDATA_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
	object_event  6, 15, SPRITE_OW_MON_2, SPRITEMOVEDATA_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
	object_event  2,  8, SPRITE_OW_MON_3, SPRITEMOVEDATA_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
	object_event 11, 19, SPRITE_OW_MON_4, SPRITEMOVEDATA_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
