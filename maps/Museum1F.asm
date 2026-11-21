	object_const_def
	const MUSEUM1F_SCIENTIST1
	const MUSEUM1F_GAMBLER
	const MUSEUM1F_OLD_AMBER_GUY
	const MUSEUM1F_SCIENTIST3
	const MUSEUM1F_OLD_AMBER

Museum1F_MapScripts:
	def_scene_scripts

	def_callbacks

	assert MUSEUM_TICKET_PRICE == 60, "the ticket texts say ¥60"

Museum1FTicketScript:
; Walking in the front way stops you at the desk until you have a ticket
	checkevent EVENT_BOUGHT_MUSEUM_TICKET
	iftrue .Done
	turnobject PLAYER, RIGHT
	opentext
	sjump Museum1FSellTicketScript

.Done:
	end

Museum1FScientist1Script:
	faceplayer
	opentext
	readvar VAR_YCOORD
	ifequal 6, .Row6
	ifnotequal 5, .Elsewhere
	readvar VAR_XCOORD
	ifequal 12, .BehindCounter
	sjump .Elsewhere

.Row6:
	readvar VAR_XCOORD
	ifequal 13, .BehindCounter
	checkevent EVENT_BOUGHT_MUSEUM_TICKET
	iffalse Museum1FSellTicketScript
	sjump .TakeYourTime

.Elsewhere:
	checkevent EVENT_BOUGHT_MUSEUM_TICKET
	iftrue .TakeYourTime
	writetext Museum1FScientist1GoToOtherSideText
	waitbutton
	closetext
	end

.TakeYourTime:
	writetext Museum1FScientist1TakePlentyOfTimeText
	waitbutton
	closetext
	end

.BehindCounter:
	writetext Museum1FScientist1DoYouKnowWhatAmberIsText
	yesorno
	iffalse .ExplainAmber
	writetext Museum1FScientist1TheresALabSomewhereText
	waitbutton
	closetext
	end

.ExplainAmber:
	writetext Museum1FScientist1AmberIsFossilizedTreeSapText
	waitbutton
	closetext
	end

Museum1FSellTicketScript:
; The text box is open
	special PlaceMoneyTopRight
	writetext Museum1FScientist1WouldYouLikeToComeInText
	yesorno
	iffalse .Refused
	checkmoney YOUR_MONEY, MUSEUM_TICKET_PRICE
	ifequal HAVE_LESS, .NotEnoughMoney
	takemoney YOUR_MONEY, MUSEUM_TICKET_PRICE
	special PlaceMoneyTopRight
	playsound SFX_TRANSACTION
	waitsfx
	setevent EVENT_BOUGHT_MUSEUM_TICKET
	writetext Museum1FScientist1ThankYouText
	waitbutton
	closetext
	end

.NotEnoughMoney:
	writetext Museum1FScientist1DontHaveEnoughMoneyText
	promptbutton
.Refused:
	writetext Museum1FScientist1ComeAgainText
	waitbutton
	closetext
	applymovement PLAYER, Museum1FStepBackMovement
	end

Museum1FStepBackMovement:
	step DOWN
	step_end

Museum1FScientist1WouldYouLikeToComeInText:
	text "It's ¥60 for a"
	line "child's ticket."

	para "Would you like to"
	line "come in?"
	done

Museum1FScientist1ThankYouText:
	text "Right, ¥60!"
	line "Thank you!"
	done

Museum1FScientist1DontHaveEnoughMoneyText:
	text "You don't have"
	line "enough money."
	done

Museum1FScientist1ComeAgainText:
	text "Come again!"
	done

Museum1FScientist1DoYouKnowWhatAmberIsText:
	text "You can't sneak"
	line "in the back way!"

	para "Oh, whatever!"
	line "Do you know what"
	cont "AMBER is?"
	done

Museum1FScientist1TheresALabSomewhereText:
	text "There was a lab"
	line "somewhere trying"
	cont "to resurrect"
	cont "ancient #MON"
	cont "from AMBER."

	para "But it was"
	line "decimated in a"
	cont "volcanic eruption!"
	done

Museum1FScientist1AmberIsFossilizedTreeSapText:
	text "AMBER is fossil-"
	line "ized tree sap."
	done

Museum1FScientist1GoToOtherSideText:
	text "Please go to the"
	line "other side!"
	done

Museum1FScientist1TakePlentyOfTimeText:
	text "Take plenty of"
	line "time to look!"
	done

Museum1FGamblerScript:
	jumptextfaceplayer Museum1FGamblerText

Museum1FGamblerText:
	text "That is one"
	line "magnificent"
	cont "fossil!"
	done

Museum1FOldAmberGuyScript:
	faceplayer
	opentext
	checkevent EVENT_GOT_OLDER_AMBER
	iftrue .GotOlderAmber
	writetext Museum1FOldAmberGuyGiveText
	promptbutton
	verbosegiveitem OLDER_AMBER
	iffalse .Done
	setevent EVENT_GOT_OLDER_AMBER
	disappear MUSEUM1F_OLD_AMBER ; the one on show was the Older Amber
	writetext Museum1FOldAmberGuyShowMeText
	waitbutton
.Done:
	closetext
	end

.GotOlderAmber:
	checkevent EVENT_SHOWED_RB_AERODACTYL
	iftrue .Tutor
	special CheckPartyForRBAerodactyl
	iftrue .ShowedAerodactyl
	writetext Museum1FOldAmberGuyWaitingText
	waitbutton
	closetext
	end

.ShowedAerodactyl:
	setevent EVENT_SHOWED_RB_AERODACTYL
	writetext Museum1FOldAmberGuyThatAerodactylText
	promptbutton
.Tutor:
	writetext Museum1FOldAmberGuyTutorText
	yesorno
	iffalse .Refused
	special Gen1Tutor
	ifequal FALSE, .Taught
.Refused:
	writetext Museum1FOldAmberGuyRefusedText
	waitbutton
	closetext
	end

.Taught:
	takemoney YOUR_MONEY, GEN1_TUTOR_PRICE
	waitsfx
	playsound SFX_TRANSACTION
	writetext Museum1FOldAmberGuyTaughtText
	waitbutton
	closetext
	end

Museum1FOldAmberGuyGiveText:
	text "Ssh! This chunk of"
	line "AMBER is older"
	cont "than any other!"

	para "I think it holds"
	line "#MON DNA!"

	para "My colleagues just"
	line "ignore me, so take"
	cont "it to a fossil"
	cont "expert for me!"
	done

Museum1FOldAmberGuyShowMeText:
	text "The last kid I"
	line "gave one of these"
	cont "to just ran off"
	cont "with it!"
	
	para "Please, make sure"
	line "to show me if a"
	cont "#MON resurrects"
	cont "from it!"
	done

Museum1FOldAmberGuyWaitingText:
	text "Has a #MON been"
	line "resurrected from"
	cont "the OLDER AMBER"
	cont "yet?"

	para "Show it to me!"
	done

Museum1FOldAmberGuyThatAerodactylText:
	text "That AERODACTYL!"
	line "It's straight out"
	cont "of an older time!"

	para "It looks just like"
	line "the #MON in my"
	cont "picture books!"

	para "Thank you! In"
	line "return, I'll teach"
	cont "you something."
	done

Museum1FOldAmberGuyTutorText:
	text "I can teach"
	line "lost moves to"
	cont "monochrome #MON"
	cont "from days past."

	para "Each move costs"
	line "¥10000. Want me to"
	cont "teach one?"
	done

Museum1FOldAmberGuyRefusedText:
	text "Come back if you"
	line "change your mind!"
	done

Museum1FOldAmberGuyTaughtText:
	text "I guess old"
	line "#MON do learn"
	cont "new tricks!"
	done

Museum1FScientist3Script:
	jumptextfaceplayer Museum1FScientist3Text

Museum1FScientist3Text:
	text "We are proud of 2"
	line "fossils of very"
	cont "rare, prehistoric"
	cont "#MON!"
	done

Museum1FOldAmberScript:
	jumptextfaceplayer Museum1FOldAmberText

Museum1FOldAmberText:
	text "The OLDER AMBER is"
	line "clear and gold!"

	para "It kind of looks"
	line "tasty…"
	done

Museum1FAerodactylFossil:
	opentext
	writetext Museum1FAerodactylFossilText
	waitbutton
	setval MUSEUM_FOSSIL_AERODACTYL
	special FossilPic
	waitbutton
	closepokepic
	closetext
	end

Museum1FAerodactylFossilText:
	text "AERODACTYL Fossil"

	para "An ancient #MON"
	line "with serrated"
	cont "fangs."
	done

Museum1FKabutopsFossil:
	opentext
	writetext Museum1FKabutopsFossilText
	waitbutton
	setval MUSEUM_FOSSIL_KABUTOPS
	special FossilPic
	waitbutton
	closepokepic
	closetext
	end

Museum1FKabutopsFossilText:
	text "KABUTOPS Fossil"

	para "An ancient #MON"
	line "that feasted on"
	cont "blood."
	done

Museum1F_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event 10,  9, PEWTER_CITY, 6
	warp_event 11,  9, PEWTER_CITY, 6
	warp_event 16,  9, PEWTER_CITY, 7
	warp_event 17,  9, PEWTER_CITY, 7
	warp_event  7,  9, MUSEUM_2F, 1

	def_coord_events
	coord_event  9,  6, SCENE_ALWAYS, Museum1FTicketScript
	coord_event 10,  6, SCENE_ALWAYS, Museum1FTicketScript

	def_bg_events
	bg_event  2,  3, BGEVENT_UP, Museum1FAerodactylFossil
	bg_event  2,  7, BGEVENT_UP, Museum1FKabutopsFossil

	def_object_events
	object_event 12,  6, SPRITE_SCIENTIST, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_GRAY, OBJECTTYPE_SCRIPT, 0, Museum1FScientist1Script, -1
	object_event  1,  8, SPRITE_POKEFAN_M, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, Museum1FGamblerScript, -1
	object_event 15,  2, SPRITE_OLD_AMBER_GUY, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_GRAY, OBJECTTYPE_SCRIPT, 0, Museum1FOldAmberGuyScript, -1
	object_event 17,  5, SPRITE_SCIENTIST, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_GRAY, OBJECTTYPE_SCRIPT, 0, Museum1FScientist3Script, -1
	object_event 16,  2, SPRITE_OLD_AMBER, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, PAL_NPC_COPY_BG_YELLOW, OBJECTTYPE_SCRIPT, 0, Museum1FOldAmberScript, EVENT_GOT_OLDER_AMBER
