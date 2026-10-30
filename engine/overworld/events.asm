SECTION "Events", ROMX

OverworldLoop::
	xor a ; MAPSTATUS_START
	ld [wMapStatus], a
.loop
	ld a, [wMapStatus]
	ld hl, .Jumptable
	call JumpTable
	ld a, [wMapStatus]
	cp MAPSTATUS_DONE
	jr nz, .loop
	ret

.Jumptable:
; entries correspond to MAPSTATUS_* constants
	dw StartMap
	dw EnterMap
	dw HandleMap
	dw DoNothing ; .done

DisableEvents:
	xor a
	ld [wEnabledPlayerEvents], a
	ret

EnableEvents::
	ld a, $ff
	ld [wEnabledPlayerEvents], a
	ret

CheckEnabledMapEventsBit5:
	ld hl, wEnabledPlayerEvents
	bit PLAYEREVENTS_UNUSED, [hl]
	ret

EnableWildEncounters:
	ld hl, wEnabledPlayerEvents
	set PLAYEREVENTS_WILD_ENCOUNTERS, [hl]
	ret

CheckWarpConnectionsEnabled:
	ld hl, wEnabledPlayerEvents
	bit PLAYEREVENTS_WARPS_AND_CONNECTIONS, [hl]
	ret

CheckCoordEventsEnabled:
	ld hl, wEnabledPlayerEvents
	bit PLAYEREVENTS_COORD_EVENTS, [hl]
	ret

CheckStepCountEnabled:
	ld hl, wEnabledPlayerEvents
	bit PLAYEREVENTS_COUNT_STEPS, [hl]
	ret

CheckWildEncountersEnabled:
	ld hl, wEnabledPlayerEvents
	bit PLAYEREVENTS_WILD_ENCOUNTERS, [hl]
	ret

StartMap:
	xor a
	ld [wScriptVar], a
	ld [wScriptRunning], a
	ld hl, wMapStatus
	ld bc, wMapStatusEnd - wMapStatus
	rst ByteFill
	farcall InitCallReceiveDelay
	call ClearJoypad
EnterMap:
	xor a
	ld [wXYComparePointer], a
	ld [wXYComparePointer + 1], a
	call SetUpFiveStepWildEncounterCooldown
	farcall RunMapSetupScript
	call DisableEvents

	ldh a, [hMapEntryMethod]
	cp MAPSETUP_CONNECTION
	call z, EnableEvents

	ldh a, [hMapEntryMethod]
	cp MAPSETUP_RELOADMAP
	jr nz, .dontresetpoison
	xor a
	ld [wPoisonStepCount], a
.dontresetpoison
	farcall RefreshFollowingCoords

	xor a ; end map entry
	ldh [hMapEntryMethod], a
	ld a, MAPSTATUS_HANDLE
	ld [wMapStatus], a
	ret

HandleMap:
	call HandleMapTimeAndJoypad
	call HandleCmdQueue
	call MapEvents

; Not immediately entering a connected map will cause problems.
	ld a, [wMapStatus]
	cp MAPSTATUS_HANDLE
	ret nz

	call HandleMapObjects
	call NextOverworldFrame
	call HandleMapBackground
	call CheckPlayerState
	xor a
	ret

MapEvents:
	ld a, [wMapEventStatus]
	and a
	ret nz
	call PlayerEvents
	call DisableEvents
	jmp ScriptEvents

NextOverworldFrame:
	; If we haven't already performed a delay outside DelayFrame as a result
	; of a busy LY overflow, perform that now.
	ld a, [wOverworldDelaySkip]
	and a
	jr nz, .done
	ldh a, [hDelayFrameLY]
	inc a
	jr nz, .LoadMapGraphicsAndDelay
	xor a
	ldh [hDelayFrameLY], a
.done
	ld a, [wOverworldDelaySkip]
	and a
	ret z
	dec a
	ld [wOverworldDelaySkip], a
	ret

.LoadMapGraphicsAndDelay:
	push hl
	push de
	push bc
	ldh a, [rVBK]
	push af
	xor a
	ldh [hDelayFrameLY], a

	; only allow this if we have time to spare
	ldh a, [rLY]
	cp $20
	jr nc, .gfx_done

	ld a, [wPendingOverworldGraphics]
	and a
	jr z, .gfx_done

	dec a
	ld [wPendingOverworldGraphics], a
	call _LoadTilesetGFX
	xor a
	ldh [hTileAnimFrame], a

.gfx_done
	ldh a, [hDelayFrameLY]
	and a
	call z, DelayFrame
	pop af
	ldh [rVBK], a
	jmp PopBCDEHL

HandleMapTimeAndJoypad:
	ld a, [wMapEventStatus]
	cp MAPEVENTS_OFF
	ret z

	call UpdateTime
	call GetJoypad
	jmp TimeOfDayPals

HandleMapObjects:
	farcall HandleNPCStep
	farcall _HandlePlayerStep
	jr _CheckObjectEnteringVisibleRange

HandleMapBackground:
	farcall _UpdateSprites
	farcall ScrollScreen
	farjp PlaceMapNameSign

Script_GetFollowerDirectionFromPlayer::
	call GetFollowerDirectionFromPlayer
	ld a, c
	ld [wScriptVar], a
	ret

GetFollowerDirectionFromPlayer::
	ld a, [wObject1MapX]
	ld b, a
	ld a, [wPlayerMapX]
	cp b
	jr z, .check_y
	ld c, RIGHT
	ret c
	ld c, LEFT
	ret

.check_y
	ld a, [wObject1MapY]
	ld b, a
	ld a, [wPlayerMapY]
	cp b
	ld c, STANDING
	ret z
	ld c, DOWN
	ret c
; nc
	ld c, UP
	ret

CheckPlayerState:
	ld a, [wPlayerStepFlags]
	bit PLAYERSTEP_CONTINUE_F, a
	jr z, .events
	bit PLAYERSTEP_STOP_F, a
	jr z, .noevents
	bit PLAYERSTEP_MIDAIR_F, a
	jr nz, .noevents
	call EnableEvents
.events
	ld a, MAPEVENTS_ON
	ld [wMapEventStatus], a
	ret

.noevents
	ld a, MAPEVENTS_OFF
	ld [wMapEventStatus], a
	ret

_CheckObjectEnteringVisibleRange:
	ld hl, wPlayerStepFlags
	bit PLAYERSTEP_STOP_F, [hl]
	ret z
	farjp CheckObjectEnteringVisibleRange

PlayerEvents:
	xor a
; If there's already a player event, don't interrupt it.
	ld a, [wScriptRunning]
	and a
	ret nz

	call Dummy_CheckEnabledMapEventsBit5 ; This is a waste of time

	call CheckTrainerEvent
	jr c, .ok

	call CheckWildMonEvent
	jr c, .ok

	call CheckTileEvent
	jr c, .ok

	call RunMemScript
	jr c, .ok

	call RunSceneScript
	jr c, .ok

	call CheckTimeEvents
	jr c, .ok

	call OWPlayerInput
	jr c, .ok

	xor a
	ret

.ok
	push af
	call EnableScriptMode
	pop af

	ld [wScriptRunning], a
	call DoPlayerEvent
	ld a, [wScriptRunning]
	cp PLAYEREVENT_CONNECTION
	jr z, .ok2
	cp PLAYEREVENT_JOYCHANGEFACING
	jr z, .ok2

	xor a
	ld [wLandmarkSignTimer], a

.ok2
	scf
	ret

CheckTrainerEvent:
	call CheckTrainerBattle
	jr nc, .nope

	ld a, PLAYEREVENT_SEENBYTRAINER
	scf
	ret

.nope
	xor a
	ret

CheckTileEvent:
; Check for warps, coord events, or wild battles.

	call CheckWarpConnectionsEnabled
	jr z, .connections_disabled

	farcall CheckMovingOffEdgeOfMap
	jr c, .map_connection

	call CheckWarpTile
	jr c, .warp_tile

.connections_disabled
	call CheckCoordEventsEnabled
	jr z, .coord_events_disabled

	call CheckCurrentMapCoordEvents
	jr c, .coord_event

.coord_events_disabled
	call CheckStepCountEnabled
	jr z, .step_count_disabled

	call CountStep
	ret c

.step_count_disabled
	call CheckWildEncountersEnabled
	jr z, .ok

	call RandomEncounter
	ret c
; fallthrough
.ok
	xor a
	ret

.map_connection
	ld a, PLAYEREVENT_CONNECTION
	scf
	ret

.warp_tile
	ld a, [wPlayerTileCollision]
	call CheckPitTile
	jr nz, .not_pit
	ld a, PLAYEREVENT_FALL
	scf
	ret

.not_pit
; A warp panel is a warp pad: the same warp, wrapped in the Teleport animation (WarpPadScript).
	cp COLL_WARP_PANEL
	ld a, PLAYEREVENT_WARP_PAD
	jr z, .got_event
	ld a, PLAYEREVENT_WARP
.got_event
	scf
	ret

.coord_event
	ld hl, wCurCoordEventScriptAddr
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call GetMapScriptsBank
	jmp CallScript

CheckWildEncounterCooldown::
	ld hl, wWildEncounterCooldown
	ld a, [hl]
	and a
	ret z
	dec [hl]
	ret z
	scf
	ret

SetUpFiveStepWildEncounterCooldown:
	ld a, 5
	ld [wWildEncounterCooldown], a
	ret

Dummy_CheckEnabledMapEventsBit5:
	jmp CheckEnabledMapEventsBit5

RunSceneScript:
	ld a, [wCurMapSceneScriptCount]
	and a
	jr z, .nope

	ld c, a
	call CheckScenes
	cp c
	jr nc, .nope

	ld e, a
	ld d, 0
	ld hl, wCurMapSceneScriptsPointer
	ld a, [hli]
	ld h, [hl]
	ld l, a
rept SCENE_SCRIPT_SIZE
	add hl, de
endr

	call GetMapScriptsBank
	call GetFarWord
	call GetMapScriptsBank
	call CallScript

	ld hl, wScriptFlags
	res RUN_DEFERRED_SCRIPT, [hl]

	call EnableScriptMode
	call ScriptEvents

	ld hl, wScriptFlags
	bit RUN_DEFERRED_SCRIPT, [hl]
	jr z, .nope

	ld hl, wDeferredScriptAddr
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wDeferredScriptBank]
	call CallScript
	scf
	ret

.nope
	xor a
	ret

CheckTimeEvents:
	ld a, [wLinkMode]
	and a
	jr nz, .nothing

	ld hl, wStatusFlags2
	bit STATUSFLAGS2_BUG_CONTEST_TIMER_F, [hl]
	jr z, .do_daily

	farcall CheckBugContestTimer
	jr c, .end_bug_contest
	xor a
	ret

.do_daily
	farcall CheckDailyResetTimer
	farcall CheckPokerusTick
	farcall CheckPhoneCall
	ret c

.nothing
	xor a
	ret

.end_bug_contest
	ld a, BANK(BugCatchingContestOverScript)
	ld hl, BugCatchingContestOverScript
	call CallScript
	scf
	ret

OWPlayerInput:
	call PlayerMovement
	ret c
	and a
	jr nz, .NoAction

; Can't perform button actions while sliding on ice.
	farcall CheckStandingOnIce
	jr c, .NoAction

	call CheckAPressOW
	jr c, .Action

	call CheckMenuOW
	jr c, .Action

.NoAction:
	xor a
	ret

.Action:
	push af
	farcall StopPlayerForEvent
	pop af
	scf
	ret

CheckAPressOW:
	ldh a, [hJoyPressed]
	and PAD_A
	ret z
	call TryObjectEvent
	ret c
	call TryBGEvent
	ret c
	call TryTileCollisionEvent
	ret c
	xor a
	ret

PlayTalkObject:
	push de
	ld de, SFX_READ_TEXT_2
	call PlaySFX
	pop de
	ret

TryObjectEvent:
	farcall CheckFacingObject
	jr c, .IsObject
	xor a
	ret

.IsObject:
; A hidden follower -- recalled into its ball on water, or hidden for a warp -- is still on the
; map, so IsNPCAtCoord finds it, but there is nothing there to talk to.
	ldh a, [hObjectStructIndex]
	cp FOLLOWER ; object struct 1 is the follower's
	jr nz, .talk
	ld a, [wFollowerFlags]
	and FOLLOWER_INVISIBLE | 1 << FOLLOWER_IN_POKEBALL_F
	jr z, .talk
	xor a
	ret

.talk
	call PlayTalkObject
	ldh a, [hObjectStructIndex]
	call GetObjectStruct
	ld hl, OBJECT_MAP_OBJECT_INDEX
	add hl, bc
	ld a, [hl]
	ldh [hLastTalked], a
	call GetMapObject
	ld hl, MAPOBJECT_TYPE
	add hl, bc
	ld a, [hl]

	push bc
	ld de, 3
	ld hl, ObjectEventTypeArray
	call IsInArray
	pop bc
	jr nc, .nope

	inc hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

.nope
	xor a
	ret

ObjectEventTypeArray:
	table_width 3
	dbw OBJECTTYPE_SCRIPT, .script
	dbw OBJECTTYPE_ITEMBALL, .itemball
	dbw OBJECTTYPE_TRAINER, .trainer
	; the remaining four are dummy events
	dbw OBJECTTYPE_WILDMON, .wildmon
	dbw OBJECTTYPE_4, .four
	dbw OBJECTTYPE_5, .five
	dbw OBJECTTYPE_6, .six
	assert_table_length NUM_OBJECT_TYPES
	db -1 ; end

.script
	ld hl, MAPOBJECT_SCRIPT_POINTER
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call GetMapScriptsBank
	jmp CallScript

.itemball
	ld hl, MAPOBJECT_SCRIPT_POINTER
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call GetMapScriptsBank
	ld de, wItemBallData
	call GetFarByte
	push hl
	push bc
	ld c, a
	inc hl
	call GetMapScriptsBank
	call GetFarByte
	ld b, a
	; bc = item index
	push bc
	pop hl
	; bc -> hl
	call GetItemIDFromIndex
	ld [de], a
	inc de
	pop bc
	pop hl
	inc hl
	inc hl
	call GetMapScriptsBank
	call GetFarByte
	ld [de], a
	ld a, PLAYEREVENT_ITEMBALL
	scf
	ret

.trainer
	call TalkToTrainer
	ld a, PLAYEREVENT_TALKTOTRAINER
	scf
	ret

.wildmon
; Pressing A on one does nothing: only walking onto it starts the battle. Otherwise a mon swimming
; by the shore could be fought from land, before the player can Surf to its levels.
	xor a
	ret

.four
	xor a
	ret

.five
	xor a
	ret

.six
	xor a
	ret

TryBGEvent:
	call CheckFacingBGEvent
	jr c, .is_bg_event
	xor a
	ret

.is_bg_event:
	ld a, [wCurBGEventType]
	ld hl, BGEventJumptable
	jmp JumpTable

BGEventJumptable:
	table_width 2
	dw .read
	dw .up
	dw .down
	dw .right
	dw .left
	dw .ifset
	dw .ifnotset
	dw .itemifset
	dw .copy
	assert_table_length NUM_BGEVENTS

.up:
	ld b, OW_UP
	jr .checkdir

.down:
	ld b, OW_DOWN
	jr .checkdir

.right:
	ld b, OW_RIGHT
	jr .checkdir

.left:
	ld b, OW_LEFT
; fallthrough
.checkdir:
	ld a, [wPlayerDirection]
	and %1100
	cp b
	jr nz, .dontread
.read:
	call PlayTalkObject
	ld hl, wCurBGEventScriptAddr
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call GetMapScriptsBank
	call CallScript
	scf
	ret

.itemifset:
	call CheckBGEventFlag
	jr nz, .dontread
	call PlayTalkObject
	call GetMapScriptsBank
	ld de, wHiddenItemData
	ld bc, wHiddenItemDataEnd - wHiddenItemData
	call FarCopyBytes
	ld hl, wHiddenItemID
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call GetItemIDFromIndex
	pop hl
	ld [hl], a
	ld a, BANK(HiddenItemScript)
	ld hl, HiddenItemScript
	call CallScript
	scf
	ret

.copy:
	call CheckBGEventFlag
	jr nz, .dontread
	call GetMapScriptsBank
	ld de, wHiddenItemData
	ld bc, wHiddenItemDataEnd - wHiddenItemData
	call FarCopyBytes
	ld hl, wHiddenItemID
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call GetItemIDFromIndex
	pop hl
	ld [hl], a
	jr .dontread

.ifset:
	call CheckBGEventFlag
	jr z, .dontread
	jr .thenread

.ifnotset:
	call CheckBGEventFlag
	jr nz, .dontread
.thenread:
	push hl
	call PlayTalkObject
	pop hl
	inc hl
	inc hl
	call GetMapScriptsBank
	call GetFarWord
	call GetMapScriptsBank
	call CallScript
	scf
	ret

.dontread:
	xor a
	ret

CheckBGEventFlag:
	ld hl, wCurBGEventScriptAddr
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
	call GetMapScriptsBank
	call GetFarWord
	ld e, l
	ld d, h
	ld b, CHECK_FLAG
	call EventFlagAction
	ld a, c
	and a
	pop hl
	ret

PlayerMovement:
	farcall DoPlayerMovement
	ld a, c
	ld hl, PlayerMovementPointers
	call JumpTable
	ld a, c
	ret

PlayerMovementPointers:
; entries correspond to PLAYERMOVEMENT_* constants
	table_width 2
	dw .normal
	dw .warp
	dw .turn
	dw .force_turn
	dw .finish
	dw .continue
	dw .exit_water
	dw .jump
	assert_table_length NUM_PLAYER_MOVEMENTS

.normal:
.finish:
	xor a
	ld c, a
	ret

.jump:
	xor a
	ld c, a
	ret

.warp:
	ld a, PLAYEREVENT_WARP
	ld c, a
	scf
	ret

.turn:
	ld a, PLAYEREVENT_JOYCHANGEFACING
	ld c, a
	scf
	ret

.force_turn:
; force the player to move in some direction
	ld a, BANK(Script_ForcedMovement)
	ld hl, Script_ForcedMovement
	call CallScript
	ld c, a
	scf
	ret

.continue:
.exit_water:
	ld a, -1
	ld c, a
	and a
	ret

CheckMenuOW:
	xor a
	ldh [hMenuReturn], a
	ldh [hUnusedByte], a
	ldh a, [hJoyPressed]

	bit B_PAD_SELECT, a
	jr nz, .Select

	bit B_PAD_START, a
	jr z, .NoMenu

	ld a, BANK(StartMenuScript)
	ld hl, StartMenuScript
	call CallScript
	scf
	ret

.NoMenu:
	xor a
	ret

.Select:
	call PlayTalkObject
	ld a, BANK(SelectMenuScript)
	ld hl, SelectMenuScript
	call CallScript
	scf
	ret

StartMenuScript:
	callasm StartMenu
	sjump StartMenuCallback

SelectMenuScript:
	callasm SelectMenu
	sjump SelectMenuCallback

StartMenuCallback:
SelectMenuCallback:
	readmem hMenuReturn
	ifequal HMENURETURN_SCRIPT, .Script
	ifequal HMENURETURN_ASM, .Asm
	end

.Script:
	memjump wQueuedScriptBank

.Asm:
	memcallasm wQueuedScriptBank
	end

CountStep:
	; Don't count steps in link communication rooms.
	ld a, [wLinkMode]
	and a
	jr nz, .done

	; If there is a special phone call, don't count the step.
	farcall CheckSpecialPhoneCall
	jr c, .doscript

	; If Repel wore off, don't count the step.
	call DoRepelStep
	jr c, .doscript

	; Count the step for poison and total steps
	ld hl, wPoisonStepCount
	inc [hl]
	ld hl, wStepCount
	inc [hl]
	; Every 256 steps, increase the happiness of all your Pokemon, and maybe their Hidden Power level.
	jr nz, .skip_happiness

	farcall StepHappiness
	farcall StepHiddenPower

.skip_happiness
	; Every 256 steps, offset from the happiness incrementor by 128 steps,
	; decrease the hatch counter of all your eggs until you reach the first
	; one that is ready to hatch.
	ld a, [wStepCount]
	cp $80
	jr nz, .skip_egg

	farcall DoEggStep
	jr nz, .hatch

.skip_egg
	; Increase the EXP of (both) DayCare Pokemon by 1.
	farcall DayCareStep

	; Every 4 steps, deal damage to all poisoned Pokemon.
	ld hl, wPoisonStepCount
	ld a, [hl]
	cp 4
	jr c, .skip_poison
	ld [hl], 0

	farcall DoPoisonStep
	jr c, .doscript

.skip_poison
	call DoBikeStep

.done
	xor a
	ret

.doscript
	ld a, -1
	scf
	ret

.hatch
	ld a, PLAYEREVENT_HATCH
	scf
	ret

DoRepelStep:
	ld a, [wRepelEffect]
	and a
	ret z

	dec a
	ld [wRepelEffect], a
	ret nz

	; offer another of the same Repel if the bag still has one
	call CheckRepelTypeInBag
	ld a, BANK(RepelWoreOffScript)
	ld hl, RepelWoreOffScript
	jr nc, .got_script
	assert BANK(UseAnotherRepelScript) == BANK(RepelWoreOffScript)
	ld hl, UseAnotherRepelScript
.got_script
	call CallScript
	scf
	ret

CheckRepelTypeInBag:
; Puts the Repel last used in wCurItem.
; Returns carry if the bag still holds one.
	call LoadRepelTypeItem
	ret nc
	ld hl, wNumItems
	jmp CheckItem

LoadRepelTypeItem::
; Puts the Repel last used in wCurItem and returns carry.
; Returns no carry if none is recorded.
	ld a, [wRepelType]
	and REPEL_TYPE_MASK
	ret z
	dec a
	add a
	ld e, a
	ld d, 0
	ld hl, RepelTypeItems
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call GetItemIDFromIndex
	ld [wCurItem], a
	scf
	ret

RepelTypeItems:
; item indexes, in REPEL_TYPE_* order from REPEL_TYPE_REPEL
	table_width 2
	dw REPEL
	dw SUPER_REPEL
	dw MAX_REPEL
	assert_table_length NUM_REPEL_TYPES

DoPlayerEvent:
	ld a, [wScriptRunning]
	and a
	ret z

	cp PLAYEREVENT_MAPSCRIPT ; run script
	ret z

	cp NUM_PLAYER_EVENTS
	ret nc

	ld c, a
	ld b, 0
	ld hl, PlayerEventScriptPointers
	add hl, bc
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld [wScriptBank], a
	ld a, [hli]
	ld [wScriptPos], a
	ld a, [hl]
	ld [wScriptPos + 1], a
	ret

PlayerEventScriptPointers:
; entries correspond to PLAYEREVENT_* constants
	table_width 3
	dba InvalidEventScript      ; PLAYEREVENT_NONE
	dba SeenByTrainerScript     ; PLAYEREVENT_SEENBYTRAINER
	dba TalkToTrainerScript     ; PLAYEREVENT_TALKTOTRAINER
	dba FindItemInBallScript    ; PLAYEREVENT_ITEMBALL
	dba EdgeWarpScript          ; PLAYEREVENT_CONNECTION
	dba WarpToNewMapScript      ; PLAYEREVENT_WARP
	dba FallIntoMapScript       ; PLAYEREVENT_FALL
	dba OverworldWhiteoutScript ; PLAYEREVENT_WHITEOUT
	dba HatchEggScript          ; PLAYEREVENT_HATCH
	dba ChangeDirectionScript   ; PLAYEREVENT_JOYCHANGEFACING
	dba WarpPadScript           ; PLAYEREVENT_WARP_PAD
	dba InvalidEventScript      ; (NUM_PLAYER_EVENTS)
	assert_table_length NUM_PLAYER_EVENTS + 1

InvalidEventScript:
	end

HatchEggScript:
	callasm OverworldHatchEgg
	end

WarpToNewMapScript:
	warpsound
	newloadmap MAPSETUP_DOOR
	end

FallIntoMapScript:
	newloadmap MAPSETUP_FALL
	; Recall the follower before the fall, not after: while it is only hidden for the warp,
	; TryRestoreHiddenFollower sees its tile free (the player is still in the air) and shows it
	; there, so the player lands on it.
	callasm FollowerInBall
	playsound SFX_KINESIS
	applymovement PLAYER, .SkyfallMovement
	playsound SFX_STRENGTH
	scall LandAfterPitfallScript
	end

.SkyfallMovement:
	skyfall
	step_end

LandAfterPitfallScript:
	earthquake 16
	end

WarpPadScript:
; A warp taken from a COLL_WARP_PANEL tile: Saffron Gym, Tin Tower's upper floors, the Rocket
; base, the Apricorn clearing. The warp itself is the ordinary one; this wraps it in the Teleport
; move's animation the way Yellow's pads do -- spin up and away before the fade, spin back down
; after it. The follower rides in its ball across the load, as it does through a pit fall, and
; steps out on the first step.
	playsound SFX_WARP_TO
	applymovement PLAYER, .Rise
; The follower goes the same way, a beat behind, when there is one out to go.
	callasm FollowerIsOut
	iffalse .NoFollower
	applymovement FOLLOWER, .Rise
	callasm RestoreFollowerAfterMovement
.NoFollower:
	newloadmap MAPSETUP_DOOR
	callasm FollowerInBall
	playsound SFX_WARP_FROM
	applymovement PLAYER, .Descend
	end

.Rise:
	teleport_from
	step_end

.Descend:
	teleport_to
	step_end

EdgeWarpScript:
	reloadend MAPSETUP_CONNECTION

ChangeDirectionScript:
	callasm UnfreezeAllObjects
	callasm EnableWildEncounters
	end

_CheckActiveFollowerBallAnim::
	ld hl, wFollowerFlags
	bit FOLLOWER_ENTERING_BALL_F, [hl]
	jr z, .not_entering
	push bc
	ld bc, wObject1Struct
	farcall SpawnPokeballClosing
	pop bc
	ret
.not_entering
	bit FOLLOWER_EXITING_BALL_F, [hl]
	ret z
	push bc
	ld bc, wObject1Struct
	farcall SpawnPokeballOpening
	pop bc
	ret

FollowerIsOut:
; wScriptVar = TRUE when a follower is on the map and not in its ball, i.e. there is a sprite a
; script can move. FALSE for nobody following, or one recalled into its ball.
	ld a, [wFollowerFlags]
	and FOLLOWER_INVISIBLE | 1 << FOLLOWER_IN_POKEBALL_F
	jr nz, .hidden
	ld a, [wFollowerPartySlot]
	and a
	jr z, .done
	ld a, TRUE
.done
	ld [wScriptVar], a
	ret

.hidden
	xor a
	jr .done

FollowerInBall:
	push bc
	ld bc, wObject1Struct
	ld hl, OBJECT_FLAGS1
	add hl, bc
	set INVISIBLE_F, [hl]
	ld hl, wFollowerFlags
	set FOLLOWER_INVISIBLE_F, [hl]
	set FOLLOWER_IN_POKEBALL_F, [hl]
	set FOLLOWER_INVISIBLE_ONE_STEP_F, [hl] ; so the player's next step brings it back out
	pop bc
	ret

INCLUDE "engine/overworld/scripting.asm"

WarpToSpawnPoint::
	ld hl, wStatusFlags2
	res STATUSFLAGS2_SAFARI_GAME_F, [hl]
	res STATUSFLAGS2_BUG_CONTEST_TIMER_F, [hl]
	ret

RunMemScript::
; If there is no script here, we don't need to be here.
	ld a, [wMapReentryScriptQueueFlag]
	and a
	ret z
; Execute the script at (wMapReentryScriptBank):(wMapReentryScriptAddress).
	ld hl, wMapReentryScriptAddress
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wMapReentryScriptBank]
	call CallScript
	scf
; Clear the buffer for the next script.
	push af
	xor a
	ld hl, wMapReentryScriptQueueFlag
	ld bc, 8
	rst ByteFill
	pop af
	ret

LoadMemScript::
; If there's already a script here, don't overwrite.
	ld hl, wMapReentryScriptQueueFlag
	ld a, [hl]
	and a
	ret nz
; Set the flag
	ld a, 1
	ld [hli], a
; Load the script pointer b:de into (wMapReentryScriptBank):(wMapReentryScriptAddress)
	ld a, b
	ld [hli], a
	ld a, e
	ld [hli], a
	ld [hl], d
	scf
	ret

TryTileCollisionEvent::
	call GetFacingTileCoord
	ld [wFacingTileID], a
	ld c, a
	; CheckFacingTileForStdScript preserves c, and
	; farcall copies c back into a.
	farcall CheckFacingTileForStdScript
	ld a, c
	jr c, .done

	; CheckCutTreeTile expects a == [wFacingTileID], which
	; it still is after the previous farcall.
	call CheckCutTreeTile
	jr nz, .whirlpool
	farcall TryCutOW
	jr .done

.whirlpool
	ld a, [wFacingTileID]
	call CheckWhirlpoolTile
	jr nz, .waterfall
	farcall TryWhirlpoolOW
	jr .done

.waterfall
	ld a, [wFacingTileID]
	call CheckWaterfallTile
	jr nz, .headbutt
	farcall TryWaterfallOW
	jr .done

.headbutt
	ld a, [wFacingTileID]
	call CheckHeadbuttTreeTile
	jr nz, .surf
	farcall TryHeadbuttOW
	jr c, .done
	jr .noevent

.surf
	farcall TrySurfOW
	jr c, .done
	farcall TryFlashOW ; in the dark, with nothing else to do
	jr c, .done
; fallthrough
.noevent
	xor a
	ret

.done
	call PlayClickSFX
	ld a, PLAYEREVENT_MAPSCRIPT
	scf
	ret

RandomEncounter::
	call CheckWildEncounterCooldown
	jr c, .nope
	call CanEncounterWildMon
	jr nc, .nope
	ld hl, wStatusFlags2
	bit STATUSFLAGS2_BUG_CONTEST_TIMER_F, [hl]
	jr nz, .bug_contest
	farcall TryWildEncounter
	jr nz, .nope
	jr .ok

.bug_contest
	call _TryWildEncounter_BugContest
	jr c, .ok_bug_contest
; fallthrough
.nope
	ld a, 1
	and a
	ret

.ok
	push bc
	ld bc, wPlayerStruct
	farcall ResetObject
	pop bc
	ld a, BANK(WildBattleScript)
	ld hl, WildBattleScript
	jr .done

.ok_bug_contest
	ld a, BANK(BugCatchingContestBattleScript)
	ld hl, BugCatchingContestBattleScript
.done
	call CallScript
	scf
	ret

WildBattleScript:
	randomwildmon
	startbattle
	reloadmapafterbattle
	end

TryClaimOverworldMonBattle:
; in:  a = a sprite id
; out: carry, and the slot recorded in wOverworldMonBattleSlot, if that sprite names a mon slot
;      holding a rolled encounter
; Both halves of the test matter: an OBJECTTYPE_WILDMON on some other sprite is a map data
; mistake, and an empty slot means the roll decided nobody appears. Neither should start a battle
; against species zero.
	sub SPRITE_OW_MON
	cp NUM_OW_MON_SLOTS
	ret nc
	ld e, a
	inc a
	ld [wOverworldMonBattleSlot], a ; 1-based, so that 0 can mean "no overworld mon battle"
	farcall GetOverworldMonEncounter
	ld a, [hli]
	or [hl]
	ret z
	scf
	ret

CheckWildMonEvent::
; Walking onto a wandering Pokemon starts a wild battle. Shaped like _CheckTrainerBattle, but it
; wants the player's own tile rather than a line of sight, and there is no approach cutscene.
;
; It also carries the shiny chime. PlayerEvents is the first thing that runs once the player
; actually has control -- past the fade, past the music starting, and it bows out entirely while a
; script is running -- so a sound played here is heard, which one played at roll time would not be.
	ld a, [wOverworldMonShinyPending]
	and a
	jr z, .no_chime
	xor a
	ld [wOverworldMonShinyPending], a
	ld de, SFX_SHINE
	call PlaySFX

.no_chime
	ld a, 1
	ld de, wMap1Object
.loop
	push af
	push de

; Has a sprite
	ld hl, MAPOBJECT_SPRITE
	add hl, de
	ld a, [hl]
	and a
	jr z, .next

; Is a wandering Pokemon
	ld hl, MAPOBJECT_TYPE
	add hl, de
	ld a, [hl]
	cp OBJECTTYPE_WILDMON
	jr nz, .next

; Is on screen
	ld hl, MAPOBJECT_OBJECT_STRUCT_ID
	add hl, de
	ld a, [hl]
	cp -1
	jr z, .next

; Has finished moving. Its map coordinates change when a step begins, not when the sprite gets
; there, so without this a mon walking onto the player starts the battle while it is still visibly
; a tile away -- the same thing that made a trigger distance of 1 read badly.
	call GetObjectStruct
	ld hl, OBJECT_WALKING
	add hl, bc
	ld a, [hl]
	cp STANDING
	jr nz, .next

; Is on the player's tile
	call .CheckDistance
	jr nc, .next

; And its sprite names a slot that actually holds a rolled encounter
	ld hl, MAPOBJECT_SPRITE
	add hl, de
	ld a, [hl]
	call TryClaimOverworldMonBattle
	jr nc, .next

	pop de
	pop af
	jr .start

.next
	pop de
	ld hl, MAPOBJECT_LENGTH
	add hl, de
	ld d, h
	ld e, l

	pop af
	inc a
	cp NUM_OBJECTS
	jr nz, .loop
	xor a
	ret

.start
; a = the map object index, and the slot is already recorded.
	ldh [hLastTalked], a
	ld [wOverworldMonBattleObject], a
	push bc
	ld bc, wPlayerStruct
	farcall ResetObject
	pop bc
	ld a, BANK(OverworldMonBattleScript)
	ld hl, OverworldMonBattleScript
	call CallScript
	scf
	ret

.CheckDistance:
; in: bc = an object struct. Returns carry when it is within OW_MON_TRIGGER_DISTANCE steps of the
; player. Steps, not line of sight -- which way either of them faces does not matter.
; de is the caller's map object pointer and d is the only scratch register free here, so it is
; saved rather than borrowed: reading the sprite id through a half-overwritten pointer is exactly
; the sort of thing that looks like "the trigger just does not fire".
	push de
	ld hl, OBJECT_MAP_X
	add hl, bc
	ld a, [wPlayerMapX]
	sub [hl]
	call .Abs
	ld d, a
	ld hl, OBJECT_MAP_Y
	add hl, bc
	ld a, [wPlayerMapY]
	sub [hl]
	call .Abs
	add d
	pop de
	cp OW_MON_TRIGGER_DISTANCE + 1
	ret

.Abs:
	bit 7, a
	ret z
	cpl
	inc a
	ret

OverworldMonBattleScript:
; Any finished battle spends the mon -- beaten, caught or run from, it is gone until the route is
; left and re-entered. `disappear` both deletes the object and sets its event flag, and the flag is
; one of the EVENT_TEMPORARY_UNTIL_MAP_RELOAD_* set, which clears on the next HandleNewMap -- the
; same boundary the reroll happens on.
; During the Bug Catching Contest a member is a contest catch like any other bug in the park:
; Park Balls, the one-catch rule, the scoring, and the walk back to the gate when the balls run
; out. Only the battle type and the tail differ; the encounter is the rolled one either way.
	checkflag ENGINE_BUG_CONTEST_TIMER
	iftrue .Contest
	callasm SetUpOverworldMonBattle
	startbattle
	callasm EndOverworldMonBattle
	disappear LAST_TALKED
; On a population map every member is rerolled here and the reload that follows places them all
; again -- the one you fought included, refilled. `disappear` stays: a deleted object cannot
; trigger, so you cannot come back from the battle into another one. Does nothing on other maps.
	callasm RerollPopulation
	callasm RerollSwarmOverworldMons ; likewise on a swarming route; does nothing elsewhere
	reloadmapafterbattle
	end

.Contest:
	loadvar VAR_BATTLETYPE, BATTLETYPE_CONTEST
	callasm SetUpOverworldMonBattle
	startbattle
	callasm EndOverworldMonBattle
	disappear LAST_TALKED
	callasm RerollPopulation
	reloadmapafterbattle
	readmem wParkBallsRemaining
	iffalse .OutOfBalls
	end

.OutOfBalls:
	farsjump BugCatchingContestOutOfBallsScript

CanEncounterWildMon::
	ld hl, wStatusFlags
	bit STATUSFLAGS_NO_WILD_ENCOUNTERS_F, [hl]
	jr nz, .no
	ld a, [wEnvironment]
	cp CAVE
	jr z, .ice_check
	cp DUNGEON
	jr z, .ice_check
	farcall CheckGrassCollision
	jr nc, .no

.ice_check
	ld a, [wPlayerTileCollision]
	call CheckIceTile
	jr z, .no
	scf
	ret

.no
	and a
	ret

_TryWildEncounter_BugContest:
	call TryWildEncounter_BugContest
	ret nc
	call ChooseWildEncounter_BugContest
	farjp CheckRepelEffect

ChooseWildEncounter_BugContest::
; Pick a random mon out of ContestMons.

.loop
	call Random
	cp 100 << 1
	jr nc, .loop
	srl a

	ld hl, ContestMons
	ld de, 5
.CheckMon:
	sub [hl]
	jr c, .GotMon
	add hl, de
	jr .CheckMon

.GotMon:
	inc hl

; Species
	ld a, [hli]
	push hl
	ld h, [hl]
	ld l, a
	call GetPokemonIDFromIndex
	pop hl
	inc hl
	ld [wTempWildMonSpecies], a

; Min level
	ld a, [hli]
	ld d, a

; Max level
	ld a, [hl]

	sub d
	jr nz, .RandomLevel

; If min and max are the same.
	ld a, d
	jr .GotLevel

.RandomLevel:
; Get a random level between the min and max.
	ld c, a
	inc c
	call Random
	ldh a, [hRandomAdd]
	call SimpleDivide
	add d

.GotLevel:
	ld [wCurPartyLevel], a

	xor a
	ret

TryWildEncounter_BugContest:
	ld a, [wPlayerTileCollision]
	call CheckSuperTallGrassTile
	ld b, 40 percent
	jr z, .ok
	ld b, 20 percent

.ok
	farcall ApplyMusicEffectOnEncounterRate
	farcall ApplyCleanseTagEffectOnEncounterRate
	call Random
	ldh a, [hRandomAdd]
	cp b
	ret c
	ld a, 1
	and a
	ret

INCLUDE "data/wild/bug_contest_mons.asm"

DoBikeStep::
	; If the bike shop owner doesn't have our number, or
	; if we've already gotten the call, we don't have to
	; be here.
	ld hl, wStatusFlags2
	bit STATUSFLAGS2_BIKE_SHOP_CALL_F, [hl]
	jr z, .NoCall

	; If we're not on the bike, we don't have to be here.
	ld a, [wPlayerState]
	cp PLAYER_BIKE
	jr nz, .NoCall

	; If we're not in an area of phone service, we don't
	; have to be here.
	call GetMapPhoneService
	and a
	jr nz, .NoCall

	; Check the bike step count and check whether we've
	; taken 65536 of them yet.
	ld hl, wBikeStep
	ld a, [hli]
	ld d, a
	ld e, [hl]
	cp 255
	jr nz, .increment
	ld a, e
	cp 255
	jr z, .dont_increment

.increment
	inc de
	ld a, e
	ld [hld], a
	ld [hl], d

.dont_increment
	; If we've taken at least 1024 steps, have the bike
	;  shop owner try to call us.
	ld a, d
	cp HIGH(1024)
	jr c, .NoCall

	; If a call has already been queued, don't overwrite
	; that call.
	ld a, [wSpecialPhoneCallID]
	and a
	jr nz, .NoCall

	; Queue the call.
	ld a, SPECIALCALL_BIKESHOP
	ld [wSpecialPhoneCallID], a
	ld hl, wStatusFlags2
	res STATUSFLAGS2_BIKE_SHOP_CALL_F, [hl]
	scf
	ret

.NoCall:
	xor a
	ret

INCLUDE "engine/overworld/cmd_queue.asm"
