MACRO e4_roster
;\1: the character's name, for the debug lineup display
;\2: trainer class
;\3: trainer id within the class (its party in data/trainers/parties.asm)
;\4: a nickname list (below), or 0 for none
;\5: E4_ROSTER_* flags
;\6: overworld sprite
;\7: object palette (PAL_NPC_*), or 0 for the sprite's own
;\8: home room layout (E4_LAYOUT_*)
;\9: partner Pokemon species
;\<10>: partner form
;\<11>: text before the battle
;\<12>: text in battle when beaten
;\<13>: text after the battle, and when talked to again
;\<14>: as champion, their Hall of Fame line in place of the usual speech, or 0
;\<15>: an EVENT_* that must be set before it can be rolled (Youngster Joey's final rematch), or -1
	assert _NARG == 15, "e4_roster takes 15 arguments, not {d:_NARG}"
	dw \1
	db \2, \3
	dw \4
	db \5, \6, \7, \8
	dw \9
	db \<10>
	dba \<11>
	dba \<12>
	dba \<13>
	if !STRCMP("\<14>", "0")
		db 0
		dw 0
	else
		dba \<14>
	endc
	dw \<15>
ENDM

EliteFourRoster:
; Everyone who can be rolled into an Elite Four lineup.
; Entries correspond to E4_ROSTER_* constants and must stay in that order.
; A party is a list of up to six: an Elite Four seat uses the first five, the champion all six.
; Its levels are ignored; the seat sets them (EliteFourSeatStats).
	table_width E4_ROSTER_ENTRY_LENGTH
	e4_roster .Will,     WILL,     WILL1,               0,                 0, SPRITE_WILL,          PAL_NPC_RED,   E4_LAYOUT_WILL,  XATU,       PLAIN_FORM,         WillScript_WillBeforeText,     WillScript_WillBeatenText,     WillScript_WillDefeatText,     0, -1
	e4_roster .Koga,     KOGA,     KOGA1,               0,                 0, SPRITE_KOGA,          PAL_NPC_BLUE,  E4_LAYOUT_KOGA,  CROBAT,     PLAIN_FORM,         KogaScript_KogaBeforeText,     KogaScript_KogaBeatenText,     KogaScript_KogaDefeatText,     0, -1
	e4_roster .Bruno,    BRUNO,    BRUNO1,              0,                 0, SPRITE_BRUNO,         PAL_NPC_BROWN, E4_LAYOUT_BRUNO, MACHAMP,    PLAIN_FORM,         BrunoScript_BrunoBeforeText,   BrunoScript_BrunoBeatenText,   BrunoScript_BrunoDefeatText,   0, -1
	e4_roster .Karen,    KAREN,    KAREN1,              0,                 0, SPRITE_KAREN,         PAL_NPC_RED,   E4_LAYOUT_KAREN, HOUNDOOM,   PLAIN_FORM,         KarenScript_KarenBeforeText,   KarenScript_KarenBeatenText,   KarenScript_KarenDefeatText,   0, -1
	e4_roster .Lance,    CHAMPION, LANCE,               0,                 0, SPRITE_LANCE,         PAL_NPC_RED,   E4_LAYOUT_BRUNO, DRAGONITE,  PLAIN_FORM,         LanceBattleIntroText,          LanceBattleWinText,            LanceBattleAfterText,          0, -1
	e4_roster .Falkner,  FALKNER,  FALKNER_ELITE_FOUR,  0,                 0, SPRITE_FALKNER,       PAL_NPC_BLUE,  E4_LAYOUT_KOGA,  PIDGEOT,    PLAIN_FORM,         FalknerEliteFourBeforeText,    FalknerEliteFourBeatenText,    FalknerEliteFourAfterText,     0, -1
	e4_roster .Bugsy,    BUGSY,    BUGSY_ELITE_FOUR,    0,                 0, SPRITE_BUGSY,         PAL_NPC_GREEN, E4_LAYOUT_KOGA,  SCYTHER,    SCYTHER_TEAL_FORM,  BugsyEliteFourBeforeText,      BugsyEliteFourBeatenText,      BugsyEliteFourAfterText,       0, -1
	e4_roster .Whitney,  WHITNEY,  WHITNEY_ELITE_FOUR,  0,                 0, SPRITE_WHITNEY,       PAL_NPC_RED,   E4_LAYOUT_KAREN, MILTANK,    PLAIN_FORM,         WhitneyEliteFourBeforeText,    WhitneyEliteFourBeatenText,    WhitneyEliteFourAfterText,     0, -1
	e4_roster .Morty,    MORTY,    MORTY_ELITE_FOUR,    0,                 0, SPRITE_MORTY,         PAL_NPC_BROWN, E4_LAYOUT_KOGA,  GENGAR,     PLAIN_FORM,         MortyEliteFourBeforeText,      MortyEliteFourBeatenText,      MortyEliteFourAfterText,       0, -1
	e4_roster .Chuck,    CHUCK,    CHUCK_ELITE_FOUR,    0,                 0, SPRITE_CHUCK,         PAL_NPC_BROWN, E4_LAYOUT_BRUNO, POLIWRATH,  PLAIN_FORM,         ChuckEliteFourBeforeText,      ChuckEliteFourBeatenText,      ChuckEliteFourAfterText,       0, -1
	e4_roster .Jasmine,  JASMINE,  JASMINE_ELITE_FOUR,  .JasmineNicknames, 0, SPRITE_JASMINE,       PAL_NPC_RED,   E4_LAYOUT_KAREN, STEELIX,    PLAIN_FORM,         JasmineEliteFourBeforeText,    JasmineEliteFourBeatenText,    JasmineEliteFourAfterText,     0, -1
	e4_roster .Pryce,    PRYCE,    PRYCE_ELITE_FOUR,    0,                 0, SPRITE_PRYCE,         PAL_NPC_BROWN, E4_LAYOUT_WILL,  PILOSWINE,  PLAIN_FORM,         PryceEliteFourBeforeText,      PryceEliteFourBeatenText,      PryceEliteFourAfterText,       0, -1
	e4_roster .Clair,    CLAIR,    CLAIR_ELITE_FOUR,    0,                 0, SPRITE_CLAIR,         PAL_NPC_BLUE,  E4_LAYOUT_BRUNO, KINGDRA,    PLAIN_FORM,         ClairEliteFourBeforeText,      ClairEliteFourBeatenText,      ClairEliteFourAfterText,       0, -1
	e4_roster .Brock,    BROCK,    BROCK_ELITE_FOUR,    0,                 0, SPRITE_BROCK,         PAL_NPC_BROWN, E4_LAYOUT_BRUNO, STEELIX,    PLAIN_FORM,         BrockEliteFourBeforeText,      BrockEliteFourBeatenText,      BrockEliteFourAfterText,       0, -1
	e4_roster .Misty,    MISTY,    MISTY_ELITE_FOUR,    0,                 0, SPRITE_MISTY,         PAL_NPC_RED,   E4_LAYOUT_WILL,  STARMIE,    STARMIE_RB_FORM,    MistyEliteFourBeforeText,      MistyEliteFourBeatenText,      MistyEliteFourAfterText,       0, -1
	e4_roster .LtSurge,  LT_SURGE, LT_SURGE_ELITE_FOUR, 0,                 0, SPRITE_SURGE,         PAL_NPC_BROWN, E4_LAYOUT_KAREN, RAICHU,     RAICHU_RB_FORM,     LtSurgeEliteFourBeforeText,    LtSurgeEliteFourBeatenText,    LtSurgeEliteFourAfterText,     0, -1
	e4_roster .Erika,    ERIKA,    ERIKA_ELITE_FOUR,    0,                 0, SPRITE_ERIKA,         PAL_NPC_GREEN, E4_LAYOUT_KOGA,  VICTREEBEL, PLAIN_FORM,         ErikaEliteFourBeforeText,      ErikaEliteFourBeatenText,      ErikaEliteFourAfterText,       0, -1
	e4_roster .Janine,   JANINE,   JANINE_ELITE_FOUR,   0,                 0, SPRITE_JANINE,        PAL_NPC_BLUE,  E4_LAYOUT_KOGA,  VENOMOTH,   VENOMOTH_RB_FORM,   JanineEliteFourBeforeText,     JanineEliteFourBeatenText,     JanineEliteFourAfterText,      0, -1
	e4_roster .Sabrina,  SABRINA,  SABRINA_ELITE_FOUR,  0,                 0, SPRITE_SABRINA,       PAL_NPC_RED,   E4_LAYOUT_WILL,  ALAKAZAM,   PLAIN_FORM,         SabrinaEliteFourBeforeText,    SabrinaEliteFourBeatenText,    SabrinaEliteFourAfterText,     0, -1
	e4_roster .Blaine,   BLAINE,   BLAINE_ELITE_FOUR,   0,                 0, SPRITE_BLAINE,        PAL_NPC_BROWN, E4_LAYOUT_BRUNO, ARCANINE,   PLAIN_FORM,         BlaineEliteFourBeforeText,     BlaineEliteFourBeatenText,     BlaineEliteFourAfterText,      0, -1
	e4_roster .Blue,     BLUE,     BLUE_ELITE_FOUR,     0,                 0, SPRITE_BLUE,          PAL_NPC_BLUE,  E4_LAYOUT_KAREN, PIDGEOT,    PLAIN_FORM,         BlueEliteFourBeforeText,       BlueEliteFourBeatenText,       BlueEliteFourAfterText,        0, -1
	e4_roster .Lorelei,  LORELEI,  LORELEI_ELITE_FOUR,  0,                 0, SPRITE_LORELEI,       PAL_NPC_RED,   E4_LAYOUT_WILL,  LAPRAS,     LAPRAS_RB_FORM,     LoreleiEliteFourBeforeText,    LoreleiEliteFourBeatenText,    LoreleiEliteFourAfterText,     0, -1
	e4_roster .Agatha,   AGATHA,   AGATHA_ELITE_FOUR,   0,                 0, SPRITE_AGATHA,        PAL_OW_PURPLE, E4_LAYOUT_KOGA,  GENGAR,     GENGAR_RB_FORM,     AgathaEliteFourBeforeText,     AgathaEliteFourBeatenText,     AgathaEliteFourAfterText,      0, -1
	e4_roster .Giovanni, GIOVANNI, GIOVANNI_ELITE_FOUR, 0,                 0, SPRITE_GIOVANNI,      PAL_OW_GRAY,   E4_LAYOUT_KAREN, PERSIAN,    PLAIN_FORM,         GiovanniEliteFourBeforeText,   GiovanniEliteFourBeatenText,   GiovanniEliteFourAfterText,    GiovanniEliteFourHallOfFameText, -1
	e4_roster .Toru,     TORU,     TORU_ELITE_FOUR,     0,                 0, SPRITE_COOLTRAINER_M, PAL_NPC_BLUE,  E4_LAYOUT_WILL,  KANGASKHAN, KANGASKHAN_RB_FORM, ToruEliteFourBeforeText,       ToruEliteFourBeatenText,       ToruEliteFourAfterText,        0, -1
	assert_table_length NUM_E4_ROSTER

.Will:  db "WILL@"
.Koga:  db "KOGA@"
.Bruno: db "BRUNO@"
.Karen: db "KAREN@"
.Lance: db "LANCE@"
.Falkner: db "FALKNER@"
.Bugsy: db "BUGSY@"
.Whitney: db "WHITNEY@"
.Morty: db "MORTY@"
.Chuck: db "CHUCK@"
.Jasmine: db "JASMINE@"
.Pryce: db "PRYCE@"
.Clair: db "CLAIR@"
.Brock: db "BROCK@"
.Misty: db "MISTY@"
.LtSurge: db "LT.SURGE@"
.Erika: db "ERIKA@"
.Janine: db "JANINE@"
.Sabrina: db "SABRINA@"
.Blaine: db "BLAINE@"
.Blue: db "BLUE@"
.Lorelei: db "LORELEI@"
.Agatha: db "AGATHA@"
.Giovanni: db "???@"
.Toru: db "TORU@"

; Nickname lists: db party slot (0-5), then the name, up to MON_NAME_LENGTH - 1 characters and
; "@"; db -1 ends the list. A slot past the team's size is skipped.

.JasmineNicknames:
	db 5, "AMPHY@" ; her Ampharos, the Olivine lighthouse's (champion only: it's her sixth)
	db -1

EliteFourRoomLayouts:
; entries correspond to E4_LAYOUT_* constants: tileset, blocks
	table_width 4
	db TILESET_ELITE_FOUR_ROOM
	dba WillsRoom_Blocks
	db TILESET_ELITE_FOUR_ROOM
	dba KogasRoom_Blocks
	db TILESET_ELITE_FOUR_ROOM
	dba BrunosRoom_Blocks
	db TILESET_ELITE_FOUR_ROOM
	dba KarensRoom_Blocks
	assert_table_length NUM_E4_LAYOUTS

EliteFourRoomMaps:
; entries correspond to E4_SEAT_* constants
	table_width 2
	map_id WILLS_ROOM
	map_id KOGAS_ROOM
	map_id BRUNOS_ROOM
	map_id KARENS_ROOM
	map_id LANCES_ROOM
	assert_table_length NUM_E4_SEATS

EliteFourSeatMembers:
; entries correspond to E4_SEAT_* constants: who sits there before the Open League, and whose room
; it is
	table_width 1
	db E4_ROSTER_WILL
	db E4_ROSTER_KOGA
	db E4_ROSTER_BRUNO
	db E4_ROSTER_KAREN
	db E4_ROSTER_LANCE
	assert_table_length NUM_E4_SEATS
