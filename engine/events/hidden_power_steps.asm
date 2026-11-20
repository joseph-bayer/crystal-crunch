StepHiddenPower::
; Every 256 steps, while a hatched Unown that hasn't fainted is in the party, each party mon may
; gain a Hidden Power level -- at most one, from either of two 1/4 chances of its own: one for
; travelling with the Unown, and a second when it holds a GLYPH SHARD. Without such an Unown
; nobody gains, shard or not. Eggs and fainted mons never gain, and MAX_HP_LEVEL is the cap.
	ld a, [wPartyCount]
	and a
	ret z
	call .PartyHasUnown
	ret nc

	ld e, 0 ; party slot
.loop
	ld hl, wPartySpecies
	ld b, 0
	ld c, e
	add hl, bc
	ld a, [hl]
	cp EGG
	jr z, .next

	; a fainted mon doesn't grow
	ld a, e
	ld hl, wPartyMon1HP
	push de
	call GetPartyLocation
	pop de
	ld a, [hli]
	or [hl]
	jr z, .next

	ld a, e
	ld hl, wPartyMon1HPLevel
	push de
	call GetPartyLocation
	pop de
	ld a, [hl]
	and HP_LEVEL_MASK
	cp MAX_HP_LEVEL
	jr nc, .next

	; its roll for travelling with the Unown
	call Random
	and %11
	jr z, .gain

	; the GLYPH SHARD holder's second roll
	push de
	push hl
	ld a, e
	ld hl, wPartyMon1Item
	call GetPartyLocation
	ld a, [hl]
	call GetItemIndexFromID
	ld a, l
	cp LOW(GLYPH_SHARD)
	jr nz, .no_shard
	ld a, h
	cp HIGH(GLYPH_SHARD)
.no_shard
	pop hl
	pop de
	jr nz, .next
	call Random
	and %11
	jr nz, .next

.gain
	inc [hl] ; the level is the low nibble, and it's below MAX_HP_LEVEL, so this can't carry out
.next
	inc e
	ld a, [wPartyCount]
	cp e
	jr nz, .loop
	ret

.PartyHasUnown:
; out: carry if a hatched Unown that hasn't fainted is in the party
	ld e, 0 ; party slot
.unown_loop
	ld hl, wPartySpecies
	ld b, 0
	ld c, e
	add hl, bc
	ld a, [hl]
	cp -1
	ret z ; the list's end; z means no carry here
	cp EGG
	jr z, .next_unown
	call IsUnownID
	jr nz, .next_unown
	ld a, e
	ld hl, wPartyMon1HP
	push de
	call GetPartyLocation
	pop de
	ld a, [hli]
	or [hl]
	jr z, .next_unown
	scf
	ret

.next_unown
	inc e
	jr .unown_loop
