	object_const_def
	const ROUTE3_FISHER1
	const ROUTE3_YOUNGSTER1
	const ROUTE3_YOUNGSTER2
	const ROUTE3_FISHER2
; New Kanto trainers: begin
	const ROUTE3_HIKER_BRUCE
	const ROUTE3_BLACKBELT_MANFORD
	const ROUTE3_BLACKBELT_ANDER
	const ROUTE3_HIKER_DWIGHT
	const ROUTE3_YOUNGSTER_REGIS
; New Kanto trainers: end
	const ROUTE3_WILD_MON_1
	const ROUTE3_WILD_MON_2
	const ROUTE3_WILD_MON_3
	const ROUTE3_WILD_MON_4

Route3_MapScripts:
	def_scene_scripts

	def_callbacks

TrainerFirebreatherOtis:
	trainer FIREBREATHER, OTIS, EVENT_BEAT_FIREBREATHER_OTIS, FirebreatherOtisSeenText, FirebreatherOtisBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext FirebreatherOtisAfterBattleText
	waitbutton
	closetext
	end

TrainerYoungsterWarren:
	trainer YOUNGSTER, WARREN, EVENT_BEAT_YOUNGSTER_WARREN, YoungsterWarrenSeenText, YoungsterWarrenBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext YoungsterWarrenAfterBattleText
	waitbutton
	closetext
	end

TrainerYoungsterJimmy:
	trainer YOUNGSTER, JIMMY, EVENT_BEAT_YOUNGSTER_JIMMY, YoungsterJimmySeenText, YoungsterJimmyBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext YoungsterJimmyAfterBattleText
	waitbutton
	closetext
	end

TrainerFirebreatherBurt:
	trainer FIREBREATHER, BURT, EVENT_BEAT_FIREBREATHER_BURT, FirebreatherBurtSeenText, FirebreatherBurtBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext FirebreatherBurtAfterBattleText
	waitbutton
	closetext
	end
; New Kanto trainers: begin

TrainerHikerBruce:
	trainer HIKER, BRUCE, EVENT_BEAT_HIKER_BRUCE, HikerBruceSeenText, HikerBruceBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext HikerBruceAfterBattleText
	waitbutton
	closetext
	end

TrainerBlackbeltManford:
	trainer BLACKBELT_T, MANFORD, EVENT_BEAT_BLACKBELT_MANFORD, BlackbeltManfordSeenText, BlackbeltManfordBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext BlackbeltManfordAfterBattleText
	waitbutton
	closetext
	end

TrainerBlackbeltAnder:
	trainer BLACKBELT_T, ANDER, EVENT_BEAT_BLACKBELT_ANDER, BlackbeltAnderSeenText, BlackbeltAnderBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext BlackbeltAnderAfterBattleText
	waitbutton
	closetext
	end

TrainerHikerDwight:
	trainer HIKER, DWIGHT, EVENT_BEAT_HIKER_DWIGHT, HikerDwightSeenText, HikerDwightBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext HikerDwightAfterBattleText
	waitbutton
	closetext
	end

TrainerYoungsterRegis:
	trainer YOUNGSTER, REGIS, EVENT_BEAT_YOUNGSTER_REGIS, YoungsterRegisSeenText, YoungsterRegisBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext YoungsterRegisAfterBattleText
	waitbutton
	closetext
	end
; New Kanto trainers: end

Route3MtMoonSquareSign:
	jumptext Route3MtMoonSquareSignText

FirebreatherOtisSeenText:
	text "Ah! The weather's"
	line "as fine as ever."
	done

FirebreatherOtisBeatenText:
	text "It's sunny, but"
	line "I'm all wet…"
	done

FirebreatherOtisAfterBattleText:
	text "When it rains,"
	line "it's hard to get"
	cont "ignition…"
	done

YoungsterWarrenSeenText:
	text "Hmmm… I don't know"
	line "what to do…"
	done

YoungsterWarrenBeatenText:
	text "I knew I'd lose…"
	done

YoungsterWarrenAfterBattleText:
	text "You looked strong."

	para "I was afraid to"
	line "take you on…"
	done

YoungsterJimmySeenText:
	text "I can run like the"
	line "wind!"
	done

YoungsterJimmyBeatenText:
	text "Blown away!"
	done

YoungsterJimmyAfterBattleText:
	text "I wear shorts the"
	line "whole year round."

	para "That's my fashion"
	line "policy."
	done

FirebreatherBurtSeenText:
	text "Step right up and"
	line "take a look!"
	done

FirebreatherBurtBeatenText:
	text "Yow! That's hot!"
	done

FirebreatherBurtAfterBattleText:
	text "The greatest fire-"
	line "breather in KANTO,"
	cont "that's me."

	para "But not the best"
	line "trainer…"
	done

Route3MtMoonSquareSignText:
	text "MT.MOON SQUARE"

	para "Just go up the"
	line "stairs."
	done

; New Kanto trainers: begin
HikerBruceSeenText:
	text "My Bag is digging"
	line "into my shoulders!"
	cont "When that happens,"
	cont "I like to take a"

	para "break and battle!"
	done

HikerBruceBeatenText:
	text "Feh."
	done

HikerBruceAfterBattleText:
	text "All right, guess I"
	line "should carry my"
	cont "Bag again!"
	done

BlackbeltManfordSeenText:
	text "Slow down and give"
	line "me the chance to"
	cont "defeat you!"
	done

BlackbeltManfordBeatenText:
	text "Looks like I've"
	line "been beaten at my"
	cont "own game…"
	done

BlackbeltManfordAfterBattleText:
	text "Even though you're"
	line "young, you have"
	cont "the spirit of"
	cont "battle within. Did"
	cont "you train under a"
	cont "well-known master?"
	done

BlackbeltAnderSeenText:
	text "Wait a moment!"
	line "Come fight me!"
	done

BlackbeltAnderBeatenText:
	text "You did it…"
	done

BlackbeltAnderAfterBattleText:
	text "You came all the"
	line "way from Johto?"
	cont "You're persistent!"
	done

HikerDwightSeenText:
	text "Peace! …Huh? When"
	line "you meet strangers"
	cont "on the mountain,"
	cont "all you want is"
	cont "peace, right?"
	done

HikerDwightBeatenText:
	text "Peace--even though"
	line "I lost!"
	done

HikerDwightAfterBattleText:
	text "Exchanging playful"
	line "greetings with"
	cont "strangers… That's"
	cont "what mountains are"
	cont "all about!"
	done

YoungsterRegisSeenText:
	text "Youngster? How"
	line "rude! Call me"
	cont "Shorts Boy!"
	done

YoungsterRegisBeatenText:
	text "That is… Fail Boy…"
	done

YoungsterRegisAfterBattleText:
	text "Looks like I need"
	line "more training!"
	done

; New Kanto trainers: end
Route3_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event 52,  1, MOUNT_MOON, 1

	def_coord_events

	def_bg_events
	bg_event 49, 13, BGEVENT_READ, Route3MtMoonSquareSign

	def_object_events
	object_event 26, 12, SPRITE_FISHER, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 2, TrainerFirebreatherOtis, -1
	object_event 10,  7, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 3, TrainerYoungsterWarren, -1
	object_event 16,  3, SPRITE_YOUNGSTER, SPRITEMOVEDATA_SPINRANDOM_FAST, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 1, TrainerYoungsterJimmy, -1
	object_event 49,  5, SPRITE_FISHER, SPRITEMOVEDATA_SPINRANDOM_FAST, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 3, TrainerFirebreatherBurt, -1
; New Kanto trainers: begin
	object_event 14,  7, SPRITE_POKEFAN_M, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_TRAINER, 4, TrainerHikerBruce, -1
	object_event 20, 10, SPRITE_BLACK_BELT, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_TRAINER, 2, TrainerBlackbeltManford, -1
	object_event 36, 15, SPRITE_BLACK_BELT, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_TRAINER, 4, TrainerBlackbeltAnder, -1
	object_event 48, 15, SPRITE_POKEFAN_M, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_TRAINER, 4, TrainerHikerDwight, -1
	object_event 12,  4, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 4, TrainerYoungsterRegis, -1
; New Kanto trainers: end
; Wandering Pokemon. The species, form, shininess, level, DVs and held item are all rolled by
; RollOverworldMons when the map is entered; the sprite id only names which rolled slot this is.
; Palette 0 so they take the mon's own colors. Slots run static, then grass, then water -- the
; order RollOverworldMons fills them in -- so these have to stay numbered that way.
; The event flag is -1: whether one is standing here is decided by whether its slot holds a
; rolled mon, not by a flag.
	object_event 22, 13, SPRITE_OW_MON_1, SPRITEMOVEDATA_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
	object_event 52, 13, SPRITE_OW_MON_2, SPRITEMOVEDATA_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
	object_event 30, 13, SPRITE_OW_MON_3, SPRITEMOVEDATA_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
	object_event 50, 15, SPRITE_OW_MON_4, SPRITEMOVEDATA_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
