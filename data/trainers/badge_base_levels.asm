BadgeBaseLevels:
; The level a LEVEL_FROM_BADGES Pokémon starts from, by the player's total badges (Johto and Kanto).
; In Johto, entry n is the ace of the gym just beaten; Chuck, Pryce and Jasmine can be beaten in
; any order, so that stretch is their aces sorted, and 5 and 6 are smoothed from 25 to 36 in steps
; of 3, since the routes open then stay at 24-31. No Johto map reads past 7: those that open later
; are capped (BadgeScalingCaps). In Kanto, entry n is the ace of the next leader the player fights,
; in whatever order, rising from 58 to 67, and 69 once all 16 are won.
	table_width 1
	db  5 ;  0
	db 10 ;  1: Falkner
	db 16 ;  2: Bugsy
	db 21 ;  3: Whitney
	db 25 ;  4: Morty
	db 28 ;  5: Chuck
	db 31 ;  6: Pryce
	db 36 ;  7: Jasmine
	db 58 ;  8: the first Kanto leader
	db 59 ;  9
	db 61 ; 10
	db 62 ; 11
	db 64 ; 12
	db 65 ; 13
	db 66 ; 14
	db 67 ; 15: the last Kanto leader
	db 69 ; 16: all badges
	assert_table_length NUM_BADGES + 1
