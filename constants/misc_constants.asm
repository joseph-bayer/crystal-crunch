; Boolean checks
DEF FALSE EQU 0
DEF TRUE  EQU 1

; genders
DEF MALE   EQU 0
DEF FEMALE EQU 1

; input
DEF NO_INPUT EQU %00000000

; FlagAction arguments (see home/flag.asm)
	const_def
	const RESET_FLAG
	const SET_FLAG
	const CHECK_FLAG

; G/S version ID: 0 = Gold, 1 = Silver (used by checkver)
; Mystery Gift uses incremented values 1 and 2
DEF GS_VERSION EQU 0
; Pokémon Pikachu 2, a step counter / virtual pet device (used by Mystery Gift)
DEF POKEMON_PIKACHU_2_VERSION EQU 3
DEF RESERVED_GAME_VERSION EQU 4

; save file corruption check values
DEF SAVE_CHECK_VALUE_1 EQU 99
DEF SAVE_CHECK_VALUE_2 EQU 127

; RTC halted check value
DEF RTC_HALT_VALUE EQU $1234

; time of day boundaries
DEF MORN_HOUR EQU 4  ; 4 AM
DEF DAY_HOUR  EQU 10 ; 10 AM
DEF EVE_HOUR  EQU 17 ; 5 PM
DEF NITE_HOUR EQU 20 ; 8 PM
DEF NOON_HOUR EQU 12 ; 12 PM
DEF MAX_HOUR  EQU 24 ; 12 AM

; significant money values
DEF START_MONEY EQU 3000
DEF MOM_MONEY   EQU 2300
DEF MAX_MONEY   EQU 999999
DEF MAX_COINS   EQU 9999

; link record
DEF MAX_LINK_RECORD EQU 9999

; day-care
DEF MAX_DAY_CARE_EXP EQU $500000

; hall of fame
DEF HOF_MASTER_COUNT EQU 200

; sm83 instructions
DEF JP_INSTRUCTION EQU $c3

; card flip
DEF CARDFLIP_DECK_SIZE EQU 4 * 6

; blackjack
DEF BLACKJACK_NUM_SUITS       EQU 4
DEF BLACKJACK_NUM_RANKS       EQU 13 ; ace = 1, jack = 11, queen = 12, king = 13
DEF BLACKJACK_DECK_SIZE       EQU BLACKJACK_NUM_SUITS * BLACKJACK_NUM_RANKS
DEF BLACKJACK_SHOE_DECKS      EQU 2
DEF BLACKJACK_SHOE_SIZE       EQU BLACKJACK_DECK_SIZE * BLACKJACK_SHOE_DECKS
DEF BLACKJACK_SHOE_CUT        EQU BLACKJACK_SHOE_SIZE * 3 / 4 ; reshuffled before the next hand
DEF BLACKJACK_MAX_HAND        EQU 11 ; A A A A 2 2 2 2 3 3 3 is 21; a twelfth card is never dealt
	assert BLACKJACK_SHOE_SIZE - BLACKJACK_SHOE_CUT >= BLACKJACK_MAX_HAND * 2, 		"a hand started before the cut card never runs out of shoe"
DEF BLACKJACK_DEALER_STANDS   EQU 17 ; the dealer stands on every 17, soft or hard
DEF BLACKJACK_BLACKJACK       EQU 21

; blackjack decks: what the cards look like (BlackjackDecks)
	const_def
	const BJ_DECK_FRENCH     ; 0, the one the game uses
	const BJ_DECK_SPACEWORLD ; 1
DEF NUM_BJ_DECKS EQU const_value

; blackjack music: the title screen's MUSIC option (BlackjackMusic)
	const_def
	const BJ_MUSIC_RONALD      ; 0, the first time
	const BJ_MUSIC_GAME_CORNER ; 1
	const BJ_MUSIC_TCG_DUEL    ; 2
DEF NUM_BJ_MUSIC EQU const_value
