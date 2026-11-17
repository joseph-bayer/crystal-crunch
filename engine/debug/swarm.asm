if DEF(_DEBUG)

; The swarm debug tools: SWARMS in the Scientist's debug menu (engine/debug/menus.asm). The
; radio's two swarms are rolled once a day, one for the day and one for the evening, and each starts
; when 6.0 announces it; these let that be tested without waiting for midnight.

DebugSwarmScript::
	faceplayer
	opentext
	writetext DebugSwarmText
	loadmenu .MenuHeader
	verticalmenu
	closewindow
	ifequal 1, .NewDay
	ifequal 2, .RocketStory
	ifequal 3, .RocketSwarm
	ifequal 4, .AltShinySwarm
	closetext
	end

.NewDay:
; What midnight does to swarms: today's picks go into the history, every running swarm ends, and
; 6.0 rolls again on the next listen.
	callasm DebugSwarmNewDay
	writetext DebugSwarmNewDayText
	waitbutton
	closetext
	end

.RocketStory:
; Only the two flags that unlock Team Rocket's swarms. The rest of the story is left as it is.
	loadmenu .StoryMenuHeader
	verticalmenu
	closewindow
	ifequal 1, .NotStarted
	ifequal 2, .HideoutDone
	ifequal 3, .TowerDone
	closetext
	end

.NotStarted:
	clearevent EVENT_CLEARED_ROCKET_HIDEOUT
	clearevent EVENT_CLEARED_RADIO_TOWER
	sjump .StoryDone

.HideoutDone:
	setevent EVENT_CLEARED_ROCKET_HIDEOUT
	clearevent EVENT_CLEARED_RADIO_TOWER
	sjump .StoryDone

.TowerDone:
	setevent EVENT_CLEARED_ROCKET_HIDEOUT
	setevent EVENT_CLEARED_RADIO_TOWER
.StoryDone:
	writetext DebugSwarmDoneText
	waitbutton
	closetext
	end

.RocketSwarm:
; Makes one of Team Rocket's rows the pick for the time of day now, whatever the story flags say,
; after ending today's swarms. It starts when 6.0 announces it, as any radio swarm does.
	loadmenu .RocketMenuHeader
	verticalmenu
	closewindow
	ifequal 5, .Cancel
	ifequal 0, .Cancel
	callasm DebugSwarmSetRocket
	writetext DebugSwarmRocketText
	waitbutton
.Cancel:
	closetext
	end

.AltShinySwarm:
; Makes one of the swarms whose shinies are alternates 4 times in 5 the pick for the time of day
; now, whatever its story flag says, after ending today's swarms. It starts when 6.0 announces it.
; BEASTS -> FORCE SHINY makes every one shiny.
	loadmenu .AltShinyMenuHeader
	verticalmenu
	closewindow
	ifequal 5, .Cancel
	ifequal 0, .Cancel
	callasm DebugSwarmSetAltShiny
	writetext DebugSwarmRocketText
	waitbutton
	closetext
	end

.MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 15, 11
	dw .MenuData
	db 1 ; default option

.MenuData:
	db STATICMENU_CURSOR ; flags
	db 5 ; items
	db "NEW DAY@"
	db "ROCKET STORY@"
	db "ROCKET SWARM@"
	db "ALT SHINY@"
	db "CANCEL@"

.StoryMenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 15, 9
	dw .StoryMenuData
	db 1 ; default option

.StoryMenuData:
	db STATICMENU_CURSOR ; flags
	db 4 ; items
	db "NOT STARTED@"
	db "HIDEOUT DONE@"
	db "TOWER DONE@"
	db "CANCEL@"

.AltShinyMenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 15, 11
	dw .AltShinyMenuData
	db 1 ; default option

.AltShinyMenuData:
	db STATICMENU_CURSOR ; flags
	db 5 ; items, in SWARM_*_ALT_SHINY order
	db "SCYTHER@"
	db "DRATINI@"
	db "MAGIKARP@"
	db "MARILL@"
	db "CANCEL@"

.RocketMenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 15, 11
	dw .RocketMenuData
	db 1 ; default option

.RocketMenuData:
	db STATICMENU_CURSOR ; flags
	db 5 ; items, in SWARM_*_ROCKET order
	db "GOLBAT@"
	db "WEEZING@"
	db "CHARMELEON@"
	db "ARBOK@"
	db "CANCEL@"

DebugSwarmNewDay:
; As the daily reset does: today's picks go into the history first.
	farcall ShiftSwarmHistory
	farjp ClearTodaysSwarms

DebugSwarmSetNow:
; in: a = a SWARM_* id, to be the pick for the time of day now once today's swarms have ended
	push af
	farcall ClearTodaysSwarms
	farcall GetSwarmRadioPickNow
	ld e, a
	ld d, 0
	ld hl, wDailySwarms
	add hl, de
	pop af
	ld [hl], a
	ret

DebugSwarmSetRocket:
; in: wScriptVar = 1-4, the Rocket menu's pick
	assert SWARM_WEEZING_ROCKET == SWARM_GOLBAT_ROCKET + 1 && SWARM_CHARMELEON_ROCKET == SWARM_GOLBAT_ROCKET + 2 \
		&& SWARM_ARBOK_ROCKET == SWARM_GOLBAT_ROCKET + 3, "the Rocket menu expects these ids in a row"
	ld a, [wScriptVar]
	add SWARM_GOLBAT_ROCKET - 1
	jr DebugSwarmSetNow

DebugSwarmSetAltShiny:
; in: wScriptVar = 1-4, the alternate-shiny menu's pick
	assert SWARM_DRATINI_ALT_SHINY == SWARM_SCYTHER_ALT_SHINY + 1 \
		&& SWARM_MAGIKARP_ALT_SHINY == SWARM_SCYTHER_ALT_SHINY + 2 \
		&& SWARM_MARILL_ALT_SHINY == SWARM_SCYTHER_ALT_SHINY + 3, "the alternate-shiny menu expects these ids in a row"
	ld a, [wScriptVar]
	add SWARM_SCYTHER_ALT_SHINY - 1
	jr DebugSwarmSetNow

DebugSwarmText:
	text "DEBUG: swarms."
	done

DebugSwarmNewDayText:
	text "Swarms cleared."
	line "6.0 rolls again."
	done

DebugSwarmDoneText:
	text "Done."
	done

DebugSwarmRocketText:
	text "Swarm set for this"
	line "time of day. Tune"
	cont "in 6.0 to start."
	done

endc
