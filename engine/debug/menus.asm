if DEF(_DEBUG)

; The three debug NPCs in the player's room (maps/PlayersHouse2F.asm), here for room in that bank.
; Each top menu leads to tools that are unchanged: the ones that expect the text box still open
; (Hidden Power, the lab items, the Open League, the animation viewer) are jumped to with it open;
; the ones that open their own close it first.

DebugStoryScript::
; The Scientist: ELM's lab (the beasts menu's FORCE SHINY covers the starters too), the beasts and
; Unown, the Open League, swarms, warps (the Rocket Base, Cerulean Cave 1F), and Kurt's two places
; at home.
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
	ifequal 6, .Kurt
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
	menu_coords 0, 0, 14, 15
	dw .MenuData
	db 1 ; default option

.MenuData:
	db STATICMENU_CURSOR ; flags
	db 7 ; items
	db "ELM'S LAB@"
	db "BEASTS@"
	db "E4 LINEUP@"
	db "SWARMS@"
	db "WARPS@"
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
