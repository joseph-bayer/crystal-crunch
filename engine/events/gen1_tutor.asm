; The Pewter Museum's Gen 1 tutor, Old Amber Guy: he teaches a Red/Blue or beta form one of the
; Gen 1 TM moves this game has no TM, HM or tutor for, if its species learned that move by TM in
; Red/Blue (Gen1TutorLearnsets). Beta forms, which Red/Blue never had, use a Red/Blue relative's
; list. The script charges GEN1_TUTOR_PRICE once a move is learned.

	assert GEN1_TUTOR_PRICE == 10000, "the tutor's texts say ¥10000"

Gen1Tutor:
; Returns wScriptVar FALSE if a move was learned, TRUE if not.
	ld a, TRUE
	ld [wScriptVar], a
	call FadeToMenu
	call ClearBGPalettes
	call ClearScreen
	call DelayFrame
	ld b, SCGB_PACKPALS
	call GetSGBLayout
	call .ChooseMon
	jmp CloseSubmenu

.ChooseMon:
	farcall LoadPartyMenuGFX
	farcall InitPartyMenuWithCancel
	farcall InitPartyMenuGFX
	ld a, PARTYMENUACTION_GEN1_TUTOR
	ld [wPartyMenuActionText], a
	farcall WritePartyMenuTilemap
	farcall PlacePartyMenuText
	call WaitBGMap
	call SetDefaultBGPAndOBP
	call DelayFrame
	farcall PartyMenuSelect
	ret c

	ld hl, Gen1TutorOnlyRBText
	ld a, [wCurPartySpecies]
	cp EGG
	jr z, .refuse
	ld a, [wCurPartyMon]
	call BuildGen1TutorList
	ld hl, Gen1TutorOnlyRBText
	jr c, .refuse
	call .GetNickname
	ld hl, Gen1TutorKnowsEveryMoveText
	ld a, [wGen1TutorMoveCount]
	and a
	jr z, .refuse

	call ChooseGen1TutorMove
	jr c, .ChooseMon
	ld a, [wMenuSelection]
	call GetGen1TutorMoveID
	ld [wPutativeTMHMMove], a
	ld [wNamedObjectIndex], a
	call GetMoveName
	call CopyName1
	call .GetNickname
	ld hl, Gen1TutorAskText
	call Gen1TutorAsk
	jr c, .ChooseMon

	ld hl, hMoneyTemp ; CompareMoney is in another bank, so the price can't be read from here
	ld a, HIGH(GEN1_TUTOR_PRICE >> 8)
	ld [hli], a
	ld a, HIGH(GEN1_TUTOR_PRICE)
	ld [hli], a
	ld [hl], LOW(GEN1_TUTOR_PRICE)
	ld de, wMoney
	ld bc, hMoneyTemp
	farcall CompareMoney
	jr nc, .teach
	ld hl, Gen1TutorNotEnoughMoneyText
	jmp Gen1TutorPrintText

.teach
	ld hl, Gen1TutorTextboxHeader
	call LoadMenuHeader
	predef LearnMove
	ld a, b
	push af
	call ExitMenu
	pop af
	and a
	jmp z, .ChooseMon
	ld c, HAPPINESS_LEARNMOVE
	farcall ChangeHappiness
	xor a ; FALSE
	ld [wScriptVar], a
	ret

.refuse
	push hl
	ld de, SFX_WRONG
	call PlaySFX
	pop hl
	call Gen1TutorPrintText
	jmp .ChooseMon

.GetNickname:
	ld a, [wCurPartyMon]
	ld hl, wPartyMonNicknames
	jmp GetNickname

ChooseGen1TutorMove:
; Lets the player pick from wGen1TutorMoves. Returns carry if cancelled, else the move's place in
; Gen1TutorMoves in [wMenuSelection].
; InitScrollingMenu draws the list's frame one tile outside its menu box, where the box's own
; backup doesn't reach, so the whole screen is backed up first and brought back afterwards.
	ld hl, .ScreenBackupHeader
	call LoadMenuHeader
	hlcoord 0, 14 ; the party menu's box top, left of the list's frame
	ld bc, 5
	ld a, " "
	rst ByteFill
	hlcoord 0, 15
	lb bc, 1, 18
	call Textbox
	hlcoord 1, 16
	ld de, .WhichMoveString
	rst PlaceString
	ld hl, .MenuHeader
	call LoadMenuHeader
	call InitScrollingMenu
	call UpdateSprites
	xor a
	ld [wMenuScrollPosition], a
	call ScrollingMenu
	call ExitMenu
	call CloseWindow
	ld a, [wMenuJoypad]
	cp PAD_B
	jr z, .cancel
	and a
	ret

.cancel
	scf
	ret

.WhichMoveString:
	db "Teach which move?@"

.ScreenBackupHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1
	dw NULL
	db 1 ; default option

.MenuHeader:
; The frame goes around this, at 5, 0 to 19, 14, just above the one-line prompt box
	db MENU_BACKUP_TILES ; flags
	menu_coords 6, 1, SCREEN_WIDTH - 2, 13
	dw .MenuData
	db 1 ; default option

.MenuData:
	db SCROLLINGMENU_DISPLAY_ARROWS ; flags
	db 6, 0 ; rows, columns
	db SCROLLINGMENU_ITEMS_NORMAL ; item format
	dbw 0, wGen1TutorMoveCount
	dba .PlaceMoveName
	dba NULL
	dba NULL

.PlaceMoveName:
	push de
	ld a, [wMenuSelection]
	call GetGen1TutorMoveID
	ld [wNamedObjectIndex], a
	call GetMoveName
	pop hl
	jmp PlaceString

Gen1TutorAsk:
; Prints the question at hl and asks yes or no. Returns carry for no.
	push hl
	ld hl, Gen1TutorTextboxHeader
	call LoadMenuHeader
	pop hl
	call PrintText
	call YesNoBox
	push af
	call ExitMenu
	pop af
	ret

Gen1TutorPrintText:
	push hl
	ld hl, Gen1TutorTextboxHeader
	call LoadMenuHeader
	pop hl
	call PrintText
	jmp ExitMenu

Gen1TutorTextboxHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 12, SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1
	dw NULL
	db 1 ; default option

CountGen1TutorMoves::
; a = a party slot. Returns a = how many Gen 1 tutor moves it could learn here (0 for any mon
; that isn't a Red/Blue or beta form). Preserves bc, de and hl.
	push hl
	push de
	push bc
	call BuildGen1TutorList
	ld a, [wGen1TutorMoveCount]
	pop bc
	pop de
	pop hl
	ret

BuildGen1TutorList:
; a = a party slot. Lists in wGen1TutorMoves the Gen 1 tutor moves it could learn and doesn't
; know. Returns carry, with the list empty, if it isn't a Red/Blue or beta form.
	ld hl, wPartyMon1
	ld bc, PARTYMON_STRUCT_LENGTH
	rst AddNTimes
	xor a
	ld [wGen1TutorMoveCount], a
	dec a
	ld [wGen1TutorMoves], a
	push hl
	ld bc, MON_FORM
	add hl, bc
	ld c, [hl]
	pop hl
	ld a, [hl] ; MON_SPECIES
	farcall GetRBFormSpecial
	ccf
	ret c

	push hl
	ld a, [hl]
	call GetPokemonIndexFromID
	call .GetLearnsetSpecies
	ld b, h
	ld c, l
	pop hl
	ld de, MON_MOVES
	add hl, de
	ld e, 0
.loop
	farcall CanLearnGen1TutorMove
	jr nc, .next
	call .Knows
	jr c, .next
	push hl
	ld hl, wGen1TutorMoveCount
	inc [hl]
	ld a, [hl]
	add LOW(wGen1TutorMoves - 1)
	ld l, a
	adc HIGH(wGen1TutorMoves - 1)
	sub l
	ld h, a
	ld a, e
	ld [hli], a
	ld [hl], -1
	pop hl
.next
	inc e
	ld a, e
	cp MAX_GEN1_TUTOR_MOVES
	jr c, .loop
	and a
	ret

.Knows:
; Returns carry if the moves at hl include Gen 1 tutor move e. Preserves bc, de and hl.
	push hl
	push de
	push bc
	push hl
	ld a, e
	call GetGen1TutorMoveIndex
	ld d, h
	ld e, l
	pop hl
	ld b, NUM_MOVES
.knows_loop
	ld a, [hli]
	and a
	jr z, .knows_next
	push hl
	call GetMoveIndexFromID
	ld a, l
	cp e
	jr nz, .not_it
	ld a, h
	cp d
	jr nz, .not_it
	pop hl
	scf
	jr .knows_done

.not_it
	pop hl
.knows_next
	dec b
	jr nz, .knows_loop
	and a
.knows_done
	pop bc
	pop de
	pop hl
	ret

.GetLearnsetSpecies:
; hl = a species index. Returns hl = the species whose Red/Blue TM list it uses.
	push de
	push bc
	ld de, Gen1TutorRelatives
.relative_loop
	ld a, [de]
	inc de
	ld c, a
	ld a, [de]
	inc de
	ld b, a
	or c
	jr z, .got_species
	ld a, c
	cp l
	jr nz, .next_relative
	ld a, b
	cp h
	jr nz, .next_relative
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	jr .got_species

.next_relative
	inc de
	inc de
	jr .relative_loop

.got_species
	pop bc
	pop de
	ret

Gen1TutorRelatives:
; Beta forms didn't exist in Red/Blue, so each takes a Red/Blue relative's TM list.
	dw PICHU,     PIKACHU
	dw IGGLYBUFF, JIGGLYPUFF
	dw CROBAT,    GOLBAT
	dw KINGDRA,   SEADRA
	dw 0 ; end

GetGen1TutorMoveIndex:
; a = a place in Gen1TutorMoves. Returns hl = that move's index. Preserves bc and de.
	push de
	ld l, a
	ld h, 0
	add hl, hl
	ld de, Gen1TutorMoves
	add hl, de
	pop de
	ld a, BANK(Gen1TutorMoves)
	jmp GetFarWord

GetGen1TutorMoveID:
; a = a place in Gen1TutorMoves. Returns a = that move's ID.
	call GetGen1TutorMoveIndex
	jmp GetMoveIDFromIndex

CheckPartyForRBAerodactyl:
; wScriptVar: TRUE if an RB Aerodactyl (not an egg) is in the party.
	xor a ; FALSE
	ld [wScriptVar], a
	ld hl, AERODACTYL
	call GetPokemonIDFromIndex
	ld d, a
	ld e, 0
.loop
	ld a, [wPartyCount]
	cp e
	ret z
	ld hl, wPartySpecies
	ld c, e
	ld b, 0
	add hl, bc
	ld a, [hl]
	cp d
	jr nz, .next
	ld hl, wPartyMon1Form
	ld bc, PARTYMON_STRUCT_LENGTH
	ld a, e
	rst AddNTimes
	ld a, [hl]
	and FORM_MASK
	cp AERODACTYL_RB_FORM
	jr nz, .next
	ld a, TRUE
	ld [wScriptVar], a
	ret

.next
	inc e
	jr .loop

Gen1TutorOnlyRBText:
	text "Only RED/BLUE-era"
	line "#MON can learn"
	cont "these moves."
	prompt

Gen1TutorKnowsEveryMoveText:
	text_ram wStringBuffer1
	text " knows"
	line "every move I can"
	cont "teach!"
	prompt

Gen1TutorAskText:
	text "Teach @"
	text_ram wStringBuffer2
	text_start
	line "for ¥10000?"
	done

Gen1TutorNotEnoughMoneyText:
	text "You don't have"
	line "enough money!"
	prompt
