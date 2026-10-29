GetOverworldMonSlot::
; Look up what one of this map's SPRITE_OW_MON_* slots stands for.
; in:  a = the slot, 0-based (SPRITE_OW_MON_n - SPRITE_OW_MON)
; out: carry set, hl = the species index and a = the form byte, if the map fills that slot
;      carry clear otherwise, and the caller should draw nothing
;
; The table is scanned rather than cached in WRAM. It is read when an object's graphics are
; loaded -- on map setup, and again as an object scrolls onto the screen -- never per frame, and
; a scan is a few dozen comparisons. Keeping it out of WRAM keeps it out of the save block.
	ld e, a ; the slot wanted

; A rolled encounter beats the static table, which is how a wandering Route 29 Sentret and the
; Blackthorn Dratini come out of the same lookup.
	call GetOverworldMonEncounter
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a ; bc = the rolled species, 0 when nothing has been rolled into this slot
	ld d, [hl] ; and its form
	ld a, b
	or c
	jr z, .static_table
	ld h, b
	ld l, c
	ld a, d
	scf
	ret

.static_table
; During the Open League, an Elite Four room's partner is the seat holder's
	farcall EliteFourRoomPartner
	ret c
	ld hl, OverworldMonObjects

.map_loop
	ld a, [hli]
	cp -1
	jr z, .not_found
	ld d, a ; this row's map group
	ld a, [hli]
	ld c, a ; this row's map number
	ld a, [hli]
	ld b, a ; how many mon this row declares

	ld a, [wMapGroup]
	cp d
	jr nz, .skip_row
	ld a, [wMapNumber]
	cp c
	jr z, .found_map

.skip_row
	ld a, b
	and a
	jr z, .map_loop
.skip_loop
	call .NextEntry
	dec b
	jr nz, .skip_loop
	jr .map_loop

.found_map
	ld a, e
	cp b
	jr nc, .not_found ; this map has no entry for that slot
	and a
	jr z, .at_entry
	ld b, a
.walk_loop
	call .NextEntry
	dec b
	jr nz, .walk_loop

.at_entry
	ld a, [hli]
	ld c, a ; species index, low
	ld a, [hli]
	ld b, a ; species index, high
	ld a, [hl] ; the form byte
	ld h, b
	ld l, c
	bit ELMS_STARTER_FORM_F, a
	jr z, .got_form
; One of Elm's starters: shiny exactly when the lab rolled it so. The marker itself is no form.
	xor ELMS_STARTER_FORM
	push af
	call IsStarterShiny ; preserves hl
	jr nc, .starter_plain
	pop af
	or SHINY_MASK
	scf
	ret

.starter_plain
	pop af
.got_form
	scf
	ret

.not_found
	and a
	ret

.NextEntry:
	ld a, l
	add OW_MON_SLOT_LENGTH
	ld l, a
	adc h
	sub l
	ld h, a
	ret

IsStarterShiny::
; in:  hl = a species index
; out: carry if it is one of Elm's starters or their evolutions, and the lab rolled that starter
;      shiny. Preserves hl.
	push hl
	ld d, h
	ld e, l
	ld hl, StarterShinyFlags
.loop
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	or c
	jr z, .done ; the end; `or` has cleared carry
	ld a, c
	cp e
	jr nz, .next
	ld a, b
	cp d
	jr z, .found
.next
	inc hl
	inc hl
	jr .loop

.found
	ld a, [hli]
	ld e, a
	ld d, [hl]
	ld b, CHECK_FLAG
	call EventFlagAction
	ld a, c
	and a ; clears carry
	jr z, .done
	scf
.done
	pop hl
	ret

StarterShinyFlags:
; Each of Elm's starters' lines, and the lab flag that says whether that starter was rolled shiny:
; read for the starters on the lab's table, and for Silver's stolen line.
	dw CHIKORITA,  EVENT_ELMS_LAB_CHIKORITA_SHINY
	dw BAYLEEF,    EVENT_ELMS_LAB_CHIKORITA_SHINY
	dw MEGANIUM,   EVENT_ELMS_LAB_CHIKORITA_SHINY
	dw CYNDAQUIL,  EVENT_ELMS_LAB_CYNDAQUIL_SHINY
	dw QUILAVA,    EVENT_ELMS_LAB_CYNDAQUIL_SHINY
	dw TYPHLOSION, EVENT_ELMS_LAB_CYNDAQUIL_SHINY
	dw TOTODILE,   EVENT_ELMS_LAB_TOTODILE_SHINY
	dw CROCONAW,   EVENT_ELMS_LAB_TOTODILE_SHINY
	dw FERALIGATR, EVENT_ELMS_LAB_TOTODILE_SHINY
	dw 0 ; end

GetOverworldMonStaticCount:
; How many of this map's SPRITE_OW_MON_* slots its static entries already own.
; out: a = the count, 0 if the map declares none
;
; Static mon and rolled ones come out of the same slot lookup in GetOverworldMonSlot, and a rolled
; encounter wins. So a roll into a slot a static mon owns would redraw that mon as whatever
; wandered in -- the whole Route 39 Miltank herd, or the Red Gyarados, turning into a Magikarp.
; The static entries always sit at the bottom, so the roll starts above them.
	ld hl, OverworldMonObjects
.map_loop
	ld a, [hli]
	cp -1
	jr z, .none
	ld d, a ; this row's map group
	ld a, [hli]
	ld e, a ; this row's map number
	ld a, [hli]
	ld b, a ; how many mon this row declares

	ld a, [wMapGroup]
	cp d
	jr nz, .skip_row
	ld a, [wMapNumber]
	cp e
	jr z, .found

.skip_row
	ld a, b
	and a
	jr z, .map_loop
.skip_loop
	ld a, l
	add OW_MON_SLOT_LENGTH
	ld l, a
	adc h
	sub l
	ld h, a
	dec b
	jr nz, .skip_loop
	jr .map_loop

.none
	xor a
	ret

.found
	ld a, b
	ret
SetUpOverworldMonBattle::
; Point the battle at the encounter that was rolled when this mon appeared on the map, instead of
; letting it roll its own. Everything else -- form, shininess, DVs, held item -- LoadEnemyMon reads
; straight out of the struct, which is why the sprite you walked into and the mon you fight match.
;
; wBattleType is left alone. LoadEnemyMon finds the rolled encounter through
; wOverworldMonBattleSlot, which TryClaimOverworldMonBattle set, so this is an ordinary wild battle
; -- or a BATTLETYPE_CONTEST one, if the script that started it said so, Park Balls and all.
	ld a, 1 << 7
	ld [wBattleScriptFlags], a ; a wild battle, the same flag `loadwildmon` sets
	call GetOverworldMonBattleEncounter
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a ; bc = the species index
	inc hl ; the form is read by LoadEnemyMon, not here
	ld a, [hl]
	ld [wCurPartyLevel], a
	ld h, b
	ld l, c
	call GetPokemonIDFromIndex
	ld [wTempWildMonSpecies], a
; A roaming beast's slot fights as a roamer: HP and DVs from its roam struct, fleeing, and moving
; on afterwards. CleanUpBattleRAM resets wBattleType.
	call IsOverworldMonBattleBeast
	jr nc, .not_beast
	ld a, BATTLETYPE_ROAMING
	ld [wBattleType], a
.not_beast
	; fallthrough

HidePlayerForOverworldMonBattle:
; Leave the mon alone on screen for the battle transition. DoBattleTransition rebuilds OAM once,
; through InitSprites, which skips any object whose facing reads STANDING -- so the facing is set
; here rather than only the flag, because HandleMapObjects (the thing that would act on the flag)
; does not get another turn between here and the transition.
	ld hl, wPlayerStruct + OBJECT_FLAGS1
	set INVISIBLE_F, [hl]
	ld hl, wPlayerStruct + OBJECT_FACING
	ld [hl], STANDING
	ld hl, wObject1Struct + OBJECT_FLAGS1 ; the follower travels with the player
	set INVISIBLE_F, [hl]
	ld hl, wObject1Struct + OBJECT_FACING
	ld [hl], STANDING
	ret

ShowPlayerAfterOverworldMonBattle:
; The map reload that follows respawns both of them, but clear the flags rather than trusting it.
; The follower goes back to its own state, not straight to visible: one recalled into its ball
; on water (FOLLOWER_INVISIBLE) has to stay hidden, or it stands on the water after the battle.
	ld hl, wPlayerStruct + OBJECT_FLAGS1
	res INVISIBLE_F, [hl]
	ld hl, wObject1Struct + OBJECT_FLAGS1
	res INVISIBLE_F, [hl]
	ld a, [wFollowerFlags]
	and FOLLOWER_INVISIBLE
	ret z
	set INVISIBLE_F, [hl]
	ret

EndOverworldMonBattle::
; Put hLastTalked back for the `disappear` that follows -- a battle is free to clobber HRAM -- and
; close the encounter out. The slot's data is left alone: the object's event flag is what keeps it
; away until the route is re-entered, and the roll overwrites the slot then anyway.
	call ShowPlayerAfterOverworldMonBattle
	ld a, [wOverworldMonBattleObject]
	ldh [hLastTalked], a
	ld a, [wOverworldMonBattleSlot]
	and a
	ret z
; A beast fought here has moved on or been caught, so forget its slot.
	ld b, a
	ld hl, wOverworldMonBeastSlots
	ld c, 2
.forget_beast
	ld a, [hl]
	cp b
	jr nz, .next_beast
	xor a
	ld [hl], a
.next_beast
	inc hl
	dec c
	jr nz, .forget_beast
	ld a, b
	dec a
	ld e, a
	call GetOverworldMonEncounter
	xor a
	ld [hli], a
	ld [hl], a ; species 0: the slot is empty, which is what keeps the object masked from here on
	ld [wOverworldMonBattleSlot], a
	ret

GetOverworldMonBattleEncounter::
; hl = the encounter the battle now running is against.
	ld a, [wOverworldMonBattleSlot]
	dec a
	ld e, a
	; fallthrough

GetOverworldMonEncounter::
; in:  e = a 0-based slot index
; out: hl = that slot's entry in wOverworldMonEncounters
; Preserves everything else. The caller is responsible for WRAM bank 1 being current.
	push de
	ld l, e
	ld h, 0
	add hl, hl ; *2
	ld d, h
	ld e, l
	add hl, hl ; *4
	add hl, hl ; *8
	add hl, de ; *10
	assert OW_MON_ENCOUNTER_LENGTH == 10, "GetOverworldMonEncounter scales a slot by ten"
	ld de, wOverworldMonEncounters
	add hl, de
	pop de
	ret

ClearOverworldMonEncounters::
; Forget every rolled encounter. Called when a map is entered, immediately before they are rolled
; again, and by the debug tooling.
	ld hl, wOverworldMonEncounters
	ld bc, NUM_OW_MON_SLOTS * OW_MON_ENCOUNTER_LENGTH
	xor a
	rst ByteFill
	ld [wOverworldMonBattleSlot], a
	ld [wOverworldMonShinyPending], a
	ld [wOverworldMonOnSurface], a
	ld [wOverworldMonBeastSlots], a
	ld [wOverworldMonBeastSlots + 1], a
; And no population, until .RollPopulation finds this map a row. PlacePopulation reads the row
; pointer as "is this a population map at all", so it must not carry over from the last one.
	ld [wPopulationRow], a
	ld [wPopulationRow + 1], a
	ld [wPopulationPlaced], a
	ret

INCLUDE "data/maps/overworld_mons.asm"


if DEF(_DEBUG)
; Force this slot shiny every time, or 0 for none. Testing a 1/512 rate by walking in and out of a
; route a few hundred times is not a test; what needs checking is whether the sprite and the battle
; agree about it, and a guaranteed shiny answers that on the first try.
DEF OW_MON_DEBUG_FORCE_SHINY_SLOT EQU 2
assert OW_MON_DEBUG_FORCE_SHINY_SLOT <= NUM_OW_MON_SLOTS, "no such slot to force shiny"
endc

RollOverworldMonsOnContinue::
; The save-load path. MapSetupScript_Continue restores the map objects straight out of the save --
; the wandering mon among them -- but skips HandleNewMap and LoadMapObjects entirely, so nothing
; rolls and nothing masks. The encounters live outside the save block, so what the objects find on
; the other side is whatever was left in WRAM: an empty slot at best, and on a cold boot garbage
; that resolves to no sprite at all, which is why they came back as a man you could not talk to.
;
; Rolling here means a reloaded save gets a fresh route, which is the same thing walking out and
; back gives you.
;
; A population keeps its species across a save (R7): the roll is told to restore them from
; wPopulationSpecies rather than pick. Everything else about each member rolls afresh.
	ld a, TRUE
	ld [wPopulationRestore], a
	call RollOverworldMons
	xor a
	ld [wPopulationRestore], a
	call UpdateOverworldMonObjectMasks
	; fallthrough

RefreshOverworldMonPalettes:
; The palette state is inside the save block; the encounters are deliberately outside it. So after
; a reload every wandering mon object still carries the palette index it had, and that index still
; holds the colors of the mon that was standing there when the game was saved -- a fresh Tentacool
; wearing the old Pikachu's colors. Re-derive them from the mon standing there now.
	farcall ResetOverworldMonPalettes ; forget which colors were claimed
	farcall InvalidateFollowerPalette ; and free every loaded index from the follower's up
	ld bc, wObjectStructs
	ld d, NUM_OBJECT_STRUCTS
.loop
	ld hl, OBJECT_SPRITE
	add hl, bc
	ld a, [hl]
	sub SPRITE_OW_MON
	cp NUM_OW_MON_SLOTS
	jr c, .rederive
; Other mon-colored objects, like a legendary beast's sprite, lost their index to the reset too.
	push hl
	ld hl, OBJECT_PAL_INDEX
	add hl, bc
	ld a, [hl]
	pop hl
	cp PAL_OW_MON
	jr c, .next
.rederive
	ld a, [hl]
	call GetSpritePalette ; preserves bc, and re-runs the whole colour lookup for this mon
	ld hl, OBJECT_PAL_INDEX
	add hl, bc
	ld [hl], a

.next
	ld hl, OBJECT_LENGTH
	add hl, bc
	ld b, h
	ld c, l
	dec d
	jr nz, .loop
	farjp CheckForUsedObjPals

RollOverworldMons::
; Decide what is wandering this map. Called from HandleNewMap, which runs on warps, connections and
; fly -- but not on returning from a battle or closing a menu. That is what makes a route reroll
; when you leave and come back, and hold still otherwise.
; Grass and water roll from separate tables, one pass each, so a Tentacool never turns up in a
; field and a Sentret never turns up out at sea. The slots fill in that order -- this map's static
; mon, then its grass slots, then its water ones -- so a map's SPRITE_OW_MON_* objects have to be
; numbered the same way.
	call ClearOverworldMonEncounters
	ld a, SWARM_GRASS ; before the population too, which is always on land
	ld [wOverworldMonSwarmTerrain], a
	call GetOverworldMonStaticCount
	ld c, a ; the first slot this map's static mon do not own
	call .RollPopulation
	ret c ; a population map fills its own slots and has no grass or water roster
	ld hl, OverworldWildMonsGrass
	push bc ; c = the first grass slot
	call .RollTable
	pop de ; e = the first grass slot, and c is now one past the last
	push bc
	call PlaceRoamingBeasts
	pop bc
	ld a, SWARM_WATER
	ld [wOverworldMonSwarmTerrain], a
	ld hl, OverworldWildMonsWater
; fallthrough

.RollTable:
; in:  hl = one terrain's table, c = the first slot to fill
; out: c advanced past whatever this table filled
	call .FindMap
	ret nc

	ld a, [hli]
	ld [wOverworldMonRollCount], a
	ld a, [hli]
	ld [wOverworldMonRollChance], a

; Step to this time of day's roster.
	ld a, [wTimeOfDay]
	cp EVE_F
	jr nz, .got_daytime
	ld a, NITE_F ; evening shares the night roster, as the grass tables do
.got_daytime
	and a
	jr z, .at_roster
	ld b, a
.daytime_loop
	ld de, NUM_OW_WILDMON * OW_WILDMON_LENGTH
	add hl, de
	dec b
	jr nz, .daytime_loop

.at_roster
	push bc
	push hl
	call .GetSwarmedRows
	pop hl
	pop bc
	ld a, [wOverworldMonRollCount]
	and a
	ret z
	ld b, a
	ld a, c
	cp NUM_OW_MON_SLOTS
	ret nc ; every slot is spoken for already
	ld a, NUM_OW_MON_SLOTS
	sub c ; how many slots are left
	cp b
	jr nc, .slot_loop ; the roster asks for no more than fit
	ld b, a ; otherwise fill what there is
.slot_loop
	push bc
	push hl
	call .RollOneSlot
	pop hl
	pop bc
	inc c
	dec b
	jr nz, .slot_loop
	ret

.RollOneSlot:
; in: hl = this time of day's roster, c = the 0-based slot
	ld a, c
	ld [wOverworldMonRollSlot], a

	call Random
	ld b, a
	ld a, [wOverworldMonRollChance]
	cp b
	ret c ; nobody appears in this slot; it stays empty and its object stays hidden

; Pick an entry by weight, subtracting as we go. A roster adding to less than 100 simply lands on
; its last entry more often, which beats silently picking nothing.
.reroll
	call Random
	cp 100
	jr nc, .reroll
	inc a ; 1 <= a <= 100
	ld b, a
	ld d, NUM_OW_WILDMON - 1
.weight_loop
	ld a, [hl]
	cp b
	jr nc, .got_entry
	ld e, a
	ld a, b
	sub e
	ld b, a
	ld a, l
	add OW_WILDMON_LENGTH
	ld l, a
	adc h
	sub l
	ld h, a
	dec d
	jr nz, .weight_loop

.got_entry
; Is this a row the swarm has taken? Worked out now, because the copy below reuses d.
	ld a, NUM_OW_WILDMON - 1
	sub d ; the row's index in the roster
	call .RowBit
	ld b, a
	ld a, [wOverworldMonSwarmRows]
	and b
	ld b, a ; nonzero if the swarm has it; the copy leaves b alone
	ld [wOverworldMonRollFromSwarm], a ; and .RollForm rolls its shininess at the swarm's rate

; Copy the roster entry into the buffer. The whole encounter is assembled there and published in
; one copy, so nothing can ever read a half-rolled mon.
	inc hl ; past the weight
	ld de, wOverworldMonRollBuffer + OW_MON_SPECIES
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ld a, [hli]
	ld [wOverworldMonRollBuffer + OW_MON_LEVEL], a
	ld a, [hli]
	ld [wOverworldMonRollBuffer + OW_MON_FORM], a
	ld a, [hli]
	ld [wOverworldMonRollBuffer + OW_MON_PERKS], a
	ld a, [hli]
	ld [wOverworldMonRollBuffer + OW_MON_MOVE], a
	ld a, [hl]
	ld [wOverworldMonRollBuffer + OW_MON_MOVE + 1], a

; A swarm takes the row over with its own species, form and move, keeping the row's level so it fits
; the route. The row's perks and extra move belong to the species it displaces, so neither carries
; over. .RollForm still rolls shininess.
	ld a, b
	and a
	jr z, .FinishRoll
	ld a, [wOverworldMonSwarmSpecies]
	ld [wOverworldMonRollBuffer + OW_MON_SPECIES], a
	ld a, [wOverworldMonSwarmSpecies + 1]
	ld [wOverworldMonRollBuffer + OW_MON_SPECIES + 1], a
	ld a, [wOverworldMonSwarmForm]
	ld [wOverworldMonRollBuffer + OW_MON_FORM], a
	ld a, [wOverworldMonSwarmMove]
	ld [wOverworldMonRollBuffer + OW_MON_MOVE], a
	ld a, [wOverworldMonSwarmMove + 1]
	ld [wOverworldMonRollBuffer + OW_MON_MOVE + 1], a
	xor a
	ld [wOverworldMonRollBuffer + OW_MON_PERKS], a

.FinishRoll:
; The shared tail: form and shininess, DVs, item, then publish. A population member joins here
; with its species, level, form and perks already in the buffer.
	call .RollUnownLetter
	jr nc, .not_locked_unown
; An Unown before any letter is unlocked: publish the slot empty, so nothing stands here. A reroll
; would otherwise leave the previous mon in it.
	xor a
	ld [wOverworldMonRollBuffer + OW_MON_SPECIES], a
	ld [wOverworldMonRollBuffer + OW_MON_SPECIES + 1], a
	ld [wOverworldMonRollFromSwarm], a
	jr .publish

.not_locked_unown
	call .RollForm
	xor a
	ld [wOverworldMonRollFromSwarm], a ; used up, and never set for a population member
	call .RollDVs
	call .RollItem

.publish
	ld a, [wOverworldMonRollSlot]
	ld e, a
	call GetOverworldMonEncounter
	ld d, h
	ld e, l
	ld hl, wOverworldMonRollBuffer
	ld bc, OW_MON_ENCOUNTER_LENGTH
	rst CopyBytes

; Note whether a water mon rides on the surface (SurfaceRidingMons), so CopySpriteMovementData can
; take OVERHEAD back off its object without a lookup from ROM0.
	ld a, [wOverworldMonSwarmTerrain]
	cp SWARM_WATER
	ret nz
	call .RidesOnSurface
	ret nc
	ld a, [wOverworldMonRollSlot]
	ld b, a
	inc b
	xor a
	scf
.surface_bit
	rla ; after slot + 1 rotations a is 1 << slot
	dec b
	jr nz, .surface_bit
	ld hl, wOverworldMonOnSurface
	or [hl]
	ld [hl], a
	ret

.GetSwarmedRows:
; Which of this roster's rows a swarm takes over: the heaviest first, adding rows while their
; combined weight keeps moving nearer SWARM_ENCOUNTER_RATE, and never all four -- one row always
; stays the route's own. Rows are weighted, not fixed-odds slots, so this is how the overworld
; lands on the same rate the grass does with its slot masks.
; in: hl = this time of day's roster
; out: wOverworldMonSwarmRows, and the swarm's species, form and move when there is one
	xor a
	ld [wOverworldMonSwarmRows], a
	push hl
	ld a, [wMapGroup]
	ld d, a
	ld a, [wMapNumber]
	ld e, a
	ld a, [wOverworldMonSwarmTerrain]
	ld b, a
	farcall GetSwarmSpeciesForMap
	pop hl
	ret nc
	ld [wOverworldMonSwarmForm], a
	ld a, c
	ld [wOverworldMonSwarmMove], a
	ld a, b
	ld [wOverworldMonSwarmMove + 1], a
	ld a, e
	ld [wOverworldMonSwarmSpecies], a
	ld a, d
	ld [wOverworldMonSwarmSpecies + 1], a

	lb bc, NUM_OW_WILDMON - 1, 0 ; at most this many rows; the weight taken so far
.take_loop
; Find the heaviest row not yet taken: e = its index, d = its weight. A tie keeps the earlier row,
; and a row of no weight is never taken.
	push bc
	push hl
	lb de, 0, -1
	ld c, 0
.scan
	ld a, c
	call .RowBit
	ld b, a
	ld a, [wOverworldMonSwarmRows]
	and b
	jr nz, .scan_next ; already taken
	ld a, [hl] ; OW_WILDMON_WEIGHT
	cp d
	jr c, .scan_next
	jr z, .scan_next
	ld d, a
	ld e, c
.scan_next
	ld a, l
	add OW_WILDMON_LENGTH
	ld l, a
	adc h
	sub l
	ld h, a
	inc c
	ld a, c
	cp NUM_OW_WILDMON
	jr nz, .scan
	pop hl
	pop bc
	ld a, e
	inc a
	ret z ; nothing left with any weight

; Take it? Always the first. After that only while it lands nearer the rate: freely while the total
; stays at or under it, and past it only if it overshoots by less than it was short -- which is
; 2 * total + weight < 2 * rate. The total never exceeds the rate here, so that cannot overflow.
	ld a, [wOverworldMonSwarmRows]
	and a
	jr z, .take
	ld a, c
	cp SWARM_ENCOUNTER_RATE
	ret nc
	add d
	cp SWARM_ENCOUNTER_RATE + 1
	jr c, .take
	ld a, c
	add a
	add d
	cp 2 * SWARM_ENCOUNTER_RATE
	ret nc
.take
	ld a, e
	call .RowBit
	push hl
	ld hl, wOverworldMonSwarmRows
	or [hl]
	ld [hl], a
	pop hl
	ld a, c
	add d
	ld c, a
	dec b
	jr nz, .take_loop
	ret

.RowBit:
; a = 1 << a
	push bc
	ld b, a
	inc b
	xor a
	scf
.row_bit_loop
	rla ; after a + 1 rotations the carry has landed on bit a
	dec b
	jr nz, .row_bit_loop
	pop bc
	ret

.RollForm:
	ld a, [wOverworldMonRollBuffer + OW_MON_FORM]
	and SHINY_MASK
	jr nz, .note_shiny ; the roster asked for one that is always shiny
; if DEF(_DEBUG)
; 	ld a, [wOverworldMonRollSlot]
; 	inc a
; 	cp OW_MON_DEBUG_FORCE_SHINY_SLOT
; 	jr z, .make_shiny
; endc
	ld a, [wOverworldMonRollBuffer + OW_MON_PERKS]
	bit OW_PERK_EXTRA_SHINY_F, a
	jr nz, .extra_shiny

if DEF(_DEBUG) && SWARM_DEBUG_FORCE_SHINY
	ld a, [wOverworldMonRollFromSwarm]
	and a
	jr nz, .make_shiny
endc
if DEF(_DEBUG)
	call DebugForceSwarmMonShiny
	jr nz, .make_shiny
endc
	call Random
	and a
	ret nz ; 255/256 not shiny, the same gate every other shiny roll uses
	ld b, OVERWORLD_MON_SHINY_NUMERATOR
	ld a, [wOverworldMonRollFromSwarm]
	and a
	jr z, .roll_shiny
	ld b, SWARM_SHINY_NUMERATOR
	jr .roll_shiny

.extra_shiny
; Deliberately without the 1/256 gate above. Behind it, no numerator can push the perk past about
; 1/257, so the perk would be a rounding error rather than a reward.
	ld b, OVERWORLD_MON_EXTRA_SHINY_NUMERATOR

.roll_shiny
	call Random
	cp b
	ret nc

.make_shiny
	ld a, [wOverworldMonRollBuffer + OW_MON_FORM]
	or SHINY_MASK
	call RollOverworldMonAltShiny
	ld [wOverworldMonRollBuffer + OW_MON_FORM], a

.note_shiny
	ld a, TRUE
	ld [wOverworldMonShinyPending], a
	ret

.RollDVs:
	call Random
	call .FloorNibbles
	ld [wOverworldMonRollBuffer + OW_MON_DVS], a
	call Random
	call .FloorNibbles
	ld [wOverworldMonRollBuffer + OW_MON_DVS + 1], a
	ret

.FloorNibbles:
; in/out: a, with either nibble raised to OVERWORLD_MON_MIN_DV when it fell below it. Half the
; appeal of chasing one of these is that it is worth keeping.
	ld b, a
	and $f0
	cp OVERWORLD_MON_MIN_DV << 4
	jr nc, .high_ok
	ld a, OVERWORLD_MON_MIN_DV << 4
.high_ok
	ld c, a
	ld a, b
	and $0f
	cp OVERWORLD_MON_MIN_DV
	jr nc, .low_ok
	ld a, OVERWORLD_MON_MIN_DV
.low_ok
	or c
	ret

.RollItem:
	ld hl, wOverworldMonRollBuffer + OW_MON_SPECIES
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call GetPokemonIDFromIndex
	ld [wCurSpecies], a
	call GetBaseData

	ld a, [wOverworldMonRollBuffer + OW_MON_PERKS]
	bit OW_PERK_ALWAYS_ITEM_F, a
	jr nz, .item1
	call Random
	cp OVERWORLD_MON_NO_ITEM_CHANCE
	jr c, .no_item
	call Random
	cp 20 percent ; the same split between the two items a grass encounter uses
	jr c, .item2
.item1
	ld hl, wBaseItem1
	jr .got_item

.item2
	ld hl, wBaseItem2
.got_item
	call GetItemIDFromHL
	jr .store_item

.no_item
	ld a, NO_ITEM
.store_item
	ld [wOverworldMonRollBuffer + OW_MON_ITEM], a
	ret

.RollUnownLetter:
; Any wandering Unown takes a random unlocked letter, whatever its row's form says, so no row can
; show a locked one -- the same pick a floor encounter gets in LoadEnemyMon.
; out: carry if it is an Unown and no letter is unlocked yet. That is ChooseWildEncounter's gate on
;      the floor encounters, and CheckUnownLetter's retry loop would never end without it.
	ld hl, wOverworldMonRollBuffer + OW_MON_SPECIES
	ld a, [hli]
	xor LOW(UNOWN)
	ret nz ; xor has cleared carry
	if HIGH(UNOWN) == 0
		or [hl]
	else
		ld a, [hl]
		xor HIGH(UNOWN)
	endc
	ret nz
	ld a, [wUnlockedUnowns]
	and a
	scf
	ret z
.letter_loop
	predef GetUnownLetter ; wForm = 0-25
	farcall CheckUnownLetter
	jr c, .letter_loop
	ld a, [wForm]
	ld [wOverworldMonRollBuffer + OW_MON_FORM], a
	and a ; a letter is 0-25, so this clears carry
	ret

.RidesOnSurface:
; out: carry if the rolled species is in SurfaceRidingMons
	ld hl, SurfaceRidingMons
.surface_loop
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	or e
	ret z ; the end; `or e` has cleared carry
	ld a, [wOverworldMonRollBuffer + OW_MON_SPECIES]
	cp e
	jr nz, .surface_loop
	ld a, [wOverworldMonRollBuffer + OW_MON_SPECIES + 1]
	cp d
	jr nz, .surface_loop
	scf
	ret

.FindMap:
; in:  hl = one terrain's table
; out: carry and hl = this map's row past the map id, or no carry when the map has no row there.
;      Preserves bc -- the caller is holding the slot to fill in c, across both passes.
	ld a, [hli]
	cp -1
	jr z, .no_row
	ld d, a
	ld a, [hli]
	ld e, a
	ld a, [wMapGroup]
	cp d
	jr nz, .skip_row
	ld a, [wMapNumber]
	cp e
	jr nz, .skip_row
	scf
	ret

.skip_row
	ld de, OW_WILDDATA_LENGTH - 2
	add hl, de
	jr .FindMap

.no_row
	and a
	ret

.RollPopulation:
; in:  c = the first slot to fill
; out: carry if this map has a population, in which case its members are rolled. The grass and
;      water tables are not consulted for such a map. See docs/overworld_pokemon.md.
	ld hl, MonPopulations
	call .FindPopulation
	ret nc

	ld a, l
	ld [wPopulationRow], a
	ld a, h
	ld [wPopulationRow + 1], a
	ld a, [hli]
	ld [wPopulationMode], a
	ld a, [hli]
	ld b, a ; how many are out at once

	ld a, NUM_OW_MON_SLOTS
	sub c
	jr z, .population_done ; every slot is spoken for already
	cp b
	jr nc, .got_population_count
	ld b, a ; the row asks for more than fit
.got_population_count

	call .GetPopulationRoster
	call .CountPopulationRoster
	and a
	jr z, .population_done ; a roster with nothing in it is a map with nothing on it

; POP_REROLL_STATS is one species for the whole visit: pick once, and every member takes it.
; POP_REROLL_SPECIES picks again for each member.
; On a continue the species come back from the save instead (R7).
	ld a, [wPopulationMode]
	cp POP_REROLL_STATS
	call z, .RestoreOrPickEntry ; one species for the visit: settled before the loop

.population_loop
	ld a, [wPopulationMode]
	cp POP_REROLL_STATS
	call nz, .RestoreOrPickEntry
	push bc
	call .RollOnePopulationSlot
	pop bc
	inc c
	dec b
	jr nz, .population_loop

.population_done
	scf
	ret

.FindEntryForSavedSpecies:
; in:  c = a slot
; out: carry and wPopulationEntry set, when the roster has an entry for the species saved in that
;      slot. Preserves bc.
	push bc
; Roster first: .GetPopulationRoster steps with de and .CountPopulationRoster scratches e, so the
; saved species is read only once both are done. Reading it first cost a round trip.
	call .GetPopulationRoster
	call .CountPopulationRoster
	ld b, a
	push hl
	ld a, c
	add a
	ld e, a
	ld d, 0
	ld hl, wPopulationSpecies
	add hl, de
	ld a, [hli]
	ld e, a
	ld d, [hl] ; de = the saved species
	pop hl
	or d
	jr z, .no_saved_species
.saved_species_loop
	inc hl ; past the weight
	ld a, [hli]
	cp e
	jr nz, .saved_species_miss
	ld a, [hl]
	cp d
	jr z, .saved_species_found
.saved_species_miss
; hl is on the species' high byte either way; the next entry's weight is POP_MON_LENGTH - 2 on
	ld a, l
	add POP_MON_LENGTH - 2
	ld l, a
	adc h
	sub l
	ld h, a
	dec b
	jr nz, .saved_species_loop
.no_saved_species
	pop bc
	and a
	ret

.saved_species_found
	dec hl
	dec hl ; back to the entry's weight, where an entry starts
	ld a, l
	ld [wPopulationEntry], a
	ld a, h
	ld [wPopulationEntry + 1], a
	pop bc
	scf
	ret

.FindPopulation:
; in:  hl = MonPopulations
; out: carry and hl = this map's row past the map id, or no carry when the map has no row.
;      Preserves bc.
	ld a, [hli]
	cp -1
	jr z, .no_population
	ld d, a
	ld a, [hli]
	ld e, a
	ld a, [wMapGroup]
	cp d
	jr nz, .skip_population
	ld a, [wMapNumber]
	cp e
	jr nz, .skip_population
	scf
	ret

.skip_population
	ld de, POP_DATA_LENGTH - 2
	add hl, de
	jr .FindPopulation

.no_population
	and a
	ret

.GetPopulationRoster:
; out: hl = the first roster entry of this map's row. Preserves bc.
	ld hl, wPopulationRow
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, 1 + 1 + MAX_SPAWN_AREAS * SPAWN_AREA_LENGTH ; past the mode, the count and the areas
	add hl, de
	ret

.CountPopulationRoster:
; in:  hl = the roster
; out: a = how many of its entries are real. Preserves bc and hl.
; The padding end_population writes is species 0, so the first empty entry is the end of the list.
	push bc
	push hl
	lb bc, 0, NUM_POP_MON
.count_population_loop
	inc hl ; past the weight
	ld a, [hli]
	ld e, a
	ld a, [hli]
	or e
	jr z, .counted_population
	ld a, l
	add POP_MON_LENGTH - 3 ; the rest of the entry
	ld l, a
	adc h
	sub l
	ld h, a
	inc b
	dec c
	jr nz, .count_population_loop
.counted_population
	ld a, b
	pop hl
	pop bc
	ret

.RestoreOrPickEntry:
; in:  c = the slot being filled. Leaves the entry to draw from in wPopulationEntry. Preserves bc.
; On a continue, and only then, the entry whose species this slot had when the game was saved; if
; the save holds no species for it, or one no longer in the roster, it falls through to a pick.
	ld a, [wPopulationRestore]
	and a
	jr z, .PickPopulationEntry
	call .FindEntryForSavedSpecies
	ret c
	; fallthrough

.PickPopulationEntry:
; Pick a roster entry by weight and leave it in wPopulationEntry. Preserves bc.
; The same subtract-as-you-go walk as .RollOneSlot, stopped at the last real entry rather than the
; last column, so a roster adding to less than 100 lands on its last entry more often instead of
; on the padding.
	push bc
	call .GetPopulationRoster
	call .CountPopulationRoster
	ld d, a
	dec d ; entries left to step over before the last one takes whatever is left
.pick_reroll
	call Random
	cp 100
	jr nc, .pick_reroll
	inc a ; 1 <= a <= 100
	ld b, a
.pick_loop
	ld a, d
	and a
	jr z, .picked
	ld a, [hl]
	cp b
	jr nc, .picked
	ld e, a
	ld a, b
	sub e
	ld b, a
	ld a, l
	add POP_MON_LENGTH
	ld l, a
	adc h
	sub l
	ld h, a
	dec d
	jr .pick_loop

.picked
	ld a, l
	ld [wPopulationEntry], a
	ld a, h
	ld [wPopulationEntry + 1], a
	pop bc
	ret

.RollOnePopulationSlot:
; in: c = the 0-based slot, wPopulationEntry = the roster entry it draws from
	ld a, c
	ld [wOverworldMonRollSlot], a

	ld hl, wPopulationEntry
	ld a, [hli]
	ld h, [hl]
	ld l, a
	inc hl ; past the weight
	ld a, [hli]
	ld [wOverworldMonRollBuffer + OW_MON_SPECIES], a
	ld a, [hli]
	ld [wOverworldMonRollBuffer + OW_MON_SPECIES + 1], a

; And into the save block, so a continue can put the same species back (R7).
	push hl
	ld a, c
	add a
	ld e, a
	ld d, 0
	ld hl, wPopulationSpecies
	add hl, de
	ld a, [wOverworldMonRollBuffer + OW_MON_SPECIES]
	ld [hli], a
	ld a, [wOverworldMonRollBuffer + OW_MON_SPECIES + 1]
	ld [hl], a
	pop hl

; Level: uniform over the entry's range. RandomRange never returns for a range of zero, and pop_mon
; refuses a max below its min, so the range here is always at least one.
	ld a, [hli] ; min
	ld b, a
	ld a, [hli] ; max
	sub b
	inc a ; how many levels the range spans
	push hl
	call RandomRange ; preserves bc
	pop hl
	add b
	ld [wOverworldMonRollBuffer + OW_MON_LEVEL], a

	ld a, [hli]
	bit POP_WILD_FORM_F, a
	jr z, .form_fixed
; POP_WILD_FORM: the random form a grass encounter of this species gets, from WildFormTable, so a
; contest Scyther can be any of its colours -- and the battle agrees, because LoadEnemyMon takes a
; wandering mon's rolled form whole. CheckForMultipleWildForms clobbers bc, de and hl.
	push bc
	push hl
	ld hl, wOverworldMonRollBuffer + OW_MON_SPECIES
	ld a, [hli]
	ld h, [hl]
	ld l, a
	farcall CheckForMultipleWildForms ; hl = the species index; carry and a = a form when it has any
	jr c, .got_wild_form
	xor a ; PLAIN_FORM
.got_wild_form
	pop hl
	pop bc
.form_fixed
	ld [wOverworldMonRollBuffer + OW_MON_FORM], a
	ld a, [hl]
	ld [wOverworldMonRollBuffer + OW_MON_PERKS], a

; No extra-move column: a member knows nothing beyond what its level taught it.
	ld a, LOW(NO_MOVE)
	ld [wOverworldMonRollBuffer + OW_MON_MOVE], a
	ld a, HIGH(NO_MOVE)
	ld [wOverworldMonRollBuffer + OW_MON_MOVE + 1], a
	jmp .FinishRoll

PlaceRoamingBeasts:
; Raikou and Entei, while on this map, each take a random grass slot that rolled a mon. The
; encounter comes from the roam struct (species, level, DVs and form), and each appearance gets the
; 1/512 shiny roll. With both here and only one slot, whichever goes first takes it.
; in: e = this map's first grass slot, c = one past its last
	ld a, [wOverworldMonRerolling]
	and a
	jmp nz, RestoreRoamingBeasts

; The candidates: grass slots that rolled a mon.
	ld b, a ; 0
.candidate_loop
	ld a, e
	cp c
	jr nc, .got_candidates
	push hl
	call GetOverworldMonEncounter ; preserves everything else
	ld a, [hli]
	or [hl]
	pop hl
	jr z, .next_candidate
	ld a, e
	call OverworldMonSlotBit
	or b
	ld b, a
.next_candidate
	inc e
	jr .candidate_loop

.got_candidates
	ld a, b
	ld [wOverworldMonBeastCandidates], a
	and a
	ret z

; A coin toss decides which beast goes first.
	call Random
	rrca
	jr c, .entei_first
	call .Raikou
	jr .Entei

.entei_first
	call .Entei
.Raikou:
	ld hl, wRoamMon1Species
	ld de, wOverworldMonBeastSlots
	jr .Place

.Entei:
	ld hl, wRoamMon2Species
	ld de, wOverworldMonBeastSlots + 1
.Place:
; in: hl = the beast's roam struct, de = its entry in wOverworldMonBeastSlots
	ld a, [hli]
	and a
	ret z ; not out: not released yet, or caught or defeated
	ld b, a ; its species ID
	inc hl ; past the level
	ld a, [wMapGroup]
	cp [hl]
	ret nz
	inc hl
	ld a, [wMapNumber]
	cp [hl]
	ret nz
	dec hl
	dec hl
	dec hl ; back to the species

; A random candidate slot: count them, pick one, find it.
	push hl
	push de
	ld a, [wOverworldMonBeastCandidates]
	and a
	jr z, .no_slot
	ld c, 0
	ld d, a
.count
	srl d
	jr nc, .count_next
	inc c
.count_next
	jr nz, .count
	ld a, c
	call RandomRange ; a = which of the candidates, 0-based
	ld c, a
	ld a, [wOverworldMonBeastCandidates]
	ld d, a
	ld e, -1 ; the slot
.find
	inc e
	srl d
	jr nc, .find
	ld a, c
	and a
	jr z, .found
	dec c
	jr .find

.found
; e = the slot. Take it from the candidates.
	ld a, e
	call OverworldMonSlotBit
	cpl
	ld hl, wOverworldMonBeastCandidates
	and [hl]
	ld [hl], a
	ld a, e
	pop de
	inc a ; 1-based
	ld [de], a
	dec a
	ld [wOverworldMonRollSlot], a
	pop hl ; the roam struct

; Assemble the encounter in the roll buffer, as .FinishRoll does, and publish it in one copy.
	push hl
	ld a, [hli] ; species ID
	push hl
	call GetPokemonIndexFromID
	ld a, l
	ld [wOverworldMonRollBuffer + OW_MON_SPECIES], a
	ld a, h
	ld [wOverworldMonRollBuffer + OW_MON_SPECIES + 1], a
	pop hl
	ld a, [hli] ; level
	ld [wOverworldMonRollBuffer + OW_MON_LEVEL], a
	inc hl ; past the map group
	inc hl ; past the map number
	inc hl ; past the HP
	ld a, [hli]
	ld [wOverworldMonRollBuffer + OW_MON_DVS], a
	ld a, [hli]
	ld [wOverworldMonRollBuffer + OW_MON_DVS + 1], a
	farcall RollLegendaryShiny ; hl = its form byte
	ld a, [hl]
	ld [wOverworldMonRollBuffer + OW_MON_FORM], a
	pop hl
	xor a
	ld [wOverworldMonRollBuffer + OW_MON_ITEM], a
	ld [wOverworldMonRollBuffer + OW_MON_PERKS], a
	assert NO_MOVE == 0
	ld [wOverworldMonRollBuffer + OW_MON_MOVE], a
	ld [wOverworldMonRollBuffer + OW_MON_MOVE + 1], a
	ld a, [wOverworldMonRollSlot]
	jr PublishBeastEncounter

.no_slot
	pop de
	pop hl
	ret

SaveRoamingBeasts:
; Set aside the slots the beasts hold, and their encounters, for RestoreRoamingBeasts.
	ld a, [wOverworldMonBeastSlots]
	ld [wOverworldMonBeastSaveSlots], a
	ld de, wOverworldMonBeastSave
	call .Save
	ld a, [wOverworldMonBeastSlots + 1]
	ld [wOverworldMonBeastSaveSlots + 1], a
	ld de, wOverworldMonBeastSave + OW_MON_ENCOUNTER_LENGTH
.Save:
; in: a = a beast's slot, 1-based or 0, de = where its encounter goes
	and a
	ret z
	dec a
	push de
	ld e, a
	call GetOverworldMonEncounter
	pop de
	ld bc, OW_MON_ENCOUNTER_LENGTH
	rst CopyBytes
	ret

RestoreRoamingBeasts:
; Stands in for PlaceRoamingBeasts during a swarm reroll: each beast goes back into its own slot,
; unchanged, with no new shiny roll.
	ld a, [wOverworldMonBeastSaveSlots]
	ld [wOverworldMonBeastSlots], a
	ld hl, wOverworldMonBeastSave
	call .Restore
	ld a, [wOverworldMonBeastSaveSlots + 1]
	ld [wOverworldMonBeastSlots + 1], a
	ld hl, wOverworldMonBeastSave + OW_MON_ENCOUNTER_LENGTH
.Restore:
; in: a = a beast's slot, 1-based or 0, hl = its saved encounter
	and a
	ret z
	dec a
	push af
	ld de, wOverworldMonRollBuffer
	ld bc, OW_MON_ENCOUNTER_LENGTH
	rst CopyBytes
	pop af
	; fallthrough

PublishBeastEncounter:
; Copy the roll buffer into slot a. A beast is on land, so clear its surface bit.
	push af
	ld e, a
	call GetOverworldMonEncounter
	ld d, h
	ld e, l
	ld hl, wOverworldMonRollBuffer
	ld bc, OW_MON_ENCOUNTER_LENGTH
	rst CopyBytes
	pop af
	call OverworldMonSlotBit
	cpl
	ld hl, wOverworldMonOnSurface
	and [hl]
	ld [hl], a
	ret

OverworldMonSlotBit:
; in: a = a 0-based slot; out: a = 1 << slot. Preserves everything else.
	push bc
	ld b, a
	inc b
	xor a
	scf
.loop
	rla
	dec b
	jr nz, .loop
	pop bc
	ret

IsOverworldMonBattleBeast::
; out: carry if the battle about to start is against a roaming beast's slot
	ld a, [wOverworldMonBattleSlot]
	and a
	ret z
	ld hl, wOverworldMonBeastSlots
	cp [hl]
	scf
	ret z
	inc hl
	cp [hl]
	scf
	ret z
	and a
	ret

RerollSwarmOverworldMons::
; After a battle on a swarming route: reroll every wandering mon, the way a population rerolls
; its members (R5), so standing in a swarm is a loop rather than a single pass. The reload that
; follows respawns them -- see PlacePopulationAndSpawn.
;
; Runs from OverworldMonBattleScript before reloadmapafterbattle. Does nothing on a population
; map, where RerollPopulation has already done this, or on a map with no swarm.
	ld hl, wPopulationRow
	ld a, [hli]
	or [hl]
	ret nz
	call IsPlayerMapSwarming
	ret nc
; A roaming beast standing here stays: set its slot aside, and have the roll put it back.
	call SaveRoamingBeasts
	ld a, TRUE
	ld [wOverworldMonRerolling], a
	call RollOverworldMons
	xor a
	ld [wOverworldMonRerolling], a

; The mon you fought is spent, as it would be anywhere else: its slot sits out this reshuffle and
; returns with the next one. The roll has just refilled it, and it would come back at its map
; object, a step or two from where it wandered to meet you -- so it is emptied again. It is found
; through its object because EndOverworldMonBattle has already cleared wOverworldMonBattleSlot.
	ld a, [wOverworldMonBattleObject]
	call GetMapObject
	ld hl, MAPOBJECT_SPRITE
	add hl, bc
	ld a, [hl]
	sub SPRITE_OW_MON
	ld e, a
	call GetOverworldMonEncounter
	xor a
	ld [hli], a
	ld [hl], a ; species 0: the slot is empty, which keeps the object masked

	ld a, TRUE
	ld [wSwarmRespawnPending], a
	ret

IsPlayerMapSwarming:
; carry if the map the player is on has a swarm of either terrain
	ld a, [wMapGroup]
	ld d, a
	ld a, [wMapNumber]
	ld e, a
	farjp IsMapSwarming

KeepSwarmClearOfPlayer:
; A route's mon reappear where their map objects stand, not on a tile chosen for them the way a
; population's members are. So one that would come back within SWARM_RESPAWN_MARGIN of the player
; -- on your tile, where it would start another battle before you could move -- sits out this
; reload, and the next roll brings it back. The mon you just fought is already out of it
; (RerollSwarmOverworldMons); this is for another slot whose object happens to stand where you do.
	ld b, 1
	ld de, wMap1Object
.loop
	ld hl, MAPOBJECT_TYPE
	add hl, de
	ld a, [hl]
	cp OBJECTTYPE_WILDMON
	jr nz, .next
	ld hl, MAPOBJECT_SPRITE
	add hl, de
	ld a, [hl]
	sub SPRITE_OW_MON
	cp NUM_OW_MON_SLOTS
	jr nc, .next
	ld c, a ; its slot

	ld hl, MAPOBJECT_Y_COORD
	add hl, de
	ld a, [hli] ; a map object holds y, then x, both 4 more than the map coordinate
	sub 4
	push hl
	ld hl, wYCoord
	sub [hl]
	pop hl
	call .Abs
	cp SWARM_RESPAWN_MARGIN + 1
	jr nc, .next
	ld a, [hl]
	sub 4
	push hl
	ld hl, wXCoord
	sub [hl]
	pop hl
	call .Abs
	cp SWARM_RESPAWN_MARGIN + 1
	jr nc, .next

	push de
	ld e, c
	call GetOverworldMonEncounter
	xor a
	ld [hli], a
	ld [hl], a ; species 0: the slot is empty, which keeps the object masked
	pop de

.next
	ld hl, MAPOBJECT_LENGTH
	add hl, de
	ld d, h
	ld e, l
	inc b
	ld a, b
	cp NUM_OBJECTS
	jr nz, .loop
	ret

.Abs:
	bit 7, a
	ret z
	cpl
	inc a
	ret

RerollPopulation::
; After a battle on a population map: roll every member again (R5). In POP_REROLL_STATS the species
; picked for this visit stays -- wPopulationEntry still names it -- and each member draws a new
; level, form, shininess, DVs and item. In POP_REROLL_SPECIES each member draws a new entry too.
; Every member is then marked unplaced, so the reload places all of them afresh, the one that was
; standing on your tile included.
;
; Runs from OverworldMonBattleScript before reloadmapafterbattle, once EndOverworldMonBattle has
; emptied the fought slot. Does nothing at all on a map without a population.
	ld hl, wPopulationRow
	ld a, [hli]
	ld h, [hl]
	ld l, a
	or h
	ret z

	inc hl ; past the mode
; GetOverworldMonStaticCount promises only a and uses b as scratch, so the count is read after it,
; not held across it. Holding it across cost a round trip with the emulator.
	push hl
	call GetOverworldMonStaticCount
	ld c, a ; the first slot the population owns
	pop hl
	ld a, [hl]
	ld b, a ; how many are out at once
	ld a, c
	cpl
	add NUM_OW_MON_SLOTS + 1 ; a = NUM_OW_MON_SLOTS - c, the slots left
	ret z
	cp b
	jr nc, .got_count
	ld b, a ; the row asks for more than fit
.got_count

	xor a
	ld [wPopulationPlaced], a

.loop
	push bc
; Clear this slot's surface bit before the roll ORs a fresh one in; static slots below c are
; left alone.
	call PlacePopulation.SlotBit ; a = 1 << c
	cpl
	ld hl, wOverworldMonOnSurface
	and [hl]
	ld [hl], a
	ld a, [wPopulationMode]
	cp POP_REROLL_STATS
	call nz, RollOverworldMons.PickPopulationEntry ; species mode picks again per member
	call RollOverworldMons.RollOnePopulationSlot
	pop bc
	inc c
	dec b
	jr nz, .loop
	ret

PlacePopulationAndSpawn::
; The map setup command for MapSetupScript_ReloadMap, which skips LoadMapObjects. Returns at once
; on a map without a population, so the script is unchanged everywhere else.
;
; Writing a map object only decides where the thing stands the next time it is spawned, so the
; members still standing -- the ones you did not fight -- are taken down first. That is the
; deletion half of `disappear`, without its mask. The masks are then rebuilt the same way
; LoadMapObjects rebuilds them, which unmasks the one `disappear` masked now that its slot is
; refilled and keeps any empty slot hidden. Then the placement pass a warp uses, and the spawner a
; warp uses, with the LCD off exactly as a warp has it.
;
; None of this touches the arrival path: PlacePopulation itself only writes map objects.
	ld hl, wPopulationRow
	ld a, [hli]
	or [hl]
	jr nz, .respawn
; A swarming route rerolls its mon after a battle against one of them (RerollSwarmOverworldMons)
; and needs them respawned the same way. Only then, though: this script also follows every
; ordinary grass battle, where the wandering mon have not changed and must be left standing --
; running here after those is what used to empty them one by one. PlacePopulation below does
; nothing off a population map, so a route's mon come back where their objects stand -- hence
; KeepSwarmClearOfPlayer.
	ld hl, wSwarmRespawnPending
	ld a, [hl]
	and a
	ret z
	xor a
	ld [hl], a
	call KeepSwarmClearOfPlayer

.respawn
	ld b, 1
	ld de, wMap1Object
.takedown_loop
	ld hl, MAPOBJECT_TYPE
	add hl, de
	ld a, [hl]
	cp OBJECTTYPE_WILDMON
	jr nz, .takedown_next
	ld hl, MAPOBJECT_SPRITE
	add hl, de
	ld a, [hl]
	sub SPRITE_OW_MON
	cp NUM_OW_MON_SLOTS
	jr nc, .takedown_next
	ld a, b
	push bc
	push de
	call ApplyDeletionToMapObject ; nothing to do when it has no struct
	pop de
	pop bc
.takedown_next
	ld hl, MAPOBJECT_LENGTH
	add hl, de
	ld d, h
	ld e, l
	inc b
	ld a, b
	cp NUM_OBJECTS
	jr nz, .takedown_loop

	call UpdateOverworldMonObjectMasks
	call PlacePopulation
	farcall InitializeVisibleSprites
; The wandering-mon palette table only resets in LoadMapObjects, which this script skips, and in
; species mode every reshuffle brings new species. Left alone, the four entries are spent after a
; couple of battles and every newcomer falls back to palette 0 -- red. So the table is rebuilt from
; the objects now standing, the same way the continue path does it.
	jmp RefreshOverworldMonPalettes

PlacePopulation::
; Give every member of this map's population a tile inside one of its spawn areas, and write it
; into the member's map object. See docs/overworld_pokemon.md, "Placement".
;
; Runs from LoadMapObjects, right before InitializeVisibleSprites: after LoadBlockData and the
; tileset, which the collision test needs, and before anything is spawned. It writes map objects
; only. Spawning is left to the pass that follows, the same one a warp uses, and to the edge
; spawner as members scroll in. Nothing else in the engine spawns object structs from inside map
; setup, and this does not start.
;
; A slot that already has a tile keeps it: map objects come back from ROM on every warp, and the
; tile has to be put back each time.
	ld hl, wPopulationRow
	ld a, [hli]
	or [hl]
	ret z ; not a population map

	call .Bounds
	call .SeedPlacement

	ld b, 1
	ld de, wMap1Object
.loop
	push de

	ld hl, MAPOBJECT_TYPE
	add hl, de
	ld a, [hl]
	cp OBJECTTYPE_WILDMON
	jr nz, .next

	ld hl, MAPOBJECT_SPRITE
	add hl, de
	ld a, [hl]
	sub SPRITE_OW_MON
	cp NUM_OW_MON_SLOTS
	jr nc, .next

	ld c, a ; the slot this object stands for

; An empty slot has no member in it, so there is nothing to place.
	push bc
	ld e, c
	call GetOverworldMonEncounter
	ld a, [hli]
	or [hl]
	pop bc
	jr z, .next

	call .SlotBit
	ld hl, wPopulationPlaced
	and [hl]
	jr nz, .have_tile

	push bc
	call .ScatterMember
	pop bc
	jr nc, .next ; nowhere valid to stand; it keeps the tile its object_event declared

; Remember the tile against the slot, then fall through to apply it.
	call .SlotBit
	ld hl, wPopulationPlaced
	or [hl]
	ld [hl], a
	call .PositionPointer
	ld a, d
	ld [hli], a
	ld [hl], e

.have_tile
	call .PositionPointer
	ld a, [hli]
	add 4 ; map coordinates to object ones
	ld d, a
	ld a, [hl]
	add 4
	ld e, a
; CopyDECoordsToMapObject is in bank 2, and it returns with bc pointing at the map object: GetMapObject
; leaves the address there. farcall keeps registers safe across the trampoline, not across the
; callee, so the object index has to be stacked. Without this every member after the first was
; written to whatever object number the address's high byte happened to name.
	push bc
	farcall CopyDECoordsToMapObject ; b = the object, de = its new tile
	pop bc

.next
	pop de
	ld hl, MAPOBJECT_LENGTH
	add hl, de
	ld d, h
	ld e, l
	inc b
	ld a, b
	cp NUM_OBJECTS
	jr nz, .loop
	ret

.SlotBit:
; in:  c = a slot
; out: a = 1 << c. Preserves bc, de, hl.
	push bc
	ld b, c
	inc b
	xor a
	scf
.slot_bit_loop
	rla ; after slot + 1 rotations a is 1 << slot
	dec b
	jr nz, .slot_bit_loop
	pop bc
	ret

.PositionPointer:
; in:  c = a slot
; out: hl = its entry in wPopulationPositions. Preserves bc, de.
	ld a, c
	add a
	ld l, a
	ld h, 0
	push de
	ld de, wPopulationPositions
	add hl, de
	pop de
	ret

.Areas:
; out: hl = this map's first spawn area
	ld hl, wPopulationRow
	ld a, [hli]
	ld h, [hl]
	ld l, a
	inc hl ; past the mode
	inc hl ; and the count
	ret

.Bounds:
; The smallest rectangle around every area this map lists, into wPopulationBounds. Tiles are drawn
; from that rectangle and kept only if they fall inside an area, which is uniform over the areas'
; union without any arithmetic wider than a byte. A map that lists no areas gets the whole map.
	ld hl, wPopulationBounds
	ld a, -1
	ld [hli], a ; x1
	ld [hli], a ; y1
	xor a
	ld [hli], a ; x2
	ld [hl], a  ; y2

	call .Areas
	ld c, MAX_SPAWN_AREAS
.bounds_loop
	ld a, [hli] ; x1
	ld d, a
	ld a, [hli] ; y1
	ld e, a
	ld a, [hli] ; x2
	ld b, a
	or d
	or e
	or [hl]
	jr z, .bounds_next ; an unused area is all zero
	ld a, [wPopulationBounds]
	cp d
	jr c, .x1_ok
	ld a, d
	ld [wPopulationBounds], a
.x1_ok
	ld a, [wPopulationBounds + 1]
	cp e
	jr c, .y1_ok
	ld a, e
	ld [wPopulationBounds + 1], a
.y1_ok
	ld a, [wPopulationBounds + 2]
	cp b
	jr nc, .x2_ok
	ld a, b
	ld [wPopulationBounds + 2], a
.x2_ok
	ld a, [wPopulationBounds + 3]
	cp [hl]
	jr nc, .bounds_next
	ld a, [hl]
	ld [wPopulationBounds + 3], a
.bounds_next
	inc hl ; past y2
	dec c
	jr nz, .bounds_loop

	ld a, [wPopulationBounds]
	cp -1
	ret nz ; at least one area, so the rectangle is real

; No areas: the whole map, in tiles.
	ld hl, wPopulationBounds
	xor a
	ld [hli], a
	ld [hli], a
	ld a, [wMapWidth]
	add a ; blocks to tiles
	dec a
	ld [hli], a
	ld a, [wMapHeight]
	add a
	dec a
	ld [hl], a
	ret

.ScatterMember:
; in:  c = the slot being placed
; out: carry and d, e = a tile for it in map coordinates, or no carry after POP_PLACE_TRIES.
	ld b, POP_PLACE_TRIES
.try
	push bc
	ld a, [wPopulationBounds + 2]
	ld hl, wPopulationBounds
	sub [hl]
	inc a ; the rectangle's width
	call .PlacementRandomRange ; preserves bc
	ld hl, wPopulationBounds
	add [hl]
	ld b, a ; x
	ld a, [wPopulationBounds + 3]
	ld hl, wPopulationBounds + 1
	sub [hl]
	inc a ; its height
	call .PlacementRandomRange
	ld hl, wPopulationBounds + 1
	add [hl]
	ld e, a ; y
	ld d, b ; x
	pop bc
	call .TileIsFree
	ret c
	dec b
	jr nz, .try
	ret ; no carry: .TileIsFree left it clear

.TileIsFree:
; in:  d = x, e = y, in map coordinates
; out: carry when a member may stand there. Preserves bc and de.
	call .InAnArea
	ret nc

; The player, with a margin either way.
	ld a, [wXCoord]
	sub d
	call .Abs
	cp POP_PLAYER_MARGIN + 1
	jr nc, .not_by_player
	ld a, [wYCoord]
	sub e
	call .Abs
	cp POP_PLAYER_MARGIN + 1
	jr c, .taken
.not_by_player

; Anything else already standing there: another member placed a moment ago, since its tile is
; written straight into its map object, or an NPC.
	push bc
	push de
	ld a, d
	add 4
	ld d, a
	ld a, e
	add 4
	ld e, a ; object coordinates
	ld hl, wMap1Object + MAPOBJECT_SPRITE ; hl walks the sprite bytes
	ld b, NUM_OBJECTS - 1
.object_loop
	ld a, [hl]
	and a
	jr z, .object_next
	push hl
	ld a, l
	add MAPOBJECT_Y_COORD - MAPOBJECT_SPRITE ; a map object holds y, then x
	ld l, a
	adc h
	sub l
	ld h, a
	ld a, [hli]
	cp e
	jr nz, .object_clear
	ld a, [hl]
	cp d
.object_clear
	pop hl
	jr z, .taken_pop
.object_next
	ld a, l
	add MAPOBJECT_LENGTH
	ld l, a
	adc h
	sub l
	ld h, a
	dec b
	jr nz, .object_loop

; Land, by the tileset collision. GetCoordTileCollision wants object coordinates -- d and e are
; already those -- and it and GetBlockLocation use bc and de as scratch. Both are on the stack.
	call GetCoordTileCollision
	call GetTilePermission
	pop de
	pop bc
	and a ; LAND_TILE
	jr nz, .taken
	scf
	ret

.taken_pop
	pop de
	pop bc
.taken
	and a
	ret

.InAnArea:
; in:  d = x, e = y. Carry if inside one of this map's spawn areas, or if it lists none.
; Preserves bc and de.
	push bc
	push de
	call .Areas
	lb bc, 0, MAX_SPAWN_AREAS ; b becomes non-zero once a real area has been seen
.area_loop
	push hl ; this area's start, so a miss part-way through can step cleanly to the next
	ld a, [hli]
	or [hl]
	inc hl
	or [hl]
	inc hl
	or [hl]
	jr z, .area_next ; unused: all four bytes zero
	inc b
	pop hl
	push hl
	ld a, d
	cp [hl] ; x1
	jr c, .area_next ; left of it
	inc hl
	ld a, e
	cp [hl] ; y1
	jr c, .area_next ; above it
	inc hl
	ld a, [hli] ; x2
	cp d
	jr c, .area_next ; right of it
	ld a, [hl] ; y2
	cp e
	jr c, .area_next ; below it
	pop hl
	pop de
	pop bc
	scf
	ret

.area_next
	pop hl
	ld a, l
	add SPAWN_AREA_LENGTH
	ld l, a
	adc h
	sub l
	ld h, a
	dec c
	jr nz, .area_loop
	ld a, b
	pop de
	pop bc
	and a
	ret nz ; there are areas and this tile is in none of them
	scf ; there are no areas: anywhere inside the bounds, which .Bounds made the whole map
	ret

.Abs:
	bit 7, a
	ret z
	cpl
	inc a
	ret

.SeedPlacement:
; Placement rolls its own numbers. Random adds the hardware divider to a running byte, and the
; divider ticks once every 256 cycles; with the LCD off nothing else moves it, and the draws in a
; placement pass come a few dozen cycles apart, so each one adds very nearly the same constant.
; That locks x to y, and it makes a member's 32 tries walk one short line of tiles -- one tile,
; when the constant happens to be a multiple of the range. The line under the player is then
; rejected 32 times over, and the member falls back to where it already stood: on the player.
;
; So the hardware generator is used once per pass, to seed a 16-bit xorshift, and every draw after
; that comes from the xorshift. Full period, no relation between consecutive draws, and a
; different starting point on every pass.
	ldh a, [hRandomAdd]
	ld [wPopulationSeed], a
	ldh a, [hRandomSub]
	ld [wPopulationSeed + 1], a
	ld hl, wPopulationSeed
	or [hl]
	ret nz
	inc [hl] ; a zero seed would stay zero forever
	ret

.PlacementRandom:
; xorshift16: x ^= x << 7; x ^= x >> 9; x ^= x << 8. Out: a = the new low byte. Preserves bc, de.
	push bc
	ld hl, wPopulationSeed
	ld a, [hli]
	ld c, a
	ld b, [hl] ; bc = x
	ld h, b
	ld l, c
rept 7
	add hl, hl
endr
	ld a, l
	xor c
	ld c, a
	ld a, h
	xor b
	ld b, a ; x ^= x << 7
	srl a ; a is still the high byte
	xor c
	ld c, a ; x ^= x >> 9 -- only the low byte is touched
	xor b
	ld b, a ; x ^= x << 8 -- only the high byte is touched
	ld hl, wPopulationSeed
	ld a, c
	ld [hli], a
	ld [hl], b
	pop bc
	ret

.PlacementRandomRange:
; in:  a = a range, 1..255
; out: a = 0 to range - 1. Preserves bc and de. hl is clobbered.
	push bc
	ld c, a
	call .PlacementRandom
	call SimpleDivide ; a = a mod c
	pop bc
	ret

ApplyWildMonMove::
; Give a wild mon the one extra move it was rolled with, on top of whatever its level taught it: a
; wandering mon's from its roster entry or its swarm, a swarm's grass or surf mon's from
; wTempWildMonMove. A plain wild encounter has nowhere to carry a move, which is what makes egg
; moves on a wandering mon worth having at all.
; Called from LoadEnemyMon after FillMoves and before the PP fill, so the move gets its PP free.
	ld hl, wTempWildMonMove
	ld a, [hli]
	ld h, [hl]
	ld l, a
	assert NO_MOVE == 0
	xor a
	ld [wTempWildMonMove], a
	ld [wTempWildMonMove + 1], a ; used up
	ld a, [wOverworldMonBattleSlot]
	and a
	jr z, .got_move
	call GetOverworldMonBattleEncounter
	ld de, OW_MON_MOVE
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
.got_move
	ld a, h
	or l
	ret z ; the entry asked for nothing
	call GetMoveIDFromIndex
	ld b, a

; Already knows it? Nothing to do -- and quietly doubling a move would be worse than doing nothing.
	ld hl, wEnemyMonMoves
	ld c, NUM_MOVES
.known_loop
	ld a, [hli]
	cp b
	ret z
	dec c
	jr nz, .known_loop

; Otherwise the first empty slot, and failing that the first move -- the one it would soonest have
; replaced by levelling anyway.
	ld hl, wEnemyMonMoves
	ld c, NUM_MOVES
.free_loop
	ld a, [hl]
	and a
	jr z, .place
	inc hl
	dec c
	jr nz, .free_loop
	ld hl, wEnemyMonMoves

.place
	ld [hl], b
	ret

UpdateOverworldMonObjectMasks::
; Hide every wandering-mon object whose slot the roll left empty, and every one whose mon has
; already been battled.
;
; Unmasks the ones that do hold a mon, rather than only masking the empty, so that this is the
; whole truth about a wandering mon's visibility and can be called from anywhere -- including the
; save-load path, where LoadObjectMasks never runs and the saved masks are whatever they were.
;
; Done by writing wObjectMasks directly, from LoadMapObjects and after LoadObjectMasks has rebuilt
; the array from event flags. The obvious mechanism would be to give each object one of the
; EVENT_TEMPORARY_UNTIL_MAP_RELOAD_* flags, which clear on exactly the right boundary -- but all
; eight are already spoken for by Bill's house, the Dragon Shrine, Goldenrod Underground, Kurt's
; house, the ports and a dozen more, and there is no ninth. So the slot being empty *is* the
; hidden state, with no flag standing in for it.
	ld b, 1
	ld de, wMap1Object
.loop
	push de

	ld hl, MAPOBJECT_TYPE
	add hl, de
	ld a, [hl]
	cp OBJECTTYPE_WILDMON
	jr nz, .next

	ld hl, MAPOBJECT_SPRITE
	add hl, de
	ld a, [hl]
	sub SPRITE_OW_MON
	cp NUM_OW_MON_SLOTS
	jr nc, .mask ; an OBJECTTYPE_WILDMON on any other sprite has no encounter behind it
	ld e, a
	push bc
	call GetOverworldMonEncounter
	pop bc
	ld a, [hli]
	or [hl]
	jr nz, .unmask ; the slot holds a mon, so let it be seen

.mask
	ld a, -1 ; masked
	jr .apply

.unmask
; An event flag on a wandering-mon object reads the other way round from everywhere else: the mon
; appears only once that event has *happened*, rather than vanishing once it has. The ordinary
; sense is no use here, since an empty slot is already what hides these, and the field was
; otherwise dead on them. It is how a roster waits for something -- the Slowpoke Well Rockets
; clearing out, say -- without a second mechanism.
	pop de
	push de ; the map object again; the slot lookup above reused de
	ld hl, MAPOBJECT_EVENT_FLAG
	add hl, de
	ld a, [hli]
	ld e, a
	ld d, [hl]
	ld a, d
	cp -1
	jr nz, .check_event
	ld a, e
	cp -1
	jr z, .seen ; -1 is no condition at all, which is what most of them carry

.check_event
	push bc
	ld b, CHECK_FLAG
	call EventFlagAction
	pop bc
	ld a, c
	and a
	jr z, .mask ; the event has not happened yet, so nothing is standing here

.seen
	xor a

.apply
	ld hl, wObjectMasks
	ld e, b
	ld d, 0
	add hl, de
	ld [hl], a

.next
	pop de
	ld hl, MAPOBJECT_LENGTH
	add hl, de
	ld d, h
	ld e, l
	inc b
	ld a, b
	cp NUM_OBJECTS
	jr nz, .loop
	ret

INCLUDE "data/wild/overworld_mons.asm"
INCLUDE "data/wild/surface_mons.asm"
INCLUDE "data/wild/mon_populations.asm"
