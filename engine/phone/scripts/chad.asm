ChadPhoneCalleeScript:
	gettrainername STRING_BUFFER_3, SCHOOLBOY, CHAD1
	checkflag ENGINE_CHAD_READY_FOR_REMATCH
	iftrue .WantsBattle
	farscall PhoneScript_AnswerPhone_Male
	checkflag ENGINE_CHAD_FRIDAY
	iftrue .NotFriday
	readvar VAR_WEEKDAY
	ifequal FRIDAY, ChadFriday

.NotFriday:
	farsjump ChadHangUpScript

.WantsBattle:
	getlandmarkname STRING_BUFFER_5, LANDMARK_ROUTE_38
	farsjump ChadReminderScript

ChadPhoneCallerScript:
	gettrainername STRING_BUFFER_3, SCHOOLBOY, CHAD1
	farscall PhoneScript_GreetPhone_Male
	checkflag ENGINE_CHAD_READY_FOR_REMATCH
	iftrue .Leftover
	checkflag ENGINE_CHAD_FRIDAY
	iftrue .Leftover
	farscall PhoneScript_Random2
	ifequal 0, ChadWantsBattle

.Leftover:
	farscall PhoneScript_Random2
	ifequal 0, ChadOakGossip
	farscall PhoneScript_Random3
	ifequal 0, ChadFoundRare
	farsjump Phone_GenericCall_Male

ChadFriday:
	setflag ENGINE_CHAD_FRIDAY

ChadWantsBattle:
	getlandmarkname STRING_BUFFER_5, LANDMARK_ROUTE_38
	setflag ENGINE_CHAD_READY_FOR_REMATCH
	farsjump PhoneScript_WantsToBattle_Male

ChadFoundRare:
	farsjump Phone_CheckIfUnseenRare_Male

ChadOakGossip:
	farsjump ChadOakGossipScript
