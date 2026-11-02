DefaultOptions:
; wOptions: fast text speed
	db TEXT_DELAY_FAST
; wSaveFileExists: no
	db FALSE
; wTextboxFrame: frame 1
	db FRAME_1
; wTextboxFlags: use text speed
	db 1 << FAST_TEXT_DELAY_F
; wGBPrinterBrightness: normal
	db GBPRINTER_NORMAL
; wOptions2: menu account on
	db 1 << MENU_ACCOUNT
; wPokedexShinyToggle: off
	db 0
; wCurPokedexColor: red
	db DEXCOLOR_RED
.End
	assert DefaultOptions.End - DefaultOptions == wOptionsEnd - wOptions
