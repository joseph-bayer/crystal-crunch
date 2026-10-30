CheckTrainerBattle::
	ldh a, [hROMBank]
	push af

	call SwitchToMapScriptsBank
	call _CheckTrainerBattle

	pop bc
	ld a, b
	rst Bankswitch
	ret

_CheckTrainerBattle::
; Check if any trainer on the map sees the player and wants to battle.

; Skip the player object.
	ld a, 1
	ld de, wMap1Object

.loop

; Start a battle if the object:
	push af
	push de

; Has a sprite
	ld hl, MAPOBJECT_SPRITE
	add hl, de
	ld a, [hl]
	and a
	jr z, .next

; Is a trainer
	ld hl, MAPOBJECT_TYPE
	add hl, de
	ld a, [hl]
	cp OBJECTTYPE_TRAINER
	jr nz, .next

; Is visible on the map
	ld hl, MAPOBJECT_OBJECT_STRUCT_ID
	add hl, de
	ld a, [hl]
	cp -1
	jr z, .next

; Is facing the player...
	call GetObjectStruct
	call FacingPlayerDistance_bc
	jr nc, .next

; ...within their sight range...
	ld hl, MAPOBJECT_SIGHT_RANGE
	add hl, de
	ld a, [hl]
	cp b
	jr c, .next

; ...and no follower in the way
	call CheckFollowerBetweenObjectAndPlayer
	jr z, .next

; And hasn't already been beaten
	push bc
	push de
	ld hl, MAPOBJECT_SCRIPT_POINTER
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld b, CHECK_FLAG
	call EventFlagAction
	ld a, c
	pop de
	pop bc
	and a
	jr z, .startbattle

.next
	pop de
	ld hl, MAPOBJECT_LENGTH
	add hl, de
	ld d, h
	ld e, l

	pop af
	inc a
	cp NUM_OBJECTS
	jr nz, .loop
	xor a
	ret

.startbattle
if DEF(_DEBUG)
	ldh a, [hJoypadDown]
	or ~B_BUTTON
	inc a
	jr z, .next ; ignore trainers
endc
	pop de
	pop af
	ldh [hLastTalked], a
	ld a, b
	ld [wSeenTrainerDistance], a
	ld a, c
	ld [wSeenTrainerDirection], a
	jr LoadTrainer_continue

TalkToTrainer::
	ld a, 1
	ld [wSeenTrainerDistance], a
	ld a, -1
	ld [wSeenTrainerDirection], a

LoadTrainer_continue::
	call GetMapScriptsBank
	ld [wSeenTrainerBank], a

	ldh a, [hLastTalked]
	call GetMapObject

	ld hl, MAPOBJECT_SCRIPT_POINTER
	add hl, bc
	ld a, [wSeenTrainerBank]
	call GetFarWord
	ld de, wTempTrainer
	ld bc, wTempTrainerEnd - wTempTrainer
	ld a, [wSeenTrainerBank]
	call FarCopyBytes
	xor a
	ld [wRunningTrainerBattleScript], a
	scf
	ret

CheckFollowerBetweenObjectAndPlayer::
; Returns z when the follower stands on the tile next to the player on the side an object facing
; direction c (OW_*) sees them from: between the two. Both coordinates have to match. Comparing
; only the column made a follower anywhere to the player's left block every right-facing trainer,
; and with nobody following, the empty follower struct sits at column 0, left of everything.
; A hidden follower never blocks: Surf and the like leave its last position behind.
	push bc
	push de
	ld d, c
	ld bc, wObject1Struct
	call DoesObjectHaveASprite
	jr z, .not_between
	ld a, [wFollowerFlags]
	bit FOLLOWER_INVISIBLE_F, a
	jr nz, .not_between
	ld hl, OBJECT_FLAGS1
	add hl, bc
	bit INVISIBLE_F, [hl]
	jr nz, .not_between
	ld a, [wPlayerMapX]
	ld b, a
	ld a, [wPlayerMapY]
	ld c, a
	ld a, d
	cp OW_DOWN ; the object is above the player
	jr nz, .not_down
	dec c
	jr .compare
.not_down
	cp OW_UP ; below
	jr nz, .not_up
	inc c
	jr .compare
.not_up
	cp OW_LEFT ; to the right
	jr nz, .right
	inc b
	jr .compare
.right ; to the left
	dec b
.compare
	ld a, [wObject1MapX]
	cp b
	jr nz, .done
	ld a, [wObject1MapY]
	cp c
	jr .done
.not_between
	or 1
.done
	pop de
	pop bc
	ret

FacingPlayerDistance_bc::
	push de
	call FacingPlayerDistance
	ld b, d
	ld c, e
	pop de
	ret

FacingPlayerDistance::
; Return carry if the sprite at bc is facing the player,
; its distance in d, and its direction in e.

	ld hl, OBJECT_MAP_X ; x
	add hl, bc
	ld d, [hl]

	ld hl, OBJECT_MAP_Y ; y
	add hl, bc
	ld e, [hl]

	ld a, [wPlayerMapX]
	cp d
	jr z, .CheckY

	ld a, [wPlayerMapY]
	cp e
	jr z, .CheckX

	and a
	ret

.CheckY:
	ld a, [wPlayerMapY]
	sub e
	jr z, .NotFacing
	jr nc, .Above

; Below
	cpl
	inc a
	ld d, a
	ld e, OW_UP
	jr .CheckFacing

.Above:
	ld d, a
	ld e, OW_DOWN
	jr .CheckFacing

.CheckX:
	ld a, [wPlayerMapX]
	sub d
	jr z, .NotFacing
	jr nc, .Left

; Right
	cpl
	inc a
	ld d, a
	ld e, OW_LEFT
	jr .CheckFacing

.Left:
	ld d, a
	ld e, OW_RIGHT

.CheckFacing:
	call GetSpriteDirection
	cp e
	jr nz, .NotFacing
	scf
	ret

.NotFacing:
	and a
	ret

PrintWinLossText::
	ld a, [wBattleResult]
	ld hl, wWinTextPointer
	and $f ; WIN?
	jr z, .won
	ld hl, wLossTextPointer

.ok
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call GetMapScriptsBank
.print
	call FarPrintText
	call WaitBGMap
	jmp WaitPressAorB_BlinkCursor

.won
; An Elite Four seat holder says their own beaten text
	ld a, [wEliteFourSeatBattle]
	and a
	jr z, .ok
	farcall GetEliteFourSeatBeatenText
	jr .print

GetTrainerAttributeClass::
; a = the trainer class whose TrainerClassAttributes row (items, prize money, AI) and name apply.
; In an Elite Four seat battle that's the seat's original member's, whoever sits in it; otherwise wTrainerClass. Preserves bc, de and hl.
	ld a, [wEliteFourSeatBattle]
	and a
	jr z, .own
	push hl
	add LOW(EliteFourSeatClasses - 1)
	ld l, a
	adc HIGH(EliteFourSeatClasses - 1)
	sub l
	ld h, a
	ld a, [hl]
	pop hl
	ret

.own
	ld a, [wTrainerClass]
	ret

EliteFourSeatClasses:
; entries correspond to E4_SEAT_* constants
	table_width 1
	db WILL     ; E4_SEAT_1
	db KOGA     ; E4_SEAT_2
	db BRUNO    ; E4_SEAT_3
	db KAREN    ; E4_SEAT_4
	db CHAMPION ; E4_SEAT_CHAMPION
	assert_table_length NUM_E4_SEATS
