IsAPokemon::
; Return carry if species a is not a Pokemon.
	and a
	jr z, .NotAPokemon
	cp EGG
	jr z, .Pokemon
	cp MON_TABLE_ENTRIES + 1
	jr c, .Pokemon

.NotAPokemon:
	scf
	ret

.Pokemon:
	and a
	ret

DrawBattleHPBar::
; Draw an HP bar d tiles long at hl
; Fill it up to e pixels

	push hl
	push de
	push bc

; Place 'HP:'
	ld a, $60
	ld [hli], a
	ld a, $61
	ld [hli], a

; Draw a template
	push hl
	ld a, $62 ; empty bar
.template
	ld [hli], a
	dec d
	jr nz, .template
	ld a, $6b ; bar end
	add b
	ld [hl], a
	pop hl

; Safety check # pixels
	ld a, e
	and a
	jr nz, .fill
	ld a, c
	and a
	jr z, .done
	ld e, 1

.fill
; Keep drawing tiles until pixel length is reached
	ld a, e
	sub TILE_WIDTH
	jr c, .lastbar

	ld e, a
	ld a, $6a ; full bar
	ld [hli], a
	ld a, e
	and a
	jr z, .done
	jr .fill

.lastbar
	ld a, $62  ; empty bar
	add e      ; + e
	ld [hl], a

.done
	jmp PopBCDEHL

PrepMonFrontpic::
	ld a, $1
	ld [wBoxAlignment], a

_PrepMonFrontpic::
	ld a, [wCurPartySpecies]
	call IsAPokemon
	jr c, .not_pokemon

	push hl
	ld de, vTiles2
	predef GetMonFrontpic
	pop hl
	xor a
	ldh [hGraphicStartTile], a
	lb bc, 7, 7
	predef PlaceGraphic
	xor a
	ld [wBoxAlignment], a
	ret

.not_pokemon
	xor a
	ld [wBoxAlignment], a
	inc a
	ld [wCurPartySpecies], a
	ret

PlayStereoCry::
	push af
	ld a, 1
	ld [wStereoPanningMask], a
	pop af
	call _PlayMonCry
	jmp WaitSFX

PlayStereoCry2::
; Don't wait for the cry to end.
; Used during pic animations.
	push af
	ld a, 1
	ld [wStereoPanningMask], a
	pop af
	jr _PlayMonCry

PlayMonCry::
	call PlayMonCry2
	jmp WaitSFX

PlayMonCry2::
; Don't wait for the cry to end.
	push af
	xor a
	ld [wStereoPanningMask], a
	ld [wCryTracks], a
	pop af

_PlayMonCry::
	push hl
	push de
	push bc

	call GetCryIndex
	jr c, .done

	ld e, c
	ld d, b
	call PlayCry

.done
	jmp PopBCDEHL

LoadCry::
	call GetCryIndex
	ret c

	ldh a, [hROMBank]
	push af
	ld a, BANK(PokemonCries)
	rst Bankswitch

	ld hl, PokemonCries
rept MON_CRY_LENGTH
	add hl, bc
endr

	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a

	ld a, [hli]
	ld [wCryPitch], a
	ld a, [hli]
	ld [wCryPitch + 1], a
	ld a, [hli]
	ld [wCryLength], a
	ld a, [hl]
	ld [wCryLength + 1], a

	pop af
	rst Bankswitch
	and a
	ret

GetCryIndex::
	and a
	jr z, .no
	cp MON_TABLE_ENTRIES + 1
	jr nc, .no

	push hl
	call GetPokemonIndexFromID
	dec hl
	ld b, h
	ld c, l
	pop hl
	and a
	ret

.no
	scf
	ret

PrintLevel::
; Print wTempMonLevel at hl

	ld a, [wTempMonLevel]
_PrintLevel::
	ld [hl], "<LV>" ; no-optimize *hl++|*hl-- = N (a is used)
	inc hl

; How many digits?
	ld c, 2
	cp 100 ; This is distinct from MAX_LEVEL.
	jr c, Print8BitNumLeftAlign

; 3-digit numbers overwrite the :L.
	dec hl
	inc c
	jr Print8BitNumLeftAlign

PrintLevel_Force3Digits::
; Print :L and all 3 digits
	ld [hl], "<LV>" ; no-optimize *hl++|*hl-- = N (a is used)
	inc hl
	ld c, 3

Print8BitNumLeftAlign::
	ld [wTextDecimalByte], a
	ld de, wTextDecimalByte
	ld b, PRINTNUM_LEFTALIGN | 1
	jmp PrintNum

GetBaseData::
	push hl
	push de
	push bc
	ldh a, [hROMBank]
	push af

; Egg doesn't have BaseData
	ld a, [wCurSpecies]
	cp EGG
	jr z, .egg

; Get BaseData
	call GetPokemonIndexFromID
	ld b, h
	ld c, l
	ld a, BANK(BaseData)
	ld hl, BaseData
	call LoadIndirectPointer
	; jr z, <some error handler>
	rst Bankswitch
	ld de, wCurBaseData
	ld bc, BASE_DATA_SIZE
	rst CopyBytes
	jr .end

.egg
	ld de, UnusedEggPic

; Sprite dimensions
	ld b, $55 ; 5x5
	ld hl, wBasePicSize
	ld [hl], b

; Beta front and back sprites
; (see pokegold-spaceworld's data/pokemon/base_stats/*)
	ld hl, wBaseUnusedFrontpic
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
	ld a, e
	ld [hli], a
	ld [hl], d

.end
; Replace Pokedex # with species
	ld a, [wCurSpecies]
	ld [wBaseSpecies], a

	pop af
	rst Bankswitch
	jmp PopBCDEHL

GetCurNickname::
	ld a, [wCurPartyMon]
	ld hl, wPartyMonNicknames

GetNickname::
; Get nickname a from list hl.

	push hl
	push bc

	call SkipNames
	ld de, wStringBuffer1

	push de
	ld bc, MON_NAME_LENGTH
	rst CopyBytes
	pop de

	farcall CorrectNickErrors

	pop bc
	pop hl
	ret

GetMonDrawForm::
; The form byte to draw a mon with. An egg is drawn with the pattern of the species inside it (from
; SpecialEggPatterns) plus the egg's own shiny bit; anything else with its own form byte. The stored
; byte is never changed.
; in: a = the mon's species-list value (EGG for an egg), hl = its party_struct
; out: a = the form byte; bc, de and hl preserved
	assert MON_SPECIES == 0
	assert EGG_PLAIN_PATTERN == 0
	assert NUM_EGG_PATTERNS - 1 <= FORM_MASK, "egg patterns must fit in FORM_MASK"
	push bc
	push de
	push hl
	ld bc, MON_FORM
	add hl, bc
	ld c, [hl] ; c = the stored form byte
	pop hl
	push hl
	cp EGG
	ld a, c
	jr nz, .done
	and SHINY_MASK
	ld b, a ; b = the egg's shiny bit
	ld a, [hl] ; the species inside
	call GetPokemonIndexFromID
	ld d, h
	ld e, l ; de = its 16-bit index
	ld hl, SpecialEggPatterns
.loop
	ld a, [hli]
	ld c, a
	or [hl]
	jr z, .got_pattern ; the end: a = EGG_PLAIN_PATTERN
	ld a, [hli]
	cp d
	jr nz, .next
	ld a, c
	cp e
	jr nz, .next
	ld a, [hl]
	jr .got_pattern

.next
	inc hl
	jr .loop

.got_pattern
	or b
.done
	pop hl
	pop de
	pop bc
	ret

SpecialEggPatterns:
; Species whose eggs are drawn with a pattern of their own, by 16-bit index. Any other egg uses
; EGG_PLAIN_PATTERN. Each pattern needs a row in the EGG tables listed in adding_cosmetic_forms.md.
	dw ELEKID
	db EGG_ELEKID_PATTERN
	dw 0 ; end
