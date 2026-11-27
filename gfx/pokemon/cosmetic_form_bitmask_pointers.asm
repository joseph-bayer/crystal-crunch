; Master table for Pokemon bitmask pointers
; Each entry corresponds to a Pokemon species (indexed by species ID)
; Entries for Pokemon with cosmetic forms point to their form-specific pointer tables
; Entries for Pokemon without cosmetic forms are null (0)
	dw 0					; EGG
	dw 0					; NULL
	dw 0					; NULL
	dw 0					; NULL
CosmeticFormBitmaskPointersTable:
	table_width 2
	dw 0					; BULBASAUR (01) - no cosmetic forms
	dw 0					; IVYSAUR (02) - no cosmetic forms
	dw 0					; VENUSAUR (03) - no cosmetic forms
	dw 0					; CHARMANDER (04) - no cosmetic forms
	dw CharmeleonBitmasksPointers		; CHARMELEON (05) - has cosmetic forms
	dw CharizardBitmasksPointers		; CHARIZARD (06) - has cosmetic forms
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
	dw ArbokBitmasksPointers		; ARBOK (18) - has cosmetic forms
	dw PikachuBitmasksPointers		; PIKACHU (19) - has cosmetic forms
	dw RaichuBitmasksPointers		; RAICHU (1a) - has cosmetic forms
	dw 0					; SANDSHREW (1b) - no cosmetic forms
	dw 0					; SANDSLASH (1c) - no cosmetic forms
	dw NidoranFBitmasksPointers		; NIDORAN_F (1d) - has cosmetic forms
	dw NidorinaBitmasksPointers		; NIDORINA (1e) - has cosmetic forms
	dw NidoqueenBitmasksPointers		; NIDOQUEEN (1f) - has cosmetic forms
	dw NidoranMBitmasksPointers		; NIDORAN_M (20) - has cosmetic forms
	dw NidorinoBitmasksPointers		; NIDORINO (21) - has cosmetic forms
	dw NidokingBitmasksPointers		; NIDOKING (22) - has cosmetic forms
	dw 0					; CLEFAIRY (23) - no cosmetic forms
	dw 0					; CLEFABLE (24) - no cosmetic forms
	dw 0					; VULPIX (25) - no cosmetic forms
	dw 0					; NINETALES (26) - no cosmetic forms
	dw JigglypuffBitmasksPointers		; JIGGLYPUFF (27) - has cosmetic forms
	dw WigglytuffBitmasksPointers		; WIGGLYTUFF (28) - has cosmetic forms
	dw ZubatBitmasksPointers		; ZUBAT (29) - has cosmetic forms
	dw GolbatBitmasksPointers		; GOLBAT (2a) - has cosmetic forms
	dw 0					; ODDISH (2b) - no cosmetic forms
	dw 0					; GLOOM (2c) - no cosmetic forms
	dw 0					; VILEPLUME (2d) - no cosmetic forms
	dw 0					; PARAS (2e) - no cosmetic forms
	dw 0					; PARASECT (2f) - no cosmetic forms
	dw VenonatBitmasksPointers	; VENONAT (30) - has cosmetic forms
	dw VenomothBitmasksPointers	; VENOMOTH (31) - has cosmetic forms
	dw 0					; DIGLETT (32) - no cosmetic forms
	dw 0					; DUGTRIO (33) - no cosmetic forms
	dw 0					; MEOWTH (34) - no cosmetic forms
	dw 0					; PERSIAN (35) - no cosmetic forms
	dw PsyduckBitmasksPointers		; PSYDUCK (36) - has cosmetic forms
	dw GolduckBitmasksPointers		; GOLDUCK (37) - has cosmetic forms
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
	dw MachopBitmasksPointers		; MACHOP (42) - has cosmetic forms
	dw MachokeBitmasksPointers		; MACHOKE (43) - has cosmetic forms
	dw MachampBitmasksPointers		; MACHAMP (44) - has cosmetic forms
	dw 0					; BELLSPROUT (45) - no cosmetic forms
	dw 0					; WEEPINBELL (46) - no cosmetic forms
	dw 0					; VICTREEBEL (47) - no cosmetic forms
	dw TentacoolBitmasksPointers		; TENTACOOL (48) - has cosmetic forms
	dw TentacruelBitmasksPointers		; TENTACRUEL (49) - has cosmetic forms
	dw GeodudeBitmasksPointers		; GEODUDE (4a) - has cosmetic forms
	dw GravelerBitmasksPointers		; GRAVELER (4b) - has cosmetic forms
	dw GolemBitmasksPointers		; GOLEM (4c) - has cosmetic forms
	dw 0					; PONYTA (4d) - no cosmetic forms
	dw 0					; RAPIDASH (4e) - no cosmetic forms
	dw 0					; SLOWPOKE (4f) - no cosmetic forms
	dw 0					; SLOWBRO (50) - no cosmetic forms
	dw 0					; MAGNEMITE (51) - no cosmetic forms
	dw 0					; MAGNETON (52) - no cosmetic forms
	dw FarfetchDBitmasksPointers	; FARFETCHD (53) - has cosmetic forms
	dw 0					; DODUO (54) - no cosmetic forms
	dw 0					; DODRIO (55) - no cosmetic forms
	dw 0					; SEEL (56) - no cosmetic forms
	dw 0					; DEWGONG (57) - no cosmetic forms
	dw 0					; GRIMER (58) - no cosmetic forms
	dw 0					; MUK (59) - no cosmetic forms
	dw ShellderBitmasksPointers		; SHELLDER (5a) - has cosmetic forms
	dw CloysterBitmasksPointers		; CLOYSTER (5b) - has cosmetic forms
	dw GastlyBitmasksPointers		; GASTLY (5c) - has cosmetic forms
	dw HaunterBitmasksPointers		; HAUNTER (5d) - has cosmetic forms
	dw GengarBitmasksPointers		; GENGAR (5e) - has cosmetic forms
	dw 0					; ONIX (5f) - no cosmetic forms
	dw 0					; DROWZEE (60) - no cosmetic forms
	dw 0					; HYPNO (61) - no cosmetic forms
	dw 0					; KRABBY (62) - no cosmetic forms
	dw 0					; KINGLER (63) - no cosmetic forms
	dw 0					; VOLTORB (64) - no cosmetic forms
	dw ElectrodeBitmasksPointers		; ELECTRODE (65) - has cosmetic forms
	dw ExeggcuteBitmasksPointers	; EXEGGCUTE (66) - has cosmetic forms
	dw ExeggutorBitmasksPointers	; EXEGGUTOR (67) - has cosmetic forms
	dw CuboneBitmasksPointers	; CUBONE (68) - has cosmetic forms
	dw MarowakBitmasksPointers	; MAROWAK (69) - has cosmetic forms
	dw 0					; HITMONLEE (6a) - no cosmetic forms
	dw 0					; HITMONCHAN (6b) - no cosmetic forms
	dw 0					; LICKITUNG (6c) - no cosmetic forms
	dw KoffingBitmasksPointers		; KOFFING (6d) - has cosmetic forms
	dw WeezingBitmasksPointers		; WEEZING (6e) - has cosmetic forms
	dw RhyhornBitmasksPointers	; RHYHORN (6f) - has cosmetic forms
	dw RhydonBitmasksPointers	; RHYDON (70) - has cosmetic forms
	dw 0					; CHANSEY (71) - no cosmetic forms
	dw 0					; TANGELA (72) - no cosmetic forms
	dw KangaskhanBitmasksPointers	; KANGASKHAN (73) - has cosmetic forms
	dw HorseaBitmasksPointers		; HORSEA (74) - has cosmetic forms
	dw SeadraBitmasksPointers		; SEADRA (75) - has cosmetic forms
	dw 0					; GOLDEEN (76) - no cosmetic forms
	dw 0					; SEAKING (77) - no cosmetic forms
	dw StaryuBitmasksPointers		; STARYU (78) - has cosmetic forms
	dw StarmieBitmasksPointers		; STARMIE (79) - has cosmetic forms
	dw 0					; MR__MIME (7a) - no cosmetic forms
	dw 0					; SCYTHER (7b) - no cosmetic forms
	dw 0					; JYNX (7c) - no cosmetic forms
	dw 0					; ELECTABUZZ (7d) - no cosmetic forms
	dw 0					; MAGMAR (7e) - no cosmetic forms
	dw 0					; PINSIR (7f) - no cosmetic forms
	dw 0					; TAUROS (80) - no cosmetic forms
	dw MagikarpBitmasksPointers		; MAGIKARP (81) - no cosmetic forms
	dw GyaradosBitmasksPointers		; GYARADOS (82) - has cosmetic forms
	dw LaprasBitmasksPointers	; LAPRAS (83) - has cosmetic forms
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
	dw AerodactylBitmasksPointers		; AERODACTYL (8e) - has cosmetic forms
	dw SnorlaxBitmasksPointers		; SNORLAX (8f) - has cosmetic forms
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
	dw CrobatBitmasksPointers		; CROBAT (a9) - has cosmetic forms
	dw 0					; CHINCHOU (aa) - no cosmetic forms
	dw 0					; LANTURN (ab) - no cosmetic forms
	dw PichuBitmasksPointers		; PICHU (ac) - has cosmetic forms
	dw 0					; CLEFFA (ad) - no cosmetic forms
	dw IgglybuffBitmasksPointers		; IGGLYBUFF (ae) - has cosmetic forms
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
	dw UnownBitmasksPointers		; UNOWN (c9) - has cosmetic forms
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
	dw ShuckleBitmasksPointers		; SHUCKLE (d5) - has cosmetic forms
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
	dw KingdraBitmasksPointers		; KINGDRA (e6) - has cosmetic forms
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

PikachuBitmasksPointers:
	table_width 2
	dw PikachuPlainBitmask
	dw PikachuSurfBitmask
	dw PikachuFlyBitmask
	dw PikachuRBBitmask
	assert_table_length NUM_PIKACHU_FORMS

CharmeleonBitmasksPointers:
	table_width 2
	dw CharmeleonPlainBitmask
	dw CharmeleonRocketBitmask
	assert_table_length NUM_CHARMELEON_FORMS

CharizardBitmasksPointers:
	table_width 2
	dw CharizardPlainBitmask
	dw CharizardRocketBitmask
	assert_table_length NUM_CHARIZARD_FORMS

WeezingBitmasksPointers:
	table_width 2
	dw WeezingPlainBitmask
	dw WeezingRocketBitmask
	dw WeezingRBBitmask
	assert_table_length NUM_WEEZING_FORMS

CrobatBitmasksPointers:
	table_width 2
	dw CrobatPlainBitmask
	dw CrobatRocketBitmask
	dw CrobatBetaBitmask
	assert_table_length NUM_CROBAT_FORMS

ElectrodeBitmasksPointers:
	table_width 2
	dw ElectrodePlainBitmask
	dw ElectrodeRocketBitmask
	assert_table_length NUM_ELECTRODE_FORMS

ArbokBitmasksPointers:
	table_width 2
	dw ArbokPlainBitmask
	dw ArbokRocketBitmask
	assert_table_length NUM_ARBOK_FORMS

GolbatBitmasksPointers:
	table_width 2
	dw GolbatPlainBitmask
	dw GolbatRocketBitmask
	dw GolbatRBBitmask
	assert_table_length NUM_GOLBAT_FORMS

SnorlaxBitmasksPointers:
	table_width 2
	dw SnorlaxPlainBitmask
	dw SnorlaxApricornBitmask
	assert_table_length NUM_SNORLAX_FORMS

ShuckleBitmasksPointers:
	table_width 2
	dw ShucklePlainBitmasks
	dw ShuckleShuckieNeutralBitmasks
	dw ShuckleShuckieHappyBitmasks
	assert_table_length NUM_SHUCKLE_FORMS

UnownBitmasksPointers:
	table_width 2
	dw UnownABitmasks
	dw UnownBBitmasks
	dw UnownCBitmasks
	dw UnownDBitmasks
	dw UnownEBitmasks
	dw UnownFBitmasks
	dw UnownGBitmasks
	dw UnownHBitmasks
	dw UnownIBitmasks
	dw UnownJBitmasks
	dw UnownKBitmasks
	dw UnownLBitmasks
	dw UnownMBitmasks
	dw UnownNBitmasks
	dw UnownOBitmasks
	dw UnownPBitmasks
	dw UnownQBitmasks
	dw UnownRBitmasks
	dw UnownSBitmasks
	dw UnownTBitmasks
	dw UnownUBitmasks
	dw UnownVBitmasks
	dw UnownWBitmasks
	dw UnownXBitmasks
	dw UnownYBitmasks
	dw UnownZBitmasks
	assert_table_length NUM_UNOWN

MagikarpBitmasksPointers:
	table_width 2
	dw MagikarpPlainBitmasks
	dw MagikarpXSBitmasks
	dw MagikarpXLBitmasks
	dw MagikarpRBBitmasks
	assert_table_length NUM_MAGIKARP_FORMS

MachopBitmasksPointers:
	table_width 2
	dw MachopPlainBitmask
	dw MachopRBBitmask
	assert_table_length NUM_MACHOP_FORMS

MachokeBitmasksPointers:
	table_width 2
	dw MachokePlainBitmask
	dw MachokeRBBitmask
	assert_table_length NUM_MACHOKE_FORMS

MachampBitmasksPointers:
	table_width 2
	dw MachampPlainBitmask
	dw MachampRBBitmask
	assert_table_length NUM_MACHAMP_FORMS

TentacoolBitmasksPointers:
	table_width 2
	dw TentacoolPlainBitmask
	dw TentacoolRBBitmask
	assert_table_length NUM_TENTACOOL_FORMS

TentacruelBitmasksPointers:
	table_width 2
	dw TentacruelPlainBitmask
	dw TentacruelRBBitmask
	assert_table_length NUM_TENTACRUEL_FORMS

IgglybuffBitmasksPointers:
	table_width 2
	dw IgglybuffPlainBitmask
	dw IgglybuffBetaBitmask
	assert_table_length NUM_IGGLYBUFF_FORMS

JigglypuffBitmasksPointers:
	table_width 2
	dw JigglypuffPlainBitmask
	dw JigglypuffRBBitmask
	assert_table_length NUM_JIGGLYPUFF_FORMS

WigglytuffBitmasksPointers:
	table_width 2
	dw WigglytuffPlainBitmask
	dw WigglytuffRBBitmask
	assert_table_length NUM_WIGGLYTUFF_FORMS

NidoranMBitmasksPointers:
	table_width 2
	dw NidoranMPlainBitmask
	dw NidoranMRBBitmask
	assert_table_length NUM_NIDORAN_M_FORMS

NidorinoBitmasksPointers:
	table_width 2
	dw NidorinoPlainBitmask
	dw NidorinoRBBitmask
	assert_table_length NUM_NIDORINO_FORMS

NidokingBitmasksPointers:
	table_width 2
	dw NidokingPlainBitmask
	dw NidokingRBBitmask
	assert_table_length NUM_NIDOKING_FORMS

NidoranFBitmasksPointers:
	table_width 2
	dw NidoranFPlainBitmask
	dw NidoranFRBBitmask
	assert_table_length NUM_NIDORAN_F_FORMS

NidorinaBitmasksPointers:
	table_width 2
	dw NidorinaPlainBitmask
	dw NidorinaRBBitmask
	assert_table_length NUM_NIDORINA_FORMS

NidoqueenBitmasksPointers:
	table_width 2
	dw NidoqueenPlainBitmask
	dw NidoqueenRBBitmask
	assert_table_length NUM_NIDOQUEEN_FORMS

ZubatBitmasksPointers:
	table_width 2
	dw ZubatPlainBitmask
	dw ZubatPlainBitmask ; looks plain
	dw ZubatRBBitmask
	assert_table_length NUM_ZUBAT_FORMS

GeodudeBitmasksPointers:
	table_width 2
	dw GeodudePlainBitmask
	dw GeodudeRBBitmask
	assert_table_length NUM_GEODUDE_FORMS

GravelerBitmasksPointers:
	table_width 2
	dw GravelerPlainBitmask
	dw GravelerRBBitmask
	assert_table_length NUM_GRAVELER_FORMS

GolemBitmasksPointers:
	table_width 2
	dw GolemPlainBitmask
	dw GolemRBBitmask
	assert_table_length NUM_GOLEM_FORMS

ShellderBitmasksPointers:
	table_width 2
	dw ShellderPlainBitmask
	dw ShellderRBBitmask
	assert_table_length NUM_SHELLDER_FORMS

CloysterBitmasksPointers:
	table_width 2
	dw CloysterPlainBitmask
	dw CloysterRBBitmask
	assert_table_length NUM_CLOYSTER_FORMS

GastlyBitmasksPointers:
	table_width 2
	dw GastlyPlainBitmask
	dw GastlyRBBitmask
	assert_table_length NUM_GASTLY_FORMS

HaunterBitmasksPointers:
	table_width 2
	dw HaunterPlainBitmask
	dw HaunterRBBitmask
	assert_table_length NUM_HAUNTER_FORMS

GengarBitmasksPointers:
	table_width 2
	dw GengarPlainBitmask
	dw GengarRBBitmask
	assert_table_length NUM_GENGAR_FORMS

KoffingBitmasksPointers:
	table_width 2
	dw KoffingPlainBitmask
	dw KoffingPlainBitmask ; looks plain
	dw KoffingRBBitmask
	assert_table_length NUM_KOFFING_FORMS

HorseaBitmasksPointers:
	table_width 2
	dw HorseaPlainBitmask
	dw HorseaRBBitmask
	assert_table_length NUM_HORSEA_FORMS

SeadraBitmasksPointers:
	table_width 2
	dw SeadraPlainBitmask
	dw SeadraRBBitmask
	assert_table_length NUM_SEADRA_FORMS

KingdraBitmasksPointers:
	table_width 2
	dw KingdraPlainBitmask
	dw KingdraBetaBitmask
	assert_table_length NUM_KINGDRA_FORMS

PsyduckBitmasksPointers:
	table_width 2
	dw PsyduckPlainBitmask
	dw PsyduckRBBitmask
	assert_table_length NUM_PSYDUCK_FORMS

GolduckBitmasksPointers:
	table_width 2
	dw GolduckPlainBitmask
	dw GolduckRBBitmask
	assert_table_length NUM_GOLDUCK_FORMS

GyaradosBitmasksPointers:
	table_width 2
	dw GyaradosPlainBitmask
	dw GyaradosPlainBitmask ; looks plain
	dw GyaradosPlainBitmask ; looks plain
	dw GyaradosRBBitmask
	assert_table_length NUM_GYARADOS_FORMS

StaryuBitmasksPointers:
	table_width 2
	dw StaryuPlainBitmask
	dw StaryuRBBitmask
	assert_table_length NUM_STARYU_FORMS

StarmieBitmasksPointers:
	table_width 2
	dw StarmiePlainBitmask
	dw StarmieRBBitmask
	assert_table_length NUM_STARMIE_FORMS

AerodactylBitmasksPointers:
	table_width 2
	dw AerodactylPlainBitmask
	dw AerodactylRBBitmask
	assert_table_length NUM_AERODACTYL_FORMS

RhyhornBitmasksPointers:
	table_width 2
	dw RhyhornPlainBitmask
	dw RhyhornRBBitmask
	assert_table_length NUM_RHYHORN_FORMS

RhydonBitmasksPointers:
	table_width 2
	dw RhydonPlainBitmask
	dw RhydonRBBitmask
	assert_table_length NUM_RHYDON_FORMS

KangaskhanBitmasksPointers:
	table_width 2
	dw KangaskhanPlainBitmask
	dw KangaskhanRBBitmask
	assert_table_length NUM_KANGASKHAN_FORMS

VenonatBitmasksPointers:
	table_width 2
	dw VenonatPlainBitmask
	dw VenonatRBBitmask
	assert_table_length NUM_VENONAT_FORMS

VenomothBitmasksPointers:
	table_width 2
	dw VenomothPlainBitmask
	dw VenomothRBBitmask
	assert_table_length NUM_VENOMOTH_FORMS

LaprasBitmasksPointers:
	table_width 2
	dw LaprasPlainBitmask
	dw LaprasRBBitmask
	assert_table_length NUM_LAPRAS_FORMS

FarfetchDBitmasksPointers:
	table_width 2
	dw FarfetchDPlainBitmask
	dw FarfetchDRBBitmask
	assert_table_length NUM_FARFETCH_D_FORMS

CuboneBitmasksPointers:
	table_width 2
	dw CubonePlainBitmask
	dw CuboneRBBitmask
	assert_table_length NUM_CUBONE_FORMS

MarowakBitmasksPointers:
	table_width 2
	dw MarowakPlainBitmask
	dw MarowakRBBitmask
	assert_table_length NUM_MAROWAK_FORMS

ExeggcuteBitmasksPointers:
	table_width 2
	dw ExeggcutePlainBitmask
	dw ExeggcuteRBBitmask
	assert_table_length NUM_EXEGGCUTE_FORMS

ExeggutorBitmasksPointers:
	table_width 2
	dw ExeggutorPlainBitmask
	dw ExeggutorRBBitmask
	assert_table_length NUM_EXEGGUTOR_FORMS

PichuBitmasksPointers:
	table_width 2
	dw PichuPlainBitmask
	dw PichuPlainBitmask ; looks plain
	dw PichuPlainBitmask ; looks plain
	dw PichuBetaBitmask
	assert_table_length NUM_PICHU_FORMS

RaichuBitmasksPointers:
	table_width 2
	dw RaichuPlainBitmask
	dw RaichuPlainBitmask ; looks plain
	dw RaichuPlainBitmask ; looks plain
	dw RaichuRBBitmask
	assert_table_length NUM_RAICHU_FORMS
