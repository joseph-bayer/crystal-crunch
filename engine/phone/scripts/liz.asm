LizPhoneCalleeScript:
	gettrainername STRING_BUFFER_3, PICNICKER, LIZ1
	checkflag ENGINE_LIZ_READY_FOR_REMATCH
	iftrue .WantsBattle
	farscall PhoneScript_AnswerPhone_Female
	checkflag ENGINE_LIZ_THURSDAY
	iftrue .NotThursday
	readvar VAR_WEEKDAY
	ifequal THURSDAY, LizThursday

.NotThursday:
	special RandomPhoneMon
	farsjump LizHangUpScript

.WantsBattle:
	getlandmarkname STRING_BUFFER_5, LANDMARK_ROUTE_32
	farsjump LizReminderScript

LizPhoneCallerScript:
	gettrainername STRING_BUFFER_3, PICNICKER, LIZ1
	checkflag ENGINE_LIZ_READY_FOR_REMATCH
	iftrue .Leftover
	checkflag ENGINE_LIZ_THURSDAY
	iftrue .Leftover
	farscall PhoneScript_Random2
	ifequal 0, .WantsBattle

.Leftover:
	farscall PhoneScript_Random4
	ifequal 0, LizWrongNumber
	farscall PhoneScript_GreetPhone_Female
	farscall PhoneScript_Random2
	ifequal 0, LizGossip
	farsjump Phone_GenericCall_Female

.WantsBattle:
	farscall PhoneScript_GreetPhone_Female
	sjump LizWantsBattle

LizThursday:
	setflag ENGINE_LIZ_THURSDAY

LizWantsBattle:
	getlandmarkname STRING_BUFFER_5, LANDMARK_ROUTE_32
	setflag ENGINE_LIZ_READY_FOR_REMATCH
	farsjump PhoneScript_WantsToBattle_Female

LizWrongNumber:
	farsjump LizWrongNumberScript

LizGossip:
	random 9
	ifequal 0, .CoolTrainerM
	ifequal 1, .Beauty
	ifequal 2, .Grunt
	ifequal 3, .Teacher
	ifequal 4, .SwimmerF
	ifequal 5, .KimonoGirl
	ifequal 6, .Skier
	ifequal 7, .Medium
	ifequal 8, .PokefanM

.CoolTrainerM:
	gettrainerclassname STRING_BUFFER_4, COOLTRAINERM
	sjump LizGossipScript

.Beauty:
	gettrainerclassname STRING_BUFFER_4, BEAUTY
	sjump LizGossipScript

.Grunt:
	gettrainerclassname STRING_BUFFER_4, GRUNTM
	sjump LizGossipScript

.Teacher:
	gettrainerclassname STRING_BUFFER_4, TEACHER
	sjump LizGossipScript

.SwimmerF:
	gettrainerclassname STRING_BUFFER_4, SWIMMERF
	sjump LizGossipScript

.KimonoGirl:
	gettrainerclassname STRING_BUFFER_4, KIMONO_GIRL
	sjump LizGossipScript

.Skier:
	gettrainerclassname STRING_BUFFER_4, SKIER
	sjump LizGossipScript

.Medium:
	gettrainerclassname STRING_BUFFER_4, MEDIUM
	sjump LizGossipScript

.PokefanM:
	gettrainerclassname STRING_BUFFER_4, POKEFANM
; fallthrough
LizGossipScript:
	farsjump LizGossipRandomScript
