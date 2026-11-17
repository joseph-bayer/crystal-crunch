	object_const_def
	const VIRIDIANFOREST_MAX_POTION
	const VIRIDIANFOREST_MAX_ETHER
	const VIRIDIANFOREST_REVIVE
; New Kanto trainers: begin
	const VIRIDIANFOREST_BUG_CATCHER_DANE
	const VIRIDIANFOREST_BUG_CATCHER_DION
	const VIRIDIANFOREST_BUG_CATCHER_STACEY
	const VIRIDIANFOREST_BUG_CATCHER_ELLIS
	const VIRIDIANFOREST_BUG_CATCHER_ABNER
; New Kanto trainers: end

ViridianForest_MapScripts:
	def_scene_scripts

	def_callbacks
; New Kanto trainers: begin

TrainerBugCatcherDane:
	trainer BUG_CATCHER, DANE, EVENT_BEAT_BUG_CATCHER_DANE, BugCatcherDaneSeenText, BugCatcherDaneBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext BugCatcherDaneAfterBattleText
	waitbutton
	closetext
	end

TrainerBugCatcherDion:
	trainer BUG_CATCHER, DION, EVENT_BEAT_BUG_CATCHER_DION, BugCatcherDionSeenText, BugCatcherDionBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext BugCatcherDionAfterBattleText
	waitbutton
	closetext
	end

TrainerBugCatcherStacey:
	trainer BUG_CATCHER, STACEY, EVENT_BEAT_BUG_CATCHER_STACEY, BugCatcherStaceySeenText, BugCatcherStaceyBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext BugCatcherStaceyAfterBattleText
	waitbutton
	closetext
	end

TrainerBugCatcherEllis:
	trainer BUG_CATCHER, ELLIS, EVENT_BEAT_BUG_CATCHER_ELLIS, BugCatcherEllisSeenText, BugCatcherEllisBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext BugCatcherEllisAfterBattleText
	waitbutton
	closetext
	end

TrainerBugCatcherAbner:
	trainer BUG_CATCHER, ABNER, EVENT_BEAT_BUG_CATCHER_ABNER, BugCatcherAbnerSeenText, BugCatcherAbnerBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext BugCatcherAbnerAfterBattleText
	waitbutton
	closetext
	end
; New Kanto trainers: end

ViridianForestTrainerTips1Script:
	jumptext ViridianForestTrainerTips1Text

ViridianForestTrainerTips1Text:
	text "TRAINER TIPS"
	para "If you want to"
	line "avoid battles,"
	cont "stay away from"
	cont "grassy areas!"
	done

ViridianForestUseAntidoteSignScript:
	jumptext ViridianForestUseAntidoteSignText

ViridianForestUseAntidoteSignText:
	text "For poison, use"
	line "ANTIDOTE! Get it"
	cont "at #MON MARTs!"
	done

ViridianForestTrainerTips2Script:
	jumptext ViridianForestTrainerTips2Text

ViridianForestTrainerTips2Text:
	text "TRAINER TIPS"
	para "Contact PROF.OAK"
	line "via PC to get"
	cont "your #DEX"
	cont "evaluated!"
	done

ViridianForestTrainerTips3Script:
	jumptext ViridianForestTrainerTips3Text

ViridianForestTrainerTips3Text:
	text "TRAINER TIPS"
	para "No stealing of"
	line "#MON from"
	cont "other trainers!"
	cont "Catch only wild"
	cont "#MON!"
	done

ViridianForestTrainerTips4Script:
	jumptext ViridianForestTrainerTips4Text

ViridianForestTrainerTips4Text:
	text "TRAINER TIPS"
	para "Weaken #MON"
	line "before attempting"
	cont "capture!"
	para "When healthy,"
	line "they may escape!"
	done

ViridianForestLeavingSignScript:
	jumptext ViridianForestLeavingSignText

ViridianForestLeavingSignText:
	text "LEAVING"
	line "VIRIDIAN FOREST"
	cont "PEWTER CITY AHEAD"
	done

; Route 2's items, moved here when the forest took its west side. They keep Route 2's event flags,
; so an item already picked up on Route 2 isn't found again.
ViridianForestHiddenFullRestore:
	hiddenitem FULL_RESTORE, EVENT_ROUTE_2_HIDDEN_FULL_RESTORE

ViridianForestHiddenFullHeal:
	hiddenitem FULL_HEAL, EVENT_ROUTE_2_HIDDEN_FULL_HEAL

ViridianForestMaxPotion:
	itemball MAX_POTION

ViridianForestMaxEther:
	itemball MAX_ETHER

ViridianForestRevive:
	itemball REVIVE

; New Kanto trainers: begin
BugCatcherDaneSeenText:
	text "Welcome to"
	line "Viridian Forest."
	cont "Enjoy my Bug-type"
	cont "#MON!"
	done

BugCatcherDaneBeatenText:
	text "That's wonderful…"
	done

BugCatcherDaneAfterBattleText:
	text "Pretty impressive!"
	line "I bet you can go"
	cont "anywhere!"
	done

BugCatcherDionSeenText:
	text "Shh! Be quiet! The"
	line "bug #MON will"
	cont "run away!"
	done

BugCatcherDionBeatenText:
	text "Phew…"
	done

BugCatcherDionAfterBattleText:
	text "Knowing how to"
	line "distinguish"
	cont "Bug-type #MON"
	cont "sounds is key!"
	done

BugCatcherStaceySeenText:
	text "Wow, that's a HUGE"
	line "#MON! … …What"
	cont "kind of TRAINER?!"
	done

BugCatcherStaceyBeatenText:
	text "I couldn't catch"
	line "it!"
	done

BugCatcherStaceyAfterBattleText:
	text "Has anyone ever"
	line "told you that from"
	cont "behind you look"
	cont "like a VENONAT?"
	done

BugCatcherEllisSeenText:
	text "There's nothing"
	line "more beautiful in"
	cont "this world"

	para "than a Bug-type"
	line "#MON."
	done

BugCatcherEllisBeatenText:
	text "I lost"
	line "beautifully!"
	done

BugCatcherEllisAfterBattleText:
	text "If this is it, I"
	line "don't mind losing!"
	done

BugCatcherAbnerSeenText:
	text "Many prefer solid"
	line "bug #MON over"
	cont "squishy bug"

	para "#MON."
	done

BugCatcherAbnerBeatenText:
	text "Thanks for your"
	line "hard work, my"
	cont "lovely #MON…"
	done

BugCatcherAbnerAfterBattleText:
	text "Doesn't matter what"
	line "kind of #MON--"

	para "as long as you"
	line "like them, they"
	cont "all look cute."
	done

; New Kanto trainers: end
ViridianForest_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  3,  2, VIRIDIAN_FOREST_NORTH_GATE, 3
	warp_event  4,  2, VIRIDIAN_FOREST_NORTH_GATE, 4
	warp_event 17, 49, VIRIDIAN_FOREST_SOUTH_GATE, 1
	warp_event 18, 49, VIRIDIAN_FOREST_SOUTH_GATE, 1
	warp_event 19, 49, VIRIDIAN_FOREST_SOUTH_GATE, 2
	warp_event 20, 49, VIRIDIAN_FOREST_SOUTH_GATE, 2

	def_coord_events

	def_bg_events
	bg_event 26, 42, BGEVENT_READ, ViridianForestTrainerTips1Script
	bg_event 18, 34, BGEVENT_READ, ViridianForestUseAntidoteSignScript
	bg_event 28, 19, BGEVENT_READ, ViridianForestTrainerTips2Script
	bg_event  6, 26, BGEVENT_READ, ViridianForestTrainerTips3Script
	bg_event 20, 47, BGEVENT_READ, ViridianForestTrainerTips4Script
	bg_event  4,  3, BGEVENT_READ, ViridianForestLeavingSignScript
	bg_event  3, 20, BGEVENT_ITEM, ViridianForestHiddenFullRestore
	bg_event 18, 44, BGEVENT_ITEM, ViridianForestHiddenFullHeal

	def_object_events
	object_event 27, 13, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, ViridianForestMaxPotion, EVENT_ROUTE_2_MAX_POTION
	object_event 14, 31, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, ViridianForestMaxEther, EVENT_ROUTE_2_HIDDEN_MAX_ETHER
	object_event  3, 33, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, ViridianForestRevive, EVENT_ROUTE_2_HIDDEN_REVIVE
; New Kanto trainers: begin
	object_event 31, 42, SPRITE_BUG_CATCHER, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_TRAINER, 3, TrainerBugCatcherDane, -1
	object_event 33, 32, SPRITE_BUG_CATCHER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_TRAINER, 3, TrainerBugCatcherDion, -1
	object_event 31, 20, SPRITE_BUG_CATCHER, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_TRAINER, 3, TrainerBugCatcherStacey, -1
	object_event 22,  4, SPRITE_BUG_CATCHER, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_TRAINER, 1, TrainerBugCatcherEllis, -1
	object_event  5, 24, SPRITE_BUG_CATCHER, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_TRAINER, 4, TrainerBugCatcherAbner, -1
; New Kanto trainers: end
; Wandering Pokemon, rolled by RollOverworldMons when the map is entered (see Route2.asm). The
; forest has no static mon and no water, so these are its four grass slots, in order.
	object_event 20, 10, SPRITE_OW_MON_1, SPRITEMOVEDATA_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
	object_event  5, 43, SPRITE_OW_MON_2, SPRITEMOVEDATA_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
	object_event 28, 26, SPRITE_OW_MON_3, SPRITEMOVEDATA_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
	object_event 23, 42, SPRITE_OW_MON_4, SPRITEMOVEDATA_WANDER_NOCLIP, 2, 2, -1, -1, 0, OBJECTTYPE_WILDMON, 0, ObjectEvent, -1
