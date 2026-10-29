	object_const_def
	const CIANWOODCITY_STANDING_YOUNGSTER
	const CIANWOODCITY_POKEFAN_M
	const CIANWOODCITY_LASS
	const CIANWOODCITY_ROCK1
	const CIANWOODCITY_ROCK2
	const CIANWOODCITY_ROCK3
	const CIANWOODCITY_ROCK4
	const CIANWOODCITY_ROCK5
	const CIANWOODCITY_ROCK6
	const CIANWOODCITY_POKEFAN_F
	const CIANWOODCITY_EUSINE
	const CIANWOODCITY_SUICUNE
	const CIANWOODCITY_WILD_MON_1
	const CIANWOODCITY_WILD_MON_2
	const CIANWOODCITY_WILD_MON_3
	const CIANWOODCITY_MYSTERY_ISLAND_SAILOR

CianwoodCity_MapScripts:
	def_scene_scripts
	scene_script CianwoodCityNoop1Scene, SCENE_CIANWOODCITY_NOOP
	scene_script CianwoodCityNoop2Scene, SCENE_CIANWOODCITY_SUICUNE_AND_EUSINE
	scene_script CianwoodCityArriveFromIslandScene, SCENE_CIANWOODCITY_ARRIVE_FROM_ISLAND

	def_callbacks
	callback MAPCALLBACK_NEWMAP, CianwoodCityFlypointAndSuicuneCallback

CianwoodCityNoop1Scene:
	end

CianwoodCityNoop2Scene:
	end

; Stepping off the boat. The follower needs no movement of its own -- ApplyMovementToFollower queues
; the player's scripted steps for it, so it walks off one tile behind.
CianwoodCityArriveFromIslandScene:
	applymovement PLAYER, CianwoodCityPlayerDisembarkMovement
	setscene SCENE_CIANWOODCITY_NOOP
	end

CianwoodCityFlypointAndSuicuneCallback:
	setflag ENGINE_FLYPOINT_CIANWOOD
	setevent EVENT_EUSINE_IN_BURNED_TOWER
	checkevent EVENT_FOUGHT_EUSINE
	iffalse .Done
	disappear CIANWOODCITY_EUSINE
.Done:
	endcallback

CianwoodCitySuicuneAndEusine:
	turnobject PLAYER, UP
	showemote EMOTE_SHOCK, PLAYER, 15
	pause 15
	playsound SFX_WARP_FROM
	applymovement CIANWOODCITY_SUICUNE, CianwoodCitySuicuneApproachMovement
	turnobject PLAYER, DOWN
	pause 15
	playsound SFX_WARP_FROM
	applymovement CIANWOODCITY_SUICUNE, CianwoodCitySuicuneDepartMovement
	disappear CIANWOODCITY_SUICUNE
	pause 10
	setscene SCENE_CIANWOODCITY_NOOP
	clearevent EVENT_SAW_SUICUNE_ON_ROUTE_42
	setmapscene ROUTE_42, SCENE_ROUTE42_SUICUNE
	checkevent EVENT_FOUGHT_EUSINE
	iftrue .Done
	getfollowerdirection
	ifnotequal DOWN, .SkipFollower
	applymovement FOLLOWER, CianwoodMoveFollower
.SkipFollower
	turnobject FOLLOWER, DOWN
	setevent EVENT_FOUGHT_EUSINE
	playmusic MUSIC_MYSTICALMAN_ENCOUNTER
	appear CIANWOODCITY_EUSINE
	applymovement CIANWOODCITY_EUSINE, CianwoodCityEusineApproachMovement
	opentext
	writetext EusineSuicuneText
	waitbutton
	closetext
	winlosstext EusineBeatenText, 0
	setlasttalked CIANWOODCITY_EUSINE
	loadtrainer MYSTICALMAN, EUSINE
	startbattle
	dontrestartmapmusic
	reloadmapafterbattle
	playmusic MUSIC_MYSTICALMAN_ENCOUNTER
	opentext
	writetext EusineAfterText
	waitbutton
	closetext
	applymovement CIANWOODCITY_EUSINE, CianwoodCityEusineDepartMovement
	disappear CIANWOODCITY_EUSINE
	pause 20
	special FadeOutMusic
	playmapmusic
	pause 10
.Done:
	end

CianwoodCityChucksWife:
	faceplayer
	opentext
	checkevent EVENT_GOT_HM02_FLY
	iftrue .GotFly
	writetext ChucksWifeEasierToFlyText
	promptbutton
	checkevent EVENT_BEAT_CHUCK
	iftrue .BeatChuck
	writetext ChucksWifeBeatChuckText
	waitbutton
	closetext
	end

.BeatChuck:
	writetext ChucksWifeGiveHMText
	promptbutton
	verbosegiveitem HM_FLY
	iffalse .Done
	setevent EVENT_GOT_HM02_FLY
	writetext ChucksWifeFlySpeechText
	promptbutton
.GotFly:
	writetext ChucksWifeChubbyText
	waitbutton
.Done:
	closetext
	end

CianwoodCityYoungster:
	jumptextfaceplayer CianwoodCityYoungsterText

CianwoodCityPokefanM:
	jumptextfaceplayer CianwoodCityPokefanMText

CianwoodCityLass:
	jumptextfaceplayer CianwoodCityLassText

CianwoodCitySign:
	jumptext CianwoodCitySignText

CianwoodGymSign:
	jumptext CianwoodGymSignText

CianwoodPharmacySign:
	jumptext CianwoodPharmacySignText

CianwoodPhotoStudioSign:
	jumptext CianwoodPhotoStudioSignText

CianwoodPokeSeerSign:
	jumptext CianwoodPokeSeerSignText

CianwoodPokecenterSign:
	jumpstd PokecenterSignScript

CianwoodCityRock:
	jumpstd SmashRockScript

CianwoodCityHiddenRevive:
	hiddenitem REVIVE, EVENT_CIANWOOD_CITY_HIDDEN_REVIVE

CianwoodCityHiddenMaxEther:
	hiddenitem MAX_ETHER, EVENT_CIANWOOD_CITY_HIDDEN_MAX_ETHER

CianwoodCitySuicuneApproachMovement:
	set_sliding
	fast_jump_step DOWN
	fast_jump_step DOWN
	fast_jump_step RIGHT
	remove_sliding
	step_end

CianwoodCitySuicuneDepartMovement:
	set_sliding
	fast_jump_step RIGHT
	fast_jump_step UP
	fast_jump_step RIGHT
	fast_jump_step RIGHT
	remove_sliding
	step_end

CianwoodCityEusineApproachMovement:
	step UP
	step UP
	step UP
	step UP
	step_end

CianwoodCityEusineDepartMovement:
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step_end

CianwoodMoveFollower:
	step RIGHT
	step UP
	step_end

ChucksWifeEasierToFlyText:
	text "You crossed the"
	line "sea to get here?"

	para "That must have"
	line "been hard."

	para "It would be much"
	line "easier if your"

	para "#MON knew how"
	line "to FLY…"
	done

ChucksWifeBeatChuckText:
	text "But you can't use"
	line "FLY without this"
	cont "city's GYM BADGE."

	para "If you beat the"
	line "GYM LEADER here,"
	cont "come see me."

	para "I'll have a nice"
	line "gift for you."
	done

ChucksWifeGiveHMText:
	text "That's CIANWOOD's"
	line "GYM BADGE!"

	para "Then you should"
	line "take this HM."
	done

ChucksWifeFlySpeechText:
	text "Teach FLY to your"
	line "#MON."

	para "You will be able"
	line "to FLY instantly"

	para "to anywhere you"
	line "have visited."
	done

ChucksWifeChubbyText:
	text "My husband lost to"
	line "you, so he needs"
	cont "to train harder."

	para "That's good, since"
	line "he was getting a"
	cont "little chubby."
	done

CianwoodCityYoungsterText:
	text "If you use FLY,"
	line "you can get back"

	para "to OLIVINE in-"
	line "stantly."
	done

CianwoodCityPokefanMText:
	text "Boulders to the"
	line "north of town can"
	cont "be crushed."

	para "They may be hiding"
	line "something."

	para "Your #MON could"
	line "use ROCK SMASH to"
	cont "break them."
	done

CianwoodCityLassText:
	text "CHUCK, the GYM"
	line "LEADER, spars with"

	para "his fighting #-"
	line "MON."
	done

EusineSuicuneText:
	text "EUSINE: Yo,"
	line "<PLAYER>."

	para "Wasn't that"
	line "SUICUNE just now?"

	para "I only caught a"
	line "quick glimpse, but"

	para "I thought I saw"
	line "SUICUNE running on"
	cont "the waves."

	para "SUICUNE is beau-"
	line "tiful and grand."

	para "And it races"
	line "through towns and"

	para "roads at simply"
	line "awesome speeds."

	para "It's wonderful…"

	para "I want to see"
	line "SUICUNE up close…"

	para "I've decided."

	para "I'll battle you as"
	line "a trainer to earn"
	cont "SUICUNE's respect!"

	para "Come on, <PLAYER>."
	line "Let's battle now!"
	done

EusineBeatenText:
	text "I hate to admit"
	line "it, but you win."
	done

EusineAfterText:
	text "You're amazing,"
	line "<PLAYER>!"

	para "No wonder #MON"
	line "gravitate to you."

	para "I get it now."

	para "I'm going to keep"
	line "searching for"
	cont "SUICUNE."

	para "I'm sure we'll see"
	line "each other again."

	para "See you around!"
	done

CianwoodCitySignText:
	text "CIANWOOD CITY"

	para "A Port Surrounded"
	line "by Rough Seas"
	done

CianwoodGymSignText:
	text "CIANWOOD CITY"
	line "#MON GYM"

	para "LEADER: CHUCK"

	para "His Roaring Fists"
	line "Do the Talking"
	done

CianwoodPharmacySignText:
	text "500 Years of"
	line "Tradition"

	para "CIANWOOD CITY"
	line "PHARMACY"

	para "We Await Your"
	line "Medicinal Queries"
	done

CianwoodPhotoStudioSignText:
	text "CIANWOOD CITY"
	line "PHOTO STUDIO"

	para "Take a Snapshot as"
	line "a Keepsake!"
	done

CianwoodPokeSeerSignText:
	text "THE # SEER"
	line "AHEAD"
	done

CianwoodCityMysteryIslandSailorScript:
	faceplayer
	opentext
; One trip a day. The flag lives in wDailyFlags3, which CheckDailyResetTimer already clears when the
; RTC day rolls over, so nothing has to remember to reset it.
	checkflag ENGINE_MYSTERY_ISLAND
	iftrue .AlreadySailedToday
	writetext CianwoodCityMysteryIslandSailorAskText
	yesorno
	iffalse .Declined
	writetext CianwoodCityMysteryIslandSailorSetSailText
	waitbutton
	closetext
; RollMysteryIsland leaves the island index in wScriptVar and will not repeat the last trip's.
; warp needs a literal map, so the index has to be branched on -- a new island means one more
; ifequal here, and the highest index falls through.
	setflag ENGINE_MYSTERY_ISLAND
; Everyone boards before the warp. The canoe is the three tiles at (27-29, 36): you take (29, 36),
; the follower lands on (28, 36) by trailing a step behind you, and the sailor takes (27, 36) last.
; The follower gets no `applymovement` of its own -- a scripted one would drop it out of the follow
; state machine and need RestoreFollowerAfterMovement to put it back.
;
; You can be on any of three tiles when you talk to him, so the route aboard is picked from which
; way you are facing -- after `faceplayer` that is still your own facing, which is the one that had
; to point at him for the conversation to start at all. Every route ends the same way, stepping into
; (28, 36) and then on to (29, 36), which is what leaves the follower amidships.
	readvar VAR_FACING
	ifequal RIGHT, .BoardFromWestOfHim
	ifequal LEFT,  .BoardFromEastOfHim
	applymovement PLAYER, CianwoodCityPlayerBoardMovement
	sjump .Aboard

.BoardFromWestOfHim:
	applymovement PLAYER, CianwoodCityPlayerBoardFromWestMovement
	sjump .Aboard

.BoardFromEastOfHim:
	applymovement PLAYER, CianwoodCityPlayerBoardFromEastMovement

.Aboard:
; He casts off last, so his walk down the dock is never the thing you are waiting on and never has
; to route around wherever you happened to be standing. It also gives the follower, which trails a
; step behind, time to take its seat before the warp.
	applymovement CIANWOODCITY_MYSTERY_ISLAND_SAILOR, CianwoodCitySailorBoardMovement
if DEF(_DEBUG)
; Pick the island instead of rolling for it, so one can be tested without sailing over and over.
;
; The timing is pinned from both sides. It cannot go any earlier, because `readvar VAR_FACING`
; above writes the menu's own answer slot, wScriptVar, and would overwrite the choice. It cannot go
; any later, because the crossing below fades the screen to black, and a menu drawn on that is a
; menu nobody can read.
	opentext
	loadmenu .DebugIslandMenuHeader
	verticalmenu
	closewindow
	closetext
endc
	farscall MysteryIslandCrossingScript
	callasm QueueMysteryIslandArrival
if DEF(_DEBUG)
	callasm ChooseMysteryIslandFromDebugMenu
else
	callasm RollMysteryIsland
endc
	ifequal 1, .ApricornForest
	ifequal 2, .ShipwreckBeach
	warpfacing LEFT, HIDDEN_GROVE, 4, 10
	end

.ApricornForest:
	warpfacing LEFT, APRICORN_FOREST_OUTSIDE, 14, 9
	end

.ShipwreckBeach:
	callasm RollShipwreckBeach ; this trip's dig spots
	warpfacing LEFT, SHIPWRECK_BEACH, 14, 17
	end

if DEF(_DEBUG)
.DebugIslandMenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 2, SCREEN_WIDTH - 1, TEXTBOX_Y - 1
	dw .DebugIslandMenuData
	db 1 ; default option

.DebugIslandMenuData:
	db STATICMENU_CURSOR ; flags
	db 4 ; items
	db "HIDDEN GROVE@"
	db "APRICORN FOREST@"
	db "SHIPWRECK BEACH@"
	db "RANDOM@"
endc

.Declined:
	writetext CianwoodCityMysteryIslandSailorDeclinedText
	waitbutton
	closetext
	end

.AlreadySailedToday:
	writetext CianwoodCityMysteryIslandSailorTiredText
	waitbutton
	closetext
	end

; From his spot at the head of the dock (27, 34) straight down into the near seat (27, 36), which
; the other two have already stepped past by the time he casts off.
CianwoodCitySailorBoardMovement:
	step DOWN  ; (27, 35)
	step DOWN  ; (27, 36)
	turn_head RIGHT
	step_end

; The three ways aboard, by where you were standing when you talked to him. All of them finish
; (28, 36) then (29, 36), and none of them crosses (27, 34) while he is still standing on it.

; From (27, 35), the tile he faces.
CianwoodCityPlayerBoardMovement:
	step DOWN  ; (27, 36)
	step RIGHT ; (28, 36)
	step RIGHT ; (29, 36), your seat
	step_end

; From (26, 34), the shore end of the dock.
CianwoodCityPlayerBoardFromWestMovement:
	step DOWN  ; (26, 35)
	step RIGHT ; (27, 35)
	step DOWN  ; (27, 36)
	step RIGHT ; (28, 36)
	step RIGHT ; (29, 36)
	step_end

; From (28, 34), out along the dock past him. The short way -- straight down and across.
CianwoodCityPlayerBoardFromEastMovement:
	step DOWN  ; (28, 35)
	step DOWN  ; (28, 36)
	step RIGHT ; (29, 36)
	step_end

; Coming back, straight up out of your seat onto the dock. It keeps clear of (27, 34), where the
; sailor is standing again by the time you land.
CianwoodCityPlayerDisembarkMovement:
	step UP    ; (29, 35), onto the dock
	turn_head DOWN
	step_end

CianwoodCityMysteryIslandSailorAskText:
	text "I run a boat out"
	line "to an island."

	para "I never know quite"
	line "which one the"

	para "current will take"
	line "us to."

	para "Want to come"
	line "along?"
	done

CianwoodCityMysteryIslandSailorSetSailText:
	text "Then climb aboard!"
	done

CianwoodCityMysteryIslandSailorDeclinedText:
	text "Suit yourself."
	line "I'll be here."
	done

CianwoodCityMysteryIslandSailorTiredText:
	text "Another trip out"
	line "to an island?"

	para "Sorry, kid. My"
	line "arms are sore!"

	para "Come back tomorrow"
	line "after I've had"
	cont "some rest."
	done

CianwoodCity_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event 17, 41, MANIAS_HOUSE, 1
	warp_event  8, 43, CIANWOOD_GYM, 1
	warp_event 23, 43, CIANWOOD_POKECENTER_1F, 1
	warp_event 15, 47, CIANWOOD_PHARMACY, 1
	warp_event  9, 31, CIANWOOD_PHOTO_STUDIO, 1
	warp_event 15, 37, CIANWOOD_LUGIA_SPEECH_HOUSE, 1
	warp_event  5, 17, POKE_SEERS_HOUSE, 1

	def_coord_events
	coord_event 11, 16, SCENE_CIANWOODCITY_SUICUNE_AND_EUSINE, CianwoodCitySuicuneAndEusine

	def_bg_events
	bg_event 20, 34, BGEVENT_READ, CianwoodCitySign
	bg_event  7, 45, BGEVENT_READ, CianwoodGymSign
	bg_event 24, 43, BGEVENT_READ, CianwoodPokecenterSign
	bg_event 19, 47, BGEVENT_READ, CianwoodPharmacySign
	bg_event  8, 32, BGEVENT_READ, CianwoodPhotoStudioSign
	bg_event  8, 24, BGEVENT_READ, CianwoodPokeSeerSign
	bg_event  4, 19, BGEVENT_ITEM, CianwoodCityHiddenRevive
	bg_event  5, 29, BGEVENT_ITEM, CianwoodCityHiddenMaxEther

	def_object_events
	object_event 21, 37, SPRITE_STANDING_YOUNGSTER, SPRITEMOVEDATA_SPINRANDOM_SLOW, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, CianwoodCityYoungster, -1
	object_event 17, 33, SPRITE_POKEFAN_M, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 1, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, CianwoodCityPokefanM, -1
	object_event 14, 42, SPRITE_LASS, SPRITEMOVEDATA_WALK_UP_DOWN, 0, 2, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, CianwoodCityLass, -1
	object_event  8, 16, SPRITE_ROCK, SPRITEMOVEDATA_SMASHABLE_ROCK, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, CianwoodCityRock, -1
	object_event  9, 17, SPRITE_ROCK, SPRITEMOVEDATA_SMASHABLE_ROCK, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, CianwoodCityRock, -1
	object_event  4, 25, SPRITE_ROCK, SPRITEMOVEDATA_SMASHABLE_ROCK, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, CianwoodCityRock, -1
	object_event  5, 29, SPRITE_ROCK, SPRITEMOVEDATA_SMASHABLE_ROCK, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, CianwoodCityRock, -1
	object_event 10, 27, SPRITE_ROCK, SPRITEMOVEDATA_SMASHABLE_ROCK, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, CianwoodCityRock, -1
	object_event  4, 19, SPRITE_ROCK, SPRITEMOVEDATA_SMASHABLE_ROCK, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, CianwoodCityRock, -1
	object_event 10, 46, SPRITE_POKEFAN_F, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 1, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, CianwoodCityChucksWife, -1
	object_event 11, 21, SPRITE_SUPER_NERD, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_CIANWOOD_CITY_EUSINE
	object_event 10, 14, SPRITE_SUICUNE, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_SAW_SUICUNE_AT_CIANWOOD_CITY
; Wandering Pokemon. The species, form, shininess, level, DVs and held item are all rolled by
; RollOverworldMons when the map is entered; the sprite id only names which rolled slot this is.
; Palette 0 so they take the mon's own colors, and the event flag is -1 -- whether one is standing
; here is decided by whether its slot holds a rolled mon, not by a flag.
	object_event 13, 23, SPRITE_OW_MON_1, SPRITEMOVEDATA_SWIM_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
	object_event 24, 27, SPRITE_OW_MON_2, SPRITEMOVEDATA_SWIM_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
	object_event 22, 21, SPRITE_OW_MON_3, SPRITEMOVEDATA_SWIM_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
	object_event 27, 34, SPRITE_SAILOR, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, CianwoodCityMysteryIslandSailorScript, -1
