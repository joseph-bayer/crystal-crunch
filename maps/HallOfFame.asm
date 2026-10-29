	object_const_def
	const HALLOFFAME_LANCE

HallOfFame_MapScripts:
	def_scene_scripts
	scene_script HallOfFameEnterScene, SCENE_HALLOFFAME_ENTER
	scene_script HallOfFameNoopScene,  SCENE_HALLOFFAME_NOOP

	def_callbacks
	callback MAPCALLBACK_CMDQUEUE, HallOfFameSeatCallback

HallOfFameSeatCallback:
; During the Open League, the champion just beaten walks the player in, not Lance
	setval E4_SEAT_CHAMPION
	callasm ApplyEliteFourRoom
	endcallback

HallOfFameEnterScene:
	sdefer HallOfFameEnterScript
	end

HallOfFameNoopScene:
	end

HallOfFameEnterScript:
	follow HALLOFFAME_LANCE, PLAYER
	applymovement HALLOFFAME_LANCE, HallOfFame_WalkUpWithLance
	stopfollow
	turnobject PLAYER, RIGHT
	opentext
	checkevent EVENT_OPEN_LEAGUE_STARTED
	iftrue .OpenLeagueText
	writetext HallOfFame_LanceText
	sjump .Spoke

.OpenLeagueText:
	callasm PrintEliteFourHallOfFameText ; some champions have their own line
	iftrue .Spoke
	writetext HallOfFame_OpenLeagueText
.Spoke:
	waitbutton
	closetext
	turnobject HALLOFFAME_LANCE, UP
	applymovement PLAYER, HallOfFame_SlowlyApproachMachine
	applymovement FOLLOWER, HallOfFame_FollowerApproachMachine
	setscene SCENE_HALLOFFAME_NOOP
	pause 15
	setval HEALMACHINE_HALL_OF_FAME
	special HealMachineAnim
	setevent EVENT_BEAT_ELITE_FOUR
	setevent EVENT_TELEPORT_GUY
	setevent EVENT_RIVAL_SPROUT_TOWER
	clearevent EVENT_RED_IN_MT_SILVER
	setevent EVENT_OLIVINE_PORT_SPRITES_BEFORE_HALL_OF_FAME
	clearevent EVENT_OLIVINE_PORT_SPRITES_AFTER_HALL_OF_FAME
	setmapscene SPROUT_TOWER_3F, SCENE_SPROUTTOWER3F_NOOP
	farscall RespawnLegendariesScript ; before halloffame saves the game
	special HealParty
	checkevent EVENT_GOT_SS_TICKET_FROM_ELM
	iftrue .LanceCall
	specialphonecall SPECIALCALL_SSTICKET ; Lance's call waits for the ticket (ElmGiveTicketScript)
	sjump .SkipPhoneCall

.LanceCall:
	checkevent EVENT_LANCE_CALLED_ABOUT_OPEN_LEAGUE
	iftrue .SkipPhoneCall
	specialphonecall SPECIALCALL_LANCE_OPEN_LEAGUE
.SkipPhoneCall:
	checkevent EVENT_OPEN_LEAGUE_STARTED
	iffalse .NotOpenLeague
	setevent EVENT_BEAT_RANDOM_ELITE_FOUR ; Oak now opens Mt. Silver
.NotOpenLeague:
	callasm EndEliteFourRun ; the next Elite Four run rolls a new one, with a different champion
	halloffame
	end

HallOfFame_WalkUpWithLance:
	step UP
	step UP
	step UP
	step UP
	step UP
	step UP
	step UP
	step UP
	step RIGHT
	turn_head LEFT
	step_end

HallOfFame_SlowlyApproachMachine:
	slow_step UP
	step_end

HallOfFame_FollowerApproachMachine:
	slow_step UP
	slow_step RIGHT
	turn_head UP
	step_end

HallOfFame_OpenLeagueText:
; During the Open League the champion may be anyone, so no name and no memories of the place
	text "This is where we"
	line "honor the LEAGUE"

	para "CHAMPIONS for all"
	line "eternity."

	para "Their courageous"
	line "#MON are also"
	cont "inducted."

	para "Here today, we"
	line "witnessed the rise"

	para "of a new LEAGUE"
	line "CHAMPION!"

	para "<PLAY_G>, allow me"
	line "to register you"

	para "and your partners"
	line "as CHAMPIONS!"
	done

HallOfFame_LanceText:
	text "LANCE: It's been a"
	line "long time since I"
	cont "last came here."

	para "This is where we"
	line "honor the LEAGUE"

	para "CHAMPIONS for all"
	line "eternity."

	para "Their courageous"
	line "#MON are also"
	cont "inducted."

	para "Here today, we"
	line "witnessed the rise"

	para "of a new LEAGUE"
	line "CHAMPION--a"

	para "trainer who feels"
	line "compassion for,"

	para "and trust toward,"
	line "all #MON."

	para "A trainer who"
	line "succeeded through"

	para "perseverance and"
	line "determination."

	para "The new LEAGUE"
	line "CHAMPION who has"

	para "all the makings"
	line "of greatness!"

	para "<PLAY_G>, allow me"
	line "to register you"

	para "and your partners"
	line "as CHAMPIONS!"
	done

HallOfFame_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  4, 13, LANCES_ROOM, 3
	warp_event  5, 13, LANCES_ROOM, 4

	def_coord_events

	def_bg_events

	def_object_events
	object_event  4, 12, SPRITE_LANCE, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ObjectEvent, -1
