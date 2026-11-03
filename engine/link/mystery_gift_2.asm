StageDataForMysteryGift:
  ; Set up the staging buffer and store game version identifier
	ld de, wMysteryGiftStaging
	ld a, GS_VERSION + 1
	ld [de], a

  ; Store player id (our id or other player's?) in staging buffer and BC
	inc de ; wMysteryGiftStaging+1
	ld a, BANK(sGameData) ; set a to SRAM bank of save data
	call OpenSRAM ; switch to SRAM bank
	ld hl, sPlayerData + wPlayerID - wPlayerData ; HL = pointer to player ID in SRAM
	ld a, [hli] ; move first byte of player ID to A and increment HL to the next byte
	ld [de], a ; store it in staging buffer
	ld b, a ; store first byte in B
	inc de ; wMysteryGiftStaging+2
	ld a, [hl] ; store the second byte of player ID in A
	ld [de], a ; store it in staging buffer 
	ld c, a ; store second byte in C

  ; Store player name in staging buffer
	inc de ; wMysteryGiftStaging+3
	push bc ; save player ID bytes on stack
	ld hl, sPlayerData + wPlayerName - wPlayerData ; HL = pointer to player name in SRAM
	ld bc, NAME_LENGTH ; BC = length of player name
	rst CopyBytes ; copy player name from SRAM to staging buffer

  ; Count caught Pokémon and store the number in staging buffer
  ; Caps at 1 byte, so anything over 255 is stored as 255 for some reason.
	push de ; wMysteryGiftStaging+14 
	ld hl, sPokemonData + wPokedexCaught - wPokemonData 
	ld bc, wEndPokedexCaught - wPokedexCaught 
	call CountSetBits16 
	ld a, b ; load high byte into A (high byte is 0 if count <= 255)
	add -1 ; add 255 to A, sets carry if overflow
	sbc a  ; A = A - A - carry (so A = 255 if the high byte > 0)
	or c 
	pop de 
	pop bc 
	ld [de], a 

  ; Generate a random bit (0 or 1) for gift randomization in buffer
	inc de ; wMysteryGiftStaging+15 
	call CloseSRAM ; close SRAM access
	call Random ; get a random number
	and 1 ; keep only 1 bit - determines item vs decoration gift later
	ld [de], a ; store random bit in staging buffer

  ; Generate two gift indices - one for item, and one for decoration, using the player ID bytes in different orders for variety.
	inc de ; wMysteryGiftStaging+16 (Item)
	call .RandomSample ; generate random gift index based on first byte of player ID (which is stored in B)
	ld [de], a ; store first gift index in staging buffer
	inc de ; wMysteryGiftStaging+17 (Decoration)
	ld a, c ; swap bytes of player ID
	ld c, b ; for different randomization
	ld b, a
	call .RandomSample ; generate second gift index based on second byte of player ID (which is now in B)
	ld [de], a ; store second gift index in staging buffer

  ; Store backup gift item and daily exchange count.
	inc de ; wMysteryGiftStaging+18
	ld a, BANK(sBackupMysteryGiftItem) ; get SRAM bank of backup item.
	call OpenSRAM ; switch to SRAM bank
	ld a, [sBackupMysteryGiftItem] ; load backup gift item. This will be populated if you haven't picked up a mystery gift yet.
	ld [de], a ; store it in staging buffer
	inc de ; wMysteryGiftStaging+19
	ld a, [sNumDailyMysteryGiftPartnerIDs] ; load daily exchange count
	ld [de], a ; store it in staging buffer

  ; Copy the staged data to the final player data structure.
	ld a, wMysteryGiftPlayerDataEnd - wMysteryGiftPlayerData
	ld [wUnusedMysteryGiftStagedDataLength], a
	call CloseSRAM
	ld hl, wMysteryGiftStaging ; HL = pointer to staging buffer
	ld de, wMysteryGiftPlayerData ; DE = pointer to player data structure
	ld bc, wMysteryGiftPlayerDataEnd - wMysteryGiftPlayerData ; BC = length of data to copy
	jmp CopyBytes

; BC = byte from player ID to use as random seed
; A = random gift index (0-33)
; When called for an Item, B is the high byte of player ID and C is the low byte.
; When called for a decoration, C is the high byte of player ID and B is the low byte.
.RandomSample:
	push de
	call Random
	cp 10 percent ; 10 percent of 255 (0-25)
	jr c, .tenpercent

  ; 90 percent chance - common item (index 0-15)
	call Random
	and %111 ; keep only lower 3 bits (0-7). Later we will use this to rotate a bitmask. generating a number from 0-7 allows us to pick one of 8 bits in a byte. 7 is the maximum value we could get following this type of pattern without needing to channge the bitmask (0-7 represnet all 8 bits in a byte)
	ld d, a ; store random number (0-7) in D
	rl d ; rotate D left once (multiply by 2). D is now 0, 2, 4, ..., 14
	ld e, %10000000 ; rotating bitmask
.loop
	rlc e ; rotate our bitmask left (circular)
	dec a ; subtract 1 from the random number (0-7) that we generated earlier
	jr nz, .loop ; continue rotating our bitmask until we've done it the number of times equal to the random number (0-7)
	ld a, e ; move bitmask to A
	and c ; and the bitmask with C (which is one byte of the player ID, or nibble-swapped player ID)
	jr z, .skip ; if the result is 0, add 0 to D
	ld a, $1 ; if the result is non-zero, add 1 to D
.skip
	add d ; add D to A. A can now be 0-15
	jr .done

.tenpercent
	call Random
	cp 20 percent - 1 
	jr c, .twopercent
  ; 8 percent chance - uncommon item (index 16-23)
	call Random
	and %011 ; keep only lower 2 bits (0-3). Later we will use this to rotate a bitmask. generating a number from 0-3 allows us to pick one of 4 bits in a nibble.
	ld d, a ; store random number (0-3) in D
	rl d ; rotate D left once (multiply by 2). D is now 0, 2, 4, or 6
	ld e, %10000000 ; rotating bitmask
.loop2
	rlc e ; rotate our bitmask left (circular)
	dec a ; subtract 1 from the random number (0-3) that we generated earlier
	jr nz, .loop2 ; continue rotating our bitmask until we've done it the number of times equal to the random number (0-3)
	ld a, e ; load bitmask into A
	and b ; and the bitmask with B (which is one byte of the player ID, or nibble-swapped player ID)
	jr z, .skip2 ; if the result is 0, add 0 to D
	ld a, $1 ; if the result is non-zero, add 1 to D
.skip2
	add d ; add D to A. A can now be 0-7
	add $10 ; add 16 to A. A can now be 16-23
	jr .done

.twopercent
	call Random
	cp 20 percent - 1
	jr c, .pointfourpercent
  ; 1.6 percent chance - rare item (index 24-31)
	ld a, b ; use the first byte of player ID as a base
	swap a ; swap nibbles to use the second half of the byte
	and %111 ; keep only lower 3 bits (0-7). 
	add $18 ; add 24 to A. A can now be 24-31
	jr .done

.pointfourpercent
  ; 0.4 percent chance - super rare item (index 32-33)
	ld a, b ; use the first byte of player ID as a base
	and %111 ; keep only lower 3 bits (0-7). Sets z flag if A is 0
	ld a, $20 ; load item index 32. Will be used if A was 0 after the AND operation
	jr z, .done
	ld a, $21 ; load item index 33

.done
	pop de ; restore DE
	ret

MysteryGiftItemToSave:
; in: c = a MysteryGiftItems position
; out: b = the byte to save for the gift, c = the item's 8-bit ID, to name it now
; A gift is saved as its position plus one, never as an 8-bit ID: an ID only means something in the
; table it came from, and the link exchange runs at the main menu, before the save's own table is
; loaded. A position past the list saves as one past it, which collects as the fallback item.
	ld a, c
	cp (MysteryGiftItems.End - MysteryGiftItems) / 2
	jr c, .in_list
	ld a, (MysteryGiftItems.End - MysteryGiftItems) / 2
.in_list
	inc a
	push af
	call MysteryGiftGetItem
	pop af
	ld b, a
	ret

MysteryGiftSavedItem:
; in: a = a saved gift (see MysteryGiftItemToSave)
; out: c = the item's 8-bit ID
	dec a
	ld c, a
	; fallthrough

MysteryGiftGetItem:
; in: c = a MysteryGiftItems position
; out: c = the item's 8-bit ID, or a Great Ball's past the end of the list
	ld a, c
	cp (MysteryGiftItems.End - MysteryGiftItems) / 2
	jr c, .in_list
	ld hl, GREAT_BALL
	jr .got_index

.in_list
	ld hl, MysteryGiftItems
	ld b, 0
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
.got_index
	call GetItemIDFromIndex
	ld c, a
	ret

MysteryGiftGetDecoration:
	ld a, c
	cp MysteryGiftDecos.End - MysteryGiftDecos
	jr nc, .fallback
	ld hl, MysteryGiftDecos
	ld b, 0
	add hl, bc
	ld c, [hl]
	ret

.fallback
	ld c, DECOFLAG_RED_CARPET
	ret

INCLUDE "data/items/mystery_gift_items.asm"

INCLUDE "data/decorations/mystery_gift_decos.asm"
