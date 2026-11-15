BattleCommand_FrustrationPower:
; A trainer's mon hits at max power. Others use (255 - happiness) * 10 / 25, at least 1.
	push bc
	call IsTrainerMonsTurn
	ld a, HAPPINESS_MOVE_MAX_POWER
	jr z, .done
	ld hl, wBattleMonHappiness
	ldh a, [hBattleTurn]
	and a
	jr z, .ok
	ld hl, wEnemyMonHappiness
.ok
	ld a, $ff
	sub [hl]
	ldh [hMultiplicand + 2], a
	xor a
	ldh [hMultiplicand + 0], a
	ldh [hMultiplicand + 1], a
	ld a, 10
	ldh [hMultiplier], a
	call Multiply
	ld a, 25
	ldh [hDivisor], a
	ld b, 4
	call Divide
	ldh a, [hQuotient + 3]
	and a
	jr nz, .done
	inc a
.done
	ld d, a
	pop bc
	ret
