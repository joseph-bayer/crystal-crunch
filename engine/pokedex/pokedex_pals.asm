; Palettes and attributes the Pokédex entry pages add to their CGB layouts

Pokedex_LoadEntryTypePals:
; Palette 7 draws the type tiles: black, then each type's color.
	ld de, wBGPals1 palette 7
	call LoadSingleBlackPal
	ld a, [wTempSpecies]
	ld [wCurSpecies], a
	call GetBaseData
	ld a, [wBaseType1]
	ld c, a
	predef GetMonTypeIndex
	ld de, wBGPals1 palette 7 + 2
	call LoadMonBaseTypePal
	ld a, [wBaseType2]
	ld c, a
	ld a, [wBaseType1]
	cp c
	ld de, wBGPals1 palette 7 + 4
	jr z, .same_type
	predef GetMonTypeIndex
	ld de, wBGPals1 palette 7 + 4
	jmp LoadMonBaseTypePal

.same_type
	jmp LoadSingleBlackPal

CheckPokedexColor:
; out: a = PREDEFPAL_* for the Pokédex frame color the player picked
	ld a, [wCurPokedexColor]
	cp NUM_DEXCOLORS
	jr c, .ok
	xor a ; DEXCOLOR_RED
.ok
	push hl
	push de
	ld e, a
	ld d, 0
	ld hl, .Palettes
	add hl, de
	ld a, [hl]
	pop de
	pop hl
	ret

.Palettes:
; entries correspond to DEXCOLOR_* constants
	table_width 1
	db PREDEFPAL_POKEDEX       ; DEXCOLOR_RED
	db PREDEFPAL_TRADE_TUBE    ; DEXCOLOR_BLUE
	db PREDEFPAL_RB_PURPLEMON  ; DEXCOLOR_PURPLE
	db PREDEFPAL_RB_BROWNMON   ; DEXCOLOR_BROWN
	db PREDEFPAL_RB_GREENMON   ; DEXCOLOR_GREEN
	db PREDEFPAL_RB_PINKMON    ; DEXCOLOR_PINK
	db PREDEFPAL_RB_YELLOWMON  ; DEXCOLOR_YELLOW
	db PREDEFPAL_RB_CYANMON    ; DEXCOLOR_CYAN
	db PREDEFPAL_CGB_BADGE     ; DEXCOLOR_GRAY
	assert_table_length NUM_DEXCOLORS

Pokedex_EntryAttrmap:
; the type tiles
	hlcoord 9, 4, wAttrmap
	lb bc, 1, 8
	ld a, 7 | VRAM_BANK_1
	call FillBoxWithByte
; category enclosure + page nums + A >
	hlcoord 18, 5, wAttrmap
	ld bc, 2
	ld a, 0 | VRAM_BANK_1
	rst ByteFill
	hlcoord 18, 7, wAttrmap
	ld bc, 2
	ld a, 0 | VRAM_BANK_1
	jmp ByteFill

Pokedex_EvoPageAttrmap:
; main screen within border, vram 1
	hlcoord 1, 1, wAttrmap
	lb bc, 16, 19
	ld a, 0 | VRAM_BANK_1
	call FillBoxWithByte

; mon slot 1 types
	hlcoord 16, 2, wAttrmap
	lb bc, 2, 4
	ld a, 1 | VRAM_BANK_1
	call FillBoxWithByte
; mon slot 2 types
	hlcoord 16, 5, wAttrmap
	lb bc, 2, 4
	ld a, 2 | VRAM_BANK_1
	call FillBoxWithByte
; mon slot 3 types
	hlcoord 16, 8, wAttrmap
	lb bc, 3, 4
	ld a, 3 | VRAM_BANK_1
	call FillBoxWithByte
; mon slot 4 types
	hlcoord 16, 12, wAttrmap
	lb bc, 3, 4
	ld a, 4 | VRAM_BANK_1
	call FillBoxWithByte
; flip bottom row of sprite icon borders
	hlcoord 1, 4, wAttrmap
	ld bc, 4
	ld a, 0 | Y_FLIP | VRAM_BANK_1
	rst ByteFill

	hlcoord 1, 8, wAttrmap
	ld bc, 4
	rst ByteFill

	hlcoord 1, 12, wAttrmap
	ld bc, 4
	rst ByteFill
	
	hlcoord 1, 16, wAttrmap
	ld bc, 4
	jmp ByteFill

Pokedex_PicsPageAttrmap:
; black in the first color of palettes 6 and 7
	ld de, wBGPals1 palette 6
	call LoadSingleBlackPal
	ld de, wBGPals1 palette 7
	call LoadSingleBlackPal
; animated front pic + border
	hlcoord 0, 0, wAttrmap
	lb bc, 9, 9
	ld a, 0 | VRAM_BANK_1
	call FillBoxWithByte
; animated front pic
	hlcoord 1, 1, wAttrmap
	lb bc, 7, 7
	ld a, 1 | VRAM_BANK_1
	call FillBoxWithByte

; back pic border
	hlcoord 10, 0, wAttrmap
	lb bc, 9, 9
	ld a, 0 | VRAM_BANK_1
	call FillBoxWithByte
; ; back pic
	hlcoord 11, 2, wAttrmap
	lb bc, 6, 6
	ld a, 1 | VRAM_BANK_1
	call FillBoxWithByte

; sprite box border
	hlcoord 1, 13, wAttrmap
	lb bc, 4, 4
	ld a, 0 | VRAM_BANK_1
	call FillBoxWithByte

; page/up down arrows
	hlcoord 9, 0, wAttrmap
	ld [hl], 0 ; remove VRAM 1 bit
	hlcoord 18, 0, wAttrmap
	ld [hl], 0 ; remove VRAM 1 bit

; front/back pic bottom border fix
	hlcoord 0, 8, wAttrmap
	ld bc, SCREEN_WIDTH
	ld a, 0 | Y_FLIP | VRAM_BANK_1
	rst ByteFill
; lower right corner of front pic
	hlcoord 8, 8, wAttrmap
	ld a, 0 | Y_FLIP | X_FLIP | VRAM_BANK_1
	ld [hli], a
	ld [hl], 0 ; remove VRAM 1 bit
; lower right corner of back pic
	hlcoord 18, 8, wAttrmap
	ld a, 0 | X_FLIP | Y_FLIP | VRAM_BANK_1
	ld [hli], a
	ld [hl], 0 ; remove VRAM 1 bit

; upper right corner of front pic
	hlcoord 8, 0, wAttrmap
	ld [hl], 0 | X_FLIP | VRAM_BANK_1
; front pic right vertical side fix
	hlcoord 8, 1, wAttrmap
	lb bc, 7, 1
	ld a, 0 | X_FLIP | Y_FLIP | VRAM_BANK_1
	call FillBoxWithByte
; back pic right vertical side fix	
	hlcoord 18, 1, wAttrmap
	lb bc, 7, 1
	ld a, 0 | X_FLIP | VRAM_BANK_1
	call FillBoxWithByte	

; animated icon, upper right corner fix
	hlcoord 4, 13, wAttrmap
	ld [hl], 0 | X_FLIP | VRAM_BANK_1
; animated icon, lower right corner fix
	hlcoord 4, 16, wAttrmap
	ld [hl], 0 | X_FLIP | Y_FLIP | VRAM_BANK_1
; animated icon, lower left corner fix
	hlcoord 1, 16, wAttrmap
	ld [hl], 0 | Y_FLIP | VRAM_BANK_1		
; sprite border right side
	hlcoord 4, 14, wAttrmap
	ld [hl], 0 | X_FLIP | VRAM_BANK_1
	hlcoord 4, 15, wAttrmap
	ld [hl], 0 | X_FLIP | VRAM_BANK_1
; page bottom border row, bottom of sprite border	
	hlcoord 2, 16, wAttrmap
	ld bc, 2
	ld a, 0 | Y_FLIP | VRAM_BANK_1
	rst ByteFill
; the form label's ◀, a flipped ▶ (Pokedex_PlaceFormLabel)
	hlcoord 11, 14, wAttrmap
	ld [hl], 0 | X_FLIP
; > CRY, set VRAM	
	hlcoord 14, 17, wAttrmap
	lb bc, 1, 2
	ld a, 0 | VRAM_BANK_1
	jmp FillBoxWithByte

LoadMonBaseTypePal:
	; destination address of Palette and Slot is passed in 'de'
	; Type Index (already fixed/adjusted if a Special Type) is passed in 'c'
	ld hl, TypeIconPals ; pointer to the Type Colors designated in gfx\types_cats_status_pals.asm
	ld a, c ; c is the Type Index
	add a
	ld c, a
	ld b, 0
	add hl, bc
	ld bc, 2
	jmp FarCopyColorWRAM

LoadSingleBlackPal:
	; Destination address of the Palette and Slot is passed in 'de'
	ldh a, [rSVBK]
	push af
	ld a, BANK(wBGPals1)
	ldh [rSVBK], a
	xor a ; the color black is $0000
	ld [de], a
	inc de
	ld [de], a
	inc de

	pop af
	ldh [rSVBK], a
	ret

LoadDexTypePals:
	ldh a, [rSVBK]
	push af
	ld a, BANK(wBGPals1)
	ldh [rSVBK], a
	xor a
	ld [de], a
	inc de
	ld [de], a
	inc de
	pop af
	ldh [rSVBK], a	

	ld hl, TypeIconPals
	ld a, b
	add a
	push bc
	ld c, a
	ld b, 0
	add hl, bc
	ld bc, 2
	push de
	call FarCopyColorWRAM
	pop de

	ld hl, TypeIconPals
	pop bc
	ld a, c
	add a
	ld c, a
	ld b, 0
	add hl, bc
	inc de
	inc de
	ld bc, 2
	push de
	call FarCopyColorWRAM
	pop de
	inc de
	inc de

	ldh a, [rSVBK]
	push af
	ld a, BANK(wBGPals1)
	ldh [rSVBK], a
	xor a
	ld [de], a
	inc de
	ld [de], a
	inc de
	pop af
	ldh [rSVBK], a
	ret

INCLUDE "gfx/type_pals.asm"
