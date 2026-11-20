	object_const_def
	const LAKEOFRAGEHIDDENPOWERHOUSE_FISHER

LakeOfRageHiddenPowerHouse_MapScripts:
	def_scene_scripts

	def_callbacks

HiddenPowerGuy:
	faceplayer
	opentext
	checkevent EVENT_GOT_GLYPH_SHARD_FROM_HIDDEN_POWER_MAN
	iftrue .AlreadyGotItem
	writetext HiddenPowerGuyText1
	promptbutton
	verbosegiveitem GLYPH_SHARD
	iffalse .Done
	setevent EVENT_GOT_GLYPH_SHARD_FROM_HIDDEN_POWER_MAN
	writetext HiddenPowerGuyText2
	waitbutton
	closetext
	end
.AlreadyGotItem:
	writetext HiddenPowerGuyText3
	waitbutton
.Done:
	closetext
	end

HiddenPowerHouseBookshelf:
	jumpstd DifficultBookshelfScript

HiddenPowerGuyText1:
	text "…You have strayed"
	line "far…"

	para "Here I have medi-"
	line "tated. Inside me,"

	para "a new power has"
	line "been awakened."

	para "Let me share my"
	line "power with your"

	para "#MON."
	line "Take this, child."
	done

HiddenPowerGuyText2:
	text "Do you see it? It"
	line "is a GLYPH SHARD!"

	para "It draws out the"
	line "HIDDEN POWER of"
	cont "the #MON that"
	cont "holds it."

	para "But only when an"
	line "UNOWN travels"
	cont "with you."

	para "Remember this: a"
	line "SHAMAN in the"
	cont "RUINS OF ALPH can"
	cont "teach you more."
	done

HiddenPowerGuyText3:
	text "I am meditating…"
	done

LakeOfRageHiddenPowerHouse_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  2,  7, LAKE_OF_RAGE, 1
	warp_event  3,  7, LAKE_OF_RAGE, 1

	def_coord_events

	def_bg_events
	bg_event  0,  1, BGEVENT_READ, HiddenPowerHouseBookshelf
	bg_event  1,  1, BGEVENT_READ, HiddenPowerHouseBookshelf

	def_object_events
	object_event  2,  3, SPRITE_FISHER, SPRITEMOVEDATA_SPINRANDOM_SLOW, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, HiddenPowerGuy, -1
