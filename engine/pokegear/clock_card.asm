; The Pokégear clock card's extras: the time of day as an icon and a word, and where the player
; is, with the map's fishing group.

DEF CLOCK_TIME_OF_DAY_ICONS EQU $6d ; morn, day, nite; tiles the clock card leaves free

PokegearClock_LoadIcons::
	ld de, PokegearTimeOfDayIconsGFX
	ld hl, vTiles2 tile CLOCK_TIME_OF_DAY_ICONS
	lb bc, BANK(PokegearTimeOfDayIconsGFX), 3
	jmp Get2bpp

PokegearClock_DrawFrame::
; Widen the clock's frame to the screen's width, for the place's name.
	hlcoord 0, 4
	ld a, $06 ; upper left corner
	ld [hli], a
	ld bc, SCREEN_WIDTH - 2
	ld a, $07 ; horizontal edge
	rst ByteFill
	ld [hl], $17 ; upper right corner
	hlcoord 0, 11
	ld a, $26 ; lower left corner
	ld [hli], a
	ld bc, SCREEN_WIDTH - 2
	ld a, $07
	rst ByteFill
	ld [hl], $27 ; lower right corner
	hlcoord 0, 5
	lb bc, 6, 1
	ld a, $16 ; vertical edge
	call FillBoxWithByte
	hlcoord SCREEN_WIDTH - 1, 5
	lb bc, 6, 1
	call FillBoxWithByte
	hlcoord 1, 5
	lb bc, 6, SCREEN_WIDTH - 2
	jmp ClearBox

PokegearClock_PlaceExtras::
; the time of day
	ld a, [wTimeOfDay]
	ld e, a
	ld d, 0
	ld hl, .Icons
	add hl, de
	ld a, [hl]
	hlcoord 2, 5
	ld [hli], a
	inc hl
	push hl
	ld hl, .Words
	add hl, de
	add hl, de
	ld a, [hli]
	ld d, [hl]
	ld e, a
	pop hl
	rst PlaceString
; where the player is, unless the map has no place of its own
	ld a, [wMapGroup]
	ld b, a
	ld a, [wMapNumber]
	ld c, a
	call GetWorldMapLocation
	and a ; LANDMARK_SPECIAL
	jr z, .fish
	hlcoord 2, 9
	call PlaceMapNameWithFloor
.fish
	call GetFishingGroup
	and a ; FISHGROUP_NONE
	ret z
	dec a
	ld hl, FishGroupNames
	ld e, a
	ld d, 0
	add hl, de
	add hl, de
	ld a, [hli]
	ld d, [hl]
	ld e, a
	hlcoord 8, 10
	rst PlaceString
	ld de, .FishText
	hlcoord 2, 10
	jmp PlaceString

.Icons:
; entries correspond to wTimeOfDay values
	table_width 1
	db CLOCK_TIME_OF_DAY_ICONS     ; MORN_F
	db CLOCK_TIME_OF_DAY_ICONS + 1 ; DAY_F
	db CLOCK_TIME_OF_DAY_ICONS + 2 ; NITE_F
	db CLOCK_TIME_OF_DAY_ICONS + 2 ; EVE_F: the night icon, for want of an evening one
	assert_table_length NUM_DAYTIMES

.Words:
; entries correspond to wTimeOfDay values
	table_width 2
	dw .Morn
	dw .Day
	dw .Nite
	dw .Eve
	assert_table_length NUM_DAYTIMES

.Morn: db "MORN@"
.Day:  db "DAY@"
.Nite: db "NITE@"
.Eve:  db "EVE@"

.FishText:
	db "FISH:@"

PokegearTimeOfDayIconsGFX:
INCBIN "gfx/pokegear/pokegear_timeofday_icons.2bpp"
