HiddenPowerDamage:
; Override Hidden Power's type with the user's Hidden Power type, and its power based on the user's
; Hidden Power level.
; out: BattleCommand_DamageStats's damage stats, with d = Hidden Power's power

	ldh a, [hBattleTurn]
	and a
	jr nz, .enemy
	call GetPlayerHiddenPowerType
	jr .got_type
.enemy
	call GetEnemyHiddenPowerType
.got_type

; Overwrite the current move type.
	push af
	ld a, BATTLE_VARS_MOVE_TYPE
	call GetBattleVarAddr
	pop af
	ld [hl], a

; Get the rest of the damage formula variables
; based on the new type.
	farcall BattleCommand_DamageStats ; damagestats

	push bc
	push de
	call GetUserHiddenPowerPower
	pop de
	ld d, a
	pop bc
	ret

GetPlayerHiddenPowerType::
; out: a = the player's battle mon's Hidden Power type
	call GetPlayerHPLevelByte
	ld b, a
	ld hl, wBattleMonDVs
	jr GetHiddenPowerType

GetEnemyHiddenPowerType::
; out: a = the enemy battle mon's Hidden Power type
	call GetEnemyHPLevelByte
	ld b, a
	ld hl, wEnemyMonDVs
	jr GetHiddenPowerType

GetMonStructHiddenPowerType::
; in: hl = a party (or box-turned-party) mon struct, such as wPartyMon1 or wTempMon
; out: a = its Hidden Power type
	push hl
	ld bc, MON_HP_LEVEL
	add hl, bc
	ld a, [hl]
	pop hl
	ld bc, MON_DVS
	add hl, bc
	ld b, a
	; fallthrough

GetHiddenPowerType::
; in: hl = a mon's DVs, b = its Hidden Power level byte (the high nibble is its type offset)
; out: a = its Hidden Power type
	ld a, b
	swap a
	and HP_TYPE_MASK >> 4
	ld c, a
	call GetDVHiddenPowerIndex
	xor c ; the type offset
	; fallthrough

HiddenPowerTypeFromIndex:
; in: a = a Hidden Power type index (0-15)
; out: a = that type

; Skip Normal
	inc a

; Skip Bird
	cp BIRD
	ret c
	inc a

; Skip unused types
	cp UNUSED_TYPES
	ret c
	add UNUSED_TYPES_END - UNUSED_TYPES
	ret

GetDVHiddenPowerIndex::
; in: hl = a mon's DVs
; out: a = the Hidden Power type index (0-15) its DVs give, before any type offset
	; Def & 3
	ld a, [hl]
	and %0011
	ld b, a

	; + (Atk & 3) << 2
	ld a, [hl]
	and %0011 << 4
	swap a
	add a
	add a
	or b
	ret

GetPlayerHPLevelByte:
; out: a = the player's battle mon's Hidden Power level byte, from its party struct
	ld a, [wCurBattleMon]
	ld hl, wPartyMon1HPLevel
	call GetPartyLocation
	ld a, [hl]
	ret

GetEnemyHPLevelByte:
; out: a = the enemy battle mon's Hidden Power level byte: a trainer's or link opponent's from its
; party struct, and 0 for a wild mon (it has none until it's caught, when it's made with 0)
	ld a, [wBattleMode]
	cp WILD_BATTLE
	jr nz, .party
	xor a
	ret

.party
	ld a, [wCurOTMon]
	ld hl, wOTPartyMon1HPLevel
	call GetPartyLocation
	ld a, [hl]
	ret

SetPlayerUnownTypes::
; An Unown is purely its Hidden Power type. Call once the player's battle mon's types are loaded.
	ld a, [wBattleMonSpecies]
	call IsUnownID
	ret nz
	call GetPlayerHiddenPowerType
	ld [wBattleMonType1], a
	ld [wBattleMonType2], a
	ret

SetEnemyUnownTypes::
; An Unown is purely its Hidden Power type. Call once the enemy battle mon's types are loaded.
	ld a, [wEnemyMonSpecies]
	call IsUnownID
	ret nz
	call GetEnemyHiddenPowerType
	ld [wEnemyMonType1], a
	ld [wEnemyMonType2], a
	ret

SetMonStructUnownBaseTypes::
; An Unown is purely its Hidden Power type: after GetBaseData, overwrite wBaseType1 and wBaseType2
; with it if the mon at hl is an Unown. Preserves all registers.
; in: hl = a party mon struct
	push af
	push bc
	push de
	push hl
	ld a, [hl] ; MON_SPECIES
	call IsUnownID
	pop hl
	push hl
	jr nz, .done
	call GetMonStructHiddenPowerType
	ld [wBaseType1], a
	ld [wBaseType2], a
.done
	pop hl
	pop de
	pop bc
	pop af
	ret

SetUnownDexTypes::
; Unown's type varies by Pokémon, so the Pokédex shows it as ???: after GetBaseData, overwrite
; wBaseType1 and wBaseType2 with DEX_UNKNOWN_TYPE if wCurSpecies is Unown. Preserves all registers.
	push af
	push hl
	ld a, [wCurSpecies]
	call IsUnownID
	jr nz, .done
	ld a, DEX_UNKNOWN_TYPE
	ld [wBaseType1], a
	ld [wBaseType2], a
.done
	pop hl
	pop af
	ret

GetUserHiddenPowerPower:
; The battle user's (hBattleTurn) Hidden Power power. The player's mon uses its own level, and so
; does a link opponent's; a wild mon uses 0, and any other trainer's mon MAX_HP_LEVEL.
; out: a = power
	ldh a, [hBattleTurn]
	and a
	jr nz, .enemy
	call GetPlayerHPLevelByte
	and HP_LEVEL_MASK
	ld b, a
	ld a, [wBattleMonSpecies]
	jr GetHiddenPowerPower

.enemy
	ld a, [wLinkMode]
	and a
	jr nz, .link_opponent
	ld a, [wBattleMode]
	cp WILD_BATTLE
	ld a, MAX_HP_LEVEL
	jr nz, .got_enemy_level
	xor a
	jr .got_enemy_level

.link_opponent
	call GetEnemyHPLevelByte
	and HP_LEVEL_MASK
.got_enemy_level
	ld b, a
	ld a, [wEnemyMonSpecies]
	; fallthrough

GetHiddenPowerPower::
; in: a = species ID, b = Hidden Power level (0 to MAX_HP_LEVEL)
; out: a = Hidden Power's power (Unown's table is higher)
	push bc
	call IsUnownID
	pop bc
	ld hl, HiddenPowerPowers
	jr nz, .got_table
	ld hl, HiddenPowerUnownPowers
.got_table
	ld a, b
	add l
	ld l, a
	adc h
	sub l
	ld h, a
	ld a, [hl]
	ret

IsUnownID::
; in: a = species ID
; out: z if it's Unown
	call GetPokemonIndexFromID
	ld a, l
	cp LOW(UNOWN)
	ret nz
	ld a, h
	cp HIGH(UNOWN)
	ret

MoveScreen_PrintMoveType::
; The party menu's move screen (PlaceMoveData).
; Print the move's type at hl. Hidden Power's is this mon's Hidden Power type, not the move data's.
	push hl
	ld a, [wCurSpecies]
	ld l, a
	ld a, MOVE_EFFECT
	call GetMoveAttribute
	pop hl
	cp EFFECT_HIDDEN_POWER
	jr z, .hidden_power_type
	ld a, [wCurSpecies]
	ld b, a
	predef_jump PrintMoveType

.hidden_power_type
	push hl
	ld a, [wCurPartyMon]
	ld hl, wPartyMon1
	call GetPartyLocation
	call GetMonStructHiddenPowerType
	pop hl
	ld b, a
	predef_jump PrintType

MoveScreen_HiddenPowerPower::
; The party menu's move screen (PlaceMoveData).
; Hidden Power shows this mon's power, from its Hidden Power level, not the move data's.
; in: a = the move data's power
; out: a = the power to show
	push af
	ld a, [wCurSpecies]
	call GetMoveIndexFromID
	ld a, l
	cp LOW(HIDDEN_POWER)
	jr nz, .not_hidden_power
	ld a, h
	cp HIGH(HIDDEN_POWER)
	jr nz, .not_hidden_power
	pop af
	ld a, [wCurPartyMon]
	ld hl, wPartyMon1HPLevel
	call GetPartyLocation
	ld a, [hl]
	and HP_LEVEL_MASK
	push af
	ld a, [wCurPartyMon]
	ld hl, wPartyMon1Species
	call GetPartyLocation
	pop bc ; b = the level
	ld a, [hl]
	jr GetHiddenPowerPower

.not_hidden_power
	pop af
	ret

StatsScreen_PlaceHiddenPowerDetails::
; The Hidden Power stats page's right half: its power and the side it hits from, by the same rule
; as battle (HiddenPowerDamageSide) but from the mon's own stats; and a star after the bar once
; its level is MAX_HP_LEVEL. The mon is wTempMon.
	ld de, .PowerString
	hlcoord 10, 12
	rst PlaceString

	ld a, [wTempMonHPLevel]
	and HP_LEVEL_MASK
	push af
	ld b, a
	ld a, [wTempMonSpecies]
	call GetHiddenPowerPower
	ld [wTextDecimalByte], a
	ld de, wTextDecimalByte
	hlcoord 11, 13
	lb bc, 1, 3
	call PrintNum

	ld hl, wTempMon
	call GetMonStructHiddenPowerType
	ld b, a
	ld hl, wTempMonAttack
	ld a, [hli]
	ld d, a
	ld e, [hl] ; de = Attack
	ld hl, wTempMonSpclAtk
	ld a, [hli] ; compare Special Attack against Attack, high byte first
	cp d
	jr nz, .compared
	ld a, [hl]
	cp e
.compared
	jr c, .physical ; Special Attack is lower
	jr nz, .special
	ld a, b ; a tie: the type decides
	cp SPECIAL
	jr c, .physical
.special
	ld de, .SpecialString
	jr .place_side

.physical
	ld de, .PhysicalString
.place_side
	hlcoord 11, 14
	rst PlaceString

	pop af
	cp MAX_HP_LEVEL
	ret c
	hlcoord 10, 15 ; after the bar's right end cap
	ld [hl], "★"
	ret

.PowerString:
	db "POWER/@"
.PhysicalString:
	db "PHYSICAL@"
.SpecialString:
	db "SPECIAL@"

HiddenPowerPowers:
; even steps, rounded down
	table_width 1
for n, MAX_HP_LEVEL + 1
	db HIDDEN_POWER_MIN_POWER + n * (HIDDEN_POWER_MAX_POWER - HIDDEN_POWER_MIN_POWER) / MAX_HP_LEVEL
endr
	assert_table_length MAX_HP_LEVEL + 1

HiddenPowerUnownPowers:
	table_width 1
for n, MAX_HP_LEVEL + 1
	db HIDDEN_POWER_MIN_POWER + n * (HIDDEN_POWER_UNOWN_MAX_POWER - HIDDEN_POWER_MIN_POWER) / MAX_HP_LEVEL
endr
	assert_table_length MAX_HP_LEVEL + 1
