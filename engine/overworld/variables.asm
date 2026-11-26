_GetVarAction::
	ld a, c
	cp NUM_VARS
	jr c, .valid
	xor a
.valid
	ld c, a
	ld b, 0
	ld hl, .VarActionTable
	add hl, bc
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld b, [hl]
	ld a, b
	and RETVAR_EXECUTE
	jr nz, .call
	ld a, b
	and RETVAR_ADDR_DE
	ret nz
	ld a, [de]
	jr .loadstringbuffer2

.call
	jmp _de_

.loadstringbuffer2
	ld de, wStringBuffer2
	ld [de], a
	ret

.VarActionTable:
; entries correspond to VAR_* constants
	; RETVAR_STRBUF2: copy [de] to wStringBuffer2
	; RETVAR_ADDR_DE: return address in de
	; RETVAR_EXECUTE: call function
	dwb wStringBuffer2,                 RETVAR_STRBUF2
	dwb wPartyCount,                    RETVAR_STRBUF2
	dwb .BattleResult,                  RETVAR_EXECUTE
	dwb wBattleType,                    RETVAR_ADDR_DE
	dwb wTimeOfDay,                     RETVAR_STRBUF2
	dwb .CountCaughtMons,               RETVAR_EXECUTE
	dwb .CountSeenMons,                 RETVAR_EXECUTE
	dwb .CountBadges,                   RETVAR_EXECUTE
	dwb wPlayerState,                   RETVAR_ADDR_DE
	dwb .PlayerFacing,                  RETVAR_EXECUTE
	dwb hHours,                         RETVAR_STRBUF2
	dwb .DayOfWeek,                     RETVAR_EXECUTE
	dwb wMapGroup,                      RETVAR_STRBUF2
	dwb wMapNumber,                     RETVAR_STRBUF2
	dwb .UnownCaught,                   RETVAR_EXECUTE
	dwb wEnvironment,                   RETVAR_STRBUF2
	dwb .BoxFreeSpace,                  RETVAR_EXECUTE
	dwb wBugContestMinsRemaining,       RETVAR_STRBUF2
	dwb wXCoord,                        RETVAR_STRBUF2
	dwb wYCoord,                        RETVAR_STRBUF2
	dwb wSpecialPhoneCallID,            RETVAR_STRBUF2
	dwb wNrOfBeatenBattleTowerTrainers, RETVAR_STRBUF2
	dwb wKurtApricornQuantity,          RETVAR_STRBUF2
	dwb wCurCaller,                     RETVAR_ADDR_DE
	dwb wBlueCardBalance,               RETVAR_ADDR_DE
	dwb wBuenasPassword,                RETVAR_ADDR_DE
	dwb wKenjiBreakTimer,               RETVAR_STRBUF2
	dwb .CountUncaughtMons,             RETVAR_EXECUTE
	dwb wFollowerState,                 RETVAR_ADDR_DE

.CountCaughtMons:
; Caught mons, of the game's own: completion doesn't count the new slots. Saturate at 255.
	ld hl, wPokedexCaught
.count_caught_or_seen_mons
	call CountOriginalDexFlags
	ld a, b
.load_or_saturate
	add -1
	sbc a
	or c
	jr .loadstringbuffer2

.CountSeenMons:
; Seen mons, of the game's own. Saturate at 255.
	ld hl, wPokedexSeen
	jr .count_caught_or_seen_mons

.CountUncaughtMons:
; Mons left to catch, of the game's own. Saturate at 255.
	ld hl, wPokedexCaught
	call CountOriginalDexFlags
	ld a, LOW(NUM_ORIGINAL_POKEMON)
	sub c
	ld c, a
	ld a, HIGH(NUM_ORIGINAL_POKEMON)
	sbc b
	jr .load_or_saturate

.CountBadges:
; Number of owned badges.
	ld hl, wBadges
	ld b, 2
	call CountSetBits
	ld a, [wNumSetBits]
	jmp .loadstringbuffer2

.PlayerFacing:
; The direction the player is facing.
	ld a, [wPlayerDirection]
	and $c
	rrca
	rrca
	jmp .loadstringbuffer2

.DayOfWeek:
; The day of the week.
	call GetWeekday
	jmp .loadstringbuffer2

.UnownCaught:
; Number of unique Unown caught.
	call .count_unown
	ld a, b
	jmp .loadstringbuffer2

.count_unown
	ld hl, wUnownDex
	ld b, 0
.loop
	ld a, [hli]
	cp -1
	ret z
	inc b
	ld a, b
	cp NUM_UNOWN
	jr c, .loop
	ret

.BoxFreeSpace:
; Remaining database entries
	farcall CheckFreeDatabaseEntries
	jmp .loadstringbuffer2

.BattleResult:
	ld a, [wBattleResult]
	and ~BATTLERESULT_BITMASK
	jmp .loadstringbuffer2

CountOriginalDexFlags::
; Count the set bits for the game's own species (indexes 1 to NUM_ORIGINAL_POKEMON) in the dex flag
; array at hl. The new slots after them don't count towards completion.
; Returns in bc; clobbers everything else
	ld b, NUM_ORIGINAL_POKEMON / 8
	call CountSetBits ; leaves hl at the byte holding the rest
	ld b, 0
	assert NUM_ORIGINAL_POKEMON % 8, "the last of the game's own species shares a byte with the new slots"
	ld a, [hl]
	and (1 << (NUM_ORIGINAL_POKEMON % 8)) - 1
.rest
	and a
	ret z
	srl a
	jr nc, .rest
	inc c
	jr .rest
