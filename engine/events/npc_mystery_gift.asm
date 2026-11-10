; NPC Mystery Gift Screen
; This file implements an NPC-triggered mystery gift screen that can be called from the overworld
;
; The gift code keeps the partner's ID and name and the player's sent gift in the link version's
; buffers, which share their RAM with wOverworldMapBlocks: the link version only runs from the
; main menu, before a map is loaded. Here a map is loaded, so whatever writes those buffers
; rebuilds the map's blocks afterwards, the way a map load does. Otherwise the blocks underneath
; stay wrong until the map is loaded again.

SetNPCMysteryGiftPartnerID:
; An NPC partner's ID, for the link version's daily partner list: 0 then the NPC's number, which
; is in wScriptVar. Shared with real link partners, so a trainer ID of 0-3 would read as an NPC.
	xor a
	ld [wMysteryGiftPartnerID], a
	ld a, [wScriptVar]
	ld [wMysteryGiftPartnerID + 1], a
	ret

CheckNPCMysteryGiftToday:
; special: before an NPC's gift screen. in: wScriptVar = the NPC's number
; out: wScriptVar = TRUE if the player already had a gift from that NPC today
	farcall DoMysteryGiftIfDayHasPassed ; so a new day clears the list first, as domysterygift does
	call SetNPCMysteryGiftPartnerID
	call DoMysteryGift.CheckAlreadyGotAGiftFromThatPerson
	sbc a ; -1 if already, else 0
	and TRUE
	push af
	call ReloadMapBlocks ; the partner ID was written over the map's blocks
	pop af
	ld [wScriptVar], a
	ret

DoNPCMysteryGift::
	; Stop updating Sprite positions and set all bg palettes to black/empty
	call DisableSpriteUpdates
	call ClearBGPalettes
	
	; Clear the screen and set up the mystery gift layout
	call ClearTilemap ; fill entire screen tilemap with blank tiles
	call ClearSprites ; remove all sprites form the screen (NPCs, player, boulders, etc)
	call WaitBGMap ; Wait for GB video hardware to finish drawing cleared screen
	
  ; Load border graphics, decorative frame, and call the CGB palette layout system.
	call InitMysteryGiftLayout
	
  ; Walking sprites have likely overwritten the font in VRAM, so lets load that back in
	call LoadStandardFont

	; Display custom text for NPC interaction
	hlcoord 3, 8
	ld de, .NPCMysteryGiftText
	rst PlaceString
	call WaitBGMap

  ; Set up palettes
	ld b, SCGB_MYSTERY_GIFT ; load mystery gift layout id into B
	call GetSGBLayout ; Applies the CGB color palette layout (sets up attribute map and loads palettes)
	call SetDefaultBGPAndOBP ; sets default bg and object palettes for non-CGB Game Boys (is this necessary?)
	call DelayFrame ; wait one frame for all graphic changes to take effect

.input_loop
	; Handle input
	call .GetInput
	jr nc, .input_loop ; nothing else to check for yet

.exit_screen
	; Play exit sound
	call PlayClickSFX
	
	; Return to overworld
	jmp .ReturnToOverworld

.GetInput
	; Get joypad input
	call GetJoypad
	ldh a, [hJoyPressed]
	
	; Check for B button to exit
	bit B_PAD_B, a
	jr nz, .pressed_b

	ldh a, [hJoyPressed]

  bit B_PAD_A, a
	jr nz, .pressed_a
	
	; Return the input for other processing
	and a ; clear carry flag
	ret

.pressed_b
  jp .MysteryGiftCanceled

.pressed_a
	call SetNPCMysteryGiftPartnerID
	call DoMysteryGift.CheckAlreadyGotAGiftFromThatPerson
	ld hl, DoMysteryGift.MysteryGiftOneADayText ; Only one gift a day per person
	jmp c, .PrintTextAndExit
  ; Check if you have a pending gift
  call GetMysteryGiftBank
  ld a, [sMysteryGiftItem]
  call CloseSRAM
	and a
	jp nz, .GiftWaiting ; If yes, tell player to get it first
; fall through
.SendGift:
  call DoMysteryGift.AddMysteryGiftPartnerID

  ; update wMysteryGiftPartnerName
  ld hl, MysteryGiftNPCNames ; store pointer to Mystery Gift NPC name table
  ld a, [wScriptVar] ; get the Mystery Gift NPC ID/Index from wScriptVar

  push af
  ; Move to the correct position in the name table
  ld bc, (NAME_LENGTH - 1)
  rst AddNTimes

  ; Copy the NPC name into wMysteryGiftPartnerName
  ld de, wMysteryGiftPartnerName
  ld bc, (NAME_LENGTH - 1)
  rst CopyBytes
  pop af

  call Random
  and 1 ; keep only 1 bit - determines item vs decoration
	jr z, .SentItem
; sent decoration
	call .RandomSample
	ld c, a
	farcall MysteryGiftGetDecoration
	push bc
	farcall CheckAndSetMysteryGiftDecorationAlreadyReceived
  farcall CopyMysteryGiftReceivedDecorationsToPC
	pop bc
	jr nz, .SentItem
; keep the decoration if it wasn't already received
	farcall GetDecorationName_c
	ld h, d
	ld l, e
	ld de, wStringBuffer1
	ld bc, ITEM_NAME_LENGTH
	rst CopyBytes
  ld hl, wPlayerName
  ld bc, NAME_LENGTH
  ld de, wMysteryGiftPlayerName
  rst CopyBytes

	ld hl, DoMysteryGift.MysteryGiftSentHomeText ; sent decoration to home
	jp .PrintTextAndExit

.SentItem
  ; Get Item name into wStringBuffer1
  ld a, BANK(sMysteryGiftData)
	call OpenSRAM
  call .RandomSample
  ld c, a
	farcall MysteryGiftItemToSave
	ld a, b
  ld [sBackupMysteryGiftItem], a
	ld [wMysteryGiftPlayerBackupItem], a
  ld [sMysteryGiftItem], a
	ld a, c
	ld [wNamedObjectIndex], a
	call CloseSRAM
  call GetItemName

  ld hl, DoMysteryGift.MysteryGiftSentText
  jr .PrintTextAndExit

.MysteryGiftCanceled:
	ld hl, DoMysteryGift.MysteryGiftCanceledText
	jr .PrintTextAndExit

.GiftWaiting:
	ld hl, DoMysteryGift.RetrieveMysteryGiftText ; receive gift at counter
	; fallthrough

.PrintTextAndExit:
  ; Clear screen so we can just show a textbox
  push hl
  call ClearTilemap
	call WaitBGMap
	ld b, SCGB_DIPLOMA
	call GetSGBLayout
	call SetDefaultBGPAndOBP
  farcall LoadFonts_NoOAMUpdate ; load font so NPC graphics don't replace border graphics
  pop hl

	call PrintText
	ld a, LCDC_DEFAULT
	ldh [rLCDC], a
	scf ; set carry flag to indicate exit
	ret

.ReturnToOverworld
	; Clear the mystery gift screen
	call ClearTilemap
	call ClearSprites
	call ClearBGPalettes
	
	; Restore overworld graphics and state
	call ReloadMapBlocks ; the gift's buffers were written over the map's blocks; the screen is drawn from them next
	call ReloadTilesetAndPalettes ; reload the map's tileset graphics and color palettes for current map data
	call UpdateSprites ; Redraw all sprites on the screen
	call EnableSpriteUpdates ; Reenable sprite updates

	; Set proper palettes for overworld
	ld b, SCGB_MAPPALS
	call GetSGBLayout ; apply standard overworld palette
	call WaitBGMap2 ; wait until graphics are drawn
	farcall LoadOW_BGPal7 ; load the standard overworld text bg palette
	farcall EnableDynPalUpdates ; re-enable automatic palette updates for things like time transitions
	call DelayFrame 
	
	; Re-enable map animations
	ld a, 1
	ldh [hMapAnims], a
	ret

; Determine gift index
; Returns Gift Index in A
.RandomSample
  call Random
  and 1
  jr z, .fiftypercent
  ; common index - 50% chance - index 0-15 
  call Random
  and 15 ; keep the lower 4 bits
  ret
.fiftypercent
  call Random
  and 1
  jr z, .twentyfivepercent
  ; uncommon index - 25% chance - index 16-23
  call Random
  and 7 ; keep only lower 3 bits (0-7)
  add $10 ; add 16 to A, so result with be 16-23
  ret
.twentyfivepercent
  call Random
  cp 20 percent - 1
  jr c, .fivepercent ; as the link version's roll does
  ; rare index - 20% chance - index (24-31)
  call Random
  and 7 ; keep only lower 3 bits (0-7)
  add $18 ; add 24 to A, so result with be 24-31
  ret
.fivepercent
  ; super rare index - 5% chance - index 32-33
  call Random
  and 1
  ld a, $20 ; index 32
  ret z
  ld a, $21 ; index 33
  ret

.NPCMysteryGiftText:
	db   "Press A to"
	next "MYSTERY GIFT"
	next "Press B to"
	next "exit screen."
	db   "@"

INCLUDE "data/mystery_gift_npcs/names.asm"