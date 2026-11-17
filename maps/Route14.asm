	object_const_def
	const ROUTE14_POKEFAN_M1
	const ROUTE14_YOUNGSTER
	const ROUTE14_POKEFAN_M2
	const ROUTE14_KIM
; New Kanto trainers: begin
	const ROUTE14_TEACHER_CLARICE
	const ROUTE14_BIRD_KEEPER_JOSH
	const ROUTE14_SCHOOLBOY_TORIN
	const ROUTE14_SCHOOLBOY_CONNOR
	const ROUTE14_SCHOOLBOY_TRAVIS
; New Kanto trainers: end
	const ROUTE14_WILD_MON_1
	const ROUTE14_WILD_MON_2

Route14_MapScripts:
	def_scene_scripts

	def_callbacks

Kim:
	faceplayer
	opentext
	trade NPC_TRADE_KIM
	waitbutton
	closetext
	end

TrainerPokefanmCarter:
	trainer POKEFANM, CARTER, EVENT_BEAT_POKEFANM_CARTER, PokefanmCarterSeenText, PokefanmCarterBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext PokefanmCarterAfterBattleText
	waitbutton
	closetext
	end

TrainerBirdKeeperRoy:
	trainer BIRD_KEEPER, ROY, EVENT_BEAT_BIRD_KEEPER_ROY, BirdKeeperRoySeenText, BirdKeeperRoyBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext BirdKeeperRoyAfterBattleText
	waitbutton
	closetext
	end

TrainerPokefanmTrevor:
	trainer POKEFANM, TREVOR, EVENT_BEAT_POKEFANM_TREVOR, PokefanmTrevorSeenText, PokefanmTrevorBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext PokefanmTrevorAfterBattleText
	waitbutton
	closetext
	end
; New Kanto trainers: begin

TrainerTeacherClarice:
	trainer TEACHER, CLARICE, EVENT_BEAT_TEACHER_CLARICE, TeacherClariceSeenText, TeacherClariceBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext TeacherClariceAfterBattleText
	waitbutton
	closetext
	end

TrainerBirdKeeperJosh:
	trainer BIRD_KEEPER, BIRD_KEEPER_JOSH, EVENT_BEAT_BIRD_KEEPER_JOSH, BirdKeeperJoshSeenText, BirdKeeperJoshBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext BirdKeeperJoshAfterBattleText
	waitbutton
	closetext
	end

TrainerSchoolboyTorin:
	trainer SCHOOLBOY, TORIN, EVENT_BEAT_SCHOOLBOY_TORIN, SchoolboyTorinSeenText, SchoolboyTorinBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext SchoolboyTorinAfterBattleText
	waitbutton
	closetext
	end

TrainerSchoolboyConnor:
	trainer SCHOOLBOY, CONNOR, EVENT_BEAT_SCHOOLBOY_CONNOR, SchoolboyConnorSeenText, SchoolboyConnorBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext SchoolboyConnorAfterBattleText
	waitbutton
	closetext
	end

TrainerSchoolboyTravis:
	trainer SCHOOLBOY, TRAVIS, EVENT_BEAT_SCHOOLBOY_TRAVIS, SchoolboyTravisSeenText, SchoolboyTravisBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext SchoolboyTravisAfterBattleText
	waitbutton
	closetext
	end
; New Kanto trainers: end

PokefanmCarterSeenText:
	text "Let me tell you,"
	line "I had a hard time"

	para "catching my prized"
	line "#MON."
	done

PokefanmCarterBeatenText:
	text "Awaaah!"
	done

PokefanmCarterAfterBattleText:
	text "SQUIRTLE, CHARMAN-"
	line "DER and BULBASAUR…"

	para "I think that's a"
	line "well-balanced mix."
	done

BirdKeeperRoySeenText:
	text "My dream is to fly"
	line "with my beloved"
	cont "bird #MON."
	done

BirdKeeperRoyBeatenText:
	text "I can dream, but I"
	line "can't ever fly…"
	done

BirdKeeperRoyAfterBattleText:
	text "You have #MON"
	line "that know the HM"

	para "move FLY, don't"
	line "you? I envy you."
	done

PokefanmTrevorSeenText:
	text "Hi. Did you know…?"

	para "#MON get more"
	line "friendly if you"

	para "train them in a"
	line "place that they"
	cont "remember."
	done

PokefanmTrevorBeatenText:
	text "Where did I meet"
	line "this PSYDUCK?"
	done

PokefanmTrevorAfterBattleText:
	text "If only there were"
	line "an easy way to"

	para "identify where I"
	line "got my #MON…"
	done

; New Kanto trainers: begin
TeacherClariceSeenText:
	text "All right, let's"
	line "get started!"
	done

TeacherClariceBeatenText:
	text "All right! That"
	line "concludes today's"
	cont "battle."
	done

TeacherClariceAfterBattleText:
	text "Don't relax just"
	line "'cause you won."
	cont "Once you get home,"
	cont "you should do a"

	para "full review!"
	done

BirdKeeperJoshSeenText:
	text "I'm in the"
	line "featherweight"
	cont "class! …Huh? That"
	cont "doesn't sound very"
	cont "strong?"
	done

BirdKeeperJoshBeatenText:
	text "I lost as light as"
	line "a feather floats!"
	done

BirdKeeperJoshAfterBattleText:
	text "Maybe I should lie"
	line "and say I'm in the"
	cont "heavyweight class…"
	done

SchoolboyTorinSeenText:
	text "It's good to put"
	line "what you learn to"
	cont "use immediately!"
	done

SchoolboyTorinBeatenText:
	text "I see. I see."
	done

SchoolboyTorinAfterBattleText:
	text "All right! Next"
	line "time, I won't make"
	cont "any mistakes!"
	done

SchoolboyConnorSeenText:
	text "I can't wait to go"
	line "home!"
	done

SchoolboyConnorBeatenText:
	text "I was in too much"
	line "of a hurry."
	done

SchoolboyConnorAfterBattleText:
	text "Don't rush, and"
	line "take the road one"
	cont "step at a time."
	cont "Great advice!"
	done

SchoolboyTravisSeenText:
	text "Do you study after"
	line "school too?"
	done

SchoolboyTravisBeatenText:
	text "So strong…"
	done

SchoolboyTravisAfterBattleText:
	text "I should join your"
	line "study sessions!"
	done

; New Kanto trainers: end
Route14_MapEvents:
	db 0, 0 ; filler

	def_warp_events

	def_coord_events

	def_bg_events

	def_object_events
	object_event 11, 15, SPRITE_POKEFAN_M, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 3, TrainerPokefanmCarter, -1
	object_event 11, 27, SPRITE_YOUNGSTER, SPRITEMOVEDATA_SPINRANDOM_FAST, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 3, TrainerBirdKeeperRoy, -1
	object_event  6, 11, SPRITE_POKEFAN_M, SPRITEMOVEDATA_SPINRANDOM_FAST, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 3, TrainerPokefanmTrevor, -1
	object_event  7,  5, SPRITE_TEACHER, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 1, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 4, Kim, -1
; New Kanto trainers: begin
	object_event 15, 10, SPRITE_TEACHER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 3, TrainerTeacherClarice, -1
	object_event 16, 21, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 3, TrainerBirdKeeperJosh, -1
	object_event  4, 21, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 4, TrainerSchoolboyTorin, -1
	object_event  9, 19, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 4, TrainerSchoolboyConnor, -1
	object_event  4, 17, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 4, TrainerSchoolboyTravis, -1
; New Kanto trainers: end
; Wandering Pokemon. The species, form, shininess, level, DVs and held item are all rolled by
; RollOverworldMons when the map is entered; the sprite id only names which rolled slot this is.
; Palette 0 so they take the mon's own colors. Slots run static, then grass, then water -- the
; order RollOverworldMons fills them in -- so these have to stay numbered that way.
; The event flag is -1: whether one is standing here is decided by whether its slot holds a
; rolled mon, not by a flag.
	object_event  9,  3, SPRITE_OW_MON_1, SPRITEMOVEDATA_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
	object_event  5,  4, SPRITE_OW_MON_2, SPRITEMOVEDATA_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
