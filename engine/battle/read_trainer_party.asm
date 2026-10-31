ReadTrainerParty:
	ld a, [wInBattleTowerBattle]
	bit IN_BATTLE_TOWER_BATTLE_F, a
	ret nz

	ld a, [wLinkMode]
	and a
	ret nz

	ld hl, wOTPartyCount
	xor a
	ld [hli], a
	dec a
	ld [hl], a

	ld hl, wOTPartyMons
	ld bc, PARTYMON_STRUCT_LENGTH * PARTY_LENGTH
	xor a
	rst ByteFill

	ld a, [wOtherTrainerClass]
	cp CAL
	jr nz, .not_cal2
	ld a, [wOtherTrainerID]
	cp CAL2
	jr z, .cal2
.not_cal2
	call FindTrainerParty
	call GetNextTrainerDataByte
	ld [wOtherTrainerType], a
	ld d, h
	ld e, l
	call ReadTrainerPartyPieces
	farcall EliteFourSeatFinishParty

.done
	jmp ComputeTrainerReward

; Fighting the Myster Gift Trainer (Cal2)
.cal2
	ld a, BANK(sMysteryGiftTrainer)
	call OpenSRAM
	ld a, TRAINERTYPE_MOVES
	ld [wOtherTrainerType], a
	ld de, sMysteryGiftTrainer
	call ReadTrainerPartyPieces
	call CloseSRAM
	jr .done


FindTrainerParty:
; Point hl at the trainer type byte of party wOtherTrainerID in class wOtherTrainerClass, with the
; group's bank in wTrainerGroupBank.
	ld a, [wOtherTrainerClass]
	dec a
	ld c, a
	ld b, 0
	ld hl, TrainerGroups
	add hl, bc
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld [wTrainerGroupBank], a
	ld a, [hli]
	ld h, [hl]
	ld l, a

	ld a, [wOtherTrainerID]
	ld b, a
.skip_trainer
	dec b
	jr z, .got_trainer
.loop
	ld a, [wTrainerGroupBank]
	call GetFarByte
	add l
	ld l, a
	jr nc, .skip_trainer
	inc h
	jr .skip_trainer
.got_trainer
	inc hl

.skip_name
	call GetNextTrainerDataByte
	cp "@"
	jr nz, .skip_name
	ret

ReadTrainerPartyPieces:
	ld h, d
	ld l, e
	; hl = pointer to level

.loop
	; Check if we're done reading this trainer's party
	call GetNextTrainerDataByte
	cp -1 ; Trainer party terminator
	ret z

	; Store level in wCurPartyLevel and get the species in de, both scaled by badges if the byte
	; asks for it. An Elite Four seat sets its own levels and team size.
	farcall TrainerMonLevel
	ret c

	; Past the species
	inc hl
	inc hl
	push hl
	ld h, d
	ld l, e
	call GetPokemonIDFromIndex
	ld [wCurPartySpecies], a

	; Add mon to party
	ld a, OTPARTYMON
	ld [wMonType], a
	predef TryAddMonToParty
	pop hl

	ld a, [wOtherTrainerType]
	and TRAINERTYPE_FORM
	jr nz, .has_form
	; No form byte in the trainer data, so this mon is plain. TryAddMonToParty seeds
	; the form from wEnemyMonForm, which still holds the last battle's form (and its
	; shiny flag), so it has to be cleared here or the mon inherits it.
	push hl
	ld a, [wOTPartyCount]
	dec a
	ld hl, wOTPartyMon1Form
	call GetPartyLocation
	ld [hl], PLAIN_FORM
	pop hl
	jr .no_form

.has_form
	; Has a form, update it in the party data
	; Start by getting the location of this mon's form from the party data into de
	push hl
	ld a, [wOTPartyCount]
	dec a
	ld hl, wOTPartyMon1Form
	call GetPartyLocation
	ld d, h
	ld e, l
	pop hl

	; hl = pointer to form byte from party data
	; de = pointer to mon's form in ot party
	push hl
	call GetNextTrainerDataByte
	; a = form byte from trainer data
	ld [de], a
	pop hl
	inc hl

.no_form
	call .StolenStarterShiny
	; Check if this mon has an item
	ld a, [wOtherTrainerType]
	and TRAINERTYPE_ITEM
	jr z, .no_item
	; Has an item, update it in the party data
	push hl
	ld a, [wOTPartyCount]
	dec a
	ld hl, wOTPartyMon1Item
	call GetPartyLocation
	ld d, h
	ld e, l
	pop hl
	push hl
	; hl = pointer to item low byte
	call GetNextTrainerDataByte
	push af
	; hl = pointer to item high byte
	call GetNextTrainerDataByte
	ld h, a ; high byte of item
	pop af
	ld l, a ; low byte of item
	call GetItemIDFromIndex
	pop hl
	ld [de], a ; de = pointer to mon's held item in ot party
	inc hl
	inc hl
.no_item

	; Check if this mon has moves
	ld a, [wOtherTrainerType]
	rra ; TRAINERTYPE_MOVES_F == 0
	jr nc, .no_moves
	; Has moves, update them in the party data
	push hl
	ld a, [wOTPartyCount]
	dec a
	ld hl, wOTPartyMon1Moves
	call GetPartyLocation
	ld d, h
	ld e, l
	pop hl

	ld b, NUM_MOVES
.copy_moves
	call GetNextTrainerDataByte
	push hl
	push af
	call GetNextTrainerDataByte
	ld h, a
	pop af
	ld l, a
	call GetMoveIDFromIndex
	pop hl
	inc hl
	ld [de], a
	inc de
	dec b
	jr nz, .copy_moves

	push hl

	ld a, [wOTPartyCount]
	dec a
	ld hl, wOTPartyMon1
	call GetPartyLocation
	ld d, h
	ld e, l
	ld hl, MON_PP
	add hl, de

	push hl
	ld hl, MON_MOVES
	add hl, de
	pop de

	ld b, NUM_MOVES
.copy_pp
	ld a, [hli]
	and a
	jr z, .copied_pp

	push hl
	ld l, a
	ld a, MOVE_PP
	call GetMoveAttribute
	pop hl

	ld [de], a
	inc de
	dec b
	jr nz, .copy_pp
.copied_pp

	pop hl
.no_moves
	; Move to the next mon in the party OR the -1 terminator
	jmp .loop

.StolenStarterShiny:
; SILVER's stolen starter, in every rival battle: shiny if it was shiny on ELM's table. He only ever
; has the line he stole, so any starter's line here is that one. Preserves bc, de and hl.
	ld a, [wOtherTrainerClass]
	cp RIVAL1
	jr z, .rival
	cp RIVAL2
	ret nz
.rival
	push bc
	push de
	push hl
	ld a, [wCurPartySpecies]
	call GetPokemonIndexFromID
	farcall IsStarterShiny
	jr nc, .not_shiny
	ld a, [wOTPartyCount]
	dec a
	ld hl, wOTPartyMon1Form
	call GetPartyLocation
	ld a, [hl]
	or SHINY_MASK
	ld [hl], a
.not_shiny
	pop hl
	pop de
	pop bc
	ret

ComputeTrainerReward:
	ld hl, hProduct
	xor a
	ld [hli], a
	ld [hli], a ; hMultiplicand + 0
	ld [hli], a ; hMultiplicand + 1
	ld a, [wEnemyTrainerBaseReward]
	ld [hli], a ; hMultiplicand + 2
	ld a, [wCurPartyLevel]
	ld [hl], a ; hMultiplier
	call Multiply
	ld hl, wBattleReward
	xor a
	ld [hli], a
	ldh a, [hProduct + 2]
	ld [hli], a
	ldh a, [hProduct + 3]
	ld [hl], a
	ret

Battle_GetTrainerName::
	ld a, [wInBattleTowerBattle]
	bit IN_BATTLE_TOWER_BATTLE_F, a
	ld hl, wOTPlayerName
	ld a, BANK(@)
	ld [wTrainerGroupBank], a
	jr nz, CopyTrainerName

	ld a, [wOtherTrainerID]
	ld b, a
	ld a, [wOtherTrainerClass]
	ld c, a
	; fallthrough

GetTrainerName::
	ld a, c
	cp CAL
	jr nz, .not_cal2

	ld a, BANK(sMysteryGiftTrainerHouseFlag)
	call OpenSRAM
	ld a, [sMysteryGiftTrainerHouseFlag]
	and a
	call CloseSRAM
	jr z, .not_cal2

	ld a, BANK(sMysteryGiftPartnerName)
	call OpenSRAM
	ld hl, sMysteryGiftPartnerName
	call CopyTrainerName
	jmp CloseSRAM

.not_cal2
	dec c
	push bc
	ld b, 0
	ld hl, TrainerGroups
	add hl, bc
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld [wTrainerGroupBank], a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop bc

.loop
	dec b
	jr z, .done

	ld a, [wTrainerGroupBank]
	call GetFarByte
	add l
	ld l, a
	jr nc, .loop
	inc h
	jr .loop

.done
	inc hl
	; fallthrough

CopyTrainerName:
	ld de, wStringBuffer1
	push de
	ld bc, NAME_LENGTH
	ld a, [wTrainerGroupBank]
	call FarCopyBytes
	pop de
	ret
; Get the byte in hl and store it in a
; move hl forward so it's ready for the next byte
GetNextTrainerDataByte:
	ld a, [wTrainerGroupBank]
	call GetFarByte
	inc hl
	ret

INCLUDE "data/trainers/party_pointers.asm"

SetTrainerBattleLevel:
	ld a, 255
	ld [wCurPartyLevel], a

	ld a, [wInBattleTowerBattle]
	bit 0, a
	ret nz

	ld a, [wLinkMode]
	and a
	ret nz

; The first Pokemon's level, found the way ReadTrainerParty finds the party
	call FindTrainerParty
	inc hl ; the trainer type
	call GetNextTrainerDataByte
	farjp SetLevelFromByte
