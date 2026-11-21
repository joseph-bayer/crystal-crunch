; Red/Blue forms (and the Spaceworld beta forms that count as them) have one Special stat,
; so their Sp.Atk and Sp.Def are always equal, and no gender. See data/pokemon/rb_forms.asm.

; The stand-in pointer LoadEnemyMon passes CalcMonStats for a wild mon: it isn't a whole struct,
; so the wild mon's form is read from wEnemyMonForm instead.
DEF WILD_MON_STATS_POINTER EQUS "(wEnemyMonDVs - (MON_DVS - MON_EVS + 1))"

GetRBFormSpecial::
; a = species ID, c = form byte.
; Returns carry and a = the Special base if this is an RB form, else no carry.
; Preserves bc, de and hl.
	push hl
	push de
	push bc
	call GetPokemonIndexFromID
	ld a, c
	and FORM_MASK
	ld c, a
	ld de, RBFormTable
	ld b, NUM_RB_FORM_ROWS
.loop
	ld a, [de]
	inc de
	cp l
	jr nz, .skip3
	ld a, [de]
	cp h
	jr nz, .skip3
	inc de
	ld a, [de]
	inc de
	cp c
	jr nz, .skip1
	ld a, [de]
	and a
	jr nz, .found
	; 0: the species' Red/Blue Special
	dec hl
	ld de, KantoMonSpecials
	add hl, de
	ld a, BANK(KantoMonSpecials)
	call GetFarByte
.found
	scf
	jr .done

.skip3
	inc de
	inc de
.skip1
	inc de
	dec b
	jr nz, .loop
	and a
.done
	pop bc
	pop de
	pop hl
	ret

ApplyRBFormStats::
; Called by CalcMonStats after GetBaseData has filled wCurBaseData.
; hl = the mon's EVs - 1 (MON_EVS - 1), b = TRUE if EVs count.
; For an RB form, use its Special as both Sp.Atk and Sp.Def bases, and if EVs count,
; make its two Special EVs one pool: both bytes take the higher.
; Preserves all registers but af.
	push hl
	push de
	push bc
	ld a, l
	cp LOW(WILD_MON_STATS_POINTER)
	jr nz, .struct
	ld a, h
	cp HIGH(WILD_MON_STATS_POINTER)
	jr nz, .struct
	ld a, [wEnemyMonForm]
	jr .got_form

.struct
	push hl
	ld de, MON_FORM - (MON_EVS - 1)
	add hl, de
	ld a, [hl]
	pop hl
.got_form
	ld c, a
	ld a, [wBaseSpecies]
	call GetRBFormSpecial
	jr nc, .done
	ld [wBaseSpecialAttack], a
	ld [wBaseSpecialDefense], a
	pop bc
	push bc
	ld a, b
	and a
	jr z, .done
	ld de, MON_SAT_EV - (MON_EVS - 1)
	add hl, de
	ld a, [hli]
	cp [hl]
	jr nc, .got_pool
	ld a, [hl]
.got_pool
	ld [hld], a
	ld [hl], a
.done
	pop bc
	pop de
	pop hl
	ret

IsRBFormGenderless::
; Called by GetGender. hl = the mon's DVs, [wCurPartySpecies] = its species.
; Returns carry if it's an RB form, which has no gender.
; Preserves all registers but af.
	push hl
	push bc
	ld a, l
	cp LOW(wEnemyMonDVs)
	jr nz, .struct
	ld a, h
	cp HIGH(wEnemyMonDVs)
	jr nz, .struct
	ld a, [wEnemyMonForm]
	jr .got_form

.struct
	dec hl
	dec hl
	assert MON_DVS - MON_FORM == 2
	ld a, [hl]
.got_form
	ld c, a
	ld a, [wCurPartySpecies]
	call GetRBFormSpecial
	pop bc
	pop hl
	ret

GetRBBreedMons::
; Returns a with bit 0 set if wBreedMon1 is a Red/Blue form, and bit 1 if wBreedMon2 is.
; Preserves bc, de and hl.
	push bc
	ld a, [wBreedMon2Form]
	ld c, a
	ld a, [wBreedMon2Species]
	call GetRBFormSpecial
	sbc a
	and %10
	ld b, a
	ld a, [wBreedMon1Form]
	ld c, a
	ld a, [wBreedMon1Species]
	call GetRBFormSpecial
	sbc a
	and %01
	or b
	pop bc
	ret

IsInheritableGen1TutorMove::
; Called by GetEggMove. de = the index of a move the father knows.
; Returns carry if it's a Gen 1 tutor move that the egg (wEggMonSpecies), or anything it evolves
; into, learned by TM in Red/Blue. Preserves bc, de and hl.
	push hl
	push de
	push bc
	ld hl, Gen1TutorMoves
	ld c, 0
.find_move
	ld a, [hli]
	cp e
	ld a, [hli]
	jr nz, .next_move
	cp d
	jr z, .found_move
.next_move
	inc c
	ld a, c
	cp NUM_GEN1_TUTOR_MOVES
	jr c, .find_move
	; no carry: not a Gen 1 tutor move
	jr .done

.found_move
	ld e, c
	ld a, [wEggMonSpecies]
	call GetPokemonIndexFromID
	ld b, h
	ld c, l
	call .CheckLine
.done
	pop bc
	pop de
	pop hl
	ret

.CheckLine:
; bc = a species index, e = a Gen 1 tutor move number.
; Returns carry if that species, or anything it evolves into, learned the move in Red/Blue.
	call CanLearnGen1TutorMove
	ret c
	ld hl, EvosAttacksPointers
	ld a, BANK(EvosAttacksPointers)
	call LoadDoubleIndirectPointer
	ld d, a
.evolution_loop
	ld a, d
	call GetFarByte
	inc hl
	and a
	ret z ; no carry
	cp EVOLVE_LEVEL
	jr z, .skip_parameter_byte
	cp EVOLVE_HAPPINESS
	jr z, .skip_parameter_byte
	inc hl
.skip_parameter_byte
	inc hl
	push hl
	ld a, d
	call GetFarWord
	ld b, h
	ld c, l
	push de
	call .CheckLine
	pop de
	pop hl
	ret c
	inc hl
	inc hl
	jr .evolution_loop

CanLearnGen1TutorMove::
; bc = a species index, e = a Gen 1 tutor move number (its place in Gen1TutorMoves).
; Returns carry if that species learned the move by TM in Red/Blue. Preserves bc, de and hl.
	ld a, b
	and a
	ret nz ; no carry: not a Kanto species
	ld a, c
	and a
	ret z
	cp NUM_KANTO_POKEMON + 1
	ret nc
	push hl
	push bc
	dec a
	ld l, a
	ld h, 0
	ld b, h
	ld c, l
	assert GEN1_TUTOR_LEARNSET_WIDTH == 5
	add hl, hl
	add hl, hl
	add hl, bc
	ld bc, Gen1TutorLearnsets
	add hl, bc
	ld a, e
	rrca
	rrca
	rrca
	and %00011111
	ld c, a
	ld b, 0
	add hl, bc
	ld a, e
	and 7
	inc a
	ld c, a
	ld a, [hl]
.bit_loop
	rrca
	dec c
	jr nz, .bit_loop
	; carry is the move's bit
	pop bc
	pop hl
	ret

IsTempMonRBForm::
; Returns carry if wTempMon is an RB form. Preserves all registers but af.
	push bc
	ld a, [wTempMonForm]
	ld c, a
	ld a, [wTempMonSpecies]
	call GetRBFormSpecial
	pop bc
	ret

PoolRBFormBattleEVs::
; Called after a battle's EV gain. hl = just past the party mon's EVs,
; bit 0 of e = it has Pokérus, wBaseSpAtkSpDefEVs = the defeated species' Special yields.
; An RB form's two Special EVs are one pool: it gets the Sp.Def yield on top of the
; Sp.Atk yield, in both bytes.
; Preserves all registers but af.
	push hl
	push de
	push bc
	ld a, [wBaseSpAtkSpDefEVs]
	swap a
	and %11 ; Sp.Def yield
	bit 0, e
	jr z, .no_pokerus
	add a
.no_pokerus
	ld d, a
	push hl
	ld bc, MON_FORM - (MON_EVS + NUM_STATS)
	add hl, bc
	ld a, [hl]
	pop hl
	push af
	push hl
	ld bc, MON_SPECIES - (MON_EVS + NUM_STATS)
	add hl, bc
	ld a, [hl]
	pop hl
	pop bc
	ld c, b
	call GetRBFormSpecial
	jr nc, .done
	dec hl
	dec hl
	assert MON_SDF_EV == MON_EVS + NUM_STATS - 1 && MON_SAT_EV == MON_SDF_EV - 1
	ld a, [hli]
	add d
	jr c, .cap
	cp MAX_EV + 1
	jr c, .got_pool
.cap
	ld a, MAX_EV
.got_pool
	cp [hl]
	jr nc, .store
	ld a, [hl]
.store
	ld [hld], a
	ld [hl], a
.done
	pop bc
	pop de
	pop hl
	ret
