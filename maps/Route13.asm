	object_const_def
	const ROUTE13_YOUNGSTER1
	const ROUTE13_YOUNGSTER2
	const ROUTE13_POKEFAN_M1
	const ROUTE13_POKEFAN_M2
	const ROUTE13_POKEFAN_M3
; New Kanto trainers: begin
	const ROUTE13_CAMPER_CLARK
	const ROUTE13_CAMPER_TANNER
	const ROUTE13_PICNICKER_PIPER
	const ROUTE13_PICNICKER_GINGER
; New Kanto trainers: end
	const ROUTE13_WILD_MON_1
	const ROUTE13_WILD_MON_2
	const ROUTE13_WILD_MON_3
	const ROUTE13_WILD_MON_4

Route13_MapScripts:
	def_scene_scripts

	def_callbacks

TrainerPokefanmAlex:
	trainer POKEFANM, ALEX, EVENT_BEAT_POKEFANM_ALEX, PokefanmAlexSeenText, PokefanmAlexBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext PokefanmAlexAfterBattleText
	waitbutton
	closetext
	end

TrainerPokefanmJoshua:
	trainer POKEFANM, JOSHUA, EVENT_BEAT_POKEFANM_JOSHUA, PokefanmJoshuaSeenText, PokefanmJoshuaBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext PokefanmJoshuaAfterBattleText
	waitbutton
	closetext
	end

TrainerBirdKeeperPerry:
	trainer BIRD_KEEPER, PERRY, EVENT_BEAT_BIRD_KEEPER_PERRY, BirdKeeperPerrySeenText, BirdKeeperPerryBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext BirdKeeperPerryAfterBattleText
	waitbutton
	closetext
	end

TrainerBirdKeeperBret:
	trainer BIRD_KEEPER, BRET, EVENT_BEAT_BIRD_KEEPER_BRET, BirdKeeperBretSeenText, BirdKeeperBretBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext BirdKeeperBretAfterBattleText
	waitbutton
	closetext
	end

TrainerHikerKenny:
	trainer HIKER, KENNY, EVENT_BEAT_HIKER_KENNY, HikerKennySeenText, HikerKennyBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext HikerKennyAfterBattleText
	waitbutton
	closetext
	end
; New Kanto trainers: begin

TrainerCamperClark:
	trainer CAMPER, CLARK, EVENT_BEAT_CAMPER_CLARK, CamperClarkSeenText, CamperClarkBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext CamperClarkAfterBattleText
	waitbutton
	closetext
	end

TrainerCamperTanner:
	trainer CAMPER, TANNER, EVENT_BEAT_CAMPER_TANNER, CamperTannerSeenText, CamperTannerBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext CamperTannerAfterBattleText
	waitbutton
	closetext
	end

TrainerPicnickerPiper:
	trainer PICNICKER, PIPER, EVENT_BEAT_PICNICKER_PIPER, PicnickerPiperSeenText, PicnickerPiperBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext PicnickerPiperAfterBattleText
	waitbutton
	closetext
	end

TrainerPicnickerGinger:
	trainer PICNICKER, GINGER, EVENT_BEAT_PICNICKER_GINGER, PicnickerGingerSeenText, PicnickerGingerBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext PicnickerGingerAfterBattleText
	waitbutton
	closetext
	end
; New Kanto trainers: end

Route13TrainerTips:
	jumptext Route13TrainerTipsText

Route13Sign:
	jumptext Route13SignText

Route13DirectionsSign:
	jumptext Route13DirectionsSignText

Route13HiddenCalcium:
	hiddenitem CALCIUM, EVENT_ROUTE_13_HIDDEN_CALCIUM

PokefanmAlexSeenText:
	text "Bow down before my"
	line "regal #MON!"
	done

PokefanmAlexBeatenText:
	text "How… How dare you"
	line "mock royalty!"
	done

PokefanmAlexAfterBattleText:
	text "Doesn't everyone"
	line "wish to someday be"
	cont "a king?"
	done

PokefanmJoshuaSeenText:
	text "Nihihi! Would you"
	line "like to battle my"
	cont "PIKACHU gang?"
	done

PokefanmJoshuaBeatenText:
	text "PI-PIKACHU!"
	done

PokefanmJoshuaAfterBattleText:
	text "You look like you"
	line "have many #MON,"

	para "but PIKACHU is"
	line "still the best."
	done

BirdKeeperPerrySeenText:
	text "Agility is the key"
	line "attribute of bird"
	cont "#MON."
	done

BirdKeeperPerryBeatenText:
	text "You beat me with"
	line "your speed…"
	done

BirdKeeperPerryAfterBattleText:
	text "Your #MON are"
	line "remarkably well-"
	cont "trained."
	done

BirdKeeperBretSeenText:
	text "Check out my #-"
	line "MON. Just look at"

	para "their coloring and"
	line "their plumage."
	done

BirdKeeperBretBeatenText:
	text "Shoot!"
	line "Not good enough!"
	done

BirdKeeperBretAfterBattleText:
	text "If you groom them,"
	line "#MON get happy."
	done

HikerKennySeenText:
	text "I should go to"
	line "ROCK TUNNEL to get"
	cont "myself an ONIX."
	done

HikerKennyBeatenText:
	text "I lost…"
	done

HikerKennyAfterBattleText:
	text "Geological fea-"
	line "tures don't appear"
	cont "to change."

	para "But they actually"
	line "change, little by"
	cont "little."
	done

Route13TrainerTipsText:
	text "TRAINER TIPS"

	para "Look! Right there,"
	line "at the left side"
	cont "of the post."
	done

Route13SignText:
	text "ROUTE 13"

	para "NORTH TO SILENCE"
	line "BRIDGE"
	done

Route13DirectionsSignText:
	text "NORTH TO LAVENDER"
	line "TOWN"

	para "WEST TO FUCHSIA"
	line "CITY"
	done

; New Kanto trainers: begin
CamperClarkSeenText:
	text "Collect water!"
	line "Don't let the fire"
	cont "go out!"

	para "Look out for wild"
	line "#MON!"

	para "Let's go, Campfire!"
	done

CamperClarkBeatenText:
	text "Pfuuuuhh…"
	done

CamperClarkAfterBattleText:
	text "It doesn't matter"
	line "what kind of prep"
	cont "you've done."

	para "If you lose, you"
	line "lose."
	done

CamperTannerSeenText:
	text "I can fit in a"
	line "quick battle while"
	cont "I'm in the midst of"
	cont "prepping a meal!"
	done

CamperTannerBeatenText:
	text "Oh, I'm hungry…"
	done

CamperTannerAfterBattleText:
	text "I figured that"
	line "would be easier…"
	done

PicnickerPiperSeenText:
	text "Hey, hey, how"
	line "about we bring out"
	cont "your #MON and"
	cont "mine for a battle?"
	done

PicnickerPiperBeatenText:
	text "Oh, that's too bad…"
	done

PicnickerPiperAfterBattleText:
	text "The way you were"
	line "walking with your"
	cont "#MON made me"
	cont "think that I'd win."
	done

PicnickerGingerSeenText:
	text "Why is it I always"
	line "get the urge to"
	cont "whistle when"
	cont "walking in nature?"
	done

PicnickerGingerBeatenText:
	text "Tweeee!"
	done

PicnickerGingerAfterBattleText:
	text "Instead of"
	line "communicating with"
	cont "#MON with"
	cont "words, you can"
	cont "communicate with"

	para "them through"
	line "whistling!"
	done

; New Kanto trainers: end
Route13_MapEvents:
	db 0, 0 ; filler

	def_warp_events

	def_coord_events

	def_bg_events
	bg_event 29, 13, BGEVENT_READ, Route13TrainerTips
	bg_event 41, 11, BGEVENT_READ, Route13Sign
	bg_event 17, 13, BGEVENT_READ, Route13DirectionsSign
	bg_event 30, 13, BGEVENT_ITEM, Route13HiddenCalcium

	def_object_events
	object_event 42,  6, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 2, TrainerBirdKeeperPerry, -1
	object_event 43,  6, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 2, TrainerBirdKeeperBret, -1
	object_event 32,  8, SPRITE_POKEFAN_M, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 3, TrainerPokefanmJoshua, -1
	object_event 14, 10, SPRITE_POKEFAN_M, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_TRAINER, 4, TrainerHikerKenny, -1
	object_event 25,  6, SPRITE_POKEFAN_M, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 4, TrainerPokefanmAlex, -1
; New Kanto trainers: begin
	object_event  5,  5, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_TRAINER, 1, TrainerCamperClark, -1
	object_event 17, 10, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_TRAINER, 4, TrainerCamperTanner, -1
	object_event 51, 10, SPRITE_LASS, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_TRAINER, 3, TrainerPicnickerPiper, -1
	object_event  4, 10, SPRITE_LASS, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_TRAINER, 2, TrainerPicnickerGinger, -1
; New Kanto trainers: end
; Wandering Pokemon. The species, form, shininess, level, DVs and held item are all rolled by
; RollOverworldMons when the map is entered; the sprite id only names which rolled slot this is.
; Palette 0 so they take the mon's own colors. Slots run static, then grass, then water -- the
; order RollOverworldMons fills them in -- so these have to stay numbered that way.
; The event flag is -1: whether one is standing here is decided by whether its slot holds a
; rolled mon, not by a flag.
	object_event 50,  3, SPRITE_OW_MON_1, SPRITEMOVEDATA_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
	object_event 47,  5, SPRITE_OW_MON_2, SPRITEMOVEDATA_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
	object_event 58,  6, SPRITE_OW_MON_3, SPRITEMOVEDATA_SWIM_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
	object_event 49, 14, SPRITE_OW_MON_4, SPRITEMOVEDATA_SWIM_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
