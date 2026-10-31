if DEF(_DEBUG)

; The BADGE CASE key item, which only the debug script gives (maps/PlayersHouse2F.asm).

DebugBadgeCase::
; Pick how many badges to have, 0 to NUM_BADGES, starting from the current count. The first that
; many are set, Johto's then Kanto's, and the rest cleared. B leaves them as they were.
	ld hl, wBadges
	ld b, 2
	call CountSetBits
	ld [wTextDecimalByte], a
	ld hl, DebugBadgeCaseHowManyText
	call MenuTextbox
.loop
	call .ShowCount
.wait
	call JoyTextDelay
	ldh a, [hJoyPressed]
	bit B_PAD_UP, a
	jr nz, .up
	bit B_PAD_DOWN, a
	jr nz, .down
	bit B_PAD_A, a
	jr nz, .set
	bit B_PAD_B, a
	jmp nz, ExitMenu
	call DelayFrame
	jr .wait

.up
	ld hl, wTextDecimalByte
	ld a, [hl]
	inc a
	cp NUM_BADGES + 1
	jr c, .got_count
	xor a
	jr .got_count

.down
	ld hl, wTextDecimalByte
	ld a, [hl]
	and a
	jr nz, .lower
	ld a, NUM_BADGES + 1
.lower
	dec a
.got_count
	ld [hl], a
	jr .loop

.set
	call ExitMenu
	ld a, [wTextDecimalByte]
	cp NUM_JOHTO_BADGES + 1
	jr c, .johto_only
	sub NUM_JOHTO_BADGES
	call .FirstBits
	ld [wKantoBadges], a
	ld a, NUM_JOHTO_BADGES
	jr .johto
.johto_only
	ld b, a
	xor a
	ld [wKantoBadges], a
	ld a, b
.johto
	call .FirstBits
	ld [wJohtoBadges], a
	ld hl, DebugBadgeCaseNowText
	jmp MenuTextboxWaitButton

.FirstBits:
; a = the lowest a bits set, for a from 0 to 8.
	and a
	ret z
	ld b, a
	xor a
.bit
	scf
	rla
	dec b
	jr nz, .bit
	ret

.ShowCount:
; PrintNum skips a number's unused leading digits rather than blanking them, so clear both first,
; or 16 then 0 shows as "10".
	hlcoord 9, 16
	ld a, " "
	ld [hli], a
	ld [hld], a
	ld de, wTextDecimalByte
	lb bc, 1, 2
	call PrintNum
	jmp WaitBGMap

DebugBadgeCaseHowManyText:
	text "How many badges?"
	line "Badges:"
	done

DebugBadgeCaseNowText:
	text "You now have"
	line "@"
	text_decimal wTextDecimalByte, 1, 2
	text " badges."
	done

endc
