BattleCommand_HappinessPower:
; A trainer's mon hits at max power. Others use happiness * 10 / 25, at least 1.
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
	xor a
	ldh [hMultiplicand + 0], a
	ldh [hMultiplicand + 1], a
	ld a, [hl]
	ldh [hMultiplicand + 2], a
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

IsTrainerMonsTurn:
; out: z if the battle user (hBattleTurn) is a trainer's mon: the enemy, in a trainer battle that
; isn't a link battle. A link opponent's mon and a wild mon get nz, like the player's.
	ldh a, [hBattleTurn]
	and a
	jr z, .no
	ld a, [wLinkMode]
	and a
	ret nz
	ld a, [wBattleMode]
	cp TRAINER_BATTLE
	ret

.no
	inc a ; nz
	ret
