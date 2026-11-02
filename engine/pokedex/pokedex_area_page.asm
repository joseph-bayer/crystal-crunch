; The AREA page: where the selected species can be found in the wild, one category at a time.
; Each place takes two rows: its name, then its odds. FindNest also runs the categories its own
; search doesn't cover, in nest mode, to mark their places on the Town Map.

DEF AREA_ROWS_PER_PAGE EQU 3
DEF NUM_ROAMMON_STRUCTS EQU 3 ; wRoamMon1-3

; wPokedexAreaMode
	const_def
	const AREA_PRINT ; print the page's places
	const AREA_NEST  ; add each place's landmark to the nest list

; wPokedexAreaFormat: what the second row of a place shows
	const_def
	const AREA_FORMAT_TIMES ; morn, day and nite odds
	const AREA_FORMAT_ONE   ; one odds
	const AREA_FORMAT_RODS  ; Old, Good and Super Rod odds
	const AREA_FORMAT_LEVEL ; a level

Pokedex_DetailedArea:
	call Pokedex_AreaGetSpecies
	xor a ; AREA_PRINT
	ld [wPokedexAreaMode], a
	ld a, [wPokedexEntryType]
	cp DEXENTRY_AREA_FIRST
	jr nc, .got_category
	ld a, DEXENTRY_AREA_FIRST
	call DexEntry_NextCategory
.got_category
	ld a, NUM_AREA_CATEGORIES
	ld [wPokedexAreaTries], a
.try
	call Pokedex_PrintAreaCategory
	cp ROWS_FULL
	jmp z, DexEntry_IncPageNum
	and a
	jr nz, .NextCategory
; nothing in this category: try the next one
	ld hl, wPokedexAreaTries
	dec [hl]
	jr z, .not_located
	call .NextCategory
	jr .try

.NextCategory:
	ld a, [wPokedexEntryType]
	inc a
	cp DEXENTRY_AREA_LAST + 1
	jr c, .next_ok
	ld a, DEXENTRY_AREA_FIRST
.next_ok
	jmp DexEntry_NextCategory

.not_located
	ld a, DEXENTRY_AREA_NONE
	call DexEntry_NextCategory
	call Pokedex_Clearbox
	ld de, .NotLocatedText
	hlcoord 2, 9
	rst PlaceString
; erase the category, page number and A > indicator
	hlcoord 9, 6
	lb bc, 2, 11
	call ClearBox
	hlcoord 18, 5
	ld bc, 2
	ld a, $4e ; category box border
	jmp ByteFill

.NotLocatedText:
	db "NOT LOCATED@"

Pokedex_AreaGetSpecies:
	ld a, [wTempSpecies]
	call GetPokemonIndexFromID
	ld a, l
	ld [wPokedexAreaSpecies], a
	ld a, h
	ld [wPokedexAreaSpecies + 1], a
	ret

Pokedex_PrintAreaCategory:
; Print the current category's page.
; out: a = ROWS_FULL if it has more places on later pages, else how many it printed
	call Pokedex_Clearbox
	ld a, [wPokedexEntryPageNum]
	ld c, AREA_ROWS_PER_PAGE
	call SimpleMultiply
	ld [wPokedexScratch], a ; places to skip
	xor a
	ld [wPokedexScratch + 1], a ; places printed
	ld a, [wPokedexEntryType]
	sub DEXENTRY_AREA_FIRST
	ld e, a
	ld d, 0
	ld hl, AreaCategories
rept 6
	add hl, de
endr
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	push hl
	call .Run
	pop hl
	ld b, a
	ld a, [wPokedexScratch + 1]
	and a
	jr z, .done
	push bc
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call Print_Category_text
	call Pokedex_PrintPageNum
	pop bc
.done
	ld a, b
	cp ROWS_FULL
	ret z
	ld a, [wPokedexScratch + 1]
	ret

.Run:
	ld h, d
	ld l, e
	jp hl

AreaCategories:
; entries correspond to DEXENTRY_AREA_* constants
; the category's places, then the two rows of its title
	table_width 6
	dw Pokedex_AreaJohtoGrass, .Johto,     .Walking
	dw Pokedex_AreaKantoGrass, .Kanto,     .Walking
	dw Pokedex_AreaJohtoWater, .Johto,     .Surfing
	dw Pokedex_AreaKantoWater, .Kanto,     .Surfing
	dw Pokedex_AreaFishing,    .Fishing,   .Rods
	dw Pokedex_AreaHeadbutt,   .Headbutt,  .Trees
	dw Pokedex_AreaRockSmash,  .Rock,      .Smash
	dw Pokedex_AreaContest,    .Bug,       .Contest
	dw Pokedex_AreaRoaming,    .Roaming,   .Blank
	dw Pokedex_AreaWandering,  .Wandering, .Blank
	assert_table_length NUM_AREA_CATEGORIES

.Johto:     db "JOHTO:@"
.Kanto:     db "KANTO:@"
.Walking:   db " WALKING@"
.Surfing:   db " SURFING@"
.Fishing:   db "FISHING@"
.Rods:      db " RODS@"
.Headbutt:  db "HEADBUTT@"
.Trees:     db " TREES@"
.Rock:      db "ROCK@"
.Smash:     db " SMASH@"
.Bug:       db "BUG@"
.Contest:   db " CONTEST@"
.Roaming:   db "ROAMING@"
.Wandering: db "WANDERING@"
.Blank:     db "@"

Pokedex_AreaJohtoGrass:
	ld hl, JohtoGrassWildMons
	jr Pokedex_AreaGrass

Pokedex_AreaKantoGrass:
	ld hl, KantoGrassWildMons
	; fallthrough

Pokedex_AreaGrass:
	assert BANK(JohtoGrassWildMons) == BANK(KantoGrassWildMons)
.loop
	push hl
	ld a, BANK(JohtoGrassWildMons)
	ld bc, GRASS_WILDDATA_LENGTH
	call Pokedex_AreaCopyRecord
	jr z, .end
	ld hl, wPokedexAreaBuffer + 2 + 3 ; morn slots, past the map and the three rates
	ld de, wPokedexAreaValues
	ld b, 3 ; morn, day, nite
.time
	push bc
	push de
	ld c, NUM_GRASSMON
	ld de, GrassMonProbTable
	call Pokedex_AreaSumSlots
	pop de
	ld [de], a
	inc de
	pop bc
	dec b
	jr nz, .time
	ld a, AREA_FORMAT_TIMES
	call Pokedex_AreaRowIfAny
	pop hl
	cp ROWS_FULL
	ret z
	ld bc, GRASS_WILDDATA_LENGTH
	add hl, bc
	jr .loop

.end
	pop hl
	xor a
	ret

Pokedex_AreaJohtoWater:
	ld hl, JohtoWaterWildMons
	jr Pokedex_AreaWater

Pokedex_AreaKantoWater:
	ld hl, KantoWaterWildMons
	; fallthrough

Pokedex_AreaWater:
	assert BANK(JohtoWaterWildMons) == BANK(JohtoGrassWildMons)
	assert BANK(KantoWaterWildMons) == BANK(JohtoGrassWildMons)
.loop
	push hl
	ld a, BANK(JohtoWaterWildMons)
	ld bc, WATER_WILDDATA_LENGTH
	call Pokedex_AreaCopyRecord
	jr z, .end
	ld hl, wPokedexAreaBuffer + 2 + 1 ; past the map and the rate
	ld c, NUM_WATERMON
	ld de, WaterMonProbTable
	call Pokedex_AreaSumSlots
	ld [wPokedexAreaValues], a
	ld a, AREA_FORMAT_ONE
	call Pokedex_AreaRowIfAny
	pop hl
	cp ROWS_FULL
	ret z
	ld bc, WATER_WILDDATA_LENGTH
	add hl, bc
	jr .loop

.end
	pop hl
	xor a
	ret

Pokedex_AreaSumSlots:
; in: hl = c slots of (level, species index) in WRAM, de = their probability table
; out: a = the percent of encounters that are the species; hl past the slots
	assert BANK(GrassMonProbTable) == BANK(WaterMonProbTable)
	xor a
	ld [wPokedexAreaPrev], a
	ld [wPokedexAreaSum], a
.slot
	push bc
	push hl
	ld h, d
	ld l, e
	ld a, BANK(GrassMonProbTable)
	call GetFarByte ; this slot's threshold
	pop hl
	inc de
	inc de
	call Pokedex_AreaShare
	inc hl ; level
	push de
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	call Pokedex_AreaIsSpecies
	pop de
	call z, Pokedex_AreaAddShare
	pop bc
	dec c
	jr nz, .slot
	ld a, [wPokedexAreaSum]
	ret

Pokedex_AreaShare:
; in: a = a slot's threshold; out: c = its share, the step from the slot before
	ld b, a
	ld a, [wPokedexAreaPrev]
	ld c, a
	ld a, b
	ld [wPokedexAreaPrev], a
	sub c
	ld c, a
	ret

Pokedex_AreaAddShare:
	ld a, [wPokedexAreaSum]
	add c
	ld [wPokedexAreaSum], a
	ret

Pokedex_AreaFishing:
	ld a, 1
.loop
	ld [wPokedexAreaGroup], a
	cp FISHGROUP_QWILFISH_SWARM
	jr z, .next ; swarms aren't listed
	dec a
	ld hl, FishGroups
	ld bc, FISHGROUP_DATA_LENGTH
	rst AddNTimes
	ld a, BANK(FishGroups)
	ld de, wPokedexAreaBuffer
	call FarCopyBytes
	ld hl, wPokedexAreaBuffer + 1 ; the Old Rod's table
	ld de, wPokedexAreaValues
	ld b, 3 ; Old, Good and Super Rod
.rod
	push bc
	push de
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	push hl
	call .SumRod
	pop hl
	pop de
	ld [de], a
	inc de
	pop bc
	dec b
	jr nz, .rod
	xor a
	ld [wPokedexAreaMap], a ; a group's name, not a map
	ld a, [wPokedexAreaGroup]
	dec a
	ld hl, FishGroupNames
	ld e, a
	ld d, 0
	add hl, de
	add hl, de
	ld a, [hli]
	ld [wPokedexAreaNamePtr], a
	ld a, [hl]
	ld [wPokedexAreaNamePtr + 1], a
	ld a, AREA_FORMAT_RODS
	call Pokedex_AreaRowIfAny
	cp ROWS_FULL
	ret z
.next
	ld a, [wPokedexAreaGroup]
	inc a
	cp NUM_FISHGROUPS + 1
	jr c, .loop
	xor a
	ret

.SumRod:
; in: de = a rod's table; out: a = the percent of bites that are the species
	assert BANK(FishGroups) == BANK(TimeFishGroups)
	xor a
	ld [wPokedexAreaPrev], a
	ld [wPokedexAreaSum], a
	ld h, d
	ld l, e
.bite
	ld a, BANK(FishGroups)
	call GetFarByte ; threshold
	ld [wPokedexAreaThreshold], a
	call Pokedex_AreaShare
	inc hl
	ld a, BANK(FishGroups)
	call GetFarByte ; level, or 0 for a time group
	inc hl
	ld b, a
	push hl
	ld a, BANK(FishGroups)
	call GetFarWord ; species, or the time group
	ld a, b
	and a
	jr nz, .species
; a time group: the species at day, then at nite
	ld a, l
	ld d, c
	ld hl, TimeFishGroups
	ld bc, 6
	rst AddNTimes
	ld c, d
	push hl
	inc hl
	ld a, BANK(TimeFishGroups)
	call GetFarWord
	ld d, h
	ld e, l
	call Pokedex_AreaIsSpecies
	pop hl
	jr z, .add
	ld de, 4
	add hl, de
	ld a, BANK(TimeFishGroups)
	call GetFarWord
.species
	ld d, h
	ld e, l
	call Pokedex_AreaIsSpecies
	jr nz, .no_add
.add
	call Pokedex_AreaAddShare
.no_add
	pop hl
	inc hl
	inc hl
	ld a, [wPokedexAreaThreshold]
	inc a ; 100 percent ends the table
	jr nz, .bite
	ld a, [wPokedexAreaSum]
	; fallthrough

Pokedex_AreaUnitsToPercent:
; in: a = a share out of $ff; out: a = that share as a rounded percent
	ld hl, $ff / 2
	ld de, 100
	and a
	ret z
.multiply
	add hl, de
	dec a
	jr nz, .multiply
	ld de, -$ff
.divide
	add hl, de
	ret nc
	inc a
	jr .divide

Pokedex_AreaHeadbutt:
	ld hl, TreeMonMaps
	jr Pokedex_AreaTrees

Pokedex_AreaRockSmash:
	ld hl, RockMonMaps
	; fallthrough

Pokedex_AreaTrees:
	assert BANK(TreeMonMaps) == BANK(RockMonMaps)
	assert BANK(TreeMonMaps) == BANK(TreeMons)
.loop
	push hl
	ld a, BANK(TreeMonMaps)
	ld bc, 3 ; map, set
	call Pokedex_AreaCopyRecord
	jr z, .end
	ld a, [wPokedexAreaBuffer + 2]
	and a ; TREEMON_SET_NONE
	jr z, .next
	ld hl, TreeMons
	ld e, a
	ld d, 0
	add hl, de
	add hl, de
	ld a, BANK(TreeMons)
	call GetFarWord
	xor a
	ld [wPokedexAreaSum], a
.tree
	ld a, BANK(TreeMons)
	call GetFarByte ; percent, or -1 for the end
	cp -1
	jr z, .got_sum
	ld c, a
	inc hl
	inc hl
	push hl
	ld a, BANK(TreeMons)
	call GetFarWord
	ld d, h
	ld e, l
	pop hl
	inc hl
	inc hl
	call Pokedex_AreaIsSpecies
	call z, Pokedex_AreaAddShare
	jr .tree

.got_sum
	ld a, [wPokedexAreaSum]
	ld [wPokedexAreaValues], a
	ld a, AREA_FORMAT_ONE
	call Pokedex_AreaRowIfAny
	cp ROWS_FULL
	jr z, .full
.next
	pop hl
	inc hl
	inc hl
	inc hl
	jr .loop

.full
	pop hl
	ret

.end
	pop hl
	xor a
	ret

Pokedex_AreaContest:
	ld hl, ContestMons
	xor a
	ld [wPokedexAreaSum], a
.loop
	ld a, BANK(ContestMons)
	call GetFarByte ; percent, or -1 for the end
	cp -1
	jr z, .got_sum
	ld c, a
	inc hl
	push hl
	ld a, BANK(ContestMons)
	call GetFarWord
	ld d, h
	ld e, l
	pop hl
	inc hl
	inc hl
	inc hl ; min level
	inc hl ; max level
	call Pokedex_AreaIsSpecies
	call z, Pokedex_AreaAddShare
	jr .loop

.got_sum
	ld a, GROUP_NATIONAL_PARK
	ld [wPokedexAreaMap], a
	ld a, MAP_NATIONAL_PARK
	ld [wPokedexAreaMap + 1], a
	ld a, [wPokedexAreaSum]
	ld [wPokedexAreaValues], a
	ld a, AREA_FORMAT_ONE
	call Pokedex_AreaRowIfAny
	cp ROWS_FULL
	ret z
	xor a
	ret

Pokedex_AreaRoaming:
	ld hl, wRoamMon1
	ld b, NUM_ROAMMON_STRUCTS
.loop
	push bc
	push hl
	ld a, [hli] ; species
	and a
	jr z, .next
	push hl
	call GetPokemonIndexFromID
	ld d, h
	ld e, l
	pop hl
	call Pokedex_AreaIsSpecies
	jr nz, .next
	ld a, [hli] ; level
	ld [wPokedexAreaValues], a
	ld a, [hli] ; map group
	ld [wPokedexAreaMap], a
	and a
	jr z, .next
	inc a ; GROUP_N_A
	jr z, .next
	ld a, [hl] ; map number
	ld [wPokedexAreaMap + 1], a
	ld a, AREA_FORMAT_LEVEL
	call Pokedex_AreaRow
	cp ROWS_FULL
	jr z, .full
.next
	pop hl
	ld bc, wRoamMon2 - wRoamMon1
	add hl, bc
	pop bc
	dec b
	jr nz, .loop
	xor a
	ret

.full
	pop hl
	pop bc
	ret

Pokedex_AreaWandering:
	assert BANK(OverworldWildMonsGrass) == BANK(OverworldWildMonsWater)
	assert BANK(OverworldWildMonsGrass) == BANK(MonPopulations)
	ld hl, OverworldWildMonsGrass
	call .Areas
	cp ROWS_FULL
	ret z
	ld hl, OverworldWildMonsWater
	call .Areas
	cp ROWS_FULL
	ret z
	ld hl, MonPopulations
.pop_loop
	push hl
	ld a, BANK(MonPopulations)
	ld bc, POP_DATA_LENGTH
	call Pokedex_AreaCopyRecord
	jr z, .end
	ld hl, wPokedexAreaBuffer + 2 + 1 + 1 + MAX_SPAWN_AREAS * SPAWN_AREA_LENGTH
	lb bc, POP_MON_LENGTH, NUM_POP_MON
	call Pokedex_AreaSumWeights
	ld [wPokedexAreaValues], a
	ld a, AREA_FORMAT_ONE
	call Pokedex_AreaRowIfAny
	pop hl
	cp ROWS_FULL
	ret z
	ld bc, POP_DATA_LENGTH
	add hl, bc
	jr .pop_loop

.Areas:
	push hl
	ld a, BANK(OverworldWildMonsGrass)
	ld bc, OW_WILDDATA_LENGTH
	call Pokedex_AreaCopyRecord
	jr z, .end
	ld hl, wPokedexAreaBuffer + 2 + 1 + 1 ; morn roster, past the map, count and chance
	ld de, wPokedexAreaValues
	ld b, 3 ; morn, day, nite
.time
	push bc
	push de
	lb bc, OW_WILDMON_LENGTH, NUM_OW_WILDMON
	call Pokedex_AreaSumWeights
	pop de
	ld [de], a
	inc de
	pop bc
	dec b
	jr nz, .time
	ld a, AREA_FORMAT_TIMES
	call Pokedex_AreaRowIfAny
	pop hl
	cp ROWS_FULL
	ret z
	ld bc, OW_WILDDATA_LENGTH
	add hl, bc
	jr .Areas

.end
	pop hl
	xor a
	ret

Pokedex_AreaSumWeights:
; in: hl = c roster entries of b bytes in WRAM, each a weight then a species index
; out: a = the summed weight of the species' entries; hl past the entries
	xor a
	ld [wPokedexAreaSum], a
.entry
	push bc
	push hl
	ld a, [hli] ; weight
	ld c, a
	ld a, [hli]
	ld e, a
	ld d, [hl]
	call Pokedex_AreaIsSpecies
	call z, Pokedex_AreaAddShare
	pop hl
	pop bc
	ld e, b
	ld d, 0
	add hl, de
	dec c
	jr nz, .entry
	ld a, [wPokedexAreaSum]
	ret

Pokedex_AreaCopyRecord:
; Copy a table record of bc bytes from a:hl to wPokedexAreaBuffer, and its map to wPokedexAreaMap.
; out: z at the table's end (-1)
	ld de, wPokedexAreaBuffer
	call FarCopyBytes
	ld a, [wPokedexAreaBuffer]
	ld [wPokedexAreaMap], a
	ld a, [wPokedexAreaBuffer + 1]
	ld [wPokedexAreaMap + 1], a
	ld a, [wPokedexAreaBuffer]
	inc a
	ret

Pokedex_AreaIsSpecies:
; out: z if de is the selected species
	ld a, [wPokedexAreaSpecies]
	cp e
	ret nz
	ld a, [wPokedexAreaSpecies + 1]
	cp d
	ret

Pokedex_AreaRowIfAny:
; Pokedex_AreaRow, if any of the values is above 0.
	ld [wPokedexAreaFormat], a
	ld hl, wPokedexAreaValues
	ld a, [hli]
	or [hl]
	inc hl
	or [hl]
	ret z
	ld a, [wPokedexAreaFormat]
	; fallthrough

Pokedex_AreaRow:
; Print a place, if it falls on this page, or add it to the nest list in nest mode.
; in: a = AREA_FORMAT_* constant; [wPokedexAreaMap] = the map, or a group of 0 and
;     [wPokedexAreaNamePtr] = a name; [wPokedexAreaValues] = the odds or the level
; out: a = ROWS_FULL if this page is already full
	ld [wPokedexAreaFormat], a
	ld a, [wPokedexAreaMap]
	and a
	jr z, .shown
	ld b, a
	ld a, [wPokedexAreaMap + 1]
	ld c, a
	call GetWorldMapLocation
	and a ; LANDMARK_SPECIAL
	ret z ; secret places stay secret
	cp HIDDEN_LANDMARK
	jr c, .shown
	xor a
	ret

.shown
	ld a, [wPokedexAreaMode]
	and a ; AREA_PRINT
	jmp nz, Pokedex_AreaAppendNest
	ld hl, wPokedexScratch
	ld a, [hl]
	and a
	jr z, .on_page
	dec [hl] ; an earlier page showed it
	xor a
	ret

.on_page
	inc hl
	ld a, [hl]
	cp AREA_ROWS_PER_PAGE
	ld a, ROWS_FULL
	ret z
	ld a, [hl]
	inc [hl]
	add a
	add 9
	ld c, a ; the place's first row
	ld b, 0
	ld hl, wTilemap + 2
	ld a, SCREEN_WIDTH
	rst AddNTimes
	push hl
	call Pokedex_AreaPlaceName
	pop hl
	ld bc, SCREEN_WIDTH
	add hl, bc
	call Pokedex_AreaPlaceValues
	xor a
	ret

Pokedex_AreaPlaceName:
	ld a, [wPokedexAreaMap]
	and a
	jr nz, .map
	ld a, [wPokedexAreaNamePtr]
	ld e, a
	ld a, [wPokedexAreaNamePtr + 1]
	ld d, a
	jmp PlaceString

.map
	ld b, a
	ld a, [wPokedexAreaMap + 1]
	ld c, a
	; fallthrough

PlaceMapNameWithFloor::
; Place at hl the landmark name of map bc, and its floor if the place has several.
	push bc
	push hl
	call GetWorldMapLocation
	ld e, a
	farcall GetLandmarkName
	pop hl
	ld de, wStringBuffer1
	rst PlaceString
	pop de ; map group and number
	ld h, b
	ld l, c
	push hl ; the name's end
	ld hl, PokedexAreaFloors
.floor
	ld a, [hli]
	and a
	jr z, .no_floor
	cp d
	jr nz, .next_map
	ld a, [hli]
	cp e
	jr z, .got_floor
	jr .next_floor

.next_map
	inc hl
.next_floor
	ld a, [hli]
	cp "@"
	jr nz, .next_floor
	jr .floor

.got_floor
	ld d, h
	ld e, l
	pop hl
	inc hl
	jmp PlaceString

.no_floor
	pop hl
	ret

Pokedex_AreaPlaceValues:
; in: hl = the place's second row
	assert HIGH(wPokedexAreaValues) == HIGH(wPokedexAreaValues + 2)
	ld a, LOW(wPokedexAreaValues)
	ld [wPokedexAreaPrev], a
	ld a, [wPokedexAreaFormat]
	cp AREA_FORMAT_LEVEL
	jr z, .level
	cp AREA_FORMAT_ONE
	jr z, .one
	ld de, .TimeTiles
	cp AREA_FORMAT_TIMES
	jr z, .three
	ld de, .RodTiles
.three
	ld b, 3
.value
	ld a, [de]
	inc de
	ld [hli], a
	push de
	push bc
	call .Percent
	pop bc
	pop de
	inc hl
	dec b
	jr nz, .value
	ret

.one
	inc hl
	; fallthrough

.Percent:
; print the next value as "nnn%"
	push hl
	ld a, [wPokedexAreaPrev]
	ld e, a
	ld d, HIGH(wPokedexAreaValues)
	inc a
	ld [wPokedexAreaPrev], a
	lb bc, 1, 3
	call PrintNum
	pop hl
	inc hl
	inc hl
	inc hl
	ld a, "<%>"
	ld [hli], a
	ret

.level
	ld a, "<DEX_LV>"
	ld [hli], a
	ld de, wPokedexAreaValues
	lb bc, PRINTNUM_LEFTALIGN | 1, 3
	jmp PrintNum

.TimeTiles:
	db $65, $6b, $6c ; morn, day, nite
.RodTiles:
	db "OGS" ; Old, Good, Super Rod

Pokedex_FindMoreNests::
; Mark on the Town Map's nest view the places only the AREA page knows of: Headbutt trees, Rock
; Smash rocks, the Bug-Catching Contest and wandering mon.
; in: de = the end of the nest list; [wPokedexAreaRegion] = 0 for Johto, 1 for Kanto
; out: de = its new end
	ld a, e
	ld [wPokedexAreaNestEnd], a
	ld a, d
	ld [wPokedexAreaNestEnd + 1], a
	ld a, AREA_NEST
	ld [wPokedexAreaMode], a
	call Pokedex_AreaGetSpecies
	call Pokedex_AreaHeadbutt
	call Pokedex_AreaRockSmash
	call Pokedex_AreaContest
	call Pokedex_AreaWandering
	xor a ; AREA_PRINT
	ld [wPokedexAreaMode], a
	ld a, [wPokedexAreaNestEnd]
	ld e, a
	ld a, [wPokedexAreaNestEnd + 1]
	ld d, a
	ret

Pokedex_AreaAppendNest:
; Add the map's landmark to the nest list, if it's in the region on show and not listed yet.
	ld a, [wPokedexAreaMap]
	ld b, a
	ld a, [wPokedexAreaMap + 1]
	ld c, a
	call GetWorldMapLocation
	ld c, a
	ld b, 0 ; Johto
	cp KANTO_LANDMARK
	jr c, .got_region
	cp KANTO_LANDMARK_LAST + 1
	jr nc, .got_region
	inc b ; Kanto
.got_region
	ld a, [wPokedexAreaRegion]
	cp b
	jr nz, .done
	ld a, [wPokedexAreaNestEnd]
	ld e, a
	ld a, [wPokedexAreaNestEnd + 1]
	ld d, a
	hlcoord 0, 0
.search
	ld a, l
	cp e
	jr nz, .compare
	ld a, h
	cp d
	jr z, .append
.compare
	ld a, [hli]
	cp c
	jr z, .done
	jr .search

.append
	ld a, c
	ld [de], a
	inc de
	ld a, e
	ld [wPokedexAreaNestEnd], a
	ld a, d
	ld [wPokedexAreaNestEnd + 1], a
.done
	xor a
	ret

INCLUDE "data/maps/dex_floor_names.asm"
INCLUDE "data/wild/fish_group_names.asm"
