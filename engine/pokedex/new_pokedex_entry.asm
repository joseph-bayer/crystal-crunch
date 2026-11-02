NewPokedexEntry:
	ldh a, [hMapAnims]
	push af
	ld a, [wPokedexShinyToggle]
	push af
; A new entry shows the Pokémon as it was met: its form ([wForm], which the frontpic loads too) in
; its own colors, shiny or alternate shiny included.
	ld a, [wForm]
	ld b, a
	and FORM_MASK
	ld [wPokedexViewForm], a
	ld c, 0
	ld a, b
	and SHINY_MASK
	jr z, .got_toggle
	ld c, 1 << POKEDEX_SHINY_F
	ld a, b
	and ALT_SHINY_MASK
	jr z, .got_toggle
	ld c, 1 << POKEDEX_SHINY_F | 1 << POKEDEX_ALT_SHINY_F
	ld a, TRUE
	ld [wPokedexAltSeen], a
.got_toggle
	ld a, c
	ld [wPokedexShinyToggle], a
	xor a
	ld [wPokedexEntryType], a ; DEXENTRY_LORE
	ld [wPokedexEntryPageNum], a
	ldh [hMapAnims], a
	call LowVolume
	call ClearBGPalettes
	call ClearTilemap
	call UpdateSprites
	call ClearSprites
	ld a, [wPokedexStatus]
	push af
	ldh a, [hSCX]
	add POKEDEX_SCX
	ldh [hSCX], a
	xor a
	ldh [hSCY], a
	ld [wPokedexStatus], a
	farcall _NewPokedexEntry
	call WaitPressAorB_BlinkCursor
	ld a, 1 ; page 2
	ld [wPokedexStatus], a
	farcall DisplayDexEntry
	call WaitPressAorB_BlinkCursor
	pop af
	ld [wPokedexStatus], a
	call MaxVolume
	ld c, 15
	call FadeToWhite
	ldh a, [hSCX]
	add -POKEDEX_SCX
	ldh [hSCX], a
	call .ReturnFromDexRegistration
	xor a
	ld [wPokedexViewForm], a ; the plain form everywhere but PICS
	pop af
	ld [wPokedexShinyToggle], a
	pop af
	ldh [hMapAnims], a
	ret

.ReturnFromDexRegistration:
	call ClearTilemap
	call LoadFontsExtra
	call LoadStandardFont
	farcall Pokedex_PlaceFrontpicTopLeftCorner
	call WaitBGMap2
	farcall GetEnemyMonDVs
	ld a, [hli]
	ld [wTempMonDVs], a
	ld a, [hl]
	ld [wTempMonDVs + 1], a
	farcall GetEnemyMonForm
	ld a, [hl]
	ld [wTempMonForm], a
	ld b, SCGB_TRAINER_OR_MON_FRONTPIC_PALS
	call GetSGBLayout
	jmp SetDefaultBGPAndOBP
