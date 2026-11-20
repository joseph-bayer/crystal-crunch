	object_const_def
	const RUINSOFALPHSHAMANCAVE_SHAMAN
	const RUINSOFALPHSHAMANCAVE_CAMPFIRE
	const RUINSOFALPHSHAMANCAVE_XATU

RuinsOfAlphShamanCave_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_OBJECTS, RuinsOfAlphShamanCaveShamanCallback

RuinsOfAlphShamanCaveShamanCallback:
; The cave stands empty until the player has met the Shaman at the Ruins of Alph Research Center.
; Her campfire and her Xatu share her object's event flag, so they come and go with her.
	checkevent EVENT_MET_HIDDEN_POWER_SHAMAN
	iftrue .Home
	disappear RUINSOFALPHSHAMANCAVE_SHAMAN
	endcallback

.Home:
	appear RUINSOFALPHSHAMANCAVE_SHAMAN
	endcallback

HiddenPowerShamanScript:
; The Hidden Power Shaman. The first talk brings out the player's power
; to see Hidden Power (the stats screen's 4th page), explains it, gives a GLYPH SHARD and offers to
; teach Hidden Power; every talk after that offers to teach it or explain it again. A shard a full
; bag couldn't take is handed over at the start of the next talk.
	faceplayer
	opentext
	checkevent EVENT_HIDDEN_POWER_PAGE_UNLOCKED
	iftrue .Returning
	writetext HiddenPowerShamanBringOutText
	promptbutton
	setevent EVENT_HIDDEN_POWER_PAGE_UNLOCKED
	writetext HiddenPowerShamanPageText
	playsound SFX_KEY_ITEM ; placeholder jingle
	waitsfx
	promptbutton
	writetext HiddenPowerShamanExplainText
	promptbutton
	verbosegiveitem GLYPH_SHARD
	iffalse .BagFull
	setevent EVENT_GOT_GLYPH_SHARD_FROM_SHAMAN
	writetext HiddenPowerShamanOfferText
	yesorno
	iftrue .Teach
	sjump .Declined

.Returning:
	checkevent EVENT_GOT_GLYPH_SHARD_FROM_SHAMAN
	iftrue .Welcome
	verbosegiveitem GLYPH_SHARD
	iffalse .BagFull
	setevent EVENT_GOT_GLYPH_SHARD_FROM_SHAMAN
.Welcome:
	writetext HiddenPowerShamanWelcomeBackText
	loadmenu .MenuHeader
	verticalmenu
	closewindow
	ifequal 1, .Teach
	ifequal 2, .Explain
.Declined:
	writetext HiddenPowerShamanFarewellText
	waitbutton
	closetext
	end

.Teach:
; The Goldenrod move tutor's flow: TM10-compatible mons only, and the standard messages turn away
; an egg, a mon that already knows it, or one that can't learn it.
	writetext HiddenPowerShamanWhichMonText
	setval MOVETUTOR_HIDDEN_POWER
	special MoveTutor
	ifequal FALSE, .Taught
	sjump .Declined

.Taught:
	writetext HiddenPowerShamanTaughtText
	waitbutton
	closetext
	end

.Explain:
	writetext HiddenPowerShamanExplainText
	waitbutton
	closetext
	end

.BagFull:
	writetext HiddenPowerShamanBagFullText
	waitbutton
	closetext
	end

.MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 10, 7
	dw .MenuData
	db 1 ; default option

.MenuData:
	db STATICMENU_CURSOR ; flags
	db 3 ; items
	db "TEACH@"
	db "EXPLAIN@"
	db "CANCEL@"

HiddenPowerShamanBringOutText:
	text "So you came after"
	line "all?"

	para "I see great"
	line "potential within"
	cont "you."

	para "It just needs"
	line "awakening."
	done

HiddenPowerShamanPageText:
	text "<PLAYER> can now"
	line "see a #MON's"
	cont "HIDDEN POWER!"
	done

HiddenPowerShamanExplainText:
	text "A #MON's HIDDEN"
	line "POWER type can't"
	cont "be changed."

	para "But traveling"
	line "with an UNOWN"
	cont "strengthens the"
	cont "HIDDEN POWER of"
	cont "your whole team,"
	cont "UNOWN included."

	para "A GLYPH SHARD"
	line "helps its holder"
	cont "grow, but only"
	cont "with an UNOWN"
	cont "by its side."

	para "And no #MON's"
	line "HIDDEN POWER can"
	cont "grow as strong"
	cont "as an UNOWN's."
	done

HiddenPowerShamanOfferText:
	text "Shall I teach one"
	line "of your #MON"
	cont "HIDDEN POWER?"
	done

HiddenPowerShamanWelcomeBackText:
	text "Welcome. What is"
	line "it you seek?"
	done

HiddenPowerShamanWhichMonText:
	text "Which #MON"
	line "shall learn it?"
	done

HiddenPowerShamanTaughtText:
	text "It is done. Let"
	line "its HIDDEN POWER"
	cont "guide it."
	done

HiddenPowerShamanFarewellText:
	text "May your HIDDEN"
	line "POWER guide you."
	done

HiddenPowerShamanBagFullText:
	text "Your bag is full."
	line "Make room, then"
	cont "come back."
	done

RuinsOfAlphShamanCaveCampfire:
	jumptext RuinsOfAlphShamanCaveCampfireText

RuinsOfAlphShamanCaveCampfireText:
	text "The fire is"
	line "crackling."

	para "It's almost like"
	line "you see an image"
	cont "between the"
	cont "flickers."
	done

RuinsOfAlphShamanCaveXatu:
	jumptext RuinsOfAlphShamanCaveXatuText

RuinsOfAlphShamanCaveXatuText:
	text "…"
	done

RuinsOfAlphShamanCave_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  2,  7, RUINS_OF_ALPH_OUTSIDE, 12
	warp_event  3,  7, RUINS_OF_ALPH_OUTSIDE, 12

	def_coord_events

	def_bg_events

	def_object_events
	object_event  3,  3, SPRITE_SHAMAN, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_SCRIPT, 0, HiddenPowerShamanScript, EVENT_RUINS_OF_ALPH_SHAMAN_HOUSE_SHAMAN
	; Polished Crystal's campfire: a bouncing 2-frame sprite, in the scene of blocks $40-$43
	object_event  3,  4, SPRITE_CAMPFIRE, SPRITEMOVEDATA_POKEMON, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, RuinsOfAlphShamanCaveCampfire, EVENT_RUINS_OF_ALPH_SHAMAN_HOUSE_SHAMAN
	; her Xatu (data/maps/overworld_mons.asm), standing in place with its two-frame idle
	object_event  1,  1, SPRITE_OW_MON_1, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, RuinsOfAlphShamanCaveXatu, EVENT_RUINS_OF_ALPH_SHAMAN_HOUSE_SHAMAN
