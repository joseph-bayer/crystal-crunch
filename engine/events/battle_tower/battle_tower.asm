BattleTowerRoomMenu:
; special
	call InitBattleTowerChallengeRAM
	farjp _BattleTowerRoomMenu

BattleTowerBattle:
	xor a ; FALSE
	ld [wBattleTowerBattleEnded], a
	call _BattleTowerBattle
	xor a
	ld l, LOCKED_MON_ID_BATTLE_TOWER_1
	call LockPokemonID
	ld l, LOCKED_MON_ID_BATTLE_TOWER_2
	call LockPokemonID
	ld l, LOCKED_MON_ID_BATTLE_TOWER_3
	call LockPokemonID
	lb bc, NUM_MOVES * 3, LOCKED_MOVE_ID_BATTLE_TOWER_MON1_MOVE1
.loop
	ld l, c
	call LockMoveID
	inc c
	dec b
	jr nz, .loop
	ld l, LOCKED_ITEM_ID_BATTLE_TOWER_1
	call LockItemID
	ld l, LOCKED_ITEM_ID_BATTLE_TOWER_2
	call LockItemID
	ld l, LOCKED_ITEM_ID_BATTLE_TOWER_3
	jmp LockItemID

InitBattleTowerChallengeRAM:
	xor a
	ld [wBattleTowerBattleEnded], a
	ld [wNrOfBeatenBattleTowerTrainers], a
	ld [wcf65], a
	ld [wcf66], a
	ret

_BattleTowerBattle:
.loop
	call .do_dw
	call DelayFrame
	ld a, [wBattleTowerBattleEnded]
	cp TRUE
	jr nz, .loop
	ret

.do_dw
	jumptable .dw, wBattleTowerBattleEnded

.dw
	dw RunBattleTowerTrainer
	dw DoNothing ; SkipBattleTowerTrainer

RunBattleTowerTrainer:
	ld a, [wOptions]
	push af
	ld hl, wOptions
	set BATTLE_SHIFT, [hl] ; SET MODE

	ld a, [wInBattleTowerBattle]
	push af
	or 1 << IN_BATTLE_TOWER_BATTLE_F
	ld [wInBattleTowerBattle], a

	xor a
	ld [wLinkMode], a
	call HealParty
	call ReadBTTrainerParty

	predef StartBattle

	farcall LoadPokemonData
	call HealParty
	ld a, [wBattleResult]
	ld [wScriptVar], a
	and a ; WIN?
	jr nz, .lost
	ld a, BANK(sNrOfBeatenBattleTowerTrainers)
	call OpenSRAM
	ld a, [sNrOfBeatenBattleTowerTrainers]
	ld [wNrOfBeatenBattleTowerTrainers], a
	call CloseSRAM
	ld hl, wStringBuffer3
	ld a, [wNrOfBeatenBattleTowerTrainers]
	add "1"
	ld [hli], a
	ld [hl], "@"

.lost
	pop af
	ld [wInBattleTowerBattle], a
	pop af
	ld [wOptions], a
	ld a, TRUE
	ld [wBattleTowerBattleEnded], a
	ret

ReadBTTrainerParty:
; Initialise the BattleTower-Trainer and his mon
	call CopyBTTrainer_FromBT_OT_TowBT_OTTemp

; Check the nicknames for illegal characters, and replace bad nicknames
; with their species names.
	ld de, wBT_OTTempMon1Name
	ld c, MON_NAME_LENGTH
	farcall CheckStringForErrors
	jr nc, .skip_mon_1

	ld a, [wBT_OTTempMon1]
	ld [wNamedObjectIndex], a
	call GetPokemonName
	ld l, e
	ld h, d
	ld de, wBT_OTTempMon1Name
	ld bc, MON_NAME_LENGTH
	rst CopyBytes

.skip_mon_1
	ld de, wBT_OTTempMon2Name
	ld c, MON_NAME_LENGTH
	farcall CheckStringForErrors
	jr nc, .skip_mon_2
	ld a, [wBT_OTTempMon2]
	ld [wNamedObjectIndex], a
	call GetPokemonName
	ld l, e
	ld h, d
	ld de, wBT_OTTempMon2Name
	ld bc, MON_NAME_LENGTH
	rst CopyBytes

.skip_mon_2
	ld de, wBT_OTTempMon3Name
	ld c, MON_NAME_LENGTH
	farcall CheckStringForErrors
	jr nc, .skip_mon_3
	ld a, [wBT_OTTempMon3]
	ld [wNamedObjectIndex], a
	call GetPokemonName
	ld l, e
	ld h, d
	ld de, wBT_OTTempMon3Name
	ld bc, MON_NAME_LENGTH
	rst CopyBytes

.skip_mon_3
; Add the terminator character to each of these names
	ld a, "@"
	ld [wBT_OTTempMon1Name + MON_NAME_LENGTH - 1], a
	ld [wBT_OTTempMon2Name + MON_NAME_LENGTH - 1], a
	ld [wBT_OTTempMon3Name + MON_NAME_LENGTH - 1], a
; Fix errors in the movesets
	call CheckBTMonMovesForErrors
; Repair the trainer name if needed, then copy it to wOTPlayerName
	ld de, wBT_OTTempName
	ld c, NAME_LENGTH - 1
	farcall CheckStringForErrors
	jr nc, .trainer_name_okay
	ld hl, BT_ChrisName
	jr .done_trainer_name

.trainer_name_okay
	ld hl, wBT_OTTempName

.done_trainer_name
	ld de, wOTPlayerName
	ld bc, NAME_LENGTH - 1
	rst CopyBytes
	ld a, "@"
	ld [de], a

	ld hl, wBT_OTTempTrainerClass
	ld a, [hli]
	ld [wOtherTrainerClass], a
	ld a, LOW(wOTPartyMonNicknames)
	ld [wBGMapBuffer], a
	ld a, HIGH(wOTPartyMonNicknames)
	ld [wBGMapBuffer + 1], a

	; Copy mon into Memory from the address in hl
	ld de, wOTPartyMon1Species
	ld bc, wOTPartyCount
	ld a, BATTLETOWER_PARTY_LENGTH
	ld [bc], a
	inc bc
.otpartymon_loop
	push af
	ld a, [hl]
	ld [bc], a
	inc bc
	push bc
	ld bc, PARTYMON_STRUCT_LENGTH
	rst CopyBytes
	push de
	ld a, [wBGMapBuffer]
	ld e, a
	ld a, [wBGMapBuffer + 1]
	ld d, a
	ld bc, MON_NAME_LENGTH
	rst CopyBytes
	ld a, e
	ld [wBGMapBuffer], a
	ld a, d
	ld [wBGMapBuffer + 1], a
	pop de
	pop bc
	pop af
	dec a
	and a
	jr nz, .otpartymon_loop
	ld a, -1
	ld [bc], a
	ret

BT_ChrisName:
	db "CHRIS@"

INCLUDE "data/battle_tower/unknown_levels.asm"

CopyBTTrainer_FromBT_OT_TowBT_OTTemp:
; copy the BattleTower-Trainer data that lies at 'wBT_OTTrainer' to 'wBT_OTTemp'
	ldh a, [rWBK]
	push af
	ld a, BANK(wBT_OTTrainer)
	ldh [rWBK], a

	ld hl, wBT_OTTrainer
	ld de, wBT_OTTemp
	ld bc, BATTLE_TOWER_STRUCT_LENGTH
	rst CopyBytes

	pop af
	ldh [rWBK], a

	ld a, BANK(sBattleTowerChallengeState)
	call OpenSRAM
	ld a, BATTLETOWER_CHALLENGE_IN_PROGRESS
	ld [sBattleTowerChallengeState], a
	ld hl, sNrOfBeatenBattleTowerTrainers
	inc [hl]
	jmp CloseSRAM

BattleTowerAction:
	jumptable .dw, wScriptVar

.dw
	table_width 2
	dw BattleTowerAction_CheckExplanationRead
	dw BattleTowerAction_SetExplanationRead
	dw BattleTowerAction_GetChallengeState
	dw BattleTowerAction_SetByteToQuickSaveChallenge
	dw BattleTowerAction_SetByteToCancelChallenge
	dw SaveBattleTowerLevelGroup
	dw LoadBattleTowerLevelGroup
	dw BattleTower_CheckSaveFileExistsAndIsYours
	dw BattleTowerAction_0A
	dw BattleTowerAction_GSBall
	dw BattleTowerAction_EggTicket
	dw BattleTowerAction_0F
	dw DoNothing ; BATTLETOWERACTION_11
	dw DoNothing ; BATTLETOWERACTION_12
	dw BattleTowerAction_14
	dw BattleTowerAction_15
	dw ResetBattleTowerTrainersSRAM
	dw BattleTower_GiveReward
	dw BattleTowerAction_1C
	dw BattleTowerAction_1D
	dw BattleTower_RandomlyChooseReward
	dw BattleTower_SaveOptions
	assert_table_length NUM_BATTLETOWERACTIONS

; Reset the save memory for BattleTower-Trainers (Counter and all 7 TrainerBytes)
ResetBattleTowerTrainersSRAM:
	ld a, BANK(sBTTrainers)
	call OpenSRAM

	ld a, $ff
	ld hl, sBTTrainers
	ld bc, BATTLETOWER_STREAK_LENGTH
	rst ByteFill

	xor a
	ld [sNrOfBeatenBattleTowerTrainers], a
	jmp CloseSRAM

BattleTower_GiveReward:
; Returns the reward's 8-bit item ID in wScriptVar, for the script to name and give (it checks the
; pack for room itself). A reward saved by an older build, as an 8-bit ID, is saved again the
; current way first, so the one handed over is the one kept if the pack is full.
	ld a, BANK(sBattleTowerReward)
	call OpenSRAM
	ld a, [sBattleTowerReward]
	cp BATTLETOWER_REWARD_SAVED
	jr c, .older_build
	sub BATTLETOWER_REWARD_SAVED
	cp NUM_BATTLETOWER_REWARDS
	jr c, .got_reward
	jr .lost ; not a value either way of saving makes

.older_build
; Honored while it still names one of the four. It may not: the ID went unprotected, so a save
; could free it, emptying the slot or handing it to another item. Then the reward is an HP Up.
	and a
	jr z, .lost
	call GetItemIndexFromID
	ld a, h
	cp HIGH(HP_UP)
	jr nz, .lost
	ld a, l
	sub LOW(HP_UP)
	cp NUM_BATTLETOWER_REWARDS
	jr c, .resave

.lost
	xor a ; HP_UP
.resave
	push af
	or BATTLETOWER_REWARD_SAVED
	ld [sBattleTowerReward], a
	pop af
.got_reward
	call CloseSRAM
	ld c, a
	ld b, 0
	ld hl, HP_UP
	add hl, bc
	call GetItemIDFromIndex
	ld [wScriptVar], a
	ret

BattleTowerAction_1C:
	ld a, BANK(sBattleTowerChallengeState)
	call OpenSRAM
	ld a, BATTLETOWER_WON_CHALLENGE
	ld [sBattleTowerChallengeState], a
	jmp CloseSRAM

BattleTowerAction_1D:
	ld a, BANK(sBattleTowerChallengeState)
	call OpenSRAM
	ld a, BATTLETOWER_RECEIVED_REWARD
	ld [sBattleTowerChallengeState], a
	jmp CloseSRAM

BattleTower_SaveOptions:
	farjp SaveOptions

BattleTower_RandomlyChooseReward:
; Choose one of the four stat boosters. It is saved as which one, not as an 8-bit item ID: it
; waits through the whole challenge, saves included, and an ID could be freed meanwhile.
	assert HP_UP + 1 == PROTEIN && HP_UP + 2 == IRON && HP_UP + 3 == CARBOS
	assert BATTLETOWER_REWARD_SAVED > ITEM_TABLE_ENTRIES, "a saved reward could read as an item ID"
	assert BATTLETOWER_REWARD_SAVED + NUM_BATTLETOWER_REWARDS <= ITEM_TABLE_MINIMUM_RESERVED_INDEX
	ld a, NUM_BATTLETOWER_REWARDS
	call RandomRange
	or BATTLETOWER_REWARD_SAVED
	push af
	ld a, BANK(sBattleTowerReward)
	call OpenSRAM
	pop af
	ld [sBattleTowerReward], a
	jmp CloseSRAM

BattleTowerAction_CheckExplanationRead:
	call BattleTower_CheckSaveFileExistsAndIsYours
	ld a, [wScriptVar]
	and a
	ret z

	ld a, BANK(sBattleTowerSaveFileFlags)
	call OpenSRAM
	ld a, [sBattleTowerSaveFileFlags]
	and 2
	ld [wScriptVar], a
	jmp CloseSRAM

BattleTowerAction_GetChallengeState:
	ld hl, sBattleTowerChallengeState
	ld a, BANK(sBattleTowerChallengeState)
	call OpenSRAM
	ld a, [hl]
	ld [wScriptVar], a
	jmp CloseSRAM

BattleTowerAction_SetExplanationRead:
	ld a, BANK(sBattleTowerSaveFileFlags)
	call OpenSRAM
	ld a, [sBattleTowerSaveFileFlags]
	or 2
	ld [sBattleTowerSaveFileFlags], a
	jmp CloseSRAM

BattleTowerAction_SetByteToQuickSaveChallenge:
	ld c, BATTLETOWER_SAVED_AND_LEFT
	jr SetBattleTowerChallengeState

BattleTowerAction_SetByteToCancelChallenge:
	ld c, BATTLETOWER_NO_CHALLENGE
SetBattleTowerChallengeState:
	ld a, BANK(sBattleTowerChallengeState)
	call OpenSRAM
	ld a, c
	ld [sBattleTowerChallengeState], a
	jmp CloseSRAM

SaveBattleTowerLevelGroup:
	ld a, BANK(sBTChoiceOfLevelGroup)
	call OpenSRAM
	ldh a, [rWBK]
	push af
	ld a, BANK(wBTChoiceOfLvlGroup)
	ldh [rWBK], a
	ld a, [wBTChoiceOfLvlGroup]
	ld [sBTChoiceOfLevelGroup], a
	pop af
	ldh [rWBK], a
	jmp CloseSRAM

LoadBattleTowerLevelGroup: ; Load level group choice
	ld a, BANK(sBTChoiceOfLevelGroup)
	call OpenSRAM
	ldh a, [rWBK]
	push af
	ld a, BANK(wBTChoiceOfLvlGroup)
	ldh [rWBK], a
	ld a, [sBTChoiceOfLevelGroup]
	ld [wBTChoiceOfLvlGroup], a
	pop af
	ldh [rWBK], a
	jmp CloseSRAM

BattleTower_CheckSaveFileExistsAndIsYours:
	ld a, [wSaveFileExists]
	and a
	jr z, .nope
	farcall CompareLoadedAndSavedPlayerID
	jr z, .yes
	xor a ; FALSE
	jr .nope

.yes
	ld a, TRUE

.nope
	ld [wScriptVar], a
	ret

BattleTowerAction_0A:
	xor a
	ld [wMusicFade], a
	jmp MaxVolume

BattleTowerAction_GSBall:
	ld a, BANK(sGSBallFlag)
	call OpenSRAM
	ld a, [sGSBallFlag]
	ld [wScriptVar], a
	jmp CloseSRAM

BattleTowerAction_EggTicket:
	xor a ; FALSE
	ld [wScriptVar], a
	ld hl, EGG_TICKET
	call GetItemIDFromIndex
	ld [wCurItem], a
	ld hl, wNumItems
	call CheckItem
	ret nc
	ld a, [wPartyCount]
	ld b, 0
	ld c, a
	ld hl, wPartySpecies
.loop
	ld a, [hli]
	cp EGG
	jr nz, .not_egg
	push hl
	ld hl, wPartyMonOTs
	ld de, NAME_LENGTH_JAPANESE
	ld a, b
	and a
	jr z, .skip
.loop2
	add hl, de
	dec a
	jr nz, .loop2
.skip
	ld de, String_MysteryJP
	ld a, NAME_LENGTH_JAPANESE
.compare_loop
	push af
	ld a, [de]
	inc de
	cp [hl]
	inc hl
	jr nz, .different
	pop af
	dec a
	jr nz, .compare_loop
rept 4
	dec hl
endr
	ld a, "@"
	ld [hli], a
	ld [hl], a
	ld hl, EGG_TICKET
	call GetItemIDFromIndex
	pop hl
	ld [wCurItem], a
	ld a, 1
	ld [wItemQuantityChange], a
	ld a, -1
	ld [wCurItemQuantity], a
	ld hl, wNumItems
	call TossItem
	ld a, TRUE
	ld [wScriptVar], a
	ret

.different
	pop af
	pop hl
.not_egg
	inc b
	dec c
	jr nz, .loop
	ret

String_MysteryJP:
	db "なぞナゾ@@" ; MYSTERY

BattleTowerAction_0F:
	ldh a, [rWBK]
	push af
	ld a, BANK(w3_d090)
	ldh [rWBK], a
	ld a, [w3_d090]
	ld [wScriptVar], a
	pop af
	ldh [rWBK], a
	ret

BattleTowerAction_14:
	call BattleTower_CheckSaveFileExistsAndIsYours
	ld a, [wScriptVar]
	and a
	ret z

	ld a, BANK(sBattleTowerSaveFileFlags)
	call OpenSRAM
	ld a, [sBattleTowerSaveFileFlags]
	and 1
	ld [wScriptVar], a
	jmp CloseSRAM

BattleTowerAction_15:
	ld a, BANK(sBattleTowerSaveFileFlags)
	call OpenSRAM
	ld a, [sBattleTowerSaveFileFlags]
	or 1
	ld [sBattleTowerSaveFileFlags], a
	jmp CloseSRAM

LoadOpponentTrainerAndPokemonWithOTSprite:
	farcall LoadOpponentTrainerAndPokemon
	ldh a, [rWBK]
	push af
	ld a, BANK(wBT_OTTrainerClass)
	ldh [rWBK], a
	ld hl, wBT_OTTrainerClass
	ld a, [hl]
	dec a
	ld c, a
	ld b, 0
	pop af
	ldh [rWBK], a
	ld hl, BTTrainerClassSprites
	add hl, bc
	ld a, [hl]
	ld [wBTTempOTSprite], a

; Load sprite of the opponent trainer
; because s/he is chosen randomly and appears out of nowhere
	ld a, [wScriptVar]
	ld e, a
	ld d, 0
	ldh [hUsedSpriteIndex], a
	ld hl, wVariableSprites
	add hl, de
	ld de, -SPRITE_VARS
	add hl, de
	ld a, [wBTTempOTSprite]
	ld [hl], a
; Its colors come from the dynamic object palettes when it appears, like any other object's: OBJ
; palette 1 is not set aside for it, and is usually the follower's.
	farjp ReloadSpriteIndex

INCLUDE "data/trainers/sprites.asm"

CheckForBattleTowerRules:
	farcall _CheckForBattleTowerRules
	jr c, .ready
	xor a ; FALSE
	jr .end

.ready
	ld a, TRUE

.end
	ld [wScriptVar], a
	ret
