; Master table for Pokemon animation pointers
; Each entry corresponds to a Pokemon species (indexed by species ID)
; Entries for Pokemon with cosmetic forms point to their form-specific pointer tables
; Entries for Pokemon without cosmetic forms are null (0)
	dw 0					; EGG
	dw 0					; NULL
	dw 0					; NULL
	dw 0					; NULL
CosmeticFormAnimationPointerTable:
	table_width 2
	dw 0					; BULBASAUR (01) - no cosmetic forms
	dw 0					; IVYSAUR (02) - no cosmetic forms
	dw 0					; VENUSAUR (03) - no cosmetic forms
	dw 0					; CHARMANDER (04) - no cosmetic forms
	dw CharmeleonAnimationPointers		; CHARMELEON (05) - has cosmetic forms
	dw CharizardAnimationPointers		; CHARIZARD (06) - has cosmetic forms
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
	dw ArbokAnimationPointers		; ARBOK (18) - has cosmetic forms
	dw PikachuAnimationPointers		; PIKACHU (19) - has cosmetic forms
	dw RaichuAnimationPointers		; RAICHU (1a) - has cosmetic forms
	dw 0					; SANDSHREW (1b) - no cosmetic forms
	dw 0					; SANDSLASH (1c) - no cosmetic forms
	dw NidoranFAnimationPointers		; NIDORAN_F (1d) - has cosmetic forms
	dw NidorinaAnimationPointers		; NIDORINA (1e) - has cosmetic forms
	dw NidoqueenAnimationPointers		; NIDOQUEEN (1f) - has cosmetic forms
	dw NidoranMAnimationPointers		; NIDORAN_M (20) - has cosmetic forms
	dw NidorinoAnimationPointers		; NIDORINO (21) - has cosmetic forms
	dw NidokingAnimationPointers		; NIDOKING (22) - has cosmetic forms
	dw 0					; CLEFAIRY (23) - no cosmetic forms
	dw 0					; CLEFABLE (24) - no cosmetic forms
	dw 0					; VULPIX (25) - no cosmetic forms
	dw 0					; NINETALES (26) - no cosmetic forms
	dw JigglypuffAnimationPointers		; JIGGLYPUFF (27) - has cosmetic forms
	dw WigglytuffAnimationPointers		; WIGGLYTUFF (28) - has cosmetic forms
	dw ZubatAnimationPointers		; ZUBAT (29) - has cosmetic forms
	dw GolbatAnimationPointers		; GOLBAT (2a) - has cosmetic forms
	dw 0					; ODDISH (2b) - no cosmetic forms
	dw 0					; GLOOM (2c) - no cosmetic forms
	dw 0					; VILEPLUME (2d) - no cosmetic forms
	dw 0					; PARAS (2e) - no cosmetic forms
	dw 0					; PARASECT (2f) - no cosmetic forms
	dw VenonatAnimationPointers	; VENONAT (30) - has cosmetic forms
	dw VenomothAnimationPointers	; VENOMOTH (31) - has cosmetic forms
	dw 0					; DIGLETT (32) - no cosmetic forms
	dw 0					; DUGTRIO (33) - no cosmetic forms
	dw 0					; MEOWTH (34) - no cosmetic forms
	dw 0					; PERSIAN (35) - no cosmetic forms
	dw PsyduckAnimationPointers		; PSYDUCK (36) - has cosmetic forms
	dw GolduckAnimationPointers		; GOLDUCK (37) - has cosmetic forms
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
	dw MachopAnimationPointers		; MACHOP (42) - has cosmetic forms
	dw MachokeAnimationPointers		; MACHOKE (43) - has cosmetic forms
	dw MachampAnimationPointers		; MACHAMP (44) - has cosmetic forms
	dw 0					; BELLSPROUT (45) - no cosmetic forms
	dw 0					; WEEPINBELL (46) - no cosmetic forms
	dw 0					; VICTREEBEL (47) - no cosmetic forms
	dw TentacoolAnimationPointers		; TENTACOOL (48) - has cosmetic forms
	dw TentacruelAnimationPointers		; TENTACRUEL (49) - has cosmetic forms
	dw GeodudeAnimationPointers		; GEODUDE (4a) - has cosmetic forms
	dw GravelerAnimationPointers		; GRAVELER (4b) - has cosmetic forms
	dw GolemAnimationPointers		; GOLEM (4c) - has cosmetic forms
	dw 0					; PONYTA (4d) - no cosmetic forms
	dw 0					; RAPIDASH (4e) - no cosmetic forms
	dw 0					; SLOWPOKE (4f) - no cosmetic forms
	dw 0					; SLOWBRO (50) - no cosmetic forms
	dw 0					; MAGNEMITE (51) - no cosmetic forms
	dw 0					; MAGNETON (52) - no cosmetic forms
	dw FarfetchDAnimationPointers	; FARFETCHD (53) - has cosmetic forms
	dw 0					; DODUO (54) - no cosmetic forms
	dw 0					; DODRIO (55) - no cosmetic forms
	dw 0					; SEEL (56) - no cosmetic forms
	dw 0					; DEWGONG (57) - no cosmetic forms
	dw 0					; GRIMER (58) - no cosmetic forms
	dw 0					; MUK (59) - no cosmetic forms
	dw ShellderAnimationPointers		; SHELLDER (5a) - has cosmetic forms
	dw CloysterAnimationPointers		; CLOYSTER (5b) - has cosmetic forms
	dw GastlyAnimationPointers		; GASTLY (5c) - has cosmetic forms
	dw HaunterAnimationPointers		; HAUNTER (5d) - has cosmetic forms
	dw GengarAnimationPointers		; GENGAR (5e) - has cosmetic forms
	dw 0					; ONIX (5f) - no cosmetic forms
	dw 0					; DROWZEE (60) - no cosmetic forms
	dw 0					; HYPNO (61) - no cosmetic forms
	dw 0					; KRABBY (62) - no cosmetic forms
	dw 0					; KINGLER (63) - no cosmetic forms
	dw 0					; VOLTORB (64) - no cosmetic forms
	dw ElectrodeAnimationPointers		; ELECTRODE (65) - has cosmetic forms
	dw ExeggcuteAnimationPointers	; EXEGGCUTE (66) - has cosmetic forms
	dw ExeggutorAnimationPointers	; EXEGGUTOR (67) - has cosmetic forms
	dw CuboneAnimationPointers	; CUBONE (68) - has cosmetic forms
	dw MarowakAnimationPointers	; MAROWAK (69) - has cosmetic forms
	dw 0					; HITMONLEE (6a) - no cosmetic forms
	dw 0					; HITMONCHAN (6b) - no cosmetic forms
	dw 0					; LICKITUNG (6c) - no cosmetic forms
	dw KoffingAnimationPointers		; KOFFING (6d) - has cosmetic forms
	dw WeezingAnimationPointers		; WEEZING (6e) - has cosmetic forms
	dw RhyhornAnimationPointers	; RHYHORN (6f) - has cosmetic forms
	dw RhydonAnimationPointers	; RHYDON (70) - has cosmetic forms
	dw 0					; CHANSEY (71) - no cosmetic forms
	dw 0					; TANGELA (72) - no cosmetic forms
	dw KangaskhanAnimationPointers	; KANGASKHAN (73) - has cosmetic forms
	dw HorseaAnimationPointers		; HORSEA (74) - has cosmetic forms
	dw SeadraAnimationPointers		; SEADRA (75) - has cosmetic forms
	dw 0					; GOLDEEN (76) - no cosmetic forms
	dw 0					; SEAKING (77) - no cosmetic forms
	dw StaryuAnimationPointers		; STARYU (78) - has cosmetic forms
	dw StarmieAnimationPointers		; STARMIE (79) - has cosmetic forms
	dw 0					; MR__MIME (7a) - no cosmetic forms
	dw 0					; SCYTHER (7b) - no cosmetic forms
	dw 0					; JYNX (7c) - no cosmetic forms
	dw 0					; ELECTABUZZ (7d) - no cosmetic forms
	dw 0					; MAGMAR (7e) - no cosmetic forms
	dw 0					; PINSIR (7f) - no cosmetic forms
	dw 0					; TAUROS (80) - no cosmetic forms
	dw MagikarpAnimationPointers		; MAGIKARP (81) - has cosmetic forms
	dw GyaradosAnimationPointers		; GYARADOS (82) - has cosmetic forms
	dw LaprasAnimationPointers	; LAPRAS (83) - has cosmetic forms
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
	dw AerodactylAnimationPointers		; AERODACTYL (8e) - has cosmetic forms
	dw SnorlaxAnimationPointers		; SNORLAX (8f) - has cosmetic forms
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
	dw CrobatAnimationPointers		; CROBAT (a9) - has cosmetic forms
	dw 0					; CHINCHOU (aa) - no cosmetic forms
	dw 0					; LANTURN (ab) - no cosmetic forms
	dw PichuAnimationPointers		; PICHU (ac) - has cosmetic forms
	dw 0					; CLEFFA (ad) - no cosmetic forms
	dw IgglybuffAnimationPointers		; IGGLYBUFF (ae) - has cosmetic forms
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
	dw UnownAnimationPointers		; UNOWN (c9) - has cosmetic forms
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
	dw ShuckleAnimationPointers		; SHUCKLE (d5) - has cosmetic forms
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
	dw KingdraAnimationPointers		; KINGDRA (e6) - has cosmetic forms
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
	dw 0					; NEW_MON_1 (fc)
	dw 0					; NEW_MON_2 (fd)
	dw 0					; NEW_MON_3 (fe)
	dw 0					; NEW_MON_4 (ff)
	dw 0					; NEW_MON_5 (100)
	assert_table_length NUM_POKEMON

; Master table for Pokemon idle animation pointers  
CosmeticFormIdleAnimationPointers:
	table_width 2
	dw 0                           		; BULBASAUR (01) - no cosmetic forms
	dw 0                           		; IVYSAUR (02) - no cosmetic forms
	dw 0                           		; VENUSAUR (03) - no cosmetic forms
	dw 0                           		; CHARMANDER (04) - no cosmetic forms
	dw CharmeleonAnimationIdlePointers	; CHARMELEON (05) - has cosmetic forms
	dw CharizardAnimationIdlePointers	; CHARIZARD (06) - has cosmetic forms
	dw 0                           		; SQUIRTLE (07) - no cosmetic forms
	dw 0                           		; WARTORTLE (08) - no cosmetic forms
	dw 0                           		; BLASTOISE (09) - no cosmetic forms
	dw 0                           		; CATERPIE (0a) - no cosmetic forms
	dw 0                           		; METAPOD (0b) - no cosmetic forms
	dw 0                           		; BUTTERFREE (0c) - no cosmetic forms
	dw 0                           		; WEEDLE (0d) - no cosmetic forms
	dw 0                           		; KAKUNA (0e) - no cosmetic forms
	dw 0                           		; BEEDRILL (0f) - no cosmetic forms
	dw 0                           		; PIDGEY (10) - no cosmetic forms
	dw 0                           		; PIDGEOTTO (11) - no cosmetic forms
	dw 0                           		; PIDGEOT (12) - no cosmetic forms
	dw 0                           		; RATTATA (13) - no cosmetic forms
	dw 0                           		; RATICATE (14) - no cosmetic forms
	dw 0                           		; SPEAROW (15) - no cosmetic forms
	dw 0                           		; FEAROW (16) - no cosmetic forms
	dw 0                           		; EKANS (17) - no cosmetic forms
	dw ArbokAnimationIdlePointers		; ARBOK (18) - has cosmetic forms
	dw PikachuAnimationIdlePointers		; PIKACHU (19) - has cosmetic forms
	dw RaichuAnimationIdlePointers		; RAICHU (1a) - has cosmetic forms
	dw 0                           		; SANDSHREW (1b) - no cosmetic forms
	dw 0                           		; SANDSLASH (1c) - no cosmetic forms
	dw NidoranFAnimationIdlePointers		; NIDORAN_F (1d) - has cosmetic forms
	dw NidorinaAnimationIdlePointers		; NIDORINA (1e) - has cosmetic forms
	dw NidoqueenAnimationIdlePointers		; NIDOQUEEN (1f) - has cosmetic forms
	dw NidoranMAnimationIdlePointers		; NIDORAN_M (20) - has cosmetic forms
	dw NidorinoAnimationIdlePointers		; NIDORINO (21) - has cosmetic forms
	dw NidokingAnimationIdlePointers		; NIDOKING (22) - has cosmetic forms
	dw 0                           		; CLEFAIRY (23) - no cosmetic forms
	dw 0                           		; CLEFABLE (24) - no cosmetic forms
	dw 0                           		; VULPIX (25) - no cosmetic forms
	dw 0                           		; NINETALES (26) - no cosmetic forms
	dw JigglypuffAnimationIdlePointers		; JIGGLYPUFF (27) - has cosmetic forms
	dw WigglytuffAnimationIdlePointers		; WIGGLYTUFF (28) - has cosmetic forms
	dw ZubatAnimationIdlePointers		; ZUBAT (29) - has cosmetic forms
	dw GolbatAnimationIdlePointers		; GOLBAT (2a) - has cosmetic forms
	dw 0                           		; ODDISH (2b) - no cosmetic forms
	dw 0                           		; GLOOM (2c) - no cosmetic forms
	dw 0                           		; VILEPLUME (2d) - no cosmetic forms
	dw 0                           		; PARAS (2e) - no cosmetic forms
	dw 0                           		; PARASECT (2f) - no cosmetic forms
	dw VenonatAnimationIdlePointers	; VENONAT (30) - has cosmetic forms
	dw VenomothAnimationIdlePointers	; VENOMOTH (31) - has cosmetic forms
	dw 0                           		; DIGLETT (32) - no cosmetic forms
	dw 0                           		; DUGTRIO (33) - no cosmetic forms
	dw 0                           		; MEOWTH (34) - no cosmetic forms
	dw 0                           		; PERSIAN (35) - no cosmetic forms
	dw PsyduckAnimationIdlePointers		; PSYDUCK (36) - has cosmetic forms
	dw GolduckAnimationIdlePointers		; GOLDUCK (37) - has cosmetic forms
	dw 0                           		; MANKEY (38) - no cosmetic forms
	dw 0                           		; PRIMEAPE (39) - no cosmetic forms
	dw 0                           		; GROWLITHE (3a) - no cosmetic forms
	dw 0                           		; ARCANINE (3b) - no cosmetic forms
	dw 0                           		; POLIWAG (3c) - no cosmetic forms
	dw 0                           		; POLIWHIRL (3d) - no cosmetic forms
	dw 0                           		; POLIWRATH (3e) - no cosmetic forms
	dw 0                           		; ABRA (3f) - no cosmetic forms
	dw 0                           		; KADABRA (40) - no cosmetic forms
	dw 0                           		; ALAKAZAM (41) - no cosmetic forms
	dw MachopAnimationIdlePointers		; MACHOP (42) - has cosmetic forms
	dw MachokeAnimationIdlePointers		; MACHOKE (43) - has cosmetic forms
	dw MachampAnimationIdlePointers		; MACHAMP (44) - has cosmetic forms
	dw 0                           		; BELLSPROUT (45) - no cosmetic forms
	dw 0                           		; WEEPINBELL (46) - no cosmetic forms
	dw 0                           		; VICTREEBEL (47) - no cosmetic forms
	dw TentacoolAnimationIdlePointers		; TENTACOOL (48) - has cosmetic forms
	dw TentacruelAnimationIdlePointers		; TENTACRUEL (49) - has cosmetic forms
	dw GeodudeAnimationIdlePointers		; GEODUDE (4a) - has cosmetic forms
	dw GravelerAnimationIdlePointers		; GRAVELER (4b) - has cosmetic forms
	dw GolemAnimationIdlePointers		; GOLEM (4c) - has cosmetic forms
	dw 0                           		; PONYTA (4d) - no cosmetic forms
	dw 0                           		; RAPIDASH (4e) - no cosmetic forms
	dw 0                           		; SLOWPOKE (4f) - no cosmetic forms
	dw 0                           		; SLOWBRO (50) - no cosmetic forms
	dw 0                           		; MAGNEMITE (51) - no cosmetic forms
	dw 0                           		; MAGNETON (52) - no cosmetic forms
	dw FarfetchDAnimationIdlePointers	; FARFETCHD (53) - has cosmetic forms
	dw 0                           		; DODUO (54) - no cosmetic forms
	dw 0                           		; DODRIO (55) - no cosmetic forms
	dw 0                           		; SEEL (56) - no cosmetic forms
	dw 0                           		; DEWGONG (57) - no cosmetic forms
	dw 0                           		; GRIMER (58) - no cosmetic forms
	dw 0                           		; MUK (59) - no cosmetic forms
	dw ShellderAnimationIdlePointers		; SHELLDER (5a) - has cosmetic forms
	dw CloysterAnimationIdlePointers		; CLOYSTER (5b) - has cosmetic forms
	dw GastlyAnimationIdlePointers		; GASTLY (5c) - has cosmetic forms
	dw HaunterAnimationIdlePointers		; HAUNTER (5d) - has cosmetic forms
	dw GengarAnimationIdlePointers		; GENGAR (5e) - has cosmetic forms
	dw 0                           		; ONIX (5f) - no cosmetic forms
	dw 0                           		; DROWZEE (60) - no cosmetic forms
	dw 0                           		; HYPNO (61) - no cosmetic forms
	dw 0                           		; KRABBY (62) - no cosmetic forms
	dw 0                           		; KINGLER (63) - no cosmetic forms
	dw 0                           		; VOLTORB (64) - no cosmetic forms
	dw ElectrodeAnimationIdlePointers	; ELECTRODE (65) - has cosmetic forms
	dw ExeggcuteAnimationIdlePointers	; EXEGGCUTE (66) - has cosmetic forms
	dw ExeggutorAnimationIdlePointers	; EXEGGUTOR (67) - has cosmetic forms
	dw CuboneAnimationIdlePointers	; CUBONE (68) - has cosmetic forms
	dw MarowakAnimationIdlePointers	; MAROWAK (69) - has cosmetic forms
	dw 0                           		; HITMONLEE (6a) - no cosmetic forms
	dw 0                           		; HITMONCHAN (6b) - no cosmetic forms
	dw 0                           		; LICKITUNG (6c) - no cosmetic forms
	dw KoffingAnimationIdlePointers		; KOFFING (6d) - has cosmetic forms
	dw WeezingAnimationIdlePointers		; WEEZING (6e) - has cosmetic forms
	dw RhyhornAnimationIdlePointers	; RHYHORN (6f) - has cosmetic forms
	dw RhydonAnimationIdlePointers	; RHYDON (70) - has cosmetic forms
	dw 0                           		; CHANSEY (71) - no cosmetic forms
	dw 0                           		; TANGELA (72) - no cosmetic forms
	dw KangaskhanAnimationIdlePointers	; KANGASKHAN (73) - has cosmetic forms
	dw HorseaAnimationIdlePointers		; HORSEA (74) - has cosmetic forms
	dw SeadraAnimationIdlePointers		; SEADRA (75) - has cosmetic forms
	dw 0                           		; GOLDEEN (76) - no cosmetic forms
	dw 0                           		; SEAKING (77) - no cosmetic forms
	dw StaryuAnimationIdlePointers		; STARYU (78) - has cosmetic forms
	dw StarmieAnimationIdlePointers		; STARMIE (79) - has cosmetic forms
	dw 0                           		; MR__MIME (7a) - no cosmetic forms
	dw 0                           		; SCYTHER (7b) - no cosmetic forms
	dw 0                           		; JYNX (7c) - no cosmetic forms
	dw 0                           		; ELECTABUZZ (7d) - no cosmetic forms
	dw 0                           		; MAGMAR (7e) - no cosmetic forms
	dw 0                           		; PINSIR (7f) - no cosmetic forms
	dw 0                           		; TAUROS (80) - no cosmetic forms
	dw MagikarpAnimationIdlePointers        ; MAGIKARP (81) - no cosmetic forms
	dw GyaradosAnimationIdlePointers		; GYARADOS (82) - has cosmetic forms
	dw LaprasAnimationIdlePointers	; LAPRAS (83) - has cosmetic forms
	dw 0                           		; DITTO (84) - no cosmetic forms
	dw 0                           		; EEVEE (85) - no cosmetic forms
	dw 0                           		; VAPOREON (86) - no cosmetic forms
	dw 0                           		; JOLTEON (87) - no cosmetic forms
	dw 0                           		; FLAREON (88) - no cosmetic forms
	dw 0                           		; PORYGON (89) - no cosmetic forms
	dw 0                           		; OMANYTE (8a) - no cosmetic forms
	dw 0                           		; OMASTAR (8b) - no cosmetic forms
	dw 0                           		; KABUTO (8c) - no cosmetic forms
	dw 0                           		; KABUTOPS (8d) - no cosmetic forms
	dw AerodactylAnimationIdlePointers		; AERODACTYL (8e) - has cosmetic forms
	dw SnorlaxAnimationIdlePointers		; SNORLAX (8f) - has cosmetic forms
	dw 0                           		; ARTICUNO (90) - no cosmetic forms
	dw 0                           		; ZAPDOS (91) - no cosmetic forms
	dw 0                           		; MOLTRES (92) - no cosmetic forms
	dw 0                           		; DRATINI (93) - no cosmetic forms
	dw 0                           		; DRAGONAIR (94) - no cosmetic forms
	dw 0                           		; DRAGONITE (95) - no cosmetic forms
	dw 0                           		; MEWTWO (96) - no cosmetic forms
	dw 0                           		; MEW (97) - no cosmetic forms
	dw 0                           		; CHIKORITA (98) - no cosmetic forms
	dw 0                           		; BAYLEEF (99) - no cosmetic forms
	dw 0                           		; MEGANIUM (9a) - no cosmetic forms
	dw 0                           		; CYNDAQUIL (9b) - no cosmetic forms
	dw 0                           		; QUILAVA (9c) - no cosmetic forms
	dw 0                           		; TYPHLOSION (9d) - no cosmetic forms
	dw 0                           		; TOTODILE (9e) - no cosmetic forms
	dw 0                           		; CROCONAW (9f) - no cosmetic forms
	dw 0                           		; FERALIGATR (a0) - no cosmetic forms
	dw 0                           		; SENTRET (a1) - no cosmetic forms
	dw 0                           		; FURRET (a2) - no cosmetic forms
	dw 0                           		; HOOTHOOT (a3) - no cosmetic forms
	dw 0                           		; NOCTOWL (a4) - no cosmetic forms
	dw 0                           		; LEDYBA (a5) - no cosmetic forms
	dw 0                           		; LEDIAN (a6) - no cosmetic forms
	dw 0                           		; SPINARAK (a7) - no cosmetic forms
	dw 0                           		; ARIADOS (a8) - no cosmetic forms
	dw CrobatAnimationIdlePointers		; CROBAT (a9) - has cosmetic forms
	dw 0                           		; CHINCHOU (aa) - no cosmetic forms
	dw 0                           		; LANTURN (ab) - no cosmetic forms
	dw PichuAnimationIdlePointers		; PICHU (ac) - has cosmetic forms
	dw 0                           		; CLEFFA (ad) - no cosmetic forms
	dw IgglybuffAnimationIdlePointers		; IGGLYBUFF (ae) - has cosmetic forms
	dw 0                           		; TOGEPI (af) - no cosmetic forms
	dw 0                           		; TOGETIC (b0) - no cosmetic forms
	dw 0                           		; NATU (b1) - no cosmetic forms
	dw 0                           		; XATU (b2) - no cosmetic forms
	dw 0                           		; MAREEP (b3) - no cosmetic forms
	dw 0                           		; FLAAFFY (b4) - no cosmetic forms
	dw 0                           		; AMPHAROS (b5) - no cosmetic forms
	dw 0                           		; BELLOSSOM (b6) - no cosmetic forms
	dw 0                           		; MARILL (b7) - no cosmetic forms
	dw 0                           		; AZUMARILL (b8) - no cosmetic forms
	dw 0                           		; SUDOWOODO (b9) - no cosmetic forms
	dw 0                           		; POLITOED (ba) - no cosmetic forms
	dw 0                           		; HOPPIP (bb) - no cosmetic forms
	dw 0                           		; SKIPLOOM (bc) - no cosmetic forms
	dw 0                           		; JUMPLUFF (bd) - no cosmetic forms
	dw 0                           		; AIPOM (be) - no cosmetic forms
	dw 0                           		; SUNKERN (bf) - no cosmetic forms
	dw 0                           		; SUNFLORA (c0) - no cosmetic forms
	dw 0                           		; YANMA (c1) - no cosmetic forms
	dw 0                           		; WOOPER (c2) - no cosmetic forms
	dw 0                           		; QUAGSIRE (c3) - no cosmetic forms
	dw 0                           		; ESPEON (c4) - no cosmetic forms
	dw 0                           		; UMBREON (c5) - no cosmetic forms
	dw 0                           		; MURKROW (c6) - no cosmetic forms
	dw 0                           		; SLOWKING (c7) - no cosmetic forms
	dw 0                           		; MISDREAVUS (c8) - no cosmetic forms
	dw UnownAnimationIdlePointers  		; UNOWN (c9) - has cosmetic forms
	dw 0                           		; WOBBUFFET (ca) - no cosmetic forms
	dw 0                           		; GIRAFARIG (cb) - no cosmetic forms
	dw 0                           		; PINECO (cc) - no cosmetic forms
	dw 0                           		; FORRETRESS (cd) - no cosmetic forms
	dw 0                           		; DUNSPARCE (ce) - no cosmetic forms
	dw 0                           		; GLIGAR (cf) - no cosmetic forms
	dw 0                           		; STEELIX (d0) - no cosmetic forms
	dw 0                           		; SNUBBULL (d1) - no cosmetic forms
	dw 0                           		; GRANBULL (d2) - no cosmetic forms
	dw 0                           		; QWILFISH (d3) - no cosmetic forms
	dw 0                           		; SCIZOR (d4) - no cosmetic forms
	dw ShuckleAnimationIdlePointers		; SHUCKLE (d5) - has cosmetic forms
	dw 0                           		; HERACROSS (d6) - no cosmetic forms
	dw 0                           		; SNEASEL (d7) - no cosmetic forms
	dw 0                           		; TEDDIURSA (d8) - no cosmetic forms
	dw 0                           		; URSARING (d9) - no cosmetic forms
	dw 0                           		; SLUGMA (da) - no cosmetic forms
	dw 0                           		; MAGCARGO (db) - no cosmetic forms
	dw 0                           		; SWINUB (dc) - no cosmetic forms
	dw 0                           		; PILOSWINE (dd) - no cosmetic forms
	dw 0                           		; CORSOLA (de) - no cosmetic forms
	dw 0                           		; REMORAID (df) - no cosmetic forms
	dw 0                           		; OCTILLERY (e0) - no cosmetic forms
	dw 0                           		; DELIBIRD (e1) - no cosmetic forms
	dw 0                           		; MANTINE (e2) - no cosmetic forms
	dw 0                           		; SKARMORY (e3) - no cosmetic forms
	dw 0                           		; HOUNDOUR (e4) - no cosmetic forms
	dw 0                           		; HOUNDOOM (e5) - no cosmetic forms
	dw KingdraAnimationIdlePointers		; KINGDRA (e6) - has cosmetic forms
	dw 0                           		; PHANPY (e7) - no cosmetic forms
	dw 0                           		; DONPHAN (e8) - no cosmetic forms
	dw 0                           		; PORYGON2 (e9) - no cosmetic forms
	dw 0                           		; STANTLER (ea) - no cosmetic forms
	dw 0                           		; SMEARGLE (eb) - no cosmetic forms
	dw 0                           		; TYROGUE (ec) - no cosmetic forms
	dw 0                           		; HITMONTOP (ed) - no cosmetic forms
	dw 0                           		; SMOOCHUM (ee) - no cosmetic forms
	dw 0                           		; ELEKID (ef) - no cosmetic forms
	dw 0                           		; MAGBY (f0) - no cosmetic forms
	dw 0                           		; MILTANK (f1) - no cosmetic forms
	dw 0                           		; BLISSEY (f2) - no cosmetic forms
	dw 0                           		; RAIKOU (f3) - no cosmetic forms
	dw 0                           		; ENTEI (f4) - no cosmetic forms
	dw 0                           		; SUICUNE (f5) - no cosmetic forms
	dw 0                           		; LARVITAR (f6) - no cosmetic forms
	dw 0                           		; PUPITAR (f7) - no cosmetic forms
	dw 0                           		; TYRANITAR (f8) - no cosmetic forms
	dw 0                           		; LUGIA (f9) - no cosmetic forms
	dw 0                           		; HO_OH (fa) - no cosmetic forms
	dw 0                           		; CELEBI (fb) - no cosmetic forms
	dw 0					; NEW_MON_1 (fc)
	dw 0					; NEW_MON_2 (fd)
	dw 0					; NEW_MON_3 (fe)
	dw 0					; NEW_MON_4 (ff)
	dw 0					; NEW_MON_5 (100)
	assert_table_length NUM_POKEMON

; Animation Pointers
PikachuAnimationPointers:
	table_width 2
	dw PikachuPlainAnimation
	dw PikachuSurfAnimation
	dw PikachuFlyAnimation
	dw PikachuRBAnimation
	assert_table_length NUM_PIKACHU_FORMS

CharmeleonAnimationPointers:
	table_width 2
	dw CharmeleonPlainAnimation
	dw CharmeleonRocketAnimation
	assert_table_length NUM_CHARMELEON_FORMS

CharizardAnimationPointers:
	table_width 2
	dw CharizardPlainAnimation
	dw CharizardRocketAnimation
	assert_table_length NUM_CHARIZARD_FORMS

WeezingAnimationPointers:
	table_width 2
	dw WeezingPlainAnimation
	dw WeezingRocketAnimation
	dw WeezingRBAnimation
	assert_table_length NUM_WEEZING_FORMS

CrobatAnimationPointers:
	table_width 2
	dw CrobatPlainAnimation
	dw CrobatRocketAnimation
	dw CrobatBetaAnimation
	assert_table_length NUM_CROBAT_FORMS

ElectrodeAnimationPointers:
	table_width 2
	dw ElectrodePlainAnimation
	dw ElectrodeRocketAnimation
	assert_table_length NUM_ELECTRODE_FORMS

ArbokAnimationPointers:
	table_width 2
	dw ArbokPlainAnimation
	dw ArbokRocketAnimation
	assert_table_length NUM_ARBOK_FORMS

GolbatAnimationPointers:
	table_width 2
	dw GolbatPlainAnimation
	dw GolbatRocketAnimation
	dw GolbatRBAnimation
	assert_table_length NUM_GOLBAT_FORMS

SnorlaxAnimationPointers:
	table_width 2
	dw SnorlaxPlainAnimation
	dw SnorlaxApricornAnimation
	assert_table_length NUM_SNORLAX_FORMS

ShuckleAnimationPointers:
	table_width 2
	dw ShucklePlainAnimation
	dw ShuckleShuckieNeutralAnimation
	dw ShuckleShuckieHappyAnimation
	assert_table_length NUM_SHUCKLE_FORMS

UnownAnimationPointers:
	table_width 2
	dw UnownAAnimation
	dw UnownBAnimation
	dw UnownCAnimation
	dw UnownDAnimation
	dw UnownEAnimation
	dw UnownFAnimation
	dw UnownGAnimation
	dw UnownHAnimation
	dw UnownIAnimation
	dw UnownJAnimation
	dw UnownKAnimation
	dw UnownLAnimation
	dw UnownMAnimation
	dw UnownNAnimation
	dw UnownOAnimation
	dw UnownPAnimation
	dw UnownQAnimation
	dw UnownRAnimation
	dw UnownSAnimation
	dw UnownTAnimation
	dw UnownUAnimation
	dw UnownVAnimation
	dw UnownWAnimation
	dw UnownXAnimation
	dw UnownYAnimation
	dw UnownZAnimation
	assert_table_length NUM_UNOWN

MagikarpAnimationPointers:
	table_width 2
	dw MagikarpPlainAnimation
	dw MagikarpXSAnimation
	dw MagikarpXLAnimation
	dw MagikarpRBAnimation
	assert_table_length NUM_MAGIKARP_FORMS

; Idle Animation Pointers
PikachuAnimationIdlePointers:
	table_width 2
	dw PikachuPlainAnimationIdle
	dw PikachuSurfAnimationIdle
	dw PikachuFlyAnimationIdle
	dw PikachuRBAnimationIdle
	assert_table_length NUM_PIKACHU_FORMS

CharmeleonAnimationIdlePointers:
	table_width 2
	dw CharmeleonPlainAnimationIdle
	dw CharmeleonRocketAnimationIdle
	assert_table_length NUM_CHARMELEON_FORMS

CharizardAnimationIdlePointers:
	table_width 2
	dw CharizardPlainAnimationIdle
	dw CharizardRocketAnimationIdle
	assert_table_length NUM_CHARIZARD_FORMS

WeezingAnimationIdlePointers:
	table_width 2
	dw WeezingPlainAnimationIdle
	dw WeezingRocketAnimationIdle
	dw WeezingRBAnimationIdle
	assert_table_length NUM_WEEZING_FORMS

CrobatAnimationIdlePointers:
	table_width 2
	dw CrobatPlainAnimationIdle
	dw CrobatRocketAnimationIdle
	dw CrobatBetaAnimationIdle
	assert_table_length NUM_CROBAT_FORMS

ElectrodeAnimationIdlePointers:
	table_width 2
	dw ElectrodePlainAnimationIdle
	dw ElectrodeRocketAnimationIdle
	assert_table_length NUM_ELECTRODE_FORMS

ArbokAnimationIdlePointers:
	table_width 2
	dw ArbokPlainAnimationIdle
	dw ArbokRocketAnimationIdle
	assert_table_length NUM_ARBOK_FORMS

GolbatAnimationIdlePointers:
	table_width 2
	dw GolbatPlainAnimationIdle
	dw GolbatRocketAnimationIdle
	dw GolbatRBAnimationIdle
	assert_table_length NUM_GOLBAT_FORMS

SnorlaxAnimationIdlePointers:
	table_width 2
	dw SnorlaxPlainAnimationIdle
	dw SnorlaxApricornAnimationIdle
	assert_table_length NUM_SNORLAX_FORMS

ShuckleAnimationIdlePointers:
	table_width 2
	dw ShucklePlainAnimationIdle
	dw ShuckleShuckieNeutralAnimationIdle
	dw ShuckleShuckieHappyAnimationIdle
	assert_table_length NUM_SHUCKLE_FORMS

UnownAnimationIdlePointers:
	table_width 2
	dw UnownAAnimationIdle
	dw UnownBAnimationIdle
	dw UnownCAnimationIdle
	dw UnownDAnimationIdle
	dw UnownEAnimationIdle
	dw UnownFAnimationIdle
	dw UnownGAnimationIdle
	dw UnownHAnimationIdle
	dw UnownIAnimationIdle
	dw UnownJAnimationIdle
	dw UnownKAnimationIdle
	dw UnownLAnimationIdle
	dw UnownMAnimationIdle
	dw UnownNAnimationIdle
	dw UnownOAnimationIdle
	dw UnownPAnimationIdle
	dw UnownQAnimationIdle
	dw UnownRAnimationIdle
	dw UnownSAnimationIdle
	dw UnownTAnimationIdle
	dw UnownUAnimationIdle
	dw UnownVAnimationIdle
	dw UnownWAnimationIdle
	dw UnownXAnimationIdle
	dw UnownYAnimationIdle
	dw UnownZAnimationIdle
	assert_table_length NUM_UNOWN

MagikarpAnimationIdlePointers:
	table_width 2
	dw MagikarpPlainAnimationIdle
	dw MagikarpXSAnimationIdle
	dw MagikarpXLAnimationIdle
	dw MagikarpRBAnimationIdle
	assert_table_length NUM_MAGIKARP_FORMS

MachopAnimationPointers:
	table_width 2
	dw MachopPlainAnimation
	dw MachopRBAnimation
	assert_table_length NUM_MACHOP_FORMS

MachopAnimationIdlePointers:
	table_width 2
	dw MachopPlainAnimationIdle
	dw MachopRBAnimationIdle
	assert_table_length NUM_MACHOP_FORMS

MachokeAnimationPointers:
	table_width 2
	dw MachokePlainAnimation
	dw MachokeRBAnimation
	assert_table_length NUM_MACHOKE_FORMS

MachokeAnimationIdlePointers:
	table_width 2
	dw MachokePlainAnimationIdle
	dw MachokeRBAnimationIdle
	assert_table_length NUM_MACHOKE_FORMS

MachampAnimationPointers:
	table_width 2
	dw MachampPlainAnimation
	dw MachampRBAnimation
	assert_table_length NUM_MACHAMP_FORMS

MachampAnimationIdlePointers:
	table_width 2
	dw MachampPlainAnimationIdle
	dw MachampRBAnimationIdle
	assert_table_length NUM_MACHAMP_FORMS

TentacoolAnimationPointers:
	table_width 2
	dw TentacoolPlainAnimation
	dw TentacoolRBAnimation
	assert_table_length NUM_TENTACOOL_FORMS

TentacoolAnimationIdlePointers:
	table_width 2
	dw TentacoolPlainAnimationIdle
	dw TentacoolRBAnimationIdle
	assert_table_length NUM_TENTACOOL_FORMS

TentacruelAnimationPointers:
	table_width 2
	dw TentacruelPlainAnimation
	dw TentacruelRBAnimation
	assert_table_length NUM_TENTACRUEL_FORMS

TentacruelAnimationIdlePointers:
	table_width 2
	dw TentacruelPlainAnimationIdle
	dw TentacruelRBAnimationIdle
	assert_table_length NUM_TENTACRUEL_FORMS

IgglybuffAnimationPointers:
	table_width 2
	dw IgglybuffPlainAnimation
	dw IgglybuffBetaAnimation
	assert_table_length NUM_IGGLYBUFF_FORMS

JigglypuffAnimationPointers:
	table_width 2
	dw JigglypuffPlainAnimation
	dw JigglypuffRBAnimation
	assert_table_length NUM_JIGGLYPUFF_FORMS

WigglytuffAnimationPointers:
	table_width 2
	dw WigglytuffPlainAnimation
	dw WigglytuffRBAnimation
	assert_table_length NUM_WIGGLYTUFF_FORMS

NidoranMAnimationPointers:
	table_width 2
	dw NidoranMPlainAnimation
	dw NidoranMRBAnimation
	assert_table_length NUM_NIDORAN_M_FORMS

NidorinoAnimationPointers:
	table_width 2
	dw NidorinoPlainAnimation
	dw NidorinoRBAnimation
	assert_table_length NUM_NIDORINO_FORMS

NidokingAnimationPointers:
	table_width 2
	dw NidokingPlainAnimation
	dw NidokingRBAnimation
	assert_table_length NUM_NIDOKING_FORMS

NidoranFAnimationPointers:
	table_width 2
	dw NidoranFPlainAnimation
	dw NidoranFRBAnimation
	assert_table_length NUM_NIDORAN_F_FORMS

NidorinaAnimationPointers:
	table_width 2
	dw NidorinaPlainAnimation
	dw NidorinaRBAnimation
	assert_table_length NUM_NIDORINA_FORMS

NidoqueenAnimationPointers:
	table_width 2
	dw NidoqueenPlainAnimation
	dw NidoqueenRBAnimation
	assert_table_length NUM_NIDOQUEEN_FORMS

ZubatAnimationPointers:
	table_width 2
	dw ZubatPlainAnimation
	dw ZubatPlainAnimation ; looks plain
	dw ZubatRBAnimation
	assert_table_length NUM_ZUBAT_FORMS

GeodudeAnimationPointers:
	table_width 2
	dw GeodudePlainAnimation
	dw GeodudeRBAnimation
	assert_table_length NUM_GEODUDE_FORMS

GravelerAnimationPointers:
	table_width 2
	dw GravelerPlainAnimation
	dw GravelerRBAnimation
	assert_table_length NUM_GRAVELER_FORMS

GolemAnimationPointers:
	table_width 2
	dw GolemPlainAnimation
	dw GolemRBAnimation
	assert_table_length NUM_GOLEM_FORMS

ShellderAnimationPointers:
	table_width 2
	dw ShellderPlainAnimation
	dw ShellderRBAnimation
	assert_table_length NUM_SHELLDER_FORMS

CloysterAnimationPointers:
	table_width 2
	dw CloysterPlainAnimation
	dw CloysterRBAnimation
	assert_table_length NUM_CLOYSTER_FORMS

GastlyAnimationPointers:
	table_width 2
	dw GastlyPlainAnimation
	dw GastlyRBAnimation
	assert_table_length NUM_GASTLY_FORMS

HaunterAnimationPointers:
	table_width 2
	dw HaunterPlainAnimation
	dw HaunterRBAnimation
	assert_table_length NUM_HAUNTER_FORMS

GengarAnimationPointers:
	table_width 2
	dw GengarPlainAnimation
	dw GengarRBAnimation
	assert_table_length NUM_GENGAR_FORMS

KoffingAnimationPointers:
	table_width 2
	dw KoffingPlainAnimation
	dw KoffingPlainAnimation ; looks plain
	dw KoffingRBAnimation
	assert_table_length NUM_KOFFING_FORMS

HorseaAnimationPointers:
	table_width 2
	dw HorseaPlainAnimation
	dw HorseaRBAnimation
	assert_table_length NUM_HORSEA_FORMS

SeadraAnimationPointers:
	table_width 2
	dw SeadraPlainAnimation
	dw SeadraRBAnimation
	assert_table_length NUM_SEADRA_FORMS

KingdraAnimationPointers:
	table_width 2
	dw KingdraPlainAnimation
	dw KingdraBetaAnimation
	assert_table_length NUM_KINGDRA_FORMS

PsyduckAnimationPointers:
	table_width 2
	dw PsyduckPlainAnimation
	dw PsyduckRBAnimation
	assert_table_length NUM_PSYDUCK_FORMS

GolduckAnimationPointers:
	table_width 2
	dw GolduckPlainAnimation
	dw GolduckRBAnimation
	assert_table_length NUM_GOLDUCK_FORMS

GyaradosAnimationPointers:
	table_width 2
	dw GyaradosPlainAnimation
	dw GyaradosPlainAnimation ; looks plain
	dw GyaradosPlainAnimation ; looks plain
	dw GyaradosRBAnimation
	assert_table_length NUM_GYARADOS_FORMS

StaryuAnimationPointers:
	table_width 2
	dw StaryuPlainAnimation
	dw StaryuRBAnimation
	assert_table_length NUM_STARYU_FORMS

StarmieAnimationPointers:
	table_width 2
	dw StarmiePlainAnimation
	dw StarmieRBAnimation
	assert_table_length NUM_STARMIE_FORMS

AerodactylAnimationPointers:
	table_width 2
	dw AerodactylPlainAnimation
	dw AerodactylRBAnimation
	assert_table_length NUM_AERODACTYL_FORMS

RhyhornAnimationPointers:
	table_width 2
	dw RhyhornPlainAnimation
	dw RhyhornRBAnimation
	assert_table_length NUM_RHYHORN_FORMS

RhydonAnimationPointers:
	table_width 2
	dw RhydonPlainAnimation
	dw RhydonRBAnimation
	assert_table_length NUM_RHYDON_FORMS

KangaskhanAnimationPointers:
	table_width 2
	dw KangaskhanPlainAnimation
	dw KangaskhanRBAnimation
	assert_table_length NUM_KANGASKHAN_FORMS

VenonatAnimationPointers:
	table_width 2
	dw VenonatPlainAnimation
	dw VenonatRBAnimation
	assert_table_length NUM_VENONAT_FORMS

VenomothAnimationPointers:
	table_width 2
	dw VenomothPlainAnimation
	dw VenomothRBAnimation
	assert_table_length NUM_VENOMOTH_FORMS

LaprasAnimationPointers:
	table_width 2
	dw LaprasPlainAnimation
	dw LaprasRBAnimation
	assert_table_length NUM_LAPRAS_FORMS

FarfetchDAnimationPointers:
	table_width 2
	dw FarfetchDPlainAnimation
	dw FarfetchDRBAnimation
	assert_table_length NUM_FARFETCH_D_FORMS

CuboneAnimationPointers:
	table_width 2
	dw CubonePlainAnimation
	dw CuboneRBAnimation
	assert_table_length NUM_CUBONE_FORMS

MarowakAnimationPointers:
	table_width 2
	dw MarowakPlainAnimation
	dw MarowakRBAnimation
	assert_table_length NUM_MAROWAK_FORMS

ExeggcuteAnimationPointers:
	table_width 2
	dw ExeggcutePlainAnimation
	dw ExeggcuteRBAnimation
	assert_table_length NUM_EXEGGCUTE_FORMS

ExeggutorAnimationPointers:
	table_width 2
	dw ExeggutorPlainAnimation
	dw ExeggutorRBAnimation
	assert_table_length NUM_EXEGGUTOR_FORMS

IgglybuffAnimationIdlePointers:
	table_width 2
	dw IgglybuffPlainAnimationIdle
	dw IgglybuffBetaAnimationIdle
	assert_table_length NUM_IGGLYBUFF_FORMS

JigglypuffAnimationIdlePointers:
	table_width 2
	dw JigglypuffPlainAnimationIdle
	dw JigglypuffRBAnimationIdle
	assert_table_length NUM_JIGGLYPUFF_FORMS

WigglytuffAnimationIdlePointers:
	table_width 2
	dw WigglytuffPlainAnimationIdle
	dw WigglytuffRBAnimationIdle
	assert_table_length NUM_WIGGLYTUFF_FORMS

NidoranMAnimationIdlePointers:
	table_width 2
	dw NidoranMPlainAnimationIdle
	dw NidoranMRBAnimationIdle
	assert_table_length NUM_NIDORAN_M_FORMS

NidorinoAnimationIdlePointers:
	table_width 2
	dw NidorinoPlainAnimationIdle
	dw NidorinoRBAnimationIdle
	assert_table_length NUM_NIDORINO_FORMS

NidokingAnimationIdlePointers:
	table_width 2
	dw NidokingPlainAnimationIdle
	dw NidokingRBAnimationIdle
	assert_table_length NUM_NIDOKING_FORMS

NidoranFAnimationIdlePointers:
	table_width 2
	dw NidoranFPlainAnimationIdle
	dw NidoranFRBAnimationIdle
	assert_table_length NUM_NIDORAN_F_FORMS

NidorinaAnimationIdlePointers:
	table_width 2
	dw NidorinaPlainAnimationIdle
	dw NidorinaRBAnimationIdle
	assert_table_length NUM_NIDORINA_FORMS

NidoqueenAnimationIdlePointers:
	table_width 2
	dw NidoqueenPlainAnimationIdle
	dw NidoqueenRBAnimationIdle
	assert_table_length NUM_NIDOQUEEN_FORMS

ZubatAnimationIdlePointers:
	table_width 2
	dw ZubatPlainAnimationIdle
	dw ZubatPlainAnimationIdle ; looks plain
	dw ZubatRBAnimationIdle
	assert_table_length NUM_ZUBAT_FORMS

GeodudeAnimationIdlePointers:
	table_width 2
	dw GeodudePlainAnimationIdle
	dw GeodudeRBAnimationIdle
	assert_table_length NUM_GEODUDE_FORMS

GravelerAnimationIdlePointers:
	table_width 2
	dw GravelerPlainAnimationIdle
	dw GravelerRBAnimationIdle
	assert_table_length NUM_GRAVELER_FORMS

GolemAnimationIdlePointers:
	table_width 2
	dw GolemPlainAnimationIdle
	dw GolemRBAnimationIdle
	assert_table_length NUM_GOLEM_FORMS

ShellderAnimationIdlePointers:
	table_width 2
	dw ShellderPlainAnimationIdle
	dw ShellderRBAnimationIdle
	assert_table_length NUM_SHELLDER_FORMS

CloysterAnimationIdlePointers:
	table_width 2
	dw CloysterPlainAnimationIdle
	dw CloysterRBAnimationIdle
	assert_table_length NUM_CLOYSTER_FORMS

GastlyAnimationIdlePointers:
	table_width 2
	dw GastlyPlainAnimationIdle
	dw GastlyRBAnimationIdle
	assert_table_length NUM_GASTLY_FORMS

HaunterAnimationIdlePointers:
	table_width 2
	dw HaunterPlainAnimationIdle
	dw HaunterRBAnimationIdle
	assert_table_length NUM_HAUNTER_FORMS

GengarAnimationIdlePointers:
	table_width 2
	dw GengarPlainAnimationIdle
	dw GengarRBAnimationIdle
	assert_table_length NUM_GENGAR_FORMS

KoffingAnimationIdlePointers:
	table_width 2
	dw KoffingPlainAnimationIdle
	dw KoffingPlainAnimationIdle ; looks plain
	dw KoffingRBAnimationIdle
	assert_table_length NUM_KOFFING_FORMS

HorseaAnimationIdlePointers:
	table_width 2
	dw HorseaPlainAnimationIdle
	dw HorseaRBAnimationIdle
	assert_table_length NUM_HORSEA_FORMS

SeadraAnimationIdlePointers:
	table_width 2
	dw SeadraPlainAnimationIdle
	dw SeadraRBAnimationIdle
	assert_table_length NUM_SEADRA_FORMS

KingdraAnimationIdlePointers:
	table_width 2
	dw KingdraPlainAnimationIdle
	dw KingdraBetaAnimationIdle
	assert_table_length NUM_KINGDRA_FORMS

PsyduckAnimationIdlePointers:
	table_width 2
	dw PsyduckPlainAnimationIdle
	dw PsyduckRBAnimationIdle
	assert_table_length NUM_PSYDUCK_FORMS

GolduckAnimationIdlePointers:
	table_width 2
	dw GolduckPlainAnimationIdle
	dw GolduckRBAnimationIdle
	assert_table_length NUM_GOLDUCK_FORMS

GyaradosAnimationIdlePointers:
	table_width 2
	dw GyaradosPlainAnimationIdle
	dw GyaradosPlainAnimationIdle ; looks plain
	dw GyaradosPlainAnimationIdle ; looks plain
	dw GyaradosRBAnimationIdle
	assert_table_length NUM_GYARADOS_FORMS

StaryuAnimationIdlePointers:
	table_width 2
	dw StaryuPlainAnimationIdle
	dw StaryuRBAnimationIdle
	assert_table_length NUM_STARYU_FORMS

StarmieAnimationIdlePointers:
	table_width 2
	dw StarmiePlainAnimationIdle
	dw StarmieRBAnimationIdle
	assert_table_length NUM_STARMIE_FORMS

AerodactylAnimationIdlePointers:
	table_width 2
	dw AerodactylPlainAnimationIdle
	dw AerodactylRBAnimationIdle
	assert_table_length NUM_AERODACTYL_FORMS

RhyhornAnimationIdlePointers:
	table_width 2
	dw RhyhornPlainAnimationIdle
	dw RhyhornRBAnimationIdle
	assert_table_length NUM_RHYHORN_FORMS

RhydonAnimationIdlePointers:
	table_width 2
	dw RhydonPlainAnimationIdle
	dw RhydonRBAnimationIdle
	assert_table_length NUM_RHYDON_FORMS

KangaskhanAnimationIdlePointers:
	table_width 2
	dw KangaskhanPlainAnimationIdle
	dw KangaskhanRBAnimationIdle
	assert_table_length NUM_KANGASKHAN_FORMS

VenonatAnimationIdlePointers:
	table_width 2
	dw VenonatPlainAnimationIdle
	dw VenonatRBAnimationIdle
	assert_table_length NUM_VENONAT_FORMS

VenomothAnimationIdlePointers:
	table_width 2
	dw VenomothPlainAnimationIdle
	dw VenomothRBAnimationIdle
	assert_table_length NUM_VENOMOTH_FORMS

LaprasAnimationIdlePointers:
	table_width 2
	dw LaprasPlainAnimationIdle
	dw LaprasRBAnimationIdle
	assert_table_length NUM_LAPRAS_FORMS

FarfetchDAnimationIdlePointers:
	table_width 2
	dw FarfetchDPlainAnimationIdle
	dw FarfetchDRBAnimationIdle
	assert_table_length NUM_FARFETCH_D_FORMS

CuboneAnimationIdlePointers:
	table_width 2
	dw CubonePlainAnimationIdle
	dw CuboneRBAnimationIdle
	assert_table_length NUM_CUBONE_FORMS

MarowakAnimationIdlePointers:
	table_width 2
	dw MarowakPlainAnimationIdle
	dw MarowakRBAnimationIdle
	assert_table_length NUM_MAROWAK_FORMS

ExeggcuteAnimationIdlePointers:
	table_width 2
	dw ExeggcutePlainAnimationIdle
	dw ExeggcuteRBAnimationIdle
	assert_table_length NUM_EXEGGCUTE_FORMS

ExeggutorAnimationIdlePointers:
	table_width 2
	dw ExeggutorPlainAnimationIdle
	dw ExeggutorRBAnimationIdle
	assert_table_length NUM_EXEGGUTOR_FORMS

PichuAnimationPointers:
	table_width 2
	dw PichuPlainAnimation
	dw PichuPlainAnimation ; looks plain
	dw PichuPlainAnimation ; looks plain
	dw PichuBetaAnimation
	assert_table_length NUM_PICHU_FORMS

RaichuAnimationPointers:
	table_width 2
	dw RaichuPlainAnimation
	dw RaichuPlainAnimation ; looks plain
	dw RaichuPlainAnimation ; looks plain
	dw RaichuRBAnimation
	assert_table_length NUM_RAICHU_FORMS

PichuAnimationIdlePointers:
	table_width 2
	dw PichuPlainAnimationIdle
	dw PichuPlainAnimationIdle ; looks plain
	dw PichuPlainAnimationIdle ; looks plain
	dw PichuBetaAnimationIdle
	assert_table_length NUM_PICHU_FORMS

RaichuAnimationIdlePointers:
	table_width 2
	dw RaichuPlainAnimationIdle
	dw RaichuPlainAnimationIdle ; looks plain
	dw RaichuPlainAnimationIdle ; looks plain
	dw RaichuRBAnimationIdle
	assert_table_length NUM_RAICHU_FORMS
