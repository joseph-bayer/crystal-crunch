if DEF(_DEBUG)

; The three debug NPCs in the player's room (maps/PlayersHouse2F.asm), here for room in that bank.
; Each top menu leads to tools that are unchanged: the ones that expect the text box still open
; (Hidden Power, the lab items, the Open League, the animation viewer) are jumped to with it open;
; the ones that open their own close it first.

DebugStoryScript::
; The Scientist: ELM's lab (the beasts menu's FORCE SHINY covers the starters too), the beasts and
; Unown, the Open League, swarms, warps (the Rocket Base, Cerulean Cave 1F), the legendaries'
; respawn, and Kurt's two places at home.
	faceplayer
	opentext
	writetext DebugStoryText
	loadmenu .MenuHeader
	verticalmenu
	closewindow
	ifequal 1, .ElmsLab
	ifequal 2, .Beasts
	ifequal 3, .EliteFourLineup
	ifequal 4, .Swarms
	ifequal 5, .Warps
	ifequal 6, .Legends
	ifequal 7, .Kurt
	closetext
	end

.ElmsLab:
	loadmenu .LabMenuHeader
	verticalmenu
	closewindow
	ifequal 1, .ReplayLab
	ifequal 2, .SkipTheft
	closetext
	end

.ReplayLab:
	farsjump PlayersHouseDebugLabItems.ReplayLab

.SkipTheft:
	farsjump PlayersHouseDebugLabItems.SkipTheft

.Beasts:
	closetext
	farsjump PlayersHouseDebugBeastsScript

.EliteFourLineup:
	farsjump DebugEliteFourLineupScript

.Swarms:
	closetext
	farsjump DebugSwarmScript

.Warps:
	loadmenu .WarpsMenuHeader
	verticalmenu
	closewindow
	ifequal 1, .RocketBase
	ifequal 2, .CeruleanCave1F
	closetext
	end

.RocketBase:
	closetext
	farsjump PlayersHouseDebugWarperScript

.CeruleanCave1F:
; On the floor just inside the exit to Cerulean City.
	closetext
	warp CERULEAN_CAVE_1F, 24, 16
	end

.Legends:
; The Elite Four respawn without the Elite Four, the wings Lugia and Ho-Oh need, a warp beside each
; one-off, and Celebi's GS Ball event set up again. Raikou and Entei are under BEASTS instead.
	loadmenu .LegendsMenuHeader
	verticalmenu
	closewindow
	ifequal 1, .RespawnNow
	ifequal 2, .GiveWings
	ifequal 3, .LegendWarps1
	ifequal 4, .LegendWarps2
	ifequal 5, .CelebiEvent
	closetext
	end

.RespawnNow:
	farscall RespawnLegendariesScript
	writetext DebugRespawnText
	waitbutton
	closetext
	end

.GiveWings:
	giveitem SILVER_WING
	giveitem RAINBOW_WING
	writetext DebugWingsText
	waitbutton
	closetext
	end

.CelebiEvent:
; The GS Ball and a restless forest, as Kurt leaves them, so the shrine plays Celebi's arrival again.
; Repeatable; BEASTS -> FORCE SHINY makes Celebi shiny.
	giveitem GS_BALL
	setevent EVENT_FOREST_IS_RESTLESS
	setflag ENGINE_FOREST_IS_RESTLESS
	clearevent EVENT_CELEBI_RETURNS
	closetext
	warp ILEX_FOREST, 8, 23
	end

.LegendWarps1:
	loadmenu .LegendWarps1MenuHeader
	verticalmenu
	closewindow
	ifequal 1, .Zapdos
	ifequal 2, .Articuno
	ifequal 3, .Moltres
	ifequal 4, .Lugia
	ifequal 5, .HoOh
	ifequal 6, .Suicune
	ifequal 7, .Mewtwo
	closetext
	end

.LegendWarps2:
	loadmenu .LegendWarps2MenuHeader
	verticalmenu
	closewindow
	ifequal 1, .Mew
	ifequal 2, .Celebi
	ifequal 3, .Sudowoodo
	ifequal 4, .VermilionSnorlax
	ifequal 5, .ApricornSnorlax
	ifequal 6, .RedGyarados
	ifequal 7, .Electrodes
	closetext
	end

.Zapdos:
	closetext
	warp ROUTE_10_NORTH, 4, 10
	end

.Articuno:
; On the shore; it's out on the water
	closetext
	warp ROUTE_20, 31, 9
	end

.Moltres:
	closetext
	warp VICTORY_ROAD, 17, 32
	end

.Lugia:
; At the chamber's entrance; it's out on the water
	closetext
	warp WHIRL_ISLAND_LUGIA_CHAMBER, 9, 13
	end

.HoOh:
	closetext
	warp TIN_TOWER_ROOF, 9, 6
	end

.Suicune:
; At the door, where its scene starts if it's still armed
	closetext
	warp TIN_TOWER_1F, 9, 15
	end

.Mewtwo:
	closetext
	warp CERULEAN_CAVE_B1F, 27, 14
	end

.Mew:
; In front of the truck
	closetext
	warp VERMILION_PORT, 14, 11
	end

.Celebi:
; In front of the shrine
	closetext
	warp ILEX_FOREST, 8, 23
	end

.Sudowoodo:
	closetext
	warp ROUTE_36, 34, 9
	end

.VermilionSnorlax:
; Its respawn spot on Route 11, not Vermilion City
	closetext
	warp ROUTE_11, 30, 13
	end

.ApricornSnorlax:
	closetext
	warp APRICORN_FOREST_CLEARING, 8, 4
	end

.RedGyarados:
; On the shore; it's out on the water
	closetext
	warp LAKE_OF_RAGE, 20, 26
	end

.Electrodes:
; On the tile the B1F stairs arrive at
	closetext
	warp TEAM_ROCKET_BASE_B2F, 3, 14
	end

.Kurt:
; Kurt's own flags only: the Rockets, Azalea's Slowpokes and the rival scene stay as they are.
; KurtsHouseKurtCallback places him the next time the house loads.
	loadmenu .KurtMenuHeader
	verticalmenu
	closewindow
	ifequal 1, .KurtFrontRoom
	ifequal 2, .KurtMakingBalls
	closetext
	end

.KurtFrontRoom:
	setevent EVENT_CLEARED_SLOWPOKE_WELL
	clearflag ENGINE_KURT_MAKING_BALLS
	writetext DebugKurtFrontRoomText
	waitbutton
	closetext
	end

.KurtMakingBalls:
	setevent EVENT_CLEARED_SLOWPOKE_WELL
	setflag ENGINE_KURT_MAKING_BALLS
	writetext DebugKurtMakingBallsText
	waitbutton
	closetext
	end

.MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 14, 17
	dw .MenuData
	db 1 ; default option

.MenuData:
	db STATICMENU_CURSOR ; flags
	db 8 ; items
	db "ELM'S LAB@"
	db "BEASTS@"
	db "E4 LINEUP@"
	db "SWARMS@"
	db "WARPS@"
	db "LEGENDS@"
	db "KURT@"
	db "CANCEL@"

.KurtMenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 15, 7
	dw .KurtMenuData
	db 1 ; default option

.KurtMenuData:
	db STATICMENU_CURSOR ; flags
	db 3 ; items
	db "FRONT ROOM@"
	db "MAKING BALLS@"
	db "CANCEL@"

.LegendsMenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 14, 13
	dw .LegendsMenuData
	db 1 ; default option

.LegendsMenuData:
	db STATICMENU_CURSOR ; flags
	db 6 ; items
	db "RESPAWN NOW@"
	db "GIVE WINGS@"
	db "WARPS 1@"
	db "WARPS 2@"
	db "CELEBI EVENT@"
	db "CANCEL@"

.LegendWarps1MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 14, 17
	dw .LegendWarps1MenuData
	db 1 ; default option

.LegendWarps1MenuData:
	db STATICMENU_CURSOR ; flags
	db 8 ; items
	db "ZAPDOS@"
	db "ARTICUNO@"
	db "MOLTRES@"
	db "LUGIA@"
	db "HO-OH@"
	db "SUICUNE@"
	db "MEWTWO@"
	db "CANCEL@"

.LegendWarps2MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 16, 17
	dw .LegendWarps2MenuData
	db 1 ; default option

.LegendWarps2MenuData:
	db STATICMENU_CURSOR ; flags
	db 8 ; items
	db "MEW@"
	db "CELEBI@"
	db "SUDOWOODO@"
	db "SNORLAX RT 11@"
	db "SNORLAX FOREST@"
	db "RED GYARADOS@"
	db "ELECTRODES@"
	db "CANCEL@"

.WarpsMenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 14, 7
	dw .WarpsMenuData
	db 1 ; default option

.WarpsMenuData:
	db STATICMENU_CURSOR ; flags
	db 3 ; items
	db "ROCKET BASE@"
	db "CERULEAN 1F@"
	db "CANCEL@"

.LabMenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 16, 7
	dw .LabMenuData
	db 1 ; default option

.LabMenuData:
	db STATICMENU_CURSOR ; flags
	db 3 ; items
	db "REPLAY LAB@"
	db "SKIP THE THEFT@"
	db "CANCEL@"

DebugBattlesScript::
; The Super Nerd: test battles and the trade screen.
	faceplayer
	opentext
	writetext DebugBattlesText
	loadmenu .MenuHeader
	verticalmenu
	closewindow
	ifequal 1, .HPBattles
	ifequal 2, .BrockPic
	ifequal 3, .Trade
	closetext
	end

.HPBattles:
	farsjump PlayersHouseDebugHPBattlesScript

.BrockPic:
	closetext
	farsjump PlayersHouseDebugTrainerPicScript

.Trade:
	closetext
	farsjump PlayersHouseDebugTraderScript

.MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 13, 9
	dw .MenuData
	db 1 ; default option

.MenuData:
	db STATICMENU_CURSOR ; flags
	db 4 ; items
	db "HP BATTLES@"
	db "BROCK PIC@"
	db "TRADE@"
	db "CANCEL@"

DebugToolsScript::
; The Youngster: the phone, Hidden Power, the HM party, the animation viewer and the Pokedex.
	faceplayer
	opentext
	writetext DebugToolsText
	loadmenu .MenuHeader
	verticalmenu
	closewindow
	ifequal 1, .Phone
	ifequal 2, .HPTools
	ifequal 3, .LearnersParty
	ifequal 4, .AnimViewer
	ifequal 5, .Pokedex
	closetext
	end

.Phone:
	closetext
	farsjump DebugPhoneScript

.HPTools:
	farsjump PlayersHouseDebugHPToolsScript

.LearnersParty:
	farsjump PlayersHouseDebugLabItems.LearnersParty

.AnimViewer:
	farsjump DebugAnimViewerScript

.Pokedex:
; Set the Pokedex to just under and just at Mew's 250-caught gate
	loadmenu .DexMenuHeader
	verticalmenu
	closewindow
	ifequal 1, .Dex249
	ifequal 2, .Dex250
	closetext
	end

.Dex249:
	callasm DebugSetDex249
	writetext DebugDex249Text
	waitbutton
	closetext
	end

.Dex250:
	callasm DebugSetDex250
	writetext DebugDex250Text
	waitbutton
	closetext
	end

.MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 16, 13
	dw .MenuData
	db 1 ; default option

.MenuData:
	db STATICMENU_CURSOR ; flags
	db 6 ; items
	db "PHONE@"
	db "HP TOOLS@"
	db "LEARNERS PARTY@"
	db "ANIM VIEWER@"
	db "#DEX@"
	db "CANCEL@"

.DexMenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 14, 7
	dw .DexMenuData
	db 1 ; default option

.DexMenuData:
	db STATICMENU_CURSOR ; flags
	db 3 ; items
	db "249 CAUGHT@"
	db "250 CAUGHT@"
	db "CANCEL@"

DebugStoryText:
	text "DEBUG: story."
	done

DebugRespawnText:
	text "DEBUG: legendaries"
	line "respawned."
	done

DebugWingsText:
	text "DEBUG: got the"
	line "SILVER and RAINBOW"
	cont "WINGS."
	done

DebugKurtFrontRoomText:
	text "DEBUG: KURT is"
	line "home, in the front"
	cont "room."
	done

DebugKurtMakingBallsText:
	text "DEBUG: KURT is"
	line "making BALLS until"
	cont "tomorrow."
	done

DebugBattlesText:
	text "DEBUG: battles."
	done

DebugToolsText:
	text "DEBUG: tools."
	done

DebugDex249Text:
	text "DEBUG: #DEX"
	line "set to 249 caught."
	done

DebugDex250Text:
	text "DEBUG: #DEX"
	line "set to 250 caught."
	done

endc
