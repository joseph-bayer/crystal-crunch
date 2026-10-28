RepelWoreOffScript::
	opentext
	writetext .RepelWoreOffText
	waitbutton
	closetext
	end

.RepelWoreOffText:
	text_far _RepelWoreOffText
	text_end

UseAnotherRepelScript::
	opentext
	readmem wCurItem
	getitemname STRING_BUFFER_3, USE_SCRIPT_VAR
	writetext .UseAnotherRepelText
	yesorno
	iffalse .done
	callasm UseAnotherRepel
.done
	closetext
	end

.UseAnotherRepelText:
	text_far _UseAnotherRepelText
	text_end

UseAnotherRepel:
	farcall LoadRepelTypeItem
	ret nc
	; make TossItem search the pocket instead of trusting the bag cursor
	ld a, -1
	ld [wCurItemQuantity], a
	jmp DoItemEffect
