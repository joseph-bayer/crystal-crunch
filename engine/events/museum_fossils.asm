MACRO fossil_pic
; pic, width and height in tiles
	dw \1
	db \2, \2 * \2
	; a smaller pic sits bottom right in the 7x7 area, like a padded front pic
	dwcoord 7 + 7 - (\2), 5 + 7 - (\2)
ENDM

FossilPics:
	table_width 6
	fossil_pic FossilAerodactylPic, 7 ; MUSEUM_FOSSIL_AERODACTYL
	fossil_pic FossilKabutopsPic,   6 ; MUSEUM_FOSSIL_KABUTOPS
	assert_table_length NUM_MUSEUM_FOSSILS

FossilPic:
; Show a Pewter Museum fossil's skeleton in pokepic's box; closepokepic takes it down.
; Like pokepic, it runs inside an open text box: the box frame's tiles are the textbox's, and the
; pic goes over the font in vTiles1, where objects keep their walking frames while no text is up.
; The closetext after closepokepic reloads those frames and stops the BG map copy closepokepic
; leaves on. The text box itself is taken off the screen first.
; wScriptVar: a MUSEUM_FOSSIL_* constant.
	call LoadOverworldTilemapAndAttrmapPals
	ld hl, .MenuHeader
	call CopyMenuHeader
	call MenuBox
	call UpdateSprites
	call ApplyTilemap
	ld b, SCGB_POKEPIC
	call GetSGBLayout
	xor a
	ldh [hBGMapMode], a

	ld a, [wScriptVar]
	ld hl, FossilPics
	ld bc, 6
	rst AddNTimes
	push hl

; load the pic
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	inc hl
	ld c, [hl] ; tiles
	ldh a, [rWBK]
	push af
	push bc
	ld a, BANK(wDecompressScratch)
	ldh [rWBK], a
	ld h, d
	ld l, e
	ld de, wDecompressScratch
	call Decompress
	pop bc
	ld b, BANK(@)
	ld de, wDecompressScratch
	ld hl, vTiles1
	call Get2bpp
	pop af
	ldh [rWBK], a

; place it
	pop hl
	inc hl
	inc hl
	ld a, [hli]
	ld b, a
	ld c, a
	inc hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	xor a
	ld [wBoxAlignment], a
	ld a, $80 ; vTiles1
	ldh [hGraphicStartTile], a
	predef PlaceGraphic
	jmp WaitBGMap

.MenuHeader:
	db 0 ; flags
	menu_coords 6, 4, 14, 13 ; pokepic's box, which closepokepic clears
	dw NULL
	db 1 ; default option

FossilAerodactylPic: INCBIN "gfx/museum/fossil_aerodactyl.2bpp.lz"
FossilKabutopsPic:   INCBIN "gfx/museum/fossil_kabutops.2bpp.lz"
