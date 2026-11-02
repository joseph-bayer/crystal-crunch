; the "???" row of gfx/pokedex/types_*.png and TypeIconPals
DEF DEX_TYPE_UNKNOWN EQU 18
; stands in for an unseen mon's types
DEF EVO_UNSEEN_TYPE EQU $ff

DisplayDexMonEvos:
	ld a, DEXENTRY_EVO
	ld [wPokedexEntryType], a
	call DisableSpriteUpdates
	farcall ClearSpriteAnims2
	farcall Pokedex_GetSelectedMon
	ld a, [wTempSpecies] ; mon we started with
	ld [wCurPartySpecies], a ; mon we started with
	ld [wCurSpecies], a ; mon we started with
	ld [wTempMonSpecies], a ; mon we started with
	ld [wPokedexScratch + 2], a ; mon we started with
	hlcoord 0, 4
	lb bc, SCREEN_HEIGHT - 4, SCREEN_WIDTH
	call ClearBox
	call EVO_Draw_border

	ld a, [wCurPartySpecies]
	farcall GetLowestEvolutionStage ; uses wCurPartySpecies
	ld a, [wCurPartySpecies]
	farcall GetLowestEvolutionStage ; uses wCurPartySpecies
	ld a, [wCurPartySpecies]
	ld [wTempSpecies], a
	ld [wCurSpecies], a
	ld [wTempMonSpecies], a
	
	
	ld de, .stage1_text
	hlcoord 6, 1
	rst PlaceString

; place the arrow to indicate the current mon we're looking at
	ld a, [wPokedexScratch + 2] ; mon we started with
	ld b, a
	ld a, [wCurPartySpecies] ; stage 1 mon
	cp b
	jr nz, .dont_arrow_stage1
	hlcoord 5, 2
	ld [hl], "→"
.dont_arrow_stage1	
	hlcoord 6, 2
	call EVO_sethlcoord
	call EVO_GetSeenMonName
	rst PlaceString
	ld a, -1
	ld [wPokedexPageFlags], a
	call EVO_DrawSpriteBox
	hlcoord 6, 2
	call EVO_sethlcoord
	call EVO_place_Mon_Types
	call EVO_CheckSeenMon
	jr z, .unseen_stage1
	call EVO_place_CaughtIcon
	call EVO_place_Mon_Icon
.unseen_stage1
	xor a
	ld [wPokedexPageFlags], a
	
	ld a, [wCurPartySpecies]
	call GetPokemonIndexFromID
	ld b, h
	ld c, l
	ld hl, EvosAttacksPointers
	ld a, BANK(EvosAttacksPointers)
	call LoadDoubleIndirectPointer
	ldh [hTemp], a ; BANK("Evolutions and Attacks Pointers")
	call GetFarByte ; Evolution method

	and a
	jr nz, .does_evo
	hlcoord 3, 6
	ld de, .doesnt_evo_text
	rst PlaceString
	hlcoord 5, 2
	ld [hl], " "
	ret ; no Evos
.does_evo
	push hl
	push af ; manner of evo
	ld a, [wPokedexScratch]
	and a
	jr z, .normal_line	
	; we're in a multi-page evo line
	pop hl ; dont need this value, just fix stack
	pop af ; dont need this value, just fix stack
	ld a, [wPokedexScratch] ; page num
	ld c, 4 ; we want the 4th Evo
	call SimpleMultiply
	call EVO_set_multi_page_ptr
	ld a, d
	push hl ; manner of evo byte
	push af ; manner of evo
	ld a, [wPokedexScratch + 1] ; stage 2
	and a
	jr z, .normal_line
	hlcoord 6, 4
	ld de, .stage3_text
	rst PlaceString
	ld b, 1 ; stage 3
	jr .cont
.normal_line
	hlcoord 6, 4
	ld de, .stage2_text
	rst PlaceString
	ld b, 0 ; stage 2
.cont	
	hlcoord 6, 5
	call EVO_sethlcoord
	pop af ; manner of evo
	pop hl ; manner of EVO byte
	inc hl ; hl points to manner byte +1  
	
	ld c, 0 ; count
; get num of stage 2 evos
; MAIN LOOP START
.main_loop
	push bc ; count and stage
	push af ; manner of evo
	push hl ; manner of EVO byte + 1
; get Species	
	call EVO_SkipExtraParamByte
	inc hl ; species byte
	push af
	push bc
	ldh a, [hTemp] ; BANK(EvosAttacksPointers)
	call GetFarWord ; species
	call GetPokemonIDFromIndex
	ld [wNamedObjectIndex], a ; species
	call EVO_GetSeenMonName
	call EVO_gethlcoord
	rst PlaceString

	ld a, [wPokedexScratch + 2]
	ld b, a
	ld a, [wNamedObjectIndex]
	cp b
	jr nz, .dont_print_arrow
	dec hl
	ld a, "→"
	ld [hli], a
.dont_print_arrow
	pop bc ; count and stage
	pop af ; manner of evo

	call EVO_DrawSpriteBox
	call EVO_place_Mon_Types
	push af
	call EVO_CheckSeenMon
	jr z, .unseen
	call EVO_place_CaughtIcon
	call EVO_place_Mon_Icon
.unseen
	pop af
	call EVO_inchlcoord

; done printing species
	pop hl ; manner of evo byte +1
	pop af ; manner of evo
	push hl ; manner of evo byte +1
	push af ; manner of evo
; print evo info
	call EVO_PrintMethod
; after the Evo manner specific prints, HL should be pointing to next EVO manner or 0
	pop af ; manner of evo
	pop hl ; manner of evo byte +1
; get Next EVO Manner or 0	
	call EVO_SkipExtraParamByte
	inc hl ; species byte 1
	inc hl ; species byte 2??
	inc hl ; points to next evo manner or 0
	ldh a, [hTemp] ; BANK(EvosAttacksPointers)
	call GetFarByte
	pop bc ; previous count
	inc c ; current count
	inc hl ; if there's a next EVO entry, points to Evo +1 now
	push af ; manner of next evo
	ld a, c
	ld [wPokedexPageFlags], a ; current page slot counter
	pop af ; manner of next evo 
	and a ; checks if evo left in stage
	jr z, .done_stage

	push af
	ld a, c ; ld a, [wPokedexPageFlags]
	cp 3
	jmp z, .exit_early_print_cont
	pop af
	jr .main_loop
.done_stage
	xor a
	cp b
	jr nz, .done ; we were in stage 3
.done_stage2
	ld a, c ; count of stage 2
	dec a
	jr nz, .done
	push bc ; count and stage
	ld a, [wCurPartySpecies]
	call GetPokemonIndexFromID
	ld b, h
	ld c, l
	ld hl, EvosAttacksPointers
	ld a, BANK(EvosAttacksPointers)
	call LoadDoubleIndirectPointer
	ldh [hTemp], a ; BANK("Evolutions and Attacks Pointers")
	call GetFarByte ; manner of stage 1 evo ; if zero, no evos
	call EVO_SkipExtraParamByte
	inc hl
	inc hl ; species byte
	ldh a, [hTemp] ; BANK("Evolutions and Attacks Pointers")
	call GetFarWord ; stage 2 species
	ld b, h
	ld c, l
	ld hl, EvosAttacksPointers
	ld a, BANK(EvosAttacksPointers)
	call LoadDoubleIndirectPointer
	ldh [hTemp], a ; BANK("Evolutions and Attacks Pointers")
	call GetFarByte ; manner of stage 1 evo ; if zero, no evos

	pop bc
	and a
	jr z, .done ; stage 2 mon doesnt evolve
	; stage 2 mon does evolve
	push hl ; manner of evo byte
	push af ; manner of evo
	; print Stage 3:
	call EVO_gethlcoord
	ld de, .stage3_text
	inc b
	push bc
	rst PlaceString
	call DelayFrame
	call EVO_inchlcoord
	pop bc
	pop af ; manner of evo
	pop hl ; manner of evo byte
	inc hl ; manner of evo byte +1
	jmp .main_loop
.done
	xor a
	ld [wPokedexEvoStage2], a
	ld [wPokedexEvoStage3], a
	ld a, [wPokedexScratch]
	and a
	jr nz, .done_multi
	xor a
	ld [wPokedexPageFlags], a
	ret
.done_multi
	ld a, b
	inc a
	ld [wPokedexPageFlags], a
	ld a, -1
	ld [wPokedexScratch + 1], a

	ld de, .cont_page_text
	hlcoord 12, 16
	jmp PlaceString
.stage1_text:
	db $6b, $6c, $6d, "1@"
.stage2_text:
	db $6b, $6c, $6d, "2@"
.stage3_text:
	db $6b, $6c, $6d, "3@"
.cont_page_text:
	db $63, $64, $65, $66, "@"
.doesnt_evo_text:
	db "DOES NOT EVOLVE@"
.exit_early_print_cont
	pop af
.exit_early_print_cont2
	ld a, b ; current stage, 0 = stage 2, 1 = stage 3
	ld [wPokedexScratch + 1], a

	ld de, .cont_page_text
	hlcoord 12, 16
	jmp PlaceString

EVO_sethlcoord:
	push af
	ld a, h
	ld [wPokedexEvoStage2], a
	ld a, l
	ld [wPokedexEvoStage3], a
	pop af
	ret
EVO_gethlcoord::
	push af
	ld a, [wPokedexEvoStage2]
	ld h, a
	ld a, [wPokedexEvoStage3]
	ld l, a
	pop af
	ret	
EVO_inchlcoord:
	push af
	push bc
	ld a, [wPokedexEvoStage2]
	ld h, a
	ld a, [wPokedexEvoStage3]
	ld l, a
	push hl
	ld bc, SCREEN_WIDTH
	add hl, bc
	ld a, h
	ld [wPokedexEvoStage2], a
	ld a, l
	ld [wPokedexEvoStage3], a
	pop hl
	pop bc
	pop af
	ret

EVO_PrintMethod:
; Print how the mon evolves; hl points to the evolution's parameter.
	cp EVOLVE_LEVEL
	jr z, EVO_level
	cp EVOLVE_ITEM
	jr z, EVO_item
	cp EVOLVE_TRADE
	jr z, EVO_trade
	cp EVOLVE_HAPPINESS
	jmp z, EVO_happiness
	cp EVOLVE_STAT
	jmp z, EVO_stats
	ret

EVO_SkipExtraParamByte:
; Every evolution's parameter is one byte but for those that take two: an item, or a level and
; a stat comparison.
	cp EVOLVE_LEVEL
	ret z
	cp EVOLVE_HAPPINESS
	ret z
	inc hl
	ret

EVO_GetItemParam:
; in: hl = an evolution's item parameter
; out: a = its item ID, or 0 for none (-1, a trade without an item)
	push hl
	ldh a, [hTemp]
	call GetFarWord
	ld a, h
	and l
	inc a
	jr z, .none
	ld a, h
	or l
	call nz, GetItemIDFromIndex
	pop hl
	ret

.none
	pop hl
	xor a
	ret

EVO_level:
	push hl ; pointing to lvl byte
	call EVO_gethlcoord
	ld [hl], "<DEX_LV_VRAM1>" ; lvl icon

	pop hl ; pointing to lvl byte
	ldh a, [hTemp] ; BANK("Evolutions and Attacks Pointers")
	call GetFarByte
	ld [wTextDecimalByte], a
	ld de, wTextDecimalByte
	call EVO_inchlcoord
	inc hl
	lb bc, PRINTNUM_LEFTALIGN | 1, 2
	call PrintNum ; lvl evolved at
	jr EVO_inchlcoord

EVO_item:
	call EVO_GetItemParam
	call EVO_inchlcoord
	push af ; item ID
	ld de, .item_text
	rst PlaceString ; item:

	pop af ; item index
	ld [wNamedObjectIndex], a
	call GetItemName

	call EVO_inchlcoord
	rst PlaceString
	jmp EVO_inchlcoord
.item_text:
	db "ITEM@"

EVO_trade:
	call EVO_GetItemParam
	push af ; item ID, or 0 for no item
	call EVO_gethlcoord
	ld de, .trade_text
	rst PlaceString

	pop af
	and a
	jr z, .done
	push af ; trade item ID
	
	call EVO_inchlcoord
	ld bc, 5
	add hl, bc
	ld de, .hold_text
	rst PlaceString
	
	pop af
	ld [wNamedObjectIndex], a
	call GetItemName
	call EVO_inchlcoord
	rst PlaceString
.done
	jmp EVO_inchlcoord
.trade_text:
	db "TRADE@"
.hold_text:
	db " ", "+","@"

EVO_happiness:
	push hl ; time of day byte
	pop hl ; time of day byte
	ldh a, [hTemp] ; BANK("Evolutions and Attacks Pointers")
	call GetFarByte
	
	ld de, .anytime_text
	cp TR_ANYTIME
	jr z, .done
	ld de, .sunup_text
	cp TR_MORNDAY
	jr z, .done
	ld de, .nite_text
.done
	call EVO_inchlcoord
	rst PlaceString
	jmp EVO_inchlcoord
.happiness_text:
	db $6e, "@"; "HAPPINESS@"
.anytime_text:
	db $6e, "@"
	; db "ANYTIME@"
.sunup_text:
	db $6e, $71, $72, "@"
	; db "MORN/DAY@"
.nite_text:
	db $6e, $73, "@"
	; db "NITE@"

EVO_stats:
	push hl ; level Needed byte
	call EVO_gethlcoord
	ld [hl], "<DEX_LV_VRAM1>" ; for vram1 side

	pop hl ; level needed byte
	ldh a, [hTemp] ; BANK("Evolutions and Attacks Pointers")
	call GetFarByte ; stats needed
	
	inc hl ; stats const needed byte
	push hl ; stats const needed byte
;print lvl
	ld [wTextDecimalByte], a
	ld de, wTextDecimalByte
	call EVO_inchlcoord
	lb bc, PRINTNUM_LEFTALIGN | 1, 2
	inc hl ;
	call PrintNum
	
	pop hl ; stats const needed byte
	ldh a, [hTemp] ; BANK("Evolutions and Attacks Pointers")
	call GetFarByte ; Stats Const, ATK >= DEF etc

	ld de, .atk_eq_def_text
	cp ATK_EQ_DEF
	jr z, .done
	ld de, .atk_gt_def_text
	cp ATK_GT_DEF
	jr z, .done
	ld de, .atk_lt_def_text
.done
	call EVO_inchlcoord
	rst PlaceString
	jmp EVO_inchlcoord

.atk_eq_def_text:
	db "ATK = DEF@"
.atk_gt_def_text:
	db "ATK > DEF@"
.atk_lt_def_text:
	db "ATK < DEF@"

EVO_place_Mon_Types:
	push af
	push bc
	push hl
	ld a, [wCurSpecies]
	push af
	ld a, [wTempSpecies]
	ld [wCurSpecies], a
	call GetBaseData
	call EVO_CheckSeenMon
	jr nz, .seen
	ld a, EVO_UNSEEN_TYPE
	ld [wBaseType1], a
	ld [wBaseType2], a
.seen

; set up the palette based on the current mon slot
	ld a, [wBaseType1]
	ld c, a
	call EVO_adjust_type_index
	ld d, c
	ld a, [wBaseType2]
	ld c, a ; type 2
	call EVO_adjust_type_index
	ld b, d
	call .determine_paladdr ; pal 1, 2, 3, or 4
	call LoadDexTypePals
	call SetDefaultBGPAndOBP
	call DelayFrame

	ld a, [wBaseType1]
	ld c, a
	call EVO_adjust_type_index
	ld a, c
	ld hl, TypeLightIconGFX
	ld bc, 4 * LEN_2BPP_TILE
	rst AddNTimes
	ld d, h
	ld e, l
	call .determine_mon_slot1
	ld a, b
	push af
	lb bc, BANK(TypeLightIconGFX), 4
	
	ld a, $1
	ldh [rVBK], a
	call Request2bpp

	call EVO_type_gethlcoord
	pop af
	ld [hli], a
	inc a
	ld [hli], a
	inc a
	ld [hli], a
	inc a
	ld [hl], a
	xor a
	ldh [rVBK], a
; 2nd Type
	ld a, [wBaseType1]
	ld b, a
	ld a, [wBaseType2]
	cp b
	jr z, .done
	ld c, a ; type 2
	call EVO_adjust_type_index

	ld a, c ; type 2
; load type 2 tiles
	ld hl, TypeDarkIconGFX ; DexTypeDarkIconGFX
	ld bc, 4 * LEN_2BPP_TILE
	rst AddNTimes
	ld d, h
	ld e, l
	call .determine_mon_slot2
	ld a, b
	push af

	ld a, $1
	ldh [rVBK], a
	lb bc, BANK(TypeDarkIconGFX), 4
	call Request2bpp
	
	call EVO_type2_gethlcoord
	pop af
	ld [hli], a
	inc a
	ld [hli], a
	inc a
	ld [hli], a
	inc a
	ld [hl], a
	xor a
	ldh [rVBK], a
.done
	pop af
	ld [wCurSpecies], a
	pop hl
	pop bc
	pop af
	ret
.determine_mon_slot1:
; out: b = the first tile of type 1's tiles in this slot, hl = its address in vTiles2
	ld b, $40
	jr .slot_tiles
.determine_mon_slot2:
	ld b, $44
.slot_tiles
	ld a, [wPokedexPageFlags]
	inc a ; -1 for stage 1, then slots 0-2
	add a
	add a
	add a ; 8 tiles a slot
	add b
	ld b, a
	swap a
	ld h, a
	and $f0
	ld l, a
	xor h
	assert LOW(vTiles2) == 0
	add HIGH(vTiles2)
	ld h, a
	ret

.determine_paladdr:
; out: de = this slot's palette, 1-4
	assert LOW(wBGPals1) + 5 palettes <= $100
	ld a, [wPokedexPageFlags]
	add 2
	add a
	add a
	add a ; 1 palettes
	add LOW(wBGPals1)
	ld e, a
	ld d, HIGH(wBGPals1)
	ret

EVO_type_gethlcoord:
	push bc
	push af
	call EVO_gethlcoord
	ld bc, 11
	add hl, bc

	dec hl
	pop af
	pop bc
	ret

EVO_type2_gethlcoord:
	push bc
	push af
	call EVO_gethlcoord
	ld bc, 11
	add hl, bc
	ld bc, SCREEN_WIDTH
	add hl, bc
	dec hl
	pop af
	pop bc
	ret

EVO_adjust_type_index:
; in: c = type, or EVO_UNSEEN_TYPE; out: c = its row in the type tiles
	ld a, c
	cp EVO_UNSEEN_TYPE
	jr z, .unseen
	predef_jump GetMonTypeIndex

.unseen
	ld c, DEX_TYPE_UNKNOWN
	ret

EVO_place_Mon_Icon:
	push af
	push bc
	push de
	push hl
	ld a, [wPokedexPageFlags]
	inc a
	ldh [hObjectStructIndex], a
	ld e, MONICON_POKEDEX
	farcall LoadMenuMonIcon
	
	pop hl
	pop de
	pop bc
	pop af
	ret

EVO_DrawSpriteBox:
	push hl
	push de
	push bc
	push af
; white rectangle/squares

	call EVO_gethlcoord
	ld a, [wPokedexPageFlags]
	cp -1
	jr z, .stage1
	dec a
	jr z, .slot3
	dec a
	jr z, .slot4
; slot 1
	hlcoord 1, 5
	jr .start
.slot3
	hlcoord 1, 9
	jr .start
.slot4
	hlcoord 1, 13
	jr .start
.stage1
	hlcoord 1, 1
.start
; top left corner
	ld [hl], $7a ; 3x1 corner, VRAM1
	push hl
	inc hl
; top border
	ld a, $79 ; VRAM1
	ld bc, 2
	push hl
	rst ByteFill
	pop hl
; top right corner
	inc hl
	inc hl	
	ld [hl], $7b ; VRAM1

	pop hl
	ld bc, SCREEN_WIDTH
	add hl, bc
	push hl
; left side	
	push hl
	lb bc, 2, 1
	ld a, $7c ; VRAM1
	call FillBoxWithByte
	pop hl
	inc hl
;white sprite box fill
	lb bc, 2, 2
	ld a, $62 ; $VRAM1
	push hl
	call FillBoxWithByte
	pop hl
; right side
	inc hl
	inc hl
	lb bc, 2, 1
	ld a, $7d ; VRAM1
	call FillBoxWithByte

; bottom left corner
	pop hl
	ld bc, SCREEN_WIDTH
	add hl, bc
	add hl, bc
	ld a, $7a ; VRAM1
	ld [hli], a
; bottom border
	ld a, $79 ; VRAM1
	ld bc, 2
	push hl
	rst ByteFill
	pop hl
; bottom right corner
	inc hl
	inc hl
	ld [hl], $7b ; VRAM1
.notslot4
	pop af
	pop bc
	pop de
	pop hl
	ret

EVO_set_multi_page_ptr:
	ld c, a
	ld a, [wPokedexScratch + 1]
	; if we're continuing the stage 3 mons,
	; need to dec a to account for stage 2 mon that wont be in evo list
	and a
	jr z, .start
	ld a, [wPokedexScratch]
	ld b, a
	ld a, c
	sub b
	ld c, a
.start
	push bc
	ld a, [wCurPartySpecies] ; stage 1 evo
	call GetPokemonIndexFromID
	ld b, h
	ld c, l
	ld hl, EvosAttacksPointers
	ld a, BANK(EvosAttacksPointers)
	call LoadDoubleIndirectPointer
	ldh [hTemp], a
	ld a, [wPokedexScratch + 1]
	and a 
	call nz, .get_stage2
.loop
	ldh a, [hTemp] ; BANK("Evolutions and Attacks Pointers")
	call GetFarByte ; manner of evo ; if zero, no evos
	ld d, a
	pop bc ; 4th entry, 8th entry, etc 
	dec c
	ld a, c
	and a
	ret z ; hl should be pointing at "espeon"'s manner of EVO byte ptr
	push bc
	; check for 0? shouldnt encounter 0
	ld a, d
	call EVO_SkipExtraParamByte
	inc hl
	inc hl ; species byte
	inc hl ; species byte 2
	inc hl ; next EVO manner byte
	jr .loop
.get_stage2:
	ldh a, [hTemp] ; BANK("Evolutions and Attacks Pointers")
	call GetFarByte ; manner of evo ; if zero, no evos
	; check for 0? shouldnt encounter 0
	call EVO_SkipExtraParamByte
	inc hl
	inc hl ; species byte 1
	inc hl ; species byte 2
	ldh a, [hTemp] ; BANK("Evolutions and Attacks Pointers")
	call GetFarWord ; stage 2 species
	ld b, h
	ld c, l
	ld hl, EvosAttacksPointers
	ld a, BANK(EvosAttacksPointers)
	call LoadDoubleIndirectPointer
	ldh [hTemp], a
	ret

EVO_place_CaughtIcon:
	push hl
	push de
	push bc
	push af
	ld a, [wTempSpecies]
	call GetPokemonIndexFromID
	ld d, h
	ld e, l
	call CheckCaughtMonIndex ; call CheckCaughtMon
	and a
	jr z, .done
	call EVO_gethlcoord
	ld a, [wPokedexPageFlags]
	cp -1
	jr z, .stage1
	dec a
	jr z, .slot3
	dec a
	jr z, .slot4
; slot 1
	hlcoord 5, 4 ; 5, 5
	jr .start
.slot3
	hlcoord 5, 8 ; 5, 9
	jr .start
.slot4
	hlcoord 5, 12 ; 5, 13
	jr .start
.stage1
	hlcoord 5, 1 ; 5, 2
.start
	ld [hl], $70 ; pokeball icon, VRAM1
.done
	pop af
	pop bc
	pop de
	pop hl
	ret

EVO_Draw_border:
; Request1bpp
; Load 1bpp at b:de to occupy c tiles of hl.
	xor a
	ldh [hBGMapMode], a
	farcall Pokedex_BlackOutBG
	
	ld a, 1
	ldh [rVBK], a

	lb bc, BANK(vTiles2), 16
	ld de, $8c00 
	ld hl, vTiles2
	call Request1bpp
	lb bc, BANK(vTiles2), 16
	ld de, $8c00 
	ld hl, vTiles2 tile $10 ; + $10
	call Request1bpp
	lb bc, BANK(vTiles2), 16
	ld de, $8c00 
	ld hl, vTiles2 tile $20 ; + $20
	call Request1bpp
	lb bc, BANK(vTiles2), 16
	ld de, $8c00 
	ld hl, vTiles2 tile $30 ; + $30
	call Request1bpp	
	farcall DrawDexEntryScreenRightEdge_Evo
	hlcoord 19, 1
	lb bc, SCREEN_HEIGHT - 2, 1
	ld a, $7f ; erase copied right border
	call FillBoxWithByte
	hlcoord 19, 0
	ld [hl], $34
	hlcoord 19, 17
	ld [hl], $39
	hlcoord 0, 0
	ld bc, SCREEN_WIDTH
	ld a, $34 ; top border
	rst ByteFill

	hlcoord 0, 17
	ld bc, SCREEN_WIDTH
	ld a, $39 ; bottom border
	rst ByteFill

	hlcoord 0, 0
	lb bc, SCREEN_HEIGHT, 1
	ld a, $36 ; left border
	call FillBoxWithByte

	hlcoord 0, 0
	ld [hl], $33 ; upper left corner
	hlcoord 0, 17 ; lower left corner
	ld [hl], $38
	xor a
	ldh [hBGMapMode], a

	ld b, SCGB_POKEDEX_EVO
	call GetSGBLayout
	
	; print b > back
	hlcoord 16, 16
	ld de, .back_page_text
	rst PlaceString

	; print up/down arrows
	hlcoord 19, 0
	ld [hl], $3f
	hlcoord 19, 17
	ld [hl], $40

	jmp WaitBGMap
.back_page_text:
	db $67, $68, $69, $6a, "@" ; VRAM1

EVO_CheckSeenMon:
; out: nz if the player has seen species [wTempSpecies]
	push bc
	push de
	push hl
	ld a, [wTempSpecies]
	call CheckSeenMon
	pop hl
	pop de
	pop bc
	and a
	ret

EVO_GetSeenMonName:
; out: de = the name of species [wNamedObjectIndex], or "?????" if the player hasn't seen it
	call GetPokemonName
	call EVO_CheckSeenMon
	ret nz
	ld de, .Unseen
	ret

.Unseen:
	db "?????@"
