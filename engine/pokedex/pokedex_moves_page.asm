; started as 5 before UI overhaul, now is 7
; would decrease to 3 if we wanted to use additional line for attack info
DEF MAX_NUM_MOVES EQU 7

; what a page's row printers return when the page has no room left
DEF ROWS_FULL EQU -1

MACRO field_move
; a field move, and its TM/HM/tutor flag if a machine or tutor teaches it
	dw \1
	IF DEF(\1_TMNUM)
		db \1_TMNUM
	ELSE
		db 0
	ENDC
ENDM

Field_Moves_List:
; the moves usable outside battle (see data/mon_menu.asm)
	field_move TELEPORT
	field_move SOFTBOILED
	field_move MILK_DRINK
	field_move HEADBUTT
	field_move ROCK_SMASH
	field_move SWEET_SCENT
	field_move DIG
	field_move CUT
	field_move FLY
	field_move SURF
	field_move STRENGTH
	field_move FLASH
	field_move WATERFALL
	field_move WHIRLPOOL
	dw 0 ; end

; the category box is 2 tiles high, 12 tiles wide
; must fill in spaces to erase other text already printed
; top string goes in 8, 6, bottom in 8, 7
String_LVL_text:
	db "LVL-UP     @"
String_FIELD_text:
	db "FIELD      @"
String_EGG_text:
	db "EGG        @"
String_MOVES_text:
	db " MOVES     @"
String_TECH_text:
	db "TECHNICAL  @"
String_MACHINES_text:
	db " MACHINES  @"
String_MOVE_text:
	db "MOVE       @"
String_TUTOR_text:
	db " TUTOR     @"

Pokedex_SkipEvolutions:
; Receives a pointer to the evos and attacks for a mon in b:hl, and skips to the attacks.
; (The same as SkipEvolutions in engine/pokemon/evolve.asm.)
	ld a, b
	call GetFarByte
	inc hl
	and a
	ret z
	cp EVOLVE_LEVEL
	jr z, .no_extra_skip
	cp EVOLVE_HAPPINESS
	jr z, .no_extra_skip
	inc hl
.no_extra_skip
	inc hl
	inc hl
	inc hl
	jr Pokedex_SkipEvolutions

Pokedex_GetNextEvoAttackByte: ; ripped straight from engine\pokemon\evolve.asm
	ldh a, [hTemp]
	call GetFarByte
	inc hl
	ret

Print_Category_MOVES_text:
	ld hl, String_MOVES_text
	jmp Print_Category_text

DisplayDexMonMoves::
	ld a, [wTempSpecies]
	ld [wCurSpecies], a
	ld [wCurPartySpecies], a
	call Pokedex_Clearbox

	; the byte flag that tells us which type of table we're currently on
	; 0 = Info, 1 = Stats, 2 = LVL UP, 3 = FIELD, 4 =  EGG, 5 = TMs, 6 = HMs, 7 = MTs
	
	ld a, [wPokedexEntryType]
	cp DEXENTRY_LVLUP
	jr z, .LvlUpLearnset
	cp DEXENTRY_EGG
	jr z, .EggMoves
	cp DEXENTRY_FIELD
	jr z, .Field_Moves
	cp DEXENTRY_TMS
	jr z, .TMs
	; bit DEXENTRY_HMS, a
	; jr nz, .HMs
	cp DEXENTRY_MTS
	jr z, .MTs
.LvlUpLearnset_new
	ld a, DEXENTRY_LVLUP
	call DexEntry_NextCategory
.LvlUpLearnset
; place category name
	ld de, String_LVL_text
	call Print_Category_MOVES_text

	ld a, DEXENTRY_LVLUP
	ld [wPokedexEntryType], a
	call Pokedex_Calc_LvlMovesPtr
	jr Pokedex_Print_NextLvlMoves
.EggMoves
; place category name
	ld de, String_EGG_text
	call Print_Category_MOVES_text

	ld a, DEXENTRY_EGG
	ld [wPokedexEntryType], a
	call Pokedex_Calc_EggMovesPtr
	ret z
	jmp Pokedex_Print_Egg_moves
.Field_Moves
; place category name
	ld de, String_FIELD_text
	call Print_Category_MOVES_text

	ld a, DEXENTRY_FIELD
	ld [wPokedexEntryType], a
	jmp Pokedex_PrintFieldMoves
.TMs
; place category name
	ld de, String_TECH_text
	ld hl, String_MACHINES_text
	call Print_Category_text

	ld a, DEXENTRY_TMS
	ld [wPokedexEntryType], a
	jmp Pokedex_PrintTMs
; .HMs
; 	ld a, DEXENTRY_HMS
; 	ld [wPokedexEntryType], a
; 	call Pokedex_PrintHMs
; 	ret
.MTs
; place category name
	ld de, String_MOVE_text
	ld hl, String_TUTOR_text
	call Print_Category_text

	ld a, DEXENTRY_MTS
	ld [wPokedexEntryType], a
	jmp Pokedex_PrintMTs

Pokedex_Calc_LvlMovesPtr:
	ld a, [wTempSpecies]
	call GetPokemonIndexFromID
	ld b, h
	ld c, l
	ld hl, EvosAttacksPointers
	ld a, BANK(EvosAttacksPointers)
	call LoadDoubleIndirectPointer
	ldh [hTemp], a ; BANK("Evolutions and Attacks Pointers")
	ld b, a
	call Pokedex_SkipEvolutions ; ripped straight from Vulcandth's, would rather copy than farcall lol
; .CalcPageoffset
	call Pokedex_PrintPageNum ; page num is also returned in a
	ld c, MAX_NUM_MOVES
	call SimpleMultiply 
	; double this num and add to first byte after Evo's 0
	; for p16, triple the num
	ld b, 0
	ld c, a
	; PK16 expanded moves: triple, since each move entry is now 3 bytes instead of 2
	add hl, bc
	add hl, bc
	add hl, bc
	ret

Pokedex_Print_NextLvlMoves:
; Print No more than MAX_NUM_MOVES moves
	ld bc, 0
.learnset_loop
	; ldh a, [hTemp] ; BANK("Evolutions and Attacks Pointers")
	; call GetFarByte ; lvl to learn move, or 0 (delimiter)
	call Pokedex_GetNextEvoAttackByte ; hl now points to second byte of move
	and a
	jr z, .FoundEnd
	push hl ; ; ptr to lvl to learn move, or 0 (delimiter)
	ld [wTextDecimalByte], a
	hlcoord 2, 9
	call DexEntry_adjusthlcoord
	ld [hl], "<DEX_LV>"
	hlcoord 3, 9
	call DexEntry_adjusthlcoord
	ld de, wTextDecimalByte
	push bc ; move counter
	lb bc, PRINTNUM_LEFTALIGN | 1, 2
	call PrintNum
	pop bc ; move counter
	pop hl ; hl now points to second byte of move ; ptr to lvl to learn move, or 0 (delimiter)
	; inc hl ; points to first byte of move
	push hl ; hl now points to second byte of move ; points to first byte of move
	ldh a, [hTemp] ; BANK("Evolutions and Attacks Pointers")
	call GetFarWord
	call GetMoveIDFromIndex
	ld [wNamedObjectIndex], a
	call GetMoveName
	hlcoord 7, 9
	call DexEntry_adjusthlcoord
	push bc ; move counter
	rst PlaceString
	pop bc ; move counter
	pop hl ; points to first byte of move
	inc hl ; points to second byte of move
	inc hl ; points to next move entry's lvl learned
	inc bc ; increment move counter
	ld a, MAX_NUM_MOVES
	cp c
	jr nz, .learnset_loop
.MaxedPage ; Printed MAX_NUM_MOVES moves. Moves are still left. Inc the Page counter
	; check to see if really any moves left, we dont want a blank page
	ldh a, [hTemp] ; BANK("Evolutions and Attacks Pointers")
	call GetFarByte ; lvl to learn move, or 0 (delimiter)
	and a
	jmp nz, DexEntry_IncPageNum
.FoundEnd
	ld a, DEXENTRY_FIELD
	jmp DexEntry_NextCategory

Pokedex_PrintFieldMoves:
; One row for each way the mon gets a field move: by level, then by machine or tutor.
	call Pokedex_StartRows
	ld hl, Field_Moves_List
.loop
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	or e
	jr z, .done
	ld a, [hli]
	push hl
	ld [wPokedexScratch + 2], a ; its TM/HM/tutor flag, or 0
	call Pokedex_LevelUpMoveLevel
	and a
	jr z, .no_level
	ld [wTextDecimalByte], a
	xor a ; by level
	call Pokedex_MoveRow
	cp ROWS_FULL
	jr z, .full
.no_level
	ld a, [wPokedexScratch + 2]
	and a
	jr z, .next
	push de
	call Pokedex_CanLearnMachine
	pop de
	jr z, .next
	ld a, [wPokedexScratch + 2]
	call Pokedex_MoveRow
	cp ROWS_FULL
	jr z, .full
.next
	pop hl
	jr .loop

.full
	pop hl
	jmp DexEntry_IncPageNum

.done
	ld a, DEXENTRY_EGG
	jmp Pokedex_FinishRows

Pokedex_LevelUpMoveLevel:
; in: de = move index
; out: a = the level the mon learns it at, or 0 if it doesn't by level; preserves de
	ld a, [wCurPartySpecies]
	call GetPokemonIndexFromID
	ld b, h
	ld c, l
	ld hl, EvosAttacksPointers
	ld a, BANK(EvosAttacksPointers)
	call LoadDoubleIndirectPointer
	ldh [hTemp], a
	ld b, a
	call Pokedex_SkipEvolutions
.find_move
	call Pokedex_GetNextEvoAttackByte
	and a
	ret z ; end of the learnset
	ld c, a
	ldh a, [hTemp]
	push hl
	call GetFarWord
	ld a, l
	cp e
	jr nz, .next
	ld a, h
	cp d
	jr nz, .next
	pop hl
	ld a, c
	ret

.next
	pop hl
	inc hl
	inc hl
	jr .find_move

Pokedex_Calc_EggMovesPtr:
	ld a, DEXENTRY_EGG
	ld [wPokedexEntryType], a
	call Pokedex_PrintPageNum ; page num is also returned in a
	ld a, [wPokedexEntryPageNum]
	ld c, MAX_NUM_MOVES ; we can print MAX_NUM_MOVES Egg moves per page
	call SimpleMultiply ; double this num and add to first byte after Evo's 0
	ld b, 0
	ld c, a
	push bc ; num of egg moves we've already printed on previous pages

	ld a, [wCurPartySpecies]
	farcall GetLowestEvolutionStage ; uses wCurPartySpecies
	ld a, [wCurPartySpecies]
	farcall GetLowestEvolutionStage ; uses wCurPartySpecies
	ld a, [wCurPartySpecies]
	ld [wTempSpecies], a
	ld [wCurSpecies], a
	ld [wTempMonSpecies], a

	call GetPokemonIndexFromID
	ld b, h
	ld c, l
	ld hl, EggMovePointers
	ld a, BANK(EggMovePointers)	
	call LoadDoubleIndirectPointer
	ldh [hTemp], a ; BANK("Egg Moves")
	push hl
	call GetFarWord ; a will be -1 in both bytes if no egg moves
	ld d, h
	ld e, l
	pop hl
	pop bc ; num of egg moves we've already printed on previous pages
	add hl, bc
	add hl, bc ; add twice since moves are now 2 bytes in PK16 expanded moves
	ld a, d
	cp -1
	ret nz
	ld a, e
	cp -1
	ret nz
	; if we reach here, the mon has no egg moves at all
	; will not call Pokedex_Print_Egg_moves
	; increment to next category
	ld a, DEXENTRY_TMS
	call DexEntry_NextCategory
	;print NONE
	hlcoord 3, 9
	ld de, DexEntry_NONE_text
	jmp PlaceString

Pokedex_Print_Egg_moves:
; Print No more than MAX_NUM_MOVES moves
	ld bc, 0
	; our adjusted pointer based on page num is in hl
.Egg_loop
	ldh a, [hTemp]; BANK("Egg Moves")
	call GetFarByte ; EGG Move, or -1 for end
	cp -1
	jr z, .FoundEnd
	push hl
	ldh a, [hTemp]; BANK("Egg Moves")
	call GetFarWord ; EGG Move, or -1 for end
	call GetMoveIDFromIndex	
	pop hl
	inc hl ; Moves HL to next Byte, 2nd byte of move
	inc hl ; moves to first byte of next move, or -1
	push hl
	ld [wNamedObjectIndex], a ; all the "Name" Funcs use this 
	call GetMoveName ; returns the string pointer in de
	hlcoord 3, 9
	call DexEntry_adjusthlcoord
	push bc
	rst PlaceString ; places Move Name
	pop bc
	pop hl
	ld a, MAX_NUM_MOVES - 1 ; means we just printed last move on page
	cp c
	jr z, .MaxedPage
	inc c
	jr .Egg_loop
.MaxedPage ; Printed MAX_NUM_MOVES moves. Moves are still left. Inc the Page counter
; CheckNextByte, we dont want blank screen if we just printed last move in slot 5
	ldh a, [hTemp]; BANK("Egg Moves")
	call GetFarByte; Move # returned in "a"
	cp -1
	jr z, .FoundEnd
	call DexEntry_IncPageNum
	ld a, [wCurPartySpecies]
	ld [wCurSpecies], a
	ld [wTempSpecies], a
	ld [wTempMonSpecies], a
	ret
.FoundEnd
	ld a, DEXENTRY_TMS
	call DexEntry_NextCategory
	ld a, [wCurPartySpecies]
	ld [wCurSpecies], a
	ld [wTempSpecies], a
	ld [wTempMonSpecies], a
	ret

Pokedex_PrintTMs:
	lb bc, 1, NUM_TMS + NUM_HMS
	call Pokedex_PrintMachineRows
	ret z ; more rows on the next page
	ld a, DEXENTRY_MTS
	jr Pokedex_FinishRows

Pokedex_PrintMTs:
	lb bc, NUM_TMS + NUM_HMS + 1, NUM_TUTORS
	call Pokedex_PrintMachineRows
	ret z ; more rows on the next page
	ld a, DEXENTRY_LVLUP
	; fallthrough

Pokedex_FinishRows:
; Go on to category a on the next A press, and print NONE if this category had no rows.
	call DexEntry_NextCategory
	ld a, [wPokedexScratch + 1]
	and a
	ret nz
	hlcoord 4, 9
	ld de, DexEntry_NONE_text
	jmp PlaceString

Pokedex_PrintMachineRows:
; in: b = first TM/HM/tutor flag, c = how many
; out: z if the page filled up with rows left over
	call Pokedex_StartRows
.loop
	ld a, b
	ld [wPokedexScratch + 2], a
	push bc
	call Pokedex_CanLearnMachine
	jr z, .next
	call Pokedex_MachineMove
	ld a, [wPokedexScratch + 2]
	call Pokedex_MoveRow
	cp ROWS_FULL
	jr z, .full
.next
	pop bc
	inc b
	dec c
	jr nz, .loop
	or 1
	ret

.full
	pop bc
	call DexEntry_IncPageNum
	xor a
	ret

Pokedex_CanLearnMachine:
; in: [wPokedexScratch + 2] = a TM/HM/tutor flag (from 1)
; out: nz if the mon can learn it
	ld a, [wCurPartySpecies]
	ld [wCurSpecies], a
	call GetBaseData
	ld a, [wPokedexScratch + 2]
	dec a
	ld c, a
	rrca
	rrca
	rrca
	and %00011111
	ld e, a
	ld d, 0
	ld hl, wBaseTMHM
	add hl, de
	ld a, c
	and 7
	ld c, a
	ld a, [hl]
	inc c
.shift
	dec c
	jr z, .got_bit
	rrca
	jr .shift

.got_bit
	and 1
	ret

Pokedex_MachineMove:
; in: [wPokedexScratch + 2] = a TM/HM/tutor flag (from 1)
; out: de = the move it teaches
	ld a, [wPokedexScratch + 2]
	dec a
	ld l, a
	ld h, 0
	add hl, hl
	ld de, TMHMMoves
	add hl, de
	ld a, BANK(TMHMMoves)
	call GetFarWord
	ld d, h
	ld e, l
	ret

Pokedex_StartRows:
; Each page of the FIELD, TM and tutor lists shows MAX_NUM_MOVES rows, after the rows of the
; pages before it.
	push bc
	call Pokedex_PrintPageNum ; a = page number
	ld c, MAX_NUM_MOVES
	call SimpleMultiply
	ld [wPokedexScratch], a ; rows to skip
	xor a
	ld [wPokedexScratch + 1], a ; rows printed
	pop bc
	ret

Pokedex_MoveRow:
; Print a row for move de, if it falls on this page.
; in: a = how it's learned: 0 by level (at [wTextDecimalByte]), else its TM/HM/tutor flag
; out: a = ROWS_FULL if this page is already full; preserves de
	ld hl, wPokedexScratch
	ld b, a
	ld a, [hl]
	and a
	jr z, .on_page
	dec [hl] ; an earlier page showed it
	xor a
	ret

.on_page
	inc hl
	ld a, [hl]
	cp MAX_NUM_MOVES
	ld a, ROWS_FULL
	ret z
	ld c, [hl]
	inc [hl]
	push de
	ld a, b
	and a
	jr nz, .machine
; LV n
	hlcoord 2, 9
	call DexEntry_adjusthlcoord
	ld a, "<DEX_LV>"
	ld [hli], a
	push bc
	ld de, wTextDecimalByte
	lb bc, PRINTNUM_LEFTALIGN | 1, 2
	call PrintNum
	pop bc
	jr .name

.machine
	hlcoord 2, 9
	call DexEntry_adjusthlcoord
	ld de, .TM
	cp NUM_TMS + 1
	jr c, .got_kind
	sub NUM_TMS
	ld de, .HM
	cp NUM_HMS + 1
	jr c, .got_kind
	ld de, .MT
	xor a
.got_kind
	ld [wTextDecimalByte], a
	push bc
	push af
	rst PlaceString
	pop af
	and a
	jr z, .no_number
	ld h, b
	ld l, c
	ld de, wTextDecimalByte
	lb bc, PRINTNUM_LEADINGZEROS | 1, 2
	call PrintNum
.no_number
	pop bc
.name
	pop de
	push de
	push bc
	ld h, d
	ld l, e
	call GetMoveIDFromIndex
	ld [wNamedObjectIndex], a
	call GetMoveName
	pop bc
	hlcoord 7, 9
	call DexEntry_adjusthlcoord
	rst PlaceString
	pop de
	ld a, 1
	ret

.TM:
	db "TM@"
.HM:
	db "HM@"
.MT:
	db "MT@"

DexEntry_NONE_text:
	db "NONE@"
