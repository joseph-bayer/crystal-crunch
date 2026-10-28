AlanPhoneCalleeScript:
	gettrainername STRING_BUFFER_3, SCHOOLBOY, ALAN1
	checkflag ENGINE_ALAN_READY_FOR_REMATCH
	iftrue .WantsBattle
	farscall PhoneScript_AnswerPhone_Male
	checkflag ENGINE_ALAN_WEDNESDAY
	iftrue .NotWednesday
	readvar VAR_WEEKDAY
	ifequal WEDNESDAY, AlanWednesday
	checkflag ENGINE_ALAN_HAS_FIRE_STONE
	iftrue .FireStone

.NotWednesday:
	farsjump AlanHangUpScript

.WantsBattle:
	getlandmarkname STRING_BUFFER_5, LANDMARK_ROUTE_36
	farsjump AlanReminderScript

.FireStone:
	getlandmarkname STRING_BUFFER_5, LANDMARK_ROUTE_36
	farsjump AlanComePickUpScript

AlanPhoneCallerScript:
	gettrainername STRING_BUFFER_3, SCHOOLBOY, ALAN1
	farscall PhoneScript_GreetPhone_Male
	checkflag ENGINE_ALAN_HAS_FIRE_STONE
	iftrue .NoItem
	checkevent EVENT_ALAN_GAVE_FIRE_STONE
	iftrue .GaveItem
	farscall PhoneScript_Random2
	ifequal 0, AlanHasFireStone
	sjump .NoItem

.GaveItem:
	farscall PhoneScript_Random4
	ifequal 0, AlanHasFireStone

.NoItem:
	checkflag ENGINE_ALAN_READY_FOR_REMATCH
	iftrue .Leftover
	checkflag ENGINE_ALAN_WEDNESDAY
	iftrue .Leftover
	farscall PhoneScript_Random2
	ifequal 0, AlanWantsBattle

.Leftover:
	farsjump Phone_GenericCall_Male

AlanWednesday:
	setflag ENGINE_ALAN_WEDNESDAY

AlanWantsBattle:
	getlandmarkname STRING_BUFFER_5, LANDMARK_ROUTE_36
	setflag ENGINE_ALAN_READY_FOR_REMATCH
	farsjump PhoneScript_WantsToBattle_Male

AlanHasFireStone:
	setflag ENGINE_ALAN_HAS_FIRE_STONE
	getlandmarkname STRING_BUFFER_5, LANDMARK_ROUTE_36
	farsjump PhoneScript_FoundItem_Male
