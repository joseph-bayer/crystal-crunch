LoadWildMonData:
	call _GrassWildmonLookup
	jr c, .copy
	ld hl, wMornEncounterRate
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	jr .done_copy

.copy
	inc hl
	inc hl
	ld de, wMornEncounterRate
	ld bc, 3
	rst CopyBytes
	ld a, [wNiteEncounterRate]
	ld [wEveEncounterRate], a
.done_copy
	call _WaterWildmonLookup
	ld a, 0 ; no-optimize a = 0
	jr nc, .no_copy
	inc hl
	inc hl
	ld a, [hl]
.no_copy
	ld [wWaterEncounterRate], a
	ret

GetTimeOfDayNotEve:
	ld a, [wTimeOfDay]
	cp EVE_F
	ret nz
	ld a, NITE_F ; ld a, DAY_F to make evening use day encounters
	ret

FindNest:
; Parameters:
; e: 0 = Johto, 1 = Kanto
; wNamedObjectIndex: species
	hlcoord 0, 0
	ld bc, SCREEN_AREA
	xor a
	rst ByteFill
	ld a, [wNamedObjectIndex]
	call GetPokemonIndexFromID
	ld b, h
	ld c, l
	ld a, e
	and a
	jr nz, .kanto
	decoord 0, 0
	ld hl, JohtoGrassWildMons
	call .FindGrass
	ld hl, JohtoWaterWildMons
	call .FindWater
	call .RoamMon1
	jmp .RoamMon2

.kanto
	decoord 0, 0
	ld hl, KantoGrassWildMons
	call .FindGrass
	ld hl, KantoWaterWildMons
	jr .FindWater

.FindGrass:
	ld a, [hl]
	cp -1
	ret z
	push bc
	push hl
	; use the math buffers as storage, since we're not doing any math
	ld a, [hli]
	ldh [hMathBuffer], a
	ld a, [hli]
	ldh [hMathBuffer + 1], a
	inc hl
	inc hl
	inc hl
	ld a, NUM_GRASSMON * 3
	call .SearchMapForMon
	jr nc, .next_grass
	ld [de], a
	inc de

.next_grass
	pop hl
	ld bc, GRASS_WILDDATA_LENGTH
	add hl, bc
	pop bc
	jr .FindGrass

.FindWater:
	ld a, [hl]
	cp -1
	ret z
	push bc
	push hl
	; use the math buffers as storage, since we're not doing any math
	ld a, [hli]
	ldh [hMathBuffer], a
	ld a, [hli]
	ldh [hMathBuffer + 1], a
	inc hl
	ld a, NUM_WATERMON
	call .SearchMapForMon
	jr nc, .next_water
	ld [de], a
	inc de

.next_water
	pop hl
	ld bc, WATER_WILDDATA_LENGTH
	add hl, bc
	pop bc
	jr .FindWater

.SearchMapForMon:
	inc hl
.ScanMapLoop:
	push af
	ld a, [hli]
	cp c
	ld a, [hli]
	jr nz, .next_mon
	cp b
	jr z, .found
.next_mon
	inc hl
	pop af
	dec a
	jr nz, .ScanMapLoop
	and a
	ret

.found
	pop af
	ldh a, [hMathBuffer]
	ld b, a
	ldh a, [hMathBuffer + 1]
	ld c, a

.AppendNest:
	push de
	call GetWorldMapLocation
	ld c, a
	hlcoord 0, 0
	ld de, SCREEN_AREA
.AppendNestLoop:
	ld a, [hli]
	cp c
	jr z, .found_nest
	dec de
	ld a, e
	or d
	jr nz, .AppendNestLoop
	ld a, c
	pop de
	scf
	ret

.found_nest
	pop de
	and a
	ret

.RoamMon1:
	ld a, [wRoamMon1Species]
	ld b, a
	ld a, [wNamedObjectIndex]
	cp b
	ret nz
	ld a, [wRoamMon1MapGroup]
	ld b, a
	ld a, [wRoamMon1MapNumber]
	ld c, a
	call .AppendNest
	ret nc
	ld [de], a
	inc de
	ret

.RoamMon2:
	ld a, [wRoamMon2Species]
	ld b, a
	ld a, [wNamedObjectIndex]
	cp b
	ret nz
	ld a, [wRoamMon2MapGroup]
	ld b, a
	ld a, [wRoamMon2MapNumber]
	ld c, a
	call .AppendNest
	ret nc
	ld [de], a
	inc de
	ret

TryWildEncounter::
; Try to trigger a wild encounter.
	call .EncounterRate
	jr nc, .no_battle
	call ChooseWildEncounter
	jr nz, .no_battle
	call CheckRepelEffect
	jr nc, .no_battle
	xor a
	ret

.no_battle
	xor a ; BATTLETYPE_NORMAL
	ld [wTempWildMonSpecies], a
	ld [wTempWildMonForm], a
	assert NO_MOVE == 0
	ld [wTempWildMonMove], a
	ld [wTempWildMonMove + 1], a
	ld [wBattleType], a
	ld a, 1
	and a
	ret

.EncounterRate:
	call GetMapEncounterRate
	call ApplyMusicEffectOnEncounterRate
	call ApplyCleanseTagEffectOnEncounterRate
	call Random
	cp b
	ret

GetMapEncounterRate:
	ld hl, wMornEncounterRate
	call CheckOnWater
	ld a, wWaterEncounterRate - wMornEncounterRate
	jr z, .ok
	ld a, [wTimeOfDay]
.ok
	ld c, a
	ld b, 0
	add hl, bc
	ld b, [hl]
	ret

ApplyMusicEffectOnEncounterRate::
; Pokemon March and Ruins of Alph signal double encounter rate.
; Pokemon Lullaby halves encounter rate.
	ld a, [wMapMusic]
	cp MUSIC_POKEMON_MARCH
	jr z, .double
	cp MUSIC_RUINS_OF_ALPH_RADIO
	jr z, .double
	cp MUSIC_POKEMON_LULLABY
	ret nz
	srl b
	ret

.double
	sla b
	ret

ApplyCleanseTagEffectOnEncounterRate::
; Cleanse Tag halves encounter rate.
	ld hl, wPartyMon1Item
	ld de, PARTYMON_STRUCT_LENGTH
	ld a, [wPartyCount]
	ld c, a
.loop
	ld a, [hl]
	push hl
	call GetItemIndexFromID
	cphl16 CLEANSE_TAG
	pop hl
	jr z, .cleansetag
	add hl, de
	dec c
	jr nz, .loop
	ret

.cleansetag
	srl b
	ret

ChooseWildEncounter:
; A swarm hands its form and move to the battle through wTempWildMonForm and wTempWildMonMove, and
; a roll that never becomes a battle (Repel, say) must not leave them behind for whatever wild mon
; comes next.
	xor a
	ld [wTempWildMonForm], a
	assert NO_MOVE == 0
	ld [wTempWildMonMove], a
	ld [wTempWildMonMove + 1], a
	call LoadWildMonDataPointer
	jr nc, .nowildbattle
; Roaming beasts aren't met in the grass, only as wandering mon, so one can't be caught twice.

	inc hl
	inc hl
	inc hl
	call CheckOnWater
	ld de, WaterMonProbTable
	jr z, .watermon
	inc hl
	inc hl
	call GetTimeOfDayNotEve
	ld bc, NUM_GRASSMON * 3
	rst AddNTimes
	ld de, GrassMonProbTable

.watermon
; hl contains the pointer to the wild mon data, let's save that to the stack
	push hl
.randomloop
	call Random
	cp 100
	jr nc, .randomloop
	inc a ; 1 <= a <= 100
	ld b, a
	ld h, d
	ld l, e
; This next loop chooses which mon to load up.
.prob_bracket_loop
	ld a, [hli]
	cp b
	jr nc, .got_it
	inc hl
	jr .prob_bracket_loop

.got_it
	ld c, [hl]
	ld b, 0
	pop hl
	add hl, bc ; this selects our mon
	push bc ; c = the slot's offset, for ApplySwarmToWildSlot
	ld a, [hli]
	ld b, a
; If the Pokemon is encountered by surfing, we need to give the levels some variety.
	call CheckOnWater
	jr nz, .ok
; Check if we buff the wild mon, and by how much.
	call Random
	cp 35 percent
	jr c, .ok
	inc b
	cp 65 percent
	jr c, .ok
	inc b
	cp 85 percent
	jr c, .ok
	inc b
	cp 95 percent
	jr c, .ok
	inc b
; Store the level
.ok
	ld a, b
	ld [wCurPartyLevel], a

	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop bc
	call ApplySwarmToWildSlot
	call ValidateTempWildMonSpecies
	jr c, .nowildbattle

	ld a, l
	sub LOW(UNOWN)
	jr nz, .done
	if HIGH(UNOWN) > 1
		ld a, h
		cp HIGH(UNOWN)
	elif HIGH(UNOWN) == 1
		ld a, h
		dec a
	else
		or h
	endc
	jr nz, .done

	ld a, [wUnlockedUnowns]
	and a
	jr z, .nowildbattle

.done
	call GetPokemonIDFromIndex
	ld [wTempWildMonSpecies], a

.startwildbattle
	xor a
	ret

.nowildbattle
	ld a, 1
	and a
	ret

INCLUDE "data/wild/probabilities.asm"

CheckRepelEffect::
; If there is no active Repel, there's no need to be here.
	ld a, [wRepelEffect]
	and a
	jr z, .encounter
; Get the first Pokemon in your party that isn't fainted.
	ld hl, wPartyMon1HP
	ld bc, PARTYMON_STRUCT_LENGTH - 1
.loop
	ld a, [hli]
	or [hl]
	jr nz, .ok
	add hl, bc
	jr .loop

.ok
; to PartyMonLevel
rept 4
	dec hl
endr

	ld a, [wCurPartyLevel]
	cp [hl]
	jr nc, .encounter
	and a
	ret

.encounter
	scf
	ret

LoadWildMonDataPointer:
	call CheckOnWater
	jr z, _WaterWildmonLookup

_GrassWildmonLookup:
	ld hl, JohtoGrassWildMons
	ld de, KantoGrassWildMons
	call _JohtoWildmonCheck
	ld bc, GRASS_WILDDATA_LENGTH
	jr _NormalWildmonOK

_WaterWildmonLookup:
	ld hl, JohtoWaterWildMons
	ld de, KantoWaterWildMons
	call _JohtoWildmonCheck
	ld bc, WATER_WILDDATA_LENGTH
	jr _NormalWildmonOK

_JohtoWildmonCheck:
	call IsInJohto
	and a
	ret z
	ld h, d
	ld l, e
	ret

_NormalWildmonOK:
	call CopyCurrMapDE
	jr LookUpWildmonsForMapDE

CopyCurrMapDE:
	ld a, [wMapGroup]
	ld d, a
	ld a, [wMapNumber]
	ld e, a
	ret

LookUpGrassJohtoWildmons::
	ld hl, JohtoGrassWildMons
	ld bc, GRASS_WILDDATA_LENGTH
LookUpWildmonsForMapDE:
.loop
	push hl
	ld a, [hl]
	inc a
	jr z, .nope
	ld a, d
	cp [hl]
	jr nz, .next
	inc hl
	ld a, e
	cp [hl]
	jr z, .yup

.next
	pop hl
	add hl, bc
	jr .loop

.nope
	pop hl
	and a
	ret

.yup
	pop hl
	scf
	ret

RollBeastsAtBurnedTower::
; Called as the Burned Tower scene starts, before the beasts wake. Each gets a fresh form, shiny at
; 1/512, so soft-resetting before the scene hunts all three at once. Suicune doesn't roam, so its
; form goes in the otherwise unused wRoamMon3, for Tin Tower.
	ld hl, wRoamMon1Form
	call .Reroll
	ld hl, wRoamMon2Form
	call .Reroll
	ld hl, wRoamMon3Form
.Reroll:
	ld [hl], PLAIN_FORM
	jr RollLegendaryShiny

RollElmsLabStarters::
; Walking into Elm's lab before the pick: a fresh 1/512 for each starter on the table, all at once,
; so soft-resetting outside the lab hunts all three. Each result goes in that starter's flag, which
; its sprite (IsStarterShiny) and the pick read.
	ld de, EVENT_ELMS_LAB_CYNDAQUIL_SHINY
	call .Roll
	ld de, EVENT_ELMS_LAB_TOTODILE_SHINY
	call .Roll
	ld de, EVENT_ELMS_LAB_CHIKORITA_SHINY
.Roll:
	push de
	ld hl, wTempByteValue
	ld [hl], PLAIN_FORM
	call RollLegendaryShiny
	pop de
	ld a, [wTempByteValue]
	assert SHINY_MASK == 1 << 7 && RESET_FLAG == 0 && SET_FLAG == 1
	rlca ; the shiny bit into bit 0: RESET_FLAG or SET_FLAG
	and 1
	ld b, a
	jmp EventFlagAction

RollTinTowerSuicuneShiny::
; As Tin Tower 1F loads with Suicune there: another 1/512 chance if it isn't shiny yet, rolled
; before its sprite appears.
	ld hl, wRoamMon3Form
	; fallthrough

RollLegendaryShiny::
; in: hl = a legendary's form byte
; Sets its shiny bit at 1/512 (1/256, then LEGENDARY_SHINY_NUMERATOR/256). Shiny stays shiny.
	ld a, [hl]
	and SHINY_MASK
	ret nz
if DEF(_DEBUG)
	push hl
	ld de, EVENT_DEBUG_FORCE_SHINY_BEASTS
	ld b, CHECK_FLAG
	call EventFlagAction
	pop hl
	ld a, c
	and a
	jr nz, .shiny
endc
	call Random
	and a
	ret nz ; 255/256 not shiny
	call Random
	cp LEGENDARY_SHINY_NUMERATOR
	ret nc ; 128/256 still not shiny
.shiny
	ld a, [hl]
	or SHINY_MASK
	ld [hl], a
	ret

InitRoamMons:
; Release Raikou and Entei at L40, as the Burned Tower does. Their DVs and forms are left alone.
	ld a, 40
	call InitRoamRaikou
	ld a, 40
	jr InitRoamEntei

InitRoamRaikou::
; in: a = level
; Puts Raikou on its release route, Route 42, with HP 0 so its first battle rolls new stats.
	ld bc, GROUP_ROUTE_42 << 8 | MAP_ROUTE_42
	ld de, wRoamMon1
	ld hl, RAIKOU
	jr InitRoamMon

InitRoamEntei::
; in: a = level
; Puts Entei on its release route, Route 37, with HP 0 so its first battle rolls new stats.
	ld bc, GROUP_ROUTE_37 << 8 | MAP_ROUTE_37
	ld de, wRoamMon2
	ld hl, ENTEI
	; fallthrough

InitRoamMon:
; in: a = level, b = map group, c = map number, de = roam struct, hl = species index
	push af
	call GetPokemonIDFromIndex
	assert wRoamMon1Species == wRoamMon1 && wRoamMon1Level == wRoamMon1Species + 1 		&& wRoamMon1MapGroup == wRoamMon1Level + 1 && wRoamMon1MapNumber == wRoamMon1MapGroup + 1 		&& wRoamMon1HP == wRoamMon1MapNumber + 1
	ld [de], a
	inc de
	pop af
	ld [de], a
	inc de
	ld a, b
	ld [de], a
	inc de
	ld a, c
	ld [de], a
	inc de
	xor a ; generate new stats
	ld [de], a
	ret

UpdateRoamMonsAfterBattle::
; After a battle: a roamer on the player's map holds still until the player leaves, except the one
; just fought.
; in: a = the species ID of the roamer just fought, or 0 after any other battle
	ld [wRoamMonsHoldExcept], a
	ld a, TRUE
	ld [wRoamMonsHold], a
	call UpdateRoamMons
	xor a
	ld [wRoamMonsHold], a
	ret

UpdateRoamMons:
if DEF(_DEBUG)
	call .DebugFollowPlayer
	jmp c, _BackUpMapIndices
endc
	ld a, [wRoamMon1MapGroup]
	cp GROUP_N_A
	jr z, .SkipRaikou
	ld b, a
	ld a, [wRoamMon1MapNumber]
	ld c, a
	ld a, [wRoamMon1Species]
	call .IsHeldHere
	jr z, .SkipRaikou
	call .Update
	ld a, b
	ld [wRoamMon1MapGroup], a
	ld a, c
	ld [wRoamMon1MapNumber], a

.SkipRaikou:
	ld a, [wRoamMon2MapGroup]
	cp GROUP_N_A
	jr z, .SkipEntei
	ld b, a
	ld a, [wRoamMon2MapNumber]
	ld c, a
	ld a, [wRoamMon2Species]
	call .IsHeldHere
	jr z, .SkipEntei
	call .Update
	ld a, b
	ld [wRoamMon2MapGroup], a
	ld a, c
	ld [wRoamMon2MapNumber], a

.SkipEntei:
	ld a, [wRoamMon3MapGroup]
	cp GROUP_N_A
	jr z, .Finished
	ld b, a
	ld a, [wRoamMon3MapNumber]
	ld c, a
	call .Update
	ld a, b
	ld [wRoamMon3MapGroup], a
	ld a, c
	ld [wRoamMon3MapNumber], a

.Finished:
	jmp _BackUpMapIndices

.IsHeldHere:
; in: a = a roamer's species ID, bc = its map
; out: z if it holds still: a battle's move, on the player's map, and not the one fought
	ld e, a
	ld a, [wRoamMonsHold]
	and a
	jr z, .moves
	ld a, [wRoamMonsHoldExcept]
	cp e
	jr z, .moves
	ld a, [wMapGroup]
	cp b
	ret nz
	ld a, [wMapNumber]
	cp c
	ret

.moves
	or 1
	ret

if DEF(_DEBUG)
.DebugFollowPlayer:
; The debug menu's BEASTS FOLLOW: on a map change onto a roaming route, the roamers land on it too.
; out: carry if it put them here
	ld a, [wRoamMonsHold]
	and a
	ret nz ; a battle's move: leave that alone
	ld de, EVENT_DEBUG_BEASTS_FOLLOW_PLAYER
	ld b, CHECK_FLAG
	call EventFlagAction
	ld a, c
	and a
	ret z
	ld a, [wMapGroup]
	ld b, a
	ld a, [wMapNumber]
	ld c, a
	ld hl, RoamMaps
.follow_search
	ld a, [hl]
	cp -1
	ret z ; not a roaming route; `cp -1` has cleared carry
	cp b
	jr nz, .follow_next
	inc hl
	ld a, [hld]
	cp c
	jr z, .follow_here
.follow_next
	ld a, [hli]
	and a
	jr nz, .follow_next
	jr .follow_search

.follow_here
	ld a, [wRoamMon1MapGroup]
	cp GROUP_N_A
	jr z, .follow_entei
	ld a, b
	ld [wRoamMon1MapGroup], a
	ld a, c
	ld [wRoamMon1MapNumber], a
.follow_entei
	ld a, [wRoamMon2MapGroup]
	cp GROUP_N_A
	jr z, .followed
	ld a, b
	ld [wRoamMon2MapGroup], a
	ld a, c
	ld [wRoamMon2MapNumber], a
.followed
	scf
	ret
endc

.Update:
	ld hl, RoamMaps
.loop
; Are we at the end of the table?
	ld a, [hl]
	cp -1
	ret z
; Is this the correct entry?
	ld a, b
	cp [hl]
	jr nz, .next
	inc hl
	ld a, c
	cp [hl]
	jr z, .yes
; We don't have the correct entry yet, so let's continue.  A 0 terminates each entry.
.next
	ld a, [hli]
	and a
	jr nz, .next
	jr .loop

; We have the correct entry now, so let's choose a random map from it.
.yes
	inc hl
	ld d, h
	ld e, l
.update_loop
	ld h, d
	ld l, e
; Choose which map to warp to.
	call Random
	and %00011111 ; 1/8n chance it moves to a completely random map, where n is the number of roaming connections from the current map.
	jr z, JumpRoamMon
	and %11
	cp [hl]
	jr nc, .update_loop ; invalid index, try again
	inc hl
	ld c, a
	ld b, 0
	add hl, bc
	add hl, bc
	ld a, [wRoamMons_LastMapGroup]
	cp [hl]
	jr nz, .done
	inc hl
	ld a, [wRoamMons_LastMapNumber]
	cp [hl]
	jr z, .update_loop
	dec hl

.done
	ld a, [hli]
	ld b, a
	ld c, [hl]
	ret

JumpRoamMons:
	ld a, [wRoamMon1MapGroup]
	cp GROUP_N_A
	jr z, .SkipRaikou
	call JumpRoamMon
	ld a, b
	ld [wRoamMon1MapGroup], a
	ld a, c
	ld [wRoamMon1MapNumber], a

.SkipRaikou:
	ld a, [wRoamMon2MapGroup]
	cp GROUP_N_A
	jr z, .SkipEntei
	call JumpRoamMon
	ld a, b
	ld [wRoamMon2MapGroup], a
	ld a, c
	ld [wRoamMon2MapNumber], a

.SkipEntei:
	ld a, [wRoamMon3MapGroup]
	cp GROUP_N_A
	jr z, _BackUpMapIndices
	call JumpRoamMon
	ld a, b
	ld [wRoamMon3MapGroup], a
	ld a, c
	ld [wRoamMon3MapNumber], a
	jr _BackUpMapIndices

JumpRoamMon:
.loop
	ld hl, RoamMaps
.innerloop1
	; 0-15 are all valid indexes into RoamMaps,
	; so this retry loop is unnecessary
	; since NUM_ROAMMON_MAPS happens to be 16
	call Random
	maskbits NUM_ROAMMON_MAPS
	cp NUM_ROAMMON_MAPS
	jr nc, .innerloop1
	inc a
	ld b, a
.innerloop2 ; Loop to get hl to the address of the chosen roam map.
	dec b
	jr z, .ok
.innerloop3 ; Loop to skip the current roam map, which is terminated by a 0.
	ld a, [hli]
	and a
	jr nz, .innerloop3
	jr .innerloop2
; Check to see if the selected map is the one the player is currently in.  If so, try again.
.ok
	ld a, [wMapGroup]
	cp [hl]
	jr nz, .done
	inc hl
	ld a, [wMapNumber]
	cp [hl]
	jr z, .loop
	dec hl
; Return the map group and number in bc.
.done
	ld a, [hli]
	ld b, a
	ld c, [hl]
	ret

_BackUpMapIndices:
	ld a, [wRoamMons_CurMapNumber]
	ld [wRoamMons_LastMapNumber], a
	ld a, [wRoamMons_CurMapGroup]
	ld [wRoamMons_LastMapGroup], a
	ld a, [wMapNumber]
	ld [wRoamMons_CurMapNumber], a
	ld a, [wMapGroup]
	ld [wRoamMons_CurMapGroup], a
	ret

INCLUDE "data/wild/roammon_maps.asm"

ValidateTempWildMonSpecies:
	ld a, h
	or l
	scf
	ret z
	ld a, h
	if LOW(NUM_POKEMON) == $FF
		cp HIGH(NUM_POKEMON) + 1
	else
		cp HIGH(NUM_POKEMON)
		ccf
		ret nz
		ld a, l
		cp LOW(NUM_POKEMON) + 1
	endc
	ccf
	ret

GetCallerRouteWildGrassMons:
	farcall GetCallerLocation
	ld d, b
	ld e, c
	ld hl, JohtoGrassWildMons
	ld bc, GRASS_WILDDATA_LENGTH
	call LookUpWildmonsForMapDE
	jr c, .found
	ld hl, KantoGrassWildMons
	call LookUpWildmonsForMapDE
	ret nc ; no carry = no grass wild mons for that route
.found
	ld bc, 5 ; skip the map ID and encounter rates
	add hl, bc
	call GetTimeOfDayNotEve
	ld bc, NUM_GRASSMON * 3
	rst AddNTimes
	scf
	ret

; Finds a rare wild Pokemon in the route of the trainer calling, then checks if it's been Seen already.
; The trainer will then tell you about the Pokemon if you haven't seen it.
RandomUnseenWildMon:
	call GetCallerRouteWildGrassMons
	jr nc, .done
	push hl
.randloop1
	call Random
	and %11
	jr z, .randloop1
	ld bc, 10 ; skip three mons plus the level of the fourth
	add hl, bc
	ld c, a
	add hl, bc
	add hl, bc
	add hl, bc
	; We now have the pointer to one of the last (rarest) three wild Pokemon found in that area.
	; Load the species index of this rare Pokemon
	ld a, [hli]
	ld d, [hl]
	ld e, a
	pop hl
	inc hl ; Species index of the most common Pokemon on that route
	ld b, 4
.loop2
	ld a, [hli]
	cp e ; Compare this common Pokemon with the rare one stored in de.
	ld a, [hli]
	jr nz, .next
	cp d
	jr z, .done
.next
	inc hl
	dec b
	jr nz, .loop2
; This Pokemon truly is rare.
	push de
	call CheckSeenMonIndex
	pop bc
	jr nz, .done
; Since we haven't seen it, have the caller tell us about it.
	ld de, wStringBuffer1
	call CopyName1
	ld h, b
	ld l, c
	call GetPokemonIDFromIndex
	ld [wNamedObjectIndex], a
	call GetPokemonName
	ld hl, .JustSawSomeRareMonText
	call PrintText
	xor a
	ld [wScriptVar], a
	ret

.done
	ld a, $1
	ld [wScriptVar], a
	ret

.JustSawSomeRareMonText:
	text_far _JustSawSomeRareMonText
	text_end

RandomPhoneWildMon:
	call GetCallerRouteWildGrassMons
	call Random
	and %11
	ld c, a
	ld b, 0
	add hl, bc
	add hl, bc
	add hl, bc
	inc hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call GetPokemonIDFromIndex
	ld [wNamedObjectIndex], a
	call GetPokemonName
	ld hl, wStringBuffer1
	ld de, wStringBuffer4
	ld bc, MON_NAME_LENGTH
	jmp CopyBytes

RandomPhoneMon:
; Get a random monster owned by the trainer who's calling.
	farcall GetCallerLocation
	ld hl, TrainerGroups
	ld a, d
	dec a
	ld c, a
	ld b, 0
	add hl, bc
	add hl, bc
	add hl, bc
	ld a, BANK(TrainerGroups)
	call GetFarByte
	ld [wTrainerGroupBank], a
	inc hl
	ld a, BANK(TrainerGroups)
	call GetFarWord

.skip_trainer
	dec e
	jr z, .skipped
.skip
	ld a, [wTrainerGroupBank]
	call GetFarByte
	add l
	ld l, a
	jr nc, .skip_trainer
	inc h
	jr .skip_trainer
.skipped
	inc hl

.skip_name
	ld a, [wTrainerGroupBank]
	call GetFarByte
	inc hl
	cp "@"
	jr nz, .skip_name

	ld a, [wTrainerGroupBank]
	call GetFarByte
	inc hl
	ld c, a
	ld a, 3
	bit TRAINERTYPE_ITEM_F, c
	jr z, .no_item
	inc a
	inc a
.no_item
	bit TRAINERTYPE_FORM_F, c
	jr z, .no_form
	inc a
.no_form
	bit TRAINERTYPE_MOVES_F, c
	jr z, .no_moves
	add NUM_MOVES * 2
.no_moves
	ld c, a
	ld b, 0

	ld e, b
	push hl
.count_mon
	inc e
	add hl, bc
	ld a, [wTrainerGroupBank]
	call GetFarByte
	cp -1
	jr nz, .count_mon
	pop hl

.rand
	call Random
	maskbits PARTY_LENGTH
	cp e
	jr nc, .rand

	inc a
.get_mon
	dec a
	jr z, .got_mon
	add hl, bc
	jr .get_mon
.got_mon

	inc hl ; species
	ld a, [wTrainerGroupBank]
	call GetFarWord
	call GetPokemonIDFromIndex
	ld [wNamedObjectIndex], a
	call GetPokemonName
	ld hl, wStringBuffer1
	ld de, wStringBuffer4
	ld bc, MON_NAME_LENGTH
	jmp CopyBytes

INCLUDE "data/wild/johto_grass.asm"
INCLUDE "data/wild/johto_water.asm"
INCLUDE "data/wild/kanto_grass.asm"
INCLUDE "data/wild/kanto_water.asm"
GetSwarmRow::
; in: a = a SWARM_* id
; out: hl = that swarm's row in SwarmTable
; Preserves bc and de.
	push bc
	dec a ; the ids are 1-based, because 0 means an empty wActiveSwarms slot
	ld bc, SWARM_ENTRY_LENGTH
	ld hl, SwarmTable
	rst AddNTimes
	pop bc
	ret

ApplySwarmToWildSlot:
; A swarm takes some of its map's encounter slots (SWARM_GRASS_SLOTS / SWARM_WATER_SLOTS) and
; substitutes its own species, form and move into them. The slot's level stands, so a swarm is
; route-appropriate wherever it is put, and the map's encounter rate is untouched -- a swarm
; changes what you meet, not how often.
; in: hl = the rolled slot's species index, c = that slot's offset in its table (index * 3)
; out: hl = the species to battle
	push hl
; the slot's index, from its offset
	ld a, c
	ld c, -1
.div3
	inc c
	sub 3
	jr nc, .div3
; the terrain being rolled, and which slots its swarms take
	call CheckOnWater
	ld b, SWARM_WATER
	ld a, SWARM_WATER_SLOTS
	jr z, .got_terrain
	ld b, SWARM_GRASS
	ld a, SWARM_GRASS_SLOTS
.got_terrain
; is the rolled slot one of them?
	inc c
.find_bit
	dec c
	jr z, .test_bit
	rrca
	jr .find_bit

.test_bit
	rrca
	jr nc, .not_swarmed
; and is this map swarming, on that terrain?
	call CopyCurrMapDE
	call GetActiveSwarmForMap
	jr nc, .not_swarmed

	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a ; de = the swarm's species
	push hl
	ld bc, 1 + 2 + 1 + 2
	add hl, bc ; past the form, map, terrain and gate, to the move
	ld a, [hli]
	ld [wTempWildMonMove], a
	ld a, [hl]
	ld [wTempWildMonMove + 1], a
	pop hl
	ld a, [hl]
; The form reaches the battle through the same byte loadwildmon uses, which the battle takes whole
; and skips its own shiny roll for. So the swarm's shininess is rolled into that byte here. A plain
; form that comes out not shiny is 0, which leaves the battle's ordinary form and shiny rolls in
; charge -- hence about 1/482 for a plain-form swarm rather than exactly 1/512.
	call RollSwarmShiny
	ld [wTempWildMonForm], a
	pop hl ; the slot's own species, displaced
	ld h, d
	ld l, e
	ret

.not_swarmed
	pop hl
	ret

RollSwarmShiny:
; in: a = a swarm mon's form byte
; out: a = that byte, with SHINY_MASK set if this one is shiny
; The same two stages as every other shiny roll: a 1/256 gate, then SWARM_SHINY_NUMERATOR out of 256.
; A row that is always shiny already carries the bit and keeps it.
	ld b, a
	and SHINY_MASK
	jr nz, .done
if DEF(_DEBUG) && SWARM_DEBUG_FORCE_SHINY
	jr .shiny
endc
	call Random ; preserves bc
	and a
	jr nz, .done ; 255/256 not shiny
	call Random
	cp SWARM_SHINY_NUMERATOR
	jr nc, .done
.shiny
	ld a, b
	or SHINY_MASK
	ret

.done
	ld a, b
	ret

DailySwarmBroadcast::
; For the Collection Guild's radio station. Rolls today's swarm if that has not happened yet,
; and loads its names for the broadcast: the species into wMonOrItemNameBuffer and its map's
; landmark into wStringBuffer1. The swarm only starts once the player hears where it is -- see
; StartDailySwarm.
; out: carry if there is a swarm to announce
	ld a, [wDailySwarm]
	and a
	jr nz, .rolled

; Every studied row is equally likely. Count the ones on offer, pick a number below that, then
; walk the rows again to find it.
	lb bc, FIRST_STUDIED_SWARM, 0 ; b = the row, c = how many are on offer
.count
	ld a, b
	call .IsOnOffer
	jr nc, .count_next
	inc c
.count_next
	inc b
	ld a, b
	cp NUM_SWARMS + 1
	jr c, .count

	ld a, c
	and a
	ret z ; nothing to report, e.g. before the Elite Four if every row is in Kanto
	call RandomRange
	ld c, a
	ld b, FIRST_STUDIED_SWARM
.pick
	ld a, b
	call .IsOnOffer
	jr nc, .pick_next
	ld a, c
	and a
	jr z, .picked
	dec c
.pick_next
	inc b
	jr .pick

.picked
	ld a, b
	ld [wDailySwarm], a
.rolled
	call GetSwarmRow
	ld a, [hli]
	push hl
	ld h, [hl]
	ld l, a
	call GetPokemonIDFromIndex
	ld [wNamedObjectIndex], a
	call GetPokemonName
	ld hl, wStringBuffer1
	ld de, wMonOrItemNameBuffer
	ld bc, MON_NAME_LENGTH
	rst CopyBytes
	pop hl
	inc hl
	inc hl ; past the form, to the map
	ld a, [hli]
	ld b, a
	ld c, [hl]
	call GetWorldMapLocation
	ld e, a
	farcall GetLandmarkName
	scf
	ret

.IsOnOffer:
; in: a = a SWARM_* id
; out: carry if the Guild can report it. Not if it was rolled on either of the last two days
; (wSwarmHistory). A row with a story gate waits for its event flag, and Kanto's rows wait for
; the Elite Four.
; Preserves bc.
	ld hl, wSwarmHistory
	cp [hl] ; an empty entry is 0, which no id is
	jr z, .recent
	inc hl
	cp [hl]
	jr z, .recent
	push bc
	call GetSwarmRow
	push hl
	ld bc, 2 + 1 + 2 + 1
	add hl, bc ; past the species, form, map and terrain, to the gate
	ld a, [hli]
	ld e, a
	ld d, [hl]
	and d
	inc a
	jr z, .no_gate ; SWARM_NO_GATE
	ld b, CHECK_FLAG
	call EventFlagAction
	ld a, c
	and a
	jr nz, .no_gate
	pop hl
	jr .done ; `and a` has cleared carry

.no_gate
	pop hl
	inc hl
	inc hl
	inc hl ; past the species and form, to the map
	ld a, [hli]
	ld b, a
	ld c, [hl]
	call GetWorldMapLocation
	cp KANTO_LANDMARK
	jr c, .on_offer
	ld de, EVENT_BEAT_ELITE_FOUR
	ld b, CHECK_FLAG
	call EventFlagAction
	ld a, c
	and a
	jr z, .done
.on_offer
	scf
.done
	pop bc
	ret

.recent
	and a
	ret

IsDailySwarmRocket::
; For the radio, which picks Team Rocket's lines for their mon.
; out: carry if today's swarm is one of SWARM_ROCKET's rows
	ld a, [wDailySwarm]
	and a
	ret z ; `and a` has cleared carry
	call GetSwarmRow
	ld bc, 2 + 1 + 2
	add hl, bc ; past the species, form and map, to the terrain
	ld a, [hl]
	add a
	assert SWARM_ROCKET_F == 7
	ret

StartDailySwarm::
; The player has heard where today's swarm is, so it begins.
	ld a, [wDailySwarm]
	and a
	ret z
	; fallthrough

StartSwarm::
; in: a = a SWARM_* id
; Claims a free wActiveSwarms slot for it. Does nothing if that swarm is already running, if its
; map already has a swarm of the same terrain, or if every slot is taken.
	ld c, a
	call IsSwarmActive
	ret c

	ld a, c
	call GetSwarmRow
	inc hl
	inc hl
	inc hl ; past the species and form, to the map
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld e, a
	ld a, [hl]
	and SWARM_TERRAIN_MASK
	ld b, a ; its terrain
	call GetActiveSwarmForMap ; preserves bc
	ret c

	ld hl, wActiveSwarms
	ld b, MAX_ACTIVE_SWARMS
.find_free_slot
	ld a, [hl]
	and a
	jr z, .claim
	inc hl
	dec b
	jr nz, .find_free_slot
	ret

.claim
	ld [hl], c
	ret

GetActiveSwarmIcon::
; For the Pokégear map, which lives in another bank and so cannot read a SwarmTable row itself.
; in: a = a wActiveSwarms slot, 0-based
; out: carry, hl = the swarm's species index, d = its form byte, e = its map's landmark, if that
; slot holds a swarm
	ld e, a
	ld d, 0
	ld hl, wActiveSwarms
	add hl, de
	ld a, [hl]
	and a
	ret z ; an empty slot; `and a` has cleared carry

	call GetSwarmRow
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	push de ; the species
	ld a, [hli]
	push af ; the form
	ld a, [hli]
	ld b, a
	ld c, [hl]
	call GetWorldMapLocation
	ld e, a
	pop af
	ld d, a
	pop hl
	scf
	ret

IsSwarmActive::
; in: a = a SWARM_* id
; out: carry if it is running
	ld hl, wActiveSwarms
	ld b, MAX_ACTIVE_SWARMS
.loop
	cp [hl] ; an empty slot is 0, which no id is
	jr z, .yes
	inc hl
	dec b
	jr nz, .loop
	and a
	ret

.yes
	scf
	ret

CheckAnySwarm::
; out: carry if any swarm is running
	ld hl, wActiveSwarms
	ld b, MAX_ACTIVE_SWARMS
	xor a
.loop
	or [hl]
	inc hl
	dec b
	jr nz, .loop
	and a
	ret z
	scf
	ret

GetSwarmSpeciesForMap::
; For the overworld roll, which lives in another bank and so cannot read a SwarmTable row itself.
; in: d = map group, e = map number, b = SWARM_GRASS or SWARM_WATER
; out: carry, de = the swarm's species, a = its form byte and bc = its move, if that map is
; swarming there
	call GetActiveSwarmForMap
	ret nc
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	push hl
	ld bc, 1 + 2 + 1 + 2
	add hl, bc ; past the form, map, terrain and gate, to the move
	ld a, [hli]
	ld b, [hl]
	ld c, a
	pop hl
	ld a, [hl]
	scf
	ret

IsMapSwarming::
; in: d = map group, e = map number
; out: carry if a swarm of either terrain is running there
	ld b, SWARM_GRASS
	call GetActiveSwarmForMap
	ret c
	ld b, SWARM_WATER
	; fallthrough

GetActiveSwarmForMap::
; Find the swarm running on a map, if one is.
; in: d = map group, e = map number, b = SWARM_GRASS or SWARM_WATER
; out: carry and hl = its row in SwarmTable, or no carry
; The terrain is matched as well as the map, so a grass swarm never reaches a map's surf slots
; or its swimming overworld mon, and a water swarm never reaches its grass ones.
	push de
	push bc
	ld hl, wActiveSwarms
	ld c, MAX_ACTIVE_SWARMS
.loop
	ld a, [hl]
	and a
	jr z, .next ; an empty slot

	push hl ; the slot being read
	call GetSwarmRow
	push hl ; the row
	inc hl
	inc hl
	inc hl ; past the species and form, to the map
	ld a, [hli]
	cp d
	jr nz, .no_match
	ld a, [hli]
	cp e
	jr nz, .no_match
	ld a, [hl]
	and SWARM_TERRAIN_MASK
	cp b
	jr nz, .no_match

	pop hl ; the row, which is the answer
	pop de ; the slot, no longer needed
	pop bc
	pop de
	scf
	ret

.no_match
	pop hl ; the row
	pop hl ; the slot
.next
	inc hl
	dec c
	jr nz, .loop

	pop bc
	pop de
	and a
	ret

INCLUDE "data/wild/swarms.asm"
