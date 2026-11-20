if DEF(_DEBUG)

; Tools for the HP TOOLS debug menu (the Youngster's, maps/PlayersHouse2F.asm).

DebugGetLeadHPLevel::
; out: wScriptVar = the lead mon's Hidden Power level
	ld a, [wPartyMon1HPLevel]
	and HP_LEVEL_MASK
	ld [wScriptVar], a
	ret

DebugSetLeadHPLevel::
; Change the lead mon's Hidden Power level by the HP LEVEL menu's choice.
; in: wScriptVar = 1 (+1), 2 (-1), 3 (set 0) or 4 (set MAX_HP_LEVEL)
; out: wScriptVar = the new level
	ld hl, wPartyMon1HPLevel
	ld a, [hl]
	and HP_LEVEL_MASK
	ld b, a
	ld a, [wScriptVar]
	dec a
	jr z, .up
	dec a
	jr z, .down
	dec a
	ld b, 0
	jr z, .set
	ld b, MAX_HP_LEVEL
	jr .set

.up
	ld a, b
	cp MAX_HP_LEVEL
	jr nc, .set
	inc b
	jr .set

.down
	ld a, b
	and a
	jr z, .set
	dec b
.set
	ld a, [hl]
	and ~HP_LEVEL_MASK
	or b
	ld [hl], a
	ld a, b
	ld [wScriptVar], a
	ret

DebugGetLeadHPType::
; out: wStringBuffer1 = the name of the lead mon's Hidden Power type
	ld hl, wPartyMon1
	farcall GetMonStructHiddenPowerType
	ld [wNamedObjectIndex], a
	predef_jump GetTypeName

DebugSetLeadHPType::
; Change the lead mon's Hidden Power type, through its type offset, by the HP TYPE menu's choice.
; in: wScriptVar = 1 (next type), 2 (previous type) or 3 (its DVs' type: offset 0)
; out: wStringBuffer1 = the new type's name
	ld hl, wPartyMon1DVs
	farcall GetDVHiddenPowerIndex
	ld d, a ; the DVs' index
	ld hl, wPartyMon1HPLevel
	ld a, [hl]
	swap a
	and HP_TYPE_MASK >> 4
	xor d
	ld e, a ; the current index
	ld a, [wScriptVar]
	dec a
	jr z, .next
	dec a
	jr z, .previous
	ld a, d
	jr .set

.next
	ld a, e
	inc a
	jr .set

.previous
	ld a, e
	dec a
.set
	and HP_TYPE_MASK >> 4 ; wrap around the 16 types
	xor d ; the offset that gives this index
	swap a
	ld b, a
	ld a, [hl]
	and HP_LEVEL_MASK
	or b
	ld [hl], a
	jr DebugGetLeadHPType

DebugSetUpHiddenPowerPair::
; The last two party mons, just given as Machamp then Alakazam, get DVs that make Machamp's Hidden
; Power a special-side type (Fire) and Alakazam's a physical-side one (Fighting), and Hidden Power
; in their first move slot. Each one's higher stat is the other side, so Hidden Power hits on the
; side of that stat, not its type's side.
	ld a, [wPartyCount]
	sub 2
	ld hl, .MachampDVs
	call .SetUp
	ld a, [wPartyCount]
	dec a
	ld hl, .AlakazamDVs
	; fallthrough

.SetUp:
; in: a = party slot, hl = DVs
	ld [wCurPartyMon], a
	push hl
	ld hl, wPartyMon1
	call GetPartyLocation
	ld d, h
	ld e, l ; de = the mon
	pop hl
	push de
	; DVs
	ld a, [hli]
	ld c, [hl]
	ld hl, MON_DVS
	add hl, de
	ld [hli], a
	ld [hl], c
	; Hidden Power in the first move slot, at full PP
	push de
	ld hl, HIDDEN_POWER
	call GetMoveIDFromIndex
	pop de
	ld hl, MON_MOVES
	add hl, de
	ld [hl], a
	ld hl, MON_PP
	add hl, de
	ld [hl], 15 ; Hidden Power's PP
	; recalculate its stats from the new DVs, at full HP
	ld hl, MON_SPECIES
	add hl, de
	ld a, [hl]
	ld [wCurSpecies], a
	call GetBaseData
	pop de
	ld hl, MON_LEVEL
	add hl, de
	ld a, [hl]
	ld [wCurPartyLevel], a
	push de
	ld hl, MON_EVS - 1
	add hl, de
	push hl
	ld hl, MON_MAXHP
	add hl, de
	ld d, h
	ld e, l
	pop hl
	ld b, TRUE
	predef CalcMonStats
	pop de
	ld hl, MON_MAXHP
	add hl, de
	ld a, [hli]
	ld c, [hl]
	ld hl, MON_HP
	add hl, de
	ld [hli], a
	ld [hl], c
	ret

; Atk/Def, then Spd/Spc. Hidden Power's type is (Atk & 3) << 2 | (Def & 3), skipping Normal:
; 2 << 2 | 0 = Fire, 0 << 2 | 0 = Fighting.
.MachampDVs:
	dn 14, 12
	dn 14, 14
.AlakazamDVs:
	dn 12, 12
	dn 14, 14

endc
