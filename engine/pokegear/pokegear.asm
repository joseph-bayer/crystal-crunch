; Pokégear cards
	const_def
	const POKEGEARCARD_CLOCK ; 0
	const POKEGEARCARD_MAP   ; 1
	const POKEGEARCARD_PHONE ; 2
	const POKEGEARCARD_RADIO ; 3
DEF NUM_POKEGEAR_CARDS EQU const_value

DEF PHONE_DISPLAY_HEIGHT EQU 4
DEF PHONE_REMATCH_ICON_TILE EQU $5e ; the last two tiles of gfx/pokegear/pokegear.png

; PokegearJumptable.Jumptable indexes
	const_def
	const POKEGEARSTATE_CLOCKINIT       ; 0
	const POKEGEARSTATE_CLOCKJOYPAD     ; 1
	const POKEGEARSTATE_MAPCHECKREGION  ; 2
	const POKEGEARSTATE_JOHTOMAPINIT    ; 3
	const POKEGEARSTATE_JOHTOMAPJOYPAD  ; 4
	const POKEGEARSTATE_KANTOMAPINIT    ; 5
	const POKEGEARSTATE_KANTOMAPJOYPAD  ; 6
	const POKEGEARSTATE_PHONEINIT       ; 7
	const POKEGEARSTATE_PHONEJOYPAD     ; 8
	const POKEGEARSTATE_MAKEPHONECALL   ; 9
	const POKEGEARSTATE_FINISHPHONECALL ; a
	const POKEGEARSTATE_RADIOINIT       ; b
	const POKEGEARSTATE_RADIOJOYPAD     ; c

PokeGear:
	ld hl, wOptions
	ld a, [hl]
	push af
	set NO_TEXT_SCROLL, [hl]
	ldh a, [hInMenu]
	push af
	ld a, $1
	ldh [hInMenu], a
	ld a, [wStateFlags]
	push af
	xor a
	ld [wStateFlags], a
	ld [wDefaultSpawnpoint], a ; nonzero on the way out means the map queued a Fly
	call .InitTilemap
	call DelayFrame
.loop
	call UpdateTime
	call JoyTextDelay
	ld a, [wJumptableIndex]
	bit JUMPTABLE_EXIT_F, a
	jr nz, .done
	call PokegearJumptable
	farcall PlaySpriteAnimations
	ld a, [wPokegearCard]
	cp POKEGEARCARD_MAP
	jr nz, .no_map_trainers
	farcall MapTrainers_Draw ; the REMATCH and GIFTS views' icons, after the structs'
.no_map_trainers
	call DelayFrame
	jr .loop

.done
	ld de, SFX_READ_TEXT_2
	call PlaySFX
	call WaitSFX
	pop af
	ld [wStateFlags], a
	pop af
	ldh [hInMenu], a
	pop af
	ld [wOptions], a
	call ClearBGPalettes
	xor a ; LOW(vBGMap0)
	ldh [hBGMapAddress], a
	ld a, HIGH(vBGMap0)
	ldh [hBGMapAddress + 1], a
	ld a, SCREEN_HEIGHT_PX
	ldh [hWY], a
	jmp ExitPokegearRadio_HandleMusic

.InitTilemap:
	call ClearBGPalettes
	call ClearTilemap
	call ClearSprites
	call DisableLCD
	xor a
	ldh [hSCY], a
	ldh [hSCX], a
	ld a, $7
	ldh [hWX], a
	call Pokegear_LoadGFX
	farcall ClearSpriteAnims
	call InitPokegearModeIndicatorArrow
	ld a, 8
	call SkipMusic
	ld a, LCDC_DEFAULT
	ldh [rLCDC], a
	farcall LoadMapViewLabelGFX
	call TownMap_InitCursorAndPlayerIconPositions
	xor a
	ld [wJumptableIndex], a ; POKEGEARSTATE_CLOCKINIT
	ld [wPokegearCard], a ; POKEGEARCARD_CLOCK
	ld [wPokegearMapRegion], a ; JOHTO_REGION
	ld [wMapMonIconRegion], a
	ld [wMapRegionScroll], a ; MAP_SCROLL_NONE
	ld [wPokegearPhoneScrollPosition], a
	ld [wPokegearPhoneCursorPosition], a
	ld [wPokegearPhoneSelectedPerson], a
	ld [wPokegearRadioChannelBank], a
	ld [wPokegearRadioChannelAddr], a
	ld [wPokegearRadioChannelAddr + 1], a
	call Pokegear_InitJumptableIndices
	call InitPokegearTilemap
	ld b, SCGB_POKEGEAR_PALS
	call GetSGBLayout
	call SetDefaultBGPAndOBP
	ldh a, [hCGB]
	and a
	ret z
	ld a, %11100100
	jmp DmgToCgbObjPal0

Pokegear_LoadGFX:
	call ClearVBank1
	ld hl, TownMapGFX
	ld de, vTiles2
	ld a, BANK(TownMapGFX)
	call FarDecompress
	ld hl, PokegearGFX
	ld de, vTiles2 tile $30
	ld a, BANK(PokegearGFX)
	call FarDecompress
	ld hl, PokegearSpritesGFX
	ld de, vTiles0
	ld a, BANK(PokegearSpritesGFX)
	call Decompress
	ld a, [wMapGroup]
	ld b, a
	ld a, [wMapNumber]
	ld c, a
	call GetWorldMapLocation
	cp LANDMARK_FAST_SHIP
	jr z, .ssaqua
	farcall GetPlayerIcon
	push de
	ld h, d
	ld l, e
	ld a, b
	; standing sprite
	push af
	ld de, vTiles0 tile $10
	ld bc, 4 tiles
	call FarCopyBytes
	pop af
	pop hl
	; walking sprite
	ld de, 12 tiles
	add hl, de
	ld de, vTiles0 tile $14
	ld bc, 4 tiles
	jmp FarCopyBytes

.ssaqua
	ld hl, FastShipGFX
	ld de, vTiles0 tile $10
	ld bc, 8 tiles
	jmp CopyBytes

FastShipGFX:
INCBIN "gfx/pokegear/fast_ship.2bpp"

InitPokegearModeIndicatorArrow:
	depixel 4, 2, 4, 0
	ld a, SPRITE_ANIM_OBJ_POKEGEAR_ARROW
	call InitSpriteAnimStruct
	ld hl, SPRITEANIMSTRUCT_TILE_ID
	add hl, bc
	ld [hl], $0
	ret

AnimatePokegearModeIndicatorArrow:
	ld hl, wPokegearCard
	ld e, [hl]
	ld d, 0
	ld hl, .XCoords
	add hl, de
	ld a, [hl]
	ld hl, SPRITEANIMSTRUCT_XOFFSET
	add hl, bc
	ld [hl], a
	ret

.XCoords:
	db $00 ; POKEGEARCARD_CLOCK
	db $10 ; POKEGEARCARD_MAP
	db $20 ; POKEGEARCARD_PHONE
	db $30 ; POKEGEARCARD_RADIO

TownMap_GetCurrentLandmark:
	ld a, [wMapGroup]
	ld b, a
	ld a, [wMapNumber]
	ld c, a
	jmp GetWorldMapLocationOrBackup

TownMap_InitCursorAndPlayerIconPositions:
	ld a, [wMapGroup]
	ld b, a
	ld a, [wMapNumber]
	ld c, a
	call GetWorldMapLocationOrBackup
	cp LANDMARK_FAST_SHIP
	jr z, .FastShip
	ld [wPokegearMapPlayerIconLandmark], a
	ld [wPokegearMapCursorLandmark], a
	ret

.FastShip:
	ld [wPokegearMapPlayerIconLandmark], a
	ld a, LANDMARK_NEW_BARK_TOWN
	ld [wPokegearMapCursorLandmark], a
	ret

Pokegear_InitJumptableIndices:
	ld a, POKEGEARSTATE_CLOCKINIT
	ld [wJumptableIndex], a
	xor a ; POKEGEARCARD_CLOCK
	ld [wPokegearCard], a
	ret

InitPokegearTilemap:
	xor a
	ldh [hBGMapMode], a
	hlcoord 0, 0
	ld bc, SCREEN_AREA
	ld a, $4f
	rst ByteFill
	ld a, [wPokegearCard]
	maskbits NUM_POKEGEAR_CARDS
	add a
	ld e, a
	ld d, 0
	ld hl, .Jumptable
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call _hl_
	call Pokegear_FinishTilemap
	call TownMapPals
	ld a, [wPokegearCard]
	cp POKEGEARCARD_MAP
	jr nz, .no_view_label
	call PokegearMap_GetShownRegion
	farcall PlaceMapViewLabel ; after TownMapPals, which would undo its attributes
.no_view_label
	ld a, [wPokegearMapRegion]
	and a
	jr nz, .kanto_0
	xor a ; LOW(vBGMap0)
	ldh [hBGMapAddress], a
	ld a, HIGH(vBGMap0)
	ldh [hBGMapAddress + 1], a
	call .UpdateBGMap
	ld a, SCREEN_HEIGHT_PX
	jr .finish

.kanto_0
	xor a ; LOW(vBGMap1)
	ldh [hBGMapAddress], a
	ld a, HIGH(vBGMap1)
	ldh [hBGMapAddress + 1], a
	call .UpdateBGMap
	xor a
.finish
	push af
	farcall MapRegionScroll_Slide ; if START asked for it, slide the new map in first
	pop af
	ldh [hWY], a
	; swap region maps
	ld a, [wPokegearMapRegion]
	maskbits NUM_REGIONS
	xor 1
	ld [wPokegearMapRegion], a
	ret

.UpdateBGMap:
	ld a, [wMapRegionScroll]
	and a
	jr z, .no_scroll
	ld b, 0 ; leave the palettes be
	farcall _SafeCopyTilemapAtOnce ; all at once, so the slide starts sooner
	ld a, 1 ; and keep the BG map up to date after, as WaitBGMap leaves it
	ldh [hBGMapMode], a
	ret

.no_scroll
	ldh a, [hCGB]
	and a
	jr z, .dmg
	ld a, $2
	ldh [hBGMapMode], a
	ld c, 3
	call DelayFrames
.dmg
	jmp WaitBGMap

.Jumptable:
; entries correspond to POKEGEARCARD_* constants
	dw .Clock
	dw .Map
	dw .Phone
	dw .Radio

.Clock:
	ld de, ClockTilemapRLE
	call Pokegear_LoadTilemapRLE
	hlcoord 12, 1
	ld de, .switch
	rst PlaceString
	hlcoord 0, 12
	lb bc, 4, 18
	call Textbox
	jmp Pokegear_UpdateClock

.switch
	db " SWITCH▶@"

.Map:
	call PokegearMap_GetShownRegion
	ld e, a
	call PokegearMap
	ld a, $07
	ld bc, SCREEN_WIDTH - 2
	hlcoord 1, 2
	rst ByteFill
	hlcoord 0, 2
	ld [hl], $06
	hlcoord 19, 2
	ld [hl], $17
	ld a, [wPokegearMapCursorLandmark]
	jmp PokegearMap_UpdateLandmarkName

.Radio:
	ld de, RadioTilemapRLE
	call Pokegear_LoadTilemapRLE
	hlcoord 0, 12
	lb bc, 4, 18
	jmp Textbox

.Phone:
	ld de, PhoneTilemapRLE
	call Pokegear_LoadTilemapRLE
	hlcoord 0, 12
	lb bc, 4, 18
	call Textbox
	call .PlacePhoneBars
	jmp PokegearPhone_UpdateDisplayList

.PlacePhoneBars:
	hlcoord 17, 1
	ld a, $3c
	ld [hli], a
	inc a
	ld [hl], a
	hlcoord 17, 2
	inc a
	ld [hli], a
	call GetMapPhoneService
	and a
	ret nz
	hlcoord 18, 2
	ld [hl], $3f
	ret

Pokegear_FinishTilemap:
	hlcoord 0, 0
	ld bc, $8
	ld a, $4f
	rst ByteFill
	hlcoord 0, 1
	ld bc, $8
	ld a, $4f
	rst ByteFill
	ld de, wPokegearFlags
	ld a, [de]
	bit POKEGEAR_MAP_CARD_F, a
	call nz, .PlaceMapIcon
	ld a, [de]
	bit POKEGEAR_PHONE_CARD_F, a
	call nz, .PlacePhoneIcon
	ld a, [de]
	bit POKEGEAR_RADIO_CARD_F, a
	call nz, .PlaceRadioIcon
	hlcoord 0, 0
	ld a, $46
	jr .PlacePokegearCardIcon

.PlaceMapIcon:
	hlcoord 2, 0
	ld a, $40
	jr .PlacePokegearCardIcon

.PlacePhoneIcon:
	hlcoord 4, 0
	ld a, $44
	jr .PlacePokegearCardIcon

.PlaceRadioIcon:
	hlcoord 6, 0
	ld a, $42
.PlacePokegearCardIcon:
	ld [hli], a
	inc a
	ld [hld], a
	ld bc, $14
	add hl, bc
	add $f
	ld [hli], a
	inc a
	ld [hld], a
	ret

PokegearJumptable:
	jumptable .Jumptable, wJumptableIndex

.Jumptable:
; entries correspond to POKEGEARSTATE_* constants
	dw PokegearClock_Init
	dw PokegearClock_Joypad
	dw PokegearMap_CheckRegion
	dw PokegearMap_Init
	dw PokegearMap_JohtoMap
	dw PokegearMap_Init
	dw PokegearMap_KantoMap
	dw PokegearPhone_Init
	dw PokegearPhone_Joypad
	dw PokegearPhone_MakePhoneCall
	dw PokegearPhone_FinishPhoneCall
	dw PokegearRadio_Init
	dw PokegearRadio_Joypad

PokegearClock_Init:
	call InitPokegearTilemap
	ld hl, PokegearPressButtonText
	call PrintText
	ld hl, wJumptableIndex
	inc [hl]
	jmp ExitPokegearRadio_HandleMusic

PokegearClock_Joypad:
	call .UpdateClock
	ld hl, hJoyLast
	ld a, [hl]
	and PAD_BUTTONS
	jr nz, .quit
	ld a, [hl]
	and PAD_LEFT
	jr nz, .left
	ld a, [hl]
	and PAD_RIGHT
	ret z
	ld a, [wPokegearFlags]
	bit POKEGEAR_MAP_CARD_F, a
	jr z, .no_map_card
	lb bc, POKEGEARCARD_MAP, POKEGEARSTATE_MAPCHECKREGION
	jr .done

.no_map_card
	ld a, [wPokegearFlags]
	bit POKEGEAR_PHONE_CARD_F, a
	jr z, .no_phone_card
	lb bc, POKEGEARCARD_PHONE, POKEGEARSTATE_PHONEINIT
	jr .done

.no_phone_card
	ld a, [wPokegearFlags]
	bit POKEGEAR_RADIO_CARD_F, a
	ret z
	lb bc, POKEGEARCARD_RADIO, POKEGEARSTATE_RADIOINIT
.done
	jmp Pokegear_SwitchPage

.left
; Left on the clock wraps round to the last card owned.
	ld a, [wPokegearFlags]
	bit POKEGEAR_RADIO_CARD_F, a
	jr z, .left_no_radio_card
	lb bc, POKEGEARCARD_RADIO, POKEGEARSTATE_RADIOINIT
	jr .done

.left_no_radio_card
	ld a, [wPokegearFlags]
	bit POKEGEAR_PHONE_CARD_F, a
	jr z, .left_no_phone_card
	lb bc, POKEGEARCARD_PHONE, POKEGEARSTATE_PHONEINIT
	jr .done

.left_no_phone_card
	ld a, [wPokegearFlags]
	bit POKEGEAR_MAP_CARD_F, a
	ret z
	lb bc, POKEGEARCARD_MAP, POKEGEARSTATE_MAPCHECKREGION
	jr .done

.quit
	ld hl, wJumptableIndex
	set JUMPTABLE_EXIT_F, [hl]
	ret

.UpdateClock:
	xor a
	ldh [hBGMapMode], a
	call Pokegear_UpdateClock
	ld a, $1
	ldh [hBGMapMode], a
	ret

Pokegear_UpdateClock:
	hlcoord 3, 5
	lb bc, 5, 14
	call ClearBox
	ldh a, [hHours]
	ld b, a
	ldh a, [hMinutes]
	ld c, a
	decoord 6, 8
	farcall PrintHoursMins
	ld hl, .GearTodayText
	bccoord 6, 6
	jmp PrintTextboxTextAt

	db "ごぜん@"
	db "ごご@"

.GearTodayText:
	text_far _GearTodayText
	text_end

PokegearMap_CheckRegion:
; Coming to the map card, it opens on the player's region, in the SWARMS view. If START left the
; cursor on the other region, it comes back to the player.
	xor a ; MAP_VIEW_SWARMS
	ld [wMapIconView], a
	ld [wMapTrainersShownCount], a
	ld a, [wPokegearMapCursorLandmark]
	call PokegearMap_GetLandmarkRegion
	ld b, a
	ld a, [wPokegearMapPlayerIconLandmark]
	call PokegearMap_GetLandmarkRegion
	cp b
	push af
	call nz, TownMap_InitCursorAndPlayerIconPositions
	pop af
	assert JOHTO_REGION == 0
	and a
	ld a, POKEGEARSTATE_JOHTOMAPINIT
	jr z, .done
	ld a, POKEGEARSTATE_KANTOMAPINIT
.done
	ld [wJumptableIndex], a
	jmp ExitPokegearRadio_HandleMusic

PokegearMap_GetShownRegion:
; out: a = JOHTO_REGION or KANTO_REGION, the region the map card is on, which its jumptable state
; says. Preserves bc, de and hl.
	assert POKEGEARSTATE_JOHTOMAPINIT < POKEGEARSTATE_KANTOMAPINIT && \
		POKEGEARSTATE_JOHTOMAPJOYPAD < POKEGEARSTATE_KANTOMAPINIT && \
		POKEGEARSTATE_KANTOMAPJOYPAD > POKEGEARSTATE_KANTOMAPINIT
	ld a, [wJumptableIndex]
	cp POKEGEARSTATE_KANTOMAPINIT
	ld a, JOHTO_REGION
	ret c
	assert KANTO_REGION == JOHTO_REGION + 1
	inc a
	ret

PokegearMap_GetLandmarkRegion:
; in: a = a landmark
; out: a = JOHTO_REGION or KANTO_REGION. The Fast Ship counts as Johto, as the Pokegear always has.
; Preserves bc, de and hl.
	cp LANDMARK_FAST_SHIP
	jr z, .johto
	cp KANTO_LANDMARK
	jr c, .johto
	ld a, KANTO_REGION
	ret

.johto
	ld a, JOHTO_REGION
	ret

PokegearMap_Init:
	call InitPokegearTilemap
	call MapIcons_Reset
	; the player icon, if the player is on the region shown
	ld a, [wPokegearMapPlayerIconLandmark]
	call PokegearMap_GetLandmarkRegion
	ld b, a
	call PokegearMap_GetShownRegion
	cp b
	jr nz, .no_player_icon
	ld a, [wPokegearMapPlayerIconLandmark]
	call PokegearMap_InitPlayerIcon
	ld a, [wPokegearMapPlayerIconLandmark]
	call MapIcons_Add ; first in turn order
.no_player_icon
	ld a, [wPokegearMapCursorLandmark]
	call PokegearMap_InitCursor
	ld a, c
	ld [wPokegearMapCursorObjectPointer], a
	ld a, b
	ld [wPokegearMapCursorObjectPointer + 1], a
	call PokegearMap_InitMonIcons
	ld hl, wJumptableIndex
	inc [hl]
	ret

PokegearMap_InitMonIcons:
; The Pokegear map's icons: those of the view SELECT is on, for the card being shown. Also notes
; whether A on a visited town can fly there.
	call PokegearMap_GetShownRegion
	ld [wMapMonIconRegion], a
	call PokegearMap_CheckCanFly
	jr PlaceMapViewIcons

FlyMap_InitMonIcons:
; The Fly map's icons: the same views as the Pokegear map's, on the region the Fly map is showing.
; The arrow and the player icon are made first, so both draw over them. Runs again whenever the
; Fly map swaps region or view, which clears every sprite.
	call FlyMap_GetShownRegion
	ld [wMapMonIconRegion], a
PlaceMapViewIcons:
; The icons of the view SELECT is on, for the region in wMapMonIconRegion: swarms and roaming beasts,
; or trainers.
	xor a
	ld [wMapTrainersShownCount], a
	ld a, [wMapIconView]
	and a ; MAP_VIEW_SWARMS
	jr nz, .trainers
	call PlaceMapMonIcons
	jr ApplyMapMonIconPals

.trainers
	farcall MapTrainers_Place
ApplyMapMonIconPals:
	call MapIcons_Apply ; the first turn, before anything is drawn
	farcall ApplyOBPals ; the screen's palettes were pushed before the icons existed
	ld a, TRUE
	ldh [hCGBPalUpdate], a
	ret

PlaceMapMonIcons:
; Every active swarm on the region in wMapMonIconRegion gets its mon's icon over its landmark. Each
; wActiveSwarms slot draws into the icon slot of the same number, so an empty slot, or a swarm on
; the other region, just leaves its icon slot unused. Raikou and Entei follow in the two slots
; after those. The icons are made after the cursor, which puts them later in OAM, so the cursor
; and the player icon both draw over them.
	assert NUM_MAP_MON_ICONS >= MAX_ACTIVE_SWARMS + 2
	xor a
.loop
	push af
	farcall GetActiveSwarmIcon
	jr nc, .next
	ld a, e
	call .IsOnShownMap
	jr nc, .next
	pop af
	push af
	call PokegearMap_InitMonIcon
.next
	pop af
	inc a
	cp MAX_ACTIVE_SWARMS
	jr c, .loop

; Raikou and Entei, while they roam, in their stored form. Drawn after the swarms, so a swarm on the
; same route sits on top.
	ld a, [wRoamMon1Form]
	ld d, a
	ld a, [wRoamMon1MapGroup]
	ld b, a
	ld a, [wRoamMon1MapNumber]
	ld c, a
	ld a, [wRoamMon1Species]
	ld e, MAX_ACTIVE_SWARMS
	call .RoamerIcon
	ld a, [wRoamMon2Form]
	ld d, a
	ld a, [wRoamMon2MapGroup]
	ld b, a
	ld a, [wRoamMon2MapNumber]
	ld c, a
	ld a, [wRoamMon2Species]
	ld e, MAX_ACTIVE_SWARMS + 1
	; fallthrough

.RoamerIcon:
; in: a = a roamer's species ID, bc = its map, d = its form, e = the icon slot
; A roamer that isn't out (not yet released, or caught or defeated) has species 0.
	and a
	ret z
	push de
	call GetPokemonIndexFromID ; hl = the species index
	ld a, b
	cp GROUP_N_A
	jr z, .no_roamer_icon
	push hl
	call GetWorldMapLocation
	pop hl
	ld c, a ; its landmark
	call .IsOnShownMap
	jr nc, .no_roamer_icon
	pop de
	ld a, e ; the icon slot
	ld e, c
	jr PokegearMap_InitMonIcon

.no_roamer_icon
	pop de
	ret

.IsOnShownMap:
; in: a = a landmark
; out: carry if it is on the region whose icons are being drawn (wMapMonIconRegion).
; Preserves bc, de and hl.
	assert JOHTO_REGION == 0 && KANTO_REGION == 1
	cp KANTO_LANDMARK
	sbc a ; -1 for Johto, 0 for Kanto
	inc a ; JOHTO_REGION or KANTO_REGION
	push hl
	ld hl, wMapMonIconRegion
	cp [hl]
	pop hl
	scf
	ret z
	and a
	ret

PokegearMap_InitMonIcon:
; Put a mon's icon on the map, bobbing through both of its frames in its own colors: the swarms,
; and the roaming beasts.
; in: a = the icon slot (0 to NUM_MAP_MON_ICONS - 1), hl = species index, d = form byte,
;     e = landmark
	push de ; the landmark
	push af ; the slot
	ld a, d
	ld [wForm], a
	call GetPokemonIDFromIndex
	ld [wCurIcon], a

	pop af
	push af
	call .FirstTile
	farcall GetIcon_a ; both frames, reading wCurIcon and wForm

	pop af
	push af
	add MAP_MON_ICON_FIRST_PAL
	ld e, a
	ld bc, wForm
	ld a, [wCurIcon]
	farcall LoadMonIconOBPal

	pop af
	push af
	depixel 0, 0
	add SPRITE_ANIM_OBJ_MAP_MON_ICON_1 ; its frames carry the slot's palette
	call InitSpriteAnimStruct
	pop af
	call .FirstTile
	ld hl, SPRITEANIMSTRUCT_TILE_ID
	add hl, bc
	ld [hl], a

	pop de
	ld a, e
	call MapIcons_Add ; in the order they're made: swarm slots, then Raikou, then Entei
	push bc
	farcall GetLandmarkCoords
	pop bc
	ld hl, SPRITEANIMSTRUCT_XCOORD
	add hl, bc
	ld [hl], e
	ld hl, SPRITEANIMSTRUCT_YCOORD
	add hl, bc
	ld [hl], d
	ret

.FirstTile:
; a = the slot -> a = its first tile
	add a
	add a
	add a
	add MAP_MON_ICON_FIRST_TILE
	ret

PokegearMap_CheckCanFly:
; Whether A on a visited town flies there: the party could Fly from where the player stands.
	xor a
	ld [wPokegearMapCanFly], a
	farcall CanFlyFromMapScreen
	ret c
	ld a, TRUE
	ld [wPokegearMapCanFly], a
	ret

PokegearMap_GetFlySpawn:
; in: a = a landmark
; out: carry, and a = its spawn point, if it is a flypoint the player has visited
	ld b, a
	ld hl, Flypoints
.loop
	ld a, [hli]
	cp -1
	jr z, .no
	cp b
	ld a, [hli] ; its spawn point
	jr nz, .loop
	push af
	ld c, a
	call HasVisitedSpawn ; a = nonzero if visited
	and a
	jr z, .not_visited
	pop af
	scf
	ret

.not_visited
	pop af
.no
	and a
	ret

PokegearMap_KantoMap:
	call TownMap_GetKantoLandmarkLimits
	jr PokegearMap_ContinueMap

PokegearMap_JohtoMap:
	lb de, JOHTO_LANDMARK_LAST, JOHTO_LANDMARK
PokegearMap_ContinueMap:
	push de
	call MapIcons_Rotate
	farcall MapTrainers_Update
	pop de
	ldh a, [hJoyPressed]
	and PAD_SELECT
	jmp nz, PokegearMap_NextView
	ldh a, [hJoyPressed]
	and PAD_START
	jmp nz, PokegearMap_SwapRegion
	ld hl, hJoyLast
	ld a, [hl]
	and PAD_A
	jr nz, .fly
	ld a, [hl]
	and PAD_B
	jr nz, .cancel
	ld a, [hl]
	and PAD_RIGHT
	jr nz, .right
	ld a, [hl]
	and PAD_LEFT
	jr nz, .left
	jr .DPad

.right
	ld a, [wPokegearFlags]
	bit POKEGEAR_PHONE_CARD_F, a
	jr z, .no_phone
	lb bc, POKEGEARCARD_PHONE, POKEGEARSTATE_PHONEINIT
	jr .done

.no_phone
; With no card to the right, wrap round to the clock.
	ld a, [wPokegearFlags]
	bit POKEGEAR_RADIO_CARD_F, a
	jr z, .left
	lb bc, POKEGEARCARD_RADIO, POKEGEARSTATE_RADIOINIT
	jr .done

.left
	lb bc, POKEGEARCARD_CLOCK, POKEGEARSTATE_CLOCKINIT
.done
	jmp Pokegear_SwitchPage

.fly
; A on a visited town flies there at once, as Polished Crystal does: queue the party menu Fly's own
; script and leave. StartMenu_Pokegear sees wDefaultSpawnpoint set and closes every menu to run it.
	ld a, [wPokegearMapCanFly]
	and a
	ret z
	ld a, [wPokegearMapCursorLandmark]
	call PokegearMap_GetFlySpawn
	ret nc
	ld [wDefaultSpawnpoint], a
	ld a, BANK(FlyFunction.FlyScript)
	ld hl, FlyFunction.FlyScript
	call FarQueueScript
	; fallthrough

.cancel
	ld hl, wJumptableIndex
	set JUMPTABLE_EXIT_F, [hl]
	ret

.DPad:
	ld hl, hJoyLast
	ld a, [hl]
	and PAD_UP
	jr nz, .up
	ld a, [hl]
	and PAD_DOWN
	jr nz, .down
	ret

.up
	ld hl, wPokegearMapCursorLandmark
	ld a, [hl]
	cp d
	jr c, .wrap_around_up
	ld a, e
	dec a
	ld [hl], a
.wrap_around_up
	inc [hl]
	jr .done_dpad

.down
	ld hl, wPokegearMapCursorLandmark
	ld a, [hl]
	cp e
	jr nz, .wrap_around_down
	ld a, d
	inc a
	ld [hl], a
.wrap_around_down
	dec [hl]
.done_dpad
	ld a, [wPokegearMapCursorLandmark]
	call PokegearMap_UpdateLandmarkName
	ld a, [wPokegearMapCursorObjectPointer]
	ld c, a
	ld a, [wPokegearMapCursorObjectPointer + 1]
	ld b, a
	ld a, [wPokegearMapCursorLandmark]
	jr PokegearMap_UpdateCursorPosition

PokegearMap_InitPlayerIcon:
	push af
	depixel 0, 0
	ld b, SPRITE_ANIM_OBJ_RED_WALK
	ld a, [wPlayerGender]
	bit PLAYERGENDER_FEMALE_F, a
	jr z, .got_gender
	ld b, SPRITE_ANIM_OBJ_BLUE_WALK
.got_gender
	ld a, b
	call InitSpriteAnimStruct
	ld hl, SPRITEANIMSTRUCT_TILE_ID
	add hl, bc
	ld [hl], $10
	pop af
	ld e, a
	push bc
	farcall GetLandmarkCoords
	pop bc
	ld hl, SPRITEANIMSTRUCT_XCOORD
	add hl, bc
	ld [hl], e
	ld hl, SPRITEANIMSTRUCT_YCOORD
	add hl, bc
	ld [hl], d
	ret

PokegearMap_InitCursor:
	push af
	call InitMapArrowCursor
	pop af
	push bc
	call PokegearMap_UpdateCursorPosition
	pop bc
	ret

InitMapArrowCursor:
; The Pokegear's arrow, for its map and for the Fly map. Placed by the caller.
; out: bc = its sprite anim struct
	depixel 0, 0
	ld a, SPRITE_ANIM_OBJ_POKEGEAR_ARROW
	call InitSpriteAnimStruct
	ld hl, SPRITEANIMSTRUCT_TILE_ID
	add hl, bc
	ld [hl], $04
	ld hl, SPRITEANIMSTRUCT_ANIM_SEQ_ID
	add hl, bc
	ld [hl], SPRITE_ANIM_FUNC_NULL
	ret

PokegearMap_UpdateLandmarkName:
	push af
	hlcoord 8, 0
	lb bc, 2, 12
	call ClearBox
	pop af
	ld e, a
	push de
	farcall GetLandmarkName
	pop de
	farcall TownMap_ConvertLineBreakCharacters
	hlcoord 8, 0
	ld [hl], $34
	ret

PokegearMap_UpdateCursorPosition:
	push bc
	ld e, a
	farcall GetLandmarkCoords
	pop bc
	ld hl, SPRITEANIMSTRUCT_XCOORD
	add hl, bc
	ld [hl], e
	ld hl, SPRITEANIMSTRUCT_YCOORD
	add hl, bc
	ld [hl], d
	ret

PokegearMap_NextView:
; SELECT shows the next view: SWARMS, REMATCH, GIFTS, then SWARMS again.
	ld a, [wMapIconView]
	inc a
	cp NUM_MAP_VIEWS
	jr c, .got_view
	xor a ; MAP_VIEW_SWARMS
.got_view
	ld [wMapIconView], a
	call PokegearMap_GetShownRegion
	jr PokegearMap_Redraw

PokegearMap_SwapRegion:
; START swaps regions, once Indigo Plateau has been visited, as on the Fly map. The cursor goes to the
; player on the player's region, else to the region's first landmark.
	ld c, SPAWN_INDIGO
	call HasVisitedSpawn
	and a
	ret z
	call PokegearMap_GetShownRegion
	assert JOHTO_REGION == 0 && KANTO_REGION == 1
	xor 1 ; the other region
	ld b, a
	ld a, [wPokegearMapPlayerIconLandmark]
	cp LANDMARK_FAST_SHIP
	jr z, .first_landmark ; the cursor never rests on the ship
	call PokegearMap_GetLandmarkRegion
	cp b
	ld a, [wPokegearMapPlayerIconLandmark]
	jr z, .got_cursor
.first_landmark
	ld a, b
	and a ; JOHTO_REGION
	ld a, JOHTO_LANDMARK
	jr z, .got_cursor
	push bc
	call TownMap_GetKantoLandmarkLimits ; e = the first landmark the cursor reaches
	pop bc
	ld a, e
.got_cursor
	ld [wPokegearMapCursorLandmark], a
	; the new region slides in: Kanto from the right, Johto from the left, below the card tabs and
	; landmark name (the map's top edge, row 2, slides with it)
	assert JOHTO_REGION == 0 && KANTO_REGION == 1
	assert MAP_SCROLL_FROM_LEFT == 1 && MAP_SCROLL_FROM_RIGHT == 2
	ld a, b
	inc a ; MAP_SCROLL_FROM_LEFT to Johto, MAP_SCROLL_FROM_RIGHT to Kanto
	ld [wMapRegionScroll], a
	ld a, 2
	ld [wMapScrollHeaderRows], a
	push bc
	farcall MapRegionScroll_Prepare
	pop bc
	; it may have moved the old map to the other BG map: draw next into the one not on screen
	ldh a, [hWY]
	and a
	jr z, .got_bg_map ; 0, BG Map 0, when the window (BG Map 1) is on screen
	ld a, 1
.got_bg_map
	ld [wPokegearMapRegion], a
	ld a, b
PokegearMap_Redraw:
; a = the region to show; Pokegear_SwitchPage plays the card-switch sound
	and a ; JOHTO_REGION
	ld c, POKEGEARSTATE_JOHTOMAPINIT
	jr z, .got_state
	ld c, POKEGEARSTATE_KANTOMAPINIT
.got_state
	xor a
	ld [wMapTrainersShownCount], a
	ld b, POKEGEARCARD_MAP
	jmp Pokegear_SwitchPage

TownMap_GetKantoLandmarkLimits:
	ld a, [wStatusFlags]
	bit STATUSFLAGS_HALL_OF_FAME_F, a
	jr z, .not_hof
	lb de, KANTO_LANDMARK_LAST, KANTO_LANDMARK
	ret

.not_hof
	lb de, LANDMARK_ROUTE_28, LANDMARK_VICTORY_ROAD
	ret

PokegearRadio_Init:
	call InitPokegearTilemap
	depixel 4, 10, 4, 4
	ld a, SPRITE_ANIM_OBJ_RADIO_TUNING_KNOB
	call InitSpriteAnimStruct
	ld hl, SPRITEANIMSTRUCT_TILE_ID
	add hl, bc
	ld [hl], $08
	call UpdateRadioStation
	ld hl, wJumptableIndex
	inc [hl]
	ret

PokegearRadio_Joypad:
	ld hl, hJoyLast
	ld a, [hl]
	and PAD_B
	jr nz, .cancel
	ld a, [hl]
	and PAD_LEFT
	jr nz, .left
	ld a, [hl]
	and PAD_RIGHT
	jr nz, .no_map ; the radio is the last card, so Right wraps round to the clock
	ld hl, wPokegearRadioChannelAddr
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wPokegearRadioChannelBank]
	and a
	ret z
	jmp FarCall_hl

.left
	ld a, [wPokegearFlags]
	bit POKEGEAR_PHONE_CARD_F, a
	jr z, .no_phone
	lb bc, POKEGEARCARD_PHONE, POKEGEARSTATE_PHONEINIT
	jr .switch_page

.no_phone
	ld a, [wPokegearFlags]
	bit POKEGEAR_MAP_CARD_F, a
	jr z, .no_map
	lb bc, POKEGEARCARD_MAP, POKEGEARSTATE_MAPCHECKREGION
	jr .switch_page

.no_map
	lb bc, POKEGEARCARD_CLOCK, POKEGEARSTATE_CLOCKINIT
.switch_page
	jmp Pokegear_SwitchPage

.cancel
	ld hl, wJumptableIndex
	set JUMPTABLE_EXIT_F, [hl]
	ret

PokegearPhone_Init:
	ld hl, wJumptableIndex
	inc [hl]
	xor a
	ld [wPokegearPhoneScrollPosition], a
	ld [wPokegearPhoneCursorPosition], a
	ld [wPokegearPhoneSelectedPerson], a
	call PokegearPhone_CountSetBits
	dec a
	ld [wPokegearPhoneMaxContact], a
	call InitPokegearTilemap
	call ExitPokegearRadio_HandleMusic
	ld hl, PokegearAskWhoCallText
	jmp PrintText

PokegearPhone_Joypad:
	ld hl, hJoyPressed
	ld a, [hl]
	and PAD_B
	jr nz, .b
	ld a, [hl]
	and PAD_A
	jr nz, .a
	ld hl, hJoyLast
	ld a, [hl]
	and PAD_LEFT
	jr nz, .left
	ld a, [hl]
	and PAD_RIGHT
	jr nz, .right
	jmp PokegearPhone_GetDPad

.left
	ld a, [wPokegearFlags]
	bit POKEGEAR_MAP_CARD_F, a
	jr z, .no_map
	lb bc, POKEGEARCARD_MAP, POKEGEARSTATE_MAPCHECKREGION
	jr .switch_page

.no_map
	lb bc, POKEGEARCARD_CLOCK, POKEGEARSTATE_CLOCKINIT
	jr .switch_page

.right
; With no radio card, wrap round to the clock.
	ld a, [wPokegearFlags]
	bit POKEGEAR_RADIO_CARD_F, a
	jr z, .no_map
	lb bc, POKEGEARCARD_RADIO, POKEGEARSTATE_RADIOINIT
.switch_page
	jmp Pokegear_SwitchPage

.b
	ld hl, wJumptableIndex
	set JUMPTABLE_EXIT_F, [hl]
	ret

.a
	call PokegearPhone_GetCellNumber
	ld a, c
	and a
	ret z
	ld [wPokegearPhoneSelectedPerson], a
	hlcoord 1, 4
	ld a, [wPokegearPhoneCursorPosition]
	ld bc, SCREEN_WIDTH * 2
	rst AddNTimes
	ld [hl], "▷"
	call PokegearPhoneContactSubmenu
	jr c, .quit_submenu
	ld hl, wJumptableIndex
	inc [hl]
	ret

.quit_submenu
	ld a, POKEGEARSTATE_PHONEJOYPAD
	ld [wJumptableIndex], a
	ret

PokegearPhone_MakePhoneCall:
	call GetMapPhoneService
	and a
	jr nz, .no_service
	ld hl, wOptions
	res NO_TEXT_SCROLL, [hl]
	xor a
	ldh [hInMenu], a
	ld de, SFX_CALL
	call PlaySFX
	ld hl, .GearEllipseText
	call PrintText
	call WaitSFX
	ld de, SFX_CALL
	call PlaySFX
	ld hl, .GearEllipseText
	call PrintText
	call WaitSFX
	ld a, [wPokegearPhoneSelectedPerson]
	ld b, a
	call MakePhoneCallFromPokegear
	ld c, 10
	call DelayFrames
	ld hl, wOptions
	set NO_TEXT_SCROLL, [hl]
	ld a, $1
	ldh [hInMenu], a
	; the call may have set up a rematch, so the VS icon may go
	xor a
	ldh [hBGMapMode], a
	call PokegearPhone_UpdateDisplayList
	call PokegearPhone_ApplyTilemap
	ld hl, wJumptableIndex
	inc [hl]
	ret

.no_service
	call Phone_NoSignal
	ld hl, .GearOutOfServiceText
	call PrintText
	ld a, POKEGEARSTATE_PHONEJOYPAD
	ld [wJumptableIndex], a
	ld hl, PokegearAskWhoCallText
	jmp PrintText

.GearEllipseText:
	text_far _GearEllipseText
	text_end

.GearOutOfServiceText:
	text_far _GearOutOfServiceText
	text_end

PokegearPhone_FinishPhoneCall:
	ldh a, [hJoyPressed]
	and PAD_A | PAD_B
	ret z
	call HangUp
	ld a, POKEGEARSTATE_PHONEJOYPAD
	ld [wJumptableIndex], a
	ld hl, PokegearAskWhoCallText
	jmp PrintText

PokegearPhone_GetDPad:
	ld hl, hJoyLast
	ld a, [hl]
	and PAD_UP
	jr nz, .up
	ld a, [hl]
	and PAD_DOWN
	jr nz, .down
	ret

.up
	ld hl, wPokegearPhoneCursorPosition
	ld a, [hl]
	and a
	jr z, .scroll_page_up
	dec [hl]
	jr .done_joypad_same_page

.scroll_page_up
	ld hl, wPokegearPhoneScrollPosition
	ld a, [hl]
	and a
	ret z
	dec [hl]
	jr .done_joypad_update_page

.down
	; Stop at the last contact.
	ld hl, wPokegearPhoneCursorPosition
	ld a, [wPokegearPhoneMaxContact]
	ld b, a
	ld a, [wPokegearPhoneScrollPosition]
	add [hl]
	cp b
	ret nc
	ld a, [hl]
	cp PHONE_DISPLAY_HEIGHT - 1
	jr nc, .scroll_page_down
	inc [hl]
	jr .done_joypad_same_page

.scroll_page_down
	; The furthest scroll is (number of contacts) - PHONE_DISPLAY_HEIGHT.
	ld hl, wPokegearPhoneScrollPosition
	ld a, [wPokegearPhoneMaxContact]
	sub PHONE_DISPLAY_HEIGHT - 1
	ret c
	cp [hl]
	ret z
	inc [hl]
	jr .done_joypad_update_page

.done_joypad_same_page
	xor a
	ldh [hBGMapMode], a
	call PokegearPhone_UpdateCursor
	jmp WaitBGMap

.done_joypad_update_page
	xor a
	ldh [hBGMapMode], a
	call PokegearPhone_UpdateDisplayList
	jr PokegearPhone_ApplyTilemap

PokegearPhone_UpdateCursor:
	ld a, " "
for y, PHONE_DISPLAY_HEIGHT
	hlcoord 1, 4 + y * 2
	ld [hl], a
endr
	hlcoord 1, 4
	ld a, [wPokegearPhoneCursorPosition]
	ld bc, 2 * SCREEN_WIDTH
	rst AddNTimes
	ld [hl], "▶"
	ret

PokegearPhone_UpdateDisplayList:
	hlcoord 1, 3
	ld b, PHONE_DISPLAY_HEIGHT * 2 + 1
	ld a, " "
.row
	ld c, SCREEN_WIDTH - 2
.col
	ld [hli], a
	dec c
	jr nz, .col
	inc hl
	inc hl
	dec b
	jr nz, .row
	ld a, [wPokegearPhoneScrollPosition]
	ld e, a
	xor a
	ld [wPokegearPhoneDisplayPosition], a
.loop
	push de
	call PokegearPhone_GetCellNumberFromE
	push bc
	ld d, c
	hlcoord 2, 4
	ld a, [wPokegearPhoneDisplayPosition]
	ld bc, 2 * SCREEN_WIDTH
	rst AddNTimes
	ld b, d
	ld d, h
	ld e, l
	call GetCallerClassAndName
	pop bc
	call PokegearPhone_PlaceRematchIcon
	pop de
	inc e
	ld a, [wPokegearPhoneDisplayPosition] ; no-optimize Inefficient WRAM increment/decrement
	inc a
	ld [wPokegearPhoneDisplayPosition], a
	cp PHONE_DISPLAY_HEIGHT
	jr c, .loop
	jr PokegearPhone_UpdateCursor

PokegearPhone_PlaceRematchIcon:
; The VS icon at the end of contact c's name row, if calling them today would set up a rematch.
	call PhoneContactHasRematchDay
	ret nc
	hlcoord 17, 4
	ld a, [wPokegearPhoneDisplayPosition]
	ld bc, 2 * SCREEN_WIDTH
	rst AddNTimes
	ld a, PHONE_REMATCH_ICON_TILE
	ld [hli], a
	inc a
	ld [hl], a
	ret

PokegearPhone_ApplyTilemap:
; Tiles and attributes together, so the VS icon keeps its colors when the list or a menu over it
; redraws. Then WaitBGMap, as before.
	call TownMapPals
	ld b, 0 ; leave the palettes be
	farcall _SafeCopyTilemapAtOnce
	jmp WaitBGMap

PokegearPhone_DeletePhoneNumber:
	call PokegearPhone_GetCellNumber
	call DelCellNum
	ld hl, wPokegearPhoneMaxContact
	dec [hl]
	; If the list was scrolled and its last page is now short, scroll up one.
	ld a, [hl]
	inc a
	ld b, a ; number of contacts
	ld a, [wPokegearPhoneScrollPosition]
	and a
	ret z
	add PHONE_DISPLAY_HEIGHT - 1
	cp b
	ret c
	sub PHONE_DISPLAY_HEIGHT
	ld [wPokegearPhoneScrollPosition], a
	ret

PokegearPhone_GetCellNumber:
; Returns in c the contact under the cursor, or 0 for a blank row.
	ld a, [wPokegearPhoneScrollPosition]
	ld e, a
	ld a, [wPokegearPhoneCursorPosition]
	add e
	ld e, a
	; fallthrough
PokegearPhone_GetCellNumberFromE:
; Returns in c the e-th registered contact (counting from 0), or 0 if there are fewer.
	inc e
	call PokegearPhone_CountSetBits
	cp e
	ld c, 0
	ret c
.loop
	inc c
	call CheckCellNum
	jr z, .loop
	dec e
	jr nz, .loop
	ret

PokegearPhone_CountSetBits:
; Returns the number of registered contacts in a. Preserves de.
	push de
	ld hl, wPhoneList
	ld b, wPhoneListEnd - wPhoneList
	call CountSetBits
	pop de
	ret

PokegearPhoneContactSubmenu:
	call PokegearPhone_GetCellNumber
	call CheckCanDeletePhoneNumber
	ld a, c
	and a
	jr z, .cant_delete
	ld hl, .CallDeleteCancelJumptable
	ld de, .CallDeleteCancelStrings
	jr .got_menu_data

.cant_delete
	ld hl, .CallCancelJumptable
	ld de, .CallCancelStrings
.got_menu_data
	xor a
	ldh [hBGMapMode], a
	push hl
	push de
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	push hl
	bccoord -1, -2, 0
	add hl, bc
	ld a, [de]
	inc de
	add a
	ld b, a
	ld c, 8
	push de
	call Textbox
	pop de
	pop hl
	inc hl
	rst PlaceString
	pop de
	xor a
	ld [wPokegearPhoneSubmenuCursor], a
	call .UpdateCursor
; de points at the menu's strings, which moving the cursor reads; applying the tilemap clobbers it.
	push de
	call PokegearPhone_ApplyTilemap
	pop de
.loop
	push de
	call JoyTextDelay
	pop de
	ld hl, hJoyPressed
	ld a, [hl]
	and PAD_UP
	jr nz, .d_up
	ld a, [hl]
	and PAD_DOWN
	jr nz, .d_down
	ld a, [hl]
	and PAD_A | PAD_B
	jr nz, .a_b
	call DelayFrame
	jr .loop

.d_up
	ld hl, wPokegearPhoneSubmenuCursor
	ld a, [hl]
	and a
	jr z, .loop
	dec [hl]
	call .UpdateCursor
	jr .loop

.d_down
	ld hl, 2
	add hl, de
	ld a, [wPokegearPhoneSubmenuCursor]
	inc a
	cp [hl]
	jr nc, .loop
	ld [wPokegearPhoneSubmenuCursor], a
	call .UpdateCursor
	jr .loop

.a_b
	xor a
	ldh [hBGMapMode], a
	call PokegearPhone_UpdateDisplayList
	call PokegearPhone_ApplyTilemap
	pop hl
	ldh a, [hJoyPressed]
	and PAD_B
	jr nz, .Cancel
	ld a, [wPokegearPhoneSubmenuCursor]
	ld e, a
	ld d, 0
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

.Cancel:
	ld hl, PokegearAskWhoCallText
	call PrintText
	scf
	ret

.Delete:
	ld hl, PokegearAskDeleteText
	call MenuTextbox
; The YES/NO box covers the VS icons of the lower contacts, and a menu redraws tiles alone, so it
; would keep their colors. Its area takes the box's colors first.
	call TownMapPals
	hlcoord SCREEN_WIDTH - 6, 7, wAttrmap
	lb bc, 5, 6
	xor a
	call FillBoxWithByte
	ld b, 0 ; leave the palettes be
	farcall _SafeCopyTilemapAtOnce
	call WaitBGMap
	call YesNoBox
	call ExitMenu
	jr c, .CancelDelete
	call PokegearPhone_DeletePhoneNumber
	xor a
	ldh [hBGMapMode], a
	call PokegearPhone_UpdateDisplayList
	ld hl, PokegearAskWhoCallText
	call PrintText
.CancelDelete:
; The icons' colors back, where the box was.
	call PokegearPhone_ApplyTilemap
	scf
	ret

.Call:
	and a
	ret

.UpdateCursor:
	push de
	ld a, [de]
	inc de
	ld l, a
	ld a, [de]
	inc de
	ld h, a
	ld a, [de]
	ld c, a
	push hl
	ld a, " "
	ld de, SCREEN_WIDTH * 2
.clear_column
	ld [hl], a
	add hl, de
	dec c
	jr nz, .clear_column
	pop hl
	ld a, [wPokegearPhoneSubmenuCursor]
	ld bc, SCREEN_WIDTH  * 2
	rst AddNTimes
	ld [hl], "▶"
	pop de
	ret

.CallDeleteCancelStrings:
	dwcoord 10, 6
	db 3
	db   "CALL"
	next "DELETE"
	next "CANCEL"
	db   "@"

.CallDeleteCancelJumptable:
	dw .Call
	dw .Delete
	dw .Cancel

.CallCancelStrings:
	dwcoord 10, 8
	db 2
	db   "CALL"
	next "CANCEL"
	db   "@"

.CallCancelJumptable:
	dw .Call
	dw .Cancel

Pokegear_SwitchPage:
	ld de, SFX_READ_TEXT_2
	call PlaySFX
	ld a, c
	ld [wJumptableIndex], a
	ld a, b
	ld [wPokegearCard], a
	jr DeleteSpriteAnimStruct2ToEnd

ExitPokegearRadio_HandleMusic:
	ld a, [wPokegearRadioMusicPlaying]
	cp RESTART_MAP_MUSIC
	jr z, .restart_map_music
	cp ENTER_MAP_MUSIC
	call z, PlayMapMusicBike
	xor a
	ld [wPokegearRadioMusicPlaying], a
	ret

.restart_map_music
	call RestartMapMusic
	xor a
	ld [wPokegearRadioMusicPlaying], a
	ret

DeleteSpriteAnimStruct2ToEnd:
	ld hl, wSpriteAnim2
	ld bc, wSpriteAnimationStructsEnd - wSpriteAnim2
	xor a
	rst ByteFill
	ld a, 2
	ld [wSpriteAnimCount], a
	ret

Pokegear_LoadTilemapRLE:
	; Format: repeat count, tile ID
	; Terminated with -1
	hlcoord 0, 0
.loop
	ld a, [de]
	cp -1
	ret z
	ld b, a
	inc de
	ld a, [de]
	ld c, a
	inc de
	ld a, b
.load
	ld [hli], a
	dec c
	jr nz, .load
	jr .loop

PokegearAskWhoCallText:
	text_far _PokegearAskWhoCallText
	text_end

PokegearPressButtonText:
	text_far _PokegearPressButtonText
	text_end

PokegearAskDeleteText:
	text_far _PokegearAskDeleteText
	text_end

PokegearSpritesGFX:
INCBIN "gfx/pokegear/pokegear_sprites.2bpp.lz"

RadioTilemapRLE:
INCBIN "gfx/pokegear/radio.tilemap.rle"
PhoneTilemapRLE:
INCBIN "gfx/pokegear/phone.tilemap.rle"
ClockTilemapRLE:
INCBIN "gfx/pokegear/clock.tilemap.rle"

AnimateTuningKnob:
	push bc
	call .TuningKnob
	pop bc
	ld a, [wRadioTuningKnob]
	ld hl, SPRITEANIMSTRUCT_XOFFSET
	add hl, bc
	ld [hl], a
	ret

.TuningKnob:
	ld hl, hJoyLast
	ld a, [hl]
	and PAD_DOWN
	jr nz, .down
	ld a, [hl]
	and PAD_UP
	jr nz, .up
	ret

.down
	ld hl, wRadioTuningKnob
	ld a, [hl]
	and a
	ret z
	dec [hl]
	dec [hl]
	jr .update

.up
	ld hl, wRadioTuningKnob
	ld a, [hl]
	cp 80
	ret nc
	inc [hl]
	inc [hl]
.update
UpdateRadioStation:
	ld hl, wRadioTuningKnob
	ld d, [hl]
	ld hl, RadioChannels
.loop
	ld a, [hli]
	cp -1
	jr z, .nostation
	cp d
	jr z, .foundstation
	inc hl
	inc hl
	jr .loop

.nostation
	jmp NoRadioStation

.foundstation
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call _hl_
	ld a, [wPokegearRadioChannelBank]
	and a
	ret z
	xor a
	ldh [hBGMapMode], a
	hlcoord 2, 9
	rst PlaceString
	ld a, $1
	ldh [hBGMapMode], a
	ret

RadioChannels:
; entries correspond to constants/radio_constants.asm
; frequency value given here = 4 × ingame_frequency − 2
	dbw 16, .PKMNTalkAndPokedexShow ; 04.5
	dbw 28, .PokemonMusic           ; 07.5
	dbw 32, .LuckyChannel           ; 08.5
	dbw 40, .BuenasPassword         ; 10.5
	dbw 48, LoadStation_SwarmRadio  ; 12.5, nationwide
	dbw 52, .RuinsOfAlphRadio       ; 13.5
	dbw 64, .PlacesAndPeople        ; 16.5
	dbw 72, .LetsAllSing            ; 18.5
	dbw 78, .PokeFluteRadio         ; 20.0
	dbw 80, .EvolutionRadio         ; 20.5
	db -1

.PKMNTalkAndPokedexShow:
; Pokédex Show in the morning
; Oak's Pokémon Talk in the afternoon and evening
	call .InJohto
	jr nc, .NoSignal
	ld a, [wTimeOfDay]
	and a
	jmp z, LoadStation_PokedexShow
	jmp LoadStation_OaksPokemonTalk

.PokemonMusic:
	call .InJohto
	jr nc, .NoSignal
	jmp LoadStation_PokemonMusic

.LuckyChannel:
	call .InJohto
	jr nc, .NoSignal
	jmp LoadStation_LuckyChannel

.BuenasPassword:
	call .InJohto
	jr nc, .NoSignal
	jmp LoadStation_BuenasPassword

.RuinsOfAlphRadio:
	ld a, [wPokegearMapPlayerIconLandmark]
	cp LANDMARK_RUINS_OF_ALPH
	jr nz, .NoSignal
	jmp LoadStation_UnownRadio

.PlacesAndPeople:
	call .InJohto
	jr c, .NoSignal
	ld a, [wPokegearFlags]
	bit POKEGEAR_EXPN_CARD_F, a
	jr z, .NoSignal
	jmp LoadStation_PlacesAndPeople

.LetsAllSing:
	call .InJohto
	jr c, .NoSignal
	ld a, [wPokegearFlags]
	bit POKEGEAR_EXPN_CARD_F, a
	jr z, .NoSignal
	jmp LoadStation_LetsAllSing

.PokeFluteRadio:
	call .PokeFluteInRange
	jr nc, .NoSignal
	ld a, [wPokegearFlags]
	bit POKEGEAR_EXPN_CARD_F, a
	jr z, .NoSignal
	jmp LoadStation_PokeFluteRadio

.EvolutionRadio:
; This station airs in the Lake of Rage area when Team Rocket is still in Mahogany.
	ld a, [wStatusFlags]
	bit STATUSFLAGS_ROCKET_SIGNAL_F, a
	jr z, .NoSignal
	ld a, [wPokegearMapPlayerIconLandmark]
	cp LANDMARK_MAHOGANY_TOWN
	jr z, .ok
	cp LANDMARK_ROUTE_43
	jr z, .ok
	cp LANDMARK_LAKE_OF_RAGE
	jr nz, .NoSignal
.ok
	jmp LoadStation_EvolutionRadio

.NoSignal:
	jmp NoRadioStation

.InJohto:
; if in Johto or on the S.S. Aqua, set carry
; otherwise clear carry
	ld a, [wPokegearMapPlayerIconLandmark]
	cp LANDMARK_FAST_SHIP
	jr z, .johto
	cp KANTO_LANDMARK
	jr c, .johto
; kanto
	and a
	ret

.johto
	scf
	ret

.PokeFluteInRange:
; Carry if the Poke Flute broadcast reaches here: anywhere in Kanto, as before, and the mystery
; islands, which get this one station the way the Ruins of Alph and Lake of Rage get theirs. It is
; the broadcast that wakes the Snorlax asleep in the Apricorn Forest clearing, and the expansion
; card is still required either way, so the Snorlax stays behind Kanto.
;
; This and the two routines it calls sit after .NoSignal on purpose: putting them any earlier
; pushes .NoSignal out of jr range for the channels above.
	call .OnMysteryIsland
	ret c
	call .InJohto
	ccf ; in range exactly when not in Johto
	ret

.OnMysteryIsland:
; Carry if the player is on one of the islands the Cianwood sailor visits. The outdoor islands are
; a map group of their own; the Apricorn Forest and its clearing sit in the dungeons group instead,
; so they are picked out by their hidden landmarks, which nothing else uses.
; wPokegearMapPlayerIconLandmark is no help here -- on any of these maps it answers with the
; mainland map that was sailed from.
	ld a, [wMapGroup]
	ld b, a
	cp MAPGROUP_MYSTERY_ISLANDS
	jr z, .on_mystery_island
	ld a, [wMapNumber]
	ld c, a
	call GetWorldMapLocation
	cp HIDDEN_LANDMARK
	jr c, .not_on_mystery_island

.on_mystery_island
	scf
	ret

.not_on_mystery_island
	and a
	ret

LoadStation_OaksPokemonTalk:
	xor a ; OAKS_POKEMON_TALK
	ld [wCurRadioLine], a
	ld [wNumRadioLinesPrinted], a
	ld a, BANK(PlayRadioShow)
	ld hl, PlayRadioShow
	call Radio_BackUpFarCallParams
	ld de, OaksPKMNTalkName
	ret

LoadStation_PokedexShow:
	ld a, POKEDEX_SHOW
	ld [wCurRadioLine], a
	xor a
	ld [wNumRadioLinesPrinted], a
	ld a, BANK(PlayRadioShow)
	ld hl, PlayRadioShow
	call Radio_BackUpFarCallParams
	ld de, PokedexShowName
	ret

LoadStation_PokemonMusic:
	ld a, POKEMON_MUSIC
	ld [wCurRadioLine], a
	xor a
	ld [wNumRadioLinesPrinted], a
	ld a, BANK(PlayRadioShow)
	ld hl, PlayRadioShow
	call Radio_BackUpFarCallParams
	ld de, PokemonMusicName
	ret

LoadStation_LuckyChannel:
	ld a, LUCKY_CHANNEL
	ld [wCurRadioLine], a
	xor a
	ld [wNumRadioLinesPrinted], a
	ld a, BANK(PlayRadioShow)
	ld hl, PlayRadioShow
	call Radio_BackUpFarCallParams
	ld de, LuckyChannelName
	ret

LoadStation_BuenasPassword:
	ld a, BUENAS_PASSWORD
	ld [wCurRadioLine], a
	xor a
	ld [wNumRadioLinesPrinted], a
	ld a, BANK(PlayRadioShow)
	ld hl, PlayRadioShow
	call Radio_BackUpFarCallParams
	ld de, NotBuenasPasswordName
	ld a, [wStatusFlags2]
	bit STATUSFLAGS2_ROCKETS_IN_RADIO_TOWER_F, a
	ret z
	ld de, BuenasPasswordName
	ret

BuenasPasswordName:    db "BUENA'S PASSWORD@"
NotBuenasPasswordName: db "@"

LoadStation_UnownRadio:
	ld a, UNOWN_RADIO
	ld [wCurRadioLine], a
	xor a
	ld [wNumRadioLinesPrinted], a
	ld a, BANK(PlayRadioShow)
	ld hl, PlayRadioShow
	call Radio_BackUpFarCallParams
	ld de, UnownStationName
	ret

LoadStation_PlacesAndPeople:
	ld a, PLACES_AND_PEOPLE
	ld [wCurRadioLine], a
	xor a
	ld [wNumRadioLinesPrinted], a
	ld a, BANK(PlayRadioShow)
	ld hl, PlayRadioShow
	call Radio_BackUpFarCallParams
	ld de, PlacesAndPeopleName
	ret

LoadStation_LetsAllSing:
	ld a, LETS_ALL_SING
	ld [wCurRadioLine], a
	xor a
	ld [wNumRadioLinesPrinted], a
	ld a, BANK(PlayRadioShow)
	ld hl, PlayRadioShow
	call Radio_BackUpFarCallParams
	ld de, LetsAllSingName
	ret

LoadStation_RocketRadio:
	ld a, ROCKET_RADIO
	ld [wCurRadioLine], a
	xor a
	ld [wNumRadioLinesPrinted], a
	ld a, BANK(PlayRadioShow)
	ld hl, PlayRadioShow
	call Radio_BackUpFarCallParams
	ld de, LetsAllSingName
	ret

LoadStation_PokeFluteRadio:
	ld a, POKE_FLUTE_RADIO
	ld [wCurRadioLine], a
	xor a
	ld [wNumRadioLinesPrinted], a
	ld a, BANK(PlayRadioShow)
	ld hl, PlayRadioShow
	call Radio_BackUpFarCallParams
	ld de, PokeFluteStationName
	ret

LoadStation_SwarmRadio:
	ld a, SWARM_RADIO
	ld [wCurRadioLine], a
	xor a
	ld [wNumRadioLinesPrinted], a
	ld a, BANK(PlayRadioShow)
	ld hl, PlayRadioShow
	call Radio_BackUpFarCallParams
	ld de, SwarmRadioName
	ret

LoadStation_EvolutionRadio:
	ld a, EVOLUTION_RADIO
	ld [wCurRadioLine], a
	xor a
	ld [wNumRadioLinesPrinted], a
	ld a, BANK(PlayRadioShow)
	ld hl, PlayRadioShow
	call Radio_BackUpFarCallParams
	ld de, UnownStationName
	ret

RadioMusicRestartDE:
	push de
	ld a, e
	ld [wPokegearRadioMusicPlaying], a
	ld de, MUSIC_NONE
	call PlayMusic
	pop de
	ld a, e
	ld [wMapMusic], a
	jmp PlayMusic

RadioMusicRestartPokemonChannel:
	push de
	ld a, RESTART_MAP_MUSIC
	ld [wPokegearRadioMusicPlaying], a
	ld de, MUSIC_NONE
	call PlayMusic
	pop de
	ld de, MUSIC_POKEMON_CHANNEL
	jmp PlayMusic

Radio_BackUpFarCallParams:
	ld [wPokegearRadioChannelBank], a
	ld a, l
	ld [wPokegearRadioChannelAddr], a
	ld a, h
	ld [wPokegearRadioChannelAddr + 1], a
	ret

NoRadioStation:
	call NoRadioMusic
	call NoRadioName
; no radio channel
	xor a
	ld [wPokegearRadioChannelBank], a
	ld [wPokegearRadioChannelAddr], a
	ld [wPokegearRadioChannelAddr + 1], a
	ld a, $1
	ldh [hBGMapMode], a
	ret

NoRadioMusic:
	ld de, MUSIC_NONE
	call PlayMusic
	ld a, ENTER_MAP_MUSIC
	ld [wPokegearRadioMusicPlaying], a
	ret

NoRadioName:
	xor a
	ldh [hBGMapMode], a
	hlcoord 1, 8
	lb bc, 3, 18
	call ClearBox
	hlcoord 0, 12
	lb bc, 4, 18
	jmp Textbox

OaksPKMNTalkName:     db "OAK's <PK><MN> Talk@"
PokedexShowName:      db "#DEX Show@"
PokemonMusicName:     db "#MON Music@"
LuckyChannelName:     db "Lucky Channel@"
UnownStationName:     db "?????@"

PlacesAndPeopleName:  db "Places & People@"
LetsAllSingName:      db "Let's All Sing!@"
PokeFluteStationName: db "# FLUTE@"
SwarmRadioName:       db "Guild Swarm News@"

_TownMap:
	ld hl, wOptions
	ld a, [hl]
	push af
	set NO_TEXT_SCROLL, [hl]

	ldh a, [hInMenu]
	push af
	ld a, $1
	ldh [hInMenu], a

	ld a, [wStateFlags]
	push af
	xor a
	ld [wStateFlags], a

	call ClearBGPalettes
	call ClearTilemap
	call ClearSprites
	call DisableLCD
	call Pokegear_LoadGFX
	farcall ClearSpriteAnims
	ld a, 8
	call SkipMusic
	ld a, LCDC_DEFAULT
	ldh [rLCDC], a
	call TownMap_GetCurrentLandmark
	ld [wTownMapPlayerIconLandmark], a
	ld [wTownMapCursorLandmark], a
	xor a
	ldh [hBGMapMode], a
	call .InitTilemap
	call WaitBGMap2
	ld a, [wTownMapPlayerIconLandmark]
	call PokegearMap_InitPlayerIcon
	ld a, [wTownMapCursorLandmark]
	call PokegearMap_InitCursor
	ld a, c
	ld [wTownMapCursorObjectPointer], a
	ld a, b
	ld [wTownMapCursorObjectPointer + 1], a
	ld b, SCGB_POKEGEAR_PALS
	call GetSGBLayout
	call SetDefaultBGPAndOBP
	ldh a, [hCGB]
	and a
	jr z, .dmg
	ld a, %11100100
	call DmgToCgbObjPal0
	call DelayFrame

.dmg
	ld a, [wTownMapPlayerIconLandmark]
	cp KANTO_LANDMARK
	jr nc, .kanto
	lb de, KANTO_LANDMARK - 1, 1
	call .loop
	jr .resume

.kanto
	call TownMap_GetKantoLandmarkLimits
	call .loop

.resume
	pop af
	ld [wStateFlags], a
	pop af
	ldh [hInMenu], a
	pop af
	ld [wOptions], a
	jmp ClearBGPalettes

.loop
	call JoyTextDelay
	ld hl, hJoyPressed
	ld a, [hl]
	and PAD_B
	ret nz

	ld hl, hJoyLast
	ld a, [hl]
	and PAD_UP
	jr nz, .pressed_up

	ld a, [hl]
	and PAD_DOWN
	jr nz, .pressed_down
.loop2
	push de
	farcall PlaySpriteAnimations
	pop de
	call DelayFrame
	jr .loop

.pressed_up
	ld hl, wTownMapCursorLandmark
	ld a, [hl]
	cp d
	jr c, .okay
	ld a, e
	dec a
	ld [hl], a

.okay
	inc [hl]
	jr .next

.pressed_down
	ld hl, wTownMapCursorLandmark
	ld a, [hl]
	cp e
	jr nz, .okay2
	ld a, d
	inc a
	ld [hl], a

.okay2
	dec [hl]

.next
	push de
	ld a, [wTownMapCursorLandmark]
	call PokegearMap_UpdateLandmarkName
	ld a, [wTownMapCursorObjectPointer]
	ld c, a
	ld a, [wTownMapCursorObjectPointer + 1]
	ld b, a
	ld a, [wTownMapCursorLandmark]
	call PokegearMap_UpdateCursorPosition
	pop de
	jr .loop2

.InitTilemap:
	ld a, [wTownMapPlayerIconLandmark]
	cp KANTO_LANDMARK
	ld e, JOHTO_REGION
	jr c, .okay_tilemap
	ld e, KANTO_REGION
.okay_tilemap
	call PokegearMap
	ld a, $07
	ld bc, 6
	hlcoord 1, 0
	rst ByteFill
	hlcoord 0, 0
	ld [hl], $06
	hlcoord 7, 0
	ld [hl], $17
	hlcoord 7, 1
	ld [hl], $16
	hlcoord 7, 2
	ld [hl], $26
	ld a, $07
	ld bc, NAME_LENGTH
	hlcoord 8, 2
	rst ByteFill
	hlcoord 19, 2
	ld [hl], $17
	ld a, [wTownMapCursorLandmark]
	call PokegearMap_UpdateLandmarkName
	jmp TownMapPals

PlayRadio:
	ld hl, wOptions
	ld a, [hl]
	push af
	set NO_TEXT_SCROLL, [hl]
	call .PlayStation
	ld c, 100
	call DelayFrames
.loop
	call JoyTextDelay
	ldh a, [hJoyPressed]
	and PAD_A | PAD_B
	jr nz, .stop
	ld hl, wPokegearRadioChannelAddr
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wPokegearRadioChannelBank]
	and a
	call nz,  FarCall_hl
	call DelayFrame
	jr .loop

.stop
	pop af
	ld [wOptions], a
	jmp ExitPokegearRadio_HandleMusic

.PlayStation:
	ld a, ENTER_MAP_MUSIC
	ld [wPokegearRadioMusicPlaying], a
	ld hl, PlayRadioStationPointers
	ld d, 0
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call _hl_
	push de
	hlcoord 0, 12
	lb bc, 4, 18
	call Textbox
	hlcoord 1, 14
	ld [hl], "“"
	pop de
	hlcoord 2, 14
	rst PlaceString
	ld h, b
	ld l, c
	ld [hl], "”"
	jmp WaitBGMap

PlayRadioStationPointers:
; entries correspond to MAPRADIO_* constants
	table_width 2
	dw LoadStation_PokemonChannel
	dw LoadStation_OaksPokemonTalk
	dw LoadStation_PokedexShow
	dw LoadStation_PokemonMusic
	dw LoadStation_LuckyChannel
	dw LoadStation_UnownRadio
	dw LoadStation_PlacesAndPeople
	dw LoadStation_LetsAllSing
	dw LoadStation_RocketRadio
	assert_table_length NUM_MAP_RADIO_STATIONS

LoadStation_PokemonChannel:
	call IsInJohto
	and a
	jr nz, .kanto
	call UpdateTime
	ld a, [wTimeOfDay]
	and a
	jmp z, LoadStation_PokedexShow
	jmp LoadStation_OaksPokemonTalk

.kanto:
	jmp LoadStation_PlacesAndPeople

PokegearMap:
	ld a, e
	and a
	jr nz, .kanto
	call LoadTownMapGFX
	jmp FillJohtoMap

.kanto
	call LoadTownMapGFX
	jmp FillKantoMap

_FlyMap:
	call ClearBGPalettes
	call ClearTilemap
	call ClearSprites
	ld hl, hInMenu
	ld a, [hl]
	push af
	ld [hl], $1
	xor a
	ldh [hBGMapMode], a
	ld a, SCREEN_HEIGHT_PX ; the window starts hidden: the map is first drawn as it, BG Map 1
	ldh [hWY], a
	ld a, 7 ; the window's left edge on the screen's
	ldh [hWX], a
	farcall ClearSpriteAnims
	call LoadTownMapGFX
	ld hl, PokegearSpritesGFX ; the arrow
	ld de, vTiles0
	lb bc, BANK(PokegearSpritesGFX), 9 ; the screen is on here, so queue it rather than write VRAM
	call DecompressRequest2bpp
	ld de, FlyMapLabelBorderGFX
	ld hl, vTiles2 tile $30
	lb bc, BANK(FlyMapLabelBorderGFX), 6
	call Request1bpp
	farcall LoadMapViewLabelGFX
	xor a ; MAP_VIEW_SWARMS
	ld [wMapIconView], a
	ld [wMapTrainersShownCount], a
	ld [wMapRegionScroll], a ; MAP_SCROLL_NONE
	ld a, -1 ; no town selected yet, so LoadMapForRegion picks the region's default
	ld [wTownMapPlayerIconLandmark], a
	call FlyMap
	call FlyMap_InitMonIcons
	ld b, SCGB_POKEGEAR_PALS
	call GetSGBLayout
	call SetDefaultBGPAndOBP
.loop
	call JoyTextDelay
	ld hl, hJoyPressed
	ld a, [hl]
	and PAD_B
	jr nz, .pressedB
	ld a, [hl]
	and PAD_A
	jr nz, .pressedA
	ld a, [hl]
	and PAD_SELECT
	call nz, .NextView
	ldh a, [hJoyPressed]
	and PAD_START
	call nz, .SwapRegion
	call .HandleDPad
	call GetMapCursorCoordinates
	call MapIcons_Rotate
	farcall MapTrainers_Update
	farcall PlaySpriteAnimations
	farcall MapTrainers_Draw ; the REMATCH and GIFTS views' icons, after the structs'
	call DelayFrame
	jr .loop

.pressedB
	ld a, -1
	jr .exit

.pressedA
	ld a, [wTownMapPlayerIconLandmark]
	ld l, a
	ld h, 0
	add hl, hl
	ld de, Flypoints + 1
	add hl, de
	ld a, [hl]
.exit
	ld [wTownMapPlayerIconLandmark], a
	pop af
	ldh [hInMenu], a
	call ClearBGPalettes
	ld a, SCREEN_HEIGHT_PX
	ldh [hWY], a
	xor a ; LOW(vBGMap0)
	ldh [hBGMapAddress], a
	ld a, HIGH(vBGMap0)
	ldh [hBGMapAddress + 1], a
	ld a, [wTownMapPlayerIconLandmark]
	ld e, a
	ret

.HandleDPad:
	ld a, [wStartFlypoint]
	ld e, a
	ld a, [wEndFlypoint]
	ld d, a
	ld hl, hJoyLast
	ld a, [hl]
	and PAD_UP
	jmp nz, .ScrollNext
	ld a, [hl]
	and PAD_DOWN
	jmp nz, .ScrollPrev

	; Left and Right swap regions once Indigo Plateau has been visited
	push hl
	ld c, SPAWN_INDIGO
	call HasVisitedSpawn
	pop hl
	and a
	ret z
	ld a, [hl]
	and PAD_LEFT
	jr nz, .SwapToJohtoRegionMap
	ld a, [hl]
	and PAD_RIGHT
	ret z
	; fallthrough

.SwapToKantoRegionMap
	ld a, KANTO_LANDMARK
	jr .SwapRegionMap

.SwapToJohtoRegionMap
	ld a, JOHTO_LANDMARK
.SwapRegionMap:
; a = a landmark on the region to show, which opens on its default town as ever. If that's the other
; region, it slides in: Kanto from the right, Johto from the left.
	ld hl, wTownMapPlayerIconLandmark
	ld [hl], -1
	ld b, a
	call FlyMap_GetShownRegion
	ld c, a
	ld a, b
	assert JOHTO_REGION == 0 && KANTO_REGION == 1
	cp KANTO_LANDMARK
	sbc a ; -1 for Johto, 0 for Kanto
	inc a ; the region to show
	cp c
	ld a, b
	jr z, .ShowRegionMap ; the region already shown: just drawn afresh
	assert MAP_SCROLL_FROM_LEFT == 1 && MAP_SCROLL_FROM_RIGHT == 2
	cp KANTO_LANDMARK
	ccf
	sbc a
	and 1
	inc a ; MAP_SCROLL_FROM_LEFT to Johto, MAP_SCROLL_FROM_RIGHT to Kanto
	ld [wMapRegionScroll], a
	ld a, 3 ; the Where? bubble holds still
	ld [wMapScrollHeaderRows], a
	push bc
	call ClearSprites ; hidden through the slide
	farcall MapRegionScroll_Prepare
	pop bc
	ld a, b
.ShowRegionMap:
; a = a landmark on the region to show. A town selected on that region stays selected.
	push af
	call ClearSprites
	farcall ClearSpriteAnims
	pop af
	call LoadMapForRegion
	jmp FlyMap_InitMonIcons

.NextView:
; SELECT shows the next view: SWARMS, REMATCH, GIFTS, then SWARMS again. The map is drawn afresh,
; keeping the town selected.
	ld de, SFX_READ_TEXT_2
	call PlaySFX
	ld a, [wMapIconView]
	inc a
	cp NUM_MAP_VIEWS
	jr c, .got_view
	xor a ; MAP_VIEW_SWARMS
.got_view
	ld [wMapIconView], a
	call FlyMap_GetShownRegion
	and a ; JOHTO_REGION
	ld a, JOHTO_LANDMARK
	jr z, .ShowRegionMap
	ld a, KANTO_LANDMARK
	jr .ShowRegionMap

.SwapRegion:
; START swaps regions too, like Left and Right, once Indigo Plateau has been visited.
	ld c, SPAWN_INDIGO
	call HasVisitedSpawn
	and a
	ret z
	ld de, SFX_READ_TEXT_2
	call PlaySFX
	call FlyMap_GetShownRegion
	and a ; JOHTO_REGION
	jr z, .SwapToKantoRegionMap
	jr .SwapToJohtoRegionMap

.ScrollNext:
	ld hl, wTownMapPlayerIconLandmark
	ld a, [hl]
	cp d
	jr nz, .NotAtEndYet
	ld a, e
	dec a
	ld [hl], a
.NotAtEndYet:
	inc [hl]
	call CheckIfVisitedFlypoint
	jr z, .ScrollNext
	jr .Finally

.ScrollPrev:
	ld hl, wTownMapPlayerIconLandmark
	ld a, [hl]
	cp e
	jr nz, .NotAtStartYet
	ld a, d
	inc a
	ld [hl], a
.NotAtStartYet:
	dec [hl]
	call CheckIfVisitedFlypoint
	jr z, .ScrollPrev
.Finally:
	call TownMapBubble
	call WaitBGMap
	xor a
	ldh [hBGMapMode], a
	ret

TownMapBubble:
; Draw the bubble containing the location text in the town map HUD

; Top-left corner
	hlcoord 1, 0
	ld a, $30
	ld [hli], a
; Top row
	ld bc, 16
	ld a, " "
	rst ByteFill
; Top-right corner
	ld [hl], $31
	hlcoord 1, 1

; Middle row
	ld bc, SCREEN_WIDTH - 2
	ld a, " "
	rst ByteFill

; Bottom-left corner
	hlcoord 1, 2
	ld a, $32
	ld [hli], a
; Bottom row
	ld bc, 16
	ld a, " "
	rst ByteFill
; Bottom-right corner
	ld [hl], $33

; Print "Where?"
	hlcoord 2, 0
	ld de, .Where
	rst PlaceString
; Print the name of the default flypoint
	call .Name
; Up/down arrows
	hlcoord 18, 1
	ld [hl], $34
	ret

.Where:
	db "Where?@"

.Name:
; We need the map location of the default flypoint
	ld a, [wTownMapPlayerIconLandmark]
	ld l, a
	ld h, 0
	add hl, hl ; two bytes per flypoint
	ld de, Flypoints
	add hl, de
	ld e, [hl]
	farcall GetLandmarkName
	hlcoord 2, 1
	ld de, wStringBuffer1
	jmp PlaceString

GetMapCursorCoordinates:
	ld a, [wTownMapPlayerIconLandmark]
	ld l, a
	ld h, 0
	add hl, hl
	ld de, Flypoints
	add hl, de
	ld e, [hl]
	farcall GetLandmarkCoords
	ld a, [wTownMapCursorCoordinates]
	ld c, a
	ld a, [wTownMapCursorCoordinates + 1]
	ld b, a
	ld hl, 4
	add hl, bc
	ld [hl], e
	ld hl, 5
	add hl, bc
	ld [hl], d
	ret

CheckIfVisitedFlypoint:
; Check if the flypoint loaded in [hl] has been visited yet.
	push bc
	push de
	push hl
	ld l, [hl]
	ld h, 0
	add hl, hl
	ld de, Flypoints + 1
	add hl, de
	ld c, [hl]
	call HasVisitedSpawn
	pop hl
	pop de
	pop bc
	and a
	ret

HasVisitedSpawn:
; Check if spawn point c has been visited.
	ld hl, wVisitedSpawns
	ld b, CHECK_FLAG
	ld d, 0
	predef SmallFarFlagAction
	ld a, c
	ret

INCLUDE "data/maps/flypoints.asm"

FlyMap:
	ld a, [wMapGroup]
	ld b, a
	ld a, [wMapNumber]
	ld c, a
; A map with no place of its own, i.e. Pokecenter floor 2F, answers with the backup map's.
	call GetWorldMapLocationOrBackup

; a = location in region that player would like to display the map of
LoadMapForRegion:
; The first 46 locations are part of Johto. The rest are in Kanto.
	push af
	call MapIcons_Reset ; this region's icons are recorded afresh
	pop af
	cp KANTO_LANDMARK
	jr nc, .KantoFlyMap
; Johto fly map
; Note that .NoKanto should be modified in tandem with this branch
	push af
	ld a, JOHTO_FLYPOINT ; first Johto flypoint
	ld [wStartFlypoint], a
	ld a, KANTO_FLYPOINT - 1 ; last Johto flypoint
	ld [wEndFlypoint], a
	ld a, JOHTO_FLYPOINT ; first one is default (New Bark Town)
	call .SelectFlypoint
; Fill out the map
	call FillJohtoMap
	call .MapHud
	pop af

  ; Don't show player icon if player is in Kanto
  call IsInJohto
  and a
  ret nz

  ; Load Player Position on Map into A
  ld a, [wMapGroup]
	ld b, a
	ld a, [wMapNumber]
	ld c, a
	call GetWorldMapLocationOrBackup
	jmp FlyMap_PlayerIcon

.KantoFlyMap:
; The event that there are no flypoints enabled in a map is not
; accounted for. As a result, if you attempt to select a flypoint
; when there are none enabled, the game will crash. Additionally,
; the flypoint selection has a default starting point that
; can be flown to even if none are enabled.
; To prevent both of these things from happening when the player
; enters Kanto, fly access is restricted until Indigo Plateau is
; visited and its flypoint enabled.
	push af
	ld c, SPAWN_INDIGO
	call HasVisitedSpawn
	and a
	jr z, .NoKanto
; Kanto's map is only loaded if we've visited Indigo Plateau
	ld a, KANTO_FLYPOINT ; first Kanto flypoint
	ld [wStartFlypoint], a
	ld a, NUM_FLYPOINTS - 1 ; last Kanto flypoint
	ld [wEndFlypoint], a
	call .SelectFlypoint ; last one is default (Indigo Plateau)
; Fill out the map
	call FillKantoMap
	call .MapHud
	pop af

  ; Don't show player icon if player is in Johto
  call IsInJohto
  and a
  ret z

  ; Load Player Position on Map into A
  ld a, [wMapGroup]
	ld b, a
	ld a, [wMapNumber]
	ld c, a
	call GetWorldMapLocation
  ; If we're not in a valid location, i.e. Pokecenter floor 2F,
  ; the backup map information is used.
	cp LANDMARK_SPECIAL
	jr nz, .DoneKanto
	ld a, [wBackupMapGroup]
	ld b, a
	ld a, [wBackupMapNumber]
	ld c, a
	call GetWorldMapLocation
.DoneKanto
	jmp FlyMap_PlayerIcon

.NoKanto:
; If Indigo Plateau hasn't been visited, we use Johto's map instead
	ld a, JOHTO_FLYPOINT ; first Johto flypoint
	ld [wStartFlypoint], a
	ld a, KANTO_FLYPOINT - 1 ; last Johto flypoint
	ld [wEndFlypoint], a
	ld a, JOHTO_FLYPOINT ; first one is default (New Bark Town)
	call .SelectFlypoint
	call FillJohtoMap
	pop af
.MapHud:
	call TownMapBubble
	call TownMapPals
	call FlyMap_GetShownRegion
	farcall PlaceMapViewLabel ; after TownMapPals, which would undo its attributes
; Draw into the BG map not on screen, then show it, as the Pokegear does: pushed onto the shown one,
; its attributes land a few frames before its tiles, and every changed tile flashes the wrong colors.
; BG Map 1 is shown as the window, over all of BG Map 0.
	ldh a, [hWY]
	and a
	hlbgcoord 0, 0 ; BG Map 0, while the window shows BG Map 1
	jr z, .got_bg_map
	hlbgcoord 0, 0, vBGMap1
.got_bg_map
	call TownMapBGUpdate
	ldh a, [hWY]
	and a
	ld a, SCREEN_HEIGHT_PX ; hide the window, showing BG Map 0
	jr z, .got_window
	xor a ; show the window, BG Map 1
.got_window
	push af
	farcall MapRegionScroll_Slide ; if a region swap asked for it, slide the new map in first
	pop af
	ldh [hWY], a
	call InitMapArrowCursor ; the regular arrow, as on the Pokegear map
	ld a, c
	ld [wTownMapCursorCoordinates], a
	ld a, b
	ld [wTownMapCursorCoordinates + 1], a
	jmp GetMapCursorCoordinates ; onto the selected town at once

.SelectFlypoint:
; a = the region's default flypoint, selected unless a town on this region already is, as when SELECT
; draws the map afresh for another view. Call once wStartFlypoint and wEndFlypoint are set.
	ld b, a
	ld a, [wStartFlypoint]
	ld c, a
	ld a, [wTownMapPlayerIconLandmark]
	cp c
	jr c, .default_flypoint
	ld c, a
	ld a, [wEndFlypoint]
	cp c
	ret nc
.default_flypoint
	ld a, b
	ld [wTownMapPlayerIconLandmark], a
	ret

FlyMap_GetShownRegion:
; out: a = JOHTO_REGION or KANTO_REGION, the region the Fly map is showing
	assert JOHTO_REGION == 0 && KANTO_REGION == 1
	ld a, [wStartFlypoint]
	cp KANTO_FLYPOINT
	sbc a ; -1 for Johto, 0 for Kanto
	inc a ; JOHTO_REGION or KANTO_REGION
	ret

Pokedex_GetArea:
; e: Current landmark
	ld a, [wTownMapPlayerIconLandmark]
	push af
	ld a, [wTownMapCursorLandmark]
	push af
	ld a, e
	ld [wTownMapPlayerIconLandmark], a
	call ClearSprites
	xor a
	ldh [hBGMapMode], a
	ld a, $1
	ldh [hInMenu], a
	ld de, PokedexNestIconGFX
	ld hl, vTiles0 tile $7f
	lb bc, BANK(PokedexNestIconGFX), 1
	call Request2bpp
	call .GetPlayerOrFastShipIcon
	ld hl, vTiles0 tile $78
	ld c, 4
	call Request2bpp
	call LoadTownMapGFX
	call FillKantoMap
	call .PlaceString_MonsNest
	call TownMapPals
	hlbgcoord 0, 0, vBGMap1
	call TownMapBGUpdate
	call FillJohtoMap
	call .PlaceString_MonsNest
	call TownMapPals
	hlbgcoord 0, 0
	call TownMapBGUpdate
	ld b, SCGB_POKEGEAR_PALS
	call GetSGBLayout
	call SetDefaultBGPAndOBP
	xor a
	ldh [hBGMapMode], a
	xor a ; JOHTO_REGION
	call .GetAndPlaceNest
.loop
	call JoyTextDelay
	ld hl, hJoyPressed
	ld a, [hl]
	and PAD_A | PAD_B
	jr nz, .a_b
	ldh a, [hJoypadDown]
	and PAD_SELECT
	jr nz, .select
	call .LeftRightInput
	call .BlinkNestIcons
	jr .next

.select
	call .HideNestsShowPlayer
.next
	call DelayFrame
	jr .loop

.a_b
	call ClearSprites
	pop af
	ld [wTownMapCursorLandmark], a
	pop af
	ld [wTownMapPlayerIconLandmark], a
	ret

.LeftRightInput:
	ld a, [hl]
	and PAD_LEFT
	jr nz, .left
	ld a, [hl]
	and PAD_RIGHT
	jr nz, .right
	ret

.left
	ldh a, [hWY]
	cp SCREEN_HEIGHT_PX
	ret z
	call ClearSprites
	ld a, SCREEN_HEIGHT_PX
	ldh [hWY], a
	xor a ; JOHTO_REGION
	jr .GetAndPlaceNest

.right
	ld a, [wStatusFlags]
	bit STATUSFLAGS_HALL_OF_FAME_F, a
	ret z
	ldh a, [hWY]
	and a
	ret z
	call ClearSprites
	xor a
	ldh [hWY], a
	ld a, KANTO_REGION
	jr .GetAndPlaceNest

.BlinkNestIcons:
	ldh a, [hVBlankCounter]
	ld e, a
	and $f
	ret nz
	ld a, e
	and $10
	jmp z, ClearSprites
	hlcoord 0, 0
	ld de, wShadowOAM
	ld bc, wShadowOAMEnd - wShadowOAM
	jmp CopyBytes

.PlaceString_MonsNest:
	hlcoord 0, 0
	ld bc, SCREEN_WIDTH
	ld a, " "
	rst ByteFill
	hlcoord 0, 1
	ld a, $06
	ld [hli], a
	ld bc, SCREEN_WIDTH - 2
	ld a, $07
	rst ByteFill
	ld [hl], $17
	call GetPokemonName
	hlcoord 2, 0
	rst PlaceString
	ld h, b
	ld l, c
	ld de, .String_SNest
	jmp PlaceString

.String_SNest:
	db "'S NEST@"

.GetAndPlaceNest:
	ld [wTownMapCursorLandmark], a
	ld e, a
	farcall FindNest ; load nest landmarks into wTilemap[0,0]
	decoord 0, 0
	ld hl, wShadowOAMSprite00
.nestloop
	ld a, [de]
	and a
	jr z, .done_nest
	push de
	ld e, a
	push hl
	farcall GetLandmarkCoords
	pop hl
	; load into OAM
	ld a, d
	sub 4
	ld [hli], a ; y
	ld a, e
	sub 4
	ld [hli], a ; x
	ld a, $7f ; nest icon
	ld [hli], a ; tile id
	xor a
	ld [hli], a ; attributes
	; next
	pop de
	inc de
	jr .nestloop

.done_nest
	ld hl, wShadowOAM
	decoord 0, 0
	ld bc, wShadowOAMEnd - wShadowOAM
	jmp CopyBytes

.HideNestsShowPlayer:
	call .CheckPlayerLocation
	ret c
	ld a, [wTownMapPlayerIconLandmark]
	ld e, a
	farcall GetLandmarkCoords
	ld c, e
	ld b, d
	ld de, .PlayerOAM
	ld hl, wShadowOAMSprite00
.ShowPlayerLoop:
	ld a, [de]
	cp $80
	jr z, .clear_oam
	add b
	ld [hli], a ; y
	inc de
	ld a, [de]
	add c
	ld [hli], a ; x
	inc de
	ld a, [de]
	add $78 ; where the player's sprite is loaded
	ld [hli], a ; tile id
	inc de
	push bc
	ld c, PAL_OW_RED
	ld a, [wPlayerGender]
	bit PLAYERGENDER_FEMALE_F, a
	jr z, .male
	assert PAL_OW_RED + 1 == PAL_OW_BLUE
	inc c
.male
	ld a, c
	ld [hli], a ; attributes
	pop bc
	jr .ShowPlayerLoop

.clear_oam
	ld hl, wShadowOAMSprite04
	ld bc, wShadowOAMEnd - wShadowOAMSprite04
	xor a
	jmp ByteFill

.PlayerOAM:
	; y pxl, x pxl, tile offset
	db -1 * TILE_WIDTH, -1 * TILE_WIDTH, 0 ; top left
	db -1 * TILE_WIDTH,  0 * TILE_WIDTH, 1 ; top right
	db  0 * TILE_WIDTH, -1 * TILE_WIDTH, 2 ; bottom left
	db  0 * TILE_WIDTH,  0 * TILE_WIDTH, 3 ; bottom right
	db $80 ; terminator

.CheckPlayerLocation:
; Don't show the player's sprite if you're
; not in the same region as what's currently
; on the screen.
	ld a, [wTownMapPlayerIconLandmark]
	cp LANDMARK_FAST_SHIP
	jr z, .johto
	cp KANTO_LANDMARK
	jr c, .johto
; kanto
	ld a, [wTownMapCursorLandmark]
	and a
	jr z, .clear
	jr .ok

.johto
	ld a, [wTownMapCursorLandmark]
	and a
	jr nz, .clear
.ok
	and a
	ret

.clear
	ld hl, wShadowOAM
	ld bc, wShadowOAMEnd - wShadowOAM
	xor a
	rst ByteFill
	scf
	ret

.GetPlayerOrFastShipIcon:
	ld a, [wTownMapPlayerIconLandmark]
	cp LANDMARK_FAST_SHIP
	jr z, .FastShip
	farjp GetPlayerIcon

.FastShip:
	ld de, FastShipGFX
	ld b, BANK(FastShipGFX)
	ret

TownMapBGUpdate:
; Update BG Map tiles and attributes

; BG Map address
	ld a, l
	ldh [hBGMapAddress], a
	ld a, h
	ldh [hBGMapAddress + 1], a
; Only update palettes on CGB
	ldh a, [hCGB]
	and a
	jr z, .tiles
; BG Map mode 2 (palettes)
	ld a, 2
	ldh [hBGMapMode], a
; The BG Map is updated in thirds, so we wait

; 3 frames to update the whole screen's palettes.
	ld c, 3
	call DelayFrames
.tiles
; Update BG Map tiles
	call WaitBGMap
; Turn off BG Map update
	xor a
	ldh [hBGMapMode], a
	ret

FillJohtoMap:
	ld de, JohtoMap
	jr FillTownMap

FillKantoMap:
	ld de, KantoMap
FillTownMap:
	hlcoord 0, 0
.loop
	ld a, [de]
	cp -1
	ret z
	ld a, [de]
	ld [hli], a
	inc de
	jr .loop

TownMapPals:
; Assign palettes based on tile ids
	hlcoord 0, 0
	decoord 0, 0, wAttrmap
	ld bc, SCREEN_AREA
.loop
; Current tile
	ld a, [hli]
	push hl
; The palette map covers tiles $00 to $5f; $60 and above use palette 0
	cp $60
	jr nc, .pal0

; The palette data is condensed to nybbles, least-significant first.
	ld hl, .PalMap
	srl a
	jr c, .odd
; Even-numbered tile ids take the bottom nybble...
	add l
	ld l, a
	adc h
	sub l
	ld h, a
	ld a, [hl]
	and OAM_PALETTE
	jr .update

.odd
; ...and odd ids take the top.
	add l
	ld l, a
	adc h
	sub l
	ld h, a
	ld a, [hl]
	swap a
	and OAM_PALETTE
	jr .update

.pal0
	xor a
.update
	pop hl
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .loop
	ret

.PalMap:
INCLUDE "gfx/pokegear/town_map_palette_map.asm"

FlyMap_PlayerIcon:
; The Fly map's player icon, first in turn order among the icons sharing its landmark.
; in: a = the player's landmark
	push af
	call TownMapPlayerIcon ; bc = its sprite anim struct
	pop af
	jr MapIcons_Add

MapIcons_Reset:
; Forget the map's icons, before a map makes its own.
	xor a
	ld [wMapIconCount], a
	ld [wMapIconTimer], a
	ld [wMapIconTurn], a
	ret

MapIcons_Add:
; Record an icon for turn-taking, in turn order.
; in: bc = its sprite anim struct, a = its landmark. Preserves bc and de.
	push de
	ld e, a
	ld a, [wMapIconCount]
	cp NUM_MAP_ICONS
	jr nc, .full
	ld d, a
	inc a
	ld [wMapIconCount], a
	ld a, d
	call MapIcons_Entry
	ld a, c
	ld [hli], a
	ld a, b
	ld [hli], a
	ld [hl], e
.full
	pop de
	ret

MapIcons_Rotate:
; Called every frame by the Pokegear map and the Fly map. About once a second, icons that share a
; landmark take the next turn, so they show one at a time instead of on top of each other.
	ld hl, wMapIconTimer
	inc [hl]
	ld a, [hl]
	cp MAP_ICON_TURN_FRAMES
	ret c
	ld [hl], 0
	ld hl, wMapIconTurn
	inc [hl]
	; fallthrough

MapIcons_Apply:
; For each icon: n = how many icons share its landmark, r = how many of those come before it in turn
; order. Alone (n = 1), it's left as it is. Otherwise it stands on its landmark when the turn, counted
; around n, comes to r, and is parked off-screen the rest of the time.
	ld a, [wMapIconCount]
	and a
	ret z
	ld b, a ; how many
	ld c, 0 ; this icon
.icon
	push bc
	ld a, c
	call MapIcons_Entry
	inc hl
	inc hl
	ld e, [hl] ; its landmark
	xor a
	ld [wMapIconGroupSize], a
	ld [wMapIconRank], a
	ld hl, wMapIcons + 2 ; the first icon's landmark
	ld d, 0 ; the icon being compared
.scan
	ld a, [hl]
	cp e
	jr nz, .scan_next
	push hl
	ld hl, wMapIconGroupSize
	inc [hl]
	ld a, d
	cp c
	jr nc, .not_before ; not before this icon
	ld hl, wMapIconRank
	inc [hl]
.not_before
	pop hl
.scan_next
	inc hl
	inc hl
	inc hl
	inc d
	ld a, d
	cp b
	jr c, .scan

	ld a, [wMapIconGroupSize]
	cp 2
	jr c, .next ; alone on its landmark
	ld d, a
	ld a, [wMapIconTurn]
.mod
	cp d
	jr c, .got_mod
	sub d
	jr .mod

.got_mod
	ld hl, wMapIconRank
	cp [hl]
	ld d, 0 ; parked
	jr nz, .place
	farcall GetLandmarkCoords ; d = its landmark's y
.place
	ld a, c
	call MapIcons_Entry
	ld a, [hli]
	ld h, [hl]
	add SPRITEANIMSTRUCT_YCOORD
	ld l, a
	adc h
	sub l
	ld h, a
	ld [hl], d
.next
	pop bc
	inc c
	ld a, c
	cp b
	jr c, .icon
	ret

MapIcons_Entry:
; in: a = an icon's place in wMapIcons. out: hl = its entry. Preserves bc and de.
	ld l, a
	add a
	add l ; 3 bytes each
	add LOW(wMapIcons)
	ld l, a
	adc HIGH(wMapIcons)
	sub l
	ld h, a
	ret

TownMapPlayerIcon:
; Draw the player icon at town map location in a
	push af
	farcall GetPlayerIcon
; Standing icon
	ld hl, vTiles0 tile $10
	ld c, 4 ; # tiles
	call Request2bpp
; Walking icon
	ld hl, 12 tiles
	add hl, de
	ld d, h
	ld e, l
	ld hl, vTiles0 tile $14
	ld c, 4 ; # tiles
	ld a, BANK(ChrisSpriteGFX) ; does nothing
	call Request2bpp
; Animation/palette
	depixel 0, 0
	ld b, SPRITE_ANIM_OBJ_RED_WALK ; Male
	ld a, [wPlayerGender]
	bit PLAYERGENDER_FEMALE_F, a
	jr z, .got_gender
	ld b, SPRITE_ANIM_OBJ_BLUE_WALK ; Female
.got_gender
	ld a, b
	call InitSpriteAnimStruct
	ld hl, SPRITEANIMSTRUCT_TILE_ID
	add hl, bc
	ld [hl], $10
	pop af
	ld e, a
	push bc
	farcall GetLandmarkCoords
	pop bc
	ld hl, SPRITEANIMSTRUCT_XCOORD
	add hl, bc
	ld [hl], e
	ld hl, SPRITEANIMSTRUCT_YCOORD
	add hl, bc
	ld [hl], d
	ret

LoadTownMapGFX:
	ld hl, TownMapGFX
	ld de, vTiles2
	lb bc, BANK(TownMapGFX), 48
	jmp DecompressRequest2bpp

JohtoMap:
INCBIN "gfx/pokegear/johto.bin"

KantoMap:
INCBIN "gfx/pokegear/kanto.bin"

PokedexNestIconGFX:
INCBIN "gfx/pokegear/dexmap_nest_icon.2bpp"
FlyMapLabelBorderGFX:
INCBIN "gfx/pokegear/flymap_label_border.1bpp"
