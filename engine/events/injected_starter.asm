; The starter a ROM can be given by the starter injector. The injector finds these bytes by their
; labels in the release's .sym and writes them; the plain build leaves the species 0, and a new game
; starts as it always has, with the pick in Elm's lab.

DEF INJECTED_STARTER_LEVEL EQU 5

InjectedStarter::
InjectedStarterSpecies::  dw 0 ; a species index; 0 for none
InjectedStarterForm::     db PLAIN_FORM ; its MON_FORM byte: the form, SHINY_MASK and ALT_SHINY_MASK
InjectedStarterItem::     dw NO_ITEM ; an item index
InjectedStarterDVs::      db $00, $00 ; Attack and Defense, Speed and Special, a nybble each
InjectedStarterMoves::    dw 0, 0, 0, 0 ; move indexes; all 0 for the moves it learns by its level
InjectedStarterNickname:: ds MON_NAME_LENGTH, "@" ; "@" first for its species name
InjectedStarterRival::    dw 0 ; the line the rival takes: CHIKORITA, CYNDAQUIL or TOTODILE
InjectedStarterBall::     dw POKE_BALL ; the ball it was caught in: an item index of the Ball pocket
InjectedStarterEnd::

GiveInjectedStarter::
; A new game in a ROM with a starter injected starts with it in party slot 1, following you.
	ld hl, InjectedStarterSpecies
	ld a, [hli]
	ld h, [hl]
	ld l, a
	or h
	ret z ; none injected
	call GetPokemonIDFromIndex
	ld [wCurPartySpecies], a
	ld a, INJECTED_STARTER_LEVEL
	ld [wCurPartyLevel], a
	ld a, [InjectedStarterForm]
	ld [wEnemyMonForm], a ; the form TryAddMonToParty stores, shine included
	xor a ; PARTYMON
	ld [wMonType], a
	ld [wBattleMode], a
	predef TryAddMonToParty ; the first mon in an empty party follows you
	ld hl, wFollowerFlags
	set FOLLOWER_BESIDE_F, [hl] ; standing at your left when the game starts
	ld a, [wPartyCount]
	dec a
	ld [wCurPartyMon], a

; The held item
	ld hl, InjectedStarterItem
	ld a, [hli]
	ld h, [hl]
	ld l, a
	or h ; NO_ITEM is 0 either way
	call nz, GetItemIDFromIndex
	ld b, a
	ld a, MON_ITEM
	call GetPartyParamLocation
	ld [hl], b

; The DVs, which also decide its gender
	ld a, MON_DVS
	call GetPartyParamLocation
	ld a, [InjectedStarterDVs]
	ld [hli], a
	ld a, [InjectedStarterDVs + 1]
	ld [hl], a

; The moves, if the injector chose them, and their PP
	ld hl, InjectedStarterMoves
	ld b, NUM_MOVES * 2
	xor a
.any_move
	or [hl]
	inc hl
	dec b
	jr nz, .any_move
	and a
	jr z, .stats ; the moves it learns by its level, as TryAddMonToParty gave
	ld a, MON_MOVES
	call GetPartyParamLocation
	ld d, h
	ld e, l
	ld hl, InjectedStarterMoves
	ld b, NUM_MOVES
.move_loop
	push bc
	ld a, [hli]
	ld c, a
	ld a, [hli]
	push hl
	ld h, a
	ld l, c
	or l ; an empty slot is 0 either way
	call nz, GetMoveIDFromIndex
	ld [de], a
	inc de
	pop hl
	pop bc
	dec b
	jr nz, .move_loop
	ld a, MON_PP
	call GetPartyParamLocation
	ld d, h
	ld e, l
	ld a, MON_MOVES
	call GetPartyParamLocation
	predef FillPP

.stats
; Its stats, from the DVs, at full HP
	ld a, MON_MAXHP
	call GetPartyParamLocation
	ld d, h
	ld e, l
	ld a, MON_EVS - 1
	call GetPartyParamLocation
	ld b, TRUE
	predef CalcMonStats
	ld a, MON_MAXHP
	call GetPartyParamLocation
	ld a, [hli]
	ld b, a
	ld c, [hl]
	ld a, MON_HP
	call GetPartyParamLocation
	ld a, b
	ld [hli], a
	ld [hl], c

; Its nickname
	ld a, [InjectedStarterNickname]
	cp "@"
	jr z, .caught_data
	ld a, [wCurPartyMon]
	ld hl, wPartyMonNicknames
	call SkipNames
	ld d, h
	ld e, l
	ld hl, InjectedStarterNickname
	ld bc, MON_NAME_LENGTH
	rst CopyBytes

.caught_data
; Caught in the injected ball, and met in New Bark Town, as Elm's starters are: no map is loaded yet
; to name. The ball only changes what the stats screen and the Pokédex show.
	ld hl, InjectedStarterBall
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call GetItemIDFromIndex
	ld [wCurItem], a
	farcall SetCaughtData
	ld a, MON_CAUGHTLOCATION
	call GetPartyParamLocation
	ld a, [hl]
	and CAUGHT_GENDER_MASK
	or LANDMARK_NEW_BARK_TOWN
	ld [hl], a
	ret

CheckInjectedStarter::
; wScriptVar = TRUE if this ROM has a starter injected
	ld hl, InjectedStarterSpecies
	ld a, [hli]
	or [hl]
	jr z, .done
	ld a, TRUE
.done
	ld [wScriptVar], a
	ret

SetInjectedStarterRival::
; Mark the Johto starter the rival's line beats as yours, as if you took it, so the rival takes his
; line's starter and fights with its parties wherever the game asks which starter you took.
	ld hl, InjectedStarterRival
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, EVENT_GOT_TOTODILE_FROM_ELM
	cphl16 CHIKORITA
	jr z, .got_event
	ld de, EVENT_GOT_CHIKORITA_FROM_ELM
	cphl16 CYNDAQUIL
	jr z, .got_event
	ld de, EVENT_GOT_CYNDAQUIL_FROM_ELM ; TOTODILE
.got_event
	ld b, SET_FLAG
	jmp EventFlagAction

CheckPartyForNewMons::
; The cable club turns away a party holding a species from one of the new slots, eggs included: a
; game without it would read past its tables. wScriptVar = TRUE, with that species' name in
; wStringBuffer1, if one is there.
	ld a, [wPartyCount]
	and a
	jr z, .none
	ld b, a
	ld hl, wPartyMon1Species
.loop
	ld a, [hl]
	push hl
	push bc
	push af
	call GetPokemonIndexFromID
	ld a, h
	and a
	jr nz, .found ; an index past 255
	ld a, l
	cp NUM_ORIGINAL_POKEMON + 1
	jr nc, .found
	pop af
	pop bc
	pop hl
	ld de, PARTYMON_STRUCT_LENGTH
	add hl, de
	dec b
	jr nz, .loop
.none
	xor a
	ld [wScriptVar], a
	ret

.found
	pop af
	pop bc
	pop hl
	ld [wNamedObjectIndex], a
	call GetPokemonName
	ld a, TRUE
	ld [wScriptVar], a
	ret
