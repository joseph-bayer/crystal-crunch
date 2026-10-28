TullyPhoneCalleeScript:
	gettrainername STRING_BUFFER_3, FISHER, TULLY1
	checkflag ENGINE_TULLY_READY_FOR_REMATCH
	iftrue .WantsBattle
	farscall PhoneScript_AnswerPhone_Male
	checkflag ENGINE_TULLY_SUNDAY
	iftrue .NotSunday
	readvar VAR_WEEKDAY
	ifequal SUNDAY, TullySunday
	checkflag ENGINE_TULLY_HAS_WATER_STONE
	iftrue .WaterStone

.NotSunday:
	farsjump TullyNoItemScript

.WantsBattle:
	getlandmarkname STRING_BUFFER_5, LANDMARK_ROUTE_42
	farsjump TullyForwardScript

.WaterStone:
	getlandmarkname STRING_BUFFER_5, LANDMARK_ROUTE_42
	farsjump TullyHurryScript

TullyPhoneCallerScript:
	gettrainername STRING_BUFFER_3, FISHER, TULLY1
	farscall PhoneScript_GreetPhone_Male
	checkflag ENGINE_TULLY_HAS_WATER_STONE
	iftrue .NoItem
	checkevent EVENT_TULLY_GAVE_WATER_STONE
	iftrue .GaveItem
	farscall PhoneScript_Random2
	ifequal 0, TullyFoundWaterStone
	sjump .NoItem

.GaveItem:
	farscall PhoneScript_Random4
	ifequal 0, TullyFoundWaterStone

.NoItem:
	checkflag ENGINE_TULLY_READY_FOR_REMATCH
	iftrue .Leftover
	checkflag ENGINE_TULLY_SUNDAY
	iftrue .Leftover
	farscall PhoneScript_Random2
	ifequal 0, TullyWantsBattle

.Leftover:
	farsjump Phone_GenericCall_Male

TullySunday:
	setflag ENGINE_TULLY_SUNDAY

TullyWantsBattle:
	getlandmarkname STRING_BUFFER_5, LANDMARK_ROUTE_42
	setflag ENGINE_TULLY_READY_FOR_REMATCH
	farsjump PhoneScript_WantsToBattle_Male

TullyFoundWaterStone:
	setflag ENGINE_TULLY_HAS_WATER_STONE
	getlandmarkname STRING_BUFFER_5, LANDMARK_ROUTE_42
	farsjump PhoneScript_FoundItem_Male
