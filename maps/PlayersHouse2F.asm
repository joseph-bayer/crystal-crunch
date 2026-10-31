	object_const_def
	const PLAYERSHOUSE2F_CONSOLE
	const PLAYERSHOUSE2F_DOLL_1
	const PLAYERSHOUSE2F_DOLL_2
	const PLAYERSHOUSE2F_BIG_DOLL
if DEF(_DEBUG)
	const PLAYERSHOUSE2F_DEBUG_STORY
	const PLAYERSHOUSE2F_DEBUG_BATTLES
	const PLAYERSHOUSE2F_DEBUG_TOOLS
endc

PlayersHouse2F_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_NEWMAP, PlayersHouse2FInitializeRoomCallback
	callback MAPCALLBACK_TILES, PlayersHouse2FSetUpTileDecorationsCallback

PlayersHouse2FInitializeRoomCallback:
	special ToggleDecorationsVisibility
	setevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_8
	checkevent EVENT_INITIALIZED_EVENTS
	iftrue .SkipInitialization
	jumpstd InitializeEventsScript
	endcallback

.SkipInitialization:
	endcallback

PlayersHouse2FSetUpTileDecorationsCallback:
	special ToggleMaptileDecorations
	endcallback

	db 0, 0, 0 ; unused

PlayersHouseDoll1Script::
	describedecoration DECODESC_LEFT_DOLL

PlayersHouseDoll2Script:
	describedecoration DECODESC_RIGHT_DOLL

PlayersHouseBigDollScript:
	describedecoration DECODESC_BIG_DOLL

PlayersHouseGameConsoleScript:
	describedecoration DECODESC_CONSOLE

PlayersHousePosterScript:
	conditional_event EVENT_PLAYERS_ROOM_POSTER, .Script

.Script:
	describedecoration DECODESC_POSTER

PlayersHouseRadioScript:
if DEF(_DEBUG)
	opentext
	; full pokegear
	setflag ENGINE_POKEGEAR
	setflag ENGINE_PHONE_CARD
	setflag ENGINE_MAP_CARD
	setflag ENGINE_RADIO_CARD
	setflag ENGINE_EXPN_CARD
	; pokedex
	setflag ENGINE_POKEDEX
	; useful items
	giveitem RARE_CANDY, 99
	giveitem MAX_REPEL, 99
	giveitem MASTER_BALL, 99
	giveitem BICYCLE
	giveitem GOOD_ROD
	giveitem PASS ; Magnet Train
	giveitem BADGE_CASE ; sets the badge count
	giveitem THUNDERSTONE, 10
	giveitem FIRE_STONE, 10
	giveitem WATER_STONE, 10
	giveitem LEAF_STONE, 10
	giveitem MOON_STONE, 10
	giveitem SUN_STONE, 10
	giveitem BERRY, 10
	giveitem GOLD_BERRY, 10
	giveitem MINT_BERRY, 10
	giveitem MYSTERYBERRY, 10
	giveitem QUICK_CLAW
	giveitem KINGS_ROCK
	giveitem AMULET_COIN
	giveitem SCOPE_LENS
	giveitem RARE_CANDY
	; all badges
	setflag ENGINE_ZEPHYRBADGE
	setflag ENGINE_HIVEBADGE
	setflag ENGINE_PLAINBADGE
	setflag ENGINE_FOGBADGE
	setflag ENGINE_STORMBADGE
	setflag ENGINE_MINERALBADGE
	setflag ENGINE_GLACIERBADGE
	setflag ENGINE_RISINGBADGE
	setflag ENGINE_BOULDERBADGE
	setflag ENGINE_CASCADEBADGE
	setflag ENGINE_THUNDERBADGE
	setflag ENGINE_RAINBOWBADGE
	setflag ENGINE_MARSHBADGE
	setflag ENGINE_SOULBADGE
	setflag ENGINE_VOLCANOBADGE
	setflag ENGINE_EARTHBADGE
	setevent EVENT_BEAT_FALKNER
	setevent EVENT_BEAT_BUGSY
	setevent EVENT_BEAT_WHITNEY
	setevent EVENT_BEAT_MORTY
	setevent EVENT_BEAT_CHUCK
	setevent EVENT_BEAT_JASMINE
	setevent EVENT_BEAT_PRYCE
	setevent EVENT_BEAT_CLAIR
	setevent EVENT_BEAT_BROCK
	setevent EVENT_BEAT_MISTY
	setevent EVENT_BEAT_LTSURGE
	setevent EVENT_BEAT_ERIKA
	setevent EVENT_BEAT_JANINE
	setevent EVENT_BEAT_SABRINA
	setevent EVENT_BEAT_BLAINE
	setevent EVENT_BEAT_BLUE
	setevent EVENT_BEAT_ELITE_FOUR
	setevent EVENT_RESTORED_POWER_TO_KANTO ; Magnet Train
	; fly anywhere
	setflag ENGINE_FLYPOINT_NEW_BARK
	setflag ENGINE_FLYPOINT_CHERRYGROVE
	setflag ENGINE_FLYPOINT_VIOLET
	setflag ENGINE_FLYPOINT_RUINS_OF_ALPH
	setflag ENGINE_FLYPOINT_AZALEA
	setflag ENGINE_FLYPOINT_GOLDENROD
	setflag ENGINE_FLYPOINT_ECRUTEAK
	setflag ENGINE_FLYPOINT_OLIVINE
	setflag ENGINE_FLYPOINT_CIANWOOD
	setflag ENGINE_FLYPOINT_MAHOGANY
	setflag ENGINE_FLYPOINT_LAKE_OF_RAGE
	setflag ENGINE_FLYPOINT_BLACKTHORN
	setflag ENGINE_FLYPOINT_SILVER_CAVE
	setflag ENGINE_FLYPOINT_INDIGO_PLATEAU
	setflag ENGINE_FLYPOINT_PALLET
	setflag ENGINE_FLYPOINT_VIRIDIAN
	setflag ENGINE_FLYPOINT_PEWTER
	setflag ENGINE_FLYPOINT_CERULEAN
	setflag ENGINE_FLYPOINT_VERMILION
	setflag ENGINE_FLYPOINT_CELADON
	setflag ENGINE_FLYPOINT_ROCK_TUNNEL
	setflag ENGINE_FLYPOINT_LAVENDER
	setflag ENGINE_FLYPOINT_FUCHSIA
	setflag ENGINE_FLYPOINT_SAFFRON
	setflag ENGINE_FLYPOINT_CINNABAR
	; post-e4
	setflag ENGINE_CREDITS_SKIP
	; good party
	givepoke MEWTWO, 100, BRIGHTPOWDER
	; hm slaves
	givepoke MEW, 100, LEFTOVERS
	givepoke LANTURN, 100, LEFTOVERS
	givepokemove FLY,        wPartyMon2, 0
	givepokemove SURF,       wPartyMon2, 1
	givepokemove STRENGTH,   wPartyMon2, 2
	givepokemove CUT,        wPartyMon2, 3
	givepokemove FLASH,      wPartyMon3, 0
	givepokemove ROCK_SMASH, wPartyMon3, 1
	givepokemove HEADBUTT,   wPartyMon3, 2
	givepokemove WATERFALL,  wPartyMon3, 3

	; DEBUG: RB form breeding -- a beta Kingdra and a Ditto, in party
	; slots 4 and 5. Their eggs should always hatch an RB Horsea.
	givepoke KINGDRA, 50, NO_ITEM, KINGDRA_BETA_FORM
	; givepoke DITTO, 50

	givepoke AMPHAROS, 50
	; DEBUG: Substitute -- a level 5 Caterpie, whose small HP is quick to bring under a quarter.
	givepoke CATERPIE, 5
	givepokemove SUBSTITUTE, wPartyMon6, 0
	; givepoke GENGAR, 50
	; A form Pikachu to make the follower, for the doll test below.
	; givepoke PIKACHU, 50, NO_ITEM, PIKACHU_FLY_FORM
	; An egg, for testing egg followers -- select it in the party and it walks around with you.
	; giveegg TOGEPI, EGG_LEVEL
	; givepoke DITTO, 50

	; DEBUG: CHECK If two Pokemon with same DEF and SPEC DVs can breed
	; change lanturn's DVs
	; loadmem wPartyMon3DVs+0, %00000000 ; 0 Atk (FEMALE), 0 Def
	; loadmem wPartyMon3DVs+1, %00000000 ; 0 Speed, 0 Special
	; givepoke LANTURN, 100, LEFTOVERS
	; ; change lanturn 2's DVs
	; loadmem wPartyMon4DVs+0, %11110000 ; 15 Atk (MALE), 0 Def
	; loadmem wPartyMon4DVs+1, %00000000 ; 0 Speed, 0 Special

	; ; misc pokemon for testing
	; givepoke PIKACHU, 50, NO_ITEM, PIKACHU_RB_FORM
	; givepoke PIKACHU, 50, NO_ITEM, PIKACHU_SURF_FORM
	; givepoke UNOWN, 50
	; givepoke MAGIKARP, 50
	; givepoke MAGIKARP, 50, NO_ITEM, MAGIKARP_XL_FORM
	; givepoke MAGIKARP, 50, NO_ITEM, MAGIKARP_XS_FORM
	; givepoke PIKACHU, 50
	; givepoke SMEARGLE, 50, NO_ITEM, SMEARGLE_BLUE_FORM | SHINY_MASK
	; ; givepoke SMEARGLE, 50
	; givepoke SMEARGLE, 50, NO_ITEM, SMEARGLE_BLUE_FORM
	; givepoke SMEARGLE, 50, NO_ITEM, SMEARGLE_YELLOW_FORM
	; givepoke SMEARGLE, 50, NO_ITEM, SMEARGLE_PURPLE_FORM
	; givepoke SMEARGLE, 50, NO_ITEM, SMEARGLE_GREEN_FORM
	; givepoke SMEARGLE, 50, NO_ITEM, SMEARGLE_ORANGE_FORM
	; givepoke SMEARGLE, 50, NO_ITEM, 0 | SHINY_MASK
	; ; givepoke SCYTHER, 50
	; givepoke SCYTHER, 50, NO_ITEM, SCYTHER_FOREST_GREEN_FORM
	; givepoke SCYTHER, 50, NO_ITEM, SCYTHER_TEAL_FORM
	; givepoke SCYTHER, 50, NO_ITEM, SCYTHER_TEAL_FORM | SHINY_MASK
	; ; givepoke SCIZOR, 50
	; givepoke SCIZOR, 50, NO_ITEM, SCIZOR_CRIMSON_FORM
	; givepoke SCIZOR, 50, NO_ITEM, SCIZOR_DUSTY_ROSE_FORM
	; givepoke SCIZOR, 50, NO_ITEM, SCIZOR_DUSTY_ROSE_FORM | SHINY_MASK
	; ; givepoke PINSIR, 50
	; givepoke PINSIR, 50, NO_ITEM, PINSIR_VINE_FORM
	; givepoke PINSIR, 50, NO_ITEM, PINSIR_SLATE_FORM
	; givepoke PINSIR, 50, NO_ITEM, PINSIR_SLATE_FORM | SHINY_MASK
	; Five Unown spread across the alphabet, to spot check form followers.
	; NOTE: the wrong-letter cause is SendMonIntoBox -- for Unown it overwrites wForm with the
	; generated mon's form, and GivePoke then stores that instead of the form it was asked for.
	; FillPCWithEveryForm below works around it by re-stamping the form after GivePoke returns.
	; NOTE 2: Gifting an UNOWN before completing the puzzle in the ruins of alph causes the game to crash. Either do that before uncommenting this code or figure out what flags need to be set.
	; givepoke UNOWN, 50, NO_ITEM, UNOWN_A
	; givepoke UNOWN, 50, NO_ITEM, UNOWN_G
	; givepoke UNOWN, 50, NO_ITEM, UNOWN_N
	; givepoke UNOWN, 50, NO_ITEM, UNOWN_T
	; givepoke UNOWN, 50, NO_ITEM, UNOWN_Z

	; One of every species and every color form, in order, filling the PC for palette review.
	; The party is full by this point, so all of them land in the boxes.
	; Comment this out for a normal debug run -- it takes a moment and fills 15 boxes.
	callasm FillPCWithEveryForm

	; Unlock the Pokemon dolls, to check whether a map object's icon picks up the follower's
	; form byte. Place one from the PC's Decoration menu, then make the Flying Pikachu above
	; your follower and see whether the Pikachu doll stays plain.
	callasm GiveDebugDolls


	giveitem HM_SURF
	giveitem HM_FLY

	; DEBUG: Test new evolution items
	; giveitem KINGS_ROCK, 2
	; giveitem METAL_COAT, 3
	; giveitem DRAGON_SCALE, 1
	; giveitem UP_GRADE, 1
	; givepoke PORYGON, 50, LEFTOVERS
	; givepoke POLIWHIRL, 50, LEFTOVERS
	; givepoke SLOWPOKE, 50, LEFTOVERS
	; givepoke SCYTHER, 50, LEFTOVERS
	; givepoke ONIX, 50, LEFTOVERS
	; givepoke SEADRA, 50, LEFTOVERS

	; Start the Dunsparce and Yanma swarms, so Dark Cave and Route 35 can be checked without waiting on
	; a phone call. The daily reset clears them at midnight; use the radio again to restart them.
	swarm SWARM_DUNSPARCE
	swarm SWARM_YANMA

	; intro events
	addcellnum PHONE_MOM
	setmapscene PLAYERS_HOUSE_1F, $1
	setevent EVENT_PLAYERS_HOUSE_MOM_1
	clearevent EVENT_PLAYERS_HOUSE_MOM_2

  special UnlockMysteryGift
  ; DEBUG: testing new rocket takeover npc placements
;   clearevent EVENT_RADIO_TOWER_ROCKET_TAKEOVER
	closetext
	end
else

	checkevent EVENT_GOT_A_POKEMON_FROM_ELM
	iftrue .NormalRadio
	checkevent EVENT_LISTENED_TO_INITIAL_RADIO
	iftrue .AbbreviatedRadio
	playmusic MUSIC_POKEMON_TALK
	opentext
	writetext PlayersRadioText1
	pause 45
	writetext PlayersRadioText2
	pause 45
	writetext PlayersRadioText3
	pause 45
	musicfadeout MUSIC_NEW_BARK_TOWN, 16
	writetext PlayersRadioText4
	pause 45
	closetext
	setevent EVENT_LISTENED_TO_INITIAL_RADIO
	end

.NormalRadio:
	jumpstd Radio1Script

.AbbreviatedRadio:
	opentext
	writetext PlayersRadioText4
	pause 45
	closetext
	end

endc

PlayersHouseBookshelfScript:
	stowfollower
	end
	;jumpstd PictureBookshelfScript

PlayersHousePCScript:
	opentext
	special PlayersHousePC
	iftrue .Warp
	closetext
	end
.Warp:
	warp NONE, 0, 0
	end

PlayersRadioText1:
	text "PROF.OAK'S #MON"
	line "TALK! Please tune"
	cont "in next time!"
	done

PlayersRadioText2:
	text "#MON CHANNEL!"
	done

PlayersRadioText3:
	text "This is DJ MARY,"
	line "your co-host!"
	done

PlayersRadioText4:
	text "#MON!"
	line "#MON CHANNEL…"
	done

if DEF(_DEBUG)
PlayersHouseDebugWarperScript::
; Drops you straight into the Rocket Base B2F Electrode room, on the tile the B1F
; stairs arrive at. Talk to him again from down there? No -- walk back up the stairs.
;
; He hands over the door passwords on the way, so neither locked door stops you: "hail Giovanni"
; for the B2F transmitter room, and the Slowpoketail and Raticate tail pair for Giovanni's office
; on B3F. The doors still have to be opened by talking to them, which is the thing worth testing.
	faceplayer
	opentext
	writetext PlayersHouseDebugWarperText
	waitbutton
	closetext
	setevent EVENT_LEARNED_HAIL_GIOVANNI
	setevent EVENT_LEARNED_SLOWPOKETAIL
	setevent EVENT_LEARNED_RATICATE_TAIL
	warp TEAM_ROCKET_BASE_B2F, 3, 14
	end

PlayersHouseDebugWarperText:
	text "DEBUG: to the"
	line "ROCKET BASE B2F,"
	cont "passwords and all."
	done

PlayersHouseDebugTraderScript::
; Reaches the trade screen on demand, as often as you like. See NPC_TRADE_DEBUG.
; The wrapping matters: trade draws into a text window, so without opentext around it the box
; lands in the wrong place and the font is never loaded.
	faceplayer
	opentext
	trade NPC_TRADE_DEBUG
	waitbutton
	closetext
	end

PlayersHouseDebugBeastsScript::
; Debug tools for the legendary beasts and the wandering Unown. The menu takes the whole screen
; height, over where the text box would be, so there is no title text.
	faceplayer
	opentext
	loadmenu .MenuHeader
	verticalmenu
	closewindow
	ifequal 1, .PostRelease
	ifequal 2, .ReplayTower
	ifequal 3, .ToggleShiny
	ifequal 4, .ToggleFollow
	ifequal 5, .UnlockUnown
	ifequal 6, .RelockUnown
	ifequal 7, .ToTheRuins
	closetext
	end

.PostRelease:
; Everything ReleaseTheBeasts leaves behind, without playing it, plus the Map Card.
	setevent EVENT_RELEASED_THE_BEASTS
	setevent EVENT_BURNED_TOWER_B1F_BEASTS_1
	setevent EVENT_BURNED_TOWER_B1F_BEASTS_2
	clearevent EVENT_EUSINE_IN_BURNED_TOWER
	setmapscene BURNED_TOWER_B1F, SCENE_BURNEDTOWERB1F_NOOP
	special InitRoamMons
	setmapscene ECRUTEAK_GYM, SCENE_ECRUTEAKGYM_NOOP
	setmapscene CIANWOOD_CITY, SCENE_CIANWOODCITY_SUICUNE_AND_EUSINE
	clearevent EVENT_SAW_SUICUNE_AT_CIANWOOD_CITY
	setevent EVENT_ECRUTEAK_GYM_GRAMPS
	clearevent EVENT_ECRUTEAK_CITY_GRAMPS
	setevent EVENT_BURNED_TOWER_MORTY
	setevent EVENT_BURNED_TOWER_1F_EUSINE
	setflag ENGINE_MAP_CARD
	writetext PlayersHouseDebugBeastsReleasedText
	waitbutton
	closetext
	end

.ReplayTower:
; Reset B1F to its new-game state and drop in where the fall from 1F lands, below the trigger.
	clearevent EVENT_RELEASED_THE_BEASTS
	setevent EVENT_BURNED_TOWER_B1F_BEASTS_1
	clearevent EVENT_BURNED_TOWER_B1F_BEASTS_2
	setevent EVENT_EUSINE_IN_BURNED_TOWER
	setmapscene BURNED_TOWER_B1F, SCENE_BURNEDTOWERB1F_RELEASE_THE_BEASTS
	closetext
	warp BURNED_TOWER_B1F, 10, 9
	end

.ToggleShiny:
; Makes RollLegendaryShiny always hit.
	checkevent EVENT_DEBUG_FORCE_SHINY_BEASTS
	iftrue .ShinyOff
	setevent EVENT_DEBUG_FORCE_SHINY_BEASTS
	writetext PlayersHouseDebugBeastsShinyOnText
	waitbutton
	closetext
	end

.ShinyOff:
	clearevent EVENT_DEBUG_FORCE_SHINY_BEASTS
	writetext PlayersHouseDebugBeastsShinyOffText
	waitbutton
	closetext
	end

.ToggleFollow:
; Roamers that are out land on each roaming route the player walks onto (by connection or door;
; warps and Fly don't move roamers).
	checkevent EVENT_DEBUG_BEASTS_FOLLOW_PLAYER
	iftrue .FollowOff
	setevent EVENT_DEBUG_BEASTS_FOLLOW_PLAYER
	writetext PlayersHouseDebugBeastsFollowOnText
	waitbutton
	closetext
	end

.FollowOff:
	clearevent EVENT_DEBUG_BEASTS_FOLLOW_PLAYER
	writetext PlayersHouseDebugBeastsFollowOffText
	waitbutton
	closetext
	end

.UnlockUnown:
; The next letter group in puzzle order, as solving that puzzle would. Only the flag: the puzzles,
; the Inner Chamber's tourists and its presence scene are left as they are.
	checkflag ENGINE_UNLOCKED_UNOWNS_A_TO_K
	iffalse .UnlockAToK
	checkflag ENGINE_UNLOCKED_UNOWNS_L_TO_R
	iffalse .UnlockLToR
	checkflag ENGINE_UNLOCKED_UNOWNS_S_TO_W
	iffalse .UnlockSToW
	checkflag ENGINE_UNLOCKED_UNOWNS_X_TO_Z
	iffalse .UnlockXToZ
	writetext PlayersHouseDebugUnownAllText
	sjump .UnownDone

.UnlockAToK:
	setflag ENGINE_UNLOCKED_UNOWNS_A_TO_K
	writetext PlayersHouseDebugUnownAToKText
	sjump .UnownDone

.UnlockLToR:
	setflag ENGINE_UNLOCKED_UNOWNS_L_TO_R
	writetext PlayersHouseDebugUnownLToRText
	sjump .UnownDone

.UnlockSToW:
	setflag ENGINE_UNLOCKED_UNOWNS_S_TO_W
	writetext PlayersHouseDebugUnownSToWText
	sjump .UnownDone

.UnlockXToZ:
	setflag ENGINE_UNLOCKED_UNOWNS_X_TO_Z
	writetext PlayersHouseDebugUnownXToZText
	sjump .UnownDone

.RelockUnown:
; Back to before any puzzle: no wandering Unown and no floor encounters in the Inner Chamber.
	clearflag ENGINE_UNLOCKED_UNOWNS_A_TO_K
	clearflag ENGINE_UNLOCKED_UNOWNS_L_TO_R
	clearflag ENGINE_UNLOCKED_UNOWNS_S_TO_W
	clearflag ENGINE_UNLOCKED_UNOWNS_X_TO_Z
	writetext PlayersHouseDebugUnownRelockedText
.UnownDone:
	waitbutton
	closetext
	end

.ToTheRuins:
; In front of the Inner Chamber's door on Ruins of Alph Outside, where the Unown are.
	closetext
	warp RUINS_OF_ALPH_OUTSIDE, 10, 14
	end

.MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 15, SCREEN_HEIGHT - 1 ; eight items, two rows apart: the whole height
	dw .MenuData
	db 1 ; default option

.MenuData:
	db STATICMENU_CURSOR ; flags
	db 8 ; items
	db "POST-RELEASE@"
	db "REPLAY TOWER@"
	db "FORCE SHINY@"
	db "BEASTS FOLLOW@"
	db "UNLOCK UNOWN@"
	db "RELOCK UNOWN@"
	db "RUINS OF ALPH@"
	db "CANCEL@"

PlayersHouseDebugUnownAToKText:
	text "DEBUG: UNOWN A-K"
	line "unlocked."
	done

PlayersHouseDebugUnownLToRText:
	text "DEBUG: UNOWN L-R"
	line "unlocked."
	done

PlayersHouseDebugUnownSToWText:
	text "DEBUG: UNOWN S-W"
	line "unlocked."
	done

PlayersHouseDebugUnownXToZText:
	text "DEBUG: UNOWN X-Z"
	line "unlocked."
	done

PlayersHouseDebugUnownAllText:
	text "DEBUG: every UNOWN"
	line "is unlocked."
	done

PlayersHouseDebugUnownRelockedText:
	text "DEBUG: every UNOWN"
	line "is locked again."
	done

PlayersHouseDebugBeastsShinyOnText:
	text "DEBUG: beasts and"
	line "ELM's starters"
	cont "always roll shiny."
	done

PlayersHouseDebugBeastsShinyOffText:
	text "DEBUG: beasts and"
	line "ELM's starters"
	cont "roll at the usual"
	cont "1/512 again."
	done

PlayersHouseDebugBeastsFollowOnText:
	text "DEBUG: beasts that"
	line "are out follow you"
	cont "onto routes."
	done

PlayersHouseDebugBeastsFollowOffText:
	text "DEBUG: beasts roam"
	line "on their own again."
	done

PlayersHouseDebugBeastsReleasedText:
	text "DEBUG: the beasts"
	line "are roaming, and"
	cont "you have the MAP"
	cont "CARD."
	done

PlayersHouseDebugPhoneScript:
; The phone debug tools live in engine/debug/phone.asm, for room in this bank.
	farsjump DebugPhoneScript

PlayersHouseDebugTrainerPicScript::
; A battle with BROCK, to check a trainer pic that uses extra palettes. It can be lost without
; whiting out (see PlayersHouseDebugHPBattlesScript).
	faceplayer
	opentext
	writetext PlayersHouseDebugTrainerPicText
	yesorno
	iffalse .done
	closetext
	winlosstext PlayersHouseDebugBattleWinText, PlayersHouseDebugBattleWinText
	loadtrainer BROCK, BROCK1
	loadvar VAR_BATTLETYPE, BATTLETYPE_CANLOSE
	startbattle
	reloadmap
	end

.done
	closetext
	end

; The three debug NPCs' top menus live in engine/debug/menus.asm, for room in this bank.
PlayersHouseDebugStoryScript:
	farsjump DebugStoryScript

PlayersHouseDebugBattlesScript:
	farsjump DebugBattlesScript

PlayersHouseDebugToolsScript:
	farsjump DebugToolsScript

PlayersHouseDebugLabItems::
; Reached from the debug menus (engine/debug/menus.asm) with the text box still open.

.LearnersParty::
; For the HM rule: Feraligatr, Pidgeot and Ampharos can learn every HM and Rock Smash between them
; (with a Pikachu and an egg behind them)
; and know none of them, so a field move can only come from "can learn it". Replaces the party
; (the follower becomes Feraligatr), gives every HM, and marks TM08 received, which is what owning
; it means for Rock Smash.
	callasm DebugEmptyParty
	givepoke FERALIGATR, 50
	givepoke PIDGEOT, 50
	givepoke AMPHAROS, 50
	; Pikachu can learn Surf and Fly, for the Surfing and Flying forms; behind the others, so it
	; doesn't change who uses what. The egg, last, checks that eggs are skipped.
	givepoke PIKACHU, 50
	giveegg TOGEPI, EGG_LEVEL
	giveitem HM_CUT
	giveitem HM_FLY
	giveitem HM_SURF
	giveitem HM_STRENGTH
	giveitem HM_FLASH
	giveitem HM_WHIRLPOOL
	giveitem HM_WATERFALL
	giveitem TM_ROCK_SMASH
	setevent EVENT_GOT_TM08_ROCK_SMASH
	writetext PlayersHouseDebugLabLearnersText
	waitbutton
	closetext
	end

.ReplayLab::
; Back to just before the pick: all three on the table and ELM waiting, without the intro, so
; walking in rolls them again. Picking again gives another starter, which may go to the PC.
; Lands just inside, past the coord events that stop you leaving before you pick.
	clearevent EVENT_GOT_A_POKEMON_FROM_ELM
	clearevent EVENT_GOT_CYNDAQUIL_FROM_ELM
	clearevent EVENT_GOT_TOTODILE_FROM_ELM
	clearevent EVENT_GOT_CHIKORITA_FROM_ELM
	clearevent EVENT_CYNDAQUIL_POKEBALL_IN_ELMS_LAB
	clearevent EVENT_TOTODILE_POKEBALL_IN_ELMS_LAB
	clearevent EVENT_CHIKORITA_POKEBALL_IN_ELMS_LAB
	setevent EVENT_COP_IN_ELMS_LAB
	setmapscene ELMS_LAB, SCENE_ELMSLAB_CANT_LEAVE
	closetext
	warp ELMS_LAB, 4, 5
	end

.SkipTheft::
; What the end of Mr. Pokemon's visit does to the lab: SILVER takes the starter strong against yours.
	checkevent EVENT_GOT_A_POKEMON_FROM_ELM
	iffalse .PickFirst
	checkevent EVENT_GOT_TOTODILE_FROM_ELM
	iftrue .TakesChikorita
	checkevent EVENT_GOT_CHIKORITA_FROM_ELM
	iftrue .TakesCyndaquil
	setevent EVENT_TOTODILE_POKEBALL_IN_ELMS_LAB
	sjump .Stolen

.TakesChikorita:
	setevent EVENT_CHIKORITA_POKEBALL_IN_ELMS_LAB
	sjump .Stolen

.TakesCyndaquil:
	setevent EVENT_CYNDAQUIL_POKEBALL_IN_ELMS_LAB
.Stolen:
	writetext PlayersHouseDebugLabStolenText
	sjump .Done

.PickFirst:
	writetext PlayersHouseDebugLabPickFirstText
.Done:
	waitbutton
	closetext
	end

PlayersHouseDebugHPToolsScript::
; Tools for testing Hidden Power: the lead's Hidden Power level, the
; stats page, one 256-step cycle's rolls, a GLYPH SHARD, and a pair whose higher stat is the other
; side from their Hidden Power type.
	writetext PlayersHouseDebugHiddenPowerText
	loadmenu .MenuHeader
	verticalmenu
	closewindow
	ifequal 1, .HPLevel
	ifequal 2, .HPPage
	ifequal 3, .HPStep
	ifequal 4, .GlyphShard
	ifequal 5, .TestPair
	ifequal 6, .GiveUnown
	closetext
	end

.GiveUnown:
; For the Unown-in-the-party roll, so it has to land in the party.
	readvar VAR_PARTYCOUNT
	ifequal PARTY_LENGTH, .GiveUnownNoRoom
	givepoke UNOWN, 50
	writetext PlayersHouseDebugGiveUnownText
	waitbutton
	closetext
	end

.GiveUnownNoRoom:
	writetext PlayersHouseDebugGiveUnownNoRoomText
	waitbutton
	closetext
	end

.HPLevel:
	callasm DebugGetLeadHPLevel
.HPLevelLoop:
	writetext PlayersHouseDebugHPLevelText
	loadmenu .HPLevelMenuHeader
	verticalmenu
	closewindow
	iffalse .HPLevelDone
	ifequal 5, .HPLevelDone
	callasm DebugSetLeadHPLevel
	sjump .HPLevelLoop

.HPLevelDone:
	closetext
	end

.HPPage:
	setevent EVENT_HIDDEN_POWER_PAGE_UNLOCKED
	writetext PlayersHouseDebugHPPageText
	waitbutton
	closetext
	end

.HPStep:
; One 256-step cycle's Hidden Power rolls, without the walking.
	callasm StepHiddenPower
	writetext PlayersHouseDebugHPStepText
	waitbutton
	closetext
	end

.GlyphShard:
	giveitem GLYPH_SHARD
	writetext PlayersHouseDebugGlyphShardText
	waitbutton
	closetext
	end

.TestPair:
; DebugSetUpHiddenPowerPair sets up the last two party mons, so both have to land in the party.
	readvar VAR_PARTYCOUNT
	ifgreater PARTY_LENGTH - 2, .TestPairNoRoom
	givepoke MACHAMP, 50
	givepoke ALAKAZAM, 50
	callasm DebugSetUpHiddenPowerPair
	writetext PlayersHouseDebugTestPairText
	waitbutton
	closetext
	end

.TestPairNoRoom:
	writetext PlayersHouseDebugTestPairNoRoomText
	waitbutton
	closetext
	end

.MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 13, 15
	dw .MenuData
	db 1 ; default option

.MenuData:
	db STATICMENU_CURSOR ; flags
	db 7 ; items
	db "HP LEVEL@"
	db "HP PAGE@"
	db "HP STEP@"
	db "GLYPH SHARD@"
	db "TEST PAIR@"
	db "GIVE UNOWN@"
	db "CANCEL@"

.HPLevelMenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 9, 11
	dw .HPLevelMenuData
	db 1 ; default option

.HPLevelMenuData:
	db STATICMENU_CURSOR ; flags
	db 5 ; items
	db "UP 1@"
	db "DOWN 1@"
	db "SET 0@"
	db "SET 15@"
	db "DONE@"

PlayersHouseDebugHPBattlesScript::
; Hidden Power test battles.
	writetext PlayersHouseDebugHiddenPowerText
	loadmenu .MenuHeader
	verticalmenu
	closewindow
	ifequal 1, .WildMew
	ifequal 2, .WildUnown
	ifequal 3, .Screens
	ifequal 4, .EnemyHiddenPower
	closetext
	end

; Every test battle can be lost without whiting out: BATTLETYPE_CANLOSE, then `reloadmap` rather
; than `reloadmapafterbattle` (which whites out on a loss), as CherrygroveCity's rival battle does.
.WildMew:
; Psychic, so every Hidden Power type connects.
	closetext
	loadwildmon MEW, 50
	loadvar VAR_BATTLETYPE, BATTLETYPE_CANLOSE
	startbattle
	reloadmap
	end

.WildUnown:
; Knows only Hidden Power: as a wild mon, level 0, so 20 power (Unown's table only differs above
; 0). A wild Unown takes a random unlocked letter, and with none unlocked that pick never ends.
	readmem wUnlockedUnowns
	iffalse .NoUnownLetters
	closetext
	loadwildmon UNOWN, 50
	loadvar VAR_BATTLETYPE, BATTLETYPE_CANLOSE
	startbattle
	reloadmap
	end

.NoUnownLetters:
	writetext PlayersHouseDebugNoUnownLettersText
	waitbutton
	closetext
	end

.Screens:
; Two MR.MIME, one knowing only REFLECT, then one knowing only LIGHT SCREEN.
	closetext
	winlosstext PlayersHouseDebugBattleWinText, PlayersHouseDebugBattleWinText
	loadtrainer SCIENTIST, SCIENTIST_DEBUG_SCREENS
	loadvar VAR_BATTLETYPE, BATTLETYPE_CANLOSE
	startbattle
	reloadmap
	end

.EnemyHiddenPower:
; MACHAMP and ALAKAZAM, each knowing only HIDDEN POWER: 70, on the side of their higher stat.
	closetext
	winlosstext PlayersHouseDebugBattleWinText, PlayersHouseDebugBattleWinText
	loadtrainer SCIENTIST, SCIENTIST_DEBUG_HIDDEN_POWER
	loadvar VAR_BATTLETYPE, BATTLETYPE_CANLOSE
	startbattle
	reloadmap
	end

.MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 13, 11
	dw .MenuData
	db 1 ; default option

.MenuData:
	db STATICMENU_CURSOR ; flags
	db 5 ; items
	db "WILD MEW@"
	db "WILD UNOWN@"
	db "SCREENS@"
	db "ENEMY HP@"
	db "CANCEL@"

PlayersHouseDebugHiddenPowerText:
	text "DEBUG: HIDDEN"
	line "POWER."
	done

PlayersHouseDebugHPLevelText:
	text "DEBUG: the lead's"
	line "HP level is @"
	text_decimal wScriptVar, 1, 2
	text "."
	done

PlayersHouseDebugTestPairText:
	text "DEBUG: MACHAMP"
	line "(FIRE) and"
	cont "ALAKAZAM (FIGHT-"
	cont "ING), with HIDDEN"
	cont "POWER."
	done

PlayersHouseDebugTestPairNoRoomText:
	text "DEBUG: make room"
	line "for two in your"
	cont "party first."
	done

PlayersHouseDebugNoUnownLettersText:
	text "DEBUG: no UNOWN"
	line "letters yet. Use"
	cont "the SUPER NERD's"
	cont "UNLOCK UNOWN."
	done

PlayersHouseDebugGiveUnownText:
	text "DEBUG: an UNOWN"
	line "joined the party."
	done

PlayersHouseDebugGiveUnownNoRoomText:
	text "DEBUG: make room"
	line "in your party"
	cont "first."
	done

PlayersHouseDebugHPPageText:
	text "DEBUG: the HIDDEN"
	line "POWER stats page"
	cont "is unlocked."
	done

PlayersHouseDebugHPStepText:
	text "DEBUG: rolled one"
	line "256-step cycle."
	done

PlayersHouseDebugGlyphShardText:
	text "DEBUG: got a"
	line "GLYPH SHARD."
	done

PlayersHouseDebugBattleWinText:
	text "DEBUG: test over."
	done

PlayersHouseDebugTrainerPicText:
	text "DEBUG: trainer pic"
	line "colors. Battle"
	cont "BROCK?"
	done

PlayersHouseDebugLabStolenText:
	text "DEBUG: <RIVAL>"
	line "stole his #MON."
	done

PlayersHouseDebugLabLearnersText:
	text "DEBUG: a party of"
	line "HM learners, and"
	cont "every HM."
	done

PlayersHouseDebugLabPickFirstText:
	text "DEBUG: pick a"
	line "starter first."
	done
endc

PlayersHouse2F_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  7,  0, PLAYERS_HOUSE_1F, 3

	def_coord_events

	def_bg_events
	bg_event  2,  1, BGEVENT_UP, PlayersHousePCScript
	bg_event  3,  1, BGEVENT_READ, PlayersHouseRadioScript
	bg_event  5,  1, BGEVENT_READ, PlayersHouseBookshelfScript
	bg_event  6,  0, BGEVENT_IFSET, PlayersHousePosterScript

	def_object_events
	object_event  4,  2, SPRITE_CONSOLE, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, PlayersHouseGameConsoleScript, EVENT_PLAYERS_HOUSE_2F_CONSOLE
	object_event  4,  4, SPRITE_DOLL_1, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, PlayersHouseDoll1Script, EVENT_PLAYERS_HOUSE_2F_DOLL_1
	object_event  5,  4, SPRITE_DOLL_2, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, PlayersHouseDoll2Script, EVENT_PLAYERS_HOUSE_2F_DOLL_2
	object_event  0,  1, SPRITE_BIG_DOLL, SPRITEMOVEDATA_BIGDOLL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, PlayersHouseBigDollScript, EVENT_PLAYERS_HOUSE_2F_BIG_DOLL
if DEF(_DEBUG)
	object_event  0,  4, SPRITE_SCIENTIST, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, PlayersHouseDebugStoryScript, -1
	object_event  1,  4, SPRITE_SUPER_NERD, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, PlayersHouseDebugBattlesScript, -1
	object_event  2,  4, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, PlayersHouseDebugToolsScript, -1
endc
