; The forms and alternate shinies the Pokédex has recorded, and how the PICS page shows them.
;
; Each non-plain form of a form species has a flag in wDexFormsSeen and wDexFormsCaught, numbered
; by DexFormFlagRows. Each species in AltShinyPalettes has a flag in wDexAltShiniesSeen and
; wDexAltShiniesCaught, numbered by its row there. A plain form needs no flag: it shows whenever its
; species has been seen. The record lives in WRAMX bank BANK(wDexForms) and is saved to SRAM copies
; of its own (sDexForms, sBackupDexForms).

DEF NUM_UNOWN_FORMS EQU NUM_UNOWN

MACRO dex_form_flags
; species, first form, number of forms
	assert (\2) >= 1 && (\2) + (\3) <= NUM_\1_FORMS, "dex_form_flags \1: forms out of range"
	dw \1
	db \2, \3
	DEF DEX_FORM_FLAGS += \3
ENDM

DexFormFlagRows:
; The order is the save's: never reorder or resize a row. A new form species, or a new form of a
; species that already has a row, gets a new row at the end.
	DEF DEX_FORM_FLAGS = 0
	dex_form_flags CHARMELEON, 1, 1
	dex_form_flags CHARIZARD,  1, 1
	dex_form_flags ARBOK,      1, 1
	dex_form_flags PIKACHU,    1, 3
	dex_form_flags RAICHU,     1, 3
	dex_form_flags NIDORAN_F,  1, 1
	dex_form_flags NIDORINA,   1, 1
	dex_form_flags NIDOQUEEN,  1, 1
	dex_form_flags NIDORAN_M,  1, 1
	dex_form_flags NIDORINO,   1, 1
	dex_form_flags NIDOKING,   1, 1
	dex_form_flags JIGGLYPUFF, 1, 1
	dex_form_flags WIGGLYTUFF, 1, 1
	dex_form_flags ZUBAT,      1, 2
	dex_form_flags GOLBAT,     1, 2
	dex_form_flags PSYDUCK,    1, 1
	dex_form_flags GOLDUCK,    1, 1
	dex_form_flags MACHOP,     1, 1
	dex_form_flags MACHOKE,    1, 1
	dex_form_flags MACHAMP,    1, 1
	dex_form_flags TENTACOOL,  1, 1
	dex_form_flags TENTACRUEL, 1, 1
	dex_form_flags GEODUDE,    1, 1
	dex_form_flags GRAVELER,   1, 1
	dex_form_flags GOLEM,      1, 1
	dex_form_flags SHELLDER,   1, 1
	dex_form_flags CLOYSTER,   1, 1
	dex_form_flags GASTLY,     1, 1
	dex_form_flags HAUNTER,    1, 1
	dex_form_flags GENGAR,     1, 1
	dex_form_flags ELECTRODE,  1, 1
	dex_form_flags KOFFING,    1, 2
	dex_form_flags WEEZING,    1, 2
	dex_form_flags HORSEA,     1, 1
	dex_form_flags SEADRA,     1, 1
	dex_form_flags STARYU,     1, 1
	dex_form_flags STARMIE,    1, 1
	dex_form_flags SCYTHER,    1, 2
	dex_form_flags PINSIR,     1, 2
	dex_form_flags MAGIKARP,   1, 3
	dex_form_flags GYARADOS,   1, 3
	dex_form_flags SNORLAX,    1, 1
	dex_form_flags CROBAT,     1, 2
	dex_form_flags PICHU,      1, 3
	dex_form_flags IGGLYBUFF,  1, 1
	dex_form_flags UNOWN,      1, 25
	dex_form_flags SCIZOR,     1, 2
	dex_form_flags SHUCKLE,    1, 2
	dex_form_flags KINGDRA,    1, 1
	dex_form_flags SMEARGLE,   1, 5
	dw 0 ; end
	assert DEX_FORM_FLAGS <= DEX_FORM_FLAG_CAPACITY, "DexFormFlagRows needs more than DEX_FORM_FLAG_CAPACITY"
	assert DEX_FORM_FLAG_CAPACITY <= 256, "flag numbers are a byte"

DexFormsLookPlain:
; Forms that keep an evolution line's form number but are drawn as the plain form: recorded, never
; offered on the PICS page. A mask of form numbers per species; ends with 0.
	dw PICHU
	db 1 << PICHU_UNUSED_1_FORM | 1 << PICHU_UNUSED_2_FORM
	dw RAICHU
	db 1 << RAICHU_SURF_FORM | 1 << RAICHU_FLY_FORM
	dw ZUBAT
	db 1 << ZUBAT_UNUSED_FORM
	dw KOFFING
	db 1 << KOFFING_UNUSED_FORM
	dw GYARADOS
	db 1 << GYARADOS_XS_FORM | 1 << GYARADOS_XL_FORM
	dw SHUCKLE
	db 1 << SHUCKLE_SHUCKIE_NEUTRAL_FORM
	dw 0 ; end

; Recording. Every entry point keeps every register; a = the species ID.

DexRecordEnemyFormSeen::
; the form byte in wEnemyMonForm
	push bc
	ld c, FALSE
	jr DexRecordEnemyForm

DexRecordEnemyFormCaught::
	push bc
	ld c, TRUE
DexRecordEnemyForm:
	push af
	ld a, [wEnemyMonForm]
	ld b, a
	pop af
	jr DexRecordForm

DexRecordTempMonFormCaught::
; the form byte in wTempMonForm
	push bc
	push af
	ld a, [wTempMonForm]
	ld b, a
	pop af
	ld c, TRUE
	jr DexRecordForm

DexRecordPartyMonFormCaught::
; the form byte of party mon [wCurPartyMon]
	push bc
	push hl
	push af
	ld a, [wCurPartyMon]
	ld hl, wPartyMon1Form
	call GetPartyLocation
	ld b, [hl]
	pop af
	pop hl
	ld c, TRUE
	jr DexRecordForm

DexRecordFormSeen::
; b = the form byte
	push bc
	ld c, FALSE
	jr DexRecordForm

DexRecordFormCaught::
; b = the form byte
	push bc
	ld c, TRUE
	; fallthrough
DexRecordForm:
; b = the form byte, c = TRUE to record it caught as well as seen; bc is on the stack
	push af
	push de
	push hl
	call GetPokemonIndexFromID
	ld d, h
	ld e, l
	ldh a, [rSVBK]
	push af
	ld a, BANK(wDexForms)
	ldh [rSVBK], a
	ld a, [wDexFormsHold]
	and a
	call z, .Record
	pop af
	ldh [rSVBK], a
	pop hl
	pop de
	pop af
	pop bc
	ret

.Record:
; de = the species index, b = the form byte, c = caught too
	ld a, b
	and FORM_MASK
	jr z, .alternate
	push bc
	ld c, a
	call DexForms_GetFlag
	pop bc
	jr nc, .alternate
	ld hl, wDexFormsSeen
	push af
	call DexForms_SetBit
	pop af
	ld hl, wDexFormsCaught
	dec c
	call z, DexForms_SetBit
	inc c
.alternate
	ld a, b
	or ~(SHINY_MASK | ALT_SHINY_MASK)
	inc a ; zero only if both bits were set
	ret nz
	push bc
	call DexForms_GetAltShinyFlag
	pop bc
	ret nc
	ld hl, wDexAltShiniesSeen
	push af
	call DexForms_SetBit
	pop af
	ld hl, wDexAltShiniesCaught
	dec c
	ret nz
	; fallthrough

DexForms_SetBit:
; Set flag a of the array at hl. Keeps bc and de.
	push bc
	call DexForms_BitAddress
	ld a, [hl]
	or b
	ld [hl], a
	pop bc
	ret

DexForms_TestBit:
; nz if flag a of the array at hl is set. Keeps bc and de.
	push bc
	call DexForms_BitAddress
	ld a, [hl]
	and b
	pop bc
	ret

DexForms_BitAddress:
; in: a = flag, hl = array
; out: hl = its byte, b = its bit as a mask
	ld b, a
	rrca
	rrca
	rrca
	and %00011111
	add l
	ld l, a
	adc h
	sub l
	ld h, a
	ld a, b
	and 7
	ld b, 1
	ret z
.shift
	sla b
	dec a
	jr nz, .shift
	ret

DexForms_GetFlag:
; in: de = species index, c = form number (not 0)
; out: carry and a = the form's flag if it has one. Clobbers b and hl.
	ld hl, DexFormFlagRows
	ld b, 0 ; the flag of this row's first form
.loop
	ld a, [hli]
	cp e
	jr nz, .other
	ld a, [hl]
	cp d
	jr z, .species
.other
	dec hl
	ld a, [hli]
	or [hl]
	ret z ; the end, no carry
	inc hl
	inc hl
	jr .next

.species
	inc hl
	ld a, c
	sub [hl] ; how far past the row's first form
	inc hl
	jr c, .next
	cp [hl]
	jr nc, .next
	add b
	scf
	ret

.next
	ld a, [hli] ; the row's number of forms
	add b
	ld b, a
	jr .loop

DexForms_GetAltShinyFlag:
; in: de = species index
; out: carry and a = its row in AltShinyPalettes if it has an alternate shiny. Clobbers bc and hl.
	ld hl, AltShinyPalettes
	ld c, 0
.loop
	push hl
	ld a, BANK(AltShinyPalettes)
	call GetFarWord
	ld a, h
	or l
	jr z, .none
	ld a, l
	cp e
	jr nz, .next
	ld a, h
	cp d
	jr z, .found
.next
	pop hl
	ld a, l
	add 2 + 2 * COLOR_SIZE
	ld l, a
	adc h
	sub l
	ld h, a
	inc c
	jr .loop

.found
	pop hl
	ld a, c
	scf
	ret

.none
	pop hl
	and a
	ret

DexForms_FormCount:
; in: de = species index
; out: a = how many forms it has (1 if it has no flags). Clobbers bc and hl.
	ld hl, DexFormFlagRows
	ld c, 1
.loop
	ld a, [hli]
	ld b, a
	ld a, [hli]
	or b
	jr z, .done
	ld a, b
	cp e
	jr nz, .skip
	dec hl
	ld a, [hli]
	cp d
	jr nz, .skip
	ld a, [hli] ; first form
	add [hl] ; + number of forms
	inc hl
	cp c
	jr c, .loop
	ld c, a
	jr .loop

.skip
	inc hl
	inc hl
	jr .loop

.done
	ld a, c
	ret

DexForms_LooksPlain:
; in: de = species index, c = form number
; out: nz if that form is drawn as the plain form. Clobbers b and hl.
	ld hl, DexFormsLookPlain
.loop
	ld a, [hli]
	ld b, a
	ld a, [hli]
	or b
	ret z ; the end
	ld a, b
	cp e
	jr nz, .next
	dec hl
	ld a, [hli]
	cp d
	jr nz, .next
	ld a, c
	cp 8
	jr nc, .no
	ld b, [hl]
	inc a
.shift
	dec a
	jr z, .test
	srl b
	jr .shift

.test
	bit 0, b
	ret

.no
	xor a
	ret

.next
	inc hl
	jr .loop

; Saving and loading. Called from engine/menus/save.asm and wherever the Pokémon data is reloaded.

SaveDexForms::
	ld a, BANK(sDexFormsMagic)
	ld hl, sDexFormsMagic
	jr _SaveDexForms

SaveBackupDexForms::
	ld a, BANK(sBackupDexFormsMagic)
	ld hl, sBackupDexFormsMagic
_SaveDexForms:
; a = the copy's SRAM bank, hl = its magic
	assert sDexForms - sDexFormsMagic == 2 && sDexFormsChecksum - sDexForms == wDexFormsEnd - wDexForms
	assert sBackupDexForms - sBackupDexFormsMagic == 2 && sBackupDexFormsChecksum - sBackupDexForms == wDexFormsEnd - wDexForms
	call OpenSRAM
	ldh a, [rSVBK]
	push af
	ld a, BANK(wDexForms)
	ldh [rSVBK], a
	ld a, LOW(DEX_FORMS_SAVE_MAGIC)
	ld [hli], a
	ld a, HIGH(DEX_FORMS_SAVE_MAGIC)
	ld [hli], a
	ld d, h
	ld e, l
	ld hl, wDexForms
	ld bc, wDexFormsEnd - wDexForms
	rst CopyBytes
	push de
	ld hl, wDexForms
	call DexForms_Checksum
	pop hl
	ld a, e
	ld [hli], a
	ld [hl], d
	pop af
	ldh [rSVBK], a
	jmp CloseSRAM

LoadDexForms::
	ld a, BANK(sDexFormsMagic)
	ld hl, sDexFormsMagic
	jr _LoadDexForms

LoadBackupDexForms::
	ld a, BANK(sBackupDexFormsMagic)
	ld hl, sBackupDexFormsMagic
_LoadDexForms:
; a = the copy's SRAM bank, hl = its magic. A copy without the magic or with a bad checksum (any
; save from before the record existed) loads as nothing met.
	call OpenSRAM
	ldh a, [rSVBK]
	push af
	ld a, BANK(wDexForms)
	ldh [rSVBK], a
	ld a, [hli]
	cp LOW(DEX_FORMS_SAVE_MAGIC)
	jr nz, .clear
	ld a, [hli]
	cp HIGH(DEX_FORMS_SAVE_MAGIC)
	jr nz, .clear
	push hl
	call DexForms_Checksum ; hl ends on the checksum
	ld a, [hli]
	cp e
	jr nz, .bad
	ld a, [hl]
	cp d
	jr nz, .bad
	pop hl
	ld de, wDexForms
	ld bc, wDexFormsEnd - wDexForms
	rst CopyBytes
	jr .done

.bad
	pop hl
.clear
	ld hl, wDexForms
	ld bc, wDexFormsEnd - wDexForms
	xor a
	rst ByteFill
.done
	xor a
	ld [wDexFormsHold], a
	pop af
	ldh [rSVBK], a
	jmp CloseSRAM

DexForms_Checksum:
; in: hl = a copy of the record
; out: de = the sum of its bytes, hl = just past it
	ld de, 0
	ld b, wDexFormsEnd - wDexForms
.loop
	ld a, [hli]
	add e
	ld e, a
	adc d
	sub e
	ld d, a
	dec b
	jr nz, .loop
	ret

; GiveEgg adds the egg's mon to the party as if it were met, then takes back the species flags.
; These hold the record off around it.

DexFormsHoldOn::
; Keeps every register.
	push af
	ld a, TRUE
	jr DexFormsSetHold

DexFormsHoldOff::
; Keeps every register.
	push af
	xor a
DexFormsSetHold:
; a = the hold; af is on the stack
	push hl
	ld l, a
	ldh a, [rSVBK]
	ld h, a
	ld a, BANK(wDexFormsHold)
	ldh [rSVBK], a
	ld a, l
	ld [wDexFormsHold], a
	ld a, h
	ldh [rSVBK], a
	pop hl
	pop af
	ret

; The Pokédex.

DexForms_IsViewable:
; in: de = species index, c = form number
; out: nz if the dex may show that form: the plain form, or a seen one that doesn't look plain.
; Clobbers a, b and hl.
	ld a, c
	and a
	jr z, .yes
	call DexForms_LooksPlain
	jr nz, .no
	call DexForms_GetFlag
	jr nc, .no
	ld b, a
	ldh a, [rSVBK]
	push af
	ld a, BANK(wDexFormsSeen)
	ldh [rSVBK], a
	ld a, b
	ld hl, wDexFormsSeen
	call DexForms_TestBit
	ld b, a ; nz if seen
	pop af
	ldh [rSVBK], a
	ld a, b
	and a
	ret

.yes
	inc a
	ret

.no
	xor a
	ret

DexForms_CheckFlag:
; in: a = flag, hl = array in WRAMX bank BANK(wDexForms)
; out: nz if set. Clobbers b.
	ld b, a
	ldh a, [rSVBK]
	push af
	ld a, BANK(wDexForms)
	ldh [rSVBK], a
	ld a, b
	call DexForms_TestBit
	ld b, a
	pop af
	ldh [rSVBK], a
	ld a, b
	and a
	ret

Pokedex_UpdateAltSeen::
; Set wPokedexAltSeen for species ID a. Keeps every register.
	push af
	call Pokedex_CheckAltSeen
	ld [wPokedexAltSeen], a
	pop af
	ret

Pokedex_CheckAltSeen:
; out: a = TRUE if species ID a has been seen as an alternate shiny, else FALSE. Keeps bc, de and hl.
	push bc
	push de
	push hl
	call GetPokemonIndexFromID
	ld d, h
	ld e, l
	call DexForms_GetAltShinyFlag
	ld b, FALSE
	jr nc, .got
	ld hl, wDexAltShiniesSeen
	call DexForms_CheckFlag
	jr z, .got
	ld b, TRUE
.got
	ld a, b
	pop hl
	pop de
	pop bc
	ret

Pokedex_IconForm:
; out: a = the form byte the evolution chart colors species ID a's icon with: plain, shiny when the
; shiny toggle is on, and its alternate shiny when the toggle is set to that and its alternate has
; been seen. Keeps bc, de and hl.
	push bc
	ld c, a
	ld a, [wPokedexShinyToggle]
	ld b, a
	xor a
	bit POKEDEX_SHINY_F, b
	jr z, .done
	ld a, SHINY_MASK
	bit POKEDEX_ALT_SHINY_F, b
	jr z, .done
	ld a, c
	call Pokedex_CheckAltSeen
	and a
	ld a, SHINY_MASK
	jr z, .done
	ld a, SHINY_MASK | ALT_SHINY_MASK
.done
	pop bc
	ret

LoadDexEvoIconPal::
; Load the OBJ palette numbered for the evolution chart's icon slot [hObjectStructIndex] with species
; [wTempIconSpecies]'s own colors, as Pokedex_IconForm picks them.
; out: a = the palette
	ld a, [wPokedexDisplayForm]
	push af
	ld a, [wTempIconSpecies]
	call Pokedex_IconForm
	ld [wPokedexDisplayForm], a
	ld bc, wPokedexDisplayForm
	ldh a, [hObjectStructIndex]
	ld e, a
	ld a, [wTempIconSpecies]
	farcall LoadMonIconOBPal
	pop af
	ld [wPokedexDisplayForm], a
	farcall ApplyOBPals
	ld a, TRUE
	ldh [hCGBPalUpdate], a
	ldh a, [hObjectStructIndex]
	ret

Pokedex_StepViewForm::
; Move wPokedexViewForm to the next (PAD_RIGHT in a) or previous viewable form of species
; [wCurPartySpecies], wrapping round.
; out: carry if it changed
	ld b, a
	ld a, [wCurPartySpecies]
	call GetPokemonIndexFromID
	ld d, h
	ld e, l
	push bc
	call DexForms_FormCount
	pop bc
	ld c, a ; the number of forms
	ld a, [wPokedexViewForm]
	ld l, a ; where it started
	ld h, a ; the form being tried
.try
	bit B_PAD_RIGHT, b
	ld a, h
	jr z, .previous
	inc a
	cp c
	jr c, .got
	xor a
	jr .got

.previous
	and a
	jr nz, .back
	ld a, c
.back
	dec a
.got
	ld h, a
	cp l
	ret z ; round to where it started: nothing else to show, no carry
	push bc
	push hl
	ld c, a
	call DexForms_IsViewable
	pop hl
	pop bc
	jr z, .try
	ld a, h
	ld [wPokedexViewForm], a
	scf
	ret

Pokedex_PlaceFormLabel::
; "FORM ◀n/m▶" at hl: the form shown is the n-th of the m the dex may show for species
; [wCurPartySpecies]. Nothing when there is only the plain form. The ◀ is a ▶ that
; Pokedex_PicsPageAttrmap flips, as the font has no ◀ of its own.
	push hl
	ld a, [wCurPartySpecies]
	call GetPokemonIndexFromID
	ld d, h
	ld e, l
	call DexForms_FormCount
	ld [wPokedexFormCount], a
	xor a
	ld [wPokedexFormsShown], a
	ld [wPokedexFormPlace], a
	ld c, a
.loop
	push bc
	call DexForms_IsViewable
	pop bc
	jr z, .next
	ld hl, wPokedexFormsShown
	inc [hl]
	ld a, [wPokedexViewForm]
	cp c
	jr nz, .next
	ld a, [hl]
	ld [wPokedexFormPlace], a
.next
	inc c
	ld a, [wPokedexFormCount]
	cp c
	jr nz, .loop
	pop hl
	ld a, [wPokedexFormsShown]
	cp 2
	ret c
	push hl
	ld de, .Form
	rst PlaceString
	pop hl
	ld bc, .FormEnd - .Form - 1
	add hl, bc
	ld de, wPokedexFormPlace
	lb bc, PRINTNUM_LEFTALIGN | 1, 2
	call PrintNum
	ld a, "/"
	ld [hli], a
	ld de, wPokedexFormsShown
	lb bc, PRINTNUM_LEFTALIGN | 1, 2
	call PrintNum
	ld [hl], "▶"
	ret

.Form:
	db "FORM ▶@"
.FormEnd:

Pokedex_PicsCaughtBall::
; nz if the PICS page shows its caught ball for species [wTempSpecies] in wPokedexViewForm and the
; colors in wPokedexDisplayForm: the species caught for the plain form, the form caught for any other,
; and when an alternate shiny is shown, that caught too.
	ld a, [wTempSpecies]
	call GetPokemonIndexFromID
	ld d, h
	ld e, l
	ld a, [wPokedexViewForm]
	and a
	jr nz, .form
	push de
	call CheckCaughtMonIndex
	pop de
	ret z
	jr .alternate

.form
	ld c, a
	call DexForms_GetFlag
	jr nc, .not_caught
	ld hl, wDexFormsCaught
	call DexForms_CheckFlag
	ret z
.alternate
	ld a, [wPokedexDisplayForm]
	and ALT_SHINY_MASK
	jr z, .caught
	call DexForms_GetAltShinyFlag
	jr nc, .not_caught
	ld hl, wDexAltShiniesCaught
	jmp DexForms_CheckFlag

.caught
	inc a
	ret

.not_caught
	xor a
	ret

Pokedex_ShinyGlyph::
; out: a = the glyph for the colors in wPokedexDisplayForm: none, "<DEX_⁂>" or "<ALT_SHINY>"
	ld a, [wPokedexDisplayForm]
	or ~(SHINY_MASK | ALT_SHINY_MASK)
	inc a ; zero only if both bits were set
	ld a, "<ALT_SHINY>"
	ret z
	ld a, [wPokedexDisplayForm]
	and SHINY_MASK
	ld a, " "
	ret z
	ld a, "<DEX_⁂>"
	ret

Pokedex_PlaceShinyGlyph::
; The glyph for the colors the selected species is shown in, at hl. Keeps bc, de and hl.
	call GetPokedexDisplayForm
	call Pokedex_ShinyGlyph
	ld [hl], a
	ret

GetPokedexDisplayForm::
; out: a = [wPokedexDisplayForm] = the form the PICS page shows (plain everywhere else), shiny when
; the Pokédex shiny toggle is on, and an alternate shiny when the toggle is set to that and the
; species' alternate has been seen. Keeps bc, de and hl.
	push bc
	ld a, [wPokedexShinyToggle]
	ld c, a
	ld a, [wPokedexViewForm]
	bit POKEDEX_SHINY_F, c
	jr z, .got_form
	or SHINY_MASK
	bit POKEDEX_ALT_SHINY_F, c
	jr z, .got_form
	ld b, a
	ld a, [wPokedexAltSeen]
	and a
	ld a, b
	jr z, .got_form
	or ALT_SHINY_MASK
.got_form
	ld [wPokedexDisplayForm], a
	pop bc
	ret
