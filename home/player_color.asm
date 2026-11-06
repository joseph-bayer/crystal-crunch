IsPlayerFemale::
; Return nz and a = 1 for a girl, z and a = 0 for a boy.
	ld a, [wPlayerGender]
	and 1 << PLAYERGENDER_FEMALE_F
	ret

GetPlayerColor::
; Return the player's PLAYER_COLOR_* in a, with 0 (or a bad value) turned into the gender's
; default. The cable club's female-to-male setup is always the boy's red.
	ld a, [wPlayerSpriteSetupFlags]
	bit PLAYERSPRITESETUP_FEMALE_TO_MALE_F, a
	ld a, PLAYER_COLOR_RED
	ret nz
	ld a, [wPlayerGender]
	and PLAYER_COLOR_MASK
	jr z, .default
	rrca
	cp NUM_PLAYER_COLORS + 1
	ret c
.default
	call IsPlayerFemale
	assert PLAYER_COLOR_RED + 1 == PLAYER_COLOR_BLUE
	add PLAYER_COLOR_RED
	ret

GetPlayerOWPal::
; Return the PAL_OW_* color the player wears in a.
	call GetPlayerColor
	assert PLAYER_COLOR_AZURE - PLAYER_COLOR_RED == PAL_OW_AZURE - PAL_OW_RED
	assert PAL_OW_AZURE + 1 == PAL_OW_WHITE && PAL_OW_WHITE + 1 == PAL_OW_BLACK
	assert PLAYER_COLOR_AZURE + 1 == PLAYER_COLOR_BLACK
	assert PAL_OW_RED == 0
	dec a
	cp PAL_OW_WHITE
	ret c
	inc a ; skip white
	ret
