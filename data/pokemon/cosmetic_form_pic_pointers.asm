; Master table for Pokemon pic pointers
; Each entry corresponds to a Pokemon species (indexed by species ID)
; Entries for Pokemon with cosmetic forms point to their form-specific pointer tables
; Entries for Pokemon without cosmetic forms are null (0)
	dw EggPicPointers			; EGG - each egg pattern has its own pic
	dw 0					; NULL
	dw 0					; NULL
	dw 0					; NULL
CosmeticFormPicPointersTable::
	table_width 2
	dw 0					; BULBASAUR (01) - no cosmetic forms
	dw 0					; IVYSAUR (02) - no cosmetic forms
	dw 0					; VENUSAUR (03) - no cosmetic forms
	dw 0					; CHARMANDER (04) - no cosmetic forms
	dw CharmeleonPicPointers		; CHARMELEON (05) - has cosmetic forms
	dw CharizardPicPointers			; CHARIZARD (06) - has cosmetic forms
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
	dw ArbokPicPointers		; ARBOK (18) - has cosmetic forms
	dw PikachuPicPointers			; PIKACHU (19) - has cosmetic forms
	dw RaichuPicPointers		; RAICHU (1a) - has cosmetic forms
	dw 0					; SANDSHREW (1b) - no cosmetic forms
	dw 0					; SANDSLASH (1c) - no cosmetic forms
	dw NidoranFPicPointers		; NIDORAN_F (1d) - has cosmetic forms
	dw NidorinaPicPointers		; NIDORINA (1e) - has cosmetic forms
	dw NidoqueenPicPointers		; NIDOQUEEN (1f) - has cosmetic forms
	dw NidoranMPicPointers		; NIDORAN_M (20) - has cosmetic forms
	dw NidorinoPicPointers		; NIDORINO (21) - has cosmetic forms
	dw NidokingPicPointers		; NIDOKING (22) - has cosmetic forms
	dw 0					; CLEFAIRY (23) - no cosmetic forms
	dw 0					; CLEFABLE (24) - no cosmetic forms
	dw 0					; VULPIX (25) - no cosmetic forms
	dw 0					; NINETALES (26) - no cosmetic forms
	dw JigglypuffPicPointers		; JIGGLYPUFF (27) - has cosmetic forms
	dw WigglytuffPicPointers		; WIGGLYTUFF (28) - has cosmetic forms
	dw ZubatPicPointers		; ZUBAT (29) - has cosmetic forms
	dw GolbatPicPointers			; GOLBAT (2a) - has cosmetic forms
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
	dw PsyduckPicPointers		; PSYDUCK (36) - has cosmetic forms
	dw GolduckPicPointers		; GOLDUCK (37) - has cosmetic forms
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
	dw MachopPicPointers			; MACHOP (42) - has cosmetic forms
	dw MachokePicPointers			; MACHOKE (43) - has cosmetic forms
	dw MachampPicPointers			; MACHAMP (44) - has cosmetic forms
	dw 0					; BELLSPROUT (45) - no cosmetic forms
	dw 0					; WEEPINBELL (46) - no cosmetic forms
	dw 0					; VICTREEBEL (47) - no cosmetic forms
	dw TentacoolPicPointers			; TENTACOOL (48) - has cosmetic forms
	dw TentacruelPicPointers			; TENTACRUEL (49) - has cosmetic forms
	dw GeodudePicPointers		; GEODUDE (4a) - has cosmetic forms
	dw GravelerPicPointers		; GRAVELER (4b) - has cosmetic forms
	dw GolemPicPointers		; GOLEM (4c) - has cosmetic forms
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
	dw ShellderPicPointers		; SHELLDER (5a) - has cosmetic forms
	dw CloysterPicPointers		; CLOYSTER (5b) - has cosmetic forms
	dw GastlyPicPointers		; GASTLY (5c) - has cosmetic forms
	dw HaunterPicPointers		; HAUNTER (5d) - has cosmetic forms
	dw GengarPicPointers		; GENGAR (5e) - has cosmetic forms
	dw 0					; ONIX (5f) - no cosmetic forms
	dw 0					; DROWZEE (60) - no cosmetic forms
	dw 0					; HYPNO (61) - no cosmetic forms
	dw 0					; KRABBY (62) - no cosmetic forms
	dw 0					; KINGLER (63) - no cosmetic forms
	dw 0					; VOLTORB (64) - no cosmetic forms
	dw ElectrodePicPointers			; ELECTRODE (65) - has cosmetic forms
	dw 0					; EXEGGCUTE (66) - no cosmetic forms
	dw 0					; EXEGGUTOR (67) - no cosmetic forms
	dw 0					; CUBONE (68) - no cosmetic forms
	dw 0					; MAROWAK (69) - no cosmetic forms
	dw 0					; HITMONLEE (6a) - no cosmetic forms
	dw 0					; HITMONCHAN (6b) - no cosmetic forms
	dw 0					; LICKITUNG (6c) - no cosmetic forms
	dw KoffingPicPointers		; KOFFING (6d) - has cosmetic forms
	dw WeezingPicPointers			; WEEZING (6e) - has cosmetic forms
	dw 0					; RHYHORN (6f) - no cosmetic forms
	dw 0					; RHYDON (70) - no cosmetic forms
	dw 0					; CHANSEY (71) - no cosmetic forms
	dw 0					; TANGELA (72) - no cosmetic forms
	dw 0					; KANGASKHAN (73) - no cosmetic forms
	dw HorseaPicPointers		; HORSEA (74) - has cosmetic forms
	dw SeadraPicPointers		; SEADRA (75) - has cosmetic forms
	dw 0					; GOLDEEN (76) - no cosmetic forms
	dw 0					; SEAKING (77) - no cosmetic forms
	dw StaryuPicPointers		; STARYU (78) - has cosmetic forms
	dw StarmiePicPointers		; STARMIE (79) - has cosmetic forms
	dw 0					; MR__MIME (7a) - no cosmetic forms
	dw 0					; SCYTHER (7b) - no cosmetic forms
	dw 0					; JYNX (7c) - no cosmetic forms
	dw 0					; ELECTABUZZ (7d) - no cosmetic forms
	dw 0					; MAGMAR (7e) - no cosmetic forms
	dw 0					; PINSIR (7f) - no cosmetic forms
	dw 0					; TAUROS (80) - no cosmetic forms
	dw MagikarpPicPointers			; MAGIKARP (81) - no cosmetic forms
	dw GyaradosPicPointers		; GYARADOS (82) - has cosmetic forms
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
	dw SnorlaxPicPointers		; SNORLAX (8f) - has cosmetic forms
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
	dw CrobatPicPointers			; CROBAT (a9) - has cosmetic forms
	dw 0					; CHINCHOU (aa) - no cosmetic forms
	dw 0					; LANTURN (ab) - no cosmetic forms
	dw PichuPicPointers		; PICHU (ac) - has cosmetic forms
	dw 0					; CLEFFA (ad) - no cosmetic forms
	dw IgglybuffPicPointers		; IGGLYBUFF (ae) - has cosmetic forms
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
	dw UnownPicPointers			; UNOWN (c9) - has cosmetic forms
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
	dw ShucklePicPointers			; SHUCKLE (d5) - has cosmetic forms
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
	dw KingdraPicPointers		; KINGDRA (e6) - has cosmetic forms
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

PikachuPicPointers::
; entries correspond to Pikachu's forms, two apiece
	table_width 3 * 2
	dba PikachuFrontpic
	dba PikachuBackpic
	dba PikachuSurfFrontpic
	dba PikachuSurfBackpic
	dba PikachuFlyFrontpic
	dba PikachuFlyBackpic
	dba PikachuRBFrontpic
	dba PikachuRBBackpic
	assert_table_length NUM_PIKACHU_FORMS

CharmeleonPicPointers::
; entries correspond to Charmeleon's forms, two apiece
	table_width 3 * 2
	dba CharmeleonFrontpic
	dba CharmeleonBackpic
	dba CharmeleonRocketFrontpic
	dba CharmeleonBackpic ; shares Charmeleon's back, drawn in the form's colours
	assert_table_length NUM_CHARMELEON_FORMS

CharizardPicPointers::
; entries correspond to Charizard's forms, two apiece
	table_width 3 * 2
	dba CharizardFrontpic
	dba CharizardBackpic
	dba CharizardRocketFrontpic
	dba CharizardBackpic ; shares Charizard's back, drawn in the form's colours
	assert_table_length NUM_CHARIZARD_FORMS

WeezingPicPointers::
; entries correspond to Weezing's forms, two apiece
	table_width 3 * 2
	dba WeezingFrontpic
	dba WeezingBackpic
	dba WeezingRocketFrontpic
	dba WeezingBackpic ; shares Weezing's back; the form keeps Weezing's colours
	dba WeezingRBFrontpic
	dba WeezingRBBackpic
	assert_table_length NUM_WEEZING_FORMS

CrobatPicPointers::
; entries correspond to Crobat's forms, two apiece
	table_width 3 * 2
	dba CrobatFrontpic
	dba CrobatBackpic
	dba CrobatRocketFrontpic
	dba CrobatBackpic ; shares Crobat's back, drawn in the form's colours
	dba CrobatBetaFrontpic
	dba CrobatBetaBackpic
	assert_table_length NUM_CROBAT_FORMS

ElectrodePicPointers::
; entries correspond to Electrode's forms, two apiece
	table_width 3 * 2
	dba ElectrodeFrontpic
	dba ElectrodeBackpic
	dba ElectrodeRocketFrontpic
	dba ElectrodeBackpic ; shares Electrode's back, drawn in the form's colours
	assert_table_length NUM_ELECTRODE_FORMS

ArbokPicPointers::
; entries correspond to Arbok's forms, two apiece
	table_width 3 * 2
	dba ArbokFrontpic
	dba ArbokBackpic
	dba ArbokRocketFrontpic
	dba ArbokBackpic ; shares Arbok's back, drawn in the form's colours
	assert_table_length NUM_ARBOK_FORMS

GolbatPicPointers::
; entries correspond to Golbat's forms, two apiece
	table_width 3 * 2
	dba GolbatFrontpic
	dba GolbatBackpic
	dba GolbatRocketFrontpic
	dba GolbatBackpic ; shares Golbat's back; the form keeps Golbat's colours
	dba GolbatRBFrontpic
	dba GolbatRBBackpic
	assert_table_length NUM_GOLBAT_FORMS

SnorlaxPicPointers::
; entries correspond to Snorlax's forms, two apiece
	table_width 3 * 2
	dba SnorlaxFrontpic
	dba SnorlaxBackpic
	dba SnorlaxApricornFrontpic
	dba SnorlaxBackpic ; shares Snorlax's back, drawn in the form's colours
	assert_table_length NUM_SNORLAX_FORMS

ShucklePicPointers::
; entries correspond to Shuckle's forms, two apiece
	table_width 3 * 2
	dba ShuckleFrontpic
	dba ShuckleBackpic
	dba ShuckleShuckieNeutralFrontpic
	dba ShuckleShuckieNeutralBackpic
	dba ShuckleShuckieHappyFrontpic
	dba ShuckleShuckieHappyBackpic
	assert_table_length NUM_SHUCKLE_FORMS

UnownPicPointers::
; entries correspond to Unown letters, two apiece
	table_width 3 * 2
	dba UnownAFrontpic
	dba UnownABackpic
	dba UnownBFrontpic
	dba UnownBBackpic
	dba UnownCFrontpic
	dba UnownCBackpic
	dba UnownDFrontpic
	dba UnownDBackpic
	dba UnownEFrontpic
	dba UnownEBackpic
	dba UnownFFrontpic
	dba UnownFBackpic
	dba UnownGFrontpic
	dba UnownGBackpic
	dba UnownHFrontpic
	dba UnownHBackpic
	dba UnownIFrontpic
	dba UnownIBackpic
	dba UnownJFrontpic
	dba UnownJBackpic
	dba UnownKFrontpic
	dba UnownKBackpic
	dba UnownLFrontpic
	dba UnownLBackpic
	dba UnownMFrontpic
	dba UnownMBackpic
	dba UnownNFrontpic
	dba UnownNBackpic
	dba UnownOFrontpic
	dba UnownOBackpic
	dba UnownPFrontpic
	dba UnownPBackpic
	dba UnownQFrontpic
	dba UnownQBackpic
	dba UnownRFrontpic
	dba UnownRBackpic
	dba UnownSFrontpic
	dba UnownSBackpic
	dba UnownTFrontpic
	dba UnownTBackpic
	dba UnownUFrontpic
	dba UnownUBackpic
	dba UnownVFrontpic
	dba UnownVBackpic
	dba UnownWFrontpic
	dba UnownWBackpic
	dba UnownXFrontpic
	dba UnownXBackpic
	dba UnownYFrontpic
	dba UnownYBackpic
	dba UnownZFrontpic
	dba UnownZBackpic
	assert_table_length NUM_UNOWN

MagikarpPicPointers::
; entries correspond to Magikarp's forms, two apiece
	table_width 3 * 2
	dba MagikarpFrontpic
	dba MagikarpBackpic
	dba MagikarpXSFrontpic
	dba MagikarpXSBackpic
	dba MagikarpXLFrontpic
	dba MagikarpXLBackpic
	dba MagikarpRBFrontpic
	dba MagikarpRBBackpic
	assert_table_length NUM_MAGIKARP_FORMS

MachopPicPointers::
; entries correspond to Machop's forms, two apiece
	table_width 3 * 2
	dba MachopFrontpic
	dba MachopBackpic
	dba MachopRBFrontpic
	dba MachopRBBackpic
	assert_table_length NUM_MACHOP_FORMS

MachokePicPointers::
; entries correspond to Machoke's forms, two apiece
	table_width 3 * 2
	dba MachokeFrontpic
	dba MachokeBackpic
	dba MachokeRBFrontpic
	dba MachokeRBBackpic
	assert_table_length NUM_MACHOKE_FORMS

MachampPicPointers::
; entries correspond to Machamp's forms, two apiece
	table_width 3 * 2
	dba MachampFrontpic
	dba MachampBackpic
	dba MachampRBFrontpic
	dba MachampRBBackpic
	assert_table_length NUM_MACHAMP_FORMS

TentacoolPicPointers::
; entries correspond to Tentacool's forms, two apiece
	table_width 3 * 2
	dba TentacoolFrontpic
	dba TentacoolBackpic
	dba TentacoolRBFrontpic
	dba TentacoolRBBackpic
	assert_table_length NUM_TENTACOOL_FORMS

TentacruelPicPointers::
; entries correspond to Tentacruel's forms, two apiece
	table_width 3 * 2
	dba TentacruelFrontpic
	dba TentacruelBackpic
	dba TentacruelRBFrontpic
	dba TentacruelRBBackpic
	assert_table_length NUM_TENTACRUEL_FORMS

EggPicPointers::
; entries correspond to egg patterns (EGG_*_PATTERN), not forms; an egg has no back pic
	table_width 3 * 2
	dba EggPic
	dbw -1, -1
	dba EggElekidPic
	dbw -1, -1
	assert_table_length NUM_EGG_PATTERNS

IgglybuffPicPointers::
; entries correspond to Igglybuff's forms, two apiece
	table_width 3 * 2
	dba IgglybuffFrontpic
	dba IgglybuffBackpic
	dba IgglybuffBetaFrontpic
	dba IgglybuffBetaBackpic
	assert_table_length NUM_IGGLYBUFF_FORMS

JigglypuffPicPointers::
; entries correspond to Jigglypuff's forms, two apiece
	table_width 3 * 2
	dba JigglypuffFrontpic
	dba JigglypuffBackpic
	dba JigglypuffRBFrontpic
	dba JigglypuffRBBackpic
	assert_table_length NUM_JIGGLYPUFF_FORMS

WigglytuffPicPointers::
; entries correspond to Wigglytuff's forms, two apiece
	table_width 3 * 2
	dba WigglytuffFrontpic
	dba WigglytuffBackpic
	dba WigglytuffRBFrontpic
	dba WigglytuffRBBackpic
	assert_table_length NUM_WIGGLYTUFF_FORMS

NidoranMPicPointers::
; entries correspond to NidoranM's forms, two apiece
	table_width 3 * 2
	dba NidoranMFrontpic
	dba NidoranMBackpic
	dba NidoranMRBFrontpic
	dba NidoranMRBBackpic
	assert_table_length NUM_NIDORAN_M_FORMS

NidorinoPicPointers::
; entries correspond to Nidorino's forms, two apiece
	table_width 3 * 2
	dba NidorinoFrontpic
	dba NidorinoBackpic
	dba NidorinoRBFrontpic
	dba NidorinoRBBackpic
	assert_table_length NUM_NIDORINO_FORMS

NidokingPicPointers::
; entries correspond to Nidoking's forms, two apiece
	table_width 3 * 2
	dba NidokingFrontpic
	dba NidokingBackpic
	dba NidokingRBFrontpic
	dba NidokingRBBackpic
	assert_table_length NUM_NIDOKING_FORMS

NidoranFPicPointers::
; entries correspond to NidoranF's forms, two apiece
	table_width 3 * 2
	dba NidoranFFrontpic
	dba NidoranFBackpic
	dba NidoranFRBFrontpic
	dba NidoranFRBBackpic
	assert_table_length NUM_NIDORAN_F_FORMS

NidorinaPicPointers::
; entries correspond to Nidorina's forms, two apiece
	table_width 3 * 2
	dba NidorinaFrontpic
	dba NidorinaBackpic
	dba NidorinaRBFrontpic
	dba NidorinaRBBackpic
	assert_table_length NUM_NIDORINA_FORMS

NidoqueenPicPointers::
; entries correspond to Nidoqueen's forms, two apiece
	table_width 3 * 2
	dba NidoqueenFrontpic
	dba NidoqueenBackpic
	dba NidoqueenRBFrontpic
	dba NidoqueenRBBackpic
	assert_table_length NUM_NIDOQUEEN_FORMS

ZubatPicPointers::
; entries correspond to Zubat's forms, two apiece
	table_width 3 * 2
	dba ZubatFrontpic
	dba ZubatBackpic
	dba ZubatFrontpic
	dba ZubatBackpic ; looks plain
	dba ZubatRBFrontpic
	dba ZubatRBBackpic
	assert_table_length NUM_ZUBAT_FORMS

GeodudePicPointers::
; entries correspond to Geodude's forms, two apiece
	table_width 3 * 2
	dba GeodudeFrontpic
	dba GeodudeBackpic
	dba GeodudeRBFrontpic
	dba GeodudeRBBackpic
	assert_table_length NUM_GEODUDE_FORMS

GravelerPicPointers::
; entries correspond to Graveler's forms, two apiece
	table_width 3 * 2
	dba GravelerFrontpic
	dba GravelerBackpic
	dba GravelerRBFrontpic
	dba GravelerRBBackpic
	assert_table_length NUM_GRAVELER_FORMS

GolemPicPointers::
; entries correspond to Golem's forms, two apiece
	table_width 3 * 2
	dba GolemFrontpic
	dba GolemBackpic
	dba GolemRBFrontpic
	dba GolemRBBackpic
	assert_table_length NUM_GOLEM_FORMS

ShellderPicPointers::
; entries correspond to Shellder's forms, two apiece
	table_width 3 * 2
	dba ShellderFrontpic
	dba ShellderBackpic
	dba ShellderRBFrontpic
	dba ShellderRBBackpic
	assert_table_length NUM_SHELLDER_FORMS

CloysterPicPointers::
; entries correspond to Cloyster's forms, two apiece
	table_width 3 * 2
	dba CloysterFrontpic
	dba CloysterBackpic
	dba CloysterRBFrontpic
	dba CloysterRBBackpic
	assert_table_length NUM_CLOYSTER_FORMS

GastlyPicPointers::
; entries correspond to Gastly's forms, two apiece
	table_width 3 * 2
	dba GastlyFrontpic
	dba GastlyBackpic
	dba GastlyRBFrontpic
	dba GastlyRBBackpic
	assert_table_length NUM_GASTLY_FORMS

HaunterPicPointers::
; entries correspond to Haunter's forms, two apiece
	table_width 3 * 2
	dba HaunterFrontpic
	dba HaunterBackpic
	dba HaunterRBFrontpic
	dba HaunterRBBackpic
	assert_table_length NUM_HAUNTER_FORMS

GengarPicPointers::
; entries correspond to Gengar's forms, two apiece
	table_width 3 * 2
	dba GengarFrontpic
	dba GengarBackpic
	dba GengarRBFrontpic
	dba GengarRBBackpic
	assert_table_length NUM_GENGAR_FORMS

KoffingPicPointers::
; entries correspond to Koffing's forms, two apiece
	table_width 3 * 2
	dba KoffingFrontpic
	dba KoffingBackpic
	dba KoffingFrontpic
	dba KoffingBackpic ; looks plain
	dba KoffingRBFrontpic
	dba KoffingRBBackpic
	assert_table_length NUM_KOFFING_FORMS

HorseaPicPointers::
; entries correspond to Horsea's forms, two apiece
	table_width 3 * 2
	dba HorseaFrontpic
	dba HorseaBackpic
	dba HorseaRBFrontpic
	dba HorseaRBBackpic
	assert_table_length NUM_HORSEA_FORMS

SeadraPicPointers::
; entries correspond to Seadra's forms, two apiece
	table_width 3 * 2
	dba SeadraFrontpic
	dba SeadraBackpic
	dba SeadraRBFrontpic
	dba SeadraRBBackpic
	assert_table_length NUM_SEADRA_FORMS

KingdraPicPointers::
; entries correspond to Kingdra's forms, two apiece
	table_width 3 * 2
	dba KingdraFrontpic
	dba KingdraBackpic
	dba KingdraBetaFrontpic
	dba KingdraBetaBackpic
	assert_table_length NUM_KINGDRA_FORMS

PsyduckPicPointers::
; entries correspond to Psyduck's forms, two apiece
	table_width 3 * 2
	dba PsyduckFrontpic
	dba PsyduckBackpic
	dba PsyduckRBFrontpic
	dba PsyduckRBBackpic
	assert_table_length NUM_PSYDUCK_FORMS

GolduckPicPointers::
; entries correspond to Golduck's forms, two apiece
	table_width 3 * 2
	dba GolduckFrontpic
	dba GolduckBackpic
	dba GolduckRBFrontpic
	dba GolduckRBBackpic
	assert_table_length NUM_GOLDUCK_FORMS

GyaradosPicPointers::
; entries correspond to Gyarados's forms, two apiece
	table_width 3 * 2
	dba GyaradosFrontpic
	dba GyaradosBackpic
	dba GyaradosFrontpic
	dba GyaradosBackpic ; looks plain
	dba GyaradosFrontpic
	dba GyaradosBackpic ; looks plain
	dba GyaradosRBFrontpic
	dba GyaradosRBBackpic
	assert_table_length NUM_GYARADOS_FORMS

StaryuPicPointers::
; entries correspond to Staryu's forms, two apiece
	table_width 3 * 2
	dba StaryuFrontpic
	dba StaryuBackpic
	dba StaryuRBFrontpic
	dba StaryuRBBackpic
	assert_table_length NUM_STARYU_FORMS

StarmiePicPointers::
; entries correspond to Starmie's forms, two apiece
	table_width 3 * 2
	dba StarmieFrontpic
	dba StarmieBackpic
	dba StarmieRBFrontpic
	dba StarmieRBBackpic
	assert_table_length NUM_STARMIE_FORMS

PichuPicPointers::
; entries correspond to Pichu's forms, two apiece
	table_width 3 * 2
	dba PichuFrontpic
	dba PichuBackpic
	dba PichuFrontpic
	dba PichuBackpic ; looks plain
	dba PichuFrontpic
	dba PichuBackpic ; looks plain
	dba PichuBetaFrontpic
	dba PichuBetaBackpic
	assert_table_length NUM_PICHU_FORMS

RaichuPicPointers::
; entries correspond to Raichu's forms, two apiece
	table_width 3 * 2
	dba RaichuFrontpic
	dba RaichuBackpic
	dba RaichuFrontpic
	dba RaichuBackpic ; looks plain
	dba RaichuFrontpic
	dba RaichuBackpic ; looks plain
	dba RaichuRBFrontpic
	dba RaichuRBBackpic
	assert_table_length NUM_RAICHU_FORMS
