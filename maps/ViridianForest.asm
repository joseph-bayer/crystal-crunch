	object_const_def
	const VIRIDIANFOREST_MAX_POTION
	const VIRIDIANFOREST_MAX_ETHER
	const VIRIDIANFOREST_REVIVE

ViridianForest_MapScripts:
	def_scene_scripts

	def_callbacks

ViridianForestTrainerTips1Script:
	jumptext ViridianForestTrainerTips1Text

ViridianForestTrainerTips1Text:
	text "TRAINER TIPS"
	para "If you want to"
	line "avoid battles,"
	cont "stay away from"
	cont "grassy areas!"
	done

ViridianForestUseAntidoteSignScript:
	jumptext ViridianForestUseAntidoteSignText

ViridianForestUseAntidoteSignText:
	text "For poison, use"
	line "ANTIDOTE! Get it"
	cont "at #MON MARTs!"
	done

ViridianForestTrainerTips2Script:
	jumptext ViridianForestTrainerTips2Text

ViridianForestTrainerTips2Text:
	text "TRAINER TIPS"
	para "Contact PROF.OAK"
	line "via PC to get"
	cont "your #DEX"
	cont "evaluated!"
	done

ViridianForestTrainerTips3Script:
	jumptext ViridianForestTrainerTips3Text

ViridianForestTrainerTips3Text:
	text "TRAINER TIPS"
	para "No stealing of"
	line "#MON from"
	cont "other trainers!"
	cont "Catch only wild"
	cont "#MON!"
	done

ViridianForestTrainerTips4Script:
	jumptext ViridianForestTrainerTips4Text

ViridianForestTrainerTips4Text:
	text "TRAINER TIPS"
	para "Weaken #MON"
	line "before attempting"
	cont "capture!"
	para "When healthy,"
	line "they may escape!"
	done

ViridianForestLeavingSignScript:
	jumptext ViridianForestLeavingSignText

ViridianForestLeavingSignText:
	text "LEAVING"
	line "VIRIDIAN FOREST"
	cont "PEWTER CITY AHEAD"
	done

; Route 2's items, moved here when the forest took its west side. They keep Route 2's event flags,
; so an item already picked up on Route 2 isn't found again.
ViridianForestHiddenFullRestore:
	hiddenitem FULL_RESTORE, EVENT_ROUTE_2_HIDDEN_FULL_RESTORE

ViridianForestHiddenFullHeal:
	hiddenitem FULL_HEAL, EVENT_ROUTE_2_HIDDEN_FULL_HEAL

ViridianForestMaxPotion:
	itemball MAX_POTION

ViridianForestMaxEther:
	itemball MAX_ETHER

ViridianForestRevive:
	itemball REVIVE

ViridianForest_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  3,  2, VIRIDIAN_FOREST_NORTH_GATE, 3
	warp_event  4,  2, VIRIDIAN_FOREST_NORTH_GATE, 4
	warp_event 17, 49, VIRIDIAN_FOREST_SOUTH_GATE, 1
	warp_event 18, 49, VIRIDIAN_FOREST_SOUTH_GATE, 1
	warp_event 19, 49, VIRIDIAN_FOREST_SOUTH_GATE, 2
	warp_event 20, 49, VIRIDIAN_FOREST_SOUTH_GATE, 2

	def_coord_events

	def_bg_events
	bg_event 26, 42, BGEVENT_READ, ViridianForestTrainerTips1Script
	bg_event 18, 34, BGEVENT_READ, ViridianForestUseAntidoteSignScript
	bg_event 28, 19, BGEVENT_READ, ViridianForestTrainerTips2Script
	bg_event  6, 26, BGEVENT_READ, ViridianForestTrainerTips3Script
	bg_event 20, 47, BGEVENT_READ, ViridianForestTrainerTips4Script
	bg_event  4,  3, BGEVENT_READ, ViridianForestLeavingSignScript
	bg_event  3, 20, BGEVENT_ITEM, ViridianForestHiddenFullRestore
	bg_event 18, 44, BGEVENT_ITEM, ViridianForestHiddenFullHeal

	def_object_events
	object_event 27, 13, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, ViridianForestMaxPotion, EVENT_ROUTE_2_MAX_POTION
	object_event 14, 31, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, ViridianForestMaxEther, EVENT_ROUTE_2_HIDDEN_MAX_ETHER
	object_event  3, 33, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, ViridianForestRevive, EVENT_ROUTE_2_HIDDEN_REVIVE
; Wandering Pokemon, rolled by RollOverworldMons when the map is entered (see Route2.asm). The
; forest has no static mon and no water, so these are its four grass slots, in order.
	object_event 20, 10, SPRITE_OW_MON_1, SPRITEMOVEDATA_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
	object_event  5, 43, SPRITE_OW_MON_2, SPRITEMOVEDATA_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
	object_event 28, 26, SPRITE_OW_MON_3, SPRITEMOVEDATA_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
	object_event 23, 42, SPRITE_OW_MON_4, SPRITEMOVEDATA_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
