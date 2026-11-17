	object_const_def
	const ROUTE6_POKEFAN_M1
	const ROUTE6_POKEFAN_M2
	const ROUTE6_POKEFAN_M3
; New Kanto trainers: begin
	const ROUTE6_CAMPER_VIRGIL
	const ROUTE6_PICNICKER_SELINA
; New Kanto trainers: end
	const ROUTE6_WILD_MON_1
	const ROUTE6_WILD_MON_2
	const ROUTE6_WILD_MON_3
	const ROUTE6_WILD_MON_4

Route6_MapScripts:
	def_scene_scripts

	def_callbacks

TrainerPokefanmRex:
	trainer POKEFANM, REX, EVENT_BEAT_POKEFANM_REX, PokefanmRexSeenText, PokefanmRexBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext PokefanmRexAfterBattleText
	waitbutton
	closetext
	end

TrainerPokefanmAllan:
	trainer POKEFANM, ALLAN, EVENT_BEAT_POKEFANM_ALLAN, PokefanmAllanSeenText, PokefanmAllanBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext PokefanmAllanAfterBattleText
	waitbutton
	closetext
	end
; New Kanto trainers: begin

TrainerCamperVirgil:
	trainer CAMPER, CAMPER_VIRGIL, EVENT_BEAT_CAMPER_VIRGIL, CamperVirgilSeenText, CamperVirgilBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext CamperVirgilAfterBattleText
	waitbutton
	closetext
	end

TrainerPicnickerSelina:
	trainer PICNICKER, SELINA, EVENT_BEAT_PICNICKER_SELINA, PicnickerSelinaSeenText, PicnickerSelinaBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext PicnickerSelinaAfterBattleText
	waitbutton
	closetext
	end
; New Kanto trainers: end

Route6PokefanMScript:
	jumptextfaceplayer Route6PokefanMText

Route6UndergroundPathSign:
	jumptext Route6UndergroundPathSignText

Route6PokefanMText:
	text "The road is closed"
	line "until the problem"

	para "at the POWER PLANT"
	line "is solved."
	done

Route6UndergroundPathSignText:
	text "UNDERGROUND PATH"

	para "CERULEAN CITY -"
	line "VERMILION CITY"
	done

PokefanmRexSeenText:
	text "My PHANPY is the"
	line "cutest in the"
	cont "world."
	done

PokefanmRexBeatenText:
	text "My PHANPY!"
	done

PokefanmRexAfterBattleText:
	text "Look how adorable"
	line "my PHANPY acts!"

	para "Isn't it cute"
	line "enough to make"
	cont "your heart melt?"
	done

PokefanmAllanSeenText:
	text "My TEDDIURSA is"
	line "the cutest in the"
	cont "world."
	done

PokefanmAllanBeatenText:
	text "My TEDDIURSA!"
	done

PokefanmAllanAfterBattleText:
	text "Look how adorable"
	line "my TEDDIURSA acts!"

	para "Isn't it cute"
	line "enough to make"
	cont "your heart melt?"
	done

; New Kanto trainers: begin
CamperVirgilSeenText:
	text "Walking along with"
	line "gear and your"
	cont "#MON gives a"
	cont "great feeling"

	para "of outdoor life!"
	done

CamperVirgilBeatenText:
	text "Yaha! I lost!"
	done

CamperVirgilAfterBattleText:
	text "Are you also on a"
	line "solo journey? See"
	cont "ya again sometime!"
	done

PicnickerSelinaSeenText:
	text "I'm headed out on a"
	line "picnic. Do you"
	cont "know why?"
	done

PicnickerSelinaBeatenText:
	text "You are pretty"
	line "good!"
	done

PicnickerSelinaAfterBattleText:
	text "The reason I'm"
	line "going on a picnic…"
	cont "It's cuz I really"
	cont "want to smell the"
	cont "fresh air… Y'know"
	cont "what I mean?"
	done

; New Kanto trainers: end
Route6_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event 17,  3, ROUTE_6_UNDERGROUND_PATH_ENTRANCE, 1
	warp_event  6,  1, ROUTE_6_SAFFRON_GATE, 3

	def_coord_events

	def_bg_events
	bg_event 19,  5, BGEVENT_READ, Route6UndergroundPathSign

	def_object_events
	object_event 17,  4, SPRITE_POKEFAN_M, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_SCRIPT, 2, Route6PokefanMScript, EVENT_ROUTE_5_6_POKEFAN_M_BLOCKS_UNDERGROUND_PATH
	object_event  9, 12, SPRITE_POKEFAN_M, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 0, TrainerPokefanmRex, -1
	object_event 10, 12, SPRITE_POKEFAN_M, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 0, TrainerPokefanmAllan, -1
; New Kanto trainers: begin
	object_event  4,  8, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_TRAINER, 3, TrainerCamperVirgil, -1
	object_event 11, 14, SPRITE_LASS, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_TRAINER, 4, TrainerPicnickerSelina, -1
; New Kanto trainers: end
; Wandering Pokemon. The species, form, shininess, level, DVs and held item are all rolled by
; RollOverworldMons when the map is entered; the sprite id only names which rolled slot this is.
; Palette 0 so they take the mon's own colors. Slots run static, then grass, then water -- the
; order RollOverworldMons fills them in -- so these have to stay numbered that way.
; The event flag is -1: whether one is standing here is decided by whether its slot holds a
; rolled mon, not by a flag.
	object_event 16, 15, SPRITE_OW_MON_1, SPRITEMOVEDATA_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
	object_event 15,  7, SPRITE_OW_MON_2, SPRITEMOVEDATA_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
	object_event  1,  7, SPRITE_OW_MON_3, SPRITEMOVEDATA_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
	object_event  2, 13, SPRITE_OW_MON_4, SPRITEMOVEDATA_SWIM_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
