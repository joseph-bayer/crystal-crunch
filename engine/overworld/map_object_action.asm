ObjectActionPairPointers:
; entries correspond to OBJECT_ACTION_* constants (see constants/map_object_constants.asm)
	table_width 2 + 2
	;  normal action,                  frozen action
	dw SetFacingStanding,              SetFacingStanding
	dw SetFacingStandAction,           SetFacingCurrent
	dw SetFacingStepAction,            SetFacingCurrent
	dw SetFacingBumpAction,            SetFacingCurrent
	dw SetFacingCounterclockwiseSpin,  SetFacingCurrent
	dw SetFacingCounterclockwiseSpin2, SetFacingStanding
	dw SetFacingFish,                  SetFacingFish
	dw SetFacingShadow,                SetFacingStanding
	dw SetFacingEmote,                 SetFacingEmote
	dw SetFacingBigDollSym,            SetFacingBigDollSym
	dw SetFacingBounce,                SetFacingFreezeBounce
	dw SetFacingWeirdTree,             SetFacingCurrent
	dw SetFacingBigDollAsym,           SetFacingBigDollAsym
	dw SetFacingBigDoll,               SetFacingBigDoll
	dw SetFacingBoulderDust,           SetFacingStanding
	dw SetFacingGrassShake,            SetFacingStanding
	dw SetFacingSkyfall,               SetFacingCurrent
	dw SetFacingRunAction,             SetFacingCurrent
	dw SetFacingFollowerStep,          SetFacingCurrent
	dw SetFacingFollowerRun,           SetFacingCurrent
	dw SetFacingFollowerIdle,          SetFacingCurrent
	assert_table_length NUM_OBJECT_ACTIONS

SetFacingStanding:
	ld hl, OBJECT_FACING
	add hl, bc
	ld [hl], STANDING
	ret

SetFacingCurrent:
	call GetSpriteDirection
	or FACING_STEP_DOWN_0 ; useless
	ld hl, OBJECT_FACING
	add hl, bc
	ld [hl], a
	ret

SetFacingStandAction:
; Standing on the moped keeps the walk cycle going at the step pace, like an idling engine.
	call IsMopedRider
	jr z, SetFacingStepPace
	ld hl, OBJECT_FACING
	add hl, bc
	ld a, [hl]
	and 1
	jr z, SetFacingCurrent
; fallthrough
SetFacingStepAction:
; The bike and the moped animate at the running shoes' pace.
	call IsRider
	jmp z, SetFacingRunAction
SetFacingStepPace:
	ld hl, OBJECT_FLAGS1
	add hl, bc
	bit SLIDING_F, [hl]
	jr nz, SetFacingCurrent

	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	inc [hl]
	ld a, [hl]
	rrca
	rrca
	rrca
	and %11
	ld d, a
	call MopedWalkFrame
	call GetSpriteDirection
	or d
	ld hl, OBJECT_FACING
	add hl, bc
	ld [hl], a
	ret

MopedWalkFrame:
; in: d = step frame 0-3 (standing, walking, standing, walking mirrored)
; On the moped the player never shows the mirrored frame: the sheet's down and up frames aren't
; symmetrical. The bike keeps the mirror.
	call IsMopedRider
	ret nz
	res 1, d
	ret

IsRider:
; Return z if bc is the player's object and the player is on the bike or the moped.
	ld a, [wPlayerState]
	cp PLAYER_BIKE
	jr z, IsPlayerObject
IsMopedRider:
; Return z if bc is the player's object and the player is on the moped.
	ld a, [wPlayerState]
	cp PLAYER_MOPED
	ret nz
IsPlayerObject:
	ld a, c
	cp LOW(wPlayerStruct)
	ret nz
	ld a, b
	cp HIGH(wPlayerStruct)
	ret

SetFacingSkyfall:
	ld hl, OBJECT_FLAGS1
	add hl, bc
	bit SLIDING_F, [hl]
	jr nz, SetFacingCurrent

	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	ld a, [hl]
	add 2
	and %00001111
	ld [hl], a

	rrca
	rrca
	maskbits NUM_DIRECTIONS
	ld d, a

	call GetSpriteDirection
	or FACING_STEP_DOWN_0 ; useless
	or d
	ld hl, OBJECT_FACING
	add hl, bc
	ld [hl], a
	ret

SetFacingBumpAction:
	ld hl, OBJECT_FLAGS1
	add hl, bc
	bit SLIDING_F, [hl]
	jmp nz, SetFacingCurrent

	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	inc [hl]

	ld a, [hl]
	rrca
	rrca
	rrca
	maskbits NUM_DIRECTIONS
	ld d, a
	call MopedWalkFrame

	call GetSpriteDirection
	or FACING_STEP_DOWN_0 ; useless
	or d
	ld hl, OBJECT_FACING
	add hl, bc
	ld [hl], a
	ret

SetFacingCounterclockwiseSpin:
	call CounterclockwiseSpinAction
	ld hl, OBJECT_DIRECTION
	add hl, bc
	ld a, [hl]
	or FACING_STEP_DOWN_0 ; useless
	ld hl, OBJECT_FACING
	add hl, bc
	ld [hl], a
	ret

SetFacingCounterclockwiseSpin2:
	call CounterclockwiseSpinAction
	jmp SetFacingStanding

CounterclockwiseSpinAction:
; Here, OBJECT_STEP_FRAME consists of two components,
; bits 0,1,2 form a 3-bit timer (6 overworld frames)
; and bits 4,5 form a 2-bit value that determines the facing - the direction is counterclockwise.
	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	ld a, [hl]
	and %11110000
	ld e, a

	ld a, [hl]
	inc a
	and %00001111
	ld d, a
	cp 6
	jr c, .ok

	ld d, 0
	ld a, e
	add $10
	and %00110000
	ld e, a

.ok
	ld a, d
	or e
	ld [hl], a

	swap e
	ld d, 0
	ld hl, .facings
	add hl, de
	ld a, [hl]
	ld hl, OBJECT_DIRECTION
	add hl, bc
	ld [hl], a
	ret

.facings:
	db OW_DOWN
	db OW_RIGHT
	db OW_UP
	db OW_LEFT

SetFacingFish:
	call GetSpriteDirection
	rrca
	rrca
	add FACING_FISH_DOWN
	ld hl, OBJECT_FACING
	add hl, bc
	ld [hl], a
	ret

SetFacingShadow:
	ld hl, OBJECT_FACING
	add hl, bc
	ld [hl], FACING_SHADOW
	ret

SetFacingEmote:
	ld hl, OBJECT_FACING
	add hl, bc
	ld [hl], FACING_EMOTE
	ret

SetFacingBigDollSym:
	ld hl, OBJECT_FACING
	add hl, bc
	ld [hl], FACING_BIG_DOLL_SYM
	ret

SetFacingBounce:
; A Pokemon's sprite is built from its party icon (ExpandMonIconToSprite): every standing facing is
; icon frame 1 and every walking facing frame 2, with the down-facing ones mirrored. So a Pokemon
; bounces between standing up and walking up, its icon's two frames, as in the party menu. Any other
; sprite (the campfire) flips between its down and up frames.
	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	ld a, [hl]
	inc a
	and %00011111
	ld [hl], a
	and %00010000
	jr z, SetFacingFreezeBounce
	call IsMonIconSprite
	assert FACING_STEP_UP_1 == FACING_STEP_UP_0 + 1
	sbc a
	and 1
	add FACING_STEP_UP_0 ; a Pokemon: walking up, icon frame 2; else standing up
	jr SetBounceFacing

SetFacingFreezeBounce:
	call IsMonIconSprite
	assert FACING_STEP_DOWN_0 == 0
	sbc a
	and FACING_STEP_UP_0 ; a Pokemon: standing up, icon frame 1 unmirrored; else standing down
	; fallthrough

SetBounceFacing:
	ld hl, OBJECT_FACING
	add hl, bc
	ld [hl], a
	ret

IsMonIconSprite:
; carry if the object's sprite is a Pokemon drawn from its party icon (SPRITE_POKEMON up to the
; variable sprites: SpriteMons, the SPRITE_OW_MON_* slots and the day-care mons)
	ld hl, OBJECT_SPRITE
	add hl, bc
	ld a, [hl]
	sub SPRITE_POKEMON
	cp SPRITE_VARS - SPRITE_POKEMON
	ret

SetFacingWeirdTree:
	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	inc [hl]
	ld a, [hl]
	maskbits NUM_DIRECTIONS, 2
	rrca
	rrca
	add FACING_WEIRD_TREE_0
	ld hl, OBJECT_FACING
	add hl, bc
	ld [hl], a
	ret

SetFacingBigDollAsym:
	ld hl, OBJECT_FACING
	add hl, bc
	ld [hl], FACING_BIG_DOLL_ASYM
	ret

SetFacingBigDoll:
	ld a, [wVariableSprites + SPRITE_BIG_DOLL - SPRITE_VARS]
	ld d, FACING_BIG_DOLL_SYM ; symmetric
	cp SPRITE_BIG_SNORLAX
	jr z, .ok
	cp SPRITE_BIG_LAPRAS
	jr z, .ok
	ld d, FACING_BIG_DOLL_ASYM ; asymmetric

.ok
	ld hl, OBJECT_FACING
	add hl, bc
	ld [hl], d
	ret

SetFacingBoulderDust:
	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	inc [hl]
	ld a, [hl]

	ld hl, OBJECT_FACING
	add hl, bc
	and 2
	ld a, FACING_BOULDER_DUST_1
	jr z, .ok
	assert FACING_BOULDER_DUST_1 + 1 == FACING_BOULDER_DUST_2
	inc a
.ok
	ld [hl], a
	ret

SetFacingGrassShake:
	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	inc [hl]
	ld a, [hl]
	ld hl, OBJECT_FACING
	add hl, bc
	and 4
	ld a, FACING_GRASS_1
	jr z, .ok
	assert FACING_GRASS_1 + 1 == FACING_GRASS_2
	inc a
.ok
	ld [hl], a
	ret

SetFacingRunAction:
	ld hl, OBJECT_FLAGS1
	add hl, bc
	bit SLIDING_F, [hl]
	jmp nz, SetFacingCurrent

	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	inc [hl]
	ld a, [hl]
	rrca
	rrca
	and %11
	ld d, a
	call MopedWalkFrame
	call GetSpriteDirection
	or d
	ld hl, OBJECT_FACING
	add hl, bc
	ld [hl], a
	ret

SetFacingFollowerIdle:
; Standing still, the follower keeps flipping between its two icon frames, the way a hovered
; party menu icon does. Nothing else drives this -- the step actions only run while the player is
; moving -- so cycle on the object's own frame counter, one flip every 16 frames.
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld [hl], 0 ; a step may have left the hop behind

; While text is up the font sits in VRAM where the second frame lives (OpenText and reanchormap
; load it over the walking frames, and CloseText reloads the sprites), so hold the standing frame
; until then. Otherwise every other frame draws font tiles: an Elite Four door closing behind a
; follower that applymovement left unfrozen.
	ld a, [wStateFlags]
	bit TEXT_STATE_F, a
	jr z, .animate
	xor a ; the standing frame
	jr _SetFacingFollowerIdleFrame

.animate
	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	inc [hl]
	ld a, [hl]
	rrca
	rrca
	rrca
	rrca
	and %1
	jr _SetFacingFollowerIdleFrame

SetFacingFollowerStep:
; The follower is drawn from its two-frame party menu icon, so it only has a standing frame and a
; walking frame. Masking the step frame to one bit alternates just those two; the normal four-frame
; cycle would also use step frame 3, which is the walking frame mirrored, flipping the icon
; left-to-right mid-stride.
	ld hl, OBJECT_FLAGS1
	add hl, bc
	bit SLIDING_F, [hl]
	jmp nz, SetFacingCurrent

	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	inc [hl]
	ld a, [hl]
	rrca
	rrca
	rrca
	and %1
	jr _SetFacingFollowerFrame

SetFacingFollowerRun:
; As above, but cycling at the faster cadence SetFacingRunAction uses.
	ld hl, OBJECT_FLAGS1
	add hl, bc
	bit SLIDING_F, [hl]
	jmp nz, SetFacingCurrent

	ld hl, OBJECT_STEP_FRAME
	add hl, bc
	inc [hl]
	ld a, [hl]
	rrca
	rrca
	and %1
_SetFacingFollowerFrame:
; in: a = 0 for the standing frame, 1 for the walking one
	ld d, a
; Lift the standing frame a pixel so the follower hops along rather than sliding.
; It has to be that frame rather than the walking one. An icon's second frame is a squash with
; the feet planted -- both frames end on the same bottom row, and the second starts one or two
; rows lower -- so lifting the squashed frame just cancels the squash, leaving the top still and
; the bottom rising. Lifting the extended frame instead reads as squash, then spring.
; Actions run after step functions, and a normal step never touches the sprite offset -- only
; jumps do, and those use their own actions -- so the two do not fight. The idle action clears it.
	ld hl, OBJECT_SPRITE_Y_OFFSET
	add hl, bc
	ld a, d
	dec a ; the extended frame lifts to -1, the squashed one stays at 0
	ld [hl], a
	ld a, d

_SetFacingFollowerIdleFrame:
; As above but leaving the sprite offset alone, so a standing follower animates without bobbing.
	ld d, a
	call GetSpriteDirection
	or d
	ld hl, OBJECT_FACING
	add hl, bc
	ld [hl], a
	ret
