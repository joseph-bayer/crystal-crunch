BadgeBaseLevels:
; The level a LEVEL_FROM_BADGES Pokémon starts from, by the player's number of badges: the ace of
; each gym in turn. Chuck, Pryce and Jasmine can be beaten in any order, and so can the Kanto
; leaders, so those stretches are their aces sorted. 5 and 6 are smoothed from 25 to 36 in steps
; of 3, since the routes open then stay at 24-31. Badges don't count the Elite Four, hence the
; jump from 8 to 9.
	table_width 1
	db  5 ;  0
	db 10 ;  1: Falkner
	db 16 ;  2: Bugsy
	db 21 ;  3: Whitney
	db 25 ;  4: Morty
	db 28 ;  5: Chuck
	db 31 ;  6: Pryce
	db 36 ;  7: Jasmine
	db 45 ;  8: Clair
	db 60 ;  9: Lt. Surge
	db 62 ; 10: Erika
	db 63 ; 11: Misty
	db 64 ; 12: Janine
	db 66 ; 13: Sabrina
	db 66 ; 14: Brock
	db 67 ; 15: Blaine
	db 69 ; 16: Blue
	assert_table_length NUM_BADGES + 1
