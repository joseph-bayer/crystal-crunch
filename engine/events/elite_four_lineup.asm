; The Open League's random lineup.
; wEliteFourLineup holds an E4_ROSTER_* id per seat; all zero means not rolled. It is in the save,
; so a reset mid-run keeps the lineup, and the Hall of Fame clears it for the next run.

RollEliteFourLineup::
; Roll a lineup unless one is already set: five distinct characters, a rare one (Joey) in one run
; in E4_RARE_ODDS in a random seat, and no E4_ROSTER_NO_CHAMPION character as champion. The last
; run's champion (wEliteFourLastChampion) can't be champion again, but can take another seat.
	ld a, [wEliteFourLineup + E4_SEAT_CHAMPION]
	and a
	ret nz

	call ClearEliteFourLineup

	ld a, E4_RARE_ODDS
	call RandomRange
	and a
	jr nz, .champion
	lb bc, E4_ROSTER_RARE, E4_ROSTER_RARE
	call PickEliteFourRosterEntry
	and a
	jr z, .champion
	ld d, a
	ld a, NUM_E4_SEATS
	call RandomRange
	ld e, a
	ld a, d
	ld d, 0
	ld hl, wEliteFourLineup
	add hl, de
	ld [hl], a

.champion
	ld hl, wEliteFourLineup + E4_SEAT_CHAMPION
	ld a, [hl]
	and a
	jr nz, .seats
	ld a, [wEliteFourLastChampion]
	ld [hl], a ; in the lineup for now, so the pick skips them
	lb bc, E4_ROSTER_RARE | E4_ROSTER_NO_CHAMPION, 0
	call PickEliteFourRosterEntry
	ld [wEliteFourLineup + E4_SEAT_CHAMPION], a

.seats
	ld hl, wEliteFourLineup
	ld e, E4_SEAT_CHAMPION ; every seat before it
.seat_loop
	ld a, [hl]
	and a
	jr nz, .next_seat
	push hl
	push de
	lb bc, E4_ROSTER_RARE, 0
	call PickEliteFourRosterEntry
	pop de
	pop hl
	ld [hl], a
.next_seat
	inc hl
	dec e
	jr nz, .seat_loop
	ret

EndEliteFourRun::
; The Hall of Fame: remember this run's champion for the next roll, then clear the lineup. A run
; without a lineup (the original Elite Four) had Lance.
	ld a, [wEliteFourLineup + E4_SEAT_CHAMPION]
	and a
	jr nz, .got_champion
	ld a, E4_ROSTER_LANCE
.got_champion
	ld [wEliteFourLastChampion], a
	; fallthrough

ClearEliteFourLineup::
	ld hl, wEliteFourLineup
	ld bc, NUM_E4_SEATS
	xor a
	jmp ByteFill

PickEliteFourRosterEntry:
; in: b = flags to test, c = the value they must have
; out: a = a random roster id not yet in the lineup whose flags & b == c, or 0 if there is none
	lb de, 1, 0 ; d = the id, e = how many qualify
.count
	ld a, d
	call .Qualifies
	jr nc, .count_next
	inc e
.count_next
	inc d
	ld a, d
	cp NUM_E4_ROSTER + 1
	jr c, .count

	ld a, e
	and a
	ret z
	call RandomRange
	ld e, a
	ld d, 1
.pick
	ld a, d
	call .Qualifies
	jr nc, .pick_next
	ld a, e
	and a
	ld a, d
	ret z
	dec e
.pick_next
	inc d
	jr .pick

.Qualifies:
; carry if roster id a is not in the lineup and its flags & b == c; preserves bc and de
	push de
	ld hl, wEliteFourLineup
	ld e, NUM_E4_SEATS
.in_lineup
	cp [hl]
	jr z, .no
	inc hl
	dec e
	jr nz, .in_lineup
	call GetEliteFourRosterEntry
	push hl
	ld de, E4ROSTER_UNLOCK_EVENT
	add hl, de
	ld a, [hli]
	ld d, [hl]
	ld e, a
	pop hl
	and d
	inc a
	jr z, .unlocked ; -1: always
	push bc
	push hl
	ld b, CHECK_FLAG
	call EventFlagAction
	ld a, c
	pop hl
	pop bc
	and a
	jr z, .no
.unlocked
	ld de, E4ROSTER_FLAGS
	add hl, de
	ld a, [hl]
	and b
	cp c
	pop de
	scf
	ret z
	and a
	ret

.no
	pop de
	and a
	ret

GetEliteFourRosterEntry:
; in: a = roster id; out: hl = its EliteFourRoster entry. Clobbers de.
	dec a
	ld e, a
	ld d, 0
	ld hl, EliteFourRoster
rept E4_ROSTER_ENTRY_LENGTH
	add hl, de
endr
	ret

GetEliteFourRosterName::
; in: a = roster id; out: hl = its name
	call GetEliteFourRosterEntry
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret

; Seat battles. wEliteFourSeatBattle is the seat plus 1 while one is being fought (0 otherwise),
; set by LoadEliteFourSeatTrainer and cleared with the rest of the battle RAM.

LoadEliteFourSeatTrainer::
; The script's loadtrainer for a seat: wScriptVar = the E4_SEAT_* to fight. Rolls a lineup if
; none is set.
	call RollEliteFourLineup
	ld a, [wScriptVar]
	ld e, a
	ld d, 0
	ld hl, wEliteFourLineup
	add hl, de
	ld a, [hl]
	call GetEliteFourRosterEntry
	ld de, E4ROSTER_CLASS
	add hl, de
	ld a, [hli]
	ld [wOtherTrainerClass], a
	ld a, [hl]
	ld [wOtherTrainerID], a
	ld a, (1 << 7) | 1 ; as Script_loadtrainer
	ld [wBattleScriptFlags], a
	ld a, [wScriptVar]
	inc a
	ld [wEliteFourSeatBattle], a
	ret

EliteFourSeatMonLevel::
; ReadTrainerPartyPieces, for each Pokemon in the party data: in a seat battle, replace
; wCurPartyLevel with the seat's level for this slot. Carry if the seat's team is already full,
; so the rest of the list is skipped. Preserves bc, de and hl.
	ld a, [wEliteFourSeatBattle]
	and a
	ret z
	push bc
	push de
	push hl
	dec a
	ld c, a ; c = the seat
	ld b, E4_SEAT_TEAM_SIZE
	ld de, EliteFourSeatLevelOffsets
	cp E4_SEAT_CHAMPION
	jr nz, .got_size
	ld b, E4_CHAMPION_TEAM_SIZE
	ld de, EliteFourChampionLevelOffsets
.got_size
	ld a, [wOTPartyCount]
	cp b
	ccf
	jr c, .done ; full
	ld l, a
	ld h, 0
	add hl, de
	ld b, [hl] ; this slot's offset
	call GetEliteFourSeatStats
	ld a, [hl] ; the seat's base level
	add b
	ld [wCurPartyLevel], a
	and a ; not full
.done
	pop hl
	pop de
	pop bc
	ret

EliteFourSeatFinishParty::
; ReadTrainerParty, once the party is loaded: in a seat battle, give every Pokemon the seat's DVs
; and EVs, recalculate its stats at full HP, and apply the character's nicknames.
	ld a, [wEliteFourSeatBattle]
	and a
	ret z
	dec a
	ld c, a
	call GetEliteFourSeatStats
	inc hl
	ld a, [hli]
	ld [wEliteFourSeatMinDV], a
	ld a, [hl]
	ld [wEliteFourSeatEVs], a

	xor a
.mon_loop
	push af
	ld hl, wOTPartyMon1
	call GetPartyLocation
	push hl

	; DVs: every one raised to at least the seat's minimum
	ld bc, MON_DVS
	add hl, bc
	ld a, [hl]
	call .RaiseDVs
	ld [hli], a
	ld a, [hl]
	call .RaiseDVs
	ld [hl], a

	; EVs: the seat's, in every stat
	pop hl
	push hl
	ld bc, MON_EVS
	add hl, bc
	ld a, [wEliteFourSeatEVs]
	ld b, NUM_STATS
.ev_loop
	ld [hli], a
	dec b
	jr nz, .ev_loop

	; Stats at this level, with the new DVs and EVs counted
	pop hl
	push hl
	ld bc, MON_LEVEL
	add hl, bc
	ld a, [hl]
	ld [wCurPartyLevel], a
	pop hl
	push hl
	ld a, [hl] ; MON_SPECIES
	ld [wCurSpecies], a
	call GetBaseData
	pop hl
	push hl
	ld bc, MON_MAXHP
	add hl, bc
	ld d, h
	ld e, l
	pop hl
	push hl
	ld bc, MON_EVS - 1
	add hl, bc
	ld b, TRUE
	farcall CalcMonStats

	; Full HP
	pop hl
	ld bc, MON_MAXHP
	add hl, bc
	ld a, [hli]
	ld b, a
	ld c, [hl]
	ld de, MON_HP - (MON_MAXHP + 1)
	add hl, de
	ld a, b
	ld [hli], a
	ld [hl], c

	pop af
	inc a
	ld hl, wOTPartyCount
	cp [hl]
	jr c, .mon_loop

	; Name every Pokemon after its species: a seat battle shows the party's nicknames (LoadEnemyMon
	; copies the party entry), and a trainer's party has none. The nickname list then renames some.
	xor a
.name_loop
	push af
	ld e, a
	ld d, 0
	ld hl, wOTPartySpecies
	add hl, de
	ld a, [hl]
	ld [wNamedObjectIndex], a
	call GetPokemonName
	pop af
	push af
	ld hl, wOTPartyMonNicknames
	call SkipNames
	ld d, h
	ld e, l
	ld hl, wStringBuffer1
	ld bc, MON_NAME_LENGTH
	rst CopyBytes
	pop af
	inc a
	ld hl, wOTPartyCount
	cp [hl]
	jr c, .name_loop

	; Nicknames
	ld a, [wEliteFourSeatBattle]
	dec a
	ld e, a
	ld d, 0
	ld hl, wEliteFourLineup
	add hl, de
	ld a, [hl]
	call GetEliteFourRosterEntry
	ld de, E4ROSTER_NICKNAMES
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	or h
	ret z
.nickname_loop
	ld a, [hli]
	cp -1
	ret z
	ld b, a ; the slot
	ld a, [wOTPartyCount]
	dec a
	cp b
	jr c, .skip_nickname ; past the team
	push hl
	ld a, b
	ld hl, wOTPartyMonNicknames
	call SkipNames
	ld d, h
	ld e, l
	pop hl
.copy_nickname
	ld a, [hli]
	ld [de], a
	inc de
	cp "@"
	jr nz, .copy_nickname
	jr .nickname_loop

.skip_nickname
	ld a, [hli]
	cp "@"
	jr nz, .skip_nickname
	jr .nickname_loop

.RaiseDVs:
; a = a DV byte; each nibble raised to at least wEliteFourSeatMinDV
	push bc
	ld b, a
	ld a, [wEliteFourSeatMinDV]
	ld c, a
	ld a, b
	swap a
	and $f
	cp c
	jr nc, .high_ok
	ld a, c
.high_ok
	swap a
	ld d, a
	ld a, b
	and $f
	cp c
	jr nc, .low_ok
	ld a, c
.low_ok
	or d
	pop bc
	ret

GetEliteFourSeatStats:
; in: c = seat; out: hl = its EliteFourSeatStats row
	ld a, c
	ld hl, EliteFourSeatStats
	add a
	add c ; 3 bytes a row
	add l
	ld l, a
	ret nc
	inc h
	ret

EliteFourSeatStats:
; entries correspond to E4_SEAT_* constants: base level, minimum DV, EVs
	table_width 3
	db E4_SEAT_1_LEVEL,   E4_SEAT_MIN_DV,     E4_SEAT_EVS
	db E4_SEAT_2_LEVEL,   E4_SEAT_MIN_DV,     E4_SEAT_EVS
	db E4_SEAT_3_LEVEL,   E4_SEAT_MIN_DV,     E4_SEAT_EVS
	db E4_SEAT_4_LEVEL,   E4_SEAT_MIN_DV,     E4_SEAT_4_EVS
	db E4_CHAMPION_LEVEL, E4_CHAMPION_MIN_DV, E4_CHAMPION_EVS
	assert_table_length NUM_E4_SEATS

EliteFourSeatLevelOffsets:
; added to the seat's base level, by party slot; the last is the ace
	db 0, 1, 0, 1, 2
	assert @ - EliteFourSeatLevelOffsets == E4_SEAT_TEAM_SIZE

EliteFourChampionLevelOffsets:
	db 0, 1, 2, 1, 2, 4
	assert @ - EliteFourChampionLevelOffsets == E4_CHAMPION_TEAM_SIZE

; The rooms. Each Elite Four room, and the Hall of Fame for the champion, runs ApplyEliteFourRoom
; in a MAPCALLBACK_CMDQUEUE callback: that runs both on entering and on continuing a save, after
; the map header is read (so it can be overridden) and before the blocks, tileset and objects load.
; Before the Open League starts nothing changes, and the rooms are as they always were.

IsOpenLeagueStarted:
; nz if the Open League has started, so every run is a random lineup
	push bc
	push de
	push hl
	ld de, EVENT_OPEN_LEAGUE_STARTED
	ld b, CHECK_FLAG
	call EventFlagAction
	ld a, c
	and a
	pop hl
	pop de
	pop bc
	ret

GetEliteFourRoomSeatEntry:
; in: a = seat; out: hl = the EliteFourRoster entry of whoever sits there. Rolls a lineup if the
; Open League has started and none is set.
	ld e, a
	ld d, 0
	call IsOpenLeagueStarted
	jr z, .member
	push de
	call RollEliteFourLineup
	pop de
	ld hl, wEliteFourLineup
	add hl, de
	ld a, [hl]
	jmp GetEliteFourRosterEntry

.member
	ld hl, EliteFourSeatMembers
	add hl, de
	ld a, [hl]
	jmp GetEliteFourRosterEntry

ApplyEliteFourRoom::
; wScriptVar = the room's seat. During the Open League: the room's first object becomes the seat
; holder (sprite and palette) and, in an Elite Four room, the room takes their home layout.
	ld a, [wScriptVar]
	ld [wEliteFourRoomSeat], a
	call IsOpenLeagueStarted
	ret z
	ld a, [wScriptVar]
	call GetEliteFourRoomSeatEntry
	push hl
	ld a, 2 ; the first map object (object_const_def)
	call GetMapObject
	pop hl
	push hl
	ld de, E4ROSTER_SPRITE
	add hl, de
	ld a, [hli]
	ld d, a ; sprite
	ld e, [hl] ; palette
	ld hl, MAPOBJECT_SPRITE
	add hl, bc
	ld [hl], d
	ld hl, MAPOBJECT_PALETTE
	add hl, bc
	ld [hl], e
	pop hl

	ld a, [wEliteFourRoomSeat]
	cp E4_SEAT_CHAMPION
	ret z ; the champion's room keeps its own layout
	ld de, E4ROSTER_LAYOUT
	add hl, de
	ld a, [hl]
	ld hl, EliteFourRoomLayouts
	add a
	add a ; 4 bytes a row
	ld e, a
	ld d, 0
	add hl, de
	ld a, [hli]
	ld [wMapTileset], a
	ld a, [hli]
	ld [wMapBlocksBank], a
	ld a, [hli]
	ld [wMapBlocksPointer], a
	ld a, [hl]
	ld [wMapBlocksPointer + 1], a
	ret

EliteFourRoomPartner::
; GetOverworldMonSlot, before the static table: during the Open League, an Elite Four room's or the
; champion's room's SPRITE_OW_MON_1 is the seat holder's partner.
; in: e = the slot; out: carry, hl = species index, a = form; preserves de otherwise
	ld a, e
	and a
	ret nz
	call IsOpenLeagueStarted
	ret z
	push de
	ld hl, EliteFourRoomMaps
	ld e, 0 ; the seat
.find_map
	ld a, [wMapGroup]
	cp [hl]
	inc hl
	jr nz, .next_map
	ld a, [wMapNumber]
	cp [hl]
	jr z, .found
.next_map
	inc hl
	inc e
	ld a, e
	cp NUM_E4_SEATS
	jr c, .find_map
	pop de
	and a
	ret

.found
	ld a, e
	call GetEliteFourRoomSeatEntry
	ld de, E4ROSTER_PARTNER
	add hl, de
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hl] ; form
	ld h, d
	ld l, e
	pop de
	scf
	ret

GetEliteFourRoomText:
; in: e = a text field (E4ROSTER_*_TEXT); out: b = bank (0 if none), hl = the room seat holder's
	push de
	ld a, [wEliteFourRoomSeat]
	call GetEliteFourRoomSeatEntry
	pop de
	ld d, 0
	add hl, de
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret

PrintEliteFourBeforeText::
	ld e, E4ROSTER_BEFORE_TEXT
	jr PrintEliteFourRoomText

PrintEliteFourAfterText::
	ld e, E4ROSTER_AFTER_TEXT
PrintEliteFourRoomText:
	call GetEliteFourRoomText
	jmp MapTextbox

PrintEliteFourHallOfFameText::
; The Hall of Fame: wScriptVar = TRUE if this run's champion has their own line in place of the
; usual speech (and it's printed)
	xor a
	ld [wScriptVar], a
	ld a, E4_SEAT_CHAMPION
	call GetEliteFourRoomSeatEntry
	ld de, E4ROSTER_HALL_OF_FAME_TEXT
	add hl, de
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, b
	and a
	ret z
	ld a, TRUE
	ld [wScriptVar], a
	jmp MapTextbox

GetEliteFourSeatBeatenText::
; PrintWinLossText, in a seat battle: a = bank, hl = the seat holder's beaten text
	ld a, [wEliteFourSeatBattle]
	dec a
	ld e, a
	ld d, 0
	ld hl, wEliteFourLineup
	add hl, de
	ld a, [hl]
	call GetEliteFourRosterEntry
	ld de, E4ROSTER_BEATEN_TEXT
	add hl, de
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, b
	ret

EliteFourRoomSeatToScriptVar::
	ld a, [wEliteFourRoomSeat]
	ld [wScriptVar], a
	ret

EliteFourPartnerCry::
; Play the room's partner's cry, and put its name in wStringBuffer1
	ld a, [wEliteFourRoomSeat]
	call GetEliteFourRoomSeatEntry
	ld de, E4ROSTER_PARTNER
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call GetPokemonIDFromIndex
	push af
	ld [wNamedObjectIndex], a
	call GetPokemonName
	pop af
	jmp PlayMonCry

EliteFourSeatBattleScript::
; The battle in an Elite Four room during the Open League, farscalled with the text box open: the seat
; holder's lines, then their team by the seat's rules (LoadEliteFourSeatTrainer). The room opens
; its door afterwards.
	callasm PrintEliteFourBeforeText
	waitbutton
	closetext
	callasm EliteFourRoomSeatToScriptVar
	callasm LoadEliteFourSeatTrainer
	winlosstext 0, 0 ; the seat holder's beaten text (PrintWinLossText); a loss blacks out
	startbattle
	reloadmapafterbattle
	opentext
	callasm PrintEliteFourAfterText
	waitbutton
	closetext
	end

EliteFourAfterBattleScript::
; Talking to the seat holder again, with the text box open
	callasm PrintEliteFourAfterText
	waitbutton
	closetext
	end

EliteFourPartnerScript::
; Talking to the seat holder's partner during the Open League
	opentext
	callasm EliteFourPartnerCry
	farwritetext EliteFourPartnerText
	waitbutton
	closetext
	end

EliteFourPartnerText:
	text_ram wStringBuffer1
	text " looks"
	line "determined."
	done

if DEF(_DEBUG)
DebugRerollEliteFourLineup::
	call ClearEliteFourLineup
	; fallthrough

DebugShowEliteFourLineup::
; The Lab scientist's E4 LINEUP: roll one if none is set, and put the five names in
; wStringBuffer1-5, seat order, for PlayersHouseDebugE4LineupText.
	call RollEliteFourLineup
	ld bc, wEliteFourLineup
	ld de, wStringBuffer1
.loop
	ld a, [bc]
	push bc
	push de
	ld hl, .Empty
	and a
	call nz, GetEliteFourRosterName
	pop de
	push de
	ld bc, STRING_BUFFER_LENGTH
	rst CopyBytes
	pop de
	ld hl, STRING_BUFFER_LENGTH
	add hl, de
	ld d, h
	ld e, l
	pop bc
	inc bc
	ld a, e
	cp LOW(wStringBuffer1 + NUM_E4_SEATS * STRING_BUFFER_LENGTH)
	jr nz, .loop
	ret

.Empty:
	db "-@"

; SET SEAT's picker. Outside a seat battle, wEliteFourSeatEVs holds the seat being set and
; wEliteFourSeatMinDV the roster id on show; LoadEliteFourSeatTrainer sets both before a battle.

DebugE4PickerStart::
; wScriptVar = the seat; start at whoever sits there, rolling a lineup if none is set
	call RollEliteFourLineup
	ld a, [wScriptVar]
	ld [wEliteFourSeatEVs], a
	call DebugE4SeatInLineup
	ld a, [hl]
	ld [wEliteFourSeatMinDV], a
	jr DebugE4PickerName

DebugE4PickerStep::
; wScriptVar = 1 PREV, 2 NEXT, 3 BACK 5, 4 NEXT 5; wraps around the roster
	ld a, [wScriptVar]
	dec a
	ld e, a
	ld d, 0
	ld hl, DebugE4PickerSteps
	add hl, de
	ld a, [wEliteFourSeatMinDV]
	add [hl]
	bit 7, a
	jr nz, .under
	and a
	jr z, .under
	cp NUM_E4_ROSTER + 1
	jr c, .got
	sub NUM_E4_ROSTER
	jr .got

.under
	add NUM_E4_ROSTER
.got
	ld [wEliteFourSeatMinDV], a
	; fallthrough

DebugE4PickerName:
; wStringBuffer1 = the name on show
	ld a, [wEliteFourSeatMinDV]
	call GetEliteFourRosterName
	ld de, wStringBuffer1
	ld bc, STRING_BUFFER_LENGTH
	rst CopyBytes
	ret

DebugE4PickerSteps:
	db -1, 1, -5, 5

DebugE4PickerSet::
; Seat the character on show; if they sit in another seat, they swap with this seat's holder
	call DebugE4SeatInLineup
	ld b, [hl]
	ld a, [wEliteFourSeatMinDV]
	ld c, a
	ld hl, wEliteFourLineup
	ld d, NUM_E4_SEATS
.find
	ld a, [hl]
	cp c
	jr nz, .next
	ld [hl], b
.next
	inc hl
	dec d
	jr nz, .find
	call DebugE4SeatInLineup
	ld [hl], c
	ret

DebugE4SeatInLineup:
; hl = the wEliteFourLineup byte of seat [wEliteFourSeatEVs]
	ld a, [wEliteFourSeatEVs]
	ld e, a
	ld d, 0
	ld hl, wEliteFourLineup
	add hl, de
	ret

DebugE4LastChampionName::
; wStringBuffer1 = the last run's champion's name, or "-" if none is stored
	ld a, [wEliteFourLastChampion]
	ld hl, DebugShowEliteFourLineup.Empty
	and a
	call nz, GetEliteFourRosterName
	ld de, wStringBuffer1
	ld bc, STRING_BUFFER_LENGTH
	rst CopyBytes
	ret

DebugClearPokedex::
; CLEAR DEX: nothing seen or caught (the two flag arrays are next to each other)
	ld hl, wPokedexCaught
	ld bc, wEndPokedexSeen - wPokedexCaught
	xor a
	jmp ByteFill

DebugSetDex250::
; 250 caught: every species seen and caught but Mew, which is neither
	call DebugFillPokedex
	jr DebugUncatchMew

DebugSetDex249::
; 249 caught: every species seen and caught but Mew and Celebi, which are neither
	call DebugFillPokedex
	ld de, CELEBI
	call DebugUncatchMon
DebugUncatchMew:
	ld de, MEW
DebugUncatchMon:
; de = a species index
	dec de
	push de
	ld hl, wPokedexCaught
	ld b, RESET_FLAG
	call FlagAction
	pop de
	ld hl, wPokedexSeen
	ld b, RESET_FLAG
	jmp FlagAction

DebugFillPokedex:
; The game's own species; the new slots stay empty
	ld de, NUM_ORIGINAL_POKEMON
.loop
	push de
	call SetSeenMonIndex
	pop de
	push de
	call SetCaughtMonIndex
	pop de
	dec de
	ld a, d
	or e
	jr nz, .loop
	ret

DebugResetOpenLeague::
; RESET LEAGUE's save state: no lineup and no last champion
	xor a
	ld [wEliteFourLastChampion], a
	jmp ClearEliteFourLineup
endc

INCLUDE "data/events/elite_four_roster.asm"
