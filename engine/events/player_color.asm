GetPlayerNPCPal:
; Put the player's PAL_NPC_* color in wScriptVar, for an NPC who dresses like the player.
	call GetPlayerOWPal
	assert PAL_NPC_RED == PAL_OW_RED + 1
	inc a
	ld [wScriptVar], a
	ret

NewGamePlayerProfile:
; Boy or girl, then the color; B on the color goes back to boy or girl.
	farcall InitGender
	xor a ; PLAYERCOLORPICKER_NEW_GAME
	call PlayerColorPicker
	jr c, NewGamePlayerProfile
	ret

PlayerColorPicker:
; The color screen: the front pic and the walking sprite in the color under the cursor.
; in: a = PLAYERCOLORPICKER_* mode
; out: carry if B was pressed, with wPlayerGender as it was; else the color is in wPlayerGender.
	ld [wPlayerColorPickerMode], a
	ld a, [wPlayerGender]
	ld [wPlayerColorPickerGender], a
	call GetPlayerColor
	call .SetColor ; a new game starts on the gender's default, so A straight through keeps it
	call .DrawScreen

.loop
	call JoyTextDelay
	ldh a, [hJoyPressed]
	bit B_PAD_A, a
	jr nz, .confirm
	bit B_PAD_B, a
	jr nz, .cancel
	ld c, 1
	bit B_PAD_RIGHT, a
	jr nz, .move
	ld c, -1
	bit B_PAD_LEFT, a
	jr z, .next_frame
.move
	call GetPlayerColor
.find
	add c
	jr nz, .not_below
	ld a, NUM_PLAYER_COLORS
.not_below
	cp NUM_PLAYER_COLORS + 1
	jr c, .in_range
	ld a, 1
.in_range
	ld b, a
	push bc
	call IsPlayerColorOffered
	pop bc
	ld a, b
	jr z, .find
	call .SetColor
	call .UpdateColor
.next_frame
	farcall PlaySpriteAnimationsAndDelayFrame
	jr .loop

.cancel
	ld a, [wPlayerColorPickerGender]
	ld [wPlayerGender], a
	call .Exit
	scf
	ret

.confirm
	ld de, SFX_READ_TEXT_2
	call PlaySFX
	call .Exit
	and a
	ret

.SetColor:
; Dress the player in PLAYER_COLOR_* a: the gender's default is stored as 0.
	ld b, a
	ld a, [wPlayerGender]
	and 1 << PLAYERGENDER_FEMALE_F
	ld [wPlayerGender], a
	assert PLAYER_COLOR_RED + 1 == PLAYER_COLOR_BLUE
	add PLAYER_COLOR_RED
	cp b
	ret z
	ld a, b
	add a
	assert PLAYER_COLOR_MASK == %1111 << 1
	ld hl, wPlayerGender
	or [hl]
	ld [hl], a
	ret

.DrawScreen:
	call ClearBGPalettes
	call ClearSprites
	farcall ClearSpriteAnims
	xor a
	ldh [hBGMapMode], a
	call LoadStandardFont
	call LoadFontsExtra
	hlcoord 0, 0
	ld bc, SCREEN_AREA
	ld a, " "
	rst ByteFill
	hlcoord 0, 0, wAttrmap
	ld bc, SCREEN_AREA
	ld a, PAL_BG_TEXT
	rst ByteFill
	hlcoord 6, 1, wAttrmap
	lb bc, 7, 7
	xor a ; the pic's palette
	farcall FillBoxCGB

; the front pic
	ld de, ChrisPic
	call IsPlayerFemale
	jr z, .got_pic
	ld de, KrisPic
.got_pic
	ld hl, vTiles2 tile $01
	lb bc, BANK(ChrisPic), 7 * 7
	assert BANK(ChrisPic) == BANK(KrisPic)
	call Get2bpp
	ld a, $01
	ldh [hGraphicStartTile], a
	hlcoord 6, 1
	lb bc, 7, 7
	predef PlaceGraphic

; the walking sprite, standing frames then walking frames
	call GetPlayerIcon
	push de
	push bc
	ld hl, vTiles0 tile $00
	ld c, 4
	call Request2bpp
	pop bc
	pop de
	ld hl, 12 tiles
	add hl, de
	ld d, h
	ld e, l
	ld hl, vTiles0 tile $04
	ld c, 4
	call Request2bpp
	xor a ; SPRITE_ANIM_DICT_DEFAULT and tile offset $00
	ld hl, wSpriteAnimDict
	ld [hli], a
	ld [hl], a
	depixel 6, 16
	ld a, SPRITE_ANIM_OBJ_RED_WALK ; OB 0
	call InitSpriteAnimStruct

	hlcoord 4, 9
	lb bc, 1, 10
	call Textbox
	call .PlaceColorName
	call WaitBGMap2
	call .LoadPalettes
	call SetDefaultBGPAndOBP
	ld hl, PlayerColorPickerText
	jmp PrintText

.UpdateColor:
	call .PlaceColorName
	call WaitBGMap
	call .LoadPalettes
	farcall ApplyPals
	ld a, TRUE
	ldh [hCGBPalUpdate], a
	ret

.PlaceColorName:
	hlcoord 5, 10
	ld bc, 10
	ld a, " "
	rst ByteFill
	hlcoord 5, 10
	ld [hl], "←"
	hlcoord 14, 10
	ld [hl], "→"
	call GetPlayerColor
	call GetPlayerColorName
; center it in the eight tiles between the arrows
	ld h, d
	ld l, e
	ld c, 8
.length
	ld a, [hli]
	cp "@"
	jr z, .got_length
	dec c
	jr .length
.got_length
	srl c
	ld b, 0
	hlcoord 6, 10
	add hl, bc
	rst PlaceString
	ret

.LoadPalettes:
	ld de, wBGPals1 palette 0
	call LoadPlayerPicColors
	farcall LoadPalette_White_Col1_Col2_Black
	ld hl, .TextPalette
	ld de, wBGPals1 palette PAL_BG_TEXT
	ld bc, 1 palettes
	ld a, BANK(wBGPals1)
	call FarCopyWRAM
	ld de, wOBPals1 palette 0
	farjp LoadPlayerDaytimeOBPal

.TextPalette:
INCLUDE "gfx/new_game/gender_screen.pal"

.Exit:
	call ClearBGPalettes
	call ClearSprites
	farcall ClearSpriteAnims
	hlcoord 0, 0
	ld bc, SCREEN_AREA
	ld a, " "
	rst ByteFill
	hlcoord 0, 0, wAttrmap
	ld bc, SCREEN_AREA
	xor a
	rst ByteFill
	jmp WaitBGMap2

IsPlayerColorOffered:
; Return nz if the picker offers PLAYER_COLOR_* a: the starting colors always, a store color only
; in the stylist's mode and once it's owned.
	cp NUM_STARTING_PLAYER_COLORS + 1
	jr nc, .store_color
	or 1 ; nz
	ret

.store_color
	ld c, a
	ld a, [wPlayerColorPickerMode]
	and a ; PLAYERCOLORPICKER_NEW_GAME
	ret z
	ld a, c
; fallthrough
IsPlayerColorOwned:
; Return nz if the player owns store color PLAYER_COLOR_* a.
	assert EVENT_OWNS_PLAYER_COLOR_BLACK - EVENT_OWNS_PLAYER_COLOR_BROWN == PLAYER_COLOR_BLACK - PLAYER_COLOR_BROWN
	add LOW(EVENT_OWNS_PLAYER_COLOR_BROWN - PLAYER_COLOR_BROWN)
	ld e, a
	adc HIGH(EVENT_OWNS_PLAYER_COLOR_BROWN - PLAYER_COLOR_BROWN)
	sub e
	ld d, a
	ld b, CHECK_FLAG
	call EventFlagAction
	ld a, c
	and a
	ret

GetPlayerColorName:
; de = the name of PLAYER_COLOR_* a.
	dec a
	ld hl, PlayerColorNames
	call GetNthString
	ld d, h
	ld e, l
	ret

MACRO color_name
	assert STRLEN(\1) <= MAX_PLAYER_COLOR_NAME_LENGTH, "color name too long: \1"
	li \1
ENDM

PlayerColorNames:
; in PLAYER_COLOR_* order
	list_start
	color_name "RED"
	color_name "BLUE"
	color_name "GREEN"
	color_name "BROWN"
	color_name "PURPLE"
	color_name "GRAY"
	color_name "PINK"
	color_name "TEAL"
	color_name "YELLOW"
	color_name "ORANGE"
	color_name "AZURE"
	color_name "BLACK"
	assert_list_length NUM_PLAYER_COLORS

PlayerColorPickerText:
	text "What color would"
	line "you like to wear?"
	done

LoadPlayerPicColors::
; Copy the player's pic colors (skin, clothes) into wPlayerPicColors and return its address in hl,
; for the palette loaders, which read it with that WRAM bank switched in.
; Preserves de.
	push de
	call GetPlayerColor
	dec a
	add a ; Chris, then Kris
	ld e, a
	ld a, [wPlayerSpriteSetupFlags]
	bit PLAYERSPRITESETUP_FEMALE_TO_MALE_F, a
	jr nz, .got_gender
	call IsPlayerFemale
	add e
	ld e, a
.got_gender
	ld a, e
	add a
	add a
	assert 2 * COLOR_SIZE == 4, "four bytes a row"
	add LOW(PlayerPicPalettes)
	ld l, a
	adc HIGH(PlayerPicPalettes)
	sub l
	ld h, a

	ldh a, [rWBK]
	push af
	ld a, BANK(wPlayerPicColors)
	ldh [rWBK], a
	ld de, wPlayerPicColors
	ld bc, 2 * COLOR_SIZE
	rst CopyBytes
	pop af
	ldh [rWBK], a
	ld hl, wPlayerPicColors
	pop de
	ret

PlayerPicPalettes:
; The pics' skin and clothes for each PLAYER_COLOR_*, Chris then Kris. The skin is the gender's own;
; the clothes are the overworld color, darkened where it would be too close to the skin, and the same
; for both. Red is Cal's clothes, as in TrainerPalettes.
	table_width 2 * COLOR_SIZE
	RGB 25, 18, 12,  22, 09, 05 ; red
	RGB 27, 17, 14,  22, 09, 05
	RGB 25, 18, 12,  10, 09, 31 ; blue
	RGB 27, 17, 14,  10, 09, 31
	RGB 25, 18, 12,  05, 17, 02 ; green
	RGB 27, 17, 14,  05, 17, 02
	RGB 25, 18, 12,  15, 10, 03 ; brown
	RGB 27, 17, 14,  15, 10, 03
	RGB 25, 18, 12,  18, 04, 18 ; purple
	RGB 27, 17, 14,  18, 04, 18
	RGB 25, 18, 12,  13, 13, 13 ; gray
	RGB 27, 17, 14,  13, 13, 13
	RGB 25, 18, 12,  26, 08, 16 ; pink
	RGB 27, 17, 14,  26, 08, 16
	RGB 25, 18, 12,  02, 16, 15 ; teal
	RGB 27, 17, 14,  02, 16, 15
	RGB 25, 18, 12,  13, 13, 00 ; yellow
	RGB 27, 17, 14,  13, 13, 00
	RGB 25, 18, 12,  22, 14, 00 ; orange, kept clear of red and brown
	RGB 27, 17, 14,  22, 14, 00
	RGB 25, 18, 12,  03, 15, 28 ; azure, kept clear of blue and teal
	RGB 27, 17, 14,  03, 15, 28
	RGB 25, 18, 12,  07, 07, 08 ; black
	RGB 27, 17, 14,  07, 07, 08
	assert_table_length NUM_PLAYER_COLORS * 2

StylistChangeStyle:
; The Goldenrod stylist's CHANGE STYLE: the color screen with every color the player owns, then the
; player's sprite in the new color, without a warp.
	call DisableSpriteUpdates
	ld a, PLAYERCOLORPICKER_OWNED
	call PlayerColorPicker
	call SetPlayerObjectPal
	jmp ReturnToMapWithSpeechTextbox

StylistWearColor:
; Dress the player in wStylistColor on the spot.
	ld a, [wStylistColor]
	call PlayerColorPicker.SetColor
	call SetPlayerObjectPal
	farcall ClearSavedObjPals
	farjp CheckForUsedObjPals

SetPlayerObjectPal:
; The player's map object and object struct take the player's color.
	call GetPlayerOWPal
	ld [wPlayerPalIndex], a
	assert PAL_NPC_RED == PAL_OW_RED + 1
	inc a
	ld [wPlayerObjectPalette], a
	ret

StylistCheckStock:
; wScriptVar = STYLIST_ALL_OWNED, STYLIST_SOLD_OUT, or FALSE if there's a color to buy today.
	call StylistStockToday
	call OwnsEveryStoreColor
	ld a, STYLIST_ALL_OWNED
	jr c, .done
	ld c, 0
.loop
	push bc
	ld de, EVENT_STYLIST_SELLS_BROWN
	ld b, CHECK_FLAG
	call StylistFlagAction
	pop bc
	jr nz, .on_sale
	inc c
	ld a, c
	cp NUM_STORE_PLAYER_COLORS
	jr c, .loop
	ld a, STYLIST_SOLD_OUT
	jr .done

.on_sale
	xor a ; FALSE
.done
	ld [wScriptVar], a
	ret

OwnsEveryStoreColor:
; Return carry if the player owns every store color.
	ld c, 0
.loop
	ld a, c
	add PLAYER_COLOR_BROWN
	push bc
	call IsPlayerColorOwned
	pop bc
	ret z ; no carry
	inc c
	ld a, c
	cp NUM_STORE_PLAYER_COLORS
	jr c, .loop
	scf
	ret

StylistColorMenu:
; The Goldenrod stylist's menu of today's colors, with the player's money. wScriptVar = the PLAYER_COLOR_* picked (also in
; wStylistColor, with its name in wStringBuffer3), 0 for CANCEL, or STYLIST_SOLD_OUT /
; STYLIST_ALL_OWNED with no menu.
	call StylistStockToday
	call OwnsEveryStoreColor
	ld a, STYLIST_ALL_OWNED
	jr nc, .collect
	ld [wScriptVar], a
	ret

.collect
; today's colors, not sold yet
	ld hl, wStylistMenuColors
	ld bc, NUM_STYLIST_COLORS_A_DAY + 1
	xor a
	rst ByteFill
	ld c, 0
.collect_loop
	push bc
	ld de, EVENT_STYLIST_SELLS_BROWN
	ld b, CHECK_FLAG
	call StylistFlagAction
	pop bc
	jr z, .collect_next
	ld hl, wStylistMenuColors
.find_end
	ld a, [hli]
	and a
	jr nz, .find_end
	dec hl
	ld a, c
	add PLAYER_COLOR_BROWN
	ld [hl], a
.collect_next
	inc c
	ld a, c
	cp NUM_STORE_PLAYER_COLORS
	jr c, .collect_loop
	ld a, [wStylistMenuColors]
	and a
	ld a, STYLIST_SOLD_OUT
	jmp z, .done

; the menu: today's colors, then CANCEL
	ld hl, wStylistMenuData + 2 ; past the flags and the item count
	ld de, wStylistMenuColors
	ld b, 1 ; CANCEL
.menu_loop
	ld a, [de]
	and a
	jr z, .menu_cancel
	inc de
	inc b
	push de
	push bc
	push hl
	call GetPlayerColorName
	pop hl
	call CopyName2
	pop bc
	pop de
	jr .menu_loop

.menu_cancel
	ld de, .CancelString
	call CopyName2
	ld hl, wStylistMenuData
	ld a, STATICMENU_CURSOR
	ld [hli], a
	ld [hl], b ; the item count
	ld hl, wStylistMenuHeader
	ld a, MENU_BACKUP_TILES
	ld [hli], a
	xor a
	ld [hli], a ; top
	ld a, SCREEN_WIDTH - 9
	ld [hli], a ; left
	ld a, b
	add a ; two rows an item
	inc a
	ld [hli], a ; bottom
	ld a, SCREEN_WIDTH - 1
	ld [hli], a ; right
	ld a, LOW(wStylistMenuData)
	ld [hli], a
	ld a, HIGH(wStylistMenuData)
	ld [hli], a
	ld [hl], 1 ; the first item
	ld hl, .MoneyMenuHeader
	call LoadMenuHeader
	call MenuBox
	call MenuBoxCoord2Tile
	ld de, SCREEN_WIDTH + 1
	add hl, de
	ld de, wMoney
	lb bc, PRINTNUM_MONEY | 3, 6
	call PrintNum
	ld hl, wStylistMenuHeader
	call LoadMenuHeader
	call VerticalMenu
	push af
	call CloseWindow
	call CloseWindow ; the money
	pop af
	jr c, .cancel
	ld a, [wMenuCursorY]
	dec a
	ld e, a
	ld d, 0
	ld hl, wStylistMenuColors
	add hl, de
	ld a, [hl]
	and a
	jr z, .done ; CANCEL
	ld [wStylistColor], a
	call GetPlayerColorName
	ld hl, wStringBuffer3
	call CopyName2
	ld a, [wStylistColor]
	jr .done

.cancel
	xor a
.done
	ld [wScriptVar], a
	ret

.CancelString:
	db "CANCEL@"

.MoneyMenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 8, 2
	dw NULL
	db 1 ; default option

StylistSellColor:
; The player now owns wStylistColor, and it's off today's stock.
	ld a, [wStylistColor]
	sub PLAYER_COLOR_BROWN
	ld c, a
	push bc
	ld de, EVENT_OWNS_PLAYER_COLOR_BROWN
	ld b, SET_FLAG
	call StylistFlagAction
	pop bc
	ld de, EVENT_STYLIST_SELLS_BROWN
	ld b, RESET_FLAG
	jmp StylistFlagAction

StylistStockToday:
; Once a day, put up to NUM_STYLIST_COLORS_A_DAY store colors the player doesn't own on sale: first
; ones that weren't on sale the last time, then those. Where the search starts moves with the day.
	ld hl, wDailyFlags3
	bit DAILYFLAGS3_STYLIST_STOCKED_F, [hl]
	ret nz
	set DAILYFLAGS3_STYLIST_STOCKED_F, [hl]
	ld hl, wStylistMenuColors
	ld bc, NUM_STYLIST_COLORS_A_DAY + 1
	xor a
	rst ByteFill
	ld b, FALSE ; not on sale last time
	call .Pass
	ld b, TRUE ; on sale last time
	call .Pass

	ld c, 0
.clear
	push bc
	ld de, EVENT_STYLIST_SELLS_BROWN
	ld b, RESET_FLAG
	call StylistFlagAction
	pop bc
	inc c
	ld a, c
	cp NUM_STORE_PLAYER_COLORS
	jr c, .clear

	ld hl, wStylistMenuColors
.set
	ld a, [hli]
	and a
	ret z
	sub PLAYER_COLOR_BROWN
	ld c, a
	push hl
	ld de, EVENT_STYLIST_SELLS_BROWN
	ld b, SET_FLAG
	call StylistFlagAction
	pop hl
	jr .set

.Pass:
; Add the unowned colors whose last-time sale matches b, while there's room.
	ld a, [wCurDay]
.mod
	sub NUM_STORE_PLAYER_COLORS
	jr nc, .mod
	add NUM_STORE_PLAYER_COLORS
	ld c, a
	ld e, NUM_STORE_PLAYER_COLORS
.loop
	ld a, [wStylistMenuColors + NUM_STYLIST_COLORS_A_DAY - 1]
	and a
	ret nz ; full
	push de
	push bc
	ld a, c
	add PLAYER_COLOR_BROWN
	call IsPlayerColorOwned
	pop bc
	push bc
	jr nz, .skip
	ld de, EVENT_STYLIST_SELLS_BROWN
	ld b, CHECK_FLAG
	call StylistFlagAction
	pop bc
	push bc
	jr z, .got_last_time
	ld a, TRUE
.got_last_time
	cp b
	jr nz, .skip
	ld hl, wStylistMenuColors
.find_end
	ld a, [hli]
	and a
	jr nz, .find_end
	dec hl
	ld a, c
	add PLAYER_COLOR_BROWN
	ld [hl], a
.skip
	pop bc
	pop de
	inc c
	ld a, c
	cp NUM_STORE_PLAYER_COLORS
	jr c, .no_wrap
	ld c, 0
.no_wrap
	dec e
	jr nz, .loop
	ret

StylistFlagAction:
; Do flag action b on the event flag de + c, for store color c (0 = brown).
; Return nz if a checked flag is set.
	ld a, c
	add e
	ld e, a
	adc d
	sub e
	ld d, a
	call EventFlagAction
	ld a, c
	and a
	ret
