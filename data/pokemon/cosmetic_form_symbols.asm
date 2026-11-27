; Master table for Pokemon symbols (used in battle HUD and stats screen)
; Each entry corresponds to a Pokemon species (indexed by species ID)
; Entries for Pokemon with cosmetic forms point to their form-specific pointer tables
; Entries for Pokemon without cosmetic forms are null (0)
	dw 0					; EGG
	dw 0					; NULL
	dw 0					; NULL
	dw 0					; NULL
CosmeticFormSymbols::
	table_width 2
	dw 0					; BULBASAUR (01)
	dw 0					; IVYSAUR (02)
	dw 0					; VENUSAUR (03)
	dw 0					; CHARMANDER (04)
	dw CharmeleonFormSymbols		; CHARMELEON (05)
	dw CharizardFormSymbols			; CHARIZARD (06)
	dw 0					; SQUIRTLE (07)
	dw 0					; WARTORTLE (08)
	dw 0					; BLASTOISE (09)
	dw 0					; CATERPIE (0a)
	dw 0					; METAPOD (0b)
	dw 0					; BUTTERFREE (0c)
	dw 0					; WEEDLE (0d)
	dw 0					; KAKUNA (0e)
	dw 0					; BEEDRILL (0f)
	dw 0					; PIDGEY (10)
	dw 0					; PIDGEOTTO (11)
	dw 0					; PIDGEOT (12)
	dw 0					; RATTATA (13)
	dw 0					; RATICATE (14)
	dw 0					; SPEAROW (15)
	dw 0					; FEAROW (16)
	dw 0					; EKANS (17)
	dw ArbokFormSymbols		; ARBOK (18)
	dw PikachuFormSymbols			; PIKACHU (19)
	dw RaichuFormSymbols			; RAICHU (1a)
	dw 0					; SANDSHREW (1b)
	dw 0					; SANDSLASH (1c)
	dw NidoranFFormSymbols			; NIDORAN_F (1d)
	dw NidorinaFormSymbols			; NIDORINA (1e)
	dw NidoqueenFormSymbols			; NIDOQUEEN (1f)
	dw NidoranMFormSymbols			; NIDORAN_M (20)
	dw NidorinoFormSymbols			; NIDORINO (21)
	dw NidokingFormSymbols			; NIDOKING (22)
	dw 0					; CLEFAIRY (23)
	dw 0					; CLEFABLE (24)
	dw 0					; VULPIX (25)
	dw 0					; NINETALES (26)
	dw JigglypuffFormSymbols			; JIGGLYPUFF (27)
	dw WigglytuffFormSymbols			; WIGGLYTUFF (28)
	dw ZubatFormSymbols			; ZUBAT (29)
	dw GolbatFormSymbols			; GOLBAT (2a)
	dw 0					; ODDISH (2b)
	dw 0					; GLOOM (2c)
	dw 0					; VILEPLUME (2d)
	dw 0					; PARAS (2e)
	dw 0					; PARASECT (2f)
	dw VenonatFormSymbols		; VENONAT (30)
	dw VenomothFormSymbols		; VENOMOTH (31)
	dw 0					; DIGLETT (32)
	dw 0					; DUGTRIO (33)
	dw 0					; MEOWTH (34)
	dw 0					; PERSIAN (35)
	dw PsyduckFormSymbols			; PSYDUCK (36)
	dw GolduckFormSymbols			; GOLDUCK (37)
	dw 0					; MANKEY (38)
	dw 0					; PRIMEAPE (39)
	dw 0					; GROWLITHE (3a)
	dw 0					; ARCANINE (3b)
	dw 0					; POLIWAG (3c)
	dw 0					; POLIWHIRL (3d)
	dw 0					; POLIWRATH (3e)
	dw 0					; ABRA (3f)
	dw 0					; KADABRA (40)
	dw 0					; ALAKAZAM (41)
	dw MachopFormSymbols			; MACHOP (42)
	dw MachokeFormSymbols			; MACHOKE (43)
	dw MachampFormSymbols			; MACHAMP (44)
	dw 0					; BELLSPROUT (45)
	dw 0					; WEEPINBELL (46)
	dw 0					; VICTREEBEL (47)
	dw TentacoolFormSymbols			; TENTACOOL (48)
	dw TentacruelFormSymbols			; TENTACRUEL (49)
	dw GeodudeFormSymbols			; GEODUDE (4a)
	dw GravelerFormSymbols			; GRAVELER (4b)
	dw GolemFormSymbols			; GOLEM (4c)
	dw 0					; PONYTA (4d)
	dw 0					; RAPIDASH (4e)
	dw 0					; SLOWPOKE (4f)
	dw 0					; SLOWBRO (50)
	dw 0					; MAGNEMITE (51)
	dw 0					; MAGNETON (52)
	dw FarfetchDFormSymbols	; FARFETCHD (53)
	dw 0					; DODUO (54)
	dw 0					; DODRIO (55)
	dw 0					; SEEL (56)
	dw 0					; DEWGONG (57)
	dw 0					; GRIMER (58)
	dw 0					; MUK (59)
	dw ShellderFormSymbols			; SHELLDER (5a)
	dw CloysterFormSymbols			; CLOYSTER (5b)
	dw GastlyFormSymbols			; GASTLY (5c)
	dw HaunterFormSymbols			; HAUNTER (5d)
	dw GengarFormSymbols			; GENGAR (5e)
	dw 0					; ONIX (5f)
	dw 0					; DROWZEE (60)
	dw 0					; HYPNO (61)
	dw 0					; KRABBY (62)
	dw 0					; KINGLER (63)
	dw 0					; VOLTORB (64)
	dw ElectrodeFormSymbols			; ELECTRODE (65)
	dw ExeggcuteFormSymbols	; EXEGGCUTE (66)
	dw ExeggutorFormSymbols	; EXEGGUTOR (67)
	dw CuboneFormSymbols		; CUBONE (68)
	dw MarowakFormSymbols		; MAROWAK (69)
	dw 0					; HITMONLEE (6a)
	dw 0					; HITMONCHAN (6b)
	dw 0					; LICKITUNG (6c)
	dw KoffingFormSymbols			; KOFFING (6d)
	dw WeezingFormSymbols			; WEEZING (6e)
	dw RhyhornFormSymbols		; RHYHORN (6f)
	dw RhydonFormSymbols		; RHYDON (70)
	dw 0					; CHANSEY (71)
	dw 0					; TANGELA (72)
	dw KangaskhanFormSymbols	; KANGASKHAN (73)
	dw HorseaFormSymbols			; HORSEA (74)
	dw SeadraFormSymbols			; SEADRA (75)
	dw 0					; GOLDEEN (76)
	dw 0					; SEAKING (77)
	dw StaryuFormSymbols			; STARYU (78)
	dw StarmieFormSymbols			; STARMIE (79)
	dw 0					; MR__MIME (7a)
	dw 0					; SCYTHER (7b)
	dw 0					; JYNX (7c)
	dw 0					; ELECTABUZZ (7d)
	dw 0					; MAGMAR (7e)
	dw 0					; PINSIR (7f)
	dw 0					; TAUROS (80)
	dw MagikarpFormSymbols			; MAGIKARP (81)
	dw GyaradosFormSymbols			; GYARADOS (82)
	dw LaprasFormSymbols		; LAPRAS (83)
	dw 0					; DITTO (84)
	dw 0					; EEVEE (85)
	dw 0					; VAPOREON (86)
	dw 0					; JOLTEON (87)
	dw 0					; FLAREON (88)
	dw 0					; PORYGON (89)
	dw 0					; OMANYTE (8a)
	dw 0					; OMASTAR (8b)
	dw 0					; KABUTO (8c)
	dw 0					; KABUTOPS (8d)
	dw AerodactylFormSymbols			; AERODACTYL (8e)
	dw 0					; SNORLAX (8f)
	dw 0					; ARTICUNO (90)
	dw 0					; ZAPDOS (91)
	dw 0					; MOLTRES (92)
	dw DratiniFormSymbols		; DRATINI (93)
	dw DragonairFormSymbols	; DRAGONAIR (94)
	dw DragoniteFormSymbols	; DRAGONITE (95)
	dw 0					; MEWTWO (96)
	dw 0					; MEW (97)
	dw 0					; CHIKORITA (98)
	dw 0					; BAYLEEF (99)
	dw 0					; MEGANIUM (9a)
	dw 0					; CYNDAQUIL (9b)
	dw 0					; QUILAVA (9c)
	dw 0					; TYPHLOSION (9d)
	dw 0					; TOTODILE (9e)
	dw 0					; CROCONAW (9f)
	dw 0					; FERALIGATR (a0)
	dw 0					; SENTRET (a1)
	dw 0					; FURRET (a2)
	dw 0					; HOOTHOOT (a3)
	dw 0					; NOCTOWL (a4)
	dw 0					; LEDYBA (a5)
	dw 0					; LEDIAN (a6)
	dw 0					; SPINARAK (a7)
	dw 0					; ARIADOS (a8)
	dw CrobatFormSymbols			; CROBAT (a9)
	dw 0					; CHINCHOU (aa)
	dw 0					; LANTURN (ab)
	dw PichuFormSymbols			; PICHU (ac)
	dw 0					; CLEFFA (ad)
	dw IgglybuffFormSymbols			; IGGLYBUFF (ae)
	dw 0					; TOGEPI (af)
	dw 0					; TOGETIC (b0)
	dw 0					; NATU (b1)
	dw 0					; XATU (b2)
	dw 0					; MAREEP (b3)
	dw 0					; FLAAFFY (b4)
	dw 0					; AMPHAROS (b5)
	dw 0					; BELLOSSOM (b6)
	dw 0					; MARILL (b7)
	dw 0					; AZUMARILL (b8)
	dw 0					; SUDOWOODO (b9)
	dw 0					; POLITOED (ba)
	dw 0					; HOPPIP (bb)
	dw 0					; SKIPLOOM (bc)
	dw 0					; JUMPLUFF (bd)
	dw 0					; AIPOM (be)
	dw 0					; SUNKERN (bf)
	dw 0					; SUNFLORA (c0)
	dw 0					; YANMA (c1)
	dw 0					; WOOPER (c2)
	dw 0					; QUAGSIRE (c3)
	dw 0					; ESPEON (c4)
	dw 0					; UMBREON (c5)
	dw 0					; MURKROW (c6)
	dw 0					; SLOWKING (c7)
	dw 0					; MISDREAVUS (c8)
	dw 0					; UNOWN (c9)
	dw 0					; WOBBUFFET (ca)
	dw 0					; GIRAFARIG (cb)
	dw 0					; PINECO (cc)
	dw 0					; FORRETRESS (cd)
	dw 0					; DUNSPARCE (ce)
	dw 0					; GLIGAR (cf)
	dw 0					; STEELIX (d0)
	dw 0					; SNUBBULL (d1)
	dw 0					; GRANBULL (d2)
	dw 0					; QWILFISH (d3)
	dw 0					; SCIZOR (d4)
	dw 0					; SHUCKLE (d5)
	dw 0					; HERACROSS (d6)
	dw 0					; SNEASEL (d7)
	dw 0					; TEDDIURSA (d8)
	dw 0					; URSARING (d9)
	dw 0					; SLUGMA (da)
	dw 0					; MAGCARGO (db)
	dw 0					; SWINUB (dc)
	dw 0					; PILOSWINE (dd)
	dw 0					; CORSOLA (de)
	dw 0					; REMORAID (df)
	dw 0					; OCTILLERY (e0)
	dw 0					; DELIBIRD (e1)
	dw 0					; MANTINE (e2)
	dw 0					; SKARMORY (e3)
	dw 0					; HOUNDOUR (e4)
	dw 0					; HOUNDOOM (e5)
	dw KingdraFormSymbols			; KINGDRA (e6)
	dw 0					; PHANPY (e7)
	dw 0					; DONPHAN (e8)
	dw 0					; PORYGON2 (e9)
	dw 0					; STANTLER (ea)
	dw 0					; SMEARGLE (eb)
	dw 0					; TYROGUE (ec)
	dw 0					; HITMONTOP (ed)
	dw 0					; SMOOCHUM (ee)
	dw 0					; ELEKID (ef)
	dw 0					; MAGBY (f0)
	dw 0					; MILTANK (f1)
	dw 0					; BLISSEY (f2)
	dw 0					; RAIKOU (f3)
	dw 0					; ENTEI (f4)
	dw 0					; SUICUNE (f5)
	dw 0					; LARVITAR (f6)
	dw 0					; PUPITAR (f7)
	dw 0					; TYRANITAR (f8)
	dw 0					; LUGIA (f9)
	dw 0					; HO_OH (fa)
	dw 0					; CELEBI (fb)
	dw 0					; NEW_MON_1 (fc)
	dw 0					; NEW_MON_2 (fd)
	dw 0					; NEW_MON_3 (fe)
	dw 0					; NEW_MON_4 (ff)
	dw 0					; NEW_MON_5 (100)
	assert_table_length NUM_POKEMON

PikachuFormSymbols:
	table_width 1
	db 0
	db 0
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_PIKACHU_FORMS

CharmeleonFormSymbols:
	table_width 1
	db 0
	db "<ROCKET_LOGO>"
	assert_table_length NUM_CHARMELEON_FORMS

CharizardFormSymbols:
	table_width 1
	db 0
	db "<ROCKET_LOGO>"
	assert_table_length NUM_CHARIZARD_FORMS

WeezingFormSymbols:
	table_width 1
	db 0
	db "<ROCKET_LOGO>"
	db "<CARTRIDGE>"
	assert_table_length NUM_WEEZING_FORMS

CrobatFormSymbols:
	table_width 1
	db 0
	db "<ROCKET_LOGO>"
	db "<CARTRIDGE>"
	assert_table_length NUM_CROBAT_FORMS

ElectrodeFormSymbols:
	table_width 1
	db 0
	db "<ROCKET_LOGO>"
	assert_table_length NUM_ELECTRODE_FORMS

ArbokFormSymbols:
	table_width 1
	db 0
	db "<ROCKET_LOGO>"
	assert_table_length NUM_ARBOK_FORMS

GolbatFormSymbols:
	table_width 1
	db 0
	db "<ROCKET_LOGO>"
	db "<CARTRIDGE>"
	assert_table_length NUM_GOLBAT_FORMS

MachopFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_MACHOP_FORMS

MachokeFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_MACHOKE_FORMS

MachampFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_MACHAMP_FORMS

TentacoolFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_TENTACOOL_FORMS

TentacruelFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_TENTACRUEL_FORMS

IgglybuffFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_IGGLYBUFF_FORMS

JigglypuffFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_JIGGLYPUFF_FORMS

WigglytuffFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_WIGGLYTUFF_FORMS

NidoranMFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_NIDORAN_M_FORMS

NidorinoFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_NIDORINO_FORMS

NidokingFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_NIDOKING_FORMS

NidoranFFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_NIDORAN_F_FORMS

NidorinaFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_NIDORINA_FORMS

NidoqueenFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_NIDOQUEEN_FORMS

ZubatFormSymbols:
	table_width 1
	db 0
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_ZUBAT_FORMS

GeodudeFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_GEODUDE_FORMS

GravelerFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_GRAVELER_FORMS

GolemFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_GOLEM_FORMS

ShellderFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_SHELLDER_FORMS

CloysterFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_CLOYSTER_FORMS

GastlyFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_GASTLY_FORMS

HaunterFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_HAUNTER_FORMS

GengarFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_GENGAR_FORMS

KoffingFormSymbols:
	table_width 1
	db 0
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_KOFFING_FORMS

HorseaFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_HORSEA_FORMS

SeadraFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_SEADRA_FORMS

KingdraFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_KINGDRA_FORMS

PsyduckFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_PSYDUCK_FORMS

GolduckFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_GOLDUCK_FORMS

MagikarpFormSymbols:
	table_width 1
	db 0
	db 0
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_MAGIKARP_FORMS

GyaradosFormSymbols:
	table_width 1
	db 0
	db 0
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_GYARADOS_FORMS

StaryuFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_STARYU_FORMS

StarmieFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_STARMIE_FORMS

AerodactylFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_AERODACTYL_FORMS

RhyhornFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_RHYHORN_FORMS

RhydonFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_RHYDON_FORMS

KangaskhanFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_KANGASKHAN_FORMS

VenonatFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_VENONAT_FORMS

VenomothFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_VENOMOTH_FORMS

LaprasFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_LAPRAS_FORMS

FarfetchDFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_FARFETCH_D_FORMS

CuboneFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_CUBONE_FORMS

MarowakFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_MAROWAK_FORMS

ExeggcuteFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_EXEGGCUTE_FORMS

ExeggutorFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_EXEGGUTOR_FORMS

DratiniFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_DRATINI_FORMS

DragonairFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_DRAGONAIR_FORMS

DragoniteFormSymbols:
	table_width 1
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_DRAGONITE_FORMS

PichuFormSymbols:
	table_width 1
	db 0
	db 0
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_PICHU_FORMS

RaichuFormSymbols:
	table_width 1
	db 0
	db 0
	db 0
	db "<CARTRIDGE>"
	assert_table_length NUM_RAICHU_FORMS
