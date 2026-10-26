BackupGSBallFlag:
	ld a, BANK(sGSBallFlag)
	call OpenSRAM
	ld a, [sGSBallFlag]
	push af
	ld a, BANK(sGSBallFlagBackup)
	call OpenSRAM
	pop af
	ld [sGSBallFlagBackup], a
	jmp CloseSRAM

RestoreGSBallFlag:
	ld a, BANK(sGSBallFlagBackup)
	call OpenSRAM
	ld a, [sGSBallFlagBackup]
	push af
	ld a, BANK(sGSBallFlag)
	call OpenSRAM
	pop af
	ld [sGSBallFlag], a
	jmp CloseSRAM

ClearGSBallFlag:
	ld a, BANK(sGSBallFlag)
	call OpenSRAM
	xor a
	ld [sGSBallFlag], a
	jmp CloseSRAM

; functions related to the cable club and various NPC scripts referencing communications

Function106464::
	ld de, MobileDialingFrameGFX
	ld hl, vTiles2 tile $62
	lb bc, BANK(MobileDialingFrameGFX), 9
	call Get2bpp
;	ld de, $40b0
;	ld hl, vTiles2 tile $6b
;	ld b, $0f ; no graphics at 0f:40b0; JP leftover???
;	call Get2bpp
	farjp LoadFrame

MobileDialingFrameGFX:
INCBIN "gfx/mobile/dialing_frame.2bpp"
