	object_const_def
	const ROUTE21_SWIMMER_GIRL
	const ROUTE21_SWIMMER_GUY
	const ROUTE21_FISHER
; New Kanto trainers: begin
	const ROUTE21_FISHER_GIDEON
	const ROUTE21_BIRD_KEEPER_KINSLEY
; New Kanto trainers: end
	const ROUTE21_WILD_MON_1
	const ROUTE21_WILD_MON_2
	const ROUTE21_WILD_MON_3
	const ROUTE21_WILD_MON_4

Route21_MapScripts:
	def_scene_scripts

	def_callbacks

TrainerSwimmermSeth:
	trainer SWIMMERM, SETH, EVENT_BEAT_SWIMMERM_SETH, SwimmermSethSeenText, SwimmermSethBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext SwimmermSethAfterBattleText
	waitbutton
	closetext
	end

TrainerSwimmerfNikki:
	trainer SWIMMERF, NIKKI, EVENT_BEAT_SWIMMERF_NIKKI, SwimmerfNikkiSeenText, SwimmerfNikkiBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext SwimmerfNikkiAfterBattleText
	waitbutton
	closetext
	end

TrainerFisherArnold:
	trainer FISHER, ARNOLD, EVENT_BEAT_FISHER_ARNOLD, FisherArnoldSeenText, FisherArnoldBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext FisherArnoldAfterBattleText
	waitbutton
	closetext
	end
; New Kanto trainers: begin

TrainerFisherGideon:
	trainer FISHER, GIDEON, EVENT_BEAT_FISHER_GIDEON, FisherGideonSeenText, FisherGideonBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext FisherGideonAfterBattleText
	waitbutton
	closetext
	end

TrainerBirdKeeperKinsley:
	trainer BIRD_KEEPER, KINSLEY, EVENT_BEAT_BIRD_KEEPER_KINSLEY, BirdKeeperKinsleySeenText, BirdKeeperKinsleyBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext BirdKeeperKinsleyAfterBattleText
	waitbutton
	closetext
	end
; New Kanto trainers: end

SwimmermSethSeenText:
	text "Land ho! Gotta"
	line "keep going!"
	done

SwimmermSethBeatenText:
	text "Glug…"
	done

SwimmermSethAfterBattleText:
	text "This arrogant guy"
	line "was at CINNABAR's"
	cont "volcano."
	done

SwimmerfNikkiSeenText:
	text "If I win, you have"
	line "to help me with my"
	cont "suntan lotion!"
	done

SwimmerfNikkiBeatenText:
	text "I'm worried about"
	line "sunburn…"
	done

SwimmerfNikkiAfterBattleText:
	text "I have to watch"
	line "out for blemishes"
	cont "caused by the sun."
	done

FisherArnoldSeenText:
	text "I'm bored by fish-"
	line "ing. Let's battle!"
	done

FisherArnoldBeatenText:
	text "Utter failure…"
	done

FisherArnoldAfterBattleText:
	text "I'll just go back"
	line "to fishing…"
	done

; New Kanto trainers: begin
FisherGideonSeenText:
	text "Question is…did I"
	line "become a fisherman"
	cont "because I'm"
	cont "patient, or did I"
	cont "get more"

	para "patient because I'm"
	line "a fisherman?"
	done

FisherGideonBeatenText:
	text "Ummm… Hmmm…"
	done

FisherGideonAfterBattleText:
	text "What's the reason"
	line "you became a"
	cont "#MON TRAINER?"
	done

BirdKeeperKinsleySeenText:
	text "Surrounding"
	line "yourself with bird"
	cont "#MON makes you"
	cont "feel that someday"
	cont "you may fly, too!"
	done

BirdKeeperKinsleyBeatenText:
	text "I couldn't fly…"
	done

BirdKeeperKinsleyAfterBattleText:
	text "I guess I just"
	line "need to practice"
	cont "flapping my wings!"
	done

; New Kanto trainers: end
Route21_MapEvents:
	db 0, 0 ; filler

	def_warp_events

	def_coord_events

	def_bg_events

	def_object_events
	object_event 11, 16, SPRITE_SWIMMER_GIRL, SPRITEMOVEDATA_SPINRANDOM_FAST, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_TRAINER, 3, TrainerSwimmerfNikki, -1
	object_event  2, 30, SPRITE_SWIMMER_GUY, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 4, TrainerSwimmermSeth, -1
	object_event 14, 22, SPRITE_FISHER, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_TRAINER, 1, TrainerFisherArnold, -1
; New Kanto trainers: begin
	object_event  5, 14, SPRITE_FISHER, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_TRAINER, 0, TrainerFisherGideon, -1
	object_event  4, 15, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 3, TrainerBirdKeeperKinsley, -1
; New Kanto trainers: end
; Wandering Pokemon. The species, form, shininess, level, DVs and held item are all rolled by
; RollOverworldMons when the map is entered; the sprite id only names which rolled slot this is.
; Palette 0 so they take the mon's own colors. Slots run static, then grass, then water -- the
; order RollOverworldMons fills them in -- so these have to stay numbered that way.
; The event flag is -1: whether one is standing here is decided by whether its slot holds a
; rolled mon, not by a flag.
	object_event 11,  3, SPRITE_OW_MON_1, SPRITEMOVEDATA_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
	object_event  6,  9, SPRITE_OW_MON_2, SPRITEMOVEDATA_SWIM_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
	object_event 10, 27, SPRITE_OW_MON_3, SPRITEMOVEDATA_SWIM_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
	object_event  2, 18, SPRITE_OW_MON_4, SPRITEMOVEDATA_SWIM_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
