CheckPartyFullAfterContest:
	ld a, [wContestMonSpecies]
	and a
	jmp z, .DidntCatchAnything
	ld [wCurPartySpecies], a
	ld [wCurSpecies], a
	call GetBaseData
	ld hl, wPartyCount
	ld a, [hl]
	cp PARTY_LENGTH
	jmp nc, .TryAddToBox
	inc a
	ld [hl], a
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [wContestMonSpecies]
	ld [hli], a
	ld [wCurSpecies], a
	ld [hl], -1
	ld hl, wPartyMon1Species
	ld a, [wPartyCount]
	dec a
	ld bc, PARTYMON_STRUCT_LENGTH
	rst AddNTimes
	ld d, h
	ld e, l
	ld hl, wContestMon
	ld bc, PARTYMON_STRUCT_LENGTH
	rst CopyBytes
	ld a, [wPartyCount]
	dec a
	ld hl, wPartyMonOTs
	call SkipNames
	ld d, h
	ld e, l
	ld hl, wPlayerName
	rst CopyBytes
	ld a, [wCurPartySpecies]
	ld [wNamedObjectIndex], a
	call GetPokemonName
	ld hl, wStringBuffer1
	ld de, wMonOrItemNameBuffer
	ld bc, MON_NAME_LENGTH
	rst CopyBytes
	call GiveANickname_YesNo
	jr c, .Party_SkipNickname
	ld a, [wPartyCount]
	dec a
	ld [wCurPartyMon], a
	xor a
	ld [wMonType], a
	ld de, wMonOrItemNameBuffer
	farcall InitNickname

.Party_SkipNickname:
	ld a, [wPartyCount]
	dec a
	ld hl, wPartyMonNicknames
	call SkipNames
	ld d, h
	ld e, l
	ld hl, wMonOrItemNameBuffer
	rst CopyBytes
	ld a, [wPartyCount]
	dec a
	ld hl, wPartyMon1Level
	call GetPartyLocation
	ld a, [hl]
	ld [wCurPartyLevel], a
	call SetCaughtData
	ld a, [wPartyCount]
	dec a
	ld hl, wPartyMon1CaughtLocation
	call GetPartyLocation
	ld a, [hl]
	and CAUGHT_GENDER_MASK
	ld b, LANDMARK_NATIONAL_PARK
	or b
	ld [hl], a
	xor a
	ld [wContestMonSpecies], a
	and a ; BUGCONTEST_CAUGHT_MON
	ld [wScriptVar], a
	ret

.TryAddToBox:
	farcall NewStorageBoxPointer
	jr c, .BoxFull
	push bc
	xor a
	ld [wCurPartyMon], a
	ld hl, wContestMon
	ld de, wBufferMon
	ld bc, PARTYMON_STRUCT_LENGTH
	rst CopyBytes
	ld hl, wPlayerName
	ld de, wBufferMonOT
	ld bc, NAME_LENGTH
	rst CopyBytes
	ld a, [wCurPartySpecies]
	ld [wBufferMonAltSpecies], a
	ld [wNamedObjectIndex], a
	call GetPokemonName
	pop bc
	ld a, b
	ld [wBufferMonBox], a
	ld a, c
	ld [wBufferMonSlot], a
	farcall UpdateStorageBoxMonFromTemp
	call GiveANickname_YesNo
	ld hl, wStringBuffer1
	jr c, .Box_SkipNickname
	ld a, BUFFERMON
	ld [wMonType], a
	ld de, wMonOrItemNameBuffer
	farcall InitNickname
	ld hl, wMonOrItemNameBuffer

.Box_SkipNickname:
	ld de, wBufferMonNickname
	ld bc, MON_NAME_LENGTH
	rst CopyBytes
	farcall UpdateStorageBoxMonFromTemp

.BoxFull:
	ld a, [wBufferMonLevel]
	ld [wCurPartyLevel], a
	call SetBoxMonCaughtData
	ld hl, wBufferMonCaughtLocation
	ld a, [hl]
	and CAUGHT_GENDER_MASK
	ld b, LANDMARK_NATIONAL_PARK
	or b
	ld [hl], a
	farcall UpdateStorageBoxMonFromTemp
	xor a
	ld [wContestMon], a
	ld a, BUGCONTEST_BOXED_MON
	ld [wScriptVar], a
	ret

.DidntCatchAnything:
	ld a, BUGCONTEST_NO_CATCH
	ld [wScriptVar], a
	ret

GiveANickname_YesNo:
	ld hl, CaughtAskNicknameText
	call PrintText
	jmp YesNoBox

CaughtAskNicknameText:
	text_far _CaughtAskNicknameText
	text_end

SetCaughtData:
	ld a, [wPartyCount]
	dec a
	ld hl, wPartyMon1CaughtLevel
	call GetPartyLocation
	call SetBoxmonOrEggmonCaughtData
	
	; Set the caught ball data
	ld a, [wPartyCount]
	dec a
	ld hl, wPartyMon1
	call GetPartyLocation
	ld bc, MON_CAUGHTBALL
	add hl, bc
	jmp SetCaughtBallData
SetBoxmonOrEggmonCaughtData:
	ld a, [wTimeOfDay]
	inc a
	rrca
	rrca
	and CAUGHT_TIME_MASK
	ld b, a
	ld a, [wCurPartyLevel]
	or b
	ld [hli], a
	ld a, [wMapGroup]
	ld b, a
	ld a, [wMapNumber]
	ld c, a
	cp MAP_POKECENTER_2F
	jr nz, .NotPokecenter2F
	ld a, b
	cp GROUP_POKECENTER_2F
	jr nz, .NotPokecenter2F

	ld a, [wBackupMapGroup]
	ld b, a
	ld a, [wBackupMapNumber]
	ld c, a

.NotPokecenter2F:
	call GetWorldMapLocation
	ld b, a
	ld a, [wPlayerGender]
	rrca ; shift bit 0 (PLAYERGENDER_FEMALE_F) to bit 7 (CAUGHT_GENDER_MASK)
	or b
	ld [hl], a
	ret

SetBoxMonCaughtData:
	ld hl, wBufferMonCaughtData
	call SetBoxmonOrEggmonCaughtData
	
	; Set the caught ball data for box Pokemon
	ld hl, wBufferMon + MON_CAUGHTBALL
	call SetCaughtBallData
	
	farjp UpdateStorageBoxMonFromTemp

SetGiftBoxMonCaughtData:
	ld hl, wBufferMonCaughtLevel
	call SetGiftMonCaughtData
	
	; Set the ball data to Poke Ball (3) for box Pokemon
	ld hl, wBufferMon + MON_CAUGHTBALL
	ld [hl], CAUGHT_POKE_BALL ; Always use Poke Ball for gifts
	
	farjp UpdateStorageBoxMonFromTemp

SetGiftPartyMonCaughtData:
	ld a, [wPartyCount]
	dec a
	ld hl, wPartyMon1CaughtLevel
	push bc
	call GetPartyLocation
	pop bc
	call SetGiftMonCaughtData
	
	; Set the ball data to Poke Ball (3) for party Pokemon
	ld a, [wPartyCount]
	dec a
	ld hl, wPartyMon1
	call GetPartyLocation
	ld bc, MON_CAUGHTBALL
	add hl, bc
	ld [hl], CAUGHT_POKE_BALL ; Always use Poke Ball for gifts
	ret

SetGiftMonCaughtData:
	xor a
	ld [hli], a
	ld a, LANDMARK_GIFT
	rrc b
	or b
	ld [hl], a
	ret

SetEggMonCaughtData:
	ld a, [wCurPartyMon]
	ld hl, wPartyMon1CaughtLevel
	call GetPartyLocation
	ld a, [wCurPartyLevel]
	push af
	ld a, CAUGHT_EGG_LEVEL
	ld [wCurPartyLevel], a
	call SetBoxmonOrEggmonCaughtData

	; Set the caught ball data for eggs
	ld a, [wCurPartyMon]
	ld hl, wPartyMon1
	call GetPartyLocation
	ld bc, MON_CAUGHTBALL
	add hl, bc
	
	; Check if ball is already set (for Odd Eggs with specific balls)
	ld a, [hl]
	and CAUGHT_BALL_MASK
	jr nz, .ball_already_set  ; Don't overwrite if already set. This will not work if it's set to MASTER_BALL (0)
	
	; Set default ball for eggs (Poke Ball)
	ld [hl], CAUGHT_POKE_BALL

.ball_already_set:
	pop af
	ld [wCurPartyLevel], a
	ret


SetCaughtBallData:
; Set the caught ball data for a Pokemon
; Input: hl = pointer to MON_CAUGHTBALL location
	; Check if ball is already defined (non-zero)
  ; This allows Odd Eggs to be set with a specific ball type
  ; We're checking non-zero, so the odd egg can never be set to a MASTER_BALL (since it's represent by 0)
	ld a, [hl]
	and CAUGHT_BALL_MASK
	ret nz            ; Return if ball is already set
	
	ld a, [wCurItem]  ; Get 8-bit item ID
	push hl           ; Save destination pointer
	call GetItemIndexFromID  ; Convert 8-bit ID to 16-bit index in hl
	
	; Check if it's a ball item (0x0200-0x020B range)
	ld a, h
	cp HIGH(FIRST_BALL_ITEM)  ; Compare high byte with 0x02
	jr nz, .not_a_ball       ; If not 0x02, it's not a ball
	
	; High byte is 0x02, check low byte range
	ld a, l
	cp LOW(FIRST_BALL_ITEM)              ; Compare with 0x00
	jr c, .not_a_ball                    ; If < 0x00, not a ball
	cp LOW(FIRST_BALL_ITEM) + NUM_BALL_ITEM_POCKET  ; Compare with 0x0C
	jr nc, .not_a_ball                   ; If >= 0x0C, not a ball
	
	; It's a valid ball, convert to 0-11 range
	sub LOW(FIRST_BALL_ITEM)             ; Convert 0x00-0x0B to 0-11
	jr .store_ball

.not_a_ball
	ld a, CAUGHT_POKE_BALL  ; Default to Poke Ball for non-balls

.store_ball
	pop hl             ; Restore destination pointer
	and CAUGHT_BALL_MASK
	ld [hl], a
	ret
