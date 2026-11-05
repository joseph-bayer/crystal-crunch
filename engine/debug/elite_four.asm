; Debug ROM: the Open League's lineup, seat battles and story steps, from the Lab scientist's menu
; in the bedroom.

if DEF(_DEBUG)

DebugEliteFourLineupScript::
; The Open League's lineup: shows the saved one, rolling it if none is set. Save and reset to
; check the lineup survives.
	callasm DebugShowEliteFourLineup
	writetext DebugE4LineupText
	waitbutton
	loadmenu .MenuHeader
	verticalmenu
	closewindow
	ifequal 1, .Reroll
	ifequal 2, .SetSeat
	ifequal 3, .FightSeat
	ifequal 4, .Warp
	ifequal 5, .Story
	ifequal 6, .OpenLeague
	ifequal 7, .ClearDex
	sjump DebugE4Done

.ClearDex:
; Every Pokemon unseen and uncaught, to check what a seat battle registers
	callasm DebugClearPokedex
	writetext DebugE4ClearDexText
	sjump DebugE4WaitDone

.Reroll:
	callasm DebugRerollEliteFourLineup
	sjump DebugE4ShowLineup

.SetSeat:
; Pick a seat, then step through the roster and seat anyone there
	scall DebugE4PickSeat
	iffalse DebugE4Done
	addval -1
	callasm DebugE4PickerStart
.PickLoop:
	writetext DebugE4PickText
	loadmenu .PickMenuHeader
	verticalmenu
	closewindow
	iffalse DebugE4Done
	ifequal 5, .PickSet
	callasm DebugE4PickerStep
	sjump .PickLoop

.PickSet:
	callasm DebugE4PickerSet
	callasm DebugShowEliteFourLineup
	sjump DebugE4ShowLineup

.FightSeat:
; Fight one seat of the lineup with the seat's team rules
	scall DebugE4PickSeat
	iffalse DebugE4Done
	addval -1
	callasm LoadEliteFourSeatTrainer
	closetext
	winlosstext DebugE4WinText, 0
	startbattle
	reloadmapafterbattle
	end

.Warp:
	loadmenu .WarpMenuHeader
	verticalmenu
	closewindow
	ifequal 1, .WarpIndigo
	ifequal 2, .WarpWill
	ifequal 3, .WarpKoga
	ifequal 4, .WarpBruno
	ifequal 5, .WarpKaren
	ifequal 6, .WarpLance
	ifequal 7, .WarpRed
	sjump DebugE4Done

.WarpIndigo:
	closetext
	warp INDIGO_PLATEAU_POKECENTER_1F, 5, 12
	end

.WarpWill:
; Each room warp turns the Open League on, so the room seats the lineup (rolling one if none is
; set), resets the rooms as entering from the Pokemon Center does, then walks in through its door
	closetext
	setevent EVENT_OPEN_LEAGUE_STARTED
	farscall IndigoPlateauResetEliteFourRooms
	warp WILLS_ROOM, 5, 17
	end

.WarpKoga:
	closetext
	setevent EVENT_OPEN_LEAGUE_STARTED
	farscall IndigoPlateauResetEliteFourRooms
	warp KOGAS_ROOM, 5, 17
	end

.WarpBruno:
	closetext
	setevent EVENT_OPEN_LEAGUE_STARTED
	farscall IndigoPlateauResetEliteFourRooms
	warp BRUNOS_ROOM, 5, 17
	end

.WarpKaren:
	closetext
	setevent EVENT_OPEN_LEAGUE_STARTED
	farscall IndigoPlateauResetEliteFourRooms
	warp KARENS_ROOM, 5, 17
	end

.WarpLance:
	closetext
	setevent EVENT_OPEN_LEAGUE_STARTED
	farscall IndigoPlateauResetEliteFourRooms
	warp LANCES_ROOM, 5, 23
	end

.WarpRed:
; Silver Cave's top room, with RED there to battle
	closetext
	clearevent EVENT_RED_IN_MT_SILVER
	warp SILVER_CAVE_ROOM_3, 9, 33
	end

.Story:
	loadmenu .StoryMenuHeader
	verticalmenu
	closewindow
	ifequal 1, .LanceCall
	ifequal 2, .MeetLance
	ifequal 3, .ResetLeague
	ifequal 4, .BeatRandom
	ifequal 5, .EndRun
	ifequal 6, .KantoDone
	sjump DebugE4Done

.LanceCall:
; As the first Hall of Fame does: Lance calls on the next steps
	setevent EVENT_BEAT_ELITE_FOUR
	clearevent EVENT_LANCE_CALLED_ABOUT_OPEN_LEAGUE
	specialphonecall SPECIALCALL_LANCE_OPEN_LEAGUE
	writetext DebugE4LanceCallText
	sjump DebugE4WaitDone

.MeetLance:
; Lance waits at the Indigo Plateau Pokemon Center
	setevent EVENT_BEAT_ELITE_FOUR
	setevent EVENT_LANCE_CALLED_ABOUT_OPEN_LEAGUE
	clearevent EVENT_OPEN_LEAGUE_STARTED
	setflag ENGINE_ZEPHYRBADGE
	setflag ENGINE_HIVEBADGE
	setflag ENGINE_PLAINBADGE
	setflag ENGINE_FOGBADGE
	setflag ENGINE_MINERALBADGE
	setflag ENGINE_STORMBADGE
	setflag ENGINE_GLACIERBADGE
	setflag ENGINE_RISINGBADGE
	scall DebugE4KantoBadges
	writetext DebugE4MeetLanceText
	sjump DebugE4WaitDone

.ResetLeague:
; The Open League's own state only: Mt. Silver stays open if it is
	clearevent EVENT_OPEN_LEAGUE_STARTED
	clearevent EVENT_LANCE_CALLED_ABOUT_OPEN_LEAGUE
	clearevent EVENT_BEAT_RANDOM_ELITE_FOUR
	callasm DebugResetOpenLeague
	writetext DebugE4ResetText
	sjump DebugE4WaitDone

.BeatRandom:
	setevent EVENT_BEAT_RANDOM_ELITE_FOUR
	writetext DebugE4BeatRandomText
	sjump DebugE4WaitDone

.EndRun:
; What the Hall of Fame does: store this run's champion, then clear the lineup
	callasm DebugE4LastChampionName
	writetext DebugE4LastChampText
	waitbutton
	callasm EndEliteFourRun
	callasm DebugE4LastChampionName
	writetext DebugE4EndRunText
	sjump DebugE4WaitDone

.KantoDone:
; Every Kanto leader beaten, so each gives their Elite Four invitation when talked to
	setevent EVENT_BEAT_BROCK
	setevent EVENT_BEAT_MISTY
	setevent EVENT_BEAT_LTSURGE
	setevent EVENT_BEAT_ERIKA
	setevent EVENT_BEAT_JANINE
	setevent EVENT_BEAT_SABRINA
	setevent EVENT_BEAT_BLAINE
	setevent EVENT_BEAT_BLUE
	scall DebugE4KantoBadges
	writetext DebugE4KantoDoneText
	sjump DebugE4WaitDone

.MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 13, SCREEN_HEIGHT - 1 ; eight items
	dw .MenuData
	db 1 ; default option

.MenuData:
	db STATICMENU_CURSOR ; flags
	db 8 ; items
	db "REROLL@"
	db "SET SEAT@"
	db "FIGHT SEAT@"
	db "WARP@"
	db "STORY@"
	db "OPEN LEAGUE@"
	db "CLEAR DEX@"
	db "CANCEL@"

.PickMenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 9, 11 ; five items, above the text box
	dw .PickMenuData
	db 2 ; default option

.PickMenuData:
	db STATICMENU_CURSOR ; flags
	db 5 ; items
	db "PREV@"
	db "NEXT@"
	db "BACK 5@"
	db "NEXT 5@"
	db "SET@"

.WarpMenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 13, SCREEN_HEIGHT - 1 ; eight items
	dw .WarpMenuData
	db 1 ; default option

.WarpMenuData:
	db STATICMENU_CURSOR ; flags
	db 8 ; items
	db "INDIGO PC@"
	db "WILL'S ROOM@"
	db "KOGA'S ROOM@"
	db "BRUNO'S ROOM@"
	db "KAREN'S ROOM@"
	db "LANCE'S ROOM@"
	db "RED'S ROOM@"
	db "CANCEL@"

.StoryMenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 14, 15 ; seven items
	dw .StoryMenuData
	db 1 ; default option

.StoryMenuData:
	db STATICMENU_CURSOR ; flags
	db 7 ; items
	db "LANCE CALL@"
	db "MEET LANCE@"
	db "RESET LEAGUE@"
	db "BEAT RANDOM@"
	db "END RUN@"
	db "KANTO DONE@"
	db "CANCEL@"

.OpenLeague:
; Turn the Open League on or off: on, the rooms seat the lineup (and roll one if none is set)
	checkevent EVENT_OPEN_LEAGUE_STARTED
	iftrue .OpenLeagueOff
	setevent EVENT_OPEN_LEAGUE_STARTED
	writetext DebugE4OpenLeagueOnText
	sjump DebugE4WaitDone

.OpenLeagueOff:
	clearevent EVENT_OPEN_LEAGUE_STARTED
	writetext DebugE4OpenLeagueOffText
	; fallthrough

DebugE4WaitDone:
	waitbutton
	; fallthrough

DebugE4Done:
	closetext
	end

DebugE4ShowLineup:
	writetext DebugE4LineupText
	sjump DebugE4WaitDone

DebugE4PickSeat:
; wScriptVar = the E4_SEAT_* picked plus 1 (the menu item), or FALSE for none
	loadmenu .SeatMenuHeader
	verticalmenu
	closewindow
	ifnotequal 6, .done
	setval FALSE
.done
	end

.SeatMenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 10, 13 ; six items
	dw .SeatMenuData
	db 1 ; default option

.SeatMenuData:
	db STATICMENU_CURSOR ; flags
	db 6 ; items
	db "SEAT 1@"
	db "SEAT 2@"
	db "SEAT 3@"
	db "SEAT 4@"
	db "CHAMPION@"
	db "CANCEL@"

DebugE4KantoBadges:
	setflag ENGINE_BOULDERBADGE
	setflag ENGINE_CASCADEBADGE
	setflag ENGINE_THUNDERBADGE
	setflag ENGINE_RAINBOWBADGE
	setflag ENGINE_SOULBADGE
	setflag ENGINE_MARSHBADGE
	setflag ENGINE_VOLCANOBADGE
	setflag ENGINE_EARTHBADGE
	end

DebugE4LineupText:
; One name a line: two seven-letter names and their numbers don't fit in 18 tiles
	text "1 @"
	text_ram wStringBuffer1
	text_start
	line "2 @"
	text_ram wStringBuffer2
	text_start
	para "3 @"
	text_ram wStringBuffer3
	text_start
	line "4 @"
	text_ram wStringBuffer4
	text_start
	para "CHAMP @"
	text_ram wStringBuffer5
	text_end

DebugE4PickText:
	text "PICK: @"
	text_ram wStringBuffer1
	text_end

DebugE4WinText:
	text "DEBUG: that was"
	line "the seat."
	done

DebugE4OpenLeagueOnText:
	text "DEBUG: OPEN LEAGUE"
	line "ON. The rooms seat"
	cont "the lineup."
	done

DebugE4OpenLeagueOffText:
	text "DEBUG: OPEN LEAGUE"
	line "OFF."
	done

DebugE4LanceCallText:
	text "DEBUG: LANCE calls"
	line "on the next steps."
	done

DebugE4MeetLanceText:
	text "DEBUG: 16 BADGES."
	line "LANCE waits at the"
	cont "INDIGO PLATEAU."
	done

DebugE4ResetText:
	text "DEBUG: OPEN LEAGUE"
	line "reset."
	done

DebugE4BeatRandomText:
	text "DEBUG: a random"
	line "lineup is beaten."
	cont "Talk to OAK."
	done

DebugE4LastChampText:
	text "DEBUG: last CHAMP"
	line "@"
	text_ram wStringBuffer1
	text_end

DebugE4EndRunText:
	text "Run ended. Last"
	line "CHAMP is now"
	cont "@"
	text_ram wStringBuffer1
	text "."
	done

DebugE4ClearDexText:
	text "DEBUG: #DEX"
	line "cleared."
	done

DebugE4KantoDoneText:
	text "DEBUG: KANTO"
	line "LEADERS beaten."
	done

endc
