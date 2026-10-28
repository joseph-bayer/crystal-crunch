; pokemon ids
; indexes for:
; - PokemonNames (see data/pokemon/names.asm)
; - BaseData (see data/pokemon/base_stats.asm)
; - EvosAttacksPointers (see data/pokemon/evos_attacks_pointers.asm)
; - EggMovePointers (see data/pokemon/egg_move_pointers.asm)
; - PokemonCries (see data/pokemon/cries.asm)
; - IconPointers (see data/pokemon/icon_pointers.asm)
; - PokemonPicPointers (see data/pokemon/pic_pointers.asm)
; - PokemonPalettes (see data/pokemon/palettes.asm)
; - PokedexDataPointerTable (see data/pokemon/dex_entry_pointers.asm)
; - AlphabeticalPokedexOrder (see data/pokemon/dex_order_alpha.asm)
; - NewPokedexOrder (see data/pokemon/dex_order_new.asm)
; - Pokered_MonIndices (see data/pokemon/gen1_order.asm)
; - Footprints (see gfx/footprints.asm)
; - AnimationPointers (see gfx/pokemon/anim_pointers.asm)
; - AnimationIdlePointers (see gfx/pokemon/idle_pointers.asm)
; - BitmasksPointers (see gfx/pokemon/bitmask_pointers.asm)
; - FramesPointers (see gfx/pokemon/frame_pointers.asm)
; - EZChat_SortedPokemon (see data/pokemon/ezchat_order.asm)
	const_def 1
	const BULBASAUR  ; 01
	const IVYSAUR    ; 02
	const VENUSAUR   ; 03
	const CHARMANDER ; 04
	const CHARMELEON ; 05
	const CHARIZARD  ; 06
	const SQUIRTLE   ; 07
	const WARTORTLE  ; 08
	const BLASTOISE  ; 09
	const CATERPIE   ; 0a
	const METAPOD    ; 0b
	const BUTTERFREE ; 0c
	const WEEDLE     ; 0d
	const KAKUNA     ; 0e
	const BEEDRILL   ; 0f
	const PIDGEY     ; 10
	const PIDGEOTTO  ; 11
	const PIDGEOT    ; 12
	const RATTATA    ; 13
	const RATICATE   ; 14
	const SPEAROW    ; 15
	const FEAROW     ; 16
	const EKANS      ; 17
	const ARBOK      ; 18
	const PIKACHU    ; 19
	const RAICHU     ; 1a
	const SANDSHREW  ; 1b
	const SANDSLASH  ; 1c
	const NIDORAN_F  ; 1d
	const NIDORINA   ; 1e
	const NIDOQUEEN  ; 1f
	const NIDORAN_M  ; 20
	const NIDORINO   ; 21
	const NIDOKING   ; 22
	const CLEFAIRY   ; 23
	const CLEFABLE   ; 24
	const VULPIX     ; 25
	const NINETALES  ; 26
	const JIGGLYPUFF ; 27
	const WIGGLYTUFF ; 28
	const ZUBAT      ; 29
	const GOLBAT     ; 2a
	const ODDISH     ; 2b
	const GLOOM      ; 2c
	const VILEPLUME  ; 2d
	const PARAS      ; 2e
	const PARASECT   ; 2f
	const VENONAT    ; 30
	const VENOMOTH   ; 31
	const DIGLETT    ; 32
	const DUGTRIO    ; 33
	const MEOWTH     ; 34
	const PERSIAN    ; 35
	const PSYDUCK    ; 36
	const GOLDUCK    ; 37
	const MANKEY     ; 38
	const PRIMEAPE   ; 39
	const GROWLITHE  ; 3a
	const ARCANINE   ; 3b
	const POLIWAG    ; 3c
	const POLIWHIRL  ; 3d
	const POLIWRATH  ; 3e
	const ABRA       ; 3f
	const KADABRA    ; 40
	const ALAKAZAM   ; 41
	const MACHOP     ; 42
	const MACHOKE    ; 43
	const MACHAMP    ; 44
	const BELLSPROUT ; 45
	const WEEPINBELL ; 46
	const VICTREEBEL ; 47
	const TENTACOOL  ; 48
	const TENTACRUEL ; 49
	const GEODUDE    ; 4a
	const GRAVELER   ; 4b
	const GOLEM      ; 4c
	const PONYTA     ; 4d
	const RAPIDASH   ; 4e
	const SLOWPOKE   ; 4f
	const SLOWBRO    ; 50
	const MAGNEMITE  ; 51
	const MAGNETON   ; 52
	const FARFETCH_D ; 53
	const DODUO      ; 54
	const DODRIO     ; 55
	const SEEL       ; 56
	const DEWGONG    ; 57
	const GRIMER     ; 58
	const MUK        ; 59
	const SHELLDER   ; 5a
	const CLOYSTER   ; 5b
	const GASTLY     ; 5c
	const HAUNTER    ; 5d
	const GENGAR     ; 5e
	const ONIX       ; 5f
	const DROWZEE    ; 60
	const HYPNO      ; 61
	const KRABBY     ; 62
	const KINGLER    ; 63
	const VOLTORB    ; 64
	const ELECTRODE  ; 65
	const EXEGGCUTE  ; 66
	const EXEGGUTOR  ; 67
	const CUBONE     ; 68
	const MAROWAK    ; 69
	const HITMONLEE  ; 6a
	const HITMONCHAN ; 6b
	const LICKITUNG  ; 6c
	const KOFFING    ; 6d
	const WEEZING    ; 6e
	const RHYHORN    ; 6f
	const RHYDON     ; 70
	const CHANSEY    ; 71
	const TANGELA    ; 72
	const KANGASKHAN ; 73
	const HORSEA     ; 74
	const SEADRA     ; 75
	const GOLDEEN    ; 76
	const SEAKING    ; 77
	const STARYU     ; 78
	const STARMIE    ; 79
	const MR__MIME   ; 7a
	const SCYTHER    ; 7b
	const JYNX       ; 7c
	const ELECTABUZZ ; 7d
	const MAGMAR     ; 7e
	const PINSIR     ; 7f
	const TAUROS     ; 80
	const MAGIKARP   ; 81
	const GYARADOS   ; 82
	const LAPRAS     ; 83
	const DITTO      ; 84
	const EEVEE      ; 85
	const VAPOREON   ; 86
	const JOLTEON    ; 87
	const FLAREON    ; 88
	const PORYGON    ; 89
	const OMANYTE    ; 8a
	const OMASTAR    ; 8b
	const KABUTO     ; 8c
	const KABUTOPS   ; 8d
	const AERODACTYL ; 8e
	const SNORLAX    ; 8f
	const ARTICUNO   ; 90
	const ZAPDOS     ; 91
	const MOLTRES    ; 92
	const DRATINI    ; 93
	const DRAGONAIR  ; 94
	const DRAGONITE  ; 95
	const MEWTWO     ; 96
	const MEW        ; 97
DEF NUM_KANTO_POKEMON EQU const_value - 1
DEF JOHTO_POKEMON EQU const_value
	const CHIKORITA  ; 98
	const BAYLEEF    ; 99
	const MEGANIUM   ; 9a
	const CYNDAQUIL  ; 9b
	const QUILAVA    ; 9c
	const TYPHLOSION ; 9d
	const TOTODILE   ; 9e
	const CROCONAW   ; 9f
	const FERALIGATR ; a0
	const SENTRET    ; a1
	const FURRET     ; a2
	const HOOTHOOT   ; a3
	const NOCTOWL    ; a4
	const LEDYBA     ; a5
	const LEDIAN     ; a6
	const SPINARAK   ; a7
	const ARIADOS    ; a8
	const CROBAT     ; a9
	const CHINCHOU   ; aa
	const LANTURN    ; ab
	const PICHU      ; ac
	const CLEFFA     ; ad
	const IGGLYBUFF  ; ae
	const TOGEPI     ; af
	const TOGETIC    ; b0
	const NATU       ; b1
	const XATU       ; b2
	const MAREEP     ; b3
	const FLAAFFY    ; b4
	const AMPHAROS   ; b5
	const BELLOSSOM  ; b6
	const MARILL     ; b7
	const AZUMARILL  ; b8
	const SUDOWOODO  ; b9
	const POLITOED   ; ba
	const HOPPIP     ; bb
	const SKIPLOOM   ; bc
	const JUMPLUFF   ; bd
	const AIPOM      ; be
	const SUNKERN    ; bf
	const SUNFLORA   ; c0
	const YANMA      ; c1
	const WOOPER     ; c2
	const QUAGSIRE   ; c3
	const ESPEON     ; c4
	const UMBREON    ; c5
	const MURKROW    ; c6
	const SLOWKING   ; c7
	const MISDREAVUS ; c8
	const UNOWN      ; c9
	const WOBBUFFET  ; ca
	const GIRAFARIG  ; cb
	const PINECO     ; cc
	const FORRETRESS ; cd
	const DUNSPARCE  ; ce
	const GLIGAR     ; cf
	const STEELIX    ; d0
	const SNUBBULL   ; d1
	const GRANBULL   ; d2
	const QWILFISH   ; d3
	const SCIZOR     ; d4
	const SHUCKLE    ; d5
	const HERACROSS  ; d6
	const SNEASEL    ; d7
	const TEDDIURSA  ; d8
	const URSARING   ; d9
	const SLUGMA     ; da
	const MAGCARGO   ; db
	const SWINUB     ; dc
	const PILOSWINE  ; dd
	const CORSOLA    ; de
	const REMORAID   ; df
	const OCTILLERY  ; e0
	const DELIBIRD   ; e1
	const MANTINE    ; e2
	const SKARMORY   ; e3
	const HOUNDOUR   ; e4
	const HOUNDOOM   ; e5
	const KINGDRA    ; e6
	const PHANPY     ; e7
	const DONPHAN    ; e8
	const PORYGON2   ; e9
	const STANTLER   ; ea
	const SMEARGLE   ; eb
	const TYROGUE    ; ec
	const HITMONTOP  ; ed
	const SMOOCHUM   ; ee
	const ELEKID     ; ef
	const MAGBY      ; f0
	const MILTANK    ; f1
	const BLISSEY    ; f2
	const RAIKOU     ; f3
	const ENTEI      ; f4
	const SUICUNE    ; f5
	const LARVITAR   ; f6
	const PUPITAR    ; f7
	const TYRANITAR  ; f8
	const LUGIA      ; f9
	const HO_OH      ; fa
	const CELEBI     ; fb
DEF NUM_JOHTO_POKEMON EQU const_value - 1
DEF NUM_POKEMON EQU const_value - 1

DEF EGG EQU -3

; limits:
; 999: everything that prints dex counts
; 1407: size of wPokedexOrder
; 4095: hard limit; would require serious redesign to increase
if NUM_POKEMON > 999
	fail "Too many Pokémon defined!"
endc

; Unown forms
	const_def 0 ; Note that forms are now 0-indexed
	const UNOWN_A ;  0
	const UNOWN_B ;  1
	const UNOWN_C ;  2
	const UNOWN_D ;  3
	const UNOWN_E ;  4
	const UNOWN_F ;  5
	const UNOWN_G ;  6
	const UNOWN_H ;  7
	const UNOWN_I ;  8
	const UNOWN_J ;  9
	const UNOWN_K ; 10
	const UNOWN_L ; 11
	const UNOWN_M ; 12
	const UNOWN_N ; 13
	const UNOWN_O ; 14
	const UNOWN_P ; 15
	const UNOWN_Q ; 16
	const UNOWN_R ; 17
	const UNOWN_S ; 18
	const UNOWN_T ; 19
	const UNOWN_U ; 20
	const UNOWN_V ; 21
	const UNOWN_W ; 22
	const UNOWN_X ; 23
	const UNOWN_Y ; 24
	const UNOWN_Z ; 25
DEF NUM_UNOWN EQU const_value ; 26

; Charmeleon forms
  const_def 0 ; Note that forms are now 0-indexed
  const CHARMELEON_PLAIN_FORM  ; 0
  const CHARMELEON_ROCKET_FORM ; 1 -- Team Rocket's
DEF NUM_CHARMELEON_FORMS EQU const_value ; 2

; Charizard forms
; Numbered in parallel with Charmeleon's, so a Rocket Charmeleon stays Rocket when it evolves
  const_def 0 ; Note that forms are now 0-indexed
  const CHARIZARD_PLAIN_FORM  ; 0
  const CHARIZARD_ROCKET_FORM ; 1 -- Team Rocket's
DEF NUM_CHARIZARD_FORMS EQU const_value ; 2

; Weezing forms
  const_def 0 ; Note that forms are now 0-indexed
  const WEEZING_PLAIN_FORM  ; 0
  const WEEZING_ROCKET_FORM ; 1 -- Team Rocket's; every Rocket Weezing is one
  const WEEZING_RB_FORM     ; 2 -- its Red/Blue sprite
DEF NUM_WEEZING_FORMS EQU const_value ; 3

; Crobat forms
; Numbered in parallel with Golbat's, so a Rocket Golbat stays Rocket when it evolves
  const_def 0 ; Note that forms are now 0-indexed
  const CROBAT_PLAIN_FORM  ; 0
  const CROBAT_ROCKET_FORM ; 1 -- Team Rocket's; every Rocket Crobat is one
  const CROBAT_BETA_FORM   ; 2 -- its Spaceworld beta sprite, numbered with the line's RB form
DEF NUM_CROBAT_FORMS EQU const_value ; 3

; Electrode forms
  const_def 0 ; Note that forms are now 0-indexed
  const ELECTRODE_PLAIN_FORM  ; 0
  const ELECTRODE_ROCKET_FORM ; 1 -- Team Rocket's; the six in the Rocket Base
DEF NUM_ELECTRODE_FORMS EQU const_value ; 2

; Pikachu forms
  const_def 0 ; Note that forms are now 0-indexed
  const PIKACHU_PLAIN_FORM  ; 0
  const PIKACHU_SURF_FORM   ; 1
  const PIKACHU_FLY_FORM    ; 2
  const PIKACHU_RB_FORM     ; 3
  ; TODO: const PIKACHU_PARTY_HAT_FORM ; 4
DEF NUM_PIKACHU_FORMS EQU const_value ; 4

; Pichu forms
; Numbered in parallel with Pikachu's, so the RB form survives evolution
  const_def 0 ; Note that forms are now 0-indexed
  const PICHU_PLAIN_FORM    ; 0
  const PICHU_UNUSED_1_FORM ; 1 -- looks plain; holds Pikachu's Surf number
  const PICHU_UNUSED_2_FORM ; 2 -- looks plain; holds Pikachu's Fly number
  const PICHU_BETA_FORM     ; 3 -- its Spaceworld beta sprite, numbered with the line's RB form
DEF NUM_PICHU_FORMS EQU const_value ; 4

; Raichu forms
; Numbered in parallel with Pikachu's, so the RB form survives evolution
  const_def 0 ; Note that forms are now 0-indexed
  const RAICHU_PLAIN_FORM ; 0
  const RAICHU_SURF_FORM  ; 1 -- looks plain; what a Surfing Pikachu evolves into
  const RAICHU_FLY_FORM   ; 2 -- looks plain; what a Flying Pikachu evolves into
  const RAICHU_RB_FORM    ; 3 -- its Red/Blue sprite
DEF NUM_RAICHU_FORMS EQU const_value ; 4

; Machop forms
  const_def 0 ; Note that forms are now 0-indexed
  const MACHOP_PLAIN_FORM ; 0
  const MACHOP_RB_FORM    ; 1 -- its Red/Blue sprite
DEF NUM_MACHOP_FORMS EQU const_value ; 2

; Machoke forms
  const_def 0 ; Note that forms are now 0-indexed
  const MACHOKE_PLAIN_FORM ; 0
  const MACHOKE_RB_FORM    ; 1 -- its Red/Blue sprite
DEF NUM_MACHOKE_FORMS EQU const_value ; 2

; Machamp forms
  const_def 0 ; Note that forms are now 0-indexed
  const MACHAMP_PLAIN_FORM ; 0
  const MACHAMP_RB_FORM    ; 1 -- its Red/Blue sprite
DEF NUM_MACHAMP_FORMS EQU const_value ; 2

; Tentacool forms
  const_def 0 ; Note that forms are now 0-indexed
  const TENTACOOL_PLAIN_FORM ; 0
  const TENTACOOL_RB_FORM    ; 1 -- its Red/Blue sprite
DEF NUM_TENTACOOL_FORMS EQU const_value ; 2

; Tentacruel forms
  const_def 0 ; Note that forms are now 0-indexed
  const TENTACRUEL_PLAIN_FORM ; 0
  const TENTACRUEL_RB_FORM    ; 1 -- its Red/Blue sprite
DEF NUM_TENTACRUEL_FORMS EQU const_value ; 2

; Igglybuff forms
  const_def 0 ; Note that forms are now 0-indexed
  const IGGLYBUFF_PLAIN_FORM ; 0
  const IGGLYBUFF_BETA_FORM  ; 1 -- its Spaceworld beta sprite, numbered with the line's RB form
DEF NUM_IGGLYBUFF_FORMS EQU const_value ; 2

; Jigglypuff forms
  const_def 0 ; Note that forms are now 0-indexed
  const JIGGLYPUFF_PLAIN_FORM ; 0
  const JIGGLYPUFF_RB_FORM    ; 1 -- its Red/Blue sprite
DEF NUM_JIGGLYPUFF_FORMS EQU const_value ; 2

; Wigglytuff forms
  const_def 0 ; Note that forms are now 0-indexed
  const WIGGLYTUFF_PLAIN_FORM ; 0
  const WIGGLYTUFF_RB_FORM    ; 1 -- its Red/Blue sprite
DEF NUM_WIGGLYTUFF_FORMS EQU const_value ; 2

; Nidoran♂ forms
  const_def 0 ; Note that forms are now 0-indexed
  const NIDORAN_M_PLAIN_FORM ; 0
  const NIDORAN_M_RB_FORM    ; 1 -- its Red/Blue sprite
DEF NUM_NIDORAN_M_FORMS EQU const_value ; 2

; Nidorino forms
  const_def 0 ; Note that forms are now 0-indexed
  const NIDORINO_PLAIN_FORM ; 0
  const NIDORINO_RB_FORM    ; 1 -- its Red/Blue sprite
DEF NUM_NIDORINO_FORMS EQU const_value ; 2

; Nidoking forms
  const_def 0 ; Note that forms are now 0-indexed
  const NIDOKING_PLAIN_FORM ; 0
  const NIDOKING_RB_FORM    ; 1 -- its Red/Blue sprite
DEF NUM_NIDOKING_FORMS EQU const_value ; 2

; Nidoran♀ forms
  const_def 0 ; Note that forms are now 0-indexed
  const NIDORAN_F_PLAIN_FORM ; 0
  const NIDORAN_F_RB_FORM    ; 1 -- its Red/Blue sprite
DEF NUM_NIDORAN_F_FORMS EQU const_value ; 2

; Nidorina forms
  const_def 0 ; Note that forms are now 0-indexed
  const NIDORINA_PLAIN_FORM ; 0
  const NIDORINA_RB_FORM    ; 1 -- its Red/Blue sprite
DEF NUM_NIDORINA_FORMS EQU const_value ; 2

; Nidoqueen forms
  const_def 0 ; Note that forms are now 0-indexed
  const NIDOQUEEN_PLAIN_FORM ; 0
  const NIDOQUEEN_RB_FORM    ; 1 -- its Red/Blue sprite
DEF NUM_NIDOQUEEN_FORMS EQU const_value ; 2

; Zubat forms
; Numbered in parallel with Golbat's and Crobat's, so an RB Zubat stays RB when it evolves
  const_def 0 ; Note that forms are now 0-indexed
  const ZUBAT_PLAIN_FORM  ; 0
  const ZUBAT_UNUSED_FORM ; 1 -- looks plain; holds the Rocket number
  const ZUBAT_RB_FORM     ; 2 -- its Red/Blue sprite
DEF NUM_ZUBAT_FORMS EQU const_value ; 3

; Geodude forms
  const_def 0 ; Note that forms are now 0-indexed
  const GEODUDE_PLAIN_FORM ; 0
  const GEODUDE_RB_FORM    ; 1 -- its Red/Blue sprite
DEF NUM_GEODUDE_FORMS EQU const_value ; 2

; Graveler forms
  const_def 0 ; Note that forms are now 0-indexed
  const GRAVELER_PLAIN_FORM ; 0
  const GRAVELER_RB_FORM    ; 1 -- its Red/Blue sprite
DEF NUM_GRAVELER_FORMS EQU const_value ; 2

; Golem forms
  const_def 0 ; Note that forms are now 0-indexed
  const GOLEM_PLAIN_FORM ; 0
  const GOLEM_RB_FORM    ; 1 -- its Red/Blue sprite
DEF NUM_GOLEM_FORMS EQU const_value ; 2

; Shellder forms
  const_def 0 ; Note that forms are now 0-indexed
  const SHELLDER_PLAIN_FORM ; 0
  const SHELLDER_RB_FORM    ; 1 -- its Red/Blue sprite
DEF NUM_SHELLDER_FORMS EQU const_value ; 2

; Cloyster forms
  const_def 0 ; Note that forms are now 0-indexed
  const CLOYSTER_PLAIN_FORM ; 0
  const CLOYSTER_RB_FORM    ; 1 -- its Red/Blue sprite
DEF NUM_CLOYSTER_FORMS EQU const_value ; 2

; Gastly forms
  const_def 0 ; Note that forms are now 0-indexed
  const GASTLY_PLAIN_FORM ; 0
  const GASTLY_RB_FORM    ; 1 -- its Red/Blue sprite
DEF NUM_GASTLY_FORMS EQU const_value ; 2

; Haunter forms
  const_def 0 ; Note that forms are now 0-indexed
  const HAUNTER_PLAIN_FORM ; 0
  const HAUNTER_RB_FORM    ; 1 -- its Red/Blue sprite
DEF NUM_HAUNTER_FORMS EQU const_value ; 2

; Gengar forms
  const_def 0 ; Note that forms are now 0-indexed
  const GENGAR_PLAIN_FORM ; 0
  const GENGAR_RB_FORM    ; 1 -- its Red/Blue sprite
DEF NUM_GENGAR_FORMS EQU const_value ; 2

; Koffing forms
; Numbered in parallel with Weezing's, so an RB Koffing stays RB when it evolves
  const_def 0 ; Note that forms are now 0-indexed
  const KOFFING_PLAIN_FORM  ; 0
  const KOFFING_UNUSED_FORM ; 1 -- looks plain; holds the Rocket number
  const KOFFING_RB_FORM     ; 2 -- its Red/Blue sprite
DEF NUM_KOFFING_FORMS EQU const_value ; 3

; Horsea forms
  const_def 0 ; Note that forms are now 0-indexed
  const HORSEA_PLAIN_FORM ; 0
  const HORSEA_RB_FORM    ; 1 -- its Red/Blue sprite
DEF NUM_HORSEA_FORMS EQU const_value ; 2

; Seadra forms
  const_def 0 ; Note that forms are now 0-indexed
  const SEADRA_PLAIN_FORM ; 0
  const SEADRA_RB_FORM    ; 1 -- its Red/Blue sprite
DEF NUM_SEADRA_FORMS EQU const_value ; 2

; Kingdra forms
  const_def 0 ; Note that forms are now 0-indexed
  const KINGDRA_PLAIN_FORM ; 0
  const KINGDRA_BETA_FORM  ; 1 -- its Spaceworld beta sprite, numbered with the line's RB form
DEF NUM_KINGDRA_FORMS EQU const_value ; 2

; Psyduck forms
  const_def 0 ; Note that forms are now 0-indexed
  const PSYDUCK_PLAIN_FORM ; 0
  const PSYDUCK_RB_FORM    ; 1 -- its Red/Blue sprite
DEF NUM_PSYDUCK_FORMS EQU const_value ; 2

; Golduck forms
  const_def 0 ; Note that forms are now 0-indexed
  const GOLDUCK_PLAIN_FORM ; 0
  const GOLDUCK_RB_FORM    ; 1 -- its Red/Blue sprite
DEF NUM_GOLDUCK_FORMS EQU const_value ; 2

; Gyarados forms
; Numbered in parallel with Magikarp's, so an RB Magikarp stays RB when it evolves
  const_def 0 ; Note that forms are now 0-indexed
  const GYARADOS_PLAIN_FORM ; 0
  const GYARADOS_XS_FORM    ; 1 -- looks plain; what an Extra Small Magikarp evolves into
  const GYARADOS_XL_FORM    ; 2 -- looks plain; what an Extra Large Magikarp evolves into
  const GYARADOS_RB_FORM    ; 3 -- its Red/Blue sprite
DEF NUM_GYARADOS_FORMS EQU const_value ; 4

; Staryu forms
  const_def 0 ; Note that forms are now 0-indexed
  const STARYU_PLAIN_FORM ; 0
  const STARYU_RB_FORM    ; 1 -- its Red/Blue sprite
DEF NUM_STARYU_FORMS EQU const_value ; 2

; Starmie forms
  const_def 0 ; Note that forms are now 0-indexed
  const STARMIE_PLAIN_FORM ; 0
  const STARMIE_RB_FORM    ; 1 -- its Red/Blue sprite
DEF NUM_STARMIE_FORMS EQU const_value ; 2

; Arbok forms
  const_def 0 ; Note that forms are now 0-indexed
  const ARBOK_PLAIN_FORM  ; 0
  const ARBOK_ROCKET_FORM ; 1 -- Team Rocket's; every Rocket Arbok is one
DEF NUM_ARBOK_FORMS EQU const_value ; 2

; Golbat forms
  const_def 0 ; Note that forms are now 0-indexed
  const GOLBAT_PLAIN_FORM   ; 0
  const GOLBAT_ROCKET_FORM  ; 1 -- Team Rocket's; every Rocket Golbat is one
  const GOLBAT_RB_FORM      ; 2 -- its Red/Blue sprite
DEF NUM_GOLBAT_FORMS EQU const_value ; 3

; Snorlax forms
  const_def 0 ; Note that forms are now 0-indexed
  const SNORLAX_PLAIN_FORM    ; 0
  const SNORLAX_APRICORN_FORM ; 1 -- the one asleep in the Apricorn Forest clearing
DEF NUM_SNORLAX_FORMS EQU const_value ; 2

; Shuckle forms
  const_def 0 ; Note that forms are now 0-indexed
  const SHUCKLE_PLAIN_FORM    	    ; 0
  const SHUCKLE_SHUCKIE_NEUTRAL_FORM ; 1
  const SHUCKLE_SHUCKIE_HAPPY_FORM   ; 2
DEF NUM_SHUCKLE_FORMS EQU const_value ; 3

; Magikarp forms
  const_def 0 ; Note that forms are now 0-indexed
  const MAGIKARP_PLAIN_FORM	; 0
  const MAGIKARP_XS_FORM	; 1
  const MAGIKARP_XL_FORM   	; 2
  const MAGIKARP_RB_FORM	; 3 -- its Red/Blue sprite
DEF NUM_MAGIKARP_FORMS EQU const_value ; 4

; Smeargle forms
  const_def 0 ; Note that forms are now 0-indexed
  const SMEARGLE_PLAIN_FORM	; 0
  const SMEARGLE_BLUE_FORM	; 1
  const SMEARGLE_YELLOW_FORM	; 2
  const SMEARGLE_PURPLE_FORM	; 3
  const SMEARGLE_GREEN_FORM	; 4
  const SMEARGLE_ORANGE_FORM	; 5
DEF NUM_SMEARGLE_FORMS EQU const_value ; 6
DEF NUM_SMEARGLE_WILD_FORMS EQU 3 ; Wild Smeargle only get first 3 forms

; Scyther forms
  const_def 0 ; Note that forms are now 0-indexed
  const SCYTHER_PLAIN_FORM		; 0
  const SCYTHER_FOREST_GREEN_FORM	; 1
  const SCYTHER_TEAL_FORM		; 2
DEF NUM_SCYTHER_FORMS EQU const_value 	; 3
DEF NUM_SCYTHER_WILD_FORMS EQU 3

; Scizor forms
  const_def 0 ; Note that forms are now 0-indexed
  const SCIZOR_PLAIN_FORM	; 0
  const SCIZOR_CRIMSON_FORM	; 1
  const SCIZOR_DUSTY_ROSE_FORM	; 2
DEF NUM_SCIZOR_FORMS EQU const_value ; 3

; Pinsir forms
  const_def 0 ; Note that forms are now 0-indexed
  const PINSIR_PLAIN_FORM	; 0
  const PINSIR_VINE_FORM	; 1
  const PINSIR_SLATE_FORM	; 2
DEF NUM_PINSIR_FORMS EQU const_value ; 3

; Egg patterns: which egg graphics an egg is drawn with, picked by the species inside (see
; SpecialEggPatterns). A pattern stands where a form number would in the EGG rows of the cosmetic
; tables, so it must fit in FORM_MASK.
  const_def 0
  const EGG_PLAIN_PATTERN  ; 0
  const EGG_ELEKID_PATTERN ; 1
DEF NUM_EGG_PATTERNS EQU const_value ; 2
