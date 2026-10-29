	object_const_def
	const ICEPATHB2FBLACKTHORNSIDE_POKE_BALL
	const ICEPATHB2FBLACKTHORNSIDE_WILD_MON_1
	const ICEPATHB2FBLACKTHORNSIDE_WILD_MON_2
	const ICEPATHB2FBLACKTHORNSIDE_WILD_MON_3
	const ICEPATHB2FBLACKTHORNSIDE_WILD_MON_4

IcePathB2FBlackthornSide_MapScripts:
	def_scene_scripts

	def_callbacks

IcePathB2FBlackthornSideTMRest:
	itemball TM_REST

IcePathB2FBlackthornSideHiddenIceHeal:
	hiddenitem ICE_HEAL, EVENT_ICE_PATH_B2F_BLACKTHORN_SIDE_HIDDEN_ICE_HEAL

IcePathB2FBlackthornSide_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  3, 15, ICE_PATH_B1F, 8
	warp_event  3,  3, ICE_PATH_B3F, 2

	def_coord_events

	def_bg_events
	bg_event  2, 10, BGEVENT_ITEM, IcePathB2FBlackthornSideHiddenIceHeal

	def_object_events
	object_event  8, 16, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, IcePathB2FBlackthornSideTMRest, EVENT_ICE_PATH_B2F_BLACKTHORN_SIDE_TM_REST
; Wandering Pokemon. The species, form, shininess, level, DVs and held item are all rolled by
; RollOverworldMons when the map is entered; the sprite id only names which rolled slot this is.
; Palette 0 so they take the mon's own colors. Slots run static, then grass, then water -- the
; order RollOverworldMons fills them in -- so these have to stay numbered that way.
; The event flag is -1: whether one is standing here is decided by whether its slot
; holds a rolled mon, not by a flag.
	object_event  4,  4, SPRITE_OW_MON_1, SPRITEMOVEDATA_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
	object_event  1, 12, SPRITE_OW_MON_2, SPRITEMOVEDATA_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
	object_event  9, 11, SPRITE_OW_MON_3, SPRITEMOVEDATA_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
	object_event  9,  2, SPRITE_OW_MON_4, SPRITEMOVEDATA_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
