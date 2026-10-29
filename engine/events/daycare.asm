; PrintDayCareText.TextTable indexes
	const_def
	const DAYCARETEXT_MAN_INTRO
	const DAYCARETEXT_MAN_INTRO_EGG
	const DAYCARETEXT_LADY_INTRO
	const DAYCARETEXT_LADY_INTRO_EGG
	const DAYCARETEXT_WHICH_ONE
	const DAYCARETEXT_DEPOSIT
	const DAYCARETEXT_CANT_BREED_EGG
	const DAYCARETEXT_LAST_MON
	const DAYCARETEXT_LAST_ALIVE_MON
	const DAYCARETEXT_COME_BACK_LATER
	const DAYCARETEXT_REMOVE_MAIL
	const DAYCARETEXT_GENIUSES
	const DAYCARETEXT_ASK_WITHDRAW
	const DAYCARETEXT_WITHDRAW
	const DAYCARETEXT_GOT_BACK
	const DAYCARETEXT_TOO_SOON
	const DAYCARETEXT_PARTY_FULL
	const DAYCARETEXT_NOT_ENOUGH_MONEY
	const DAYCARETEXT_OH_FINE
	const DAYCARETEXT_COME_AGAIN

DayCareMan:
	ld hl, wDayCareMan
	bit DAYCAREMAN_HAS_MON_F, [hl]
	jr nz, .AskWithdrawMon
	ld hl, wDayCareMan
	ld a, DAYCARETEXT_MAN_INTRO
	call DayCareManIntroText
	jr c, .cancel
	call DayCareAskDepositPokemon
	jr c, .print_text
	farcall DepositMonWithDayCareMan
	ld hl, wDayCareMan
	set DAYCAREMAN_HAS_MON_F, [hl]
	call DayCare_DepositPokemonText
	jmp DayCare_InitBreeding

.AskWithdrawMon:
	farcall GetBreedMon1LevelGrowth
	ld hl, wBreedMon1Nickname
	call GetPriceToRetrieveBreedmon
	call DayCare_AskWithdrawBreedMon
	jr c, .print_text
	farcall RetrieveMonFromDayCareMan
	call DayCare_GetBackMonForMoney
	ld hl, wDayCareMan
	res DAYCAREMAN_HAS_MON_F, [hl]
	res DAYCAREMAN_MONS_COMPATIBLE_F, [hl]
	jr .cancel

.print_text
	call PrintDayCareText

.cancel
	ld a, DAYCARETEXT_COME_AGAIN
	jmp PrintDayCareText

DayCareLady:
	ld hl, wDayCareLady
	bit DAYCARELADY_HAS_MON_F, [hl]
	jr nz, .AskWithdrawMon
	ld hl, wDayCareLady
	ld a, DAYCARETEXT_LADY_INTRO
	call DayCareLadyIntroText
	jr c, .cancel
	call DayCareAskDepositPokemon
	jr c, .print_text
	farcall DepositMonWithDayCareLady
	ld hl, wDayCareLady
	set DAYCARELADY_HAS_MON_F, [hl]
	call DayCare_DepositPokemonText
	jmp DayCare_InitBreeding

.AskWithdrawMon:
	farcall GetBreedMon2LevelGrowth
	ld hl, wBreedMon2Nickname
	call GetPriceToRetrieveBreedmon
	call DayCare_AskWithdrawBreedMon
	jr c, .print_text
	farcall RetrieveMonFromDayCareLady
	call DayCare_GetBackMonForMoney
	ld hl, wDayCareLady
	res DAYCARELADY_HAS_MON_F, [hl]
	ld hl, wDayCareMan
	res DAYCAREMAN_MONS_COMPATIBLE_F, [hl]
	jr .cancel

.print_text
	call PrintDayCareText

.cancel
	ld a, DAYCARETEXT_COME_AGAIN
	jmp PrintDayCareText

DayCareLadyIntroText:
	bit DAYCARELADY_ACTIVE_F, [hl]
	jr nz, .okay
	set DAYCARELADY_ACTIVE_F, [hl]
	inc a
.okay
	call PrintDayCareText
	jmp YesNoBox

DayCareManIntroText:
	set DAYCAREMAN_ACTIVE_F, [hl]
	call PrintDayCareText
	jmp YesNoBox

DayCareAskDepositPokemon:
	ld a, [wPartyCount]
	cp 2
	jr c, .OnlyOneMon
	ld a, DAYCARETEXT_WHICH_ONE
	call PrintDayCareText
	ld b, PARTYMENUACTION_GIVE_MON
	farcall SelectTradeOrDayCareMon
	jr c, .Declined
	ld a, [wCurPartySpecies]
	cp EGG
	jr z, .Egg
	farcall CheckCurPartyMonFainted
	jr c, .OutOfUsableMons
	ld hl, wPartyMon1Item
	ld bc, PARTYMON_STRUCT_LENGTH
	ld a, [wCurPartyMon]
	rst AddNTimes
	ld d, [hl]
	farcall ItemIsMail
	jr c, .HoldingMail
	ld hl, wPartyMonNicknames
	ld a, [wCurPartyMon]
	call GetNickname
	and a
	ret

.Declined:
	ld a, DAYCARETEXT_OH_FINE
	scf
	ret

.Egg:
	ld a, DAYCARETEXT_CANT_BREED_EGG
	scf
	ret

.OnlyOneMon:
	ld a, DAYCARETEXT_LAST_MON
	scf
	ret

.OutOfUsableMons:
	ld a, DAYCARETEXT_LAST_ALIVE_MON
	scf
	ret

.HoldingMail:
	ld a, DAYCARETEXT_REMOVE_MAIL
	scf
	ret

DayCare_DepositPokemonText:
	ld a, DAYCARETEXT_DEPOSIT
	call PrintDayCareText
	ld a, [wCurPartySpecies]
	call PlayMonCry
	ld a, DAYCARETEXT_COME_BACK_LATER
	jmp PrintDayCareText

DayCare_AskWithdrawBreedMon:
	ld a, [wStringBuffer2 + 1]
	and a
	jr nz, .grew_at_least_one_level
	ld a, DAYCARETEXT_TOO_SOON
	call PrintDayCareText
	call YesNoBox
	jr c, .refused
	jr .check_money

.grew_at_least_one_level
	ld a, DAYCARETEXT_GENIUSES
	call PrintDayCareText
	call YesNoBox
	jr c, .refused
	ld a, DAYCARETEXT_ASK_WITHDRAW
	call PrintDayCareText
	call YesNoBox
	jr c, .refused

.check_money
	ld de, wMoney
	ld bc, wStringBuffer2 + 2
	call CompareMoney
	jr c, .not_enough_money
	ld a, [wPartyCount]
	cp PARTY_LENGTH
	jr nc, .party_full
	and a
	ret

.refused
	ld a, DAYCARETEXT_OH_FINE
	scf
	ret

.not_enough_money
	ld a, DAYCARETEXT_NOT_ENOUGH_MONEY
	scf
	ret

.party_full
	ld a, DAYCARETEXT_PARTY_FULL
	scf
	ret

DayCare_GetBackMonForMoney:
	ld bc, wStringBuffer2 + 2
	ld de, wMoney
	call TakeMoney
	ld a, DAYCARETEXT_WITHDRAW
	call PrintDayCareText
	ld a, [wCurPartySpecies]
	call PlayMonCry
	ld a, DAYCARETEXT_GOT_BACK
	jr PrintDayCareText

GetPriceToRetrieveBreedmon:
	ld a, b
	ld [wStringBuffer2], a
	ld a, d
	ld [wStringBuffer2 + 1], a
	ld de, wStringBuffer1
	ld bc, NAME_LENGTH
	rst CopyBytes
	ld hl, 0
	ld bc, 100
	ld a, [wStringBuffer2 + 1]
	rst AddNTimes
	ld de, 100
	add hl, de
	xor a
	ld [wStringBuffer2 + 2], a
	ld a, h
	ld [wStringBuffer2 + 3], a
	ld a, l
	ld [wStringBuffer2 + 4], a
	ret

PrintDayCareText:
	ld e, a
	ld d, 0
	ld hl, .TextTable
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jmp PrintText

.TextTable:
; entries correspond to DAYCARETEXT_* constants
	dw .DayCareManIntroText ; 00
	dw .DayCareManIntroEggText ; 01
	dw .DayCareLadyIntroText ; 02
	dw .DayCareLadyIntroEggText ; 03
	dw .WhatShouldIRaiseText ; 04
	dw .IllRaiseYourMonText ; 05
	dw .CantAcceptEggText ; 06
	dw .OnlyOneMonText ; 07
	dw .LastHealthyMonText ; 08
	dw .ComeBackLaterText ; 09
	dw .RemoveMailText ; 0a
	dw .AreWeGeniusesText ; 0b
	dw .YourMonHasGrownText ; 0c
	dw .PerfectHeresYourMonText ; 0d
	dw .GotBackMonText ; 0e
	dw .BackAlreadyText ; 0f
	dw .HaveNoRoomText ; 10
	dw .NotEnoughMoneyText ; 11
	dw .OhFineThenText ; 12
	dw .ComeAgainText ; 13

.DayCareManIntroText:
	text_far _DayCareManIntroText
	text_end

.DayCareManIntroEggText:
	text_far _DayCareManIntroEggText
	text_end

.DayCareLadyIntroText:
	text_far _DayCareLadyIntroText
	text_end

.DayCareLadyIntroEggText:
	text_far _DayCareLadyIntroEggText
	text_end

.WhatShouldIRaiseText:
	text_far _WhatShouldIRaiseText
	text_end

.OnlyOneMonText:
	text_far _OnlyOneMonText
	text_end

.CantAcceptEggText:
	text_far _CantAcceptEggText
	text_end

.RemoveMailText:
	text_far _RemoveMailText
	text_end

.LastHealthyMonText:
	text_far _LastHealthyMonText
	text_end

.IllRaiseYourMonText:
	text_far _IllRaiseYourMonText
	text_end

.ComeBackLaterText:
	text_far _ComeBackLaterText
	text_end

.AreWeGeniusesText:
	text_far _AreWeGeniusesText
	text_end

.YourMonHasGrownText:
	text_far _YourMonHasGrownText
	text_end

.PerfectHeresYourMonText:
	text_far _PerfectHeresYourMonText
	text_end

.GotBackMonText:
	text_far _GotBackMonText
	text_end

.BackAlreadyText:
	text_far _BackAlreadyText
	text_end

.HaveNoRoomText:
	text_far _HaveNoRoomText
	text_end

.NotEnoughMoneyText:
	text_far _NotEnoughMoneyText
	text_end

.OhFineThenText:
	text_far _OhFineThenText
	text_end

.ComeAgainText:
	text_far _ComeAgainText
	text_end

DayCareManOutside:
	ld hl, wDayCareMan
	bit DAYCAREMAN_HAS_EGG_F, [hl]
	jr nz, .AskGiveEgg
	ld hl, .NotYetText
	jmp PrintText

.NotYetText:
	text_far _NotYetText
	text_end

.AskGiveEgg:
	ld hl, .FoundAnEggText
	call PrintText
	call YesNoBox
	jr c, .Declined
	ld a, [wPartyCount]
	cp PARTY_LENGTH
	jr nc, .PartyFull
	call DayCare_GiveEgg
	ld hl, wDayCareMan
	res DAYCAREMAN_HAS_EGG_F, [hl]
	call DayCare_InitBreeding
	ld hl, .ReceivedEggText
	call PrintText
	ld de, SFX_GET_EGG
	call PlaySFX
	ld c, 120
	call DelayFrames
	ld hl, .TakeGoodCareOfEggText
	jr .Load0

.Declined:
	ld hl, .IllKeepItThanksText

.Load0:
	call PrintText
	xor a ; FALSE
	ld [wScriptVar], a
	ret

.PartyFull:
	ld hl, .NoRoomForEggText
	call PrintText
	ld a, TRUE
	ld [wScriptVar], a
	ret

.FoundAnEggText:
	text_far _FoundAnEggText
	text_end

.ReceivedEggText:
	text_far _ReceivedEggText
	text_end

.TakeGoodCareOfEggText:
	text_far _TakeGoodCareOfEggText
	text_end

.IllKeepItThanksText:
	text_far _IllKeepItThanksText
	text_end

.NoRoomForEggText:
	text_far _NoRoomForEggText
	text_end

DayCare_GiveEgg:
	ld a, [wEggMonLevel]
	ld [wCurPartyLevel], a
	ld hl, wPartyCount
	ld a, [hl]
	cp PARTY_LENGTH
	jr nc, .PartyFull
	inc a
	ld [hl], a

	ld c, a
	ld b, 0
	add hl, bc
	ld a, EGG
	ld [hli], a
	ld a, [wEggMonSpecies]
	ld [wCurSpecies], a
	ld [wCurPartySpecies], a
	ld [hl], -1

	ld hl, wPartyMonNicknames
	ld bc, MON_NAME_LENGTH
	call DayCare_GetCurrentPartyMember
	ld hl, wEggMonNickname
	rst CopyBytes

	ld hl, wPartyMonOTs
	ld bc, NAME_LENGTH
	call DayCare_GetCurrentPartyMember
	ld hl, wEggMonOT
	rst CopyBytes

	ld hl, wPartyMon1
	ld bc, PARTYMON_STRUCT_LENGTH
	call DayCare_GetCurrentPartyMember
	ld hl, wEggMon
	ld bc, BOXMON_STRUCT_LENGTH
	rst CopyBytes

	call GetBaseData
	ld a, [wPartyCount]
	dec a
	ld hl, wPartyMon1
	ld bc, PARTYMON_STRUCT_LENGTH
	rst AddNTimes
	ld b, h
	ld c, l
	ld hl, MON_OT_ID + 1
	add hl, bc
	push hl
	ld hl, MON_MAXHP
	add hl, bc
	ld d, h
	ld e, l
	pop hl
	push bc
	ld b, FALSE
	predef CalcMonStats
	pop bc
	ld hl, MON_HP
	add hl, bc
	xor a
	ld [hli], a
	ld [hl], a
	and a
	ret

.PartyFull:
	scf
	ret

DayCare_GetCurrentPartyMember:
	ld a, [wPartyCount]
	dec a
	rst AddNTimes
	ld d, h
	ld e, l
	ret

DayCare_InitBreeding:
	ld a, [wDayCareLady]
	bit DAYCARELADY_HAS_MON_F, a
	ret z
	ld a, [wDayCareMan]
	bit DAYCAREMAN_HAS_MON_F, a
	ret z
	call CheckBreedmonCompatibility
	ld a, [wBreedingCompatibility]
	and a
	ret z
	inc a
	ret z
	ld hl, wDayCareMan
	set DAYCAREMAN_MONS_COMPATIBLE_F, [hl]
.loop
	call Random
	cp 150
	jr c, .loop
	ld [wStepsToEgg], a
; fallthrough
.UselessJump:
	xor a
	ld hl, wEggMon
	ld bc, BOXMON_STRUCT_LENGTH
	rst ByteFill
	ld hl, wEggMonNickname
	ld bc, MON_NAME_LENGTH
	rst ByteFill
	ld hl, wEggMonOT
	ld bc, NAME_LENGTH
	rst ByteFill
	ld a, [wBreedMon1DVs]
	ld [wTempMonDVs], a
	ld a, [wBreedMon1DVs + 1]
	ld [wTempMonDVs + 1], a
	ld a, [wBreedMon1Species]
	ld [wCurPartySpecies], a
	ld a, TEMPMON
	ld [wMonType], a
	ld hl, DITTO
	call GetPokemonIDFromIndex
	ld c, a
	ld a, [wBreedMon1Species]
	cp c
	ld a, $1
	jr z, .LoadWhichBreedmonIsTheMother
	ld a, [wBreedMon2Species]
	cp c
	ld a, $0 ; no-optimize a = 0
	jr z, .LoadWhichBreedmonIsTheMother
	farcall GetGender
	ld a, $0 ; no-optimize a = 0
	jr z, .LoadWhichBreedmonIsTheMother
	inc a

.LoadWhichBreedmonIsTheMother:
	ld [wBreedMotherOrNonDitto], a
	and a
	ld a, [wBreedMon1Species]
	jr z, .GotMother
	ld a, [wBreedMon2Species]

.GotMother:
	ld [wCurPartySpecies], a
	farcall GetLowestEvolutionStage
	ld a, EGG_LEVEL
	ld [wCurPartyLevel], a
	call Daycare_CheckAlternateOffspring
	ld [wCurPartySpecies], a
	ld [wCurSpecies], a
	ld [wEggMonSpecies], a

	call GetBaseData
	ld hl, wEggMonNickname
	ld de, .String_EGG
	call CopyName2
	ld hl, wPlayerName
	ld de, wEggMonOT
	ld bc, NAME_LENGTH
	rst CopyBytes
	xor a
	ld [wEggMonItem], a
	ld de, wEggMonMoves
	xor a ; FALSE
	ld [wSkipMovesBeforeLevelUp], a
	predef FillMoves
	call InitEggMoves
	ld hl, wEggMonID
	ld a, [wPlayerID]
	ld [hli], a
	ld a, [wPlayerID + 1]
	ld [hl], a
	ld a, [wCurPartyLevel]
	ld d, a
	farcall CalcExpAtLevel
	ld hl, wEggMonExp
	ldh a, [hMultiplicand]
	ld [hli], a
	ldh a, [hMultiplicand + 1]
	ld [hli], a
	ldh a, [hMultiplicand + 2]
	ld [hl], a
	xor a
	ld b, wEggMonDVs - wEggMonEVs
	ld hl, wEggMonEVs
.loop2
	ld [hli], a
	dec b
	jr nz, .loop2
	ld hl, DITTO
	call GetPokemonIDFromIndex
	ld b, a
	ld hl, wEggMonDVs
	call Random
	ld [hli], a
	ld [wTempMonDVs], a
	call Random
	ld [hld], a
	ld [wTempMonDVs + 1], a
	ld de, wBreedMon1DVs
	ld a, [wBreedMon1Species]
	cp b
	jr z, .GotDVs
	ld de, wBreedMon2DVs
	ld a, [wBreedMon2Species]
	cp b
	jr z, .GotDVs
	ld a, TEMPMON
	ld [wMonType], a
	push hl
	farcall GetGender
	pop hl
	ld de, wBreedMon1DVs
	ld bc, wBreedMon2DVs
	jr c, .SkipDVs
	jr z, .ParentCheck2
	ld a, [wBreedMotherOrNonDitto]
	and a
	jr z, .GotDVs
	ld d, b
	ld e, c
	jr .GotDVs

.ParentCheck2:
	ld a, [wBreedMotherOrNonDitto]
	and a
	jr nz, .GotDVs
	ld d, b
	ld e, c

.GotDVs:
	ld a, [de]
	inc de
	and $f
	ld b, a
	ld a, [hl]
	and $f0
	add b
	ld [hli], a
	ld a, [de]
	and $7
	ld b, a
	ld a, [hl]
	and $f8
	add b
	ld [hl], a

.SkipDVs:
	ld hl, wStringBuffer1
	ld de, wMonOrItemNameBuffer
	ld bc, NAME_LENGTH
	rst CopyBytes
	ld hl, wEggMonMoves
	ld de, wEggMonPP
	predef FillPP
	ld hl, wMonOrItemNameBuffer
	ld de, wStringBuffer1
	ld bc, NAME_LENGTH
	rst CopyBytes
	ld a, [wBaseEggSteps]
	ld hl, wEggMonHappiness
	ld [hli], a
	xor a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld a, [wCurPartyLevel]
	ld [wEggMonLevel], a

; Species-specific form inheritance
	call CheckMultiFormEggInheritance
	jr nc, .Smeargle ; Not a multi-form Pokémon, continue to Smeargle

.Smeargle
; Check if egg is Smeargle
	ld a, [wEggMonSpecies]
	call GetPokemonIndexFromID
	ld a, l
	sub LOW(SMEARGLE)
	if HIGH(SMEARGLE) == 0
		or h
	else
		jr nz, .Shininess
		if HIGH(SMEARGLE) == 1
			dec h
		else
			ld a, h
			cp HIGH(SMEARGLE)
		endc
	endc
	jp nz, .Shininess
; Baby is a Smeargle!

; We will set b to 0 if parent 1 is Smeargle.
; We will set c to 0 if parent 2 is Smeargle.
.smeargle_check_parent_1
	ld a, [wBreedMon1Species]
	call GetPokemonIndexFromID
	ld a, l
	sub LOW(SMEARGLE)
	if HIGH(SMEARGLE) == 0
		or h
	else
		ld b, a
		jr nz, .smeargle_check_parent_2
		if HIGH(SMEARGLE) == 1
			dec h
		else
			ld a, h
			cp HIGH(SMEARGLE)
		endc
	endc
	ld b, a
	; fallthrough

.smeargle_check_parent_2
	ld a, [wBreedMon2Species]
	call GetPokemonIndexFromID
	ld a, l
	sub LOW(SMEARGLE)
	if HIGH(SMEARGLE) == 0
		or h
	else
		ld c, a
		jr nz, .determine_smeargle_form_passing_function
		if HIGH(SMEARGLE) == 1
			dec h
		else
			ld a, h
			cp HIGH(SMEARGLE)
		endc
	endc
	ld c, a
	; fallthrough

.determine_smeargle_form_passing_function
	ld a, b
	or c
	jr z, .both_parents_smeargle
	; only one parent is Smeargle
	ld a, b
	or a
	jr z, .only_parent_1_smeargle
	jr .only_parent_2_smeargle

.both_parents_smeargle
; We will set b to 0 if parent 1 is a primary color form. Otherwise 1.
; We will set c to 0 if parent 2 is a primary color form. Otherwise 1.
; Primary color Smeargles are 0 (Red), 1 (Blue), and 2 (Yellow)

; check parent 1 primary color
	xor a
	ld b, a
	ld a, [wBreedMon1Form]
	and FORM_MASK
	cp 3
	jr c, .check_parent_2_primary_color
	; not primary color
	or 1 ; set a to 1
	ld b, a
.check_parent_2_primary_color
	xor a
	ld c, a
	ld a, [wBreedMon2Form]
	and FORM_MASK
	cp 3
	jr c, .determine_primary_color_function
	; not primary color
	or 1 ; set a to 1
	ld c, a

.determine_primary_color_function
; b = 0 if parent 1 is primary color, else 1
; c = 0 if parent 2 is primary color, else 1
	ld a, b
	or c
	jr z, .both_parents_primary_color
	; only one parent is primary color
	ld a, b
	or a
	jr z, .only_parent_1_primary_color
	ld a, c
	or a
	jr z, .only_parent_2_primary_color
	; fallthrough

.neither_parent_primary_color
	; neither parent is primary color, so flip a coin for which parent passes its form
	ld a, [wBreedMon1Form]
	and FORM_MASK
	ld [wEggMonForm], a
	ld [wTempMonForm], a
	call Random
	cp 128
	jr c, .Shininess
	ld a, [wBreedMon2Form]
	and FORM_MASK
	ld [wEggMonForm], a
	ld [wTempMonForm], a
	jr .Shininess

.only_parent_1_smeargle
	; Pass form without any special logic
	ld a, [wBreedMon1Form]
	and FORM_MASK
	ld [wEggMonForm], a
	ld [wTempMonForm], a
	jr .Shininess
.only_parent_2_smeargle
	ld a, [wBreedMon2Form]
	and FORM_MASK
	ld [wEggMonForm], a
	ld [wTempMonForm], a
	jr .Shininess

.both_parents_primary_color
	; Both parents are primary colors. We need to verify that they are different colors.
	ld a, [wBreedMon1Form]
	and FORM_MASK
	ld b, a
	ld a, [wBreedMon2Form]
	and FORM_MASK
	cp b
	ld [wEggMonForm], a
	ld [wTempMonForm], a
	jr z, .Shininess ; same color, so just pass that color
	; Both parents are primary colors and different colors, so let's mix them to produce secondary colors!
	; Primary colors form values are 0 (Red), 1 (Blue), and 2 (Yellow)
	; Adding these colors' form values together give us unique results in all combinations:
	; Red + Blue = 0 + 1 = 1 (Purple)
	; Red + Yellow = 0 + 2 = 2 (Orange)
	; Blue + Yellow = 1 + 2 = 3 (Green)
	; So if the result is 1, we'll assign form 3 (Purple)
	; If the result is 2, we'll assign form 4 (Orange)
	; If the result is 3, we'll assign form 5 (Green)
	add b
	ld b, a
	dec a ; 1
	ld a, SMEARGLE_PURPLE_FORM
	ld [wEggMonForm], a
	ld [wTempMonForm], a
	jr z, .Shininess
	ld a, b
	cp 2
	ld a, SMEARGLE_ORANGE_FORM
	ld [wEggMonForm], a
	ld [wTempMonForm], a
	jr z, .Shininess
	; must be 3
	ld a, SMEARGLE_GREEN_FORM
	ld [wEggMonForm], a
	ld [wTempMonForm], a
	jr .Shininess

.only_parent_1_primary_color
	; if parent 1 is primary color, that means parent 2 is a secondary color
	; secondary colors take precedence over primary colors
	ld a, [wBreedMon2Form]
	jr .done_smeargle_inheritance
.only_parent_2_primary_color
	; if parent 2 is primary color, that means parent 1 is a secondary color
	; secondary colors take precedence over primary colors
	ld a, [wBreedMon1Form]
	; fallthrough

.done_smeargle_inheritance
	and FORM_MASK
	ld [wEggMonForm], a
	ld [wTempMonForm], a
	; fallthrough

.Shininess:
	; Check if both parents are shiny
	ld a, [wBreedMon1Form]
	and SHINY_MASK
	ld b, a
	ld a, [wBreedMon2Form]
	and SHINY_MASK
	or b
	jr z, .no_shiny_parent ; Neither parent is shiny
	
	; At least one parent is shiny
	ld a, [wBreedMon1Form]
	and SHINY_MASK
	ld b, a
	ld a, [wBreedMon2Form]
	and SHINY_MASK
	and b
	jr z, .one_parent_shiny ; Only one parent is shiny
	
	; Both parents are shiny
	call Random
	cp SHINY_EGG_TWO_SHINY_PARENTS_NUMERATOR ; 8/256 = 1/32 chance
	ret nc
	ld a, [wEggMonForm]
	or SHINY_MASK
	call RollAltShiny
	ld [wEggMonForm], a
	ld [wTempMonForm], a
	ret
	
.one_parent_shiny:
	; One parent is shiny - higher chance for shiny offspring
	call Random
	cp SHINY_EGG_ONE_SHINY_PARENT_NUMERATOR ; 4/256 = 1/64 chance
	ret nc
	ld a, [wEggMonForm]
	or SHINY_MASK
	call RollAltShiny
	ld [wEggMonForm], a
	ld [wTempMonForm], a
	ret
	
.no_shiny_parent:
	call Random
	and a 
	ret nz ; 255/256 chance of not being shiny
	call Random
	cp SHINY_EGG_NUMERATOR ; 240/256 chance of not being shiny
	ret nc
	ld a, [wEggMonForm]
	or SHINY_MASK
	call RollAltShiny
	ld [wEggMonForm], a
	ld [wTempMonForm], a
	ret

.String_EGG:
	db "EGG@"

Daycare_CheckAlternateOffspring:
	; returns [wCurPartySpecies] in a, unless that species may give birth to an alternate species (e.g., gender variant)
	; if an alternate species is possible, it returns it 50% of the time
	call Random
	add a
	ld a, [wCurPartySpecies]
	ret nc
	push hl
	push de
	push bc
	call GetPokemonIndexFromID
	ld b, h
	ld c, l
	ld de, 4
	ld hl, .alternate_offspring_table
	call IsInWordArray
	pop bc
	pop de
	ld a, [wCurPartySpecies]
	jr nc, .done
	inc hl
	inc hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call GetPokemonIDFromIndex
.done
	pop hl
	ret

.alternate_offspring_table
	dw NIDORAN_F, NIDORAN_M
	dw -1

; Check if egg species requires special form inheritance (Scyther/Pinsir)
; Input: wEggMonSpecies set
; Output: carry = found and handled, no carry = not found
; Clobbers: a, bc, de, hl
CheckMultiFormEggInheritance:
	ld a, [wEggMonSpecies]
	call GetPokemonIndexFromID
	; hl = pokemon index
	
	; Check table for matching species
	ld de, MultiFormEggTable
.loop:
	ld a, [de] ; Load low byte of species ID
	inc de
	ld c, a
	ld a, [de] ; Load high byte of species ID
	inc de
	ld b, a
	; Check for end marker
	or c ; TODO: will the low byte ever be 0 for a valid species?
	jr z, .not_found
	
	; Compare bc (table entry) with hl (egg species)
	ld a, c
	cp l
	jr nz, .next_entry
	ld a, b
	cp h
	jr nz, .next_entry
	
	; Found match! Now handle form inheritance
	call HandleSimpleFormInheritance
	scf ; Set carry to indicate we handled it
	ret

.next_entry:
	inc de ; past the row's form
	jr .loop

.not_found:
	and a ; Clear carry to indicate not found
	ret

; Handle simple form inheritance for the species in MultiFormEggTable
; If both parents are the species: 50% chance to inherit from each parent
; If only one parent is the species: inherit its form
; The inherited form is kept only if the species' row lets it pass (see MultiFormEggTable)
HandleSimpleFormInheritance:
	; First check if both parents are the same species as the egg
	ld a, [wEggMonSpecies]
	call GetPokemonIndexFromID
	ld b, h
	ld c, l ; bc = egg species index
	
	; Check parent 1 - convert to lowest evolution stage first
	ld a, [wBreedMon1Species]
	ld [wCurPartySpecies], a
	push bc
	farcall GetLowestEvolutionStage
	pop bc
	call GetPokemonIndexFromID
	ld a, l
	cp c
	jr nz, .check_parent2_only
	ld a, h
	cp b
	jr nz, .check_parent2_only
	
	; Parent 1 matches, check parent 2 - convert to lowest evolution stage first
	ld a, [wBreedMon2Species]
	ld [wCurPartySpecies], a
	push bc
	farcall GetLowestEvolutionStage
	pop bc
	call GetPokemonIndexFromID
	ld a, l
	cp c
	jr nz, .inherit_parent1
	ld a, h
	cp b
	jr nz, .inherit_parent1
	
	; Both parents match - 50% chance for each
	call Random
	cp 128
	jr c, .inherit_parent1
	jr .inherit_parent2

.check_parent2_only:
	; Check if parent 2 matches - convert to lowest evolution stage first
	ld a, [wBreedMon2Species]
	ld [wCurPartySpecies], a
	push bc
	farcall GetLowestEvolutionStage
	pop bc
	call GetPokemonIndexFromID
	ld a, l
	cp c
	ret nz
	ld a, h
	cp b
	ret nz
	jr .inherit_parent2

	; Only parent 1 matches
.inherit_parent1:
	ld a, [wBreedMon1Form]
	jr .done

.inherit_parent2:
	ld a, [wBreedMon2Form]
	; fallthrough
.done
	and FORM_MASK
; Only the form the species' row names passes (ALL_FORMS: any). Anything else -- a Rocket form, a
; Surfing or Flying Pikachu, an XS or XL Magikarp -- hatches plain.
	ld e, a
	call GetEggFormFilter
	cp ALL_FORMS
	jr z, .got_form
	cp e
	jr z, .got_form
	ld e, PLAIN_FORM
.got_form
	ld a, e
	ld [wTempMonForm], a
	ld [wEggMonForm], a
	ret

GetEggFormFilter:
; in: bc = egg species index, which has a row in MultiFormEggTable
; out: a = the form that row lets pass
	ld hl, MultiFormEggTable
.loop
	ld a, [hli]
	cp c
	jr nz, .skip_high
	ld a, [hli]
	cp b
	jr nz, .skip_form
	ld a, [hl]
	ret

.skip_high
	inc hl
.skip_form
	inc hl
	jr .loop

; Pokémon whose egg can take a parent's form, and which form passes. A parent's form passes when
; it is that species' line (its lowest evolution is the egg's species), and its form is the one
; named here, or any with ALL_FORMS. Each RB line's forms are numbered in parallel for evolution,
; so one number covers the whole line: beta Kingdra, RB Seadra and RB Horsea are all 1.
; Format: species_id (word), form (byte)
MultiFormEggTable:
	dwb SCYTHER,    ALL_FORMS
	dwb PINSIR,     ALL_FORMS
	dwb PICHU,      PICHU_BETA_FORM      ; from RB Pikachu or Raichu; not Surfing or Flying
	dwb IGGLYBUFF,  IGGLYBUFF_BETA_FORM  ; from RB Jigglypuff or Wigglytuff
	dwb MACHOP,     MACHOP_RB_FORM
	dwb TENTACOOL,  TENTACOOL_RB_FORM
	dwb NIDORAN_M,  NIDORAN_M_RB_FORM
	dwb NIDORAN_F,  NIDORAN_F_RB_FORM    ; Nidorina and Nidoqueen can't breed
	dwb ZUBAT,      ZUBAT_RB_FORM        ; from RB Zubat or Golbat, or beta Crobat; not Rocket
	dwb GEODUDE,    GEODUDE_RB_FORM
	dwb SHELLDER,   SHELLDER_RB_FORM
	dwb GASTLY,     GASTLY_RB_FORM
	dwb KOFFING,    KOFFING_RB_FORM      ; from RB Koffing or Weezing; not Rocket
	dwb HORSEA,     HORSEA_RB_FORM       ; from RB Horsea or Seadra, or beta Kingdra
	dwb PSYDUCK,    PSYDUCK_RB_FORM
	dwb MAGIKARP,   MAGIKARP_RB_FORM     ; not XS or XL: those come from size at hatch
	dwb STARYU,     STARYU_RB_FORM
	dw $0000 ; end marker
