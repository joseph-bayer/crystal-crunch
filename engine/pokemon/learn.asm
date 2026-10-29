LearnMove:
	call LoadTilemapToTempTilemap
	ld a, [wCurPartyMon]
	ld hl, wPartyMonNicknames
	call GetNickname
	ld hl, wStringBuffer1
	ld de, wMonOrItemNameBuffer
	ld bc, MON_NAME_LENGTH
	rst CopyBytes

.loop
	ld hl, wPartyMon1Moves
	ld bc, PARTYMON_STRUCT_LENGTH
	ld a, [wCurPartyMon]
	rst AddNTimes
	ld d, h
	ld e, l
	ld b, NUM_MOVES
; Get the first empty move slot.  This routine also serves to
; determine whether the Pokemon learning the moves already has
; all four slots occupied, in which case one would need to be
; deleted.
.next
	ld a, [hl]
	and a
	jr z, .learn
	inc hl
	dec b
	jr nz, .next
; If we're here, we enter the routine for forgetting a move
; to make room for the new move we're trying to learn.
	push de
	call ForgetMove
	pop de
	jr c, .cancel

	push hl
	push de
	ld [wNamedObjectIndex], a

	ld b, a
	ld a, [wBattleMode]
	and a
	jr z, .not_disabled
	ld a, [wDisabledMove]
	cp b
	jr nz, .not_disabled
	xor a
	ld [wDisabledMove], a
	ld [wPlayerDisableCount], a
.not_disabled

	call GetMoveName
	ld hl, Text_1_2_and_Poof ; 1, 2 and…
	call PrintText
	pop de
	pop hl

.learn
	ld a, [wPutativeTMHMMove]
	ld [hl], a
	ld bc, MON_PP - MON_MOVES
	add hl, bc

	push hl
	ld l, a
	ld a, MOVE_PP
	call GetMoveAttribute
	pop hl

	ld [hl], a

	ld a, [wBattleMode]
	and a
	jr z, .learned

	ld a, [wCurPartyMon]
	ld b, a
	ld a, [wCurBattleMon]
	cp b
	jr nz, .learned

	ld a, [wPlayerSubStatus5]
	bit SUBSTATUS_TRANSFORMED, a
	jr nz, .learned

	ld h, d
	ld l, e
	ld de, wBattleMonMoves
	ld bc, NUM_MOVES
	rst CopyBytes
	ld bc, wPartyMon1PP - (wPartyMon1Moves + NUM_MOVES)
	add hl, bc
	ld de, wBattleMonPP
	ld bc, NUM_MOVES
	rst CopyBytes
	jr .learned

.cancel
	ld hl, StopLearningMoveText
	call PrintText
	call YesNoBox
	jmp c, .loop

	ld hl, DidNotLearnMoveText
	call PrintText
	ld b, 0
	ret

.learned
	ld hl, LearnedMoveText
	call PrintText
	
; Update Pokemon forms based on updated movepool
; - If the Pokemon can change form based on know moves...
;   - First, we'll check if any existing move forms should be reverted
;   - Then we'll check if any new move forms should be applied

	; Check if the Pokemon is Pikachu using 16-bit index
	ld hl, PIKACHU
	farcall CheckPokemonIsSpecies
	jp nz, .done

	; Get Form
	ld hl, wPartyMon1Species
	ld a, [wCurPartyMon]
	call GetPartyLocation
	ld bc, MON_FORM
	add hl, bc
	ld a, [hl]
	and FORM_MASK ; only care about form bits, not shiny bit

	cp PIKACHU_PLAIN_FORM
	jr z, .check_for_new_pikachu_form  ; Plain form, check if it should change


.should_revert_surf_form
	; If in surf form, check if it still knows Surf and revert if not
	ld a, [hl]
	and FORM_MASK ; only care about form bits, not shiny bit
	cp PIKACHU_SURF_FORM  
	jr nz, .should_revert_fly_form

	; Pikachu is in surfing form, check if it still knows Surf
	ld hl, SURF
	farcall CheckPokemonKnowsMove
	jr z, .done  ; Still knows Surf, keep surf form

	call .reset_pikachu_to_plain_form
	jr .check_for_new_pikachu_form ; Check if it should change to fly form

.should_revert_fly_form
	; If in fly form, check if it still knows Fly and revert if not
	ld a, [hl]
	and FORM_MASK ; only care about form bits, not shiny bit
	cp PIKACHU_FLY_FORM  ; Fly form
	jr nz, .done ; any other form, such as RB, never turns into Surf or Fly

	ld hl, FLY
	farcall CheckPokemonKnowsMove
	jr z, .done  ; Still knows Fly, keep fly form

	call .reset_pikachu_to_plain_form
	; fallthrough to check if it should change to a new form

.check_for_new_pikachu_form
	ld hl, SURF
	farcall CheckPokemonKnowsMove
	jr nz, .check_flying_pikachu

	; Pikachu knows Surf and is in its default form
	; Set its form to SURFING_PIKACHU (form 1)
	ld hl, wPartyMon1Species
	ld a, [wCurPartyMon]
	call GetPartyLocation
	ld bc, MON_FORM
	add hl, bc
	ld a, PIKACHU_SURF_FORM  ; Surfing Pikachu form
	or [hl] ; preserve shiny bit
	ld [hl], a
	jr .done

.check_flying_pikachu
	ld hl, FLY
	farcall CheckPokemonKnowsMove
	jr nz, .done  ; Doesn't know Fly, nothing to do

	; Pikachu knows Fly, set its form to FLYING_PIKACHU (form 2)
	ld hl, wPartyMon1Species
	ld a, [wCurPartyMon]
	call GetPartyLocation
	ld bc, MON_FORM
	add hl, bc
	ld a, PIKACHU_FLY_FORM  ; Flying Pikachu form
	or [hl] ; preserve shiny bit
	ld [hl], a
	jr .done

.reset_pikachu_to_plain_form
	; Pikachu no longer knows Surf, revert to plain form
	ld hl, wPartyMon1Species
	ld a, [wCurPartyMon]
	call GetPartyLocation
	ld bc, MON_FORM
	add hl, bc
	ld a, [hl]
	and SHINY_MASK | ALT_SHINY_MASK ; only keep its shininess. Clear everything else.
	ld [hl], a
.done
	
	ld b, 1
	ret

ForgetMove:
	push hl
	ld hl, AskForgetMoveText
	call PrintText
	call YesNoBox
	pop hl
	ret c
	ld bc, -NUM_MOVES
	add hl, bc
	push hl
	ld de, wListMoves_MoveIndicesBuffer
	ld bc, NUM_MOVES
	rst CopyBytes
	pop hl
.loop
	push hl
	ld hl, MoveAskForgetText
	call PrintText
	hlcoord 5, 2
	lb bc, NUM_MOVES * 2, MOVE_NAME_LENGTH
	call Textbox
	hlcoord 5 + 2, 2 + 2
	ld a, SCREEN_WIDTH * 2
	ld [wListMovesLineSpacing], a
	predef ListMoves
	; w2DMenuData
	ld a, $4
	ld [w2DMenuCursorInitY], a
	ld a, $6
	ld [w2DMenuCursorInitX], a
	ld a, [wNumMoves]
	inc a
	ld [w2DMenuNumRows], a
	ld a, $1
	ld [w2DMenuNumCols], a
	ld [wMenuCursorY], a
	ld [wMenuCursorX], a
	ld a, $3
	ld [wMenuJoypadFilter], a
	ld a, $20
	ld [w2DMenuFlags1], a
	xor a
	ld [w2DMenuFlags2], a
	ld a, $20
	ld [w2DMenuCursorOffsets], a
	call StaticMenuJoypad
	push af
	call SafeLoadTempTilemapToTilemap
	pop af
	pop hl
	bit B_PAD_B, a
	jr nz, .cancel
	push hl
	ld a, [wMenuCursorY]
	dec a
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [hl] ; any move, HMs included: the party can still use an HM by learnability
	pop hl
	add hl, bc
	and a
	ret

.cancel
	scf
	ret

LearnedMoveText:
	text_far _LearnedMoveText
	text_end

MoveAskForgetText:
	text_far _MoveAskForgetText
	text_end

StopLearningMoveText:
	text_far _StopLearningMoveText
	text_end

DidNotLearnMoveText:
	text_far _DidNotLearnMoveText
	text_end

AskForgetMoveText:
	text_far _AskForgetMoveText
	text_end

Text_1_2_and_Poof:
	text_far Text_MoveForgetCount ; 1, 2 and…
	text_asm
	push de
	ld de, SFX_SWITCH_POKEMON
	call PlaySFX
	pop de
	ld hl, .MoveForgotText
	ret

.MoveForgotText:
	text_far _MoveForgotText
	text_end

