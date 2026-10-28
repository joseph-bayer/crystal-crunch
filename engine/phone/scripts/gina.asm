GinaPhoneCalleeScript:
	gettrainername STRING_BUFFER_3, PICNICKER, GINA1
	checkflag ENGINE_GINA_READY_FOR_REMATCH
	iftrue .WantsBattle
	farscall PhoneScript_AnswerPhone_Female
	checkflag ENGINE_GINA_SUNDAY
	iftrue .NotSunday
	readvar VAR_WEEKDAY
	ifequal SUNDAY, GinaSunday
	checkflag ENGINE_GINA_HAS_LEAF_STONE
	iftrue .HasLeafStone

.NotSunday:
	checkflag ENGINE_ROCKETS_IN_RADIO_TOWER
	iftrue .Rockets
	farsjump GinaHangUpScript

.Rockets:
	farsjump GinaRocketRumorScript

.WantsBattle:
	getlandmarkname STRING_BUFFER_5, LANDMARK_ROUTE_34
	farsjump GinaReminderScript

.HasLeafStone:
	getlandmarkname STRING_BUFFER_5, LANDMARK_ROUTE_34
	farsjump GinaComePickUpScript

GinaPhoneCallerScript:
	gettrainername STRING_BUFFER_3, PICNICKER, GINA1
	farscall PhoneScript_GreetPhone_Female
	checkflag ENGINE_ROCKETS_IN_RADIO_TOWER
	iftrue GinaRockets
	checkflag ENGINE_GINA_HAS_LEAF_STONE
	iftrue .NoItem
	checkevent EVENT_GINA_GAVE_LEAF_STONE
	iftrue .GaveItem
	farscall PhoneScript_Random2
	ifequal 0, GinaHasLeafStone
	sjump .NoItem

.GaveItem:
	farscall PhoneScript_Random4
	ifequal 0, GinaHasLeafStone

.NoItem:
	checkflag ENGINE_GINA_READY_FOR_REMATCH
	iftrue .Leftover
	checkflag ENGINE_GINA_SUNDAY
	iftrue .Leftover
	farscall PhoneScript_Random2
	ifequal 0, GinaWantsBattle

.Leftover:
	farsjump Phone_GenericCall_Female

GinaSunday:
	setflag ENGINE_GINA_SUNDAY

GinaWantsBattle:
	getlandmarkname STRING_BUFFER_5, LANDMARK_ROUTE_34
	setflag ENGINE_GINA_READY_FOR_REMATCH
	farsjump PhoneScript_WantsToBattle_Female

GinaRockets:
	farsjump GinaRocketRumorScript

GinaHasLeafStone:
	setflag ENGINE_GINA_HAS_LEAF_STONE
	getlandmarkname STRING_BUFFER_5, LANDMARK_ROUTE_34
	farsjump PhoneScript_FoundItem_Female
