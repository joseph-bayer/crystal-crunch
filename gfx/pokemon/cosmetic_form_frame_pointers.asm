; Master table for Pokemon frame pointers
; Each entry corresponds to a Pokemon species (indexed by species ID)
; Entries for Pokemon with cosmetic forms point to their form-specific pointer tables
; Entries for Pokemon without cosmetic forms are null (0)
	dw 0					; EGG
	dw 0					; NULL
	dw 0					; NULL
	dw 0					; NULL
CosmeticFormFramePointersTable:
	table_width 2
	dw 0					; BULBASAUR (01) - no cosmetic forms
	dw 0					; IVYSAUR (02) - no cosmetic forms
	dw 0					; VENUSAUR (03) - no cosmetic forms
	dw 0					; CHARMANDER (04) - no cosmetic forms
	dw CharmeleonFramesPointers		; CHARMELEON (05) - has cosmetic forms
	dw CharizardFramesPointers		; CHARIZARD (06) - has cosmetic forms
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
	dw ArbokFramesPointers		; ARBOK (18) - has cosmetic forms
	dw PikachuFramesPointers		; PIKACHU (19) - has cosmetic forms
	dw RaichuFramesPointers		; RAICHU (1a) - has cosmetic forms
	dw 0					; SANDSHREW (1b) - no cosmetic forms
	dw 0					; SANDSLASH (1c) - no cosmetic forms
	dw NidoranFFramesPointers		; NIDORAN_F (1d) - has cosmetic forms
	dw NidorinaFramesPointers		; NIDORINA (1e) - has cosmetic forms
	dw NidoqueenFramesPointers		; NIDOQUEEN (1f) - has cosmetic forms
	dw NidoranMFramesPointers		; NIDORAN_M (20) - has cosmetic forms
	dw NidorinoFramesPointers		; NIDORINO (21) - has cosmetic forms
	dw NidokingFramesPointers		; NIDOKING (22) - has cosmetic forms
	dw 0					; CLEFAIRY (23) - no cosmetic forms
	dw 0					; CLEFABLE (24) - no cosmetic forms
	dw 0					; VULPIX (25) - no cosmetic forms
	dw 0					; NINETALES (26) - no cosmetic forms
	dw JigglypuffFramesPointers		; JIGGLYPUFF (27) - has cosmetic forms
	dw WigglytuffFramesPointers		; WIGGLYTUFF (28) - has cosmetic forms
	dw ZubatFramesPointers		; ZUBAT (29) - has cosmetic forms
	dw GolbatFramesPointers		; GOLBAT (2a) - has cosmetic forms
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
	dw PsyduckFramesPointers		; PSYDUCK (36) - has cosmetic forms
	dw GolduckFramesPointers		; GOLDUCK (37) - has cosmetic forms
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
	dw MachopFramesPointers		; MACHOP (42) - has cosmetic forms
	dw MachokeFramesPointers		; MACHOKE (43) - has cosmetic forms
	dw MachampFramesPointers		; MACHAMP (44) - has cosmetic forms
	dw 0					; BELLSPROUT (45) - no cosmetic forms
	dw 0					; WEEPINBELL (46) - no cosmetic forms
	dw 0					; VICTREEBEL (47) - no cosmetic forms
	dw TentacoolFramesPointers		; TENTACOOL (48) - has cosmetic forms
	dw TentacruelFramesPointers		; TENTACRUEL (49) - has cosmetic forms
	dw GeodudeFramesPointers		; GEODUDE (4a) - has cosmetic forms
	dw GravelerFramesPointers		; GRAVELER (4b) - has cosmetic forms
	dw GolemFramesPointers		; GOLEM (4c) - has cosmetic forms
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
	dw ShellderFramesPointers		; SHELLDER (5a) - has cosmetic forms
	dw CloysterFramesPointers		; CLOYSTER (5b) - has cosmetic forms
	dw GastlyFramesPointers		; GASTLY (5c) - has cosmetic forms
	dw HaunterFramesPointers		; HAUNTER (5d) - has cosmetic forms
	dw GengarFramesPointers		; GENGAR (5e) - has cosmetic forms
	dw 0					; ONIX (5f) - no cosmetic forms
	dw 0					; DROWZEE (60) - no cosmetic forms
	dw 0					; HYPNO (61) - no cosmetic forms
	dw 0					; KRABBY (62) - no cosmetic forms
	dw 0					; KINGLER (63) - no cosmetic forms
	dw 0					; VOLTORB (64) - no cosmetic forms
	dw ElectrodeFramesPointers		; ELECTRODE (65) - has cosmetic forms
	dw 0					; EXEGGCUTE (66) - no cosmetic forms
	dw 0					; EXEGGUTOR (67) - no cosmetic forms
	dw 0					; CUBONE (68) - no cosmetic forms
	dw 0					; MAROWAK (69) - no cosmetic forms
	dw 0					; HITMONLEE (6a) - no cosmetic forms
	dw 0					; HITMONCHAN (6b) - no cosmetic forms
	dw 0					; LICKITUNG (6c) - no cosmetic forms
	dw KoffingFramesPointers		; KOFFING (6d) - has cosmetic forms
	dw WeezingFramesPointers		; WEEZING (6e) - has cosmetic forms
	dw 0					; RHYHORN (6f) - no cosmetic forms
	dw 0					; RHYDON (70) - no cosmetic forms
	dw 0					; CHANSEY (71) - no cosmetic forms
	dw 0					; TANGELA (72) - no cosmetic forms
	dw 0					; KANGASKHAN (73) - no cosmetic forms
	dw HorseaFramesPointers		; HORSEA (74) - has cosmetic forms
	dw SeadraFramesPointers		; SEADRA (75) - has cosmetic forms
	dw 0					; GOLDEEN (76) - no cosmetic forms
	dw 0					; SEAKING (77) - no cosmetic forms
	dw StaryuFramesPointers		; STARYU (78) - has cosmetic forms
	dw StarmieFramesPointers		; STARMIE (79) - has cosmetic forms
	dw 0					; MR__MIME (7a) - no cosmetic forms
	dw 0					; SCYTHER (7b) - no cosmetic forms
	dw 0					; JYNX (7c) - no cosmetic forms
	dw 0					; ELECTABUZZ (7d) - no cosmetic forms
	dw 0					; MAGMAR (7e) - no cosmetic forms
	dw 0					; PINSIR (7f) - no cosmetic forms
	dw 0					; TAUROS (80) - no cosmetic forms
	dw MagikarpFramesPointers		; MAGIKARP (81) - no cosmetic forms
	dw GyaradosFramesPointers		; GYARADOS (82) - has cosmetic forms
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
	dw AerodactylFramesPointers		; AERODACTYL (8e) - has cosmetic forms
	dw SnorlaxFramesPointers		; SNORLAX (8f) - has cosmetic forms
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
	dw CrobatFramesPointers			; CROBAT (a9) - has cosmetic forms
	dw 0					; CHINCHOU (aa) - no cosmetic forms
	dw 0					; LANTURN (ab) - no cosmetic forms
	dw PichuFramesPointers		; PICHU (ac) - has cosmetic forms
	dw 0					; CLEFFA (ad) - no cosmetic forms
	dw IgglybuffFramesPointers		; IGGLYBUFF (ae) - has cosmetic forms
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
	dw UnownFramesPointers			; UNOWN (c9) - has cosmetic forms
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
	dw ShuckleFramesPointers		; SHUCKLE (d5) - has cosmetic forms
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
	dw KingdraFramesPointers		; KINGDRA (e6) - has cosmetic forms
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

PikachuFramesPointers:
	table_width 2
	dw PikachuPlainFrames
	dw PikachuSurfFrames
	dw PikachuFlyFrames
	dw PikachuRBFrames
	assert_table_length NUM_PIKACHU_FORMS

CharmeleonFramesPointers:
	table_width 2
	dw CharmeleonPlainFrames
	dw CharmeleonRocketFrames
	assert_table_length NUM_CHARMELEON_FORMS

CharizardFramesPointers:
	table_width 2
	dw CharizardPlainFrames
	dw CharizardRocketFrames
	assert_table_length NUM_CHARIZARD_FORMS

WeezingFramesPointers:
	table_width 2
	dw WeezingPlainFrames
	dw WeezingRocketFrames
	dw WeezingRBFrames
	assert_table_length NUM_WEEZING_FORMS

CrobatFramesPointers:
	table_width 2
	dw CrobatPlainFrames
	dw CrobatRocketFrames
	dw CrobatBetaFrames
	assert_table_length NUM_CROBAT_FORMS

ElectrodeFramesPointers:
	table_width 2
	dw ElectrodePlainFrames
	dw ElectrodeRocketFrames
	assert_table_length NUM_ELECTRODE_FORMS

ArbokFramesPointers:
	table_width 2
	dw ArbokPlainFrames
	dw ArbokRocketFrames
	assert_table_length NUM_ARBOK_FORMS

GolbatFramesPointers:
	table_width 2
	dw GolbatPlainFrames
	dw GolbatRocketFrames
	dw GolbatRBFrames
	assert_table_length NUM_GOLBAT_FORMS

SnorlaxFramesPointers:
	table_width 2
	dw SnorlaxPlainFrames
	dw SnorlaxApricornFrames
	assert_table_length NUM_SNORLAX_FORMS

ShuckleFramesPointers:
	table_width 2
	dw ShucklePlainFrames
	dw ShuckleShuckieNeutralFrames
	dw ShuckleShuckieHappyFrames
	assert_table_length NUM_SHUCKLE_FORMS

UnownFramesPointers:
	table_width 2
	dw UnownAFrames
	dw UnownBFrames
	dw UnownCFrames
	dw UnownDFrames
	dw UnownEFrames
	dw UnownFFrames
	dw UnownGFrames
	dw UnownHFrames
	dw UnownIFrames
	dw UnownJFrames
	dw UnownKFrames
	dw UnownLFrames
	dw UnownMFrames
	dw UnownNFrames
	dw UnownOFrames
	dw UnownPFrames
	dw UnownQFrames
	dw UnownRFrames
	dw UnownSFrames
	dw UnownTFrames
	dw UnownUFrames
	dw UnownVFrames
	dw UnownWFrames
	dw UnownXFrames
	dw UnownYFrames
	dw UnownZFrames
	assert_table_length NUM_UNOWN

MagikarpFramesPointers:
	table_width 2
	dw MagikarpPlainFrames
	dw MagikarpXSFrames
	dw MagikarpXLFrames
	dw MagikarpRBFrames
	assert_table_length NUM_MAGIKARP_FORMS

MachopFramesPointers:
	table_width 2
	dw MachopPlainFrames
	dw MachopRBFrames
	assert_table_length NUM_MACHOP_FORMS

MachokeFramesPointers:
	table_width 2
	dw MachokePlainFrames
	dw MachokeRBFrames
	assert_table_length NUM_MACHOKE_FORMS

MachampFramesPointers:
	table_width 2
	dw MachampPlainFrames
	dw MachampRBFrames
	assert_table_length NUM_MACHAMP_FORMS

TentacoolFramesPointers:
	table_width 2
	dw TentacoolPlainFrames
	dw TentacoolRBFrames
	assert_table_length NUM_TENTACOOL_FORMS

TentacruelFramesPointers:
	table_width 2
	dw TentacruelPlainFrames
	dw TentacruelRBFrames
	assert_table_length NUM_TENTACRUEL_FORMS

IgglybuffFramesPointers:
	table_width 2
	dw IgglybuffPlainFrames
	dw IgglybuffBetaFrames
	assert_table_length NUM_IGGLYBUFF_FORMS

JigglypuffFramesPointers:
	table_width 2
	dw JigglypuffPlainFrames
	dw JigglypuffRBFrames
	assert_table_length NUM_JIGGLYPUFF_FORMS

WigglytuffFramesPointers:
	table_width 2
	dw WigglytuffPlainFrames
	dw WigglytuffRBFrames
	assert_table_length NUM_WIGGLYTUFF_FORMS

NidoranMFramesPointers:
	table_width 2
	dw NidoranMPlainFrames
	dw NidoranMRBFrames
	assert_table_length NUM_NIDORAN_M_FORMS

NidorinoFramesPointers:
	table_width 2
	dw NidorinoPlainFrames
	dw NidorinoRBFrames
	assert_table_length NUM_NIDORINO_FORMS

NidokingFramesPointers:
	table_width 2
	dw NidokingPlainFrames
	dw NidokingRBFrames
	assert_table_length NUM_NIDOKING_FORMS

NidoranFFramesPointers:
	table_width 2
	dw NidoranFPlainFrames
	dw NidoranFRBFrames
	assert_table_length NUM_NIDORAN_F_FORMS

NidorinaFramesPointers:
	table_width 2
	dw NidorinaPlainFrames
	dw NidorinaRBFrames
	assert_table_length NUM_NIDORINA_FORMS

NidoqueenFramesPointers:
	table_width 2
	dw NidoqueenPlainFrames
	dw NidoqueenRBFrames
	assert_table_length NUM_NIDOQUEEN_FORMS

ZubatFramesPointers:
	table_width 2
	dw ZubatPlainFrames
	dw ZubatPlainFrames ; looks plain
	dw ZubatRBFrames
	assert_table_length NUM_ZUBAT_FORMS

GeodudeFramesPointers:
	table_width 2
	dw GeodudePlainFrames
	dw GeodudeRBFrames
	assert_table_length NUM_GEODUDE_FORMS

GravelerFramesPointers:
	table_width 2
	dw GravelerPlainFrames
	dw GravelerRBFrames
	assert_table_length NUM_GRAVELER_FORMS

GolemFramesPointers:
	table_width 2
	dw GolemPlainFrames
	dw GolemRBFrames
	assert_table_length NUM_GOLEM_FORMS

ShellderFramesPointers:
	table_width 2
	dw ShellderPlainFrames
	dw ShellderRBFrames
	assert_table_length NUM_SHELLDER_FORMS

CloysterFramesPointers:
	table_width 2
	dw CloysterPlainFrames
	dw CloysterRBFrames
	assert_table_length NUM_CLOYSTER_FORMS

GastlyFramesPointers:
	table_width 2
	dw GastlyPlainFrames
	dw GastlyRBFrames
	assert_table_length NUM_GASTLY_FORMS

HaunterFramesPointers:
	table_width 2
	dw HaunterPlainFrames
	dw HaunterRBFrames
	assert_table_length NUM_HAUNTER_FORMS

GengarFramesPointers:
	table_width 2
	dw GengarPlainFrames
	dw GengarRBFrames
	assert_table_length NUM_GENGAR_FORMS

KoffingFramesPointers:
	table_width 2
	dw KoffingPlainFrames
	dw KoffingPlainFrames ; looks plain
	dw KoffingRBFrames
	assert_table_length NUM_KOFFING_FORMS

HorseaFramesPointers:
	table_width 2
	dw HorseaPlainFrames
	dw HorseaRBFrames
	assert_table_length NUM_HORSEA_FORMS

SeadraFramesPointers:
	table_width 2
	dw SeadraPlainFrames
	dw SeadraRBFrames
	assert_table_length NUM_SEADRA_FORMS

KingdraFramesPointers:
	table_width 2
	dw KingdraPlainFrames
	dw KingdraBetaFrames
	assert_table_length NUM_KINGDRA_FORMS

PsyduckFramesPointers:
	table_width 2
	dw PsyduckPlainFrames
	dw PsyduckRBFrames
	assert_table_length NUM_PSYDUCK_FORMS

GolduckFramesPointers:
	table_width 2
	dw GolduckPlainFrames
	dw GolduckRBFrames
	assert_table_length NUM_GOLDUCK_FORMS

GyaradosFramesPointers:
	table_width 2
	dw GyaradosPlainFrames
	dw GyaradosPlainFrames ; looks plain
	dw GyaradosPlainFrames ; looks plain
	dw GyaradosRBFrames
	assert_table_length NUM_GYARADOS_FORMS

StaryuFramesPointers:
	table_width 2
	dw StaryuPlainFrames
	dw StaryuRBFrames
	assert_table_length NUM_STARYU_FORMS

StarmieFramesPointers:
	table_width 2
	dw StarmiePlainFrames
	dw StarmieRBFrames
	assert_table_length NUM_STARMIE_FORMS

AerodactylFramesPointers:
	table_width 2
	dw AerodactylPlainFrames
	dw AerodactylRBFrames
	assert_table_length NUM_AERODACTYL_FORMS

PichuFramesPointers:
	table_width 2
	dw PichuPlainFrames
	dw PichuPlainFrames ; looks plain
	dw PichuPlainFrames ; looks plain
	dw PichuBetaFrames
	assert_table_length NUM_PICHU_FORMS

RaichuFramesPointers:
	table_width 2
	dw RaichuPlainFrames
	dw RaichuPlainFrames ; looks plain
	dw RaichuPlainFrames ; looks plain
	dw RaichuRBFrames
	assert_table_length NUM_RAICHU_FORMS
