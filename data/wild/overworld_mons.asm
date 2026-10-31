; Which Pokemon wander which map, and how likely each is.
;
; Two tables, grass and water, the way JohtoGrassWildMons and JohtoWaterWildMons are two tables.
; RollOverworldMons runs one pass over each, so a map's grass slots can only draw land mon and its
; water slots only water ones.
;
; The slots fill in a fixed order: a map's static mon first (data/maps/overworld_mons.asm), then
; its grass slots, then its water ones. A map's SPRITE_OW_MON_* objects must be numbered to match.
;
; Separate from data/wild/johto_grass.asm on purpose. The species overlap but nothing else does:
; these have their own odds, a shorter list, and per-entry forms and perks that a grass encounter
; has no field for.
;
; Read by RollOverworldMons, which runs from HandleNewMap - so a map rerolls when you leave and
; come back, and holds still through battles and menus.
;
; ow_wildmon is weight, species, level, form, perks, extra move. Weights are out of 100 within
; their time of day; a block adding to less than 100 simply lands on its last entry more often.

OverworldWildMonsGrass:

; =================
; JOHTO - OUTSIDE
; =================

	def_ow_wildmons ROUTE_29
	db 4 ; how many can be out at once -- one SPRITE_OW_MON_n object each
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 50, PIDGEY,      2, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 40, SENTRET,     2, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  RATTATA,     2, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  HOPPIP,      3, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 50, PIDGEY,      2, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 40, SENTRET,     2, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  RATTATA,     2, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  HOPPIP,      3, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 35, RATTATA,     2, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, HOOTHOOT,    2, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 25, HOOTHOOT,    3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, RATTATA,     3, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_30
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 50, CATERPIE,    3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, LEDYBA,      3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, PIDGEY,      4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, WEEDLE,      3, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 50, CATERPIE,    3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, PIDGEY,      3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, LEDYBA,      4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, WEEDLE,      3, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 45, HOOTHOOT,    3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, SPINARAK,    3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, POLIWAG,     4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  ZUBAT,       3, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_31
	db 3 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 34, LEDYBA,      4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, BELLSPROUT,  4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, CATERPIE,    5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, MAREEP,      5, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 34, PIDGEY,      4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, CATERPIE,    4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, BELLSPROUT,  5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, MAREEP,      5, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 34, SPINARAK,    4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, POLIWAG,     4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, BELLSPROUT,  5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, HOOTHOOT,    5, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_32
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 52, MAREEP,      7, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, WOOPER,      7, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, EKANS,       6, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  PIDGEY,      7, PLAIN_FORM, 0,                  PURSUIT
	; day
	ow_wildmon 52, MAREEP,      7, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, WOOPER,      7, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, EKANS,       6, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  PIDGEY,      7, PLAIN_FORM, 0,                  PURSUIT
	; nite
	ow_wildmon 50, WOOPER,      7, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, ZUBAT,       7, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 15, GASTLY,      6, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  MAREEP,      7, PLAIN_FORM, 0,                  PURSUIT
	end_ow_wildmons

	def_ow_wildmons ROUTE_33
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 35, EKANS,       9, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, SPEAROW,     9, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, RATTATA,     8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 15, MACHOP,      9, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 40, MACHOP,      9, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 35, EKANS,       9, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, RATTATA,     8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  MACHOP,      8, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 35, ZUBAT,       9, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, EKANS,       9, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, RATTATA,     8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 15, MACHOP,      9, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_34
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 34, MANKEY,     14, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, ABRA,       13, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, SNUBBULL,   14, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, GRIMER,     13, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 34, MANKEY,     14, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, ABRA,       13, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, SNUBBULL,   14, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, GRIMER,     13, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 34, DROWZEE,    14, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, GRIMER,     13, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, ABRA,       14, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, SNUBBULL,   13, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_35
	db 3 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 33, SNUBBULL,   15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, ABRA,       15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 23, YANMA,      15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, PIDGEY,     14, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 33, SNUBBULL,   15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, PIDGEY,     15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, ABRA,       15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 12, YANMA,      14, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 35, PSYDUCK,    15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, GROWLITHE,  15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, ABRA,       15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 12, YANMA,      14, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

; The park outside the contest. Its grass table's first four slots per time of day, with the slot
; odds they have there (30, 30, 20, 10), with the fourth taking the other 10 too so each time
; of day totals 100.
; The Persian owns slot 1, so these three take SPRITE_OW_MON_2..4.
	def_ow_wildmons NATIONAL_PARK
	db 3 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 30, NIDORAN_M,  14, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, NIDORAN_F,  15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, SUNKERN,    17, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, WEEDLE,     10, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 30, NIDORAN_F,  15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, NIDORAN_M,  14, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, WEEDLE,     10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, SUNKERN,    13, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 30, PSYDUCK,    13, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, MURKROW,    17, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, SPINARAK,   14, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, HOOTHOOT,   15, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_36
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 35, RATTATA,     4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, BELLSPROUT,  4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 25, PIDGEY,      5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, GROWLITHE,   5, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 35, RATTATA,     4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, BELLSPROUT,  4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 25, PIDGEY,      5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, GROWLITHE,   5, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 35, RATTATA,     4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 35, GASTLY,      4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, HOOTHOOT,    5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, HOUNDOUR,    5, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_37
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 50, PIDGEY,     16, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 35, VULPIX,     17, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, PIDGEOTTO,  18, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  LEDIAN,     18, PLAIN_FORM, 0,                  PSYBEAM
	; day
	ow_wildmon 50, PIDGEY,     16, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 35, GROWLITHE,  16, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, PIDGEOTTO,  16, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  STANTLER,   18, PLAIN_FORM, 0,                  BITE
	; nite
	ow_wildmon 42, STANTLER,   18, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, SPINARAK,   16, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, HOOTHOOT,   15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  NOCTOWL,    19, PLAIN_FORM, 0,                  SKY_ATTACK
	end_ow_wildmons

	def_ow_wildmons ROUTE_38
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 34, TAUROS,     21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, MILTANK,    21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, MAGNEMITE,  20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, DODUO,      20, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 34, MAGNEMITE,  20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, MILTANK,    21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, TAUROS,     21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, DODUO,      20, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 30, RATICATE,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, MAGNEMITE,  20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, MEOWTH,     19, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, NOCTOWL,    21, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_39
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 34, PONYTA,     21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, RATICATE,   21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, MAGNEMITE,  21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, DODUO,      21, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 34, PONYTA,     21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, RATICATE,   21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, MAGNEMITE,  21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, DODUO,      21, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 40, MEOWTH,     21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, RATICATE,   21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, MAGNEMITE,  20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, NOCTOWL,    20, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_42
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 36, FEAROW,     20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, EKANS,      20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, GLIGAR,     21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, RATICATE,   21, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 36, FEAROW,     20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, EKANS,      20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, GLIGAR,     21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, RATICATE,   21, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 31, RATICATE,   22, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, ZUBAT,      20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, GLIGAR,     21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 16, GOLBAT,     22, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_43
	db 3 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 34, FURRET,     21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, GIRAFARIG,  22, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, FARFETCH_D, 22, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, FLAAFFY,    23, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 34, FURRET,     21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, GIRAFARIG,  22, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, FARFETCH_D, 22, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, FLAAFFY,    23, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 34, VENONAT,    21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, GIRAFARIG,  22, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, RATICATE,   22, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, FLAAFFY,    23, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_44
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 31, TANGELA,    33, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, LICKITUNG,  32, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 26, WEEPINBELL, 32, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, PIDGEOTTO,  34, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 31, TANGELA,    33, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, LICKITUNG,  32, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 26, WEEPINBELL, 32, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, PIDGEOTTO,  34, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 40, POLIWHIRL,  33, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, LICKITUNG,  32, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 25, WEEPINBELL, 32, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  ELECTABUZZ, 36, PLAIN_FORM, 0,                  ROLLING_KICK
	end_ow_wildmons

	def_ow_wildmons ROUTE_45
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 42, DONPHAN,    34, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, GRAVELER,   34, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, GLIGAR,     31, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  URSARING,   35, PLAIN_FORM, 0,                  CRUNCH
	; day
	ow_wildmon 42, DONPHAN,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, GRAVELER,   34, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, GLIGAR,     31, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  URSARING,   35, PLAIN_FORM, 0,                  CRUNCH
	; nite
	ow_wildmon 63, GRAVELER,   35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, GLIGAR,     31, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, MURKROW,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  GOLBAT,     35, PLAIN_FORM, 0,                  QUICK_ATTACK
	end_ow_wildmons

	def_ow_wildmons ROUTE_46
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 50, GEODUDE,     2, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, SPEAROW,     2, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 15, RATTATA,     3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  PHANPY,      2, PLAIN_FORM, 0,                  WATER_GUN
	; day
	ow_wildmon 50, GEODUDE,     2, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, SPEAROW,     2, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, PHANPY,      3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, RATTATA,     2, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 40, RATTATA,     2, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GEODUDE,     2, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, GEODUDE,     3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, RATTATA,     3, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons


	def_ow_wildmons RUINS_OF_ALPH_OUTSIDE
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 80, NATU,       21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SMEARGLE,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  SMEARGLE,   20, SMEARGLE_YELLOW_FORM, 0,        NO_MOVE
	ow_wildmon 5,  SMEARGLE,   22, SMEARGLE_BLUE_FORM, 0,          NO_MOVE
	; day
	ow_wildmon 80, NATU,       21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SMEARGLE,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  SMEARGLE,   20, SMEARGLE_YELLOW_FORM, 0,        NO_MOVE
	ow_wildmon 5,  SMEARGLE,   22, SMEARGLE_BLUE_FORM, 0,          NO_MOVE
	; nite
	ow_wildmon 80, NATU,       21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SMEARGLE,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  SMEARGLE,   20, SMEARGLE_YELLOW_FORM, 0,        NO_MOVE
	ow_wildmon 5,  SMEARGLE,   22, SMEARGLE_BLUE_FORM, 0,          NO_MOVE
	end_ow_wildmons

; ===============
; JOHTO - INSIDE
; ===============

	def_ow_wildmons DARK_CAVE_BLACKTHORN_ENTRANCE
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 34, GEODUDE,    33, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, ZUBAT,      33, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, GRAVELER,   35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, URSARING,   35, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 31, GEODUDE,    33, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, ZUBAT,      33, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, GRAVELER,   35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 16, URSARING,   35, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 31, GEODUDE,    33, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, ZUBAT,      33, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, GRAVELER,   35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 16, WOBBUFFET,  30, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons DARK_CAVE_VIOLET_ENTRANCE
	db 3 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 51, ZUBAT,       2, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 40, GEODUDE,     3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  TEDDIURSA,   2, PLAIN_FORM, 0,                  CRUNCH
	ow_wildmon 4,  LARVITAR,    2, PLAIN_FORM, 0,                  PURSUIT
	; day
	ow_wildmon 55, ZUBAT,       2, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 40, GEODUDE,     3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 4,  LARVITAR,    2, PLAIN_FORM, 0,                  PURSUIT
	ow_wildmon 1,  DUNSPARCE,   4, PLAIN_FORM, 0,                  ROCK_SLIDE
	; nite
	ow_wildmon 55, ZUBAT,       2, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 40, GEODUDE,     3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 4,  LARVITAR,    2, PLAIN_FORM, 0,                  PURSUIT
	ow_wildmon 1,  DUNSPARCE,   4, PLAIN_FORM, 0,                  ROCK_SLIDE
	end_ow_wildmons

	def_ow_wildmons ICE_PATH_1F
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 30, SWINUB,     21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, ZUBAT,      22, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GOLBAT,     22, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SWINUB,     23, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 30, SWINUB,     21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, ZUBAT,      22, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GOLBAT,     22, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SWINUB,     23, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 30, DELIBIRD,   21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, ZUBAT,      22, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GOLBAT,     22, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, DELIBIRD,   23, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ICE_PATH_B1F
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 35, SWINUB,     32, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 31, JYNX,       33, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 24, GOLBAT,     33, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SNEASEL,    34, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 35, SWINUB,     32, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 31, JYNX,       33, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 24, GOLBAT,     33, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SNEASEL,    34, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 31, SNEASEL,    33, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, DELIBIRD,   32, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 29, GOLBAT,     33, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, DELIBIRD,   34, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ICE_PATH_B2F_BLACKTHORN_SIDE
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 35, SWINUB,     32, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 31, JYNX,       33, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 24, GOLBAT,     33, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SNEASEL,    34, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 35, SWINUB,     32, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 31, JYNX,       33, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 24, GOLBAT,     33, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SNEASEL,    34, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 35, SNEASEL,    33, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, DELIBIRD,   32, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 25, GOLBAT,     33, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, DELIBIRD,   34, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ICE_PATH_B3F
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 40, JYNX,       35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, SNEASEL,    34, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, GOLBAT,     35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SWINUB,     36, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 40, JYNX,       35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, SNEASEL,    34, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, GOLBAT,     35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SWINUB,     36, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 40, SNEASEL,    34, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, JYNX,       35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, GOLBAT,     35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, DELIBIRD,   36, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ILEX_FOREST
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 31, CATERPIE,    8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, WEEDLE,      8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 26, PARAS,      12, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, ODDISH,     12, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 31, CATERPIE,    8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, WEEDLE,      8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 26, PARAS,      12, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, ODDISH,     12, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 36, ODDISH,     12, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, VENONAT,    12, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, PARAS,      12, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, HOOTHOOT,   12, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

; Apricorn Forest starts from Ilex Forest's roster; adjust as the forest takes shape.
	def_ow_wildmons APRICORN_FOREST
	db 4 ; how many can be out at once -- one SPRITE_OW_MON_n object each
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 31, TEDDIURSA,  23, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, BEEDRILL,   24, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 26, DODUO,      25, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, VOLTORB,    26, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 31, TEDDIURSA,  23, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, BEEDRILL,   24, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 26, DODUO,      25, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, VOLTORB,    26, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 36, TEDDIURSA,  23, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, BEEDRILL,   24, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, DODUO,      25, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, VOLTORB,    26, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons MOUNT_MORTAR_1F_INSIDE
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 34, GEODUDE,    LEVEL_FROM_BADGES - 5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, ZUBAT,      LEVEL_FROM_BADGES - 5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, MACHOP,     LEVEL_FROM_BADGES - 4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, GOLBAT,     LEVEL_FROM_BADGES - 3, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 34, GEODUDE,    LEVEL_FROM_BADGES - 5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, ZUBAT,      LEVEL_FROM_BADGES - 5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, MACHOP,     LEVEL_FROM_BADGES - 4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, GOLBAT,     LEVEL_FROM_BADGES - 3, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 34, GEODUDE,    LEVEL_FROM_BADGES - 5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, ZUBAT,      LEVEL_FROM_BADGES - 5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, MARILL,     LEVEL_FROM_BADGES - 4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, GOLBAT,     LEVEL_FROM_BADGES - 3, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons MOUNT_MORTAR_1F_OUTSIDE
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 34, GEODUDE,    LEVEL_FROM_BADGES - 5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, ZUBAT,      LEVEL_FROM_BADGES - 5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, MACHOP,     LEVEL_FROM_BADGES - 4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, GOLBAT,     LEVEL_FROM_BADGES - 3, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 34, GEODUDE,    LEVEL_FROM_BADGES - 5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, ZUBAT,      LEVEL_FROM_BADGES - 5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, MACHOP,     LEVEL_FROM_BADGES - 4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, GOLBAT,     LEVEL_FROM_BADGES - 3, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 34, GEODUDE,    LEVEL_FROM_BADGES - 5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, ZUBAT,      LEVEL_FROM_BADGES - 5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, MARILL,     LEVEL_FROM_BADGES - 4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, GOLBAT,     LEVEL_FROM_BADGES - 3, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons MOUNT_MORTAR_2F_INSIDE
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 34, GRAVELER,   LEVEL_FROM_BADGES - 6, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, MACHOKE,    LEVEL_FROM_BADGES - 5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, GEODUDE,    LEVEL_FROM_BADGES - 6, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, RATICATE,   LEVEL_FROM_BADGES - 7, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 34, GRAVELER,   LEVEL_FROM_BADGES - 6, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, MACHOKE,    LEVEL_FROM_BADGES - 5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, GEODUDE,    LEVEL_FROM_BADGES - 6, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, RATICATE,   LEVEL_FROM_BADGES - 7, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 31, GRAVELER,   LEVEL_FROM_BADGES - 6, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, GEODUDE,    LEVEL_FROM_BADGES - 6, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, RATICATE,   LEVEL_FROM_BADGES - 7, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 16, GOLBAT,     LEVEL_FROM_BADGES - 7, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons MOUNT_MORTAR_B1F
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 34, GEODUDE,    LEVEL_FROM_BADGES - 5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, ZUBAT,      LEVEL_FROM_BADGES - 5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, MACHOP,     LEVEL_FROM_BADGES - 4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, GOLBAT,     LEVEL_FROM_BADGES - 3, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 34, GEODUDE,    LEVEL_FROM_BADGES - 5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, ZUBAT,      LEVEL_FROM_BADGES - 5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, MACHOP,     LEVEL_FROM_BADGES - 4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, GOLBAT,     LEVEL_FROM_BADGES - 3, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 34, GEODUDE,    LEVEL_FROM_BADGES - 5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, ZUBAT,      LEVEL_FROM_BADGES - 5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, MARILL,     LEVEL_FROM_BADGES - 4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, GOLBAT,     LEVEL_FROM_BADGES - 3, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons SILVER_CAVE_ROOM_1
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 34, GRAVELER,   63, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, URSARING,   64, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, ONIX,       62, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, MAGMAR,     65, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 34, GRAVELER,   63, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, URSARING,   64, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, ONIX,       62, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, MAGMAR,     65, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 45, GOLBAT,     64, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GRAVELER,   63, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, ONIX,       62, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  GOLDUCK,    65, PLAIN_FORM, 0,                  HYPNOSIS
	end_ow_wildmons

	def_ow_wildmons SILVER_CAVE_ROOM_2
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 31, GOLBAT,     68, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, MACHOKE,    68, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, URSARING,   67, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 16, PARASECT,   66, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 31, GOLBAT,     68, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, MACHOKE,    68, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, URSARING,   67, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 16, PARASECT,   66, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 50, GOLBAT,     68, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GOLDUCK,    68, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 15, PARASECT,   66, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  MISDREAVUS, 65, PLAIN_FORM, 0,                  DESTINY_BOND
	end_ow_wildmons

	def_ow_wildmons SLOWPOKE_WELL_B1F
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 55, ZUBAT,       5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, ZUBAT,       6, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SLOWPOKE,    6, PLAIN_FORM, 0,                  FUTURE_SIGHT
	ow_wildmon 5,  SLOWPOKE,    8, PLAIN_FORM, 0,                  FUTURE_SIGHT
	; day
	ow_wildmon 55, ZUBAT,       5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, ZUBAT,       6, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SLOWPOKE,    6, PLAIN_FORM, 0,                  FUTURE_SIGHT
	ow_wildmon 5,  SLOWPOKE,    8, PLAIN_FORM, 0,                  FUTURE_SIGHT
	; nite
	ow_wildmon 55, ZUBAT,       5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, ZUBAT,       6, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SLOWPOKE,    6, PLAIN_FORM, 0,                  FUTURE_SIGHT
	ow_wildmon 5,  SLOWPOKE,    8, PLAIN_FORM, 0,                  FUTURE_SIGHT
	end_ow_wildmons

	def_ow_wildmons SLOWPOKE_WELL_B2F
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 50, ZUBAT,      21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, ZUBAT,      23, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 15, SLOWPOKE,   21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  GOLBAT,     23, PLAIN_FORM, 0,                  FUTURE_SIGHT
	; day
	ow_wildmon 50, ZUBAT,      21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, ZUBAT,      23, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 15, SLOWPOKE,   21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  GOLBAT,     23, PLAIN_FORM, 0,                  FUTURE_SIGHT
	; nite
	ow_wildmon 50, ZUBAT,      21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, ZUBAT,      23, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 15, SLOWPOKE,   21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  GOLBAT,     23, PLAIN_FORM, 0,                  FUTURE_SIGHT
	end_ow_wildmons

	def_ow_wildmons SPROUT_TOWER_2F
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 40, RATTATA,     3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, RATTATA,     4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 25, RATTATA,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  RATTATA,     6, PLAIN_FORM, 0,                  FLAME_WHEEL
	; day
	ow_wildmon 40, RATTATA,     3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, RATTATA,     4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 25, RATTATA,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  RATTATA,     6, PLAIN_FORM, 0,                  FLAME_WHEEL
	; nite
	ow_wildmon 40, RATTATA,     3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 35, GASTLY,      4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, RATTATA,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  GASTLY,      6, PLAIN_FORM, 0,                  PSYWAVE
	end_ow_wildmons

	def_ow_wildmons BURNED_TOWER_1F
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 35, RATICATE,   15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, SLUGMA,     14, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, KOFFING,    14, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 15, HOUNDOUR,   15, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 35, RATICATE,   15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, SLUGMA,     14, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, KOFFING,    14, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 15, HOUNDOUR,   15, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 35, RATICATE,   15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, SLUGMA,     14, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, KOFFING,    14, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 15, ZUBAT,      14, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons UNION_CAVE_1F
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 42, GEODUDE,     8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, SANDSHREW,   8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, ZUBAT,       9, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  CUBONE,      8, PLAIN_FORM, 0,                  SKULL_BASH
	; day
	ow_wildmon 42, GEODUDE,     8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, SANDSHREW,   8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, ZUBAT,       9, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  CUBONE,      8, PLAIN_FORM, 0,                  SKULL_BASH
	; nite
	ow_wildmon 42, GEODUDE,     8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, SANDSHREW,   8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, ZUBAT,       9, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  CUBONE,      8, PLAIN_FORM, 0,                  SKULL_BASH
	end_ow_wildmons

	def_ow_wildmons UNION_CAVE_B1F
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 50, ZUBAT,       8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GEODUDE,     8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, ONIX,        8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, MARILL,      8, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 50, ZUBAT,       8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GEODUDE,     8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, ONIX,        8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, MARILL,      8, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 50, ZUBAT,       8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GEODUDE,     8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, ONIX,        8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, MARILL,      8, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons WHIRL_ISLAND_B1F
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 35, GOLBAT,     25, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, KRABBY,     26, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 25, SEEL,       24, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, KRABBY,     27, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 35, GOLBAT,     25, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, KRABBY,     26, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 25, SEEL,       24, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, KRABBY,     27, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 40, GOLBAT,     25, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, KRABBY,     26, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, SEEL,       24, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, KRABBY,     27, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

; ==============
; KANTO OUTSIDE
; ==============

	def_ow_wildmons ROUTE_1
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 45, PIDGEY,      2, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, RATTATA,     2, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, SENTRET,     3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  FURRET,      6, PLAIN_FORM, 0,                  SLASH
	; day
	ow_wildmon 45, PIDGEY,      2, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, RATTATA,     2, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, SENTRET,     3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  FURRET,      6, PLAIN_FORM, 0,                  SLASH
	; nite
	ow_wildmon 45, HOOTHOOT,    2, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, RATTATA,     2, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, RATTATA,     3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  RATICATE,    6, PLAIN_FORM, 0,                  FLAME_WHEEL
	end_ow_wildmons

	def_ow_wildmons ROUTE_2
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 34, CATERPIE,    3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, LEDYBA,      3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, PIDGEY,      5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, BUTTERFREE,  7, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 52, PIDGEY,      3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, CATERPIE,    3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, BUTTERFREE,  7, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  PIDGEOTTO,   7, PLAIN_FORM, 0,                  PURSUIT
	; nite
	ow_wildmon 50, HOOTHOOT,    3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, SPINARAK,    3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 15, NOCTOWL,     7, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  ARIADOS,     7, PLAIN_FORM, 0,                  PSYBEAM
	end_ow_wildmons

	def_ow_wildmons ROUTE_3
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 34, SPEAROW,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, RATTATA,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, EKANS,       8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, RATICATE,   10, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 34, SPEAROW,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, RATTATA,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, EKANS,       8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, RATICATE,   10, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 65, RATTATA,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, RATICATE,   10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, ZUBAT,       6, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  CLEFAIRY,    6, PLAIN_FORM, 0,                  PRESENT
	end_ow_wildmons

	def_ow_wildmons ROUTE_4
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 34, SPEAROW,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, RATTATA,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, EKANS,       8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, RATICATE,   10, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 34, SPEAROW,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, RATTATA,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, EKANS,       8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, RATICATE,   10, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 65, RATTATA,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, RATICATE,   10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, ZUBAT,       6, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  CLEFAIRY,    6, PLAIN_FORM, 0,                  PRESENT
	end_ow_wildmons

	def_ow_wildmons ROUTE_5
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 31, PIDGEY,     13, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, SNUBBULL,   13, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, PIDGEOTTO,  15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 16, ABRA,       12, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 31, PIDGEY,     13, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, SNUBBULL,   13, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, PIDGEOTTO,  15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 16, ABRA,       12, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 31, HOOTHOOT,   13, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, MEOWTH,     13, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, NOCTOWL,    15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 16, ABRA,       12, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_6
	db 3 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 34, RATTATA,    13, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, SNUBBULL,   13, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, MAGNEMITE,  14, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, RATICATE,   15, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 34, RATTATA,    13, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, SNUBBULL,   13, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, MAGNEMITE,  14, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, RATICATE,   15, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 34, MEOWTH,     13, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, DROWZEE,    13, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, MAGNEMITE,  14, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, PSYDUCK,    15, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_7
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 34, RATTATA,    17, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, SPEAROW,    17, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, SNUBBULL,   18, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, RATICATE,   18, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 34, RATTATA,    17, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, SPEAROW,    17, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, SNUBBULL,   18, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, RATICATE,   18, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 34, MEOWTH,     17, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, MURKROW,    17, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, HOUNDOUR,   18, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, PERSIAN,    18, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_8
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 34, SNUBBULL,   17, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, PIDGEOTTO,  19, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, ABRA,       16, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, GROWLITHE,  17, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 34, SNUBBULL,   17, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, PIDGEOTTO,  19, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, ABRA,       16, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, GROWLITHE,  17, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 34, MEOWTH,     17, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, NOCTOWL,    20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, ABRA,       16, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, HAUNTER,    17, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_9
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 31, RATTATA,    15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, SPEAROW,    15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, RATICATE,   15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 16, FEAROW,     15, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 31, RATTATA,    15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, SPEAROW,    15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, RATICATE,   15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 16, FEAROW,     15, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 31, RATTATA,    15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, VENONAT,    15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 26, RATICATE,   15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, VENOMOTH,   15, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_10_NORTH
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 34, SPEAROW,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, VOLTORB,    37, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, RATICATE,   35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, FEAROW,     45, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 34, SPEAROW,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, VOLTORB,    37, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, RATICATE,   35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, FEAROW,     45, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 34, VENONAT,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, VOLTORB,    37, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, RATICATE,   35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, VENOMOTH,   45, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_11
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 36, HOPPIP,     14, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, RATICATE,   13, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, MAGNEMITE,  15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, PIDGEOTTO,  16, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 36, HOPPIP,     14, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, RATICATE,   13, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, MAGNEMITE,  15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, PIDGEOTTO,  16, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 34, DROWZEE,    14, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, MEOWTH,     13, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, MAGNEMITE,  15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, NOCTOWL,    16, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_13
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 31, NIDORINO,   23, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, NIDORINA,   23, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, PIDGEOTTO,  25, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 19, HOPPIP,     25, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 31, NIDORINO,   23, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, NIDORINA,   23, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, PIDGEOTTO,  25, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 19, HOPPIP,     25, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 40, QUAGSIRE,   23, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, VENONAT,    23, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, NOCTOWL,    25, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, VENOMOTH,   25, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_14
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 34, NIDORINO,   26, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, NIDORINA,   26, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, PIDGEOTTO,  28, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, HOPPIP,     28, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 34, NIDORINO,   26, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, NIDORINA,   26, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, PIDGEOTTO,  28, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, HOPPIP,     28, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 40, QUAGSIRE,   26, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, VENONAT,    26, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, NOCTOWL,    28, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, VENOMOTH,   28, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_15
	db 3 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 31, NIDORINO,   23, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, NIDORINA,   23, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, PIDGEOTTO,  25, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 19, HOPPIP,     25, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 31, NIDORINO,   23, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, NIDORINA,   23, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, PIDGEOTTO,  25, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 19, HOPPIP,     25, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 40, QUAGSIRE,   23, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, VENONAT,    23, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, NOCTOWL,    25, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, VENOMOTH,   25, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_16
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 45, FEAROW,     27, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GRIMER,     26, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, GRIMER,     28, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  MUK,        30, PLAIN_FORM, 0,                  LICK
	; day
	ow_wildmon 50, GRIMER,     26, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 40, FEAROW,     27, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  SLUGMA,     29, PLAIN_FORM, 0,                  ACID_ARMOR
	ow_wildmon 5,  MUK,        30, PLAIN_FORM, 0,                  LICK
	; nite
	ow_wildmon 50, GRIMER,     26, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GRIMER,     27, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 15, MURKROW,    29, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  MUK,        30, PLAIN_FORM, 0,                  LICK
	end_ow_wildmons

	def_ow_wildmons ROUTE_17
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 40, FEAROW,     30, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 35, GRIMER,     29, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, GRIMER,     31, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  MUK,        33, PLAIN_FORM, 0,                  LICK
	; day
	ow_wildmon 40, FEAROW,     30, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 35, SLUGMA,     29, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, GRIMER,     29, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  MUK,        33, PLAIN_FORM, 0,                  LICK
	; nite
	ow_wildmon 45, GRIMER,     30, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GRIMER,     29, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, GRIMER,     31, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  MUK,        33, PLAIN_FORM, 0,                  LICK
	end_ow_wildmons

	def_ow_wildmons ROUTE_18
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 45, FEAROW,     27, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GRIMER,     26, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, GRIMER,     28, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  MUK,        30, PLAIN_FORM, 0,                  LICK
	; day
	ow_wildmon 50, GRIMER,     26, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 40, FEAROW,     27, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  SLUGMA,     29, PLAIN_FORM, 0,                  ACID_ARMOR
	ow_wildmon 5,  MUK,        30, PLAIN_FORM, 0,                  LICK
	; nite
	ow_wildmon 45, GRIMER,     26, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GRIMER,     27, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, GRIMER,     28, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  MUK,        30, PLAIN_FORM, 0,                  LICK
	end_ow_wildmons

	def_ow_wildmons ROUTE_21
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 50, TANGELA,    30, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, RATTATA,    25, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, RATICATE,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, MR__MIME,   30, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 50, TANGELA,    30, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, RATTATA,    25, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, RATICATE,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, MR__MIME,   28, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 40, TANGELA,    30, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, RATTATA,    25, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, TANGELA,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, RATICATE,   20, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_22
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 52, SPEAROW,     3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, RATTATA,     3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, DODUO,       4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  PONYTA,      6, PLAIN_FORM, 0,                  HYPNOSIS
	; day
	ow_wildmon 52, SPEAROW,     3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, RATTATA,     3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, DODUO,       4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  PONYTA,      6, PLAIN_FORM, 0,                  HYPNOSIS
	; nite
	ow_wildmon 40, RATTATA,     3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, POLIWAG,     3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, RATTATA,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, POLIWAG,     4, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_24
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 63, CATERPIE,    8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, METAPOD,    12, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, ABRA,       12, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  BELLSPROUT, 10, PLAIN_FORM, 0,                  SYNTHESIS
	; day
	ow_wildmon 52, CATERPIE,    8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, SUNKERN,    12, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, ABRA,       12, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  BELLSPROUT, 10, PLAIN_FORM, 0,                  SYNTHESIS
	; nite
	ow_wildmon 52, ODDISH,     10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, VENONAT,    10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, ABRA,       12, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  BELLSPROUT, 10, PLAIN_FORM, 0,                  SYNTHESIS
	end_ow_wildmons

	def_ow_wildmons ROUTE_25
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 34, CATERPIE,   10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, PIDGEY,     10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, PIDGEOTTO,  12, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, METAPOD,    12, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 34, CATERPIE,   10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, PIDGEY,     10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, PIDGEOTTO,  12, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, METAPOD,    12, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 31, ODDISH,     10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, HOOTHOOT,   10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, VENONAT,    10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 16, NOCTOWL,    12, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_26
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 40, DODRIO,     38, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, ARBOK,      38, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, PONYTA,     39, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, RAPIDASH,   42, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 40, DODRIO,     38, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, ARBOK,      38, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, PONYTA,     39, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, RAPIDASH,   42, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 34, MURKROW,    38, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, ARBOK,      38, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, PONYTA,     39, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, RAPIDASH,   42, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_27
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 36, DODRIO,     38, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, ARBOK,      38, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, PONYTA,     39, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, RAPIDASH,   42, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 36, DODRIO,     38, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, ARBOK,      38, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, PONYTA,     39, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, RAPIDASH,   42, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 34, MURKROW,    38, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, ARBOK,      38, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, PONYTA,     39, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, RAPIDASH,   42, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_28
	db 3 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 34, TANGELA,    39, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, PONYTA,     40, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, RAPIDASH,   40, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, ARBOK,      42, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 34, TANGELA,    39, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, PONYTA,     40, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, RAPIDASH,   40, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, ARBOK,      42, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 40, POLIWHIRL,  40, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, TANGELA,    39, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, GOLBAT,     40, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, GOLBAT,     42, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

; ==============
; KANTO INSIDE
; ==============

	def_ow_wildmons DIGLETTS_CAVE
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 40, DIGLETT,     3, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, DIGLETT,     6, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, DIGLETT,    12, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, DUGTRIO,    24, PLAIN_FORM, 0,                  PURSUIT
	; day
	ow_wildmon 40, DIGLETT,     2, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, DIGLETT,     4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, DIGLETT,     8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, DUGTRIO,    16, PLAIN_FORM, 0,                  PURSUIT
	; nite
	ow_wildmon 40, DIGLETT,     4, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, DIGLETT,     8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 20, DIGLETT,    16, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, DUGTRIO,    32, PLAIN_FORM, 0,                  PURSUIT
	end_ow_wildmons

	def_ow_wildmons MOUNT_MOON
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 36, GEODUDE,     8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, ZUBAT,       6, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, SANDSHREW,   8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, PARAS,      12, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 36, GEODUDE,     8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, ZUBAT,       6, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, SANDSHREW,   8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, PARAS,      12, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 35, GEODUDE,     8, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, ZUBAT,       6, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 25, CLEFAIRY,    8, PLAIN_FORM, 0,                  SWIFT
	ow_wildmon 10, PARAS,      12, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROCK_TUNNEL_1F
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 34, CUBONE,     42, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, GEODUDE,    44, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, MACHOP,     43, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, ZUBAT,      42, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 34, CUBONE,     42, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, GEODUDE,    44, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, MACHOP,     43, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, ZUBAT,      42, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 50, GEODUDE,    44, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 35, ZUBAT,      42, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, HAUNTER,    42, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  GOLBAT,     44, PLAIN_FORM, 0,                  QUICK_ATTACK
	end_ow_wildmons

	def_ow_wildmons ROCK_TUNNEL_B1F
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 34, CUBONE,     42, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, GEODUDE,    44, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, ONIX,       46, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, ZUBAT,      42, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 34, CUBONE,     42, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, GEODUDE,    44, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, ONIX,       46, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, ZUBAT,      42, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 42, ZUBAT,      42, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 32, GEODUDE,    44, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 21, ONIX,       46, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  HAUNTER,    45, PLAIN_FORM, 0,                  PSYWAVE
	end_ow_wildmons

	def_ow_wildmons CERULEAN_CAVE_1F
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 40, GRAVELER,   45, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 40, SANDSLASH,  52, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, VENOMOTH,   54, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, PARASECT,   54, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 40, GRAVELER,   45, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 40, SANDSLASH,  52, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, VENOMOTH,   54, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, PARASECT,   54, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 40, GRAVELER,   45, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 40, SANDSLASH,  52, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, VENOMOTH,   54, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, PARASECT,   54, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons CERULEAN_CAVE_2F
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 40, RHYHORN,    50, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, DITTO,      60, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 15, GLOOM,      58, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 15, WEEPINBELL, 58, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 40, RHYHORN,    50, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, DITTO,      60, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 15, GLOOM,      58, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 15, WEEPINBELL, 58, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 40, RHYHORN,    50, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, DITTO,      60, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 15, GLOOM,      58, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 15, WEEPINBELL, 58, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons CERULEAN_CAVE_B1F
	db 3 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 45, RHYDON,     62, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 35, DITTO,      60, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, CHANSEY,    56, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, LICKITUNG,  55, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 45, RHYDON,     62, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 35, DITTO,      60, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, CHANSEY,    56, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, LICKITUNG,  55, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 45, RHYDON,     62, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 35, DITTO,      60, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, CHANSEY,    56, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, LICKITUNG,  55, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons
	def_ow_wildmons VICTORY_ROAD
	db 3 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 34, GOLEM,      44, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, RHYDON,     42, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, DONPHAN,    43, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, GOLBAT,     44, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 34, GOLEM,      44, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, RHYDON,     42, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, DONPHAN,    43, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, GOLBAT,     44, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 34, GOLEM,      44, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 33, RHYDON,     42, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 22, DONPHAN,    43, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 11, GOLBAT,     44, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons SILVER_CAVE_OUTSIDE
	db 3 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 35, URSARING,   50, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 35, GOLEM,      51, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 28, RAPIDASH,   54, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 2,  VENUSAUR,   50, PLAIN_FORM, 0,                  ANCIENTPOWER
	; day
	ow_wildmon 35, URSARING,   50, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 35, GOLEM,      52, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 28, SKARMORY,   54, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 2,  CHARIZARD,  50, PLAIN_FORM, 0,                  CRUNCH
	; nite
	ow_wildmon 35, URSARING,   50, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 35, QUAGSIRE,   53, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 28, CROBAT,     54, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 2,  BLASTOISE,  50, PLAIN_FORM, 0,                  ZAP_CANNON
	end_ow_wildmons
	db -1 ; end of table


OverworldWildMonsWater:

; ======================
; JOHTO WATER - OUTSIDE 
; ======================

; Whether a water Pokemon rides on top of the water or swims in it is decided by its species, in
; data/wild/surface_mons.asm, not by these rows.
	def_ow_wildmons CHERRYGROVE_CITY
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, TENTACOOL,  20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 30, TENTACOOL,  15, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 10, TENTACRUEL, 20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 1,  TENTACRUEL, 18, PLAIN_FORM, 0,                  AURORA_BEAM
	; day
	ow_wildmon 59, TENTACOOL,  20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 30, TENTACOOL,  15, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 10, TENTACRUEL, 20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 1,  TENTACRUEL, 18, PLAIN_FORM, 0,                  AURORA_BEAM
	; nite
	ow_wildmon 59, TENTACOOL,  20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 30, TENTACOOL,  15, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 10, TENTACRUEL, 20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 1,  TENTACRUEL, 18, PLAIN_FORM, 0,                  AURORA_BEAM
	end_ow_wildmons

	def_ow_wildmons ROUTE_30
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 50, POLIWAG,    15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, POLIWAG,    20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 15, POLIWHIRL,  20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  POLIWHIRL,  22, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 50, POLIWAG,    15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, POLIWAG,    20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 15, POLIWHIRL,  20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  POLIWHIRL,  22, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 50, POLIWAG,    15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, POLIWAG,    20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 15, POLIWHIRL,  20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  POLIWHIRL,  22, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_31
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 50, POLIWAG,    15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, POLIWAG,    20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 15, POLIWHIRL,  20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  POLIWHIRL,  22, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 50, POLIWAG,    15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, POLIWAG,    20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 15, POLIWHIRL,  20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  POLIWHIRL,  22, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 50, POLIWAG,    15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, POLIWAG,    20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 15, POLIWHIRL,  20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 5,  POLIWHIRL,  22, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_32
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, TENTACOOL,  15, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 30, QUAGSIRE,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, TENTACRUEL, 20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 1,  TENTACRUEL, 23, PLAIN_FORM, 0,                  AURORA_BEAM
	; day
	ow_wildmon 59, TENTACOOL,  15, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 30, QUAGSIRE,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, TENTACRUEL, 20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 1,  TENTACRUEL, 23, PLAIN_FORM, 0,                  AURORA_BEAM
	; nite
	ow_wildmon 59, TENTACOOL,  15, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 30, QUAGSIRE,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, TENTACRUEL, 20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 1,  TENTACRUEL, 23, PLAIN_FORM, 0,                  AURORA_BEAM
	end_ow_wildmons

	def_ow_wildmons ROUTE_34
	db 0 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, TENTACOOL,  20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 30, TENTACOOL,  15, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 10, TENTACRUEL, 20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 1,  TENTACRUEL, 18, PLAIN_FORM, 0,                  AURORA_BEAM
	; day
	ow_wildmon 59, TENTACOOL,  20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 30, TENTACOOL,  15, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 10, TENTACRUEL, 20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 1,  TENTACRUEL, 18, PLAIN_FORM, 0,                  AURORA_BEAM
	; nite
	ow_wildmon 59, TENTACOOL,  20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 30, TENTACOOL,  15, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 10, TENTACRUEL, 20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 1,  TENTACRUEL, 18, PLAIN_FORM, 0,                  AURORA_BEAM
	end_ow_wildmons

	def_ow_wildmons ROUTE_35
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, PSYDUCK,    20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, PSYDUCK,    15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, GOLDUCK,    20, PLAIN_FORM, 0,                  HYPNOSIS
	ow_wildmon 1,  PSYDUCK,    18, PLAIN_FORM, 0,                  HYPNOSIS
	; day
	ow_wildmon 59, PSYDUCK,    20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, PSYDUCK,    15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, GOLDUCK,    20, PLAIN_FORM, 0,                  HYPNOSIS
	ow_wildmon 1,  PSYDUCK,    18, PLAIN_FORM, 0,                  HYPNOSIS
	; nite
	ow_wildmon 59, PSYDUCK,    20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, PSYDUCK,    15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, GOLDUCK,    20, PLAIN_FORM, 0,                  HYPNOSIS
	ow_wildmon 1,  PSYDUCK,    18, PLAIN_FORM, 0,                  HYPNOSIS
	end_ow_wildmons

	def_ow_wildmons ROUTE_40
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, TENTACOOL,  20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 30, SHELLDER,   21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, CORSOLA,    22, PLAIN_FORM, 0,                  ROCK_SLIDE
	ow_wildmon 1,  TENTACRUEL, 25, PLAIN_FORM, 0,                  AURORA_BEAM
	; day
	ow_wildmon 59, TENTACOOL,  20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 30, SHELLDER,   21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, CORSOLA,    22, PLAIN_FORM, 0,                  ROCK_SLIDE
	ow_wildmon 1,  TENTACRUEL, 25, PLAIN_FORM, 0,                  AURORA_BEAM
	; nite
	ow_wildmon 59, TENTACOOL,  20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 30, SHELLDER,   21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, STARYU,     22, PLAIN_FORM, 0, CONFUSE_RAY
	ow_wildmon 1,  TENTACRUEL, 25, PLAIN_FORM, 0,                  AURORA_BEAM
	end_ow_wildmons

	def_ow_wildmons ROUTE_41
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 50, TENTACOOL,  20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 30, HORSEA,     21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, MANTINE,    22, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, CHINCHOU,   25, PLAIN_FORM, 0,                  NO_MOVE
	; day
	ow_wildmon 50, TENTACOOL,  20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 30, HORSEA,     21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, MANTINE,    22, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, CHINCHOU,   25, PLAIN_FORM, 0,                  NO_MOVE
	; nite
	ow_wildmon 50, TENTACOOL,  20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 30, HORSEA,     21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, MANTINE,    22, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, CHINCHOU,   25, PLAIN_FORM, 0,                  NO_MOVE
	end_ow_wildmons

	def_ow_wildmons ROUTE_42
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, REMORAID,   21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GOLDEEN,    20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SEAKING,    25, PLAIN_FORM, 0,                  PSYBEAM
	ow_wildmon 1,  SEAKING,    28, PLAIN_FORM, 0,                  PSYBEAM
	; day
	ow_wildmon 59, REMORAID,   21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GOLDEEN,    20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SEAKING,    25, PLAIN_FORM, 0,                  PSYBEAM
	ow_wildmon 1,  SEAKING,    28, PLAIN_FORM, 0,                  PSYBEAM
	; nite
	ow_wildmon 59, REMORAID,   21, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GOLDEEN,    20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SEAKING,    25, PLAIN_FORM, 0,                  PSYBEAM
	ow_wildmon 1,  SEAKING,    28, PLAIN_FORM, 0,                  PSYBEAM
	end_ow_wildmons

	def_ow_wildmons ROUTE_43
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, MAGIKARP,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, MAGIKARP,   15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, MAGIKARP,   10, PLAIN_FORM, 0,                  BUBBLE
	ow_wildmon 1,  MAGIKARP,   13, PLAIN_FORM, 0,                  BUBBLE
	; day
	ow_wildmon 59, MAGIKARP,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, MAGIKARP,   15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, MAGIKARP,   10, PLAIN_FORM, 0,                  BUBBLE
	ow_wildmon 1,  MAGIKARP,   13, PLAIN_FORM, 0,                  BUBBLE
	; nite
	ow_wildmon 59, MAGIKARP,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, MAGIKARP,   15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, MAGIKARP,   10, PLAIN_FORM, 0,                  BUBBLE
	ow_wildmon 1,  MAGIKARP,   13, PLAIN_FORM, 0,                  BUBBLE
	end_ow_wildmons

	def_ow_wildmons ROUTE_44
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, POLIWAG,    25, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, POLIWAG,    24, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, POLIWHIRL,  28, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 1,  POLIWAG,    27, PLAIN_FORM, 0,                  HAZE
	; day
	ow_wildmon 59, POLIWAG,    25, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, POLIWAG,    24, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, POLIWHIRL,  28, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 1,  POLIWAG,    27, PLAIN_FORM, 0,                  HAZE
	; nite
	ow_wildmon 59, POLIWAG,    25, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, POLIWAG,    24, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, POLIWHIRL,  28, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 1,  POLIWAG,    27, PLAIN_FORM, 0,                  HAZE
	end_ow_wildmons

	def_ow_wildmons CIANWOOD_CITY
	db 3 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, TENTACOOL,  20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 30, TENTACOOL,  15, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 10, CORSOLA,    20, PLAIN_FORM, 0,                  ROCK_SLIDE
	ow_wildmon 1,  TENTACRUEL, 18, PLAIN_FORM, 0,                  AURORA_BEAM
	; day
	ow_wildmon 59, TENTACOOL,  20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 30, TENTACOOL,  15, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 10, CORSOLA,    20, PLAIN_FORM, 0,                  ROCK_SLIDE
	ow_wildmon 1,  TENTACRUEL, 18, PLAIN_FORM, 0,                  AURORA_BEAM
	; nite
	ow_wildmon 59, TENTACOOL,  20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 30, TENTACOOL,  15, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 10, CORSOLA,    20, PLAIN_FORM, 0,                  ROCK_SLIDE
	ow_wildmon 1,  TENTACRUEL, 18, PLAIN_FORM, 0,                  AURORA_BEAM
	end_ow_wildmons

	def_ow_wildmons ECRUTEAK_CITY
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, POLIWAG,    20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, POLIWAG,    15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, POLIWHIRL,  20, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 1,  POLIWAG,    18, PLAIN_FORM, 0,                  HAZE
	; day
	ow_wildmon 59, POLIWAG,    20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, POLIWAG,    15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, POLIWHIRL,  20, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 1,  POLIWAG,    18, PLAIN_FORM, 0,                  HAZE
	; nite
	ow_wildmon 59, POLIWAG,    20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, POLIWAG,    15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, POLIWHIRL,  20, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 1,  POLIWAG,    18, PLAIN_FORM, 0,                  HAZE
	end_ow_wildmons

	def_ow_wildmons OLIVINE_CITY
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, TENTACOOL,  20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 30, TENTACOOL,  15, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 10, CORSOLA,    20, PLAIN_FORM, 0,                  ROCK_SLIDE
	ow_wildmon 1,  TENTACRUEL, 18, PLAIN_FORM, 0,                  RAPID_SPIN
	; day
	ow_wildmon 59, TENTACOOL,  20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 30, TENTACOOL,  15, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 10, CORSOLA,    20, PLAIN_FORM, 0,                  ROCK_SLIDE
	ow_wildmon 1,  TENTACRUEL, 18, PLAIN_FORM, 0,                  AURORA_BEAM
	; nite
	ow_wildmon 59, TENTACOOL,  20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 30, TENTACOOL,  15, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 10, CORSOLA,    20, PLAIN_FORM, 0,                  ROCK_SLIDE
	ow_wildmon 1,  TENTACRUEL, 18, PLAIN_FORM, 0,                  AURORA_BEAM
	end_ow_wildmons

	def_ow_wildmons OLIVINE_PORT
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, TENTACOOL,  20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 30, TENTACOOL,  15, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 10, CHINCHOU,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  TENTACRUEL, 18, PLAIN_FORM, 0,                  AURORA_BEAM
	; day
	ow_wildmon 59, TENTACOOL,  20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 30, TENTACOOL,  15, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 10, CHINCHOU,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  TENTACRUEL, 18, PLAIN_FORM, 0,                  AURORA_BEAM
	; nite
	ow_wildmon 59, TENTACOOL,  20, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 30, TENTACOOL,  15, PLAIN_FORM, 0,                  RAPID_SPIN
	ow_wildmon 10, CHINCHOU,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  TENTACRUEL, 18, PLAIN_FORM, 0,                  AURORA_BEAM
	end_ow_wildmons

	def_ow_wildmons VIOLET_CITY
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, POLIWAG,    20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, POLIWAG,    15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, POLIWHIRL,  20, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 1,  POLIWAG,    18, PLAIN_FORM, 0,                  HAZE
	; day
	ow_wildmon 59, POLIWAG,    20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, POLIWAG,    15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, POLIWHIRL,  20, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 1,  POLIWAG,    18, PLAIN_FORM, 0,                  HAZE
	; nite
	ow_wildmon 59, POLIWAG,    20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, POLIWAG,    15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, POLIWHIRL,  20, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 1,  POLIWAG,    18, PLAIN_FORM, 0,                  HAZE
	end_ow_wildmons

	def_ow_wildmons LAKE_OF_RAGE
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
; Magikarp only, by design since the story on the lake is focused on Red Gyarados.
	; morn
	ow_wildmon 40, MAGIKARP,   10, PLAIN_FORM,       0,                  FLAIL
	ow_wildmon 30, MAGIKARP,   15, PLAIN_FORM,       0,                  FLAIL
	ow_wildmon 20, MAGIKARP,   20, PLAIN_FORM,       0,                  FLAIL
	ow_wildmon 10, MAGIKARP,   25, PLAIN_FORM,       0,                  FLAIL
	; day
	ow_wildmon 40, MAGIKARP,   10, PLAIN_FORM,       0,                  FLAIL
	ow_wildmon 30, MAGIKARP,   15, PLAIN_FORM,       0,                  FLAIL
	ow_wildmon 20, MAGIKARP,   20, PLAIN_FORM,       0,                  FLAIL
	ow_wildmon 10, MAGIKARP,   25, PLAIN_FORM,       0,                  FLAIL
	; nite
	ow_wildmon 40, MAGIKARP,   10, PLAIN_FORM,       0,                  FLAIL
	ow_wildmon 30, MAGIKARP,   15, PLAIN_FORM,       0,                  FLAIL
	ow_wildmon 20, MAGIKARP,   20, PLAIN_FORM,       0,                  FLAIL
	ow_wildmon 10, MAGIKARP,   25, PLAIN_FORM,       0,                  FLAIL
	end_ow_wildmons


	def_ow_wildmons RUINS_OF_ALPH_OUTSIDE
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, WOOPER,     15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, QUAGSIRE,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, QUAGSIRE,   15, PLAIN_FORM, 0,                  BODY_SLAM
	ow_wildmon 1,  QUAGSIRE,   18, PLAIN_FORM, 0,                  BODY_SLAM
	; day
	ow_wildmon 59, WOOPER,     15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, QUAGSIRE,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, QUAGSIRE,   15, PLAIN_FORM, 0,                  BODY_SLAM
	ow_wildmon 1,  QUAGSIRE,   18, PLAIN_FORM, 0,                  BODY_SLAM
	; nite
	ow_wildmon 59, WOOPER,     15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, QUAGSIRE,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, QUAGSIRE,   15, PLAIN_FORM, 0,                  BODY_SLAM
	ow_wildmon 1,  QUAGSIRE,   18, PLAIN_FORM, 0,                  BODY_SLAM
	end_ow_wildmons


; ======================
; JOHTO WATER - INSIDE 
; ======================

	def_ow_wildmons DARK_CAVE_BLACKTHORN_ENTRANCE
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, MAGIKARP,   15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, MAGIKARP,   10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, MAGIKARP,    5, PLAIN_FORM, 0,                  BUBBLE
	ow_wildmon 1,  MAGIKARP,    8, PLAIN_FORM, 0,                  BUBBLE
	; day
	ow_wildmon 59, MAGIKARP,   15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, MAGIKARP,   10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, MAGIKARP,    5, PLAIN_FORM, 0,                  BUBBLE
	ow_wildmon 1,  MAGIKARP,    8, PLAIN_FORM, 0,                  BUBBLE
	; nite
	ow_wildmon 59, MAGIKARP,   15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, MAGIKARP,   10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, MAGIKARP,    5, PLAIN_FORM, 0,                  BUBBLE
	ow_wildmon 1,  MAGIKARP,    8, PLAIN_FORM, 0,                  BUBBLE
	end_ow_wildmons

	def_ow_wildmons DARK_CAVE_VIOLET_ENTRANCE
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, MAGIKARP,   15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, MAGIKARP,   10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, MAGIKARP,    5, PLAIN_FORM, 0,                  BUBBLE
	ow_wildmon 1,  MAGIKARP,    8, PLAIN_FORM, 0,                  BUBBLE
	; day
	ow_wildmon 59, MAGIKARP,   15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, MAGIKARP,   10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, MAGIKARP,    5, PLAIN_FORM, 0,                  BUBBLE
	ow_wildmon 1,  MAGIKARP,    8, PLAIN_FORM, 0,                  BUBBLE
	; nite
	ow_wildmon 59, MAGIKARP,   15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, MAGIKARP,   10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, MAGIKARP,    5, PLAIN_FORM, 0,                  BUBBLE
	ow_wildmon 1,  MAGIKARP,    8, PLAIN_FORM, 0,                  BUBBLE
	end_ow_wildmons

	def_ow_wildmons ILEX_FOREST
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, PSYDUCK,    15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, PSYDUCK,    10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, GOLDUCK,    15, PLAIN_FORM, 0,                  HYPNOSIS
	ow_wildmon 1,  PSYDUCK,    13, PLAIN_FORM, 0,                  HYPNOSIS
	; day
	ow_wildmon 59, PSYDUCK,    15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, PSYDUCK,    10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, GOLDUCK,    15, PLAIN_FORM, 0,                  HYPNOSIS
	ow_wildmon 1,  PSYDUCK,    13, PLAIN_FORM, 0,                  HYPNOSIS
	; nite
	ow_wildmon 59, PSYDUCK,    15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, PSYDUCK,    10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, GOLDUCK,    15, PLAIN_FORM, 0,                  HYPNOSIS
	ow_wildmon 1,  PSYDUCK,    13, PLAIN_FORM, 0,                  HYPNOSIS
	end_ow_wildmons

	def_ow_wildmons MOUNT_MORTAR_2F_INSIDE
	db 3 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, GOLDEEN,    LEVEL_FROM_BADGES - 17, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, MARILL,     LEVEL_FROM_BADGES - 12, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SEAKING,    LEVEL_FROM_BADGES - 12, PLAIN_FORM, 0,                  PSYBEAM
	ow_wildmon 1,  SEAKING,    LEVEL_FROM_BADGES - 9, PLAIN_FORM, 0,                  PSYBEAM
	; day
	ow_wildmon 59, GOLDEEN,    LEVEL_FROM_BADGES - 17, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, MARILL,     LEVEL_FROM_BADGES - 12, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SEAKING,    LEVEL_FROM_BADGES - 12, PLAIN_FORM, 0,                  PSYBEAM
	ow_wildmon 1,  SEAKING,    LEVEL_FROM_BADGES - 9, PLAIN_FORM, 0,                  PSYBEAM
	; nite
	ow_wildmon 59, GOLDEEN,    LEVEL_FROM_BADGES - 17, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, MARILL,     LEVEL_FROM_BADGES - 12, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SEAKING,    LEVEL_FROM_BADGES - 12, PLAIN_FORM, 0,                  PSYBEAM
	ow_wildmon 1,  SEAKING,    LEVEL_FROM_BADGES - 9, PLAIN_FORM, 0,                  PSYBEAM
	end_ow_wildmons

	def_ow_wildmons MOUNT_MORTAR_B1F
	db 3 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, GOLDEEN,    LEVEL_FROM_BADGES - 10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, MARILL,     LEVEL_FROM_BADGES - 5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SEAKING,    LEVEL_FROM_BADGES - 5, PLAIN_FORM, 0,                  PSYBEAM
	ow_wildmon 1,  SEAKING,    LEVEL_FROM_BADGES - 2, PLAIN_FORM, 0,                  PSYBEAM
	; day
	ow_wildmon 59, GOLDEEN,    LEVEL_FROM_BADGES - 10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, MARILL,     LEVEL_FROM_BADGES - 5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SEAKING,    LEVEL_FROM_BADGES - 5, PLAIN_FORM, 0,                  PSYBEAM
	ow_wildmon 1,  SEAKING,    LEVEL_FROM_BADGES - 2, PLAIN_FORM, 0,                  PSYBEAM
	; nite
	ow_wildmon 59, GOLDEEN,    LEVEL_FROM_BADGES - 10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, MARILL,     LEVEL_FROM_BADGES - 5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SEAKING,    LEVEL_FROM_BADGES - 5, PLAIN_FORM, 0,                  PSYBEAM
	ow_wildmon 1,  SEAKING,    LEVEL_FROM_BADGES - 2, PLAIN_FORM, 0,                  PSYBEAM
	end_ow_wildmons

	def_ow_wildmons SILVER_CAVE_ROOM_2
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, SEAKING,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GOLDUCK,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, GOLDEEN,    35, PLAIN_FORM, 0,                  PSYBEAM
	ow_wildmon 1,  GOLDEEN,    38, PLAIN_FORM, 0,                  PSYBEAM
	; day
	ow_wildmon 59, SEAKING,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GOLDUCK,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, GOLDEEN,    35, PLAIN_FORM, 0,                  PSYBEAM
	ow_wildmon 1,  GOLDEEN,    38, PLAIN_FORM, 0,                  PSYBEAM
	; nite
	ow_wildmon 59, SEAKING,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GOLDUCK,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, GOLDEEN,    35, PLAIN_FORM, 0,                  PSYBEAM
	ow_wildmon 1,  GOLDEEN,    38, PLAIN_FORM, 0,                  PSYBEAM
	end_ow_wildmons

	def_ow_wildmons SLOWPOKE_WELL_B1F
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, SLOWPOKE,   15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, SLOWPOKE,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SLOWPOKE,   10, PLAIN_FORM, 0,                  FUTURE_SIGHT
	ow_wildmon 1,  SLOWPOKE,   13, PLAIN_FORM, 0,                  FUTURE_SIGHT
	; day
	ow_wildmon 59, SLOWPOKE,   15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, SLOWPOKE,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SLOWPOKE,   10, PLAIN_FORM, 0,                  FUTURE_SIGHT
	ow_wildmon 1,  SLOWPOKE,   13, PLAIN_FORM, 0,                  FUTURE_SIGHT
	; nite
	ow_wildmon 59, SLOWPOKE,   15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, SLOWPOKE,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SLOWPOKE,   10, PLAIN_FORM, 0,                  FUTURE_SIGHT
	ow_wildmon 1,  SLOWPOKE,   13, PLAIN_FORM, 0,                  FUTURE_SIGHT
	end_ow_wildmons

	def_ow_wildmons SLOWPOKE_WELL_B2F
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, SLOWPOKE,   15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, SLOWPOKE,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SLOWBRO,    20, PLAIN_FORM, 0,                  FUTURE_SIGHT
	ow_wildmon 1,  SLOWPOKE,   23, PLAIN_FORM, 0,                  FUTURE_SIGHT
	; day
	ow_wildmon 59, SLOWPOKE,   15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, SLOWPOKE,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SLOWBRO,    20, PLAIN_FORM, 0,                  FUTURE_SIGHT
	ow_wildmon 1,  SLOWPOKE,   23, PLAIN_FORM, 0,                  FUTURE_SIGHT
	; nite
	ow_wildmon 59, SLOWPOKE,   15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, SLOWPOKE,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SLOWBRO,    20, PLAIN_FORM, 0,                  FUTURE_SIGHT
	ow_wildmon 1,  SLOWPOKE,   23, PLAIN_FORM, 0,                  FUTURE_SIGHT
	end_ow_wildmons

	def_ow_wildmons UNION_CAVE_B1F
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, WOOPER,     15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, QUAGSIRE,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, QUAGSIRE,   15, PLAIN_FORM, 0,                  BODY_SLAM
	ow_wildmon 1,  QUAGSIRE,   18, PLAIN_FORM, 0,                  BODY_SLAM
	; day
	ow_wildmon 59, WOOPER,     15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, QUAGSIRE,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, QUAGSIRE,   15, PLAIN_FORM, 0,                  BODY_SLAM
	ow_wildmon 1,  QUAGSIRE,   18, PLAIN_FORM, 0,                  BODY_SLAM
	; nite
	ow_wildmon 59, WOOPER,     15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, QUAGSIRE,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, QUAGSIRE,   15, PLAIN_FORM, 0,                  BODY_SLAM
	ow_wildmon 1,  QUAGSIRE,   18, PLAIN_FORM, 0,                  BODY_SLAM
	end_ow_wildmons

; ==============
; KANTO OUTSIDE
; ==============

	def_ow_wildmons ROUTE_6
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, PSYDUCK,    10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, PSYDUCK,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, GOLDUCK,    10, PLAIN_FORM, 0,                  HYPNOSIS
	ow_wildmon 1,  PSYDUCK,     8, PLAIN_FORM, 0,                  HYPNOSIS
	; day
	ow_wildmon 59, PSYDUCK,    10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, PSYDUCK,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, GOLDUCK,    10, PLAIN_FORM, 0,                  HYPNOSIS
	ow_wildmon 1,  PSYDUCK,     8, PLAIN_FORM, 0,                  HYPNOSIS
	; nite
	ow_wildmon 59, PSYDUCK,    10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, PSYDUCK,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, GOLDUCK,    10, PLAIN_FORM, 0,                  HYPNOSIS
	ow_wildmon 1,  PSYDUCK,     8, PLAIN_FORM, 0,                  HYPNOSIS
	end_ow_wildmons

	def_ow_wildmons ROUTE_12
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, TENTACOOL,  25, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, QUAGSIRE,   25, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, QWILFISH,   25, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 1,  TENTACRUEL, 28, PLAIN_FORM, 0,                  AURORA_BEAM
	; day
	ow_wildmon 59, TENTACOOL,  25, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, QUAGSIRE,   25, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, QWILFISH,   25, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 1,  TENTACRUEL, 28, PLAIN_FORM, 0,                  AURORA_BEAM
	; nite
	ow_wildmon 59, TENTACOOL,  25, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, QUAGSIRE,   25, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, QWILFISH,   25, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 1,  TENTACRUEL, 28, PLAIN_FORM, 0,                  AURORA_BEAM
	end_ow_wildmons

	def_ow_wildmons ROUTE_13
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, TENTACOOL,  25, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, QUAGSIRE,   25, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, QWILFISH,   25, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 1,  TENTACRUEL, 28, PLAIN_FORM, 0,                  AURORA_BEAM
	; day
	ow_wildmon 59, TENTACOOL,  25, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, QUAGSIRE,   25, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, QWILFISH,   25, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 1,  TENTACRUEL, 28, PLAIN_FORM, 0,                  AURORA_BEAM
	; nite
	ow_wildmon 59, TENTACOOL,  25, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, QUAGSIRE,   25, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, QWILFISH,   25, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 1,  TENTACRUEL, 28, PLAIN_FORM, 0,                  AURORA_BEAM
	end_ow_wildmons

	def_ow_wildmons ROUTE_19
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, TENTACOOL,  35, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, TENTACOOL,  30, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 10, CORSOLA,    35, PLAIN_FORM, 0,                  ROCK_SLIDE
	ow_wildmon 1,  TENTACRUEL, 33, PLAIN_FORM, 0,                  AURORA_BEAM
	; day
	ow_wildmon 59, TENTACOOL,  35, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, TENTACOOL,  30, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 10, CORSOLA,    35, PLAIN_FORM, 0,                  ROCK_SLIDE
	ow_wildmon 1,  TENTACRUEL, 33, PLAIN_FORM, 0,                  AURORA_BEAM
	; nite
	ow_wildmon 59, TENTACOOL,  35, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, TENTACOOL,  30, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 10, CORSOLA,    35, PLAIN_FORM, 0,                  ROCK_SLIDE
	ow_wildmon 1,  TENTACRUEL, 33, PLAIN_FORM, 0,                  AURORA_BEAM
	end_ow_wildmons

	def_ow_wildmons ROUTE_20
	db 3 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, TENTACOOL,  35, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, TENTACOOL,  30, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 10, LANTURN,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  TENTACRUEL, 33, PLAIN_FORM, 0,                  AURORA_BEAM
	; day
	ow_wildmon 59, TENTACOOL,  35, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, TENTACOOL,  30, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 10, LANTURN,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  TENTACRUEL, 33, PLAIN_FORM, 0,                  AURORA_BEAM
	; nite
	ow_wildmon 59, TENTACOOL,  35, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, TENTACOOL,  30, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 10, LANTURN,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  TENTACRUEL, 33, PLAIN_FORM, 0,                  AURORA_BEAM
	end_ow_wildmons

	def_ow_wildmons ROUTE_21
	db 3 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, TENTACOOL,  35, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, TENTACOOL,  30, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 10, LANTURN,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  TENTACRUEL, 33, PLAIN_FORM, 0,                  AURORA_BEAM
	; day
	ow_wildmon 59, TENTACOOL,  35, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, TENTACOOL,  30, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 10, LANTURN,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  TENTACRUEL, 33, PLAIN_FORM, 0,                  AURORA_BEAM
	; nite
	ow_wildmon 59, TENTACOOL,  35, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, TENTACOOL,  30, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 10, LANTURN,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  TENTACRUEL, 33, PLAIN_FORM, 0,                  AURORA_BEAM
	end_ow_wildmons

	def_ow_wildmons ROUTE_22
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, POLIWAG,    10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, POLIWAG,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, POLIWHIRL,  10, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 1,  POLIWAG,     8, PLAIN_FORM, 0,                  HAZE
	; day
	ow_wildmon 59, POLIWAG,    10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, POLIWAG,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, POLIWHIRL,  10, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 1,  POLIWAG,     8, PLAIN_FORM, 0,                  HAZE
	; nite
	ow_wildmon 59, POLIWAG,    10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, POLIWAG,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, POLIWHIRL,  10, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 1,  POLIWAG,     8, PLAIN_FORM, 0,                  HAZE
	end_ow_wildmons

	def_ow_wildmons ROUTE_24
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, GOLDEEN,    10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GOLDEEN,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SEAKING,    10, PLAIN_FORM, 0,                  PSYBEAM
	ow_wildmon 1,  GOLDEEN,     8, PLAIN_FORM, 0,                  PSYBEAM
	; day
	ow_wildmon 59, GOLDEEN,    10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GOLDEEN,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SEAKING,    10, PLAIN_FORM, 0,                  PSYBEAM
	ow_wildmon 1,  GOLDEEN,     8, PLAIN_FORM, 0,                  PSYBEAM
	; nite
	ow_wildmon 59, GOLDEEN,    10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GOLDEEN,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SEAKING,    10, PLAIN_FORM, 0,                  PSYBEAM
	ow_wildmon 1,  GOLDEEN,     8, PLAIN_FORM, 0,                  PSYBEAM
	end_ow_wildmons

	def_ow_wildmons ROUTE_25
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, GOLDEEN,    10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GOLDEEN,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SEAKING,    10, PLAIN_FORM, 0,                  PSYBEAM
	ow_wildmon 1,  GOLDEEN,     8, PLAIN_FORM, 0,                  PSYBEAM
	; day
	ow_wildmon 59, GOLDEEN,    10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GOLDEEN,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SEAKING,    10, PLAIN_FORM, 0,                  PSYBEAM
	ow_wildmon 1,  GOLDEEN,     8, PLAIN_FORM, 0,                  PSYBEAM
	; nite
	ow_wildmon 59, GOLDEEN,    10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GOLDEEN,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, SEAKING,    10, PLAIN_FORM, 0,                  PSYBEAM
	ow_wildmon 1,  GOLDEEN,     8, PLAIN_FORM, 0,                  PSYBEAM
	end_ow_wildmons

	def_ow_wildmons ROUTE_26
	db 2 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, TENTACOOL,  30, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, TENTACOOL,  25, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 10, CHINCHOU,   30, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  TENTACRUEL, 33, PLAIN_FORM, 0,                  AURORA_BEAM
	; day
	ow_wildmon 59, TENTACOOL,  30, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, TENTACOOL,  25, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 10, CHINCHOU,   30, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  TENTACRUEL, 33, PLAIN_FORM, 0,                  AURORA_BEAM
	; nite
	ow_wildmon 59, TENTACOOL,  30, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, TENTACOOL,  25, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 10, CHINCHOU,   30, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  TENTACRUEL, 33, PLAIN_FORM, 0,                  AURORA_BEAM
	end_ow_wildmons

	def_ow_wildmons ROUTE_27
	db 3 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, TENTACOOL,  20, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, TENTACOOL,  15, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 10, CHINCHOU,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  TENTACRUEL, 33, PLAIN_FORM, 0,                  AURORA_BEAM
	; day
	ow_wildmon 59, TENTACOOL,  20, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, TENTACOOL,  15, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 10, CHINCHOU,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  TENTACRUEL, 33, PLAIN_FORM, 0,                  AURORA_BEAM
	; nite
	ow_wildmon 59, TENTACOOL,  20, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, TENTACOOL,  15, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 10, CHINCHOU,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  TENTACRUEL, 33, PLAIN_FORM, 0,                  AURORA_BEAM
	end_ow_wildmons

	def_ow_wildmons ROUTE_28
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, POLIWAG,    40, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, POLIWAG,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, POLIWHIRL,  40, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 1,  POLIWAG,    38, PLAIN_FORM, 0,                  HAZE
	; day
	ow_wildmon 59, POLIWAG,    40, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, POLIWAG,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, POLIWHIRL,  40, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 1,  POLIWAG,    38, PLAIN_FORM, 0,                  HAZE
	; nite
	ow_wildmon 59, POLIWAG,    40, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, POLIWAG,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, POLIWHIRL,  40, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 1,  POLIWAG,    38, PLAIN_FORM, 0,                  HAZE
	end_ow_wildmons

	def_ow_wildmons CELADON_CITY
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, GRIMER,     20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GRIMER,     15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, MUK,        15, PLAIN_FORM, 0,                  LICK
	ow_wildmon 1,  GRIMER,     18, PLAIN_FORM, 0,                  LICK
	; day
	ow_wildmon 59, GRIMER,     20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GRIMER,     15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, MUK,        15, PLAIN_FORM, 0,                  LICK
	ow_wildmon 1,  GRIMER,     18, PLAIN_FORM, 0,                  LICK
	; nite
	ow_wildmon 59, GRIMER,     20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, GRIMER,     15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, MUK,        15, PLAIN_FORM, 0,                  LICK
	ow_wildmon 1,  GRIMER,     18, PLAIN_FORM, 0,                  LICK
	end_ow_wildmons

	def_ow_wildmons CINNABAR_ISLAND
	db 4 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, TENTACOOL,  35, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, TENTACOOL,  30, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 10, LANTURN,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  TENTACRUEL, 33, PLAIN_FORM, 0,                  AURORA_BEAM
	; day
	ow_wildmon 59, TENTACOOL,  35, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, TENTACOOL,  30, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 10, LANTURN,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  TENTACRUEL, 33, PLAIN_FORM, 0,                  AURORA_BEAM
	; nite
	ow_wildmon 59, TENTACOOL,  35, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, TENTACOOL,  30, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 10, LANTURN,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  TENTACRUEL, 33, PLAIN_FORM, 0,                  AURORA_BEAM
	end_ow_wildmons

	def_ow_wildmons FUCHSIA_CITY
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, MAGIKARP,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, MAGIKARP,   15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, MAGIKARP,   10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  MAGIKARP,   13, PLAIN_FORM, 0,                  BUBBLE
	; day
	ow_wildmon 59, MAGIKARP,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, MAGIKARP,   15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, MAGIKARP,   10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  MAGIKARP,   13, PLAIN_FORM, 0,                  BUBBLE
	; nite
	ow_wildmon 59, MAGIKARP,   20, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, MAGIKARP,   15, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, MAGIKARP,   10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  MAGIKARP,   13, PLAIN_FORM, 0,                  BUBBLE
	end_ow_wildmons

	def_ow_wildmons PALLET_TOWN
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, TENTACOOL,  35, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, TENTACOOL,  30, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 10, LANTURN,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  TENTACRUEL, 33, PLAIN_FORM, 0,                  AURORA_BEAM
	; day
	ow_wildmon 59, TENTACOOL,  35, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, TENTACOOL,  30, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 10, LANTURN,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  TENTACRUEL, 33, PLAIN_FORM, 0,                  AURORA_BEAM
	; nite
	ow_wildmon 59, TENTACOOL,  35, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, TENTACOOL,  30, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 10, LANTURN,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  TENTACRUEL, 33, PLAIN_FORM, 0,                  AURORA_BEAM
	end_ow_wildmons

	def_ow_wildmons VERMILION_CITY
	db 3 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, TENTACOOL,  35, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, TENTACOOL,  30, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 10, LANTURN,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  TENTACRUEL, 33, PLAIN_FORM, 0,                  AURORA_BEAM
	; day
	ow_wildmon 59, TENTACOOL,  35, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, TENTACOOL,  30, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 10, LANTURN,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  TENTACRUEL, 33, PLAIN_FORM, 0,                  AURORA_BEAM
	; nite
	ow_wildmon 59, TENTACOOL,  35, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, TENTACOOL,  30, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 10, LANTURN,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  TENTACRUEL, 33, PLAIN_FORM, 0,                  AURORA_BEAM
	end_ow_wildmons

	def_ow_wildmons VERMILION_PORT
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, TENTACOOL,  35, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, TENTACOOL,  30, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 10, LANTURN,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  TENTACRUEL, 33, PLAIN_FORM, 0,                  AURORA_BEAM
	; day
	ow_wildmon 59, TENTACOOL,  35, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, TENTACOOL,  30, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 10, LANTURN,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  TENTACRUEL, 33, PLAIN_FORM, 0,                  AURORA_BEAM
	; nite
	ow_wildmon 59, TENTACOOL,  35, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 30, TENTACOOL,  30, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 10, LANTURN,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  TENTACRUEL, 33, PLAIN_FORM, 0,                  AURORA_BEAM
	end_ow_wildmons

	def_ow_wildmons VIRIDIAN_CITY
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, POLIWAG,    10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, POLIWAG,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, POLIWHIRL,  10, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 1,  POLIWAG,     8, PLAIN_FORM, 0,                  HAZE
	; day
	ow_wildmon 59, POLIWAG,    10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, POLIWAG,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, POLIWHIRL,  10, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 1,  POLIWAG,     8, PLAIN_FORM, 0,                  HAZE
	; nite
	ow_wildmon 59, POLIWAG,    10, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, POLIWAG,     5, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, POLIWHIRL,  10, PLAIN_FORM, 0,                  HAZE
	ow_wildmon 1,  POLIWAG,     8, PLAIN_FORM, 0,                  HAZE
	end_ow_wildmons

	def_ow_wildmons SILVER_CAVE_OUTSIDE
	db 1 ; how many can be out at once
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 59, POLIWHIRL,  35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, POLIWHIRL,  40, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, POLIWAG,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  POLIWRATH,  43, PLAIN_FORM, 0,                  HAZE
	; day
	ow_wildmon 59, POLIWHIRL,  35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, POLIWHIRL,  40, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, POLIWAG,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  POLIWRATH,  43, PLAIN_FORM, 0,                  HAZE
	; nite
	ow_wildmon 59, POLIWHIRL,  35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 30, POLIWHIRL,  40, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 10, POLIWAG,    35, PLAIN_FORM, 0,                  NO_MOVE
	ow_wildmon 1,  POLIWRATH,  43, PLAIN_FORM, 0,                  HAZE
	end_ow_wildmons
	db -1 ; end of table
