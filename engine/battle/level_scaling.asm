; Trainer and wild Pokémon whose level scales with the player's badges (LEVEL_FROM_BADGES).

TrainerMonLevel::
; ReadTrainerPartyPieces, for each Pokemon: a = the party's level byte, hl = its species in the party
; data (bank wTrainerGroupBank). Set wCurPartyLevel and return the species index in de: for a
; LEVEL_FROM_BADGES entry, the stage of the named line its level reaches. Then let an Elite Four
; seat replace the level. Carry as EliteFourSeatMonLevel. Preserves bc and hl.
	push hl
	push af
	ld a, [wTrainerGroupBank]
	call GetFarWord
	ld d, h
	ld e, l
	pop af
	pop hl
	cp MAX_LEVEL + 1
	push af
	call SetLevelFromByte
	pop af
	call nc, GrowToLevel
	jmp EliteFourSeatMonLevel

SetLevelFromByte::
; Set wCurPartyLevel from the party level byte in a.
	call LevelFromBadges
	ld [wCurPartyLevel], a
	ret

LevelFromBadges::
; Return the level for a trainer party or wild slot level byte in a. A byte up to MAX_LEVEL is the
; level itself; above it, the base level for the player's badge count (no more than the map's cap
; in BadgeScalingCaps) plus (a - LEVEL_FROM_BADGES), kept within MIN_LEVEL to MAX_LEVEL.
; Preserves bc, de and hl.
	cp MAX_LEVEL + 1
	ret c
	push bc
	push de
	push hl
	sub LEVEL_FROM_BADGES
	push af ; the offset, signed
	ld hl, wBadges
	ld b, (NUM_JOHTO_BADGES + 7) / 8 + (NUM_KANTO_BADGES + 7) / 8
	call CountSetBits
	call CapBadgeCount
	ld e, a
	ld d, 0
	ld hl, BadgeBaseLevels
	add hl, de
	pop af
	ld e, a
	ld a, [hl]
	bit 7, e
	jr nz, .lower
	add e
	cp MAX_LEVEL + 1
	jr c, .done
	ld a, MAX_LEVEL
	jr .done

.lower
; Adding a negative offset carries unless the level went below 0.
	add e
	jr nc, .min
	cp MIN_LEVEL
	jr nc, .done
.min
	ld a, MIN_LEVEL
.done
	pop hl
	pop de
	pop bc
	ret

CapBadgeCount:
; a = a badge count; return it no higher than the current map's cap in BadgeScalingCaps.
	ld c, a
	ld hl, BadgeScalingCaps
.loop
	ld a, [hli]
	cp -1
	jr z, .done
	ld b, a
	ld a, [wMapGroup]
	cp b
	ld a, [hli]
	jr nz, .next
	ld b, a
	ld a, [wMapNumber]
	cp b
	jr nz, .next
	ld a, [hl]
	cp c
	jr nc, .done
	ld c, a
	jr .done
.next
	inc hl ; past the cap
	jr .loop
.done
	ld a, c
	ret

GrowToLevel::
; de = the final species a LEVEL_FROM_BADGES entry names. Return in de the stage of its line that
; wCurPartyLevel reaches: the line's first stage (the next one, for a baby), then each evolution
; toward that species whose level, or its method's stand-in level, has been reached. The target is
; kept in hMathBuffer. Preserves bc and hl.
	push bc
	push hl
	ld a, e
	ldh [hMathBuffer], a
	ld a, d
	ldh [hMathBuffer + 1], a
	ld h, d
	ld l, e
	add hl, hl
	ld bc, FirstEvoStages - 2
	add hl, bc
	ld a, BANK(FirstEvoStages)
	call GetFarWord
	ld b, h
	ld c, l
	call IsBabyStage
	jr nc, .loop
	call NextStageToward
	jr c, .done

.loop
	ld d, b
	ld e, c
	call IsTargetSpecies
	jr z, .done
	push bc
	call NextStageToward
	jr c, .stay
	ld hl, wCurPartyLevel
	cp [hl]
	jr z, .reached
	jr nc, .stay
.reached
	pop de ; the stage before
	jr .loop

.stay
	pop bc
.done
	ld d, b
	ld e, c
	pop hl
	pop bc
	ret

IsTargetSpecies:
; z if de is GrowToLevel's target.
	ldh a, [hMathBuffer]
	cp e
	ret nz
	ldh a, [hMathBuffer + 1]
	cp d
	ret

IsBabyStage:
; Carry if species bc is one of BabyStages.
	ld hl, BabyStages
.loop
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	and e
	inc a
	ret z ; -1: the end
	ld a, e
	cp c
	jr nz, .loop
	ld a, d
	cp b
	jr nz, .loop
	scf
	ret

NextStageToward:
; Return in bc the evolution of species bc that leads to GrowToLevel's target (it is the target, or
; evolves into it), and in a the level it takes. Carry if there is none, with bc kept.
	push bc
	push de
	push hl
	ld hl, EvosAttacksPointers
	ld a, BANK(EvosAttacksPointers)
	call LoadDoubleIndirectPointer
.next
	call ReadEvolution
	jr z, .none
	call IsTargetSpecies
	jr z, .found
	push bc
	push de
	push hl
	ld b, d
	ld c, e
	call EvolvesIntoTarget
	pop hl
	pop de
	pop bc
	jr nc, .next
.found
	ld a, c
	pop hl
	ld b, d
	ld c, e
	pop de
	inc sp ; the species bc held
	inc sp
	and a
	ret

.none
	pop hl
	pop de
	pop bc
	scf
	ret

EvolvesIntoTarget:
; Carry if one of species bc's evolutions is GrowToLevel's target.
	ld hl, EvosAttacksPointers
	ld a, BANK(EvosAttacksPointers)
	call LoadDoubleIndirectPointer
.loop
	call ReadEvolution
	ret z
	call IsTargetSpecies
	jr nz, .loop
	scf
	ret

ReadEvolution:
; Read the evolution at b:hl and move hl past it. z at the end of the list; otherwise de = the
; species and c = the level it takes (a stand-in level for item, trade and happiness).
	ld a, b
	call GetFarByte
	inc hl
	and a
	ret z
	ld d, a ; the method
	ld a, b
	call GetFarByte
	inc hl
	ld c, a ; the level, for level and stat evolutions
	ld a, d
	cp EVOLVE_LEVEL
	jr z, .species
	cp EVOLVE_STAT
	jr z, .skip_byte
	ld c, SCALED_HAPPINESS_EVO_LEVEL
	cp EVOLVE_HAPPINESS
	jr z, .species
	ld c, SCALED_ITEM_EVO_LEVEL
	cp EVOLVE_ITEM
	jr z, .skip_byte
	ld c, SCALED_TRADE_EVO_LEVEL
.skip_byte
	inc hl
.species
	push hl
	ld a, b
	call GetFarWord
	ld d, h
	ld e, l
	pop hl
	inc hl
	inc hl
	or 1 ; nz
	ret

BabyStages:
; Never shown as a scaled trainer Pokémon: their lines start at the next stage.
	dw PICHU, CLEFFA, IGGLYBUFF, TOGEPI, TYROGUE, SMOOCHUM, ELEKID, MAGBY
	dw -1

INCLUDE "data/trainers/badge_base_levels.asm"
INCLUDE "data/trainers/badge_scaling_caps.asm"
