_UpdatePlayerSprite::
	call GetPlayerSprite
	ld a, [wUsedSprites]
	ldh [hUsedSpriteIndex], a
	ld a, [wUsedSprites + 1]
	ldh [hUsedSpriteTile], a
	ld hl, wSpriteFlags
	res 5, [hl]
	jmp GetUsedSprite

LoadStandingSpritesGFX: ; mobile
	ld hl, wSpriteFlags
	ld a, [hl]
	push af
	res SPRITES_SKIP_STANDING_GFX_F, [hl]
	set SPRITES_SKIP_WALKING_GFX_F, [hl]
	call LoadUsedSpritesGFX
	pop af
	ld [wSpriteFlags], a
	ret

LoadWalkingSpritesGFX: ; mobile
	ld hl, wSpriteFlags
	ld a, [hl]
	push af
	set SPRITES_SKIP_STANDING_GFX_F, [hl]
	res SPRITES_SKIP_WALKING_GFX_F, [hl]
	call LoadUsedSpritesGFX
	pop af
	ld [wSpriteFlags], a
	ret

GetPlayerSprite:
; Get Chris or Kris's sprite.
	ld hl, ChrisStateSprites
	ld a, [wPlayerSpriteSetupFlags]
	bit PLAYERSPRITESETUP_FEMALE_TO_MALE_F, a
	jr nz, .go
	ld a, [wPlayerGender]
	bit PLAYERGENDER_FEMALE_F, a
	jr z, .go
	ld hl, KrisStateSprites

.go
	ld a, [wPlayerState]
	ld c, a
.loop
	ld a, [hli]
	cp c
	jr z, .good
	inc hl
	cp -1
	jr nz, .loop

; Any player state not in the array defaults to Chris's sprite.
	xor a ; ld a, PLAYER_NORMAL
	ld [wPlayerState], a
	ld a, SPRITE_CHRIS
	jr .finish

.good
	ld a, [hl]

.finish
	ld [wUsedSprites + 0], a
	ld [wPlayerSprite], a
	ld [wPlayerObjectSprite], a
	ret

INCLUDE "data/sprites/player_sprites.asm"

RefreshSprites::
	push hl
	push de
	push bc
	call UpdateFollowerPresence
	call GetPlayerSprite
	xor a
	ldh [hUsedSpriteIndex], a
	call ReloadSpriteIndex
	call LoadMiscTiles
	jmp PopBCDEHL

ReloadSpriteIndex::
; Reloads sprites using hUsedSpriteIndex.
; Used to reload variable sprites
	ld hl, wObjectStructs
	ld de, OBJECT_LENGTH
	push bc
	ldh a, [hUsedSpriteIndex]
	ld b, a
	xor a
.loop
	ldh [hObjectStructIndex], a
	ld a, [hl]
	and a
	jr z, .done
	bit 7, b
	jr z, .continue
	cp b
	jr nz, .done
.continue
	push hl
	call GetSpriteVTile
	pop hl
	push hl
	inc hl
	inc hl
	ld [hl], a
	pop hl
.done
	add hl, de
	ldh a, [hObjectStructIndex]
	inc a
	cp NUM_OBJECT_STRUCTS
	jr nz, .loop
	pop bc
	ret

LoadUsedSpritesGFX:
	ld a, MAPCALLBACK_SPRITES
	call RunMapCallback
	call GetUsedSprites
; fallthrough
LoadMiscTiles:
	ld a, [wSpriteFlags]
	bit SPRITES_SKIP_WALKING_GFX_F, a
	ret nz

	ld c, EMOTE_POKE_BALL
	call LoadEmote

	ld c, EMOTE_SHADOW
	call LoadEmote
	call GetMapEnvironment
	call CheckOutdoorMap
	ld c, EMOTE_GRASS_RUSTLE
	jr z, .outdoor
	ld c, EMOTE_BOULDER_DUST
.outdoor
	jmp LoadEmote

SafeGetSprite:
	push hl
	call GetSprite
	pop hl
	ret

GetSprite::
	call GetFollowingSprite
	ret c
	call GetMonSprite
	ret c

	ld hl, OverworldSprites + SPRITEDATA_ADDR
	dec a
	ld c, a
	ld b, 0
	ld a, NUM_SPRITEDATA_FIELDS
	rst AddNTimes
	; load the address into de
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	; load the length into c
	ld a, [hli]
	swap a
	ld c, a
	; load the sprite bank into both b and h
	ld b, [hl]
	ld a, [hli]
	; load the sprite type into l
	ld l, [hl]
	ld h, a
	ret

GetMonSprite:
; Return carry if a monster sprite was loaded.

	cp SPRITE_POKEMON
	jr c, .Normal
	cp SPRITE_OW_MON
	jr c, .pokemon_sprite
	cp SPRITE_OW_MON + NUM_OW_MON_SLOTS
	jr c, .ow_mon
	cp SPRITE_DAY_CARE_MON_1
	jr z, .BreedMon1
	cp SPRITE_DAY_CARE_MON_2
	jr z, .BreedMon2
	cp SPRITE_VARS
	jr nc, .Variable
	jr .pokemon_sprite

.Normal:
	and a
	ret

.pokemon_sprite:
	sub SPRITE_POKEMON
	ld e, a
	ld d, 0
; A SpriteMons entry names a species and nothing else, so the form is always the plain one.
; Say so, rather than leaving wForm holding whatever wrote it last -- the follower loads before
; any map object and would otherwise lend a Pikachu doll its Flying Pikachu form.
	xor a ; PLAIN_FORM
	ld [wForm], a
	ld hl, SpriteMons
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call GetPokemonIDFromIndex
	jr .Mon

.ow_mon
; The species is not in the sprite id -- the id names a slot, and this map's row in
; OverworldMonObjects says what the slot holds. So the same id is a Dratini in Blackthorn and a
; Miltank on Route 39, and either can carry a cosmetic form or be shiny.
	sub SPRITE_OW_MON
	farcall GetOverworldMonSlot ; hl = species index, a = form byte, carry if the slot is filled
	jr nc, .NoBreedmon ; nothing declared this slot: show nothing rather than species 0
	ld [wForm], a ; LoadOverworldMonIcon reads this for cosmetic forms and Unown letters
	call GetPokemonIDFromIndex
	ld d, 0 ; not a day-care mon, so the form written above is used as-is
	jr .Mon

.BreedMon1
	ld a, [wBreedMon1Species]
	ld d, 1
	jr .Mon

.BreedMon2
	ld a, [wBreedMon2Species]
	ld d, 2

.Mon:
	ld e, a
	and a
	jr z, .NoBreedmon

	farcall LoadOverworldMonIcon
; An icon is 8 tiles; an overworld sprite is 12 standing and 12 walking. Handing the 8 straight to
; the loader leaves it copying whatever sits after them in the icon table -- which is invisible on
; a mon that only ever faces the camera, and is the garbage you see the moment one turns or walks.
	jmp ExpandMonIconToSprite

.Variable:
	sub SPRITE_VARS
	ld e, a
	ld d, 0
	ld hl, wVariableSprites
	add hl, de
	ld a, [hl]
	and a
	jr nz, GetMonSprite

.NoBreedmon:
	ld a, WALKING_SPRITE
	lb hl, 0, WALKING_SPRITE
	and a
	ret

GetFollowerMon::
; Returns the follower's species ID in a and its 1-based party slot in d.
; Returns a = 0 when nobody should be out: an empty party, nobody selected, or a selected mon
; that has fainted -- a fainted follower keeps its slot, it just stays in its ball. There is no
; falling through to another mon: once the choice is the player's, quietly substituting a
; different one is worse than showing nobody.
	ld a, [wPartyCount]
	and a
	ret z
	ld e, a ; how many mons are in the party

	ld a, [wFollowerPartySlot]
	and a
	ret z ; nobody selected
	cp e
	jr z, .in_party
	ret nc ; the slot points past the end of the party; a = the slot, so nonzero -- fix below
.in_party
	ld d, a ; d = the follower's slot, 1-based

	dec a
	add LOW(wPartySpecies)
	ld l, a
	adc HIGH(wPartySpecies)
	sub l
	ld h, a
	ld a, [hl]
	cp EGG
	ret z ; an egg has no HP worth testing, and following as one is allowed
	push af

	ld a, d
	dec a
	ld hl, wPartyMon1HP
	call GetPartyLocation
	ld a, [hli]
	or [hl]
	jr z, .fainted
	pop af
	ret

.fainted
	pop af
	xor a
	ret

UpdateFollowerPresence::
; Keeps the follower object in step with the party menu's choice. With nobody following -- no
; selection, an empty party, or a choice that has fainted -- there is no mon to put on screen,
; and SPRITE_FOLLOWER has no OverworldSprites entry of its own, so GetFollowingSprite's fallback
; used to hand the object a placeholder NPC sprite and one walked around behind the player.
; Only acts on a change, so it is safe on the every-text-close path that calls it.
	call GetFollowerMon
	and a
	ld a, [wObject1Sprite]
	jr z, .nobody
	cp SPRITE_FOLLOWER
	ret z ; already out
	farjp SpawnFollowerObject

.nobody
	cp SPRITE_FOLLOWER
	ret nz ; already gone
	farjp DespawnFollowerObject

SwapFollowerSlot::
; Keep the follower pointing at the same mon when two party slots trade places.
; in: b, c = the two 1-based slots being exchanged. Preserves everything else.
	ld a, [wFollowerPartySlot]
	cp b
	jr z, .take_c
	cp c
	ret nz
	ld a, b
	ld [wFollowerPartySlot], a
	ret

.take_c
	ld a, c
	ld [wFollowerPartySlot], a
	ret

RemoveFollowerSlot::
; Called when a party slot is removed and the ones after it shift down to fill the gap.
; in: a = the 1-based slot that left.
; The follower shifts with them; if the follower is what left, the first slot takes over.
	ld b, a
	ld a, [wFollowerPartySlot]
	and a
	ret z ; nobody selected, and deselecting is deliberate
	cp b
	jr z, .default_to_first
	ret c ; ahead of the gap, so its slot is unchanged
	dec a
	ld [wFollowerPartySlot], a
	ret

.default_to_first
	ld a, 1
	ld [wFollowerPartySlot], a
	ret

ValidateFollowerSlot::
; The PC removes a mon by shifting it to the end of the party and then shortening the party, so a
; follower left pointing past the end is the mon that just left. Also repairs a slot from an older
; save that predates this being stored.
	ld a, [wFollowerPartySlot]
	and a
	ret z ; nobody selected, and deselecting is deliberate
	ld b, a
	ld a, [wPartyCount]
	cp b
	ret nc
	ld a, 1
	ld [wFollowerPartySlot], a
	ret

SetFollowerFromParty::
; Picks the follower from the party and locks its 8-bit ID so the
; 16-bit conversion table can't evict it while it's on screen.
; Returns a = species ID (0 if the party is empty).
	call GetFollowerMon
	and a
	ret z
	ld [wFollowerSpriteID], a
	ld l, LOCKED_MON_ID_FOLLOWER
	call LockPokemonID
	ld a, d
	ld [wFollowerPartyNum], a
	ld a, [wFollowerSpriteID]
	ret

GetFollowingSprite:
	cp SPRITE_FOLLOWER
	jr z, .follower
	and a ; not the follower; let GetMonSprite deal with this sprite id
	ret

.follower
	call SetFollowerFromParty
	and a
; No party (or no living mon): there is no follower sprite to load. SPRITE_FOLLOWER has no
; OverworldSprites entry, so fall back rather than running off the end of the table.
	jmp z, GetMonSprite.NoBreedmon
	; fallthrough

; A party menu icon is 8 tiles: two 2x2 frames, each stored top-left, top-right, bottom-left,
; bottom-right. An overworld sprite wants 12 standing tiles - facing down at $00, up at $04,
; left/right at $08 - followed by the same 12 walking tiles at +$80. Copying frame 1 into all
; three standing facings and frame 2 into all three walking facings makes the engine's own walk
; cycle alternate the icon's two frames, whichever way the mon is facing.
DEF MON_ICON_FRAME_SIZE EQU 4 tiles
DEF MON_ICON_FACINGS    EQU 3

GetFollowerIconSprite:
; in: a = the follower's species ID
; out: the GetSprite contract - de = graphics, b = bank, c = tile count, l = sprite type, carry set
	push af
	ld a, [wFollowerPartyNum]
	dec a ; wFollowerPartyNum is 1-based
	ld hl, wPartyMon1
	call GetPartyLocation
	pop af
	push af
	call GetMonDrawForm ; an egg's pattern, or the mon's own form
	ld [wForm], a ; LoadOverworldMonIcon reads this for cosmetic forms and Unown letters
	pop af
	ld e, a
	ld d, 0 ; not a day-care mon, so wForm above is used as-is
	farcall LoadOverworldMonIcon ; de = icon graphics, b = its bank, c = 8 tiles
	; fallthrough

ExpandMonIconToSprite::
; Build a full overworld sprite out of a party menu icon.
; in:  de = the icon's two 2x2 frames, b = the bank they are in
; out: the GetSprite contract - de = graphics, b = bank, c = tile count, l = type, carry set
	ldh a, [rSVBK]
	push af
	ld a, BANK(wDecompressScratch)
	ldh [rSVBK], a

	ld h, d
	ld l, e ; hl = icon frame 1
	ld a, b ; a = icon bank
	ld de, wDecompressScratch
	call .CopyFrameToEachFacing ; frame 1 becomes every standing facing
	ld bc, MON_ICON_FRAME_SIZE
	add hl, bc ; hl = icon frame 2
	call .CopyFrameToEachFacing ; frame 2 becomes every walking facing

; Every facing holds the same artwork, so mirror the down-facing copies. Walking towards the camera
; then reads as a different pose from walking away, rather than the two being identical.
	ld hl, wDecompressScratch
	call .MirrorFrameInPlace
	ld hl, wDecompressScratch + MON_ICON_FACINGS * MON_ICON_FRAME_SIZE
	call .MirrorFrameInPlace

	pop af
	ldh [rSVBK], a

	ldh a, [hROMBank]
	ld b, a ; the graphics are in WRAM now, so any valid bank will do for Get2bpp
	ld de, wDecompressScratch
	ld c, MON_ICON_FACINGS * 4
	lb hl, 0, WALKING_SPRITE
	scf
	ret

.CopyFrameToEachFacing:
; in: a = bank, hl = one 2x2 frame, de = destination
; out: de advanced past the block, a and hl unchanged
	push hl
	ld c, MON_ICON_FACINGS
.loop
	push bc
	push hl
	push af
	ld bc, MON_ICON_FRAME_SIZE
	call FarCopyBytes ; copies bc bytes from a:hl to de, advancing de
	pop af
	pop hl
	pop bc
	dec c
	jr nz, .loop
	pop hl
	ret

.MirrorFrameInPlace:
; in: hl = one 2x2 frame in WRAM, stored top-left, top-right, bottom-left, bottom-right
; Mirrors it horizontally: the two columns swap, and every byte's bits are reversed.
	push hl
	ld d, h
	ld e, l ; de = top-left
	ld bc, TILE_SIZE
	add hl, bc ; hl = top-right
	call .SwapAndReverseTiles
	pop hl
	push hl
	ld bc, TILE_SIZE * 2
	add hl, bc
	ld d, h
	ld e, l ; de = bottom-left
	ld bc, TILE_SIZE
	add hl, bc ; hl = bottom-right
	call .SwapAndReverseTiles
	pop hl
	ret

.SwapAndReverseTiles:
; in: hl and de each point at one 2bpp tile in WRAM; swaps them, reversing each byte
	ld c, TILE_SIZE
.swap_loop
	ld a, [de]
	call .ReverseBits
	ld b, a
	ld a, [hl]
	call .ReverseBits
	ld [de], a
	ld a, b
	ld [hli], a
	inc de
	dec c
	jr nz, .swap_loop
	ret

.ReverseBits:
; in: a = a byte. out: a = that byte with its bits in the opposite order.
	push bc
	ld b, a
	ld c, 0
	ld a, 8
.reverse_loop
	rl b ; the top bit of b falls out into carry...
	rr c ; ...and lands in the bottom of c, one place further each time
	dec a
	jr nz, .reverse_loop
	ld a, c
	pop bc
	ret

_DoesSpriteHaveFacings::
; Checks to see whether we can apply a facing to a sprite.
; Returns carry unless the sprite is a Pokemon or a Still Sprite.
	cp SPRITE_FOLLOWER
	jr z, .follower
	cp SPRITE_POKEMON
	jr nc, .only_down

	push hl
	push bc
	ld hl, OverworldSprites + SPRITEDATA_TYPE
	dec a
	ld c, a
	ld b, 0
	ld a, NUM_SPRITEDATA_FIELDS
	rst AddNTimes
	ld a, [hl]
	pop bc
	pop hl
	cp STILL_SPRITE
	jr nz, .only_down
	scf
	ret

.follower
	ld a, WALKING_SPRITE

.only_down
	and a
	ret

_GetSpritePalette::
	ld a, c
	cp SPRITE_FOLLOWER
	jr z, .follower
	call .GetBeast
	jr c, .is_beast
	ld a, c
	call GetMonSprite
	jr c, .is_pokemon

.sprite_table
	ld hl, OverworldSprites + SPRITEDATA_PALETTE
	dec a
	ld c, a
	ld b, 0
	ld a, NUM_SPRITEDATA_FIELDS
	rst AddNTimes
	ld c, [hl]
	ret

.is_pokemon
; Colored from the mon itself, exactly as the follower is. GetMonSprite has just resolved the
; icon, which leaves the species in wCurIcon and the form in wForm -- everything the color lookup
; wants, and it does not matter which path got here: a mon slot, a SpriteMons id, a doll's
; variable sprite or a day-care mon all arrive with those two set.
	call .MonColors
	jr c, .no_mon_palette ; every index is spoken for; fall back to a flat overworld color
	ld c, a
	ret

.no_mon_palette
	xor a
	ld c, a
	ret

.is_beast
; With no mon-color index free, a beast keeps its classic sprite-table color.
	push bc ; c = the sprite
	call .MonColors
	pop bc
	jr c, .beast_classic
	ld c, a
	ret

.beast_classic
	ld a, c
	jr .sprite_table

.MonColors:
; out: a = the claimed mon-color index, or carry if there is no mon or no free index
	ld a, [wCurIcon]
	and a
	scf
	ret z
	ld bc, wForm
	farcall GetArrangedMonIconColors ; bc = the light color, de = the dark one
	jr ClaimOverworldMonPalette

.GetBeast:
; The legendary beasts' sprites are colored from the beast itself, by its stored form, so a shiny
; one looks shiny. An object's own palette still overrides this, which keeps the statues silver.
; in: c = a sprite id
; out: carry, with wCurIcon and wForm set, if it is one of the three
	ld hl, .Beasts
.beast_loop
	ld a, [hli]
	and a
	ret z ; not a beast; `and a` has cleared carry
	cp c
	jr z, .found_beast
	inc hl
	inc hl
	inc hl
	inc hl
	jr .beast_loop

.found_beast
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a ; de = the species index
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [hl] ; its stored form
	ld [wForm], a
	ld h, d
	ld l, e
	call GetPokemonIDFromIndex
	ld [wCurIcon], a
	scf
	ret

.Beasts:
	db SPRITE_RAIKOU
	dw RAIKOU, wRoamMon1Form
	db SPRITE_ENTEI
	dw ENTEI, wRoamMon2Form
	db SPRITE_SUICUNE
	dw SUICUNE, wRoamMon3Form ; Suicune doesn't roam, but its form is kept here
	db 0 ; end

.follower
; The follower is colored from the mon's own palette -- the two colors its battle sprite uses,
; form and shininess included -- rather than from one of the eight overworld colors.
; CopySpritePal reads them back out of wFollowerPalette when it loads PAL_OW_FOLLOWER.
	call SetFollowerFromParty
	and a
	jr z, .no_mon_palette
	push af
	ld a, [wFollowerPartyNum]
	dec a ; wFollowerPartyNum is 1-based
	ld hl, wPartyMon1
	call GetPartyLocation
	pop af ; a = the follower's species
	push af
	call GetMonDrawForm ; an egg's pattern, or the mon's own form
	ld [wForm], a
	ld bc, wForm ; the follower's draw form, its shiny bit included
	pop af
	farcall GetArrangedMonIconColors ; bc = the light color, de = the dark one
	call StoreFollowerPalette
	ld c, PAL_OW_FOLLOWER
	ret

StoreFollowerPalette:
; Keep the follower's colors where CopySpritePal can reach them without a bank switch, and when
; they have changed, drop the loaded copy so the allocator fetches the new ones. Without that
; last part MarkUsedPal sees PAL_OW_FOLLOWER already loaded and keeps showing the previous mon's.
; in: bc = the light color, de = the dark color
	ld hl, wFollowerPalette
	ld a, c
	cp [hl]
	jr nz, .changed
	inc hl
	ld a, b
	cp [hl]
	jr nz, .changed
	inc hl
	ld a, e
	cp [hl]
	jr nz, .changed
	inc hl
	ld a, d
	cp [hl]
	ret z

.changed
	ld hl, wFollowerPalette
	ld a, c
	ld [hli], a
	ld a, b
	ld [hli], a
	ld a, e
	ld [hli], a
	ld a, d
	ld [hl], a
	; fallthrough

ClaimOverworldMonPalette::
; Hand back the PAL_OW_MON_* index carrying these two colors on this map, claiming a fresh one if
; they are not there yet. Identical mon share an index, which is what keeps the six Rocket Base
; Electrode and the four Route 39 Miltank down to one palette each.
; in:  bc = the light color, de = the dark color (both preserved)
; out: a = the palette index and carry clear, or carry set when every index is taken
;
; The colors are written into the next free entry before the search rather than after it. That
; way the comparison is memory against memory and the loop has registers to spare, instead of
; juggling four bytes of color through it. The entry it writes is the one at the current count,
; which is a real entry while there is room and the spare scratch entry once there is not -- so a
; full table still recognises colors it already holds instead of turning them down.
	push hl
	push de
	push bc
	ld a, [wNumOverworldMonPals]
	call .EntryAddress ; once the table is full this is the spare entry past the end
	ld a, c
	ld [hli], a
	ld a, b
	ld [hli], a
	ld a, e
	ld [hli], a
	ld a, d
	ld [hl], a

	ld c, 0 ; the index being compared against it
.search
	ld a, [wNumOverworldMonPals]
	cp c
	jr z, .claim ; nothing earlier matched, so the entry just written becomes a real one
	ld a, c
	call .EntryAddress
	ld d, h
	ld e, l
	ld a, [wNumOverworldMonPals]
	call .EntryAddress
	ld b, OW_MON_PAL_LENGTH
.compare
	ld a, [de]
	cp [hl]
	jr nz, .next
	inc de
	inc hl
	dec b
	jr nz, .compare
	ld a, c ; a match: reuse that index and leave the count alone
	jr .done

.next
	inc c
	jr .search

.claim
	ld a, [wNumOverworldMonPals]
	cp NUM_OW_MON_PALS
	jr nc, .full ; the colors stay in the scratch entry and are discarded
	ld c, a
	inc a
	ld [wNumOverworldMonPals], a
	ld a, c
.done
	add PAL_OW_MON
	pop bc
	pop de
	pop hl
	and a ; a real index, so no carry
	ret

.full
	pop bc
	pop de
	pop hl
	scf
	ret

.EntryAddress:
; in: a = an index. out: hl = its entry. Preserves bc and de.
	add a
	add a
	assert OW_MON_PAL_LENGTH == 4, "ClaimOverworldMonPalette doubles twice to scale an index"
	add LOW(wOverworldMonPals)
	ld l, a
	adc HIGH(wOverworldMonPals)
	sub l
	ld h, a
	ret

InvalidateFollowerPalette::
; Drop the loaded copy of every palette that comes from a Pokemon rather than a table -- the
; follower's and the overworld mon's alike -- so the allocator fetches them again. MarkUsedPal
; dedupes by palette index, so without this a changed mon -- or a changed time of day -- would
; keep whatever is already sitting in the slot.
	ld hl, wLoadedObjPal0
	ld c, 8
.loop
	ld a, [hl]
	cp PAL_OW_FOLLOWER
	jr c, .next ; every index from the follower's up is a mon's own colors
	ld [hl], -1 ; free the slot, the way ClearSavedObjPals marks an empty one
.next
	inc hl
	dec c
	jr nz, .loop
	ret

AddSpriteGFX:
; Add any new sprite ids to a list of graphics to be loaded.
; Return carry if the list is full.

	push hl
	push bc
	ld b, a
	ld hl, wUsedSprites + 2
	ld c, SPRITE_GFX_LIST_CAPACITY - 1
.loop
	ld a, [hl]
	cp b
	jr z, .exists
	and a
	jr z, .new
	inc hl
	inc hl
	dec c
	jr nz, .loop

	pop bc
	pop hl
	scf
	ret

.exists
	pop bc
	pop hl
	and a
	ret

.new
	ld [hl], b
	pop bc
	pop hl
	and a
	ret

GetSpriteLength:
; Return the length of sprite type a in tiles.

	cp WALKING_SPRITE
	jr z, .AnyDirection
	cp STANDING_SPRITE
	jr z, .AnyDirection
	cp STILL_SPRITE
	jr z, .OneDirection

	ld a, 12
	ret

.AnyDirection:
	ld a, 12
	ret

.OneDirection:
	ld a, 4
	ret

GetUsedSprites:
	ld hl, wUsedSprites
	ld c, SPRITE_GFX_LIST_CAPACITY

.loop
	ld a, [wSpriteFlags]
	res SPRITES_VRAM_BANK_0_F, a
	ld [wSpriteFlags], a

	ld a, [hli]
	and a
	ret z
	ldh [hUsedSpriteIndex], a

	ld a, [hli]
	ldh [hUsedSpriteTile], a

	bit 7, a ; tiles $80+ are in VRAM bank 0
	jr z, .dont_set

	ld a, [wSpriteFlags]
	set SPRITES_VRAM_BANK_0_F, a
	ld [wSpriteFlags], a

.dont_set
	push bc
	push hl
	call GetUsedSprite
	pop hl
	pop bc
	dec c
	jr nz, .loop
	ret

GetUsedSprite::
	ldh a, [hUsedSpriteIndex]
	call SafeGetSprite
	ldh a, [hUsedSpriteTile]
	call .GetTileAddr
	push hl
	push de
	push bc
	ld a, [wSpriteFlags]
	bit SPRITES_SKIP_STANDING_GFX_F, a
	call z, .CopyToVram
	pop bc
	ld l, c
	ld h, $0
rept 4
	add hl, hl
endr
	pop de
	add hl, de
	ld d, h
	ld e, l
	pop hl

	ld a, [wSpriteFlags]
	bit SPRITES_SKIP_WALKING_GFX_F, a
	ret nz

	ldh a, [hUsedSpriteIndex]
	call _DoesSpriteHaveFacings
	ret c

	ld a, [wSpriteFlags]
	bit 5, a
	ld a, h
	jr nz, .vram1
	add 4
.vram1
	add 4
	ld h, a
; fallthrough
.CopyToVram:
	ldh a, [rVBK]
	push af
	ld a, [wSpriteFlags]
	and 1 << 5
	swap a
	rra
	ldh [rVBK], a
; the follower's sprite is decompressed into wDecompressScratch (WRAMX)
	ldh a, [rSVBK]
	push af
	ld a, BANK(wDecompressScratch)
	ldh [rSVBK], a
	call Get2bpp
	pop af
	ldh [rSVBK], a
	pop af
	ldh [rVBK], a
	ret

.GetTileAddr:
; Return the address of tile (a) in (hl).
	and $7f
	swap a
	ld l, a
	and $f
	ld h, a
	xor l
	add LOW(vTiles0)
	ld l, a
	ld a, h
	adc HIGH(vTiles0)
	ld h, a
	ret

LoadEmote::
; Get the address of the pointer to emote c.
	ld a, c
	ld bc, EMOTE_LENGTH
	ld hl, Emotes
	rst AddNTimes
; Load the emote address into de
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
; load the length of the emote (in tiles) into c
	ld a, [hli]
	ld c, a
	swap c
; load the emote pointer bank into b
	ld a, [hli]
	ld b, a
; load the VRAM destination into hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
; if the emote has a length of 0, do not proceed (error handling)
	ld a, c
	and a
	ret z
	jmp Get2bpp

INCLUDE "data/sprites/emotes.asm"

INCLUDE "data/sprites/sprite_mons.asm"

INCLUDE "data/sprites/sprites.asm"
