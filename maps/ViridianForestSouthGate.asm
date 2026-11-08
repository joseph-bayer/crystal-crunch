	object_const_def
	const VIRIDIANFORESTSOUTHGATE_LASS

ViridianForestSouthGate_MapScripts:
	def_scene_scripts

	def_callbacks

ViridianForestSouthGateLassScript:
	jumptextfaceplayer ViridianForestSouthGateLassText

ViridianForestSouthGateLassText:
	text "Are you going to"
	line "VIRIDIAN FOREST?"
	cont "Be careful, it's"
	cont "a natural maze!"
	done

ViridianForestSouthGate_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  4,  0, VIRIDIAN_FOREST, 4
	warp_event  5,  0, VIRIDIAN_FOREST, 4
	warp_event  4,  7, ROUTE_2, 8
	warp_event  5,  7, ROUTE_2, 8

	def_coord_events

	def_bg_events

	def_object_events
	object_event  7,  4, SPRITE_LASS, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, ViridianForestSouthGateLassScript, -1
