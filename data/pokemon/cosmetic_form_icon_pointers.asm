; Master table for Pokemon icon pointers
; Each entry corresponds to a Pokemon species (indexed by species ID)
; Entries for Pokemon with cosmetic forms point to their form-specific pointer tables
; Entries for Pokemon without cosmetic forms are null (0)
	dw EggIconPointers			; EGG - each egg pattern has its own icon
	dw 0					; NULL
	dw 0					; NULL
	dw 0					; NULL
CosmeticFormIconPointersTable:
	table_width 2
	dw 0					; BULBASAUR (01) - no cosmetic forms
	dw 0					; IVYSAUR (02) - no cosmetic forms
	dw 0					; VENUSAUR (03) - no cosmetic forms
	dw 0					; CHARMANDER (04) - no cosmetic forms
	dw 0					; CHARMELEON (05) - no cosmetic forms
	dw 0					; CHARIZARD (06) - no cosmetic forms
	dw 0					; SQUIRTLE (07) - no cosmetic forms
	dw 0					; WARTORTLE (08) - no cosmetic forms
	dw 0					; BLASTOISE (09) - no cosmetic forms
	dw 0					; CATERPIE (0a) - no cosmetic forms
	dw 0					; METAPOD (0b) - no cosmetic forms
	dw 0					; BUTTERFREE (0c) - no cosmetic forms
	dw 0					; WEEDLE (0d) - no cosmetic forms
	dw 0					; KAKUNA (0e) - no cosmetic forms
	dw 0					; BEEDRILL (0f) - no cosmetic forms
	dw 0					; PIDGEY (10) - no cosmetic forms
	dw 0					; PIDGEOTTO (11) - no cosmetic forms
	dw 0					; PIDGEOT (12) - no cosmetic forms
	dw 0					; RATTATA (13) - no cosmetic forms
	dw 0					; RATICATE (14) - no cosmetic forms
	dw 0					; SPEAROW (15) - no cosmetic forms
	dw 0					; FEAROW (16) - no cosmetic forms
	dw 0					; EKANS (17) - no cosmetic forms
	dw 0					; ARBOK (18) - no cosmetic forms
	dw PikachuIconPointers			; PIKACHU (19) - has cosmetic forms
	dw 0					; RAICHU (1a) - no cosmetic forms
	dw 0					; SANDSHREW (1b) - no cosmetic forms
	dw 0					; SANDSLASH (1c) - no cosmetic forms
	dw 0					; NIDORAN_F (1d) - no cosmetic forms
	dw 0					; NIDORINA (1e) - no cosmetic forms
	dw 0					; NIDOQUEEN (1f) - no cosmetic forms
	dw 0					; NIDORAN_M (20) - no cosmetic forms
	dw 0					; NIDORINO (21) - no cosmetic forms
	dw 0					; NIDOKING (22) - no cosmetic forms
	dw 0					; CLEFAIRY (23) - no cosmetic forms
	dw 0					; CLEFABLE (24) - no cosmetic forms
	dw 0					; VULPIX (25) - no cosmetic forms
	dw 0					; NINETALES (26) - no cosmetic forms
	dw 0					; JIGGLYPUFF (27) - no cosmetic forms
	dw 0					; WIGGLYTUFF (28) - no cosmetic forms
	dw 0					; ZUBAT (29) - no cosmetic forms
	dw 0					; GOLBAT (2a) - no cosmetic forms
	dw 0					; ODDISH (2b) - no cosmetic forms
	dw 0					; GLOOM (2c) - no cosmetic forms
	dw 0					; VILEPLUME (2d) - no cosmetic forms
	dw 0					; PARAS (2e) - no cosmetic forms
	dw 0					; PARASECT (2f) - no cosmetic forms
	dw 0					; VENONAT (30) - no cosmetic forms
	dw 0					; VENOMOTH (31) - no cosmetic forms
	dw 0					; DIGLETT (32) - no cosmetic forms
	dw 0					; DUGTRIO (33) - no cosmetic forms
	dw 0					; MEOWTH (34) - no cosmetic forms
	dw 0					; PERSIAN (35) - no cosmetic forms
	dw 0					; PSYDUCK (36) - no cosmetic forms
	dw 0					; GOLDUCK (37) - no cosmetic forms
	dw 0					; MANKEY (38) - no cosmetic forms
	dw 0					; PRIMEAPE (39) - no cosmetic forms
	dw 0					; GROWLITHE (3a) - no cosmetic forms
	dw 0					; ARCANINE (3b) - no cosmetic forms
	dw 0					; POLIWAG (3c) - no cosmetic forms
	dw 0					; POLIWHIRL (3d) - no cosmetic forms
	dw 0					; POLIWRATH (3e) - no cosmetic forms
	dw 0					; ABRA (3f) - no cosmetic forms
	dw 0					; KADABRA (40) - no cosmetic forms
	dw 0					; ALAKAZAM (41) - no cosmetic forms
	dw 0					; MACHOP (42) - RB form reuses the species icon
	dw 0					; MACHOKE (43) - RB form reuses the species icon
	dw 0					; MACHAMP (44) - RB form reuses the species icon
	dw 0					; BELLSPROUT (45) - no cosmetic forms
	dw 0					; WEEPINBELL (46) - no cosmetic forms
	dw 0					; VICTREEBEL (47) - no cosmetic forms
	dw 0					; TENTACOOL (48) - RB form reuses the species icon
	dw 0					; TENTACRUEL (49) - RB form reuses the species icon
	dw 0					; GEODUDE (4a) - no cosmetic forms
	dw 0					; GRAVELER (4b) - no cosmetic forms
	dw 0					; GOLEM (4c) - no cosmetic forms
	dw 0					; PONYTA (4d) - no cosmetic forms
	dw 0					; RAPIDASH (4e) - no cosmetic forms
	dw 0					; SLOWPOKE (4f) - no cosmetic forms
	dw 0					; SLOWBRO (50) - no cosmetic forms
	dw 0					; MAGNEMITE (51) - no cosmetic forms
	dw 0					; MAGNETON (52) - no cosmetic forms
	dw 0					; FARFETCHD (53) - no cosmetic forms
	dw 0					; DODUO (54) - no cosmetic forms
	dw 0					; DODRIO (55) - no cosmetic forms
	dw 0					; SEEL (56) - no cosmetic forms
	dw 0					; DEWGONG (57) - no cosmetic forms
	dw 0					; GRIMER (58) - no cosmetic forms
	dw 0					; MUK (59) - no cosmetic forms
	dw 0					; SHELLDER (5a) - no cosmetic forms
	dw 0					; CLOYSTER (5b) - no cosmetic forms
	dw 0					; GASTLY (5c) - no cosmetic forms
	dw 0					; HAUNTER (5d) - no cosmetic forms
	dw 0					; GENGAR (5e) - no cosmetic forms
	dw 0					; ONIX (5f) - no cosmetic forms
	dw 0					; DROWZEE (60) - no cosmetic forms
	dw 0					; HYPNO (61) - no cosmetic forms
	dw 0					; KRABBY (62) - no cosmetic forms
	dw 0					; KINGLER (63) - no cosmetic forms
	dw 0					; VOLTORB (64) - no cosmetic forms
	dw 0					; ELECTRODE (65) - no cosmetic forms
	dw 0					; EXEGGCUTE (66) - no cosmetic forms
	dw 0					; EXEGGUTOR (67) - no cosmetic forms
	dw 0					; CUBONE (68) - no cosmetic forms
	dw 0					; MAROWAK (69) - no cosmetic forms
	dw 0					; HITMONLEE (6a) - no cosmetic forms
	dw 0					; HITMONCHAN (6b) - no cosmetic forms
	dw 0					; LICKITUNG (6c) - no cosmetic forms
	dw 0					; KOFFING (6d) - no cosmetic forms
	dw 0					; WEEZING (6e) - no cosmetic forms
	dw 0					; RHYHORN (6f) - no cosmetic forms
	dw 0					; RHYDON (70) - no cosmetic forms
	dw 0					; CHANSEY (71) - no cosmetic forms
	dw 0					; TANGELA (72) - no cosmetic forms
	dw 0					; KANGASKHAN (73) - no cosmetic forms
	dw 0					; HORSEA (74) - no cosmetic forms
	dw 0					; SEADRA (75) - no cosmetic forms
	dw 0					; GOLDEEN (76) - no cosmetic forms
	dw 0					; SEAKING (77) - no cosmetic forms
	dw 0					; STARYU (78) - no cosmetic forms
	dw 0					; STARMIE (79) - no cosmetic forms
	dw 0					; MR__MIME (7a) - no cosmetic forms
	dw 0					; SCYTHER (7b) - no cosmetic forms
	dw 0					; JYNX (7c) - no cosmetic forms
	dw 0					; ELECTABUZZ (7d) - no cosmetic forms
	dw 0					; MAGMAR (7e) - no cosmetic forms
	dw 0					; PINSIR (7f) - no cosmetic forms
	dw 0					; TAUROS (80) - no cosmetic forms
	dw 0					; MAGIKARP (81) - has cosmetic forms, but does not require icon variants
	dw 0					; GYARADOS (82) - no cosmetic forms
	dw 0					; LAPRAS (83) - no cosmetic forms
	dw 0					; DITTO (84) - no cosmetic forms
	dw 0					; EEVEE (85) - no cosmetic forms
	dw 0					; VAPOREON (86) - no cosmetic forms
	dw 0					; JOLTEON (87) - no cosmetic forms
	dw 0					; FLAREON (88) - no cosmetic forms
	dw 0					; PORYGON (89) - no cosmetic forms
	dw 0					; OMANYTE (8a) - no cosmetic forms
	dw 0					; OMASTAR (8b) - no cosmetic forms
	dw 0					; KABUTO (8c) - no cosmetic forms
	dw 0					; KABUTOPS (8d) - no cosmetic forms
	dw 0					; AERODACTYL (8e) - no cosmetic forms
	dw SnorlaxIconPointers			; SNORLAX (8f) - has cosmetic forms
	dw 0					; ARTICUNO (90) - no cosmetic forms
	dw 0					; ZAPDOS (91) - no cosmetic forms
	dw 0					; MOLTRES (92) - no cosmetic forms
	dw 0					; DRATINI (93) - no cosmetic forms
	dw 0					; DRAGONAIR (94) - no cosmetic forms
	dw 0					; DRAGONITE (95) - no cosmetic forms
	dw 0					; MEWTWO (96) - no cosmetic forms
	dw 0					; MEW (97) - no cosmetic forms
	dw 0					; CHIKORITA (98) - no cosmetic forms
	dw 0					; BAYLEEF (99) - no cosmetic forms
	dw 0					; MEGANIUM (9a) - no cosmetic forms
	dw 0					; CYNDAQUIL (9b) - no cosmetic forms
	dw 0					; QUILAVA (9c) - no cosmetic forms
	dw 0					; TYPHLOSION (9d) - no cosmetic forms
	dw 0					; TOTODILE (9e) - no cosmetic forms
	dw 0					; CROCONAW (9f) - no cosmetic forms
	dw 0					; FERALIGATR (a0) - no cosmetic forms
	dw 0					; SENTRET (a1) - no cosmetic forms
	dw 0					; FURRET (a2) - no cosmetic forms
	dw 0					; HOOTHOOT (a3) - no cosmetic forms
	dw 0					; NOCTOWL (a4) - no cosmetic forms
	dw 0					; LEDYBA (a5) - no cosmetic forms
	dw 0					; LEDIAN (a6) - no cosmetic forms
	dw 0					; SPINARAK (a7) - no cosmetic forms
	dw 0					; ARIADOS (a8) - no cosmetic forms
	dw 0					; CROBAT (a9) - no cosmetic forms
	dw 0					; CHINCHOU (aa) - no cosmetic forms
	dw 0					; LANTURN (ab) - no cosmetic forms
	dw 0					; PICHU (ac) - no cosmetic forms
	dw 0					; CLEFFA (ad) - no cosmetic forms
	dw IgglybuffIconPointers		; IGGLYBUFF (ae) - has cosmetic forms
	dw 0					; TOGEPI (af) - no cosmetic forms
	dw 0					; TOGETIC (b0) - no cosmetic forms
	dw 0					; NATU (b1) - no cosmetic forms
	dw 0					; XATU (b2) - no cosmetic forms
	dw 0					; MAREEP (b3) - no cosmetic forms
	dw 0					; FLAAFFY (b4) - no cosmetic forms
	dw 0					; AMPHAROS (b5) - no cosmetic forms
	dw 0					; BELLOSSOM (b6) - no cosmetic forms
	dw 0					; MARILL (b7) - no cosmetic forms
	dw 0					; AZUMARILL (b8) - no cosmetic forms
	dw 0					; SUDOWOODO (b9) - no cosmetic forms
	dw 0					; POLITOED (ba) - no cosmetic forms
	dw 0					; HOPPIP (bb) - no cosmetic forms
	dw 0					; SKIPLOOM (bc) - no cosmetic forms
	dw 0					; JUMPLUFF (bd) - no cosmetic forms
	dw 0					; AIPOM (be) - no cosmetic forms
	dw 0					; SUNKERN (bf) - no cosmetic forms
	dw 0					; SUNFLORA (c0) - no cosmetic forms
	dw 0					; YANMA (c1) - no cosmetic forms
	dw 0					; WOOPER (c2) - no cosmetic forms
	dw 0					; QUAGSIRE (c3) - no cosmetic forms
	dw 0					; ESPEON (c4) - no cosmetic forms
	dw 0					; UMBREON (c5) - no cosmetic forms
	dw 0					; MURKROW (c6) - no cosmetic forms
	dw 0					; SLOWKING (c7) - no cosmetic forms
	dw 0					; MISDREAVUS (c8) - no cosmetic forms
	dw UnownIconPointers			; UNOWN (c9) - has cosmetic forms
	dw 0					; WOBBUFFET (ca) - no cosmetic forms
	dw 0					; GIRAFARIG (cb) - no cosmetic forms
	dw 0					; PINECO (cc) - no cosmetic forms
	dw 0					; FORRETRESS (cd) - no cosmetic forms
	dw 0					; DUNSPARCE (ce) - no cosmetic forms
	dw 0					; GLIGAR (cf) - no cosmetic forms
	dw 0					; STEELIX (d0) - no cosmetic forms
	dw 0					; SNUBBULL (d1) - no cosmetic forms
	dw 0					; GRANBULL (d2) - no cosmetic forms
	dw 0					; QWILFISH (d3) - no cosmetic forms
	dw 0					; SCIZOR (d4) - no cosmetic forms
	dw 0					; SHUCKLE (d5) - has cosmetic forms, but does not require icon variants
	dw 0					; HERACROSS (d6) - no cosmetic forms
	dw 0					; SNEASEL (d7) - no cosmetic forms
	dw 0					; TEDDIURSA (d8) - no cosmetic forms
	dw 0					; URSARING (d9) - no cosmetic forms
	dw 0					; SLUGMA (da) - no cosmetic forms
	dw 0					; MAGCARGO (db) - no cosmetic forms
	dw 0					; SWINUB (dc) - no cosmetic forms
	dw 0					; PILOSWINE (dd) - no cosmetic forms
	dw 0					; CORSOLA (de) - no cosmetic forms
	dw 0					; REMORAID (df) - no cosmetic forms
	dw 0					; OCTILLERY (e0) - no cosmetic forms
	dw 0					; DELIBIRD (e1) - no cosmetic forms
	dw 0					; MANTINE (e2) - no cosmetic forms
	dw 0					; SKARMORY (e3) - no cosmetic forms
	dw 0					; HOUNDOUR (e4) - no cosmetic forms
	dw 0					; HOUNDOOM (e5) - no cosmetic forms
	dw 0					; KINGDRA (e6) - no cosmetic forms
	dw 0					; PHANPY (e7) - no cosmetic forms
	dw 0					; DONPHAN (e8) - no cosmetic forms
	dw 0					; PORYGON2 (e9) - no cosmetic forms
	dw 0					; STANTLER (ea) - no cosmetic forms
	dw 0					; SMEARGLE (eb) - no cosmetic forms
	dw 0					; TYROGUE (ec) - no cosmetic forms
	dw 0					; HITMONTOP (ed) - no cosmetic forms
	dw 0					; SMOOCHUM (ee) - no cosmetic forms
	dw 0					; ELEKID (ef) - no cosmetic forms
	dw 0					; MAGBY (f0) - no cosmetic forms
	dw 0					; MILTANK (f1) - no cosmetic forms
	dw 0					; BLISSEY (f2) - no cosmetic forms
	dw 0					; RAIKOU (f3) - no cosmetic forms
	dw 0					; ENTEI (f4) - no cosmetic forms
	dw 0					; SUICUNE (f5) - no cosmetic forms
	dw 0					; LARVITAR (f6) - no cosmetic forms
	dw 0					; PUPITAR (f7) - no cosmetic forms
	dw 0					; TYRANITAR (f8) - no cosmetic forms
	dw 0					; LUGIA (f9) - no cosmetic forms
	dw 0					; HO_OH (fa) - no cosmetic forms
	dw 0					; CELEBI (fb) - no cosmetic forms
	assert_table_length NUM_POKEMON

PikachuIconPointers:
	table_width 2, PikachuIconPointers
	dw PikachuPlainIcon
	dw PikachuSurfIcon
	dw PikachuFlyIcon
	dw PikachuPlainIcon
	assert_table_length NUM_PIKACHU_FORMS

SnorlaxIconPointers:
	table_width 2, SnorlaxIconPointers
	dw SnorlaxPlainIcon
	dw SnorlaxApricornIcon
	assert_table_length NUM_SNORLAX_FORMS

IgglybuffIconPointers:
	table_width 2, IgglybuffIconPointers
	dw IgglybuffPlainIcon
	dw IgglybuffBetaIcon
	assert_table_length NUM_IGGLYBUFF_FORMS

EggIconPointers:
; indexed by egg pattern (EGG_*_PATTERN), not by form
	table_width 2, EggIconPointers
	dw EggPlainIcon
	dw EggElekidIcon
	assert_table_length NUM_EGG_PATTERNS

UnownIconPointers:
	table_width 2, UnownIconPointers
	dw UnownAIcon
	dw UnownBIcon
	dw UnownCIcon
	dw UnownDIcon
	dw UnownEIcon
	dw UnownFIcon
	dw UnownGIcon
	dw UnownHIcon
	dw UnownIIcon
	dw UnownJIcon
	dw UnownKIcon
	dw UnownLIcon
	dw UnownMIcon
	dw UnownNIcon
	dw UnownOIcon
	dw UnownPIcon
	dw UnownQIcon
	dw UnownRIcon
	dw UnownSIcon
	dw UnownTIcon
	dw UnownUIcon
	dw UnownVIcon
	dw UnownWIcon
	dw UnownXIcon
	dw UnownYIcon
	dw UnownZIcon
	assert_table_length NUM_UNOWN



