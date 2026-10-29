MoveDeletion:
	ld hl, .DeleterIntroText
	call PrintText
	call YesNoBox
	jr c, .declined
	ld hl, .DeleterAskWhichMonText
	call PrintText
	farcall SelectMonFromParty
	jr c, .declined
	ld a, [wCurPartySpecies]
	cp EGG
	jr z, .egg
	ld a, [wCurPartyMon]
	ld hl, wPartyMon1Moves + 1
	ld bc, PARTYMON_STRUCT_LENGTH
	rst AddNTimes
	ld a, [hl]
	and a
	jr z, .onlyonemove
	ld hl, .DeleterAskWhichMoveText
	call PrintText
	call LoadStandardMenuHeader
	farcall ChooseMoveToDelete
	push af
	call ReturnToMapWithSpeechTextbox
	pop af
	jr c, .declined
	ld a, [wMenuCursorY]
	push af
	ld a, [wCurSpecies]
	ld [wNamedObjectIndex], a
	call GetMoveName
	ld hl, .AskDeleteMoveText
	call PrintText
	call YesNoBox
	pop bc
	jr c, .declined
	call .DeleteMove
	call WaitSFX
	ld de, SFX_MOVE_DELETED
	call PlaySFX
	call WaitSFX
	ld hl, .DeleterForgotMoveText
	call PrintText

	; Revert Pikachu to normal form it it is in Surf form and no longer knows Surf
	ld hl, PIKACHU
	farcall CheckPokemonIsSpecies
	jr z, .RevertPikachuFormIfNecessary

	ret

.egg
	ld hl, .MailEggText
	jmp PrintText

.declined
	ld hl, .DeleterNoComeAgainText
	jmp PrintText

.onlyonemove
	ld hl, .MoveKnowsOneText
	jmp PrintText

.MoveKnowsOneText:
	text_far _MoveKnowsOneText
	text_end

.AskDeleteMoveText:
	text_far _AskDeleteMoveText
	text_end

.DeleterForgotMoveText:
	text_far _DeleterForgotMoveText
	text_end

.MailEggText:
	text_far _DeleterEggText
	text_end

.DeleterNoComeAgainText:
	text_far _DeleterNoComeAgainText
	text_end

.DeleterAskWhichMoveText:
	text_far _DeleterAskWhichMoveText
	text_end

.DeleterIntroText:
	text_far _DeleterIntroText
	text_end

.DeleterAskWhichMonText:
	text_far _DeleterAskWhichMonText
	text_end

.RevertPikachuFormIfNecessary
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
	ld a, [hl]
	and FORM_MASK ; only care about form bits, not shiny bit
	cp PIKACHU_SURF_FORM  ; Surfing form
	jr nz, .should_revert_fly_form  ; Not in Surf form, check if fly form should be reverted

	; Pikachu is in surfing form, check if it still knows Surf
	ld hl, SURF
	farcall CheckPokemonKnowsMove
	ret z ; Still knows Surf, keep surfing form

	call .revert_pikachu_to_plain_form
	jr .check_for_new_pikachu_form

.should_revert_fly_form
	ld a, [hl]
	and FORM_MASK ; only care about form bits, not shiny bit
	cp PIKACHU_FLY_FORM  ; Flying form
	ret nz ; any other form, such as RB, never turns into Surf or Fly

	ld hl, FLY
	farcall CheckPokemonKnowsMove
	ret z ; Still knows Fly, keep flying form

	call .revert_pikachu_to_plain_form
	jr .check_for_new_pikachu_form

.revert_pikachu_to_plain_form
	; Pikachu no longer knows Surf, revert to plain form
	ld hl, wPartyMon1Species
	ld a, [wCurPartyMon]
	call GetPartyLocation
	ld bc, MON_FORM
	add hl, bc
	ld a, [hl]
	and SHINY_MASK | ALT_SHINY_MASK ; only keep its shininess. Clear everything else.
	ld [hl], a
	ret

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
	ret

.check_flying_pikachu
	ld hl, FLY
	farcall CheckPokemonKnowsMove
	ret nz  ; Doesn't know Fly, nothing to do

	; Pikachu knows Fly, set its form to FLYING_PIKACHU (form 2)
	ld hl, wPartyMon1Species
	ld a, [wCurPartyMon]
	call GetPartyLocation
	ld bc, MON_FORM
	add hl, bc
	ld a, PIKACHU_FLY_FORM  ; Flying Pikachu form
	or [hl] ; preserve shiny bit
	ld [hl], a
	ret

.DeleteMove:
	ld a, b
	push bc
	dec a
	ld c, a
	ld b, 0
	ld hl, wPartyMon1Moves
	add hl, bc
	ld a, [wCurPartyMon]
	ld bc, PARTYMON_STRUCT_LENGTH
	rst AddNTimes
	pop bc
	push bc
	inc b
.loop
	ld a, b
	cp NUM_MOVES + 1
	jr z, .okay
	inc hl
	ld a, [hld]
	ld [hli], a
	inc b
	jr .loop

.okay
	xor a
	ld [hl], a
	pop bc

	ld a, b
	push bc
	dec a
	ld c, a
	ld b, 0
	ld hl, wPartyMon1PP
	add hl, bc
	ld a, [wCurPartyMon]
	ld bc, PARTYMON_STRUCT_LENGTH
	rst AddNTimes
	pop bc
	inc b
.loop2
	ld a, b
	cp NUM_MOVES + 1
	jr z, .done
	inc hl
	ld a, [hld]
	ld [hli], a
	inc b
	jr .loop2

.done
	xor a
	ld [hl], a
	ret
