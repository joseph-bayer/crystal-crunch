	object_const_def
	const MUSEUM2F_YOUNGSTER
	const MUSEUM2F_GRAMPS
	const MUSEUM2F_SCIENTIST
	const MUSEUM2F_BRUNETTE_GIRL
	const MUSEUM2F_HIKER

Museum2F_MapScripts:
	def_scene_scripts

	def_callbacks

Museum2FSpaceShuttleSignScript:
	jumptext Museum2FSpaceShuttleSignText

Museum2FSpaceShuttleSignText:
	text "SPACE SHUTTLE"
	line "COLUMBIA"
	done

Museum2FMoonStoneSignScript:
	jumptext Museum2FMoonStoneSignText

Museum2FMoonStoneSignText:
	text "Meteorite that"
	line "fell on MT.MOON."
	cont "(MOON STONE)"
	done

Museum2FYoungsterScript:
	jumptextfaceplayer Museum2FYoungsterText

Museum2FYoungsterText:
	text "MOON STONE…"
	para "I understand"
	line "what's so special"
	cont "about it now!"
	done

Museum2FGrampsScript:
	jumptextfaceplayer Museum2FGrampsText

Museum2FGrampsText:
	text "July 20, 1969!"
	para "The 1st lunar"
	line "landing!"
	para "I bought a color"
	line "TV to watch it!"
	done

Museum2FScientistScript:
	jumptextfaceplayer Museum2FScientistText

Museum2FScientistText:
	text "The space exhibit"
	line "has been popular!"
	done

Museum2FBrunetteGirlScript:
	jumptextfaceplayer Museum2FBrunetteGirlText

Museum2FBrunetteGirlText:
	text "I want a PICHU"
	line "so my PIKACHU has"
	cont "someone to play" 
	cont "with!"

	para "I asked my Daddy"
	line "to catch me one!"
	done

Museum2FHikerScript:
	jumptextfaceplayer Museum2FHikerText

Museum2FHikerText:
	text "Yeah yeah, a PICHU"
	line "soon, I promise!"
	done

Museum2F_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  7,  7, MUSEUM_1F, 5

	def_coord_events

	def_bg_events
	bg_event 11, 2, BGEVENT_READ, Museum2FSpaceShuttleSignScript
	bg_event 2, 5, BGEVENT_READ, Museum2FMoonStoneSignScript

	def_object_events
	object_event  1,  7, SPRITE_YOUNGSTER, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 1, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, Museum2FYoungsterScript, -1
	object_event  0,  5, SPRITE_GRAMPS, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_DEFAULT, OBJECTTYPE_SCRIPT, 0, Museum2FGrampsScript, -1
	object_event  7,  5, SPRITE_SCIENTIST, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_GRAY, OBJECTTYPE_SCRIPT, 0, Museum2FScientistScript, -1
	object_event 11,  5, SPRITE_LASS, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_DEFAULT, OBJECTTYPE_SCRIPT, 0, Museum2FBrunetteGirlScript, -1
	object_event 12,  5, SPRITE_POKEFAN_M, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_DEFAULT, OBJECTTYPE_SCRIPT, 0, Museum2FHikerScript, -1
