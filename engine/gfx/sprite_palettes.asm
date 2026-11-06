CopyBGGreenToOBPal7:
; Some overworld effects (Fly leaves, Cut leaves, Cut trees, Headbutt trees)
; have hard-coded OB palette 7 in their OAM data.
	ld a, PAL_OW_COPY_BG_GREEN
	; fallthrough
CopySpritePalToOBPal7:
	ld [wNeededPalIndex], a
	ld [wLoadedObjPal7], a
	ld de, wOBPals1 palette 7
	; fallthrough
CopySpritePal::
	push af
	push bc
	push hl
	push de
	ld a, [wNeededPalIndex]
	cp PAL_OW_FOLLOWER
	jr z, .follower
	jr nc, .overworld_mon ; every index past the follower's carries a mon's own colors
	sub FIRST_COPY_BG_PAL
	jr c, .not_copy_bg
	ld hl, wBGPals1
	ld bc, 1 palettes
	rst AddNTimes
	jr .got_pal

.not_copy_bg
	; check darkness
	push hl
	push de
	call GetMapTimeOfDay
	pop de
	pop hl
	or ~IN_DARKNESS
	inc a
	jr nz, .not_darkness
	ld a, [wStatusFlags]
	bit STATUSFLAGS_FLASH_F, a ; Flash
	jr nz, .not_darkness
	ld a, [wPalFlags]
	bit USE_DAYTIME_PAL_F, a
	jr nz, .not_darkness
	ld a, [wNeededPalIndex]
	cp NUM_OW_TIME_OF_DAY_PALS
	jr nc, .not_darkness
	ld hl, DarknessOBPalette
	ld bc, 1 palettes
	rst AddNTimes
	jr .got_pal

.not_darkness
	ld a, [wNeededPalIndex]
	cp NUM_OW_TIME_OF_DAY_PALS
	jr c, .time_of_day_pal
	ld hl, SingleObjectPals - NUM_OW_TIME_OF_DAY_PALS palettes
	ld bc, 1 palettes
	rst AddNTimes
	jr .got_pal

.time_of_day_pal
	ld hl, MapObjectPals
	ld bc, 1 palettes
	rst AddNTimes
.check_daytimes
	ld a, [wPalFlags]
	bit USE_DAYTIME_PAL_F, a
	ld a, 1
	jr nz, .daytime
	ld a, [wTimeOfDayPal]
.daytime
	maskbits NUM_DAYTIMES
	ld bc, NUM_OW_TIME_OF_DAY_PALS palettes
	rst AddNTimes
	jr .got_pal

.follower
	ld hl, wFollowerPalette
	jr .mon_colors

.overworld_mon
; An overworld Pokemon object. Its colors were arranged into wOverworldMonPals when the sprite's
; palette was chosen, and the index says which entry.
	sub PAL_OW_MON
	add a
	add a
	assert OW_MON_PAL_LENGTH == 4, "CopySpritePal doubles twice to scale a mon palette index"
	add LOW(wOverworldMonPals)
	ld l, a
	adc HIGH(wOverworldMonPals)
	sub l
	ld h, a
	; fallthrough

.mon_colors
; A Pokemon is colored from itself, so there is no table to index -- hl already points at its two
; arranged colors. Bookend them white and black the way every mon pic is.
; Read them out here, while the dynamic palette system's WRAM bank is still current.
; WriteIconPalette switches to the palette bank, which these colors do not live in, so anything
; still unread by then comes back as zeroes.
; Reached without a bank switch, so a layout change that separated the two would otherwise fail
; silently at runtime rather than here.
	assert BANK(WriteIconPalette) == BANK(@), "CopySpritePal calls WriteIconPalette directly"
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a ; bc = the light color
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld d, h
	ld e, l ; de = the dark color
	call .TimeOfDayAdjust
	pop hl ; the destination pushed on entry
	call WriteIconPalette
	jr .apply

.got_pal
	pop de
	ld bc, 1 palettes
	call FarCopyColorWRAM
.apply
	ld hl, wPalFlags
	bit NO_DYN_PAL_APPLY_F, [hl]
	jr nz, .skip_apply
	call ApplyOBPals
	ld a, TRUE
	ldh [hCGBPalUpdate], a
.skip_apply
	pop af
	pop bc
	pop hl
	ret

.TimeOfDayAdjust:
; in: bc = the light color, de = the dark color. Adjusts both for the time of day.
; Only night and darkness do anything. Comparing the daytimes in npc_sprites.pal, morn, day and
; eve leave a sprite's own two colors alone -- practically all of the difference between them sits
; in color 0, which an OBJ palette never draws.
	push bc
	push de
	call GetMapTimeOfDay
	pop de
	pop bc
	or ~IN_DARKNESS
	inc a
	jr nz, .check_night

	ld a, [wStatusFlags]
	bit STATUSFLAGS_FLASH_F, a
	jr nz, .check_night
	ld a, [wPalFlags]
	bit USE_DAYTIME_PAL_F, a
	jr nz, .check_night

; An unlit cave drops every character to the same flat silhouette, so take it from the table the
; other palettes use rather than dimming the mon's own colors towards it.
	ld hl, DarknessOBPalette + COLOR_SIZE
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld e, a
	ld d, [hl]
	ret

.check_night
	ld a, [wPalFlags]
	bit USE_DAYTIME_PAL_F, a
	ret nz ; a map that forces daylight

	ld a, [wTimeOfDayPal]
	maskbits NUM_DAYTIMES
	cp NITE_F
	ret nz

	push de
	call .Darken
	pop de
	push bc
	ld b, d
	ld c, e
	call .Darken
	ld d, b
	ld e, c
	pop bc
	ret

.Darken:
; in: bc = a 15-bit color. out: bc, darkened to night brightness.
; Red and green halve while blue keeps about seven eighths, which is roughly what day -> nite does
; to the authored palettes -- a cool darkening rather than an even dim, so the follower sits
; alongside the NPCs instead of going flatly grey.
	ld a, c
	and %00011111
	srl a
	ld l, a ; red

	ld a, c
	rlca
	rlca
	rlca
	and %00000111
	ld h, a
	ld a, b
	and %00000011
	add a
	add a
	add a
	or h
	srl a
	ld h, a ; green

	ld a, b
	rrca
	rrca
	and %00011111
	ld d, a
	rrca
	rrca
	rrca
	and %00011111 ; a >> 3
	ld e, a
	ld a, d
	sub e
	ld d, a ; blue

	ld a, h
	and %00000111
	rrca
	rrca
	rrca
	or l
	ld c, a

	ld a, h
	rrca
	rrca
	rrca
	and %00011111 ; a >> 3
	ld l, a
	ld a, d
	add a
	add a
	or l
	ld b, a
	ret


LoadPlayerDaytimeOBPal::
; Fill OBJ palette de in wOBPals1 with the player's overworld colors as they look by day, for the
; screens that show the player's icon outside the map.
	push de
	call GetPlayerOWPal
	ld hl, MapObjectPals + DAY_F * NUM_OW_TIME_OF_DAY_PALS palettes
	ld bc, 1 palettes
	rst AddNTimes
	pop de
	jmp FarCopyColorWRAM

LoadMapTrainerOBPals::
; The Pokegear map's and the Fly map's trainer icons: the daytime red, blue, green and brown NPC
; colors, then the party menu's held-item red for the GIFTS view's item markers.
	assert PAL_OW_RED == 0 && PAL_OW_BLUE == 1 && PAL_OW_GREEN == 2 && PAL_OW_BROWN == 3
	assert NUM_MAP_TRAINER_PALS == 4
	ld hl, MapObjectPals + DAY_F * NUM_OW_TIME_OF_DAY_PALS palettes
	ld de, wOBPals1 palette MAP_TRAINER_FIRST_PAL
	ld bc, NUM_MAP_TRAINER_PALS palettes
	call FarCopyColorWRAM
	jmp LoadHeldItemOBPal

ApplyOBPals:
	ld hl, wOBPals1
	ld de, wOBPals2
	ld bc, 8 palettes
	ld a, BANK(wGBCPalettes)
	jmp FarCopyColorWRAM

MapObjectPals:
	table_width 1 palettes
INCLUDE "gfx/overworld/npc_sprites.pal"
	assert_table_length NUM_OW_TIME_OF_DAY_PALS * NUM_DAYTIMES ; morn, day, nite, eve

SingleObjectPals:
	table_width 1 palettes
INCLUDE "gfx/overworld/npc_single_object.pal"
	assert_table_length NUM_OW_INDIVIDUAL_PALS

DarknessOBPalette:
	table_width 1 palettes
INCLUDE "gfx/overworld/npc_sprites_darkness.pal"
	assert_table_length NUM_OW_TIME_OF_DAY_PALS + NUM_OW_INDIVIDUAL_PALS
