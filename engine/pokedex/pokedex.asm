; Pokedex_RunJumptable.Jumptable indexes
	const_def
	const DEXSTATE_MAIN_SCR
	const DEXSTATE_UPDATE_MAIN_SCR
	const DEXSTATE_DEX_ENTRY_SCR
	const DEXSTATE_UPDATE_DEX_ENTRY_SCR
	const DEXSTATE_REINIT_DEX_ENTRY_SCR
	const DEXSTATE_SEARCH_SCR
	const DEXSTATE_UPDATE_SEARCH_SCR
	const DEXSTATE_OPTION_SCR
	const DEXSTATE_UPDATE_OPTION_SCR
	const DEXSTATE_SEARCH_RESULTS_SCR
	const DEXSTATE_UPDATE_SEARCH_RESULTS_SCR
	const DEXSTATE_UNOWN_MODE
	const DEXSTATE_UPDATE_UNOWN_MODE
	const DEXSTATE_COLOR_OPTION
	const DEXSTATE_UPDATE_COLOR_OPTION
	const DEXSTATE_EXIT

EXPORT DEF POKEDEX_SCX EQU 5

Pokedex:
	ldh a, [hWX]
	ld l, a
	ldh a, [hWY]
	ld h, a
	push hl
	ldh a, [hSCX]
	push af
	ld hl, wOptions
	ld a, [hl]
	push af
	set NO_TEXT_SCROLL, [hl]
	ld a, [wStateFlags]
	push af
	xor a
	ld [wStateFlags], a
	ldh a, [hInMenu]
	push af
	ld a, $1
	ldh [hInMenu], a

	xor a
	ldh [hMapAnims], a
	call InitPokedex
	call DelayFrame

.main
	call JoyTextDelay
	ld a, [wJumptableIndex]
	bit JUMPTABLE_EXIT_F, a
	jr nz, .exit
	call Pokedex_RunJumptable
	call DelayFrame
	jr .main

.exit
	ld de, SFX_READ_TEXT_2
	call PlaySFX
	call WaitSFX
	call ClearSprites
	ld a, [wCurDexMode]
	ld [wLastDexMode], a

	call Pokedex_ClearLockedIDs

	pop af
	ldh [hInMenu], a
	pop af
	ld [wStateFlags], a
	pop af
	ld [wOptions], a
	pop af
	ldh [hSCX], a
	pop hl
	ld a, l
	ldh [hWX], a
	ld a, h
	ldh [hWY], a
	ret

InitPokedex:
	call ClearBGPalettes
	call ClearSprites
	call ClearTilemap
	call Pokedex_LoadGFX

	ld hl, wPokedexDataStart
	ld bc, wPokedexDataEnd - wPokedexDataStart
	xor a
	rst ByteFill

	xor a
	ld [wJumptableIndex], a
	ld [wPrevDexEntryJumptableIndex], a
	ld [wPrevDexEntryBackup], a
	ld [wPrevDexEntryBackup + 1], a
	ld [wPokedexViewForm], a
	ld [wPokedexAltSeen], a

	call Pokedex_CheckUnlockedUnownMode

	ld a, [wLastDexMode]
	ld [wCurDexMode], a

	call Pokedex_OrderMonsByMode
	call Pokedex_InitCursorPosition
	call Pokedex_GetLandmark
	farcall DrawDexEntryScreenRightEdge
	call Pokedex_ResetBGMapMode
	; fallthrough

Pokedex_ClearLockedIDs:
	xor a
	ld l, LOCKED_MON_ID_DEX_SELECTED
	jmp LockPokemonID

Pokedex_CheckUnlockedUnownMode:
	ld a, [wStatusFlags]
	bit STATUSFLAGS_UNOWN_DEX_F, a
	jr nz, .unlocked

	xor a
	ld [wUnlockedUnownMode], a
	ret

.unlocked
	ld a, TRUE
	ld [wUnlockedUnownMode], a
	ret

Pokedex_InitCursorPosition:
	xor a
	ld [wDexListingScrollOffset], a
	ld [wDexListingScrollOffset + 1], a
	ld [wDexListingCursor], a
	ld hl, wPrevDexEntry + 1
	ld a, [hld]
	ld c, [hl]
	ld b, a
	if NUM_POKEMON <= $FF
		and a
		ret nz
	else
		cp HIGH(NUM_POKEMON)
		jr c, .check_zero
		ret nz
		if LOW(NUM_POKEMON) < $FF
			ld a, c
			cp LOW(NUM_POKEMON) + 1
			ret nc
		endc
		jr .go
	endc
.check_zero
	or c
	ret z

.go
	; ensure we have a list terminator
	ld hl, wDexListingEnd
	ld a, [hli]
	ld d, [hl]
	ld e, a
	push de
	sla e
	rl d
	ldh a, [rSVBK]
	push af
	ld a, BANK(wPokedexOrder)
	ldh [rSVBK], a
	ld hl, wPokedexOrder
	push hl
	add hl, de
	ld a, -1
	ld [hli], a
	ld [hl], a

	; and look for the entry in the list
	ld de, 2
	pop hl
	call IsInWordArray ;returns carry and pointer in hl if found
	pop de
	ld a, d
	ldh [rSVBK], a
	pop de
	ret nc
	ld bc, $10000 - wPokedexOrder ;ld bc, -wPokedexOrder -- see https://github.com/rednex/rgbds/issues/279
	add hl, bc
	srl h
	rr l

	; hl contains the index of wPrevDexEntry into wPokedexOrder, and de contains wDexListingEnd (therefore hl < de)
	; if de <= 7, then we only have one page; wDexListingScrollOffset must be zero and wDexListingCursor = hl (= l)
	ld a, d
	and a
	jr nz, .can_scroll
	ld a, e
	cp 8
	jr nc, .can_scroll
	ld a, l
	ld [wDexListingCursor], a
	ret

.can_scroll
	; otherwise, if hl <= (de - 7), then wDexListingScrollOffset = hl, wDexListingCursor = 0 (default)
	; else, wDexListingScrollOffset = de - 7, wDexListingCursor = hl - wDexListingScrollOffset
	ld a, e
	sub 7
	ld e, a
	ld [wDexListingScrollOffset], a
	jr nc, .no_carry
	dec d
.no_carry
	ld a, l
	sub e
	ld c, a
	ld a, h
	sbc d
	jr c, .not_last_page
	ld a, d
	ld [wDexListingScrollOffset + 1], a
	ld a, c
	ld [wDexListingCursor], a
	ret

.not_last_page
	ld a, l
	ld [wDexListingScrollOffset], a
	ld a, h
	ld [wDexListingScrollOffset + 1], a
	ret

Pokedex_GetLandmark:
	ld a, [wMapGroup]
	ld b, a
	ld a, [wMapNumber]
	ld c, a
	call GetWorldMapLocation

	cp LANDMARK_SPECIAL
	jr nz, .load

	ld a, [wBackupMapGroup]
	ld b, a
	ld a, [wBackupMapNumber]
	ld c, a
	call GetWorldMapLocation

.load
	ld [wDexCurLocation], a
	ret

Pokedex_RunJumptable:
	ld a, [wJumptableIndex]
	ld hl, .Jumptable
	call Pokedex_LoadPointer
	jp hl

.Jumptable:
; entries correspond to DEXSTATE_* constants
	dw Pokedex_InitMainScreen
	dw Pokedex_UpdateMainScreen
	dw Pokedex_InitDexEntryScreen
	dw Pokedex_UpdateDexEntryScreen
	dw Pokedex_ReinitDexEntryScreen
	dw Pokedex_InitSearchScreen
	dw Pokedex_UpdateSearchScreen
	dw Pokedex_InitOptionScreen
	dw Pokedex_UpdateOptionScreen
	dw Pokedex_InitSearchResultsScreen
	dw Pokedex_UpdateSearchResultsScreen
	dw Pokedex_InitUnownMode
	dw Pokedex_UpdateUnownMode
	dw Pokedex_InitColorOption
	dw Pokedex_UpdateColorOption
	dw Pokedex_Exit

Pokedex_IncrementDexPointer:
	ld hl, wJumptableIndex
	inc [hl]
	ret

Pokedex_Exit:
	ld hl, wJumptableIndex
	set JUMPTABLE_EXIT_F, [hl]
	ret

Pokedex_InitMainScreen:
	xor a
	ldh [hBGMapMode], a
	call ClearSprites
	xor a
	hlcoord 0, 0, wAttrmap
	ld bc, SCREEN_AREA
	rst ByteFill
	farcall DrawPokedexListWindow
	hlcoord 0, 17
	ld de, String_START_SEARCH
	call Pokedex_PlaceString
	ld a, 7
	ld [wDexListingHeight], a
	call Pokedex_PrintListing
	call Pokedex_SetBGMapMode_3ifDMG_4ifCGB
	call Pokedex_ResetBGMapMode
	call Pokedex_DrawMainScreenBG
	ld a, POKEDEX_SCX
	ldh [hSCX], a

	ld a, [wCurDexMode]
	cp DEXMODE_OLD
	ld a, $4a
	jr z, .okay
	ld a, $47
.okay
	ldh [hWX], a
	xor a
	ldh [hWY], a
	call WaitBGMap

	call Pokedex_ResetBGMapMode
	ld a, -1
	ld [wCurPartySpecies], a
	ld a, SCGB_POKEDEX
	call Pokedex_GetSGBLayout
	call Pokedex_UpdateCursorOAM
	farcall DrawPokedexListWindow
	hlcoord 0, 17
	ld de, String_START_SEARCH
	call Pokedex_PlaceString
	ld a, 7
	ld [wDexListingHeight], a
	call Pokedex_PrintListing
	jr Pokedex_IncrementDexPointer

Pokedex_UpdateMainScreen:
	ld hl, hJoyPressed
	ld a, [hl]
	and PAD_B
	jr nz, .b
	ld a, [hl]
	and PAD_A
	jr nz, .a
	ld a, [hl]
	and PAD_SELECT
	jr nz, .select
	ld a, [hl]
	and PAD_START
	jr nz, .start
	call Pokedex_ListingHandleDPadInput
	ret nc
	call Pokedex_UpdateCursorOAM
	xor a
	ldh [hBGMapMode], a
	call Pokedex_PrintListing
	call Pokedex_SetBGMapMode3
	jmp Pokedex_ResetBGMapMode

.a
	call Pokedex_GetSelectedMon
	call Pokedex_CheckSeen
	ret z
	ld a, DEXSTATE_DEX_ENTRY_SCR
	ld [wJumptableIndex], a
	ld a, DEXSTATE_MAIN_SCR
	ld [wPrevDexEntryJumptableIndex], a
	ret

.select
	call Pokedex_BlackOutBG
	ld a, DEXSTATE_OPTION_SCR
	ld [wJumptableIndex], a
	xor a
	ldh [hSCX], a
	ld a, $a7
	ldh [hWX], a
	jmp DelayFrame

.start
	call Pokedex_BlackOutBG
	ld a, DEXSTATE_SEARCH_SCR
	ld [wJumptableIndex], a
	xor a
	ldh [hSCX], a
	ld a, $a7
	ldh [hWX], a
	jmp DelayFrame

.b
	ld a, DEXSTATE_EXIT
	ld [wJumptableIndex], a
	ret

Pokedex_InitDexEntryScreen:
	call LowVolume
	xor a ; page 1
	ld [wPokedexStatus], a ; moves machines index
	ld [wPokedexEntryPageNum], a
	ld [wPokedexEntryType], a
	ld [wPokedexEvoStage2], a
	ld [wPokedexEvoStage3], a
	ldh [hBGMapMode], a
	call ClearSprites

	call Pokedex_GetSelectedMon
	ld [wCurPartySpecies], a
	farcall Pokedex_UpdateAltSeen
	ld a, SCGB_POKEDEX
	call Pokedex_GetSGBLayout

	call Pokedex_LoadCurrentFootprint
	call Pokedex_DrawDexEntryScreenBG
	call Pokedex_InitArrowCursor
	call Pokedex_GetSelectedMon
	ld a, l
	ld [wPrevDexEntry], a
	ld a, h
	ld [wPrevDexEntry + 1], a
	call Pokedex_DrawFootprint
	farcall DisplayDexEntry
	call WaitBGMap
	ld a, $a7
	ldh [hWX], a
	ld a, [wCurPartySpecies]
	call PlayMonCry2
	jmp Pokedex_IncrementDexPointer

Pokedex_UpdateDexEntryScreen:
	ld de, DexEntryScreen_ArrowCursorData
	call Pokedex_MoveArrowCursor
	ld hl, hJoyPressed
	ld a, [hl]
	and PAD_B
	jr nz, .return_to_prev_screen
	ld a, [hl]
	and PAD_A
	jr nz, .do_menu_action
	ld a, [hl] ;
	and PAD_START
	jmp nz, Area_Page_map ; .toCry ;
	ld a, [hl]
	and PAD_SELECT
	call nz, Pokedex_toggle_shininess_Entry	
	call Pokedex_NextOrPreviousDexEntry
	ret nc
	jmp Pokedex_IncrementDexPointer

.do_menu_action
	ld a, [wDexArrowCursorPosIndex]
	ld hl, DexEntryScreen_MenuActionJumptable
	call Pokedex_LoadPointer
	jp hl

.return_to_prev_screen
	ld a, [wLastVolume]
	and a
	jr z, .max_volume
	ld a, MAX_VOLUME
	ld [wLastVolume], a

.max_volume
	call MaxVolume
	ld a, [wPrevDexEntryJumptableIndex]
	ld [wJumptableIndex], a
	ret

Pokedex_Page:
	call Pokedex_GetSelectedMon
	ld a, l
	ld [wPrevDexEntry], a
	ld a, h
	ld [wPrevDexEntry + 1], a
	farjp DisplayDexEntry

Pokedex_toggle_shininess_Entry:
	call Pokedex_toggle_shininess1
; refresh palettes
	ld a, SCGB_POKEDEX
	call Pokedex_GetSGBLayout
	hlcoord 8, 1
	farcall Pokedex_PlaceShinyGlyph
	call Pokedex_toggle_shininess2
	jmp WaitSFX

Pokedex_toggle_shininess_Pics:
	call Pokedex_toggle_shininess1
; refresh palettes
	ld a, SCGB_POKEDEX_PICS
	call Pokedex_GetSGBLayout
	farcall Pokedex_PicsPlaceMarks
; recolor the icon at once: the layout reset it to the default colors
	xor a
	ldh [hObjectStructIndex], a
	farcall SetDexMonIconColor_SpritePage
	jr Pokedex_toggle_shininess2

Pokedex_toggle_shininess1:
; Step the shiny toggle: off, shiny, then the alternate shiny when this species' alternate has been
; seen, then off again.
	ld hl, wPokedexShinyToggle
	bit POKEDEX_SHINY_F, [hl]
	jr z, .shiny
	bit POKEDEX_ALT_SHINY_F, [hl]
	jr nz, .off
	ld a, [wPokedexAltSeen]
	and a
	jr z, .off
	set POKEDEX_ALT_SHINY_F, [hl]
	ret

.off
	res POKEDEX_SHINY_F, [hl]
	res POKEDEX_ALT_SHINY_F, [hl]
	ret

.shiny
	set POKEDEX_SHINY_F, [hl]
	res POKEDEX_ALT_SHINY_F, [hl]
	ret

Pokedex_toggle_shininess2:
; play sound based on setting
	ld de, SFX_BUMP
	ld a, [wPokedexShinyToggle]
	bit POKEDEX_SHINY_F, a
	jr z, .got_sound
	ld de, SFX_SHINE
.got_sound
	jmp PlaySFX

Pokedex_ReinitDexEntryScreen:
; Reinitialize the Pokédex entry screen after changing the selected mon.
	call Pokedex_BlackOutBG
	call Pokedex_DrawDexEntryScreenBG
	call Pokedex_LoadCurrentFootprint
	call Pokedex_GetSelectedMon
	farcall Pokedex_UpdateAltSeen
	ld a, l
	ld [wPrevDexEntry], a
	ld a, h
	ld [wPrevDexEntry + 1], a

	ld a, [wPokedexEntryType]
	cp DEXENTRY_PICS
	jr c, .not_area
	; find first area entry or none?
	xor a
	ld [wPokedexEntryPageNum], a
	ld a, DEXENTRY_PICS
	ld [wPokedexEntryType], a
	call Area_Page
	jr .cont
.not_area
	ld a, [wPokedexEntryType]
	cp DEXENTRY_PICS
	jr nz, .evo
	xor a
	ld [wPokedexEntryPageNum], a
	call Pics_Page
	jr .cont	
.evo
	ld a, [wPokedexEntryType]
	cp DEXENTRY_EVO
	jr nz, .lore
.evo2
	xor a
	ld [wPokedexEntryPageNum], a
	call Evos_Page
	jr .cont

.lore
	cp DEXENTRY_LORE
	jr nz, .basestats_check
	xor a
	ld [wPokedexEntryPageNum], a
	farcall DisplayDexEntry
	jr .cont
.basestats_check
	; so we can preserve the place for easy swithing when comparing base stats
	; since each mon will have the same number and layout of base stats
	ld a, [wPokedexEntryType]
	cp DEXENTRY_BASESTATS
	jr nz, .moves

	; dec page, since it's auto inc'd after printing
	ld a, [wPokedexEntryPageNum]
	dec a
	cp $ff ; were we on the max page? would have page num turned to 0, -1 is $ff
	jr nz, .basestats
	ld a, POKEDEX_STATSPAGE_MAX_PAGE_NUM - 1
.basestats
	ld [wPokedexEntryPageNum], a
	farcall DisplayDexMonStats
	jr .cont

; if not lore or base stats, it's moves
.moves
	; for moves, we can have different numbers of pages.
	; but we can at least keep them on the first move page of the category they were in
	; roll back category if page is 0
	; since it auto inc's category and xors page num after printing last page of move category
	ld a, [wPokedexEntryPageNum]
	and a
	jr nz, .moves_done
; .rollbackcategory
	ld hl, wPokedexEntryType
	dec [hl] ; make sure the order of the consts is right!!!
	ld a, [hl]
	cp DEXENTRY_BASESTATS
	jr nz, .moves_done
	; if a is now DEXENTRY_BASESTATS, we know we were in LVLUP moves category
	; meaning, the last actuall printed category was for the last const, DEXENTRY_MTS 
	ld a, DEXENTRY_MTS
	ld [wPokedexEntryType], a
.moves_done
	xor a
	ld [wPokedexEntryPageNum], a
	ld [wPokedexStatus], a ; moves machines index
	farcall DisplayDexMonMoves
.cont
	call Pokedex_DrawFootprint
	call Pokedex_LoadSelectedMonTiles
	hlcoord 8, 1
	farcall Pokedex_PlaceShinyGlyph
	call WaitBGMap
	call Pokedex_GetSelectedMon
	ld [wCurPartySpecies], a
	ld a, SCGB_POKEDEX
	call Pokedex_GetSGBLayout
	ld a, [wCurPartySpecies]
	call PlayMonCry2
	ld hl, wJumptableIndex
	dec [hl]
	ld a, [wLastDexMode]
	cp -2
	ret nz
	; fallthrough

Pokedex_Handle_Reinit_Evo:
	ld a, [wCurDexMode]
	ld [wLastDexMode], a
	jmp Pokedex_IncrementDexPointer

DexEntryScreen_ArrowCursorData:
	db PAD_RIGHT | PAD_LEFT, 6
	dwcoord 1, 17  ; INFO
	dwcoord 4, 17  ; STAT
	dwcoord 7, 17  ; MOVES
	dwcoord 11, 17 ; AREA
	dwcoord 14, 17 ; EVO
	dwcoord 17, 17 ; PICS

DexEntryScreen_MenuActionJumptable:
	dw Pokedex_Page
	dw BaseStat_Page
	dw Moves_Page
	dw Area_Page
	dw Evos_Page
	dw Pics_Page ; .SpriteAnim

Handle_Button_Banner:
	hlcoord 2, 0
	ld a, [hl]
	cp $41 ; first tile of PAD_START > MAP button banner
	ret nz
; overwrite the button banner
	ld a, $48 ; SELECT 1
	ld [hli], a
	inc a ; $49, SELECT 2
	ld [hli], a
	inc a ; $4a, SELECT 3
	ld [hli], a
	ld a, $61 ; SHINY 1
	ld [hli], a
	inc a ; $62, SHINY 2
	ld [hli], a
	ld [hl], $63 ; SHINY 2
	ret

BaseStat_Page:
	call Handle_Button_Banner
	call Pokedex_GetSelectedMon
	farjp DisplayDexMonStats

Moves_Page:
	call Handle_Button_Banner
	call Pokedex_GetSelectedMon
	farcall DisplayDexMonMoves
	ld a, [wCurPartySpecies]
	ld [wCurSpecies], a
	ld [wTempSpecies], a
	ld [wTempMonSpecies], a
	ret

Area_Page:
	ld a, [wPrevDexEntryJumptableIndex] ; same ram as wPokedexPageFlags
	push af
	call Pokedex_GetSelectedMon
	xor a
	ldh [hBGMapMode], a
	; print button banner based on the current category being displayed
	; only print map banner when you've pressed AREA first
; print map button banner, START > MAP
	; START > $41, $42, $43
	; > MAP $5e, $5f, $60
	hlcoord 2, 0
	ld a, [hl]
	cp $48 ; first tile of PAD_SELECT > SHINY
	jr nz, .button_done
	ld a, $41 ; START #1
	ld [hli], a
	inc a ; $42, START #2
	ld [hli], a
	inc a ; $43, START #3
	ld [hli], a
	ld a, $5e ; MAP #1
	ld [hli], a
	inc a ; $5f, MAP #2
	ld [hli], a
	ld [hl], $60 ; MAP #3
.button_done	
	farcall Pokedex_DetailedArea
	call WaitBGMap
	pop af
	ld [wPrevDexEntryJumptableIndex], a ; same ram as wPokedexPageFlags
	ret

Area_Page_map:
	ld a, [wPrevDexEntryJumptableIndex] ; same ram as wPokedexPageFlags
	push af
	call LoadTilemapToTempTilemap
	call Pokedex_BlackOutBG
	xor a
	ldh [hSCX], a
	call DelayFrame
	ld a, $7
	ldh [hWX], a
	ld a, $90
	ldh [hWY], a
	call Pokedex_GetSelectedMon
	ld a, [wDexCurLocation]
	ld e, a
	predef Pokedex_GetArea
	call Pokedex_BlackOutBG
	call DelayFrame
	xor a
	ldh [hBGMapMode], a
	ld a, $90
	ldh [hWY], a
	ld a, POKEDEX_SCX
	ldh [hSCX], a
	call DelayFrame
	call Pokedex_RedisplayDexEntry
	call Pokedex_LoadSelectedMonTiles
	call WaitBGMap
	call Pokedex_GetSelectedMon
	ld [wCurPartySpecies], a
	ld a, SCGB_POKEDEX
	call Pokedex_GetSGBLayout
	pop af
	ld [wPrevDexEntryJumptableIndex], a ; same ram as wPokedexPageFlags	
	ret

Evos_Page:
	ld a, [wPrevDexEntryJumptableIndex] ; same ram as wPokedexPageFlags
	ld b, a
	ld a, [wPokedexEntryType]
	ld c, a
	ld a, [wPokedexEntryPageNum]
	ld d, a
	push bc
	push de
	xor a
	; ldh [hSCX], a
	; ld hl, wPrevDexEntryBackup
	; ld a, [hli]
	; ld h, [hl]
	; ld l, a
	; push hl ; ///////////////
	; ld a, [wPrevDexEntryJumptableIndex]
	; push af
	; ld a, [wJumptableIndex]
	ld [wPokedexPageFlags], a
	ld a, [wLastDexMode]
	cp -1
	jr z, .handle_recursed
	cp -2
	jr z, .skip
	ld a, [wCurDexMode]
	ld [wLastDexMode], a
	jr .skip
.handle_recursed
	ld a, -2
	ld [wLastDexMode], a
.skip
	call LoadTilemapToTempTilemap
	call Pokedex_BlackOutBG
	xor a
	ldh [hBGMapMode], a
	ld [wPokedexScratch], a
	ld [wPokedexScratch + 1], a
	hlcoord 0, 0
	lb bc, SCREEN_HEIGHT, SCREEN_WIDTH
	call ClearBox
	call WaitBGMap
	xor a
	ldh [hBGMapMode], a
	farcall HDMATransferTilemapToWRAMBank3
	
	ld a, $1
	ldh [rVBK], a
	ld de, Pokedex_ExtraTiles ; tile 19
	ld hl, vTiles2 tile $62
	lb bc, BANK(Pokedex_ExtraTiles), 31 ; 30 ; 10
	call Request2bpp

	call Pokedex_LoadInversedFont
	xor a
	ldh [rVBK], a
	call DelayFrame
	
	ld a, SCGB_POKEDEX_EVO
	call Pokedex_GetSGBLayout
.nextpage_jump
	xor a
	ldh [hBGMapMode], a
	call ClearSprites
	call Pokedex_GetSelectedMon
	ld [wCurPartySpecies], a
	call GetPokemonIndexFromID
	push hl
	; farcall PrintDexEntry
	; pop af
	; ld [wJumptableIndex], a
	; pop af
	; ld [wPrevDexEntryJumptableIndex], a
	farcall DisplayDexMonEvos
	call WaitBGMap
	pop hl
	; ld a, l
	; ld [wPrevDexEntryBackup], a
	; ld a, h
	; ld [wPrevDexEntryBackup + 1], a
	; call ClearBGPalettes
	; call DisableLCD
	; call Pokedex_LoadInvertedFont
	call GetPokemonIDFromIndex

	ld [wCurPartySpecies], a 
	ld [wTempSpecies], a
	ld [wCurSpecies], a
	ld [wTempMonSpecies], a
	ld a, DEXENTRY_EVO
	ld [wPokedexEntryType], a
.evopage_loop
	farcall PlaySpriteAnimations
	call JoyTextDelay
	ld hl, hJoyPressed
	ld a, [hl]
	bit B_PAD_B, a
	jr nz, .evo_exit
	ld a, [wPokedexPageFlags] ; page/continue evo line flag
	and a
	jr z, .no_second_page
	ld hl, hJoyPressed
	ld a, [hl]
	bit B_PAD_A, a
	jmp nz, .right_dpad
	ld hl, hJoyLast
	ld a, [hl]
	and PAD_RIGHT
	jmp nz, .right_dpad
	ld a, [hl]
.no_second_page
	ld hl, hJoyLast
	ld a, [hl]
	and PAD_UP
	jr nz, .up_or_down_pressed
	ld a, [hl]
	and PAD_DOWN
	jr nz, .up_or_down_pressed
	call DelayFrame
	jr .evopage_loop
.up_or_down_pressed
	ld a, -1
	ld [wLastDexMode], a
	call Pokedex_NextOrPreviousDexEntry
	call Pokedex_GetSelectedMon
	ld [wCurPartySpecies], a
.evo_exit
	call Pokedex_BlackOutBG
	call DelayFrame
	xor a
	ldh [hBGMapMode], a
	call ClearSprites
	call Pokedex_LoadCurrentFootprint
	call Pokedex_DrawFootprint
	call Pokedex_LoadPageNums
	ld a, $90
	ldh [hWY], a
	ld a, POKEDEX_SCX
	ldh [hSCX], a
	farcall DrawDexEntryScreenRightEdge
	call DelayFrame
	call Pokedex_RedisplayDexEntry
	call Pokedex_LoadSelectedMonTiles
	call Pokedex_GetSelectedMon
	ld [wCurPartySpecies], a
	ld a, SCGB_POKEDEX
	call Pokedex_GetSGBLayout
	pop de
	pop bc
	ld a, b
	ld [wPrevDexEntryJumptableIndex], a ; same ram as wPokedexPageFlags
	ld a, c
	ld [wPokedexEntryType], a
	ld a, d
	ld [wPokedexEntryPageNum], a
	ld a, [wLastDexMode]
	cp -1
	call z, Evos_Page
	cp -2
	jmp z, Pokedex_ReinitDexEntryScreen

	hlcoord 8, 1
	ld a, [wPokedexShinyToggle]
	bit 0, a
	jr z, .not_shiny
	ld [hl], "<DEX_⁂>"
	jr .shiny_done
.not_shiny
	ld [hl], " "
.shiny_done	
	jmp WaitBGMap

.right_dpad
	ld a, [wPokedexScratch + 1]
	cp -1
	jr nz, .inc_evopage; .nextpage_jump
	xor a
	ld [wPokedexScratch], a
	jmp .nextpage_jump
.inc_evopage
	ld hl, wPokedexScratch
	inc [hl]
	jmp .nextpage_jump

; SpriteAnim:
Pics_Page:
; The plain form of a newly selected species.
	xor a
	ld [wPokedexViewForm], a
	ld a, [wCurPartySpecies]
	farcall Pokedex_UpdateAltSeen
	ld a, [wPrevDexEntryJumptableIndex] ; same ram as wPokedexPageFlags
	ld b, a
	ld a, [wPokedexEntryType]
	ld c, a
	ld a, [wPokedexEntryPageNum]
	ld d, a
	push bc
	push de
	ld a, [wLastDexMode]
	cp -1
	jr z, .handle_recursed
	cp -2
	jr z, .skip
	ld a, [wCurDexMode]
	ld [wLastDexMode], a
	jr .skip
.handle_recursed
	ld a, -2
	ld [wLastDexMode], a
.skip
	call LoadTilemapToTempTilemap ; the entry screen's tilemap, to go back to
	hlcoord 0, 0
	lb bc, SCREEN_HEIGHT, SCREEN_WIDTH
	call ClearBox	
	call Pokedex_BlackOutBG
	farcall HDMATransferTilemapToWRAMBank3	
	call ClearSprites
	call DisableSpriteUpdates
	farcall ClearSpriteAnims2
	xor a
	ldh [hBGMapMode], a
	ldh [hSCX], a
	ld a, $7
	ldh [hWX], a
	ld a, $90
	ldh [hWY], a

	ld a, $1
	ldh [rVBK], a ; Switch to VRAM 1

; Load skinny side color border
	ld de, Pokedex_ExtraTiles tile 37
	ld hl, vTiles0 tile DEXPICS_SKINNY_TILE
	lb bc, BANK(Pokedex_ExtraTiles), 1
	call Request2bpp
	ld de, Pokedex_ExtraTiles tile 19
	ld hl, vTiles0 tile DEXPICS_CRY_TILE
	lb bc, BANK(Pokedex_ExtraTiles), 2
	call Request2bpp	

; 1x1 inner corner and x1 white + x1 black vertical + horiz line
	ld de, Pokedex_ExtraTiles tile 21
	ld hl, vTiles0 tile DEXPICS_FRAME_TILE
	lb bc, BANK(Pokedex_ExtraTiles), 8
	call Request2bpp
	
	xor a
	ldh [rVBK], a

	ld a, [wCurPartySpecies]
	ld [wCurSpecies], a
	ld [wTempSpecies], a
	ld [wTempMonSpecies], a
	call GetBaseData
	call Pokedex_GetSelectedMon

	hlcoord 0, 0
	lb bc, SCREEN_HEIGHT, SCREEN_WIDTH
	call ClearBox	

	hlcoord 6, 11 ; 2, 11 ; 1, 9
	call GetPokemonName
	rst PlaceString	
	hlcoord 6, 14
	farcall Pokedex_PlaceFormLabel
	farcall Pokedex_PlaceBackPic
	xor a
	ld [wPokedexPageFlags], a
	farcall Pokedex_PlaceAnimatedFrontpic
	farcall Dex_Pics_DrawBorder
	call WaitBGMap
; the page's colors only once it's drawn, so it stays black while the pics load
	ld a, SCGB_POKEDEX_PICS
	call Pokedex_GetSGBLayout
	farcall Pokedex_place_Mon_Icon
.spritepage_loop
	farcall PlaySpriteAnimations
	call JoyTextDelay
	ld hl, hJoyPressed
	ld a, [hl]
	and PAD_SELECT ; toggle shininess
	jmp nz, .toggle_shininess
	ld a, [hl]
	and PAD_START
	call nz, .toCry
	ld a, [hl]
	bit B_PAD_B, a
	jr nz, .sprite_b
	ldh a, [hJoyPressed]
	and PAD_LEFT | PAD_RIGHT
	jr nz, .left_or_right
	ld hl, hJoyLast
	ld a, [hl]
	and PAD_UP
	jr nz, .up_or_down_pressed
	ld a, [hl]
	and PAD_DOWN
	jr nz, .up_or_down_pressed
	farcall Pokedex_PicsPageFrame
	jr .spritepage_loop
.up_or_down_pressed
	ld a, -1
	ld [wLastDexMode], a
	call Pokedex_NextOrPreviousDexEntry
	call Pokedex_GetSelectedMon
	ld [wCurPartySpecies], a
	pop de
	pop bc
	ld a, b
	ld [wPrevDexEntryJumptableIndex], a ; same ram as wPokedexPageFlags
	ld a, c
	ld [wPokedexEntryType], a
	ld a, d
	ld [wPokedexEntryPageNum], a
	jmp Pics_Page
.left_or_right
	farcall Pokedex_StepViewForm
	call c, Pokedex_PicsSwapForm
	jr .spritepage_loop
.no_other_form
	farcall Pokedex_PicsPageFrame
	jr .spritepage_loop
.sprite_b
	xor a
	ld [wPokedexViewForm], a ; the entry screen shows the plain form
	call Pokedex_BlackOutBG
	call Pokedex_LoadInversedFont ; the back pic and the PICS page's tiles went over it
	call DelayFrame
	xor a
	ldh [hBGMapMode], a
	call ClearSprites
	call Pokedex_LoadCurrentFootprint
	call Pokedex_DrawFootprint
	call Pokedex_LoadPageNums
	ld a, $90
	ldh [hWY], a
	ld a, POKEDEX_SCX
	ldh [hSCX], a
	farcall DrawDexEntryScreenRightEdge
	call DelayFrame
	call Pokedex_RedisplayDexEntry
	call Pokedex_LoadSelectedMonTiles
	call Pokedex_GetSelectedMon
	ld [wCurPartySpecies], a
	ld a, SCGB_POKEDEX
	call Pokedex_GetSGBLayout
	pop de
	pop bc
	ld a, b
	ld [wPrevDexEntryJumptableIndex], a ; same ram as wPokedexPageFlags
	ld a, c
	ld [wPokedexEntryType], a
	ld a, d
	ld [wPokedexEntryPageNum], a
	ld a, [wLastDexMode]
	cp -2
	jmp z, Pokedex_ReinitDexEntryScreen
	hlcoord 8, 1
	farcall Pokedex_PlaceShinyGlyph
	jmp WaitBGMap
.toggle_shininess:
	xor a
	ldh [hBGMapMode], a
	call Pokedex_toggle_shininess_Pics
	farcall HDMATransferTilemapToWRAMBank3 ; the marks, in a frame, so the animation hardly pauses
	jmp .spritepage_loop

.toCry:
; keeps hl, which the loop reads the buttons through
	push hl
	call Pokedex_GetSelectedMon
	ld a, [wTempSpecies]
	call GetCryIndex
	ld e, c
	ld d, b
	call PlayCry
	pop hl
	ret

Pokedex_PicsSwapForm:
; Show the form in wPokedexViewForm in place: the pics, icon, colors, label and marks change, and the
; rest of the page stays.
	xor a
	ldh [hBGMapMode], a
	call ClearSprites
	farcall ClearSpriteAnims2
; blank boxes where the pics go while their tiles reload
	hlcoord 1, 1
	lb bc, 7, 7
	call ClearBox
	hlcoord 11, 2
	lb bc, 6, 6
	call ClearBox
	hlcoord 6, 14
	lb bc, 1, 13
	call ClearBox
	farcall HDMATransferTilemapToWRAMBank3
	hlcoord 6, 14
	farcall Pokedex_PlaceFormLabel
	farcall Pokedex_PlaceBackPic
	xor a
	ld [wPokedexPageFlags], a
	farcall Pokedex_PlaceAnimatedFrontpic
	farcall Pokedex_PicsPlaceMarks
; the new colors while the boxes are still blank, then the pics
	ld a, SCGB_POKEDEX_PICS
	call Pokedex_GetSGBLayout
	call WaitBGMap
	farjp Pokedex_place_Mon_Icon

Pokedex_RedisplayDexEntry:
	call Pokedex_DrawDexEntryScreenBG
	call Pokedex_GetSelectedMon
	call SafeLoadTempTilemapToTilemap
	jmp Pokedex_DrawFootprint

Pokedex_InitOptionScreen:
	xor a
	ldh [hBGMapMode], a
	call ClearSprites
	call Pokedex_DrawOptionScreenBG
	call Pokedex_InitArrowCursor
	ld [wDexArrowCursorPosIndex], a
	call Pokedex_DisplayModeDescription
	call WaitBGMap
	ld a, SCGB_POKEDEX_SEARCH_OPTION
	call Pokedex_GetSGBLayout
	jmp Pokedex_IncrementDexPointer

Pokedex_UpdateOptionScreen:
	ld a, [wUnlockedUnownMode]
	and a
	jr nz, .okay
	ld de, .NoUnownModeArrowCursorData
	jr .okay2
.okay
	ld de, .ArrowCursorData
.okay2
	call Pokedex_MoveArrowCursor
	call c, Pokedex_DisplayModeDescription
	ld hl, hJoyPressed
	ld a, [hl]
	and PAD_SELECT | PAD_B
	jr nz, .return_to_main_screen
	vc_hook Forbid_printing_Pokedex
	ld a, [hl]
	and PAD_A
	ret z
	ld a, [wDexArrowCursorPosIndex]
	ld hl, .MenuActionJumptable
	call Pokedex_LoadPointer
	jp hl

.return_to_main_screen
	call Pokedex_BlackOutBG
	ld a, DEXSTATE_MAIN_SCR
	ld [wJumptableIndex], a
	ret

.NoUnownModeArrowCursorData:
	db PAD_UP | PAD_DOWN, 5
	dwcoord 2,  3 ; COLOR
	dwcoord 2,  4 ; ABC
	dwcoord 2,  5 ; NEW
	dwcoord 2,  6 ; OLD
	dwcoord 2,  7 ; PRINT

.ArrowCursorData:
	db PAD_UP | PAD_DOWN, 6
	dwcoord 2,  3 ; COLOR
	dwcoord 2,  4 ; ABC
	dwcoord 2,  5 ; NEW
	dwcoord 2,  6 ; OLD
	dwcoord 2,  7 ; PRINT
	dwcoord 2,  8 ; UNOWN

.MenuActionJumptable:
	dw .MenuAction_ColorOption
	dw .MenuAction_ABCMode
	dw .MenuAction_NewMode
	dw .MenuAction_OldMode
	dw .MenuAction_Print
	dw .MenuAction_UnownMode

.MenuAction_NewMode:
	ld b, DEXMODE_NEW
	jr .ChangeMode

.MenuAction_OldMode:
	ld b, DEXMODE_OLD
	jr .ChangeMode

.MenuAction_ABCMode:
	ld b, DEXMODE_ABC

.ChangeMode:
	ld a, [wCurDexMode]
	cp b
	jr z, .skip_changing_mode ; Skip if new mode is same as current.

	ld a, b
	ld [wCurDexMode], a
	call Pokedex_OrderMonsByMode
	call Pokedex_DisplayChangingModesMessage
	call Pokedex_InitCursorPosition

.skip_changing_mode
	call Pokedex_BlackOutBG
	ld a, DEXSTATE_MAIN_SCR
	ld [wJumptableIndex], a
	ret

.MenuAction_ColorOption
	call Pokedex_BlackOutBG
	ld a, DEXSTATE_COLOR_OPTION
	ld [wJumptableIndex], a
	ret

.MenuAction_Print:
; Print the entry of the species under the list's cursor, once seen.
	call Pokedex_GetSelectedMon
	call Pokedex_CheckSeen
	jr nz, .print
	ld de, SFX_WRONG
	jmp PlaySFX

.print
	call Pokedex_ApplyPrintPals
	xor a
	ldh [hSCX], a
	ld a, [wJumptableIndex]
	push af
	farcall PrintDexEntry
	pop af
	ld [wJumptableIndex], a
	call ClearBGPalettes
	call DisableLCD
	call Pokedex_LoadInvertedFont
	call EnableLCD
	ld a, POKEDEX_SCX
	ldh [hSCX], a
	call Pokedex_ApplyUsualPals
	ld a, DEXSTATE_OPTION_SCR
	ld [wJumptableIndex], a
	ret

.MenuAction_UnownMode:
	call Pokedex_BlackOutBG
	ld a, DEXSTATE_UNOWN_MODE
	ld [wJumptableIndex], a
	ret

Pokedex_InitSearchScreen:
	xor a
	ldh [hBGMapMode], a
	call ClearSprites
	call Pokedex_LoadGFX ; restoring our precious Slowpoke Sprite
	call Pokedex_DrawSearchScreenBG
	call Pokedex_InitArrowCursor
	ld a, NORMAL + 1
	ld [wDexSearchMonType1], a
	xor a
	ld [wDexSearchMonType2], a
	call Pokedex_PlaceSearchScreenTypeStrings
	xor a
	ld [wDexSearchSlowpokeFrame], a
	farcall DoDexSearchSlowpokeFrame
	call WaitBGMap
	ld a, SCGB_POKEDEX_SEARCH_OPTION
	call Pokedex_GetSGBLayout
	jmp Pokedex_IncrementDexPointer

Pokedex_UpdateSearchScreen:
	ld de, .ArrowCursorData
	call Pokedex_MoveArrowCursor
	call Pokedex_UpdateSearchMonType
	call c, Pokedex_PlaceSearchScreenTypeStrings
	ld hl, hJoyPressed
	ld a, [hl]
	and PAD_START | PAD_B
	jr nz, .cancel
	ld a, [hl]
	and PAD_A
	ret z
	ld a, [wDexArrowCursorPosIndex]
	ld hl, .MenuActionJumptable
	call Pokedex_LoadPointer
	jp hl

.cancel
	call Pokedex_BlackOutBG
	ld a, DEXSTATE_MAIN_SCR
	ld [wJumptableIndex], a
	ret

.ArrowCursorData:
	db PAD_UP | PAD_DOWN, 4
	dwcoord 2, 4  ; TYPE 1
	dwcoord 2, 6  ; TYPE 2
	dwcoord 2, 13 ; BEGIN SEARCH
	dwcoord 2, 15 ; CANCEL

.MenuActionJumptable:
	dw .MenuAction_MonSearchType
	dw .MenuAction_MonSearchType
	dw .MenuAction_BeginSearch
	dw .MenuAction_Cancel

.MenuAction_MonSearchType:
	call Pokedex_NextSearchMonType
	jmp Pokedex_PlaceSearchScreenTypeStrings

.MenuAction_BeginSearch:
	call Pokedex_SearchForMons
	farcall AnimateDexSearchSlowpoke
	ld hl, wDexSearchResultCount
	ld a, [hli]
	or [hl]
	jr nz, .show_search_results

; No mon with matching types was found.
	call Pokedex_OrderMonsByMode
	call Pokedex_DisplayTypeNotFoundMessage
	xor a
	ldh [hBGMapMode], a
	call Pokedex_DrawSearchScreenBG
	call Pokedex_InitArrowCursor
	call Pokedex_PlaceSearchScreenTypeStrings
	jmp WaitBGMap

.show_search_results
	ld a, [wDexSearchResultCount]
	ld [wDexListingEnd], a
	ld a, [wDexSearchResultCount + 1]
	ld [wDexListingEnd + 1], a
	ld a, [wDexListingScrollOffset]
	ld [wDexListingScrollOffsetBackup], a
	ld a, [wDexListingScrollOffset + 1]
	ld [wDexListingScrollOffsetBackup + 1], a
	ld a, [wDexListingCursor]
	ld [wDexListingCursorBackup], a
	ld a, [wPrevDexEntry]
	ld [wPrevDexEntryBackup], a
	ld a, [wPrevDexEntry + 1]
	ld [wPrevDexEntryBackup + 1], a
	xor a
	ld [wDexListingScrollOffset], a
	ld [wDexListingScrollOffset + 1], a
	ld [wDexListingCursor], a
	call Pokedex_BlackOutBG
	ld a, DEXSTATE_SEARCH_RESULTS_SCR
	ld [wJumptableIndex], a
	ret

.MenuAction_Cancel:
	call Pokedex_BlackOutBG
	ld a, DEXSTATE_MAIN_SCR
	ld [wJumptableIndex], a
	ret

Pokedex_InitSearchResultsScreen:
	xor a
	ldh [hBGMapMode], a
	xor a
	hlcoord 0, 0, wAttrmap
	ld bc, SCREEN_AREA
	rst ByteFill
	call Pokedex_SetBGMapMode4
	call Pokedex_ResetBGMapMode
	farcall DrawPokedexSearchResultsWindow
	call Pokedex_PlaceSearchResultsTypeStrings
	ld a, 4
	ld [wDexListingHeight], a
	call Pokedex_PrintListing
	call Pokedex_SetBGMapMode3
	call Pokedex_ResetBGMapMode
	call Pokedex_DrawSearchResultsScreenBG
	ld a, POKEDEX_SCX
	ldh [hSCX], a
	ld a, $4a
	ldh [hWX], a
	xor a
	ldh [hWY], a
	call WaitBGMap
	call Pokedex_ResetBGMapMode
	farcall DrawPokedexSearchResultsWindow
	call Pokedex_PlaceSearchResultsTypeStrings
	call Pokedex_UpdateSearchResultsCursorOAM
	ld a, -1
	ld [wCurPartySpecies], a
	ld a, SCGB_POKEDEX
	call Pokedex_GetSGBLayout
	jmp Pokedex_IncrementDexPointer

Pokedex_UpdateSearchResultsScreen:
	ld hl, hJoyPressed
	ld a, [hl]
	and PAD_B
	jr nz, .return_to_search_screen
	ld a, [hl]
	and PAD_A
	jr nz, .go_to_dex_entry
	call Pokedex_ListingHandleDPadInput
	ret nc
	call Pokedex_UpdateSearchResultsCursorOAM
	xor a
	ldh [hBGMapMode], a
	call Pokedex_PrintListing
	call Pokedex_SetBGMapMode3
	jmp Pokedex_ResetBGMapMode

.go_to_dex_entry
	call Pokedex_GetSelectedMon
	call Pokedex_CheckSeen
	ret z
	ld a, DEXSTATE_DEX_ENTRY_SCR
	ld [wJumptableIndex], a
	ld a, DEXSTATE_SEARCH_RESULTS_SCR
	ld [wPrevDexEntryJumptableIndex], a
	ret

.return_to_search_screen
	ld a, [wDexListingScrollOffsetBackup]
	ld [wDexListingScrollOffset], a
	ld a, [wDexListingScrollOffsetBackup + 1]
	ld [wDexListingScrollOffset + 1], a
	ld a, [wDexListingCursorBackup]
	ld [wDexListingCursor], a
	ld a, [wPrevDexEntryBackup]
	ld [wPrevDexEntry], a
	ld a, [wPrevDexEntryBackup + 1]
	ld [wPrevDexEntry + 1], a
	call Pokedex_BlackOutBG
	call ClearSprites
	call Pokedex_OrderMonsByMode
	ld a, DEXSTATE_SEARCH_SCR
	ld [wJumptableIndex], a
	xor a
	ldh [hSCX], a
	ld a, $a7
	ldh [hWX], a
	ret

Pokedex_InitUnownMode:
	call Pokedex_LoadUnownFont
	call Pokedex_DrawUnownModeBG
	xor a
	ld [wDexCurUnownIndex], a
	call Pokedex_LoadUnownFrontpicTiles
	call Pokedex_UnownModePlaceCursor
	farcall PrintUnownWord
	call WaitBGMap
	ld a, SCGB_POKEDEX_UNOWN_MODE
	call Pokedex_GetSGBLayout
	jmp Pokedex_IncrementDexPointer

Pokedex_UpdateUnownMode:
	ld hl, hJoyPressed
	ld a, [hl]
	and PAD_A | PAD_B
	jr z, Pokedex_UnownModeHandleDPadInput
	call Pokedex_BlackOutBG
	ld a, DEXSTATE_OPTION_SCR
	ld [wJumptableIndex], a
	call DelayFrame
	call Pokedex_CheckSGB
	jr nz, .decompress
	farjp LoadSGBPokedexGFX2

.decompress
	ld hl, PokedexLZ
	ld de, vTiles2 tile $31
	lb bc, BANK(PokedexLZ), 58
	jmp DecompressRequest2bpp

Pokedex_UnownModeHandleDPadInput:
	ld hl, hJoyLast
	ld a, [hl]
	and PAD_RIGHT
	jr nz, .right
	ld a, [hl]
	and PAD_LEFT
	jr nz, .left
	ret

.right
	ld a, [wDexUnownCount]
	ld e, a
	ld hl, wDexCurUnownIndex
	ld a, [hl]
	inc a
	cp e
	ret nc
	ld a, [hl]
	inc [hl]
	jr .update

.left
	ld hl, wDexCurUnownIndex
	ld a, [hl]
	and a
	ret z
	ld a, [hl]
	dec [hl]

.update
	push af
	xor a
	ldh [hBGMapMode], a
	pop af
	call Pokedex_UnownModeEraseCursor
	call Pokedex_LoadUnownFrontpicTiles
	call Pokedex_UnownModePlaceCursor
	farcall PrintUnownWord
	ld a, $1
	ldh [hBGMapMode], a
	call DelayFrame
	jmp DelayFrame

Pokedex_UnownModeEraseCursor:
	ld c, " "
	jr Pokedex_UnownModeUpdateCursorGfx

Pokedex_UnownModePlaceCursor:
	ld a, [wDexCurUnownIndex]
	ld c, FIRST_UNOWN_CHAR + NUM_UNOWN ; diamond cursor

Pokedex_UnownModeUpdateCursorGfx:
	ld e, a
	ld d, 0
	ld hl, UnownModeLetterAndCursorCoords + 2
rept 4
	add hl, de
endr
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld [hl], c
	ret

Pokedex_LoadListingScrollParams:
	; d = min(wDexListingEnd, wDexListingHeight); e = remaining scroll distance (cap at $FF)
	ld hl, wDexListingScrollOffset
	ld a, [hli]
	cpl
	ld e, a
	ld a, [hli]
	cpl
	ld d, a
	inc hl
	; hl = wDexListingEnd
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, de
	inc hl
	ld a, [wDexListingHeight]
	ld d, a
	ld a, l
	sub d
	ld e, a
	ld a, h
	jr nc, .check_overflow
	sub 1 ; no-optimize a++|a--
	jr c, .underflow
.check_overflow
	and a
	ret z
	ld e, $FF
	ret

.underflow
	ld e, h ; h = 0 here
	ld a, [wDexListingEnd]
	ld d, a
	ret

Pokedex_NextOrPreviousDexEntry:
	ld a, [wDexListingCursor]
	ld [wBackupDexListingCursor], a
	ld a, [wDexListingScrollOffset]
	ld [wBackupDexListingPage], a
	ld a, [wDexListingScrollOffset + 1]
	ld [wBackupDexListingPage + 1], a
	ld hl, hJoyLast
	ld a, [hl]
	and PAD_UP
	jr nz, .up
	ld a, [hl]
	and PAD_DOWN
	ret z

; down
.next
	call Pokedex_LoadListingScrollParams
	call Pokedex_ListingMoveCursorDown
	jr nc, .nope
	call Pokedex_GetSelectedMon
	call Pokedex_CheckSeen
	jr z, .next
	scf
	ret

.check
	call Pokedex_GetSelectedMon
	call Pokedex_CheckSeen
	scf
	ret nz
.up
	call Pokedex_ListingMoveCursorUp
	jr c, .check
.nope
	ld a, [wBackupDexListingCursor]
	ld [wDexListingCursor], a
	ld a, [wBackupDexListingPage]
	ld [wDexListingScrollOffset], a
	ld a, [wBackupDexListingPage + 1]
	ld [wDexListingScrollOffset + 1], a
	and a
	ret

Pokedex_ListingHandleDPadInput:
; Handles D-pad input for a list of Pokémon.
	call Pokedex_LoadListingScrollParams
	ld hl, hJoyLast
	bit B_PAD_UP, [hl]
	jr nz, Pokedex_ListingMoveCursorUp
	bit B_PAD_DOWN, [hl]
	jr nz, Pokedex_ListingMoveCursorDown
	ld a, [wDexListingHeight]
	xor d ; compares for equality (if zero) and clears carry
	ret nz
	bit B_PAD_LEFT, [hl]
	jr nz, Pokedex_ListingMoveUpOnePage
	bit B_PAD_RIGHT, [hl]
	jr nz, Pokedex_ListingMoveDownOnePage
	ret

Pokedex_ListingMoveCursorUp:
	ld hl, wDexListingCursor
	ld a, [hl]
	and a
	jr z, .try_scrolling
	dec [hl]
.done
	scf
	ret

.try_scrolling
	ld hl, wDexListingScrollOffset + 1
	ld a, [hld]
	and a
	ld a, [hl]
	jr nz, .go
	and a
	ret z
.go
	sub 1 ; no-optimize a++|a--
	ld [hli], a
	jr nc, .done
	dec [hl]
	ret

Pokedex_ListingMoveCursorDown:
	ld hl, wDexListingCursor
	inc [hl]
	ld a, [hl]
	cp d
	ret c
	dec [hl]
	ld a, e
	and a
	ret z
	ld hl, wDexListingScrollOffset
	inc [hl]
	jr nz, .done
	inc hl
	inc [hl]
.done
	scf
	ret

Pokedex_ListingMoveUpOnePage:
	ld hl, wDexListingScrollOffset + 1
	ld a, [hld]
	or [hl]
	ret z
	ld a, [hl]
	sub d
	ld [hli], a
	jr nc, .done
	ld a, [hl]
	dec [hl]
	and a
	jr nz, .done
	; a = 0 here
	ld [hld], a
	ld [hl], a
.done
	scf
	ret

Pokedex_ListingMoveDownOnePage:
	ld a, e
	and a
	ret z
	cp d
	jr c, .got_scroll
	ld a, d
.got_scroll
	ld hl, wDexListingScrollOffset
	add [hl]
	ld [hli], a
	jr nc, .done
	inc [hl]
.done
	scf
	ret

Pokedex_FillColumn:
; Fills a column starting at hl, going downwards.
; b is the height of the column, and a is the tile it's filled with.
	push de
	ld de, SCREEN_WIDTH
.loop
	ld [hl], a
	add hl, de
	dec b
	jr nz, .loop
	pop de
	ret

Pokedex_PrintLittleEndian:
	; in: hl, de as per PrintNum - bc will be set internally
	ld a, [de]
	ld [wPokedexDisplayNumber + 1], a
	inc de
	ld a, [de]
	ld de, wPokedexDisplayNumber
	ld [de], a
	lb bc, 2, 3
	jmp PrintNum

Pokedex_DrawMainScreenBG:
; Draws the left sidebar and the bottom bar on the main screen.
	hlcoord 0, 17
	ld de, String_START_SEARCH
	call Pokedex_PlaceString
	ld a, $32
	hlcoord 0, 0
	ld bc, SCREEN_AREA
	rst ByteFill
	hlcoord 0, 0
	lb bc, 7, 7
	call Pokedex_PlaceBorder
	hlcoord 0, 9
	lb bc, 6, 7
	call Pokedex_PlaceBorder
	hlcoord 1, 11
	ld de, String_SEEN
	call Pokedex_PlaceString
	ld hl, wPokedexSeen
	ld bc, wEndPokedexSeen - wPokedexSeen
	call CountSetBits16
	ld a, c
	ld de, wPokedexDisplayNumber + 1
	ld [de], a
	dec de
	ld a, b
	ld [de], a
	hlcoord 5, 12
	lb bc, 2, 3
	call PrintNum
	hlcoord 1, 14
	ld de, String_OWN
	call Pokedex_PlaceString
	ld hl, wPokedexCaught
	ld bc, wEndPokedexCaught - wPokedexCaught
	call CountSetBits16
	ld a, c
	ld de, wPokedexDisplayNumber + 1
	ld [de], a
	dec de
	ld a, b
	ld [de], a
	hlcoord 5, 15
	lb bc, 2, 3
	call PrintNum
	hlcoord 1, 17
	ld de, String_SELECT_OPTION
	call Pokedex_PlaceString
	hlcoord 8, 1
	ld b, 7
	ld a, $5a
	call Pokedex_FillColumn
	hlcoord 8, 10
	ld b, 6
	ld a, $5a
	call Pokedex_FillColumn
	hlcoord 8, 0
	ld [hl], $59
	hlcoord 8, 8
	ld [hl], $53
	hlcoord 8, 9
	ld [hl], $54
	hlcoord 8, 16
	ld [hl], $5b
	jmp Pokedex_PlaceFrontpicTopLeftCorner

String_SEEN:
	db "SEEN", -1
String_OWN:
	db "OWN", -1
String_SELECT_OPTION:
	db $3b, $48, $49, $4a, $44, $45, $46, $47 ; SELECT > OPTION
	; fallthrough
String_START_SEARCH:
	db $3c, $3b, $41, $42, $43, $4b, $4c, $4d, $3c, $32, -1 ; START > SEARCH

Pokedex_DrawDexEntryScreenBG:
	hlcoord 0, 0
	lb bc, 15, 18
	call Pokedex_PlaceBorder
	hlcoord 19, 0
	ld [hl], $34
	hlcoord 19, 1
	ld a, " "
	ld b, 15
	call Pokedex_FillColumn
	ld [hl], $39
; SELECT > SHINY, START > MAP
	; SELECT > $48, $49, $4a
	; > SHINY $61-63
	hlcoord	1, 0
	ld a, $57 ; new curved text border, left
	ld [hli], a
	ld a, $48 ; SELECT 1
	ld [hli], a
	inc a ; $49, SELECT 2
	ld [hli], a
	inc a ; $4a, SELECT 3
	ld [hli], a
	ld a, $61 ; SHINY 1
	ld [hli], a
	inc a ; $62, SHINY 2
	ld [hli], a
	inc a ; $63, SHINY 2
	ld [hli], a
	ld [hl], $58 ; new curved text border, right
; clear the row for bottom menu
	hlcoord 1, 17
	ld bc, SCREEN_WIDTH - 2
	ld a, " "
	rst ByteFill
	ld c, 4
	call DelayFrames
; erase the bottom half of screen where info will go
	lb bc, 8, SCREEN_WIDTH - 1 ; 8 tiles high, 19 tiles wide
	hlcoord 1, 8 
	call ClearBox
; horizonal skinny line ending in the page num tab
	hlcoord 1, 8
	ld bc, 19
	ld a, $55
	rst ByteFill
; category enclosure
; ; corners
; 	hlcoord 8, 5
; 	ld [hl], $6f
; 	inc hl
; plaine horizontal line
	hlcoord 8, 5
	ld a, $4e ; VRAM 1
	ld bc, 12
	rst ByteFill
; ; vertical lateral lines	
; 	hlcoord 8, 6
; 	ld [hl], $6e
; 	hlcoord 8, 7
; 	ld [hl], $6e	
; place species name
	ld a, [wTempSpecies]
	ld [wCurSpecies], a
	farcall DisplayDexMonType_CustomGFX
	call GetPokemonName
	hlcoord 9, 3
	rst PlaceString ; mon species	
; .print_dex_num ; Print dex number
	hlcoord 10, 1
	ld a, $5c ; No
	ld [hli], a
	ld a, $e8 ; .
	ld [hli], a
	push hl ; hlcoord
	ld a, [wTempSpecies]
	call GetPokemonIndexFromID
	ld b, l
	ld c, h
	ld hl, sp + 0
	ld d, h
	ld e, l
	pop hl ; hlcoord
	push bc ; mon index
	lb bc, PRINTNUM_LEADINGZEROS | 2, 3
	call PrintNum
	pop bc ; mon index
; up/down arrow indicators
	hlcoord 19, 0
	ld [hl], $3f
	hlcoord 19, 16
	ld [hl], $40
; place bottom row menu
	hlcoord 0, 17
	ld de, .MenuItems
	call Pokedex_PlaceString
	call Pokedex_PlaceFrontpicTopLeftCorner
; Check to see if we caught it.  Get out of here if we haven't.
	ld a, [wTempSpecies]
	call GetPokemonIndexFromID
	ld d, h
	ld e, l
	call CheckCaughtMonIndex ; call CheckCaughtMon
	ret z
; place Caught ball icon
	hlcoord 16, 1
	ld [hl], $4f ; pokeball icon
	ret

.MenuItems:
	db $3b, " ", $79, $7a, " ", \ ; INFO
		$71, $72, " ", \ ; STATS
		$74, $75, $76, " ", \ ; MOVES
		$77, $78, " ", \ ; AREA
		$7d, $7e, \ ; EVO
		$31, $7b, $7c, -1 ; PICS

Pokedex_LoadTextboxSpaceGFX:
	push hl
	push de
	push bc
	push af
	call DelayFrame
	ldh a, [rVBK]
	push af
	ld a, $1
	ldh [rVBK], a
	ld de, TextboxSpaceGFX
	lb bc, BANK(TextboxSpaceGFX), 1
	ld hl, vTiles2 tile " "
	call Get2bpp
	pop af
	ldh [rVBK], a
	pop af
	pop bc
	pop de
	pop hl
	ret

Pokedex_DrawOptionScreenBG:
	call Pokedex_FillBackgroundColor2
	hlcoord 0, 2
	lb bc, 8, 18
	call Pokedex_PlaceBorder
	hlcoord 0, 12
	lb bc, 4, 18
	call Pokedex_PlaceBorder
	hlcoord 0, 1
	ld de, .Title
	call Pokedex_PlaceString
	hlcoord 3, 3
	ld de, .Color
	rst PlaceString
	hlcoord 3, 4
	ld de, .AtoZMode
	rst PlaceString
	hlcoord 3, 5
	ld de, .NewMode
	rst PlaceString
	hlcoord 3, 6
	ld de, .OldMode
	rst PlaceString
	hlcoord 3, 7
	ld de, .Print
	rst PlaceString
	ld a, [wUnlockedUnownMode]
	and a
	ret z
	hlcoord 3, 8
	ld de, .UnownMode
	jmp PlaceString

.Title:
	db $3b, " OPTION ", $3c, -1

.NewMode:
	db "NEW #DEX MODE@"

.OldMode:
	db "OLD #DEX MODE@"

.AtoZMode:
	db "A to Z MODE@"
	
.Color:
	db "#DEX COLOR@"

.Print:
	db "PRINT ENTRY@"

.UnownMode:
	db "UNOWN MODE@"

Pokedex_DrawColorScreenBG:
	call Pokedex_FillBackgroundColor2
	hlcoord 0, 2
	lb bc, 14, 18
	call Pokedex_PlaceBorder
	hlcoord 0, 1
	ld de, .Title
	call Pokedex_PlaceString
	hlcoord 3, 3
	ld de, .Red
	call Pokedex_PlaceString	
	hlcoord 3, 4
	ld de, .Blue
	call Pokedex_PlaceString
	hlcoord 3, 5
	ld de, .Purple
	call Pokedex_PlaceString
	hlcoord 3, 6
	ld de, .Brown
	call Pokedex_PlaceString
	hlcoord 3, 7
	ld de, .Green
	call Pokedex_PlaceString
	hlcoord 3, 8
	ld de, .Pink
	call Pokedex_PlaceString
	hlcoord 3, 9
	ld de, .Yellow
	call Pokedex_PlaceString
	hlcoord 3, 10
	ld de, .Cyan
	call Pokedex_PlaceString
	hlcoord 3, 11
	ld de, .Gray
	jmp Pokedex_PlaceString
	; hlcoord 3, 12
	; ld de, .Mewtwo
	; jp Pokedex_PlaceString

 .Title:
	db $3b, " COLORS ", $3c, -1

 .Red
	db "RED    ", $4f, -1
	
 .Blue
	db "BLUE   ", $4f, -1

 .Purple
	db "PURPLE ", $4f, -1

 .Brown
	db "BROWN  ", $4f, -1

 .Green
	db "GREEN  ", $4f, -1	
	
 .Pink
	db "PINK   ", $4f, -1	
	
 .Yellow
	db "YELLOW ", $4f, -1	
	
 .Cyan
	db "CYAN   ", $4f, -1
	
 .Gray
	db "GRAY   ", $4f, -1	
	
 ; .Mewtwo
; 	db "MEWTWO ", $4f, -1	

 Pokedex_UpdateColorOption:
	ld de, .ArrowCursorData
	call Pokedex_MoveArrowCursor
	ld hl, hJoyPressed
	ld a, [hl]
	and PAD_SELECT | PAD_B
	jr nz, .return_to_options
	ld a, [hl]
	and PAD_A
	ret z
; the menu's rows are in DEXCOLOR_* order
	ld a, [wDexArrowCursorPosIndex]
	ld [wCurPokedexColor], a
	call Pokedex_BlackOutBG
	ld a, DEXSTATE_COLOR_OPTION
	ld [wJumptableIndex], a
	ret

.return_to_options
	call Pokedex_BlackOutBG
	ld a, DEXSTATE_OPTION_SCR
	ld [wJumptableIndex], a
	ret

.ArrowCursorData:
	db PAD_UP | PAD_DOWN, NUM_DEXCOLORS
	dwcoord 2,  3  ; DEXCOLOR_RED
	dwcoord 2,  4  ; DEXCOLOR_BLUE
	dwcoord 2,  5  ; DEXCOLOR_PURPLE
	dwcoord 2,  6  ; DEXCOLOR_BROWN
	dwcoord 2,  7  ; DEXCOLOR_GREEN
	dwcoord 2,  8  ; DEXCOLOR_PINK
	dwcoord 2,  9  ; DEXCOLOR_YELLOW
	dwcoord 2,  10 ; DEXCOLOR_CYAN
	dwcoord 2,  11 ; DEXCOLOR_GRAY

Pokedex_DrawSearchScreenBG:
	call Pokedex_FillBackgroundColor2
	hlcoord 0, 2
	lb bc, 14, 18
	call Pokedex_PlaceBorder
	hlcoord 0, 1
	ld de, .Title
	call Pokedex_PlaceString
	hlcoord 8, 4
	ld de, .TypeLeftRightArrows
	call Pokedex_PlaceString
	hlcoord 8, 6
	ld de, .TypeLeftRightArrows
	call Pokedex_PlaceString
	hlcoord 3, 4
	ld de, .Types
	rst PlaceString
	hlcoord 3, 13
	ld de, .Menu
	jmp PlaceString

.Title:
	db $3b, " SEARCH ", $3c, -1

.TypeLeftRightArrows:
	db $3d, "        ", $3e, -1

.Types:
	db   "TYPE1"
	next "TYPE2"
	db   "@"

.Menu:
	db   "BEGIN SEARCH!!"
	next "CANCEL"
	db   "@"

Pokedex_DrawSearchResultsScreenBG:
	call Pokedex_FillBackgroundColor2
	hlcoord 0, 0
	lb bc, 7, 7
	call Pokedex_PlaceBorder
	hlcoord 0, 11
	lb bc, 5, 18
	call Pokedex_PlaceBorder
	hlcoord 1, 12
	ld de, .BottomWindowText
	rst PlaceString
	ld de, wDexSearchResultCount
	hlcoord 1, 16
	call Pokedex_PrintLittleEndian
	hlcoord 8, 0
	ld [hl], $59
	hlcoord 8, 1
	ld b, 7
	ld a, $5a
	call Pokedex_FillColumn
	hlcoord 8, 8
	ld [hl], $53
	hlcoord 8, 9
	ld [hl], $69
	hlcoord 8, 10
	ld [hl], $6a
	jmp Pokedex_PlaceFrontpicTopLeftCorner

.BottomWindowText:
	db   "SEARCH RESULTS"
	next "  TYPE"
	next "    FOUND!"
	db   "@"
Pokedex_PlaceSearchResultsTypeStrings:
	ld a, [wDexSearchMonType1]
	hlcoord 0, 14
	call Pokedex_PlaceTypeString
	ld a, [wDexSearchMonType1]
	ld b, a
	ld a, [wDexSearchMonType2]
	and a
	ret z
	cp b
	ret z
	hlcoord 2, 15
	call Pokedex_PlaceTypeString
	hlcoord 1, 15
	ld [hl], "/"
	ret

Pokedex_DrawUnownModeBG:
	call Pokedex_FillBackgroundColor2
	hlcoord 2, 1
	lb bc, 10, 13
	call Pokedex_PlaceBorder
	hlcoord 2, 14
	lb bc, 1, 13
	call Pokedex_PlaceBorder
	hlcoord 2, 15
	ld [hl], $3d
	hlcoord 16, 15
	ld [hl], $3e
	hlcoord 6, 5
	call PlaceFrontpicAtHL
	ld de, 0
	lb bc, 0, NUM_UNOWN
.loop
	ld hl, wUnownDex
	add hl, de
	ld a, [hl]
	cp -1
	jr z, .done
	push af
	ld hl, UnownModeLetterAndCursorCoords
rept 4
	add hl, de
endr
	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop af
	add FIRST_UNOWN_CHAR ; Unown A
	ld [hl], a
	inc de
	inc b
	dec c
	jr nz, .loop
.done
	ld a, b
	ld [wDexUnownCount], a
	ret

UnownModeLetterAndCursorCoords:
; entries correspond to Unown forms
;           letter, cursor
	dwcoord   4,11,   3,11 ; A
	dwcoord   4,10,   3,10 ; B
	dwcoord   4, 9,   3, 9 ; C
	dwcoord   4, 8,   3, 8 ; D
	dwcoord   4, 7,   3, 7 ; E
	dwcoord   4, 6,   3, 6 ; F
	dwcoord   4, 5,   3, 5 ; G
	dwcoord   4, 4,   3, 4 ; H
	dwcoord   4, 3,   3, 2 ; I
	dwcoord   5, 3,   5, 2 ; J
	dwcoord   6, 3,   6, 2 ; K
	dwcoord   7, 3,   7, 2 ; L
	dwcoord   8, 3,   8, 2 ; M
	dwcoord   9, 3,   9, 2 ; N
	dwcoord  10, 3,  10, 2 ; O
	dwcoord  11, 3,  11, 2 ; P
	dwcoord  12, 3,  12, 2 ; Q
	dwcoord  13, 3,  13, 2 ; R
	dwcoord  14, 3,  15, 2 ; S
	dwcoord  14, 4,  15, 4 ; T
	dwcoord  14, 5,  15, 5 ; U
	dwcoord  14, 6,  15, 6 ; V
	dwcoord  14, 7,  15, 7 ; W
	dwcoord  14, 8,  15, 8 ; X
	dwcoord  14, 9,  15, 9 ; Y
	dwcoord  14,10,  15,10 ; Z

Pokedex_FillBackgroundColor2:
	hlcoord 0, 0
	ld a, $32
	ld bc, SCREEN_AREA
	jmp ByteFill

Pokedex_PlaceFrontpicTopLeftCorner:
	hlcoord 1, 1
PlaceFrontpicAtHL:
	xor a
	ld b, $7
.row
	ld c, $7
	push af
	push hl
.col
	ld [hli], a
	add $7
	dec c
	jr nz, .col
	pop hl
	ld de, SCREEN_WIDTH
	add hl, de
	pop af
	inc a
	dec b
	jr nz, .row
	ret

Pokedex_PlaceString:
.loop
	ld a, [de]
	cp -1
	ret z
	inc de
	ld [hli], a
	jr .loop

Pokedex_PlaceBorder:
	push hl
	ld a, $33
	ld [hli], a
	ld d, $34
	call .FillRow
	ld [hl], $35
	pop hl
	ld de, SCREEN_WIDTH
	add hl, de
.loop
	push hl
	ld a, $36
	ld [hli], a
	ld d, $7f
	call .FillRow
	ld [hl], $37
	pop hl
	ld de, SCREEN_WIDTH
	add hl, de
	dec b
	jr nz, .loop
	ld a, $38
	ld [hli], a
	ld d, $39
	call .FillRow
	ld [hl], $3a
	ret

.FillRow:
	ld e, c
.row_loop
	ld a, e
	and a
	ret z
	ld a, d
	ld [hli], a
	dec e
	jr .row_loop

Pokedex_PrintListing:
; Prints the list of Pokémon on the main Pokédex screen.

	ld c, 11
; Clear (2 * [wDexListingHeight] + 1) by 11 box starting at 0,1
	hlcoord 0, 1
	ld a, [wDexListingHeight]
	add a
	inc a
	ld b, a
	ld a, " "
	call Pokedex_FillBox

; Load de with a pointer to the first mon on the list
	ld hl, wDexListingScrollOffset
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, hl
	ld de, wPokedexOrder
	add hl, de
	ld e, l
	ld d, h
	hlcoord 0, 2
	ldh a, [rSVBK]
	push af
	ld a, [wDexListingHeight]
.loop
	push af
	ld a, BANK(wPokedexOrder)
	ldh [rSVBK], a
	ld a, [de]
	ld c, a
	inc de
	ld a, [de]
	inc de
	push de
	ld d, a
	ld e, c
	or e
	push hl
	call nz, .PrintEntry
	pop hl
	ld de, 2 * SCREEN_WIDTH
	add hl, de
	pop de
	pop af
	dec a
	jr nz, .loop
	pop af
	ldh [rSVBK], a
	jmp Pokedex_LoadSelectedMonTiles

.PrintEntry:
	ld a, d
	and e
	inc a
	ret z
	ld a, BANK(wPokedexSeen)
	ldh [rSVBK], a
	call Pokedex_PrintNumberIfOldMode
	call Pokedex_PlaceDefaultStringIfNotSeen
	ret c
	call Pokedex_PlaceCaughtSymbolIfCaught
	push hl
	; hl = de * 10 (length of a Pokémon name)
	ld h, d
	ld l, e
	add hl, hl
	add hl, hl
	add hl, de
	add hl, hl
	ld de, PokemonNames - (MON_NAME_LENGTH - 1) ;correct for the one-based indexing
	add hl, de
	ld a, BANK(PokemonNames)
	ld bc, MON_NAME_LENGTH - 1
	ld de, wPokedexNameBuffer
	push de
	call FarCopyBytes
	ld a, "@"
	ld [wPokedexNameBuffer + MON_NAME_LENGTH - 1], a
	pop de
	pop hl
	jmp PlaceString

Pokedex_PrintNumberIfOldMode:
	ld a, [wCurDexMode]
	cp DEXMODE_OLD
	ret nz
	push hl
	push de
	ld bc, -SCREEN_WIDTH
	add hl, bc
	ld a, e
	ld [wPokedexDisplayNumber + 1], a
	ld a, d
	ld de, wPokedexDisplayNumber
	ld [de], a
	lb bc, PRINTNUM_LEADINGZEROS | 2, 3
	call PrintNum
	pop de
	pop hl
	ret

Pokedex_PlaceCaughtSymbolIfCaught:
	push hl
	push de
	call CheckCaughtMonIndex
	pop de
	pop hl
	jr nz, .place_caught_symbol
	inc hl
	ret

.place_caught_symbol
	ld a, $4f
	ld [hli], a
	ret

Pokedex_PlaceDefaultStringIfNotSeen:
	push hl
	push de
	call CheckSeenMonIndex
	; ld a, 1 ; DEBUG
	; and a ; DEBUG
	pop de
	pop hl
	ret nz
	inc hl
	ld de, .NameNotSeen
	rst PlaceString
	scf
	ret

.NameNotSeen:
	db "-----@"

Pokedex_DrawFootprint:
	hlcoord 18, 1
	ld a, $6d ; $62
	ld [hli], a
	inc a
	ld [hl], a
	hlcoord 18, 2
	ld a, $6f ; $64
	ld [hli], a
	inc a
	ld [hl], a
	ret

Pokedex_GetSelectedMon:
; Gets the species of the currently selected Pokémon. This corresponds to the
; position of the cursor in the main listing, but this function can be used
; on all Pokédex screens.
	ldh a, [rSVBK]
	push af
	ld a, BANK(wPokedexOrder)
	ldh [rSVBK], a
	ld hl, wDexListingScrollOffset
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wDexListingCursor]
	ld e, a
	ld d, 0
	add hl, de
	ld de, wPokedexOrder
	add hl, hl
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop af
	ldh [rSVBK], a
	push hl
	call GetPokemonIDFromIndex
	ld l, LOCKED_MON_ID_DEX_SELECTED
	call LockPokemonID
	pop hl
	ld [wTempSpecies], a
	ret

Pokedex_CheckSeen:
	push de
	push hl
	ld a, [wTempSpecies]
	call CheckSeenMon
	; ld a, 1 ; DEBUG, to unlock all unseen mon
	; and a ; DEBUG, to unlock all unseen mon
	pop hl
	pop de
	ret

Pokedex_OrderMonsByMode:
	ld hl, wEndPokedexSeen - 1
	ld c, wEndPokedexSeen - wPokedexSeen
.last_seen_loop
	ld a, [hld]
	and a
	jr nz, .found_last_seen
	dec c
	jr nz, .last_seen_loop
.found_last_seen
	ld [wDexLastSeenValue], a
	dec c
	and a ;flags will be preserved until the jump, since all following operations are loads (and a push)
	ld a, c
	ld [wDexLastSeenIndex], a

	ldh a, [rSVBK]
	push af
	ld a, BANK(wPokedexOrder)
	ldh [rSVBK], a
	ld hl, wPokedexOrder
	ld a, -1
	jr z, .nothing_seen
	ld bc, (NUM_POKEMON + 1) * 2
	rst ByteFill
	ld a, [wCurDexMode]
	ld hl, .Jumptable
	call Pokedex_LoadPointer
	call _hl_
.restore_bank_and_exit
	pop af
	ldh [rSVBK], a
	ret

.nothing_seen
	ld [hli], a
	ld [hl], a
	xor a
	ld hl, wDexListingEnd
	ld [hli], a
	ld [hl], a
	jr .restore_bank_and_exit

.Jumptable:
	dw .NewMode
	dw .OldMode
	dw Pokedex_ABCMode

.OldMode:
	ld a, [wDexLastSeenValue] ;known to be non-zero
	ld c, 9 ;bits are numbered 1-8 (instead of 0-7) because the first dex entry is #001, not #000
.highest_bit_index_loop
	dec c
	add a
	jr nc, .highest_bit_index_loop
	ld a, [wDexLastSeenIndex]
	ld l, a
	ld h, 0
	ld b, h
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, bc
	ld d, h
	ld e, l
	ld hl, wPokedexOrder
	ld c, b ;b = 0
.old_mode_loop
	inc bc
	ld a, c
	ld [hli], a
	ld a, b
	ld [hli], a
	cp d
	jr c, .old_mode_loop
	ld a, c
	cp e
	jr c, .old_mode_loop
	ld hl, wDexListingEnd
	ld a, e
	ld [hli], a
	ld [hl], d
	ret

.NewMode:
	ld hl, NewPokedexOrder
	ld de, wPokedexOrder
	ld bc, NUM_POKEMON * 2
	rst CopyBytes
	ld a, BANK(wPokedexSeen)
	ldh [rSVBK], a
	ld bc, NUM_POKEMON
	ld hl, NewPokedexOrder + (2 * NUM_POKEMON) - 1
.new_mode_last_seen_loop
	ld a, [hld]
	ld d, a
	ld a, [hld]
	ld e, a
	push hl
	push bc
	call CheckSeenMonIndex
	pop bc
	pop hl
	jr nz, .found_last_seen_index
	dec bc
	ld a, b
	or c
	jr nz, .new_mode_last_seen_loop
.found_last_seen_index
	ld hl, wDexListingEnd
	ld a, c
	ld [hli], a
	ld [hl], b
	ret

Pokedex_ABCMode:
	; called in the WRAM bank of wPokedexOrder; the function doesn't preserve it
	ld hl, wDexTempCounter
	ld a, LOW(-NUM_POKEMON)
	ld [hli], a
	ld [hl], HIGH(-NUM_POKEMON)
	ld bc, AlphabeticalPokedexOrder
	ld de, wPokedexOrder
	ld a, BANK(wPokedexSeen)
	ldh [rSVBK], a
.loop
	push de
	ld a, [bc]
	ld e, a
	inc bc
	ld a, [bc]
	ld d, a
	push bc
	call CheckSeenMonIndex
	pop bc
	pop de
	jr z, .skip
	ld a, BANK(wPokedexOrder)
	ldh [rSVBK], a
	dec bc
	ld a, [bc]
	ld [de], a
	inc de
	inc bc
	ld a, [bc]
	ld [de], a
	inc de
	ld a, BANK(wPokedexSeen)
	ldh [rSVBK], a
.skip
	inc bc
	ld hl, wDexTempCounter
	inc [hl]
	jr nz, .loop
	inc hl
	inc [hl]
	jr nz, .loop
	ld hl, $10000 - wPokedexOrder ;ld hl, -wPokedexOrder -- see https://github.com/rednex/rgbds/issues/279
	add hl, de
	srl h
	rr l
	ld a, l
	ld [wDexListingEnd], a
	ld a, h
	ld [wDexListingEnd + 1], a
	ret

INCLUDE "data/pokemon/dex_order_alpha.asm"

INCLUDE "data/pokemon/dex_order_new.asm"

Pokedex_DisplayModeDescription:
	xor a
	ldh [hBGMapMode], a
	hlcoord 0, 12
	lb bc, 4, 18
	call Pokedex_PlaceBorder
	ld a, [wDexArrowCursorPosIndex]
	ld hl, .Modes
	call Pokedex_LoadPointer
	ld e, l
	ld d, h
	hlcoord 1, 14
	call Pokedex_PlaceString
	ld a, $1
	ldh [hBGMapMode], a
	ret

.Modes:
	dw .Color
	dw .ABCMode
	dw .NewMode
	dw .OldMode
	dw .Print
	dw .UnownMode

.Print:
	db   "Print the entry of", $37, $36, \
		 "                  ", $37, $36, \
		 "the selected <PK><MN>.", -1

.NewMode:
	db   "<PK><MN> are listed by  ", $37, $36, \
		 "                  ", $37, $36, \
		 "evolution type.", -1

.OldMode:
	db   "<PK><MN> are listed by  ", $37, $36, \
		 "                  ", $37, $36, \
		 "official type.", -1

.ABCMode:
	db   "<PK><MN> are listed     ", $37, $36, \
		 "                  ", $37, $36, \
		 "alphabetically.", -1

.Color
	db   "Change the color  ", $37, $36, \
		 "                  ", $37, $36, \
		 "of the border.", -1

.UnownMode:
	db   "UNOWN are listed  ", $37, $36, \
		 "                  ", $37, $36, \
		 "in catching order.", -1

Pokedex_DisplayChangingModesMessage:
	xor a
	ldh [hBGMapMode], a
	hlcoord 0, 12
	lb bc, 4, 18
	call Pokedex_PlaceBorder
	ld de, String_ChangingModesPleaseWait
	hlcoord 1, 14
	rst PlaceString
	ld a, $1
	ldh [hBGMapMode], a
	ld c, 64
	call DelayFrames
	ld de, SFX_CHANGE_DEX_MODE
	call PlaySFX
	ld c, 64
	jmp DelayFrames

String_ChangingModesPleaseWait:
	db   "Changing modes."
	next "Please wait.@"

Pokedex_UpdateSearchMonType:
	ld a, [wDexArrowCursorPosIndex]
	cp 2
	jr nc, .no_change
	ld hl, hJoyLast
	ld a, [hl]
	and PAD_LEFT
	jr nz, Pokedex_PrevSearchMonType
	ld a, [hl]
	and PAD_RIGHT
	jr nz, Pokedex_NextSearchMonType
.no_change
	and a
	ret

Pokedex_PrevSearchMonType:
	ld a, [wDexArrowCursorPosIndex]
	and a
	jr nz, .type2

	ld hl, wDexSearchMonType1
	ld a, [hl]
	dec a
	jr z, .wrap_around
	dec [hl]
	jr .done

.type2
	ld hl, wDexSearchMonType2
	ld a, [hl]
	and a
	jr z, .wrap_around
	dec [hl]
	jr .done

.wrap_around
	ld [hl], NUM_TYPES

.done
	scf
	ret

Pokedex_NextSearchMonType:
	ld a, [wDexArrowCursorPosIndex]
	and a
	jr nz, .type2

	ld hl, wDexSearchMonType1
	ld a, [hl]
	cp NUM_TYPES
	jr nc, .type1_wrap_around
	inc [hl]
	jr .done
.type1_wrap_around
	ld [hl], 1
	jr .done

.type2
	ld hl, wDexSearchMonType2
	ld a, [hl]
	cp NUM_TYPES
	jr nc, .type2_wrap_around
	inc [hl]
	jr .done
.type2_wrap_around
	ld [hl], 0

.done
	scf
	ret

Pokedex_PlaceSearchScreenTypeStrings:
	xor a
	ldh [hBGMapMode], a
	hlcoord 9, 3
	lb bc, 4, 8
	ld a, " "
	call Pokedex_FillBox
	ld a, [wDexSearchMonType1]
	hlcoord 9, 4
	call Pokedex_PlaceTypeString
	ld a, [wDexSearchMonType2]
	hlcoord 9, 6
	call Pokedex_PlaceTypeString
	ld a, $1
	ldh [hBGMapMode], a
	ret

Pokedex_PlaceTypeString:
	push hl
	ld e, a
	ld d, 0
	ld hl, PokedexTypeSearchStrings
rept POKEDEX_TYPE_STRING_LENGTH
	add hl, de
endr
	ld e, l
	ld d, h
	pop hl
	jmp PlaceString

INCLUDE "data/types/search_strings.asm"

Pokedex_SearchForMons:
	ldh a, [rSVBK]
	push af
	ld a, BANK(wPokedexOrder)
	ldh [rSVBK], a
	ld a, [wDexSearchMonType2]
	and a
	call nz, .Search
	ld a, [wDexSearchMonType1]
	and a
	call nz, .Search
	pop af
	ldh [rSVBK], a
	ret

.Search:
	ld e, a
	xor a
	ld hl, wDexSearchResultCount
	ld [hli], a
	ld [hl], a
	ld d, a
	ld hl, PokedexTypeSearchConversionTable - 1
	add hl, de
	ld a, [hl]
	ld [wDexConvertedMonType], a
	ld hl, wDexListingEnd
	ld a, [hli]
	ld b, [hl]
	ld c, a
	ld hl, wPokedexOrder
	ld d, h
	ld e, l

.loop
	push bc
	ld a, [hli]
	ld c, a
	ld a, [hli]
	push hl
	ld b, a
	or c
	jr z, .next_mon
	ld a, b
	and c
	inc a
	jr z, .next_mon
	push bc
	push de
	ld d, b
	ld e, c
	ld a, BANK(wPokedexSeen)
	ldh [rSVBK], a
	call CheckSeenMonIndex
	ld a, BANK(wPokedexOrder)
	ldh [rSVBK], a
	pop de
	pop bc
	jr z, .next_mon
	; instead of going through an index conversion and GetBaseData (which would end up GC'ing the
	; index table several times!), just load the base data pointer directly and do a far read
	ld a, BANK(BaseData)
	ld hl, BaseData
	push bc
	call LoadIndirectPointer
	ld bc, BASE_TYPES
	add hl, bc
	pop bc
	jr z, .next_mon
	call GetFarWord ;load both types in hl
	ld a, [wDexConvertedMonType]
	cp h
	jr z, .match_found
	cp l
	jr nz, .next_mon

.match_found
	ld a, c
	ld [de], a
	inc de
	ld a, b
	ld [de], a
	inc de
	ld hl, wDexSearchResultCount
	inc [hl]
	jr nz, .next_mon
	inc hl
	inc [hl]

.next_mon
	pop hl
	pop bc
	dec bc
	ld a, b
	or c
	jr nz, .loop

	ld hl, wDexSearchResultCount
	ld bc, -(NUM_POKEMON + 1)
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, bc ;hl = minus the number of entries to clear
	ld c, l
	ld b, h
	ld l, e
	ld h, d
	ld a, -1
.clear_remaining_mons
	ld [hli], a
	ld [hli], a
	inc c
	jr nz, .clear_remaining_mons
	inc b
	jr nz, .clear_remaining_mons
	ret

INCLUDE "data/types/search_types.asm"

Pokedex_DisplayTypeNotFoundMessage:
	xor a
	ldh [hBGMapMode], a
	hlcoord 0, 12
	lb bc, 4, 18
	call Pokedex_PlaceBorder
	ld de, .TypeNotFound
	hlcoord 1, 14
	rst PlaceString
	ld a, $1
	ldh [hBGMapMode], a
	ld c, $80
	jmp DelayFrames

.TypeNotFound:
	db   "The specified type"
	next "was not found.@"

Pokedex_UpdateCursorOAM:
	ld a, [wCurDexMode]
	cp DEXMODE_OLD
	jr z, Pokedex_PutOldModeCursorOAM
	call Pokedex_PutNewModeABCModeCursorOAM
	jmp Pokedex_PutScrollbarOAM

Pokedex_PutOldModeCursorOAM:
	ld hl, .CursorOAM
	ld a, [wDexListingCursor]
	or a
	jr nz, .okay
	ld hl, .CursorAtTopOAM
.okay
	jmp Pokedex_LoadCursorOAM

.CursorOAM:
	dbsprite  9,  3, -1,  0, $30, 7
	dbsprite  9,  2, -1,  0, $31, 7
	dbsprite 10,  2, -1,  0, $32, 7
	dbsprite 11,  2, -1,  0, $32, 7
	dbsprite 12,  2, -1,  0, $32, 7
	dbsprite 13,  2, -1,  0, $33, 7
	dbsprite 16,  2, -2,  0, $33, 7 | OAM_XFLIP
	dbsprite 17,  2, -2,  0, $32, 7 | OAM_XFLIP
	dbsprite 18,  2, -2,  0, $32, 7 | OAM_XFLIP
	dbsprite 19,  2, -2,  0, $32, 7 | OAM_XFLIP
	dbsprite 20,  2, -2,  0, $31, 7 | OAM_XFLIP
	dbsprite 20,  3, -2,  0, $30, 7 | OAM_XFLIP
	dbsprite  9,  4, -1,  0, $30, 7 | OAM_YFLIP
	dbsprite  9,  5, -1,  0, $31, 7 | OAM_YFLIP
	dbsprite 10,  5, -1,  0, $32, 7 | OAM_YFLIP
	dbsprite 11,  5, -1,  0, $32, 7 | OAM_YFLIP
	dbsprite 12,  5, -1,  0, $32, 7 | OAM_YFLIP
	dbsprite 13,  5, -1,  0, $33, 7 | OAM_YFLIP
	dbsprite 16,  5, -2,  0, $33, 7 | OAM_XFLIP | OAM_YFLIP
	dbsprite 17,  5, -2,  0, $32, 7 | OAM_XFLIP | OAM_YFLIP
	dbsprite 18,  5, -2,  0, $32, 7 | OAM_XFLIP | OAM_YFLIP
	dbsprite 19,  5, -2,  0, $32, 7 | OAM_XFLIP | OAM_YFLIP
	dbsprite 20,  5, -2,  0, $31, 7 | OAM_XFLIP | OAM_YFLIP
	dbsprite 20,  4, -2,  0, $30, 7 | OAM_XFLIP | OAM_YFLIP
	db -1

.CursorAtTopOAM:
; OAM data for when the cursor is at the top of the list. The tiles at the top
; are cut off so they don't show up outside the list area.
	dbsprite  9,  3, -1,  0, $30, 7
	dbsprite  9,  2, -1,  0, $34, 7
	dbsprite 10,  2, -1,  0, $35, 7
	dbsprite 11,  2, -1,  0, $35, 7
	dbsprite 12,  2, -1,  0, $35, 7
	dbsprite 13,  2, -1,  0, $36, 7
	dbsprite 16,  2, -2,  0, $36, 7 | OAM_XFLIP
	dbsprite 17,  2, -2,  0, $35, 7 | OAM_XFLIP
	dbsprite 18,  2, -2,  0, $35, 7 | OAM_XFLIP
	dbsprite 19,  2, -2,  0, $35, 7 | OAM_XFLIP
	dbsprite 20,  2, -2,  0, $34, 7 | OAM_XFLIP
	dbsprite 20,  3, -2,  0, $30, 7 | OAM_XFLIP
	dbsprite  9,  4, -1,  0, $30, 7 | OAM_YFLIP
	dbsprite  9,  5, -1,  0, $31, 7 | OAM_YFLIP
	dbsprite 10,  5, -1,  0, $32, 7 | OAM_YFLIP
	dbsprite 11,  5, -1,  0, $32, 7 | OAM_YFLIP
	dbsprite 12,  5, -1,  0, $32, 7 | OAM_YFLIP
	dbsprite 13,  5, -1,  0, $33, 7 | OAM_YFLIP
	dbsprite 16,  5, -2,  0, $33, 7 | OAM_XFLIP | OAM_YFLIP
	dbsprite 17,  5, -2,  0, $32, 7 | OAM_XFLIP | OAM_YFLIP
	dbsprite 18,  5, -2,  0, $32, 7 | OAM_XFLIP | OAM_YFLIP
	dbsprite 19,  5, -2,  0, $32, 7 | OAM_XFLIP | OAM_YFLIP
	dbsprite 20,  5, -2,  0, $31, 7 | OAM_XFLIP | OAM_YFLIP
	dbsprite 20,  4, -2,  0, $30, 7 | OAM_XFLIP | OAM_YFLIP
	db -1

Pokedex_PutNewModeABCModeCursorOAM:
	ld hl, .CursorOAM
	jmp Pokedex_LoadCursorOAM

.CursorOAM:
	dbsprite  9,  3, -1,  3, $30, 7
	dbsprite  9,  2, -1,  3, $31, 7
	dbsprite 10,  2, -1,  3, $32, 7
	dbsprite 11,  2, -1,  3, $32, 7
	dbsprite 12,  2, -1,  3, $33, 7
	dbsprite 16,  2,  0,  3, $33, 7 | OAM_XFLIP
	dbsprite 17,  2,  0,  3, $32, 7 | OAM_XFLIP
	dbsprite 18,  2,  0,  3, $32, 7 | OAM_XFLIP
	dbsprite 19,  2,  0,  3, $31, 7 | OAM_XFLIP
	dbsprite 19,  3,  0,  3, $30, 7 | OAM_XFLIP
	dbsprite  9,  4, -1,  3, $30, 7 | OAM_YFLIP
	dbsprite  9,  5, -1,  3, $31, 7 | OAM_YFLIP
	dbsprite 10,  5, -1,  3, $32, 7 | OAM_YFLIP
	dbsprite 11,  5, -1,  3, $32, 7 | OAM_YFLIP
	dbsprite 12,  5, -1,  3, $33, 7 | OAM_YFLIP
	dbsprite 16,  5,  0,  3, $33, 7 | OAM_XFLIP | OAM_YFLIP
	dbsprite 17,  5,  0,  3, $32, 7 | OAM_XFLIP | OAM_YFLIP
	dbsprite 18,  5,  0,  3, $32, 7 | OAM_XFLIP | OAM_YFLIP
	dbsprite 19,  5,  0,  3, $31, 7 | OAM_XFLIP | OAM_YFLIP
	dbsprite 19,  4,  0,  3, $30, 7 | OAM_XFLIP | OAM_YFLIP
	db -1

Pokedex_UpdateSearchResultsCursorOAM:
	ld a, [wCurDexMode]
	cp DEXMODE_OLD
	jmp z, Pokedex_PutOldModeCursorOAM
	ld hl, .CursorOAM
	jr Pokedex_LoadCursorOAM

.CursorOAM:
	dbsprite  9,  3, -1,  3, $30, 7
	dbsprite  9,  2, -1,  3, $31, 7
	dbsprite 10,  2, -1,  3, $32, 7
	dbsprite 11,  2, -1,  3, $32, 7
	dbsprite 12,  2, -1,  3, $32, 7
	dbsprite 13,  2, -1,  3, $33, 7
	dbsprite 16,  2, -2,  3, $33, 7 | OAM_XFLIP
	dbsprite 17,  2, -2,  3, $32, 7 | OAM_XFLIP
	dbsprite 18,  2, -2,  3, $32, 7 | OAM_XFLIP
	dbsprite 19,  2, -2,  3, $32, 7 | OAM_XFLIP
	dbsprite 20,  2, -2,  3, $31, 7 | OAM_XFLIP
	dbsprite 20,  3, -2,  3, $30, 7 | OAM_XFLIP
	dbsprite  9,  4, -1,  3, $30, 7 | OAM_YFLIP
	dbsprite  9,  5, -1,  3, $31, 7 | OAM_YFLIP
	dbsprite 10,  5, -1,  3, $32, 7 | OAM_YFLIP
	dbsprite 11,  5, -1,  3, $32, 7 | OAM_YFLIP
	dbsprite 12,  5, -1,  3, $32, 7 | OAM_YFLIP
	dbsprite 13,  5, -1,  3, $33, 7 | OAM_YFLIP
	dbsprite 16,  5, -2,  3, $33, 7 | OAM_XFLIP | OAM_YFLIP
	dbsprite 17,  5, -2,  3, $32, 7 | OAM_XFLIP | OAM_YFLIP
	dbsprite 18,  5, -2,  3, $32, 7 | OAM_XFLIP | OAM_YFLIP
	dbsprite 19,  5, -2,  3, $32, 7 | OAM_XFLIP | OAM_YFLIP
	dbsprite 20,  5, -2,  3, $31, 7 | OAM_XFLIP | OAM_YFLIP
	dbsprite 20,  4, -2,  3, $30, 7 | OAM_XFLIP | OAM_YFLIP
	db -1

Pokedex_LoadCursorOAM:
	ld de, wShadowOAMSprite00
.loop
	ld a, [hl]
	cp -1
	ret z
	ld a, [wDexListingCursor]
	and $7
	swap a
	add [hl] ; y
	inc hl
	ld [de], a
	inc de
	ld a, [hli] ; x
	ld [de], a
	inc de
	ld a, [hli] ; tile id
	ld [de], a
	inc de
	ld a, [hli] ; attributes
	ld [de], a
	inc de
	jr .loop

Pokedex_PutScrollbarOAM:
	push de
	ld hl, wDexListingEnd
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wDexListingHeight]
	cpl
	ld c, a
	ld b, $FF
	; subtract wDexListingHeight + 1 so it will also overflow on wDexListingEnd = wDexListingHeight
	add hl, bc
	inc b ;b = 0
	jr nc, .done
	inc hl ;compensate for the +1
	push hl
	ld hl, wDexListingScrollOffset
	ld a, [hli]
	ld h, [hl]
	ld l, a
	; multiply by 121 (scrollbar size) - first by 15...
	; (assume that the dex has less than $1000 entries - it won't fit in any RAM otherwise)
	ld b, h
	ld c, l
	rept 4
		add hl, hl
	endr
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	; ...then by 8 (15 * 8 = 120), storing overflows in a...
	xor a
	rept 3
		add hl, hl
		adc a
	endr
	; ...and add the original value, for a full result of ahl = wDexListingScrollOffset * 121
	add hl, bc
	adc 0
	; finally, double the value (for rounding after dividing) and transfer it to chl
	add hl, hl
	adc a
	ld c, a
	; load the scroll height (pushed before) back into de, and multiply by -16...
	pop de
	push de
	swap d
	swap e
	ld a, e
	and $f
	or d
	cpl
	ld d, a
	ld a, e
	and $f0
	cpl
	ld e, a
	inc de
	; ...and use it to calculate the upper nibble of the quotient by subtraction
	inc c
	ld b, 0
.upper_loop
	inc b
	add hl, de
	jr c, .upper_loop
	dec c
	jr nz, .upper_loop
	res 4, b ;ensure overflow doesn't leave garbage behind
	swap b
	; now there's a negative value in hl and an overly large result in b - adjust until the right value is found
	pop de
.lower_loop
	dec b
	add hl, de
	jr nc, .lower_loop
	; the result is in b - which is twice the true quotient, so increment and halve to round to nearest
	inc b
	srl b
.done
	ld a, 20 ; min y
	add b
	pop hl
	ld [hli], a
	ld a, 161 ; x
	ld [hli], a
	ld a, $3f ; $0f ; tile id
	ld [hli], a
	ld [hl], 0 ; attributes
	ret

Pokedex_InitArrowCursor:
	xor a
	ld [wDexArrowCursorPosIndex], a
	ld [wDexArrowCursorDelayCounter], a
	ld [wDexArrowCursorBlinkCounter], a
	ret

Pokedex_MoveArrowCursor:
; bc = [de] - 1
	ld a, [de]
	ld b, a
	inc de
	ld a, [de]
	dec a
	ld c, a
	inc de
	call Pokedex_BlinkArrowCursor

	ld hl, hJoyPressed
	ld a, [hl]
	and PAD_LEFT | PAD_UP
	and b
	jr nz, .move_left_or_up
	ld a, [hl]
	and PAD_RIGHT | PAD_DOWN
	and b
	jr nz, .move_right_or_down
	ld a, [hl]
	and PAD_SELECT
	and b
	jr nz, .select
	call Pokedex_ArrowCursorDelay
	jr c, .no_action
	ld hl, hJoyLast
	ld a, [hl]
	and PAD_LEFT | PAD_UP
	and b
	jr nz, .move_left_or_up
	ld a, [hl]
	and PAD_RIGHT | PAD_DOWN
	and b
	jr nz, .move_right_or_down
	jr .no_action

; A Left/Right cursor wraps around its ends; an Up/Down one stops at them.
.move_left_or_up
	ld a, [wDexArrowCursorPosIndex]
	dec a
	cp c
	jr c, .move_to_a
	bit B_PAD_LEFT, b
	jr z, .no_action
	ld a, c
	jr .move_to_a

.move_right_or_down
	ld a, [wDexArrowCursorPosIndex]
	cp c
	inc a
	jr c, .move_to_a
	bit B_PAD_RIGHT, b
	jr z, .no_action
	xor a
.move_to_a
	push af
	call Pokedex_GetArrowCursorPos
	ld [hl], " "
	pop af
	ld [wDexArrowCursorPosIndex], a

.update_cursor_pos
	call Pokedex_GetArrowCursorPos
	ld [hl], "▶"
	ld a, 12
	ld [wDexArrowCursorDelayCounter], a
	xor a
	ld [wDexArrowCursorBlinkCounter], a
	scf
	ret

.no_action
	and a
	ret

.select
	call Pokedex_GetArrowCursorPos
	ld [hl], " "
	ld a, [wDexArrowCursorPosIndex]
	cp c
	jr c, .update
	ld a, -1
.update
	inc a
	ld [wDexArrowCursorPosIndex], a
	jr .update_cursor_pos

Pokedex_GetArrowCursorPos:
	ld a, [wDexArrowCursorPosIndex]
	add a
	ld l, a
	ld h, 0
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret

Pokedex_BlinkArrowCursor:
	ld hl, wDexArrowCursorBlinkCounter
	ld a, [hl]
	inc [hl]
	and $8
	jr z, .blink_on
	call Pokedex_GetArrowCursorPos
	ld [hl], " "
	ret

.blink_on
	call Pokedex_GetArrowCursorPos
	ld [hl], "▶"
	ret

Pokedex_ArrowCursorDelay:
; Updates the delay counter set when moving the arrow cursor.
; Returns whether the delay is active in carry.
	ld hl, wDexArrowCursorDelayCounter
	ld a, [hl]
	and a
	ret z

	dec [hl]
	scf
	ret

Pokedex_FillBox:
	jmp FillBoxWithByte

Pokedex_BlackOutBG:
	ldh a, [rWBK]
	push af
	ld a, BANK(wBGPals1)
	ldh [rWBK], a
	ld hl, wBGPals1
	ld bc, 8 palettes
	xor a
	rst ByteFill
	pop af
	ldh [rWBK], a

Pokedex_ApplyPrintPals:
	ld a, $ff
	call DmgToCgbBGPals
	jmp DelayFrame

Pokedex_GetSGBLayout:
	ld b, a
	call GetSGBLayout

Pokedex_ApplyUsualPals:
; This applies the palettes used for most Pokédex screens.
	ld a, $e4
	jmp DmgToCgbBGPals

Pokedex_LoadPointer:
	ld e, a
	ld d, 0
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret

Pokedex_LoadSelectedMonTiles:
; Loads the tiles of the currently selected Pokémon.
	call Pokedex_GetSelectedMon
	call Pokedex_CheckSeen
	jr z, .QuestionMark
	; ld a, [wFirstUnownSeen] ; TODO: show first unown seen in dex
	xor a
	ld [wForm], a
	ld a, [wTempSpecies]
	ld [wCurPartySpecies], a
	call GetBaseData
	ld de, vTiles2
	predef_jump GetMonFrontpic

.QuestionMark:
	ld a, BANK(sScratch)
	call OpenSRAM
	farcall LoadQuestionMarkPic
	ld hl, vTiles2
	ld de, sScratch
	ld c, 7 * 7
	ldh a, [hROMBank]
	ld b, a
	call Get2bpp
	jmp CloseSRAM

Pokedex_LoadCurrentFootprint:
	call Pokedex_GetSelectedMon

Pokedex_LoadAnyFootprint:
	ld a, [wTempSpecies]
	call GetPokemonIndexFromID
	dec hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, Footprints
	add hl, de

	ld e, l
	ld d, h
	ld hl, vTiles2 tile $6d ; $62 is vanilla location for footprints
	lb bc, BANK(Footprints), 4
	jmp Request1bpp

Pokedex_LoadGFX:
	call Pokedex_LoadPageNums
	call DisableLCD
	ld hl, vTiles2
	ld bc, $31 tiles
	xor a
	rst ByteFill
	call Pokedex_LoadInvertedFont
	call LoadFontsExtra
	ld hl, vTiles2 tile $60
	ld bc, $20 tiles
	call Pokedex_InvertTiles
	call Pokedex_CheckSGB
	jr nz, .LoadPokedexLZ
	farcall LoadSGBPokedexGFX
	jr .LoadPokedexSlowpokeLZ

.LoadPokedexLZ:
	ld a, BANK(PokedexLZ)
	ld hl, PokedexLZ
	ld de, vTiles2 tile $31
	call FarDecompress

.LoadPokedexSlowpokeLZ:
	ld a, BANK(PokedexSlowpokeLZ)
	ld hl, PokedexSlowpokeLZ
	ld de, vTiles0
	call FarDecompress
	
	ld hl, vTiles0 tile $3f
	ld de, vTiles0 tile 15
	lb bc, BANK(vTiles0), 1 ; tile
	call Get2bpp

	ld a, 6
	call SkipMusic
	jmp EnableLCD

Pokedex_LoadPageNums:
; load pagenum tiles to vram1
; lcd needs to be enabled or it will crash !!!
	ldh a, [rLCDC]
	push af ; preserve the state of lcd for after we're done
	bit rLCDC_ENABLE, a
	call z, EnableLCD
	ld a, $1
	ldh [rVBK], a
	ld de, Pokedex_PageNumTiles tile 0
	ld hl, vTiles2 tile $60
	lb bc, BANK(Pokedex_PageNumTiles), 14
	call Request2bpp
; ; corner of box	
	; ld de, Pokedex_PageNumTiles tile 16
	; ld hl, vTiles2 tile $6f
	; lb bc, BANK(Pokedex_PageNumTiles), 1
	; call Request2bpp
; plain line		
	ld de, Pokedex_PageNumTiles tile 13
	ld hl, vTiles2 tile $4e
	lb bc, BANK(Pokedex_PageNumTiles), 1
	call Request2bpp
; ; vertical line
; 	ld de, Pokedex_PageNumTiles tile 15
; 	ld hl, vTiles2 tile $5a
; 	lb bc, BANK(Pokedex_PageNumTiles), 1
; 	call Request2bpp	
; single black tile at vram1 $7f
	ld de, Pokedex_ExtraTiles tile 31
	ld hl, vTiles2 tile $7f
	lb bc, BANK(Pokedex_ExtraTiles), 1
	call Request2bpp
	ld de, Pokedex_ExtraTiles tile 38
	ld hl, vTiles2 tile $70
	lb bc, BANK(Pokedex_ExtraTiles), 7
	call Request2bpp

	xor a
	ldh [rVBK], a
	pop af
	ldh [rLCDC], a
	ret

Pokedex_LoadInversedFont:
	ld a, 1
	ldh [rVBK], a

	ld hl, vTiles1
	lb bc, BANK(FontInversed), 128 ; $80 tiles
	ld de, FontInversed
	ld a, BANK(FontInversed)
	call Get1bpp
	ld hl, vTiles0 tile $bb
	lb bc, BANK(Pokedex_MathTiles), 5 ; 5 tiles
	ld de, Pokedex_MathTiles
	ld a, BANK(Pokedex_MathTiles)
	call Get1bpp
	ld hl, vTiles0 tile $ce
	lb bc, BANK(Pokedex_Imperial_Tiles), 2 ; 4 tiles
	ld de, Pokedex_Imperial_Tiles
	ld a, BANK(Pokedex_Imperial_Tiles)
	call Get1bpp
	ld hl, vTiles0 tile $eb
	lb bc, BANK(Pokedex_RightArrow_Tile), 1 ; 1 tiles
	ld de, Pokedex_RightArrow_Tile
	ld a, BANK(Pokedex_RightArrow_Tile)
	call Get1bpp

	xor a
	ldh [rVBK], a	
	ret

Pokedex_LoadInvertedFont:
	call LoadStandardFont
	ld hl, vTiles1
	ld bc, $80 tiles

Pokedex_InvertTiles:
.loop
	ld a, [hl]
	cpl
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, .loop

	ld hl, vTiles0 tile $bb
	lb bc, BANK(Pokedex_MathTiles), 5 ; 5 tiles
	ld de, Pokedex_MathTiles
	ld a, BANK(Pokedex_MathTiles)
	call Get1bpp
	ld hl, vTiles0 tile $ce
	lb bc, BANK(Pokedex_Imperial_Tiles), 2 ; 2 tiles
	ld de, Pokedex_Imperial_Tiles
	ld a, BANK(Pokedex_Imperial_Tiles)
	jmp Get1bpp

Pokedex_CheckSGB:
	ldh a, [hCGB]
	or a
	ret nz
	ldh a, [hSGB]
	dec a
	ret

Pokedex_LoadUnownFont:
	ld a, BANK(sScratch)
	call OpenSRAM
	ld hl, UnownFont
	; sScratch + $188 was the address of sDecompressBuffer in pokegold
	ld de, sScratch + $188
	ld bc, 39 tiles
	ld a, BANK(UnownFont)
	call FarCopyBytes
	ld hl, sScratch + $188
	ld bc, (NUM_UNOWN + 1) tiles
	call Pokedex_InvertTiles
	ld de, sScratch + $188
	ld hl, vTiles2 tile FIRST_UNOWN_CHAR
	lb bc, BANK(Pokedex_LoadUnownFont), NUM_UNOWN + 1
	call Request2bpp
	jmp CloseSRAM

Pokedex_LoadUnownFrontpicTiles:
	ld a, [wForm]
	and FORM_MASK ; only care about form bits, not shiny bit
	push af
	ld a, [wDexCurUnownIndex]
	ld e, a
	ld d, 0
	ld hl, wUnownDex
	add hl, de
	ld a, [hl]
	ld [wForm], a
	ld hl, UNOWN
	call GetPokemonIDFromIndex
	ld [wCurPartySpecies], a
	ld l, LOCKED_MON_ID_DEX_SELECTED
	call LockPokemonID
	call GetBaseData
	ld de, vTiles2 tile $00
	predef GetMonFrontpic
	pop af
	ld [wForm], a
	ret

_NewPokedexEntry:
	xor a
	ldh [hBGMapMode], a
	farcall DrawDexEntryScreenRightEdge
	call Pokedex_ResetBGMapMode
	call DisableLCD
	call LoadStandardFont
	call LoadFontsExtra
	call Pokedex_LoadGFX
	call Pokedex_LoadAnyFootprint
	ld a, [wTempSpecies]
	ld [wCurPartySpecies], a
	call Pokedex_DrawDexEntryScreenBG
	call Pokedex_DrawFootprint
	hlcoord 0, 17
	ld a, $3b
	ld [hli], a
	ld bc, 19
	ld a, " "
	rst ByteFill
	farcall DisplayDexEntry
	call EnableLCD
	call WaitBGMap
	call GetBaseData
	ld de, vTiles2
	predef GetMonFrontpic
	ld a, SCGB_POKEDEX
	call Pokedex_GetSGBLayout
	ld a, [wCurPartySpecies]
	jmp PlayMonCry

Pokedex_SetBGMapMode3:
	ld a, $3
	ldh [hBGMapMode], a
	ld c, 4
	jmp DelayFrames

Pokedex_SetBGMapMode4:
	ld a, $4
	ldh [hBGMapMode], a
	ld c, 4
	jmp DelayFrames

Pokedex_SetBGMapMode_3ifDMG_4ifCGB:
	ldh a, [hCGB]
	and a
	call nz, Pokedex_SetBGMapMode4
	jr Pokedex_SetBGMapMode3

Pokedex_ResetBGMapMode:
	xor a
	ldh [hBGMapMode], a
	ret

Pokedex_InitColorOption:
	xor a
	ldh [hBGMapMode], a
	call ClearSprites
	call Pokedex_DrawColorScreenBG
	call Pokedex_InitArrowCursor
	ld a, [wCurPokedexColor]
	ld [wDexArrowCursorPosIndex], a
	call WaitBGMap
	ld a, SCGB_POKEDEX_SEARCH_OPTION
	call Pokedex_GetSGBLayout
	jmp Pokedex_IncrementDexPointer
