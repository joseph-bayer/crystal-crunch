JosePhoneCalleeScript:
	gettrainername STRING_BUFFER_3, BIRD_KEEPER, JOSE2
	checkflag ENGINE_JOSE_READY_FOR_REMATCH
	iftrue .WantsBattle
	farscall PhoneScript_AnswerPhone_Male
	checkflag ENGINE_JOSE_SATURDAY
	iftrue .NotSaturday
	readvar VAR_WEEKDAY
	ifequal SATURDAY, JoseSaturday
	checkflag ENGINE_JOSE_HAS_STAR_PIECE
	iftrue .HasItem

.NotSaturday:
	farsjump JoseHangUpScript

.WantsBattle:
	getlandmarkname STRING_BUFFER_5, LANDMARK_ROUTE_27
	farsjump JoseReminderScript

.HasItem:
	getlandmarkname STRING_BUFFER_5, LANDMARK_ROUTE_27
	farsjump JoseReminderScript

JosePhoneCallerScript:
	gettrainername STRING_BUFFER_3, BIRD_KEEPER, JOSE2
	farscall PhoneScript_GreetPhone_Male
	checkflag ENGINE_JOSE_HAS_STAR_PIECE
	iftrue .NoItem
	farscall PhoneScript_Random3
	ifequal 0, JoseHasStarPiece

.NoItem:
	checkflag ENGINE_JOSE_READY_FOR_REMATCH
	iftrue .Leftover
	checkflag ENGINE_JOSE_SATURDAY
	iftrue .Leftover
	farscall PhoneScript_Random2
	ifequal 0, JoseWantsBattle

.Leftover:
	farscall PhoneScript_Random3
	ifequal 0, JoseFoundRare
	farsjump Phone_GenericCall_Male

JoseSaturday:
	setflag ENGINE_JOSE_SATURDAY

JoseWantsBattle:
	getlandmarkname STRING_BUFFER_5, LANDMARK_ROUTE_27
	setflag ENGINE_JOSE_READY_FOR_REMATCH
	farsjump PhoneScript_WantsToBattle_Male

JoseFoundRare:
	farsjump Phone_CheckIfUnseenRare_Male

JoseHasStarPiece:
	setflag ENGINE_JOSE_HAS_STAR_PIECE
	getlandmarkname STRING_BUFFER_5, LANDMARK_ROUTE_27
	farsjump PhoneScript_FoundItem_Male
