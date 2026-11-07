DEF MOPED_PRICE EQU 100000

	object_const_def
	const CERULEANMOPEDSHOP_CLERK

CeruleanMopedShop_MapScripts:
	def_scene_scripts

	def_callbacks

CeruleanMopedShopClerkScript:
	faceplayer
	opentext
	checkitem MOPED
	iftrue .GotMoped
	special PlaceMoneyTopRight
	writetext CeruleanMopedShopClerkSellText
	yesorno
	iffalse .Refused
	checkmoney YOUR_MONEY, MOPED_PRICE
	ifequal HAVE_LESS, .NotEnoughMoney
	takemoney YOUR_MONEY, MOPED_PRICE
	special PlaceMoneyTopRight
	playsound SFX_TRANSACTION
	waitsfx
	writetext CeruleanMopedShopClerkThanksText
	promptbutton
	giveitem MOPED
	writetext BoughtAMopedText
	playsound SFX_KEY_ITEM
	waitsfx
	itemnotify
	writetext CeruleanMopedShopClerkRideText
	waitbutton
	closetext
	end

.NotEnoughMoney:
	writetext CeruleanMopedShopClerkNotEnoughMoneyText
	waitbutton
	closetext
	end

.GotMoped:
	writetext CeruleanMopedShopClerkBicycleText
	waitbutton
	closetext
	end

.Refused:
	writetext CeruleanMopedShopClerkRefusedText
	waitbutton
	closetext
	end

CeruleanMopedShopBicycle:
	jumptext CeruleanMopedShopBicycleText

CeruleanMopedShopClerkSellText:
	text "Hey kid! Want"
	line "to go fast?"

	para "A MOPED rides"
	line "faster than any"
	cont "BICYCLE."

	para "All for the low"
	line "cost of ¥100,000!"
	done

CeruleanMopedShopClerkThanksText:
	text "Thanks kid! Don't"
	line "drive recklessly!"
	done

BoughtAMopedText:
	text "<PLAYER> got a"
	line "MOPED."
	done

CeruleanMopedShopClerkRideText:
	text "Ride that puppy"
	line "anywhere you'd"
	cont "ride a BICYCLE!"
	done

CeruleanMopedShopClerkNotEnoughMoneyText:
	text "Sorry, you don't"
	line "have enough money."
	done

CeruleanMopedShopClerkRefusedText:
	text "Come back any"
	line "time!"
	done

CeruleanMopedShopClerkBicycleText:
	text "Why's there a"
	line "BICYCLE here?"

	para "That's mine. You"
	line "think I can afford"
	cont "a MOPED?"
	done

CeruleanMopedShopBicycleText:
	text "It's a beat-up,"
	line "old BICYCLE."
	done

CeruleanMopedShop_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  2,  7, CERULEAN_CITY, 8
	warp_event  3,  7, CERULEAN_CITY, 8

	def_coord_events

	def_bg_events
	bg_event  0,  2, BGEVENT_READ, CeruleanMopedShopBicycle
	bg_event  1,  2, BGEVENT_READ, CeruleanMopedShopBicycle

	def_object_events
	object_event  7,  2, SPRITE_PHARMACIST, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, CeruleanMopedShopClerkScript, -1
