BrentPhoneCalleeScript:
	gettrainername STRING_BUFFER_3, POKEMANIAC, BRENT1
	checkflag ENGINE_BRENT_READY_FOR_REMATCH
	iftrue .WantsBattle
	farscall PhoneScript_AnswerPhone_Male
	checkflag ENGINE_BRENT_MONDAY
	iftrue .NotMonday
	readvar VAR_WEEKDAY
	ifequal MONDAY, BrentMonday

.NotMonday:
	farsjump BrentHangUpScript

.WantsBattle:
	getlandmarkname STRING_BUFFER_5, LANDMARK_ROUTE_43
	farsjump BrentReminderScript

BrentPhoneCallerScript:
	gettrainername STRING_BUFFER_3, POKEMANIAC, BRENT1
	farscall PhoneScript_GreetPhone_Male
	checkflag ENGINE_BRENT_READY_FOR_REMATCH
	iftrue .Leftover
	checkflag ENGINE_BRENT_MONDAY
	iftrue .Leftover
	farscall PhoneScript_Random2
	ifequal 0, BrentWantsBattle

.Leftover:
	farscall PhoneScript_Random2
	ifequal 0, BrentBillTrivia
	farsjump Phone_GenericCall_Male

BrentMonday:
	setflag ENGINE_BRENT_MONDAY

BrentWantsBattle:
	getlandmarkname STRING_BUFFER_5, LANDMARK_ROUTE_43
	setflag ENGINE_BRENT_READY_FOR_REMATCH
	farsjump PhoneScript_WantsToBattle_Male

BrentBillTrivia:
	farsjump BrentBillTriviaScript
