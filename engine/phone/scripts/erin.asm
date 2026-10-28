ErinPhoneCalleeScript:
	gettrainername STRING_BUFFER_3, PICNICKER, ERIN1
	checkflag ENGINE_ERIN_READY_FOR_REMATCH
	iftrue .WantsBattle
	farscall PhoneScript_AnswerPhone_Female
	checkflag ENGINE_ERIN_SATURDAY
	iftrue .NotSaturday
	readvar VAR_WEEKDAY
	ifequal SATURDAY, ErinSaturday

.NotSaturday:
	farsjump ErinWorkingHardScript

.WantsBattle:
	getlandmarkname STRING_BUFFER_5, LANDMARK_ROUTE_46
	farsjump ErinComeBattleScript

ErinPhoneCallerScript:
	gettrainername STRING_BUFFER_3, PICNICKER, ERIN1
	farscall PhoneScript_GreetPhone_Female
	checkflag ENGINE_ERIN_READY_FOR_REMATCH
	iftrue .GenericCall
	checkflag ENGINE_ERIN_SATURDAY
	iftrue .GenericCall
	farscall PhoneScript_Random3
	ifequal 0, ErinWantsBattle
	ifequal 1, ErinWantsBattle

.GenericCall:
	farsjump Phone_GenericCall_Female

ErinSaturday:
	setflag ENGINE_ERIN_SATURDAY

ErinWantsBattle:
	getlandmarkname STRING_BUFFER_5, LANDMARK_ROUTE_46
	setflag ENGINE_ERIN_READY_FOR_REMATCH
	farsjump PhoneScript_WantsToBattle_Female
