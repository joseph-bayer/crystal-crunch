; The contact list is a flag array with one bit per contact (from Polished Crystal).

PhoneFlagAction:
; Perform flag action b on contact c. Contacts start at 1; the flag array starts at bit 0.
	push bc
	dec c
	ld d, 0
	ld hl, wPhoneList
	farcall SmallFarFlagAction
	pop bc
	ret

AddPhoneNumber::
; Adds contact c to the contact list. Returns carry if it's already there.
	call CheckCellNum
	ret c
	ld b, SET_FLAG
	jr DoAddOrDelPhoneNumber

DelCellNum::
; Deletes contact c from the contact list. Returns carry if it isn't there.
	call CheckCellNum
	ccf
	ret c
	ld b, RESET_FLAG
	; fallthrough
DoAddOrDelPhoneNumber:
	call PhoneFlagAction
	xor a
	ret

CheckCellNum::
; Returns carry (and nz) if contact c is in the contact list.
	ld b, CHECK_FLAG
	call PhoneFlagAction
	scf
	ret nz
	xor a
	ret

CheckPhoneCall::
; Check if the phone is ringing in the overworld.

	call CheckStandingOnEntrance
	jr z, .no_call

	call .timecheck
	jr nc, .no_call

	; 50% chance for a call
	call Random
	ld b, a
	and %01111111
	cp b
	jr nz, .no_call

	call GetMapPhoneService
	and a
	jr nz, .no_call

	call ChooseRandomCaller
	jr nc, .no_call

	ld e, a
	call LoadCallerScript
	ld a, BANK(Script_ReceivePhoneCall)
	ld hl, Script_ReceivePhoneCall
	call CallScript
	scf
	ret

.no_call
	xor a
	ret

.timecheck
	farjp CheckReceiveCallTimer

CheckPhoneContactTimeOfDay:
	push hl
	push bc
	push de
	push af

	farcall CheckTime
	pop af
	and ANYTIME
	and c

	pop de
	pop bc
	pop hl
	ret

ChooseRandomCaller:
; Returns a random available caller in a, with carry. Returns nc if nobody can call.
; Every eligible contact is equally likely (reservoir sampling, from Polished Crystal).
	farcall CheckTime
	ld d, c
	xor a
	ld b, a ; eligible contacts seen so far
	ld c, NUM_PHONE_CONTACTS ; also the last contact
	push af
.loop
	call .IsValidCaller
	jr nc, .next
	inc b
	; Replace the current pick with this contact with chance 1/b.
	ld a, b
	call RandomRange
	and a
	jr nz, .next
	pop af
	ld a, c
	scf
	push af
.next
	dec c
	jr nz, .loop
	pop af
	ret

.IsValidCaller:
; Returns carry if contact c is registered, calls at time of day d, and isn't on this map.
	push bc
	push de
	call CheckCellNum
	pop de
	jr nc, .invalid
	ld a, c
	ld hl, PhoneContacts + PHONE_CONTACT_SCRIPT2_TIME
	ld bc, PHONE_CONTACT_SIZE
	rst AddNTimes
	ld a, d
	and [hl]
	jr z, .invalid
	ld bc, PHONE_CONTACT_MAP_GROUP - PHONE_CONTACT_SCRIPT2_TIME
	add hl, bc
	ld a, [wMapGroup]
	cp [hl]
	jr nz, .other_map
	inc hl
	ld a, [wMapNumber]
	cp [hl]
	jr z, .invalid
.other_map
	; Contacts with a rematch or item waiting don't call.
	pop bc
	push bc
	push de
	call PhoneContactIsWaiting
	pop de
	jr c, .invalid
	; Contacts who only ever chat are eligible half the time.
	pop bc
	push bc
	ld a, c
	cp PHONE_JUGGLER_IRWIN
	jr z, .half_weight
	cp PHONE_BLACKBELT_KENJI
	jr z, .half_weight
	cp PHONE_BUENA
	jr nz, .valid
.half_weight
	call Random
	rrca
	jr nc, .invalid
.valid
	scf
	jr .done

.invalid
	xor a
.done
	pop bc
	ret

PhoneContactIsWaiting:
; Returns carry if contact c has a rematch or an item waiting.
	ld a, c
	ld hl, PhoneContactWaitingFlags
	ld bc, 4
	rst AddNTimes
	call .CheckFlag
	ret c
	; fallthrough
.CheckFlag:
; Checks the engine flag at hl (-1 = none) and advances hl. Returns carry if it's set.
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	cp HIGH(-1)
	ret z ; and nc
	push hl
	ld b, CHECK_FLAG
	farcall EngineFlagAction
	pop hl
	ld a, c
	and a
	ret z
	scf
	ret

INCLUDE "data/phone/waiting_flags.asm"

CheckSpecialPhoneCall::
	ld a, [wSpecialPhoneCallID]
	and a
	jr z, .NoPhoneCall

	dec a
	ld c, a
	ld b, 0
	ld hl, SpecialPhoneCallList
	ld a, SPECIALCALL_SIZE
	rst AddNTimes
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call _hl_
	jr nc, .NoPhoneCall

	call .DoSpecialPhoneCall
	inc hl
	inc hl
	ld a, [hli]
	ld e, a
	push hl
	call LoadCallerScript
	pop hl
	ld de, wCallerContact + PHONE_CONTACT_SCRIPT2_BANK
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ld a, BANK(.script)
	ld hl, .script
	call CallScript
	scf
	ret
.NoPhoneCall:
	xor a
	ret

.script
	pause 30
	sjump Script_ReceivePhoneCall

.DoSpecialPhoneCall:
	ld a, [wSpecialPhoneCallID]
	dec a
	ld c, a
	ld b, 0
	ld hl, SpecialPhoneCallList
	ld a, SPECIALCALL_SIZE
	jmp AddNTimes

SpecialCallOnlyWhenOutside:
	ld a, [wEnvironment]
	cp TOWN
	jr z, .outside
	cp ROUTE
	jr z, .outside
	xor a
	ret

.outside
	scf
	ret

SpecialCallWhereverYouAre:
	scf
	ret

MakePhoneCallFromPokegear:
	; Don't do the call if you're in a link communication
	ld a, [wLinkMode]
	and a
	jr nz, .OutOfArea
	; If you're in an area without phone service, don't do the call
	call GetMapPhoneService
	and a
	jr nz, .OutOfArea
	; If the person can't take a call at that time, don't do the call
	ld a, b
	ld [wCurCaller], a
	ld hl, PhoneContacts
	ld bc, PHONE_CONTACT_SIZE
	rst AddNTimes
	ld d, h
	ld e, l
	ld hl, PHONE_CONTACT_SCRIPT1_TIME
	add hl, de
	ld a, [hl]
	call CheckPhoneContactTimeOfDay
	jr z, .OutOfArea
	; If we're in the same map as the person we're calling,
	; use the "Just talk to that person" script.
	ld hl, PHONE_CONTACT_MAP_GROUP
	add hl, de
	ld a, [wMapGroup]
	cp [hl]
	jr nz, .GetPhoneScript
	ld hl, PHONE_CONTACT_MAP_NUMBER
	add hl, de
	ld a, [wMapNumber]
	cp [hl]
	jr nz, .GetPhoneScript
	ld b, BANK(PhoneScript_JustTalkToThem)
	ld hl, PhoneScript_JustTalkToThem
	jr .DoPhoneCall

.GetPhoneScript:
	ld hl, PHONE_CONTACT_SCRIPT1_BANK
	add hl, de
	ld b, [hl]
	ld hl, PHONE_CONTACT_SCRIPT1_ADDR
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jr .DoPhoneCall

.OutOfArea:
	ld b, BANK(LoadOutOfAreaScript)
	ld de, LoadOutOfAreaScript
	jmp ExecuteCallbackScript

.DoPhoneCall:
	ld a, b
	ld [wPhoneScriptBank], a
	ld a, l
	ld [wPhoneCaller], a
	ld a, h
	ld [wPhoneCaller + 1], a
	ld b, BANK(LoadPhoneScriptBank)
	ld de, LoadPhoneScriptBank
	jmp ExecuteCallbackScript

LoadPhoneScriptBank:
	memcall wPhoneScriptBank
	endcallback

LoadOutOfAreaScript:
	scall PhoneOutOfAreaScript
	endcallback

LoadCallerScript:
	ld a, e
	ld [wCurCaller], a
	and a
	jr nz, .actualcaller
	ld a, BANK(WrongNumber)
	ld hl, WrongNumber
	jr .proceed

.actualcaller
	ld hl, PhoneContacts
	ld bc, PHONE_CONTACT_SIZE
	ld a, e
	rst AddNTimes
	ld a, BANK(PhoneContacts)
.proceed
	ld de, wCallerContact
	ld bc, PHONE_CONTACT_SIZE
	jmp FarCopyBytes

WrongNumber:
	db TRAINER_NONE, PHONE_00
	dba .script
.script
	writetext .PhoneWrongNumberText
	end
.PhoneWrongNumberText:
	text_far _PhoneWrongNumberText
	text_end

; Incoming calls can be answered or declined (from Sour Crystal).
; wScriptVar after RingTwice_StartCall:
	const_def
	const CALL_DECLINED ; B, or no answer before the rings run out
	const CALL_ANSWERED ; A, or a caller who can't be declined

DEF NUM_DECLINABLE_CALL_RINGS EQU 10

Script_ReceivePhoneCall::
	reanchormap
	setval CALL_DECLINED
	callasm RingTwice_StartCall
	ifequal CALL_DECLINED, .declined
	memcall wCallerContact + PHONE_CONTACT_SCRIPT2_BANK
	waitbutton
	callasm HangUp
	closetext
	callasm InitCallReceiveDelay
	end

.declined
	callasm HangUp_ShutDown
	closetext
	callasm InitCallReceiveDelay
	end

Script_SpecialBillCall::
	callasm .LoadBillScript
	sjump Script_ReceivePhoneCall

.LoadBillScript:
	ld e, PHONE_BILL
	jr LoadCallerScript

RingTwice_StartCall:
	call .IsForcedCaller
	jr nc, .declinable
	ld a, CALL_ANSWERED
	ld [wScriptVar], a
	call .Ring
	jr .Ring

.declinable
; Ring until the player answers or declines, or the rings run out.
	call Phone_StartRinging
	ld c, 30
	call DelayFrames
	ld c, NUM_DECLINABLE_CALL_RINGS
.ring_loop
	push bc
	call .CallerTextboxWithName
	call Phone_AnswerDeclinePrompt
	call .WaitForAnswer
	jr c, .answered_or_declined
	call Phone_StartRinging
	call .WaitForAnswer
	jr c, .answered_or_declined
	pop bc
	dec c
	jr nz, .ring_loop
	jr .done

.answered_or_declined
	pop bc
.done
	call .CallerTextboxWithName
	jmp WaitSFX

.WaitForAnswer:
; Wait about half a second for A (answer) or B (decline). Returns carry once one is pressed.
	farcall PhoneRing_CopyTilemapAtOnce
	ld c, 30
.wait_loop
	call DelayFrame
	push bc
	call JoyTextDelay
	ldh a, [hJoyPressed]
	ld b, a
	and PAD_B
	jr nz, .declined
	ld a, b
	and PAD_A
	jr nz, .answered
	pop bc
	dec c
	ret z
	jr .wait_loop

.answered
	pop bc
	ld a, CALL_ANSWERED
	ld [wScriptVar], a
	scf
	ret

.declined
	pop bc
	ld a, CALL_DECLINED
	ld [wScriptVar], a
	scf
	ret

.IsForcedCaller:
; Returns carry if the current caller can't be declined.
	ld a, [wCurCaller]
	ld hl, .ForcedCallers
.forced_loop
	cp [hl]
	jr z, .forced
	inc hl
	inc [hl]
	dec [hl]
	jr nz, .forced_loop
	and a
	ret

.forced
	scf
	ret

.ForcedCallers:
	db PHONE_MOM
	db PHONE_OAK ; the Bike Shop
	db PHONE_BILL
	db PHONE_ELM
	db PHONE_LANCE ; the Open League call
	db 0 ; end

.Ring:
	call Phone_StartRinging
	call Phone_Wait20Frames
	call .CallerTextboxWithName
	call Phone_Wait20Frames
	call Phone_CallerTextbox
	call Phone_Wait20Frames
; fallthrough
.CallerTextboxWithName:
	ld a, [wCurCaller]
	ld b, a
	jmp Phone_TextboxWithName

Phone_AnswerDeclinePrompt:
; A one-line box at the bottom of the screen, with any sprites under it hidden.
	hlcoord 0, SCREEN_HEIGHT - 3
	lb bc, 1, SCREEN_WIDTH - 2
	call Textbox
	hlcoord 1, SCREEN_HEIGHT - 2
	ld de, .AnswerDeclineText
	rst PlaceString
	ld hl, wShadowOAM
	ld de, OBJ_SIZE
	ld c, OAM_COUNT
.loop
	ld a, [hl]
	cp (SCREEN_HEIGHT - 3) * TILE_WIDTH
	jr c, .next
	ld [hl], OAM_YCOORD_HIDDEN
.next
	add hl, de
	dec c
	jr nz, .loop
	ldh a, [hOAMUpdate]
	push af
	ld a, TRUE
	ldh [hOAMUpdate], a
	call DelayFrame
	pop af
	ldh [hOAMUpdate], a
	ret

.AnswerDeclineText:
	db "A:ANSWER B:DECLINE@"

PhoneCall::
	ld a, b
	ld [wPhoneScriptBank], a
	ld a, e
	ld [wPhoneCaller], a
	ld a, d
	ld [wPhoneCaller + 1], a
	call .Ring
	; fallthrough

.Ring:
	call Phone_StartRinging
	call Phone_Wait20Frames
	call .CallerTextboxWithName
	call Phone_Wait20Frames
	call Phone_CallerTextbox
	call Phone_Wait20Frames
; fallthrough
.CallerTextboxWithName:
	call Phone_CallerTextbox
	hlcoord 1, 2
	ld a, "☎"
	ld [hli], a
	inc hl
	ld a, [wPhoneCaller]
	ld e, a
	ld a, [wPhoneCaller + 1]
	ld d, a
	ld a, [wPhoneScriptBank]
	jmp FarPlaceString

Phone_NoSignal:
	ld de, SFX_NO_SIGNAL
	call PlaySFX
	jr Phone_CallEnd

HangUp::
	call HangUp_Beep
	call HangUp_Wait20Frames
Phone_CallEnd:
	call HangUp_BoopOn
	call HangUp_Wait20Frames
	call HangUp_BoopOff
	call HangUp_Wait20Frames
	call HangUp_BoopOn
	call HangUp_Wait20Frames
	call HangUp_BoopOff
	call HangUp_Wait20Frames
	call HangUp_BoopOn
	call HangUp_Wait20Frames
	call HangUp_BoopOff
	jr HangUp_Wait20Frames

HangUp_ShutDown:
	ld de, SFX_SHUT_DOWN_PC
	jmp PlaySFX

HangUp_Beep:
	ld hl, PhoneClickText
	call PrintText
	ld de, SFX_HANG_UP
	jmp PlaySFX

PhoneClickText:
	text_far _PhoneClickText
	text_end

HangUp_BoopOn:
	ld hl, PhoneEllipseText
	jmp PrintText

PhoneEllipseText:
	text_far _PhoneEllipseText
	text_end

HangUp_BoopOff:
	jmp SpeechTextbox

Phone_StartRinging:
	call WaitSFX
	ld de, SFX_CALL
	call PlaySFX
	call Phone_CallerTextbox
	call UpdateSprites
	farjp PhoneRing_CopyTilemapAtOnce

HangUp_Wait20Frames:
; fallthrough
Phone_Wait20Frames:
	ld c, 20
	call DelayFrames
	farjp PhoneRing_CopyTilemapAtOnce

Phone_TextboxWithName:
	push bc
	call Phone_CallerTextbox
	hlcoord 1, 1
	ld a, "☎"
	ld [hli], a
	inc hl
	ld d, h
	ld e, l
	pop bc
	jr GetCallerClassAndName

Phone_CallerTextbox:
	hlcoord 0, 0
	lb bc, 2, SCREEN_WIDTH - 2
	jmp Textbox

GetCallerClassAndName:
	ld h, d
	ld l, e
	ld a, b
	call GetCallerTrainerClass
	jr GetCallerName

CheckCanDeletePhoneNumber:
	ld a, c
	call GetCallerTrainerClass
	ld a, c
	and a
	ret nz
	ld a, b
	cp PHONECONTACT_MOM
	ret z
	cp PHONECONTACT_ELM
	ret z
	ld c, $1
	ret

GetCallerTrainerClass:
	push hl
	ld hl, PhoneContacts + PHONE_CONTACT_TRAINER_CLASS
	ld bc, PHONE_CONTACT_SIZE
	rst AddNTimes
	ld a, [hli]
	ld b, [hl]
	ld c, a
	pop hl
	ret

GetCallerName:
	ld a, c
	and a
	jr z, .NotTrainer

	call Phone_GetTrainerName
	push hl
	push bc
	rst PlaceString
	ld a, ":"
	ld [bc], a
	pop bc
	pop hl
	ld de, SCREEN_WIDTH + 3
	add hl, de
	call Phone_GetTrainerClassName
	jmp PlaceString

.NotTrainer:
	push hl
	ld c, b
	ld b, 0
	ld hl, NonTrainerCallerNames
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld d, [hl]
	ld e, a
	pop hl
	jmp PlaceString

INCLUDE "data/phone/non_trainer_names.asm"

Phone_GetTrainerName:
	push hl
	push bc
	farcall GetTrainerName
	pop bc
	pop hl
	ret

Phone_GetTrainerClassName:
	push hl
	push bc
	farcall GetTrainerClassName
	pop bc
	pop hl
	ret

GetCallerLocation:
	ld a, [wCurCaller]
	call GetCallerTrainerClass
	ld d, c
	ld e, b
	push de
	ld a, [wCurCaller]
	ld hl, PhoneContacts + PHONE_CONTACT_MAP_GROUP
	ld bc, PHONE_CONTACT_SIZE
	rst AddNTimes
	ld a, [hli]
	ld b, a
	ld c, [hl]
	push bc
	call GetWorldMapLocation
	ld e, a
	farcall GetLandmarkName
	pop bc
	pop de
	ret

INCLUDE "data/phone/phone_contacts.asm"

INCLUDE "data/phone/special_calls.asm"

PhoneOutOfAreaScript:
	writetext PhoneOutOfAreaText
	end

PhoneOutOfAreaText:
	text_far _PhoneOutOfAreaText
	text_end

PhoneScript_JustTalkToThem:
	writetext PhoneJustTalkToThemText
	end

PhoneJustTalkToThemText:
	text_far _PhoneJustTalkToThemText
	text_end

if DEF(_DEBUG)

; Phone debug tools for the bedroom's debug NPC (see PlayersHouseDebugPhoneScript).

DebugPhoneRegisterAll::
; Registers every contact, skipping the contact table's unused rows.
	ld c, NUM_PHONE_CONTACTS
.loop
	push bc
	ld a, c
	ld hl, PhoneContacts + PHONE_CONTACT_TRAINER_CLASS
	ld bc, PHONE_CONTACT_SIZE
	rst AddNTimes
	ld a, [hli]
	or [hl]
	pop bc
	call nz, AddPhoneNumber
	dec c
	jr nz, .loop
	ret

DebugPhonePickCaller::
; Picks a caller like CheckPhoneCall, without its timer or 50% roll.
; wScriptVar: 0 = caller loaded, 1 = no phone service here, 2 = nobody can call.
	call GetMapPhoneService
	and a
	ld a, 1
	jr nz, .done
	call ChooseRandomCaller
	jr nc, .nobody
	ld e, a
	call LoadCallerScript
	xor a
	jr .done

.nobody
	ld a, 2
.done
	ld [wScriptVar], a
	ret

DebugPhoneSetAllRematches::
	ld hl, PhoneContactWaitingFlags
	jr DebugPhoneSetWaitingFlags

DebugPhoneSetAllItems::
	ld hl, PhoneContactWaitingFlags + 2
	; fallthrough
DebugPhoneSetWaitingFlags:
; Sets one column of PhoneContactWaitingFlags, starting at hl.
	ld c, NUM_PHONE_CONTACTS + 1
.loop
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	inc hl
	inc hl
	cp HIGH(-1)
	jr z, .next
	push hl
	push bc
	ld b, SET_FLAG
	farcall EngineFlagAction
	pop bc
	pop hl
.next
	dec c
	jr nz, .loop
	ret

DebugPhoneClearWaitingFlags::
; Clears every rematch, item and weekly-window flag.
	assert wDailyPhoneItemFlags == wDailyRematchFlags + 4
	assert wDailyPhoneTimeOfDayFlags == wDailyPhoneItemFlags + 4
	xor a
	ld hl, wDailyRematchFlags
	ld bc, 4 * 3
	rst ByteFill
	ret

endc
