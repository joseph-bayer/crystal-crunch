	object_const_def
	const VIRIDIANFORESTNORTHGATE_GRAMPS

ViridianForestNorthGate_MapScripts:
	def_scene_scripts

	def_callbacks

ViridianForestNorthGateGrampsScript:
	jumptextfaceplayer ViridianForestNorthGateGrampsText

ViridianForestNorthGateGrampsText:
	text "There's a man in"
	line "the museum who"
	para "says he can teach"
	line "strange-looking"
	cont "#MON new moves."
	done

ViridianForestNorthGate_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  4,  0, ROUTE_2, 6
	warp_event  5,  0, ROUTE_2, 7
	warp_event  4,  7, VIRIDIAN_FOREST, 1
	warp_event  5,  7, VIRIDIAN_FOREST, 2

	def_coord_events

	def_bg_events

	def_object_events
	object_event  2,  5, SPRITE_GRAMPS, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_SCRIPT, 0, ViridianForestNorthGateGrampsScript, -1
