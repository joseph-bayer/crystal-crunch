AnthonyPhoneCalleeScript:
	gettrainername STRING_BUFFER_3, HIKER, ANTHONY2
	checkflag ENGINE_ANTHONY_READY_FOR_REMATCH
	iftrue .WantsBattle
	farscall PhoneScript_AnswerPhone_Male
	checkflag ENGINE_ANTHONY_FRIDAY
	iftrue .NotFriday
	readvar VAR_WEEKDAY
	ifequal FRIDAY, AnthonyFriday

.NotFriday:
	checkswarm SWARM_DUNSPARCE
	iftrue .AlreadySwarming
	farsjump AnthonyHangUpScript

.WantsBattle:
	getlandmarkname STRING_BUFFER_5, LANDMARK_ROUTE_33
	farsjump AnthonyReminderScript

.AlreadySwarming:
	getlandmarkname STRING_BUFFER_5, LANDMARK_ROUTE_33
	farsjump AnthonyHurryScript

AnthonyPhoneCallerScript:
	gettrainername STRING_BUFFER_3, HIKER, ANTHONY2
	farscall PhoneScript_GreetPhone_Male
	checkflag ENGINE_ANTHONY_READY_FOR_REMATCH
	iftrue .TriesSwarm
	checkflag ENGINE_ANTHONY_FRIDAY
	iftrue .TriesSwarm
	farscall PhoneScript_Random2
	ifequal 0, AnthonyWantsBattle

.TriesSwarm:
	farscall PhoneScript_Random5
	ifequal 0, AnthonyTriesDunsparceSwarm
	farsjump Phone_GenericCall_Male

AnthonyFriday:
	setflag ENGINE_ANTHONY_FRIDAY

AnthonyWantsBattle:
	getlandmarkname STRING_BUFFER_5, LANDMARK_ROUTE_33
	setflag ENGINE_ANTHONY_READY_FOR_REMATCH
	farsjump PhoneScript_WantsToBattle_Male

AnthonyTriesDunsparceSwarm:
	checkswarm SWARM_DUNSPARCE
	iftrue .Generic
	getmonname STRING_BUFFER_4, DUNSPARCE
	swarm SWARM_DUNSPARCE
	getlandmarkname STRING_BUFFER_5, LANDMARK_DARK_CAVE
	farsjump AnthonySwarmScript

.Generic:
	farsjump Phone_GenericCall_Male
