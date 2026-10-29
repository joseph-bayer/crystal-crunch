if DEF(_DEBUG)

; Sweep only the species that have cosmetic forms, every form of each, instead of walking the
; dex. Every mon stored then exercises the form path -- what to reach for when checking whether a
; problem is form-related rather than volume-related.
DEF FILL_PC_FORM_SPECIES_ONLY EQU 0

; Stop after this many mons, whichever mode is running, or 0 for no limit. Useful for keeping a
; sweep inside one box, or one past it, to separate "breaks on forms" from "breaks on a second
; box". The budget lives in a single register, so it cannot exceed a byte -- a full-dex sweep is
; 281 mons and has to run uncapped rather than with a cap that would silently wrap.
DEF FILL_PC_MAX_MONS EQU 0
assert FILL_PC_MAX_MONS < $100, "the mon budget is kept in one register; use 0 for no limit"

; Unown's 26 letters differ in shape, not color -- Unown has no entry in
; CosmeticFormPalettePointersTable, so every letter reads the same two colors. For reviewing
; palettes they are 25 identical slots, and PlayersHouse2F records that gifting Unown before the
; Ruins of Alph puzzle is done can crash. So the sweep leaves them out. Set this to 1 to get all
; 26 when testing icon *graphics* rather than colors.
DEF FILL_PC_ALL_UNOWN_LETTERS EQU 0

; The span of the dex to sweep, inclusive, when FILL_PC_FORM_SPECIES_ONLY is off.
DEF FILL_PC_FIRST_SPECIES EQU 1
DEF FILL_PC_LAST_SPECIES  EQU NUM_POKEMON
assert FILL_PC_FIRST_SPECIES >= 1, "the sweep range starts at species index 1"
assert FILL_PC_LAST_SPECIES <= NUM_POKEMON, "the sweep range ends at NUM_POKEMON"

; Give each species every cosmetic form rather than only its default. Ignored when
; FILL_PC_FORM_SPECIES_ONLY is on, since the forms are the whole point of that mode.
DEF FILL_PC_INCLUDE_FORMS EQU 1

FillPCWithEveryForm::
; Put mons into the PC in order, so their icon and follower palettes can be reviewed side by
; side. Reach it with
;   callasm FillPCWithEveryForm
; from a debug script. What it sweeps depends on the switches above.
;
; These go straight into the boxes regardless of how full the party is. The PC holds
; NUM_BOXES * MONS_PER_BOX = 360 mons across MONDB_ENTRIES * 2 = 370 database entries, but the
; allocator rescans the database for every mon and falls back to FlushStorageSystem when it runs
; short, so a large sweep is slow rather than instant.
;
; It calls SendMonIntoBox rather than GivePoke, which would print "was sent to BILL's PC" and
; offer a nickname prompt for every one of them. That also means no gift shiny roll, so the
; sweep is a clean set of normal colors. After it come the species with an alternate shiny, every
; form of each as an ordinary shiny and then its alternate.
	call .Sweep
	jr .AltShinies

.Sweep:
if FILL_PC_MAX_MONS
	ld b, FILL_PC_MAX_MONS ; b is the budget throughout, and survives .StoreOne on the stack
endc
if FILL_PC_FORM_SPECIES_ONLY
	ld hl, .FormCounts
.species_loop
	ld a, [hli]
	ld d, a ; species index; NUM_POKEMON fits in a byte, so the high byte is always zero
	inc hl
	and a
	ret z ; the terminator
	ld a, [hli]
	ld c, a ; c = how many forms this species has

	ld e, 0
.form_loop
	push hl
	push bc
	call .StoreOne
	pop bc
	pop hl
	ret nc ; the storage system is full
if FILL_PC_MAX_MONS
	dec b
	ret z ; the budget is spent
endc

	inc e
	ld a, c
	cp e
	jr nz, .form_loop
	jr .species_loop

else
	ld d, FILL_PC_FIRST_SPECIES
.species_loop
if !FILL_PC_ALL_UNOWN_LETTERS
	ld a, d
	cp LOW(UNOWN) ; PlayersHouse2F records that storing Unown this early can crash
	jr z, .next_species
endc
	call .HasAltShiny
	jr c, .next_species ; it comes after the sweep, with its shinies
	ld e, 0
.form_loop
	call .IsLookAlike
	jr c, .next_form
	push bc
	call .StoreOne
	pop bc
	ret nc ; the storage system is full
if FILL_PC_MAX_MONS
	dec b
	ret z ; the budget is spent
endc

.next_form
	push bc
	ld l, d
	ld h, 0
	call .GetFormCount
	pop bc
	inc e
	cp e
	jr nz, .form_loop

.next_species
	inc d
	ld a, d
	cp FILL_PC_LAST_SPECIES + 1
	jr nz, .species_loop
	ret
endc

.AltShinies:
; After the sweep, every form of each species with an alternate shiny, in its normal colors, as an
; ordinary shiny and as its alternate, side by side.
	ld hl, AltShinyPalettes
.alt_loop
	push hl
	ld a, BANK(AltShinyPalettes)
	call GetFarWord
	ld a, h
	or l
	ld d, l ; species index; NUM_POKEMON fits in a byte
	pop hl
	ret z ; the end
	push hl
	ld l, d
	ld h, 0
	call .LookUpFormCount
	ld e, 0
.alt_form_loop
	push af ; the form count
	push de
	call .StoreOne
	ld a, e
	or SHINY_MASK
	ld e, a
	call .StoreOne
	ld a, e
	or ALT_SHINY_MASK
	ld e, a
	call .StoreOne
	pop de
	pop af
	inc e
	cp e
	jr nz, .alt_form_loop
	pop hl
	ld bc, 2 + 2 * COLOR_SIZE ; past this row's species and two colors
	add hl, bc
	jr .alt_loop

.HasAltShiny:
; in: d = species index. out: carry if it has an alternate shiny. Preserves bc and de.
	push bc
	ld hl, AltShinyPalettes
.has_alt_loop
	push hl
	ld a, BANK(AltShinyPalettes)
	call GetFarWord
	ld a, h
	or l
	jr z, .no_alt ; the end
	ld a, l
	cp d ; NUM_POKEMON fits in a byte, so the high byte is always zero
	jr z, .has_alt
	pop hl
	ld bc, 2 + 2 * COLOR_SIZE ; past this row's species and two colors
	add hl, bc
	jr .has_alt_loop

.has_alt
	pop hl
	pop bc
	scf
	ret

.no_alt
	pop hl
	pop bc
	ret ; `or l` has cleared carry

.IsLookAlike:
; in: d = species index, e = form. out: carry if the sweep leaves this form out. Preserves bc and de.
	push hl
	ld hl, .LookAlikeForms
.look_alike_loop
	ld a, [hli]
	and a
	jr z, .not_look_alike ; the end; `and a` has cleared carry
	inc hl ; NUM_POKEMON fits in a byte, so the high byte is always zero
	cp d
	ld a, [hli] ; the form
	jr nz, .look_alike_loop
	cp e
	jr nz, .look_alike_loop
	scf
.not_look_alike
	pop hl
	ret

.LookAlikeForms:
; Forms that look like the plain one and only carry a number for an evolution, so the sweep's
; boxes aren't spent on duplicates.
	dwb ZUBAT,   ZUBAT_UNUSED_FORM
	dwb KOFFING, KOFFING_UNUSED_FORM
	dw 0

.StoreOne:
; in: d = species index, e = cosmetic form. Returns carry if the mon was stored. Preserves de.
	push de
	ld l, d
	ld h, 0
	call GetPokemonIDFromIndex ; hl = index, out a = the 8-bit handle the box wants
	ld [wCurPartySpecies], a
	ld [wTempEnemyMonSpecies], a
	xor a
	ld [wMonType], a ; PARTYMON, the state GivePoke builds a mon in
	ld [wCurItem], a
	ld a, 5
	ld [wCurPartyLevel], a
	pop de

	push de
	farcall LoadEnemyMon ; SendMonIntoBox builds the box mon out of wEnemyMon
	pop de

; SendMonIntoBox takes the stored form from wEnemyMonForm, so set it here rather than correcting
; it afterwards. Re-running UpdateStorageBoxMonFromTemp to fix the form would erase and reallocate
; the database entry SendMonIntoBox just made. This is also the fix for a gifted Unown's wrong
; letter -- GivePoke stamps wForm after the fact and hits exactly that problem.
	push de
	ld a, e
	ld [wEnemyMonForm], a
	farcall SendMonIntoBox
	pop de
	ret

if !FILL_PC_FORM_SPECIES_ONLY
.GetFormCount:
; in: hl = species index. out: a = how many forms to sweep, at least 1. Preserves de.
if !FILL_PC_INCLUDE_FORMS
	ld a, 1
	ret
endc
	; fallthrough
endc

.LookUpFormCount:
; in: hl = species index. out: a = how many forms it has, at least 1. Preserves de.
; Every other per-form table is indexed by species and says nothing about its own length, so the
; counts live here rather than being derived from one of them.
	push de
	ld de, .FormCounts
.lookup_loop
	ld a, [de]
	inc de
	ld c, a
	ld a, [de]
	inc de
	ld b, a
	or c
	jr z, .no_forms ; the terminator
	ld a, c
	cp l
	jr nz, .next_entry
	ld a, b
	cp h
	jr nz, .next_entry
	ld a, [de]
	pop de
	ret

.next_entry
	inc de ; step over the count
	jr .lookup_loop

.no_forms
	ld a, 1
	pop de
	ret

.FormCounts:
; Ordered so a six-box budget still reaches every species here. Magikarp leads because it is
; the one species LoadEnemyMon has a form branch for -- a DV reroll loop that jumps backwards --
; so if the sweep is going to die on a form, it dies first. Smeargle trails because it has the
; most forms and is the one worth truncating.
	dwb MAGIKARP,   NUM_MAGIKARP_FORMS   ; 4, running total 4
	dwb PIKACHU,    NUM_PIKACHU_FORMS    ; 4, running total 8
	dwb SCYTHER,    NUM_SCYTHER_FORMS    ; 3, running total 11
	dwb SCIZOR,     NUM_SCIZOR_FORMS     ; 3, running total 14
	dwb PINSIR,     NUM_PINSIR_FORMS     ; 3, running total 17
	dwb SHUCKLE,    NUM_SHUCKLE_FORMS    ; 3, running total 20
	dwb CHARMELEON, NUM_CHARMELEON_FORMS ; 2, running total 22
	dwb CHARIZARD,  NUM_CHARIZARD_FORMS  ; 2, running total 24
	dwb ARBOK,      NUM_ARBOK_FORMS      ; 2, running total 26
	dwb GOLBAT,     NUM_GOLBAT_FORMS     ; 3, running total 29
	dwb MACHOP,     NUM_MACHOP_FORMS     ; 2, running total 31
	dwb MACHOKE,    NUM_MACHOKE_FORMS    ; 2, running total 33
	dwb MACHAMP,    NUM_MACHAMP_FORMS    ; 2, running total 35
	dwb TENTACOOL,  NUM_TENTACOOL_FORMS  ; 2, running total 37
	dwb TENTACRUEL, NUM_TENTACRUEL_FORMS ; 2, running total 39
	dwb ELECTRODE,  NUM_ELECTRODE_FORMS  ; 2, running total 41
	dwb WEEZING,    NUM_WEEZING_FORMS    ; 3, running total 44
	dwb SNORLAX,    NUM_SNORLAX_FORMS    ; 2, running total 46
	dwb CROBAT,     NUM_CROBAT_FORMS     ; 3, running total 49
	dwb IGGLYBUFF,  NUM_IGGLYBUFF_FORMS  ; 2, running total 51
	dwb JIGGLYPUFF, NUM_JIGGLYPUFF_FORMS ; 2, running total 53
	dwb WIGGLYTUFF, NUM_WIGGLYTUFF_FORMS ; 2, running total 55
	dwb NIDORAN_M,  NUM_NIDORAN_M_FORMS  ; 2, running total 57
	dwb NIDORINO,   NUM_NIDORINO_FORMS   ; 2, running total 59
	dwb NIDOKING,   NUM_NIDOKING_FORMS   ; 2, running total 61
	dwb NIDORAN_F,  NUM_NIDORAN_F_FORMS  ; 2, running total 63
	dwb NIDORINA,   NUM_NIDORINA_FORMS   ; 2, running total 65
	dwb NIDOQUEEN,  NUM_NIDOQUEEN_FORMS  ; 2, running total 67
	dwb ZUBAT,      NUM_ZUBAT_FORMS      ; 3, running total 70
	dwb GEODUDE,    NUM_GEODUDE_FORMS    ; 2, running total 72
	dwb GRAVELER,   NUM_GRAVELER_FORMS   ; 2, running total 74
	dwb GOLEM,      NUM_GOLEM_FORMS      ; 2, running total 76
	dwb SHELLDER,   NUM_SHELLDER_FORMS   ; 2, running total 78
	dwb CLOYSTER,   NUM_CLOYSTER_FORMS   ; 2, running total 80
	dwb GASTLY,     NUM_GASTLY_FORMS     ; 2, running total 82
	dwb HAUNTER,    NUM_HAUNTER_FORMS    ; 2, running total 84
	dwb GENGAR,     NUM_GENGAR_FORMS     ; 2, running total 86
	dwb KOFFING,    NUM_KOFFING_FORMS    ; 3, running total 89
	dwb HORSEA,     NUM_HORSEA_FORMS     ; 2, running total 91
	dwb SEADRA,     NUM_SEADRA_FORMS     ; 2, running total 93
	dwb KINGDRA,    NUM_KINGDRA_FORMS    ; 2, running total 95
	dwb PSYDUCK,    NUM_PSYDUCK_FORMS    ; 2, running total 97
	dwb GOLDUCK,    NUM_GOLDUCK_FORMS    ; 2, running total 99
	dwb GYARADOS,   NUM_GYARADOS_FORMS   ; 4, running total 103
	dwb STARYU,     NUM_STARYU_FORMS     ; 2, running total 105
	dwb STARMIE,    NUM_STARMIE_FORMS    ; 2, running total 107
	dwb PICHU,      NUM_PICHU_FORMS      ; 4, running total 111
	dwb RAICHU,     NUM_RAICHU_FORMS     ; 4, running total 115
	dwb SMEARGLE,   NUM_SMEARGLE_FORMS   ; 6, running total 121
if FILL_PC_ALL_UNOWN_LETTERS
	dwb UNOWN,    NUM_UNOWN
endc
	dw 0

GiveDebugDolls::
; Unlock the Pokemon dolls whose species have cosmetic forms, so the doll objects in the player's
; room can be used to see what form a SPRITE_POKEMON map object actually draws. Reach it with
;   callasm GiveDebugDolls
; then place one from the PC's Decoration menu -- it resolves through SPRITE_DOLL_1 / SPRITE_DOLL_2
; into the SpriteMons entry for that species.
;
; The test: make a Pikachu with a cosmetic form your follower, then look at the Pikachu doll. The
; map object path leaves wForm alone, so if the doll comes out surfing or flying rather than plain,
; the follower's form byte leaked into it.
	ld hl, .Flags
.loop
	ld a, [hli]
	cp -1
	ret z
	ld c, a
	push hl
	farcall SetSpecificDecorationFlag
	pop hl
	jr .loop

.Flags:
	db DECOFLAG_PIKACHU_DOLL      ; four forms, and the plain icon is unmistakable
	db DECOFLAG_SURF_PIKACHU_DOLL ; its own sprite, not a SpriteMons entry -- the control
	db DECOFLAG_MAGIKARP_DOLL     ; three size forms
	db DECOFLAG_UNOWN_DOLL        ; 26 letters, so any leak is obvious
	db -1

DebugEmptyParty::
; Empty the party so a debug script can givepoke a fresh one into slots 1 onward. The follower
; points at slot 1, so whatever lands there walks behind the player.
	xor a
	ld [wPartyCount], a
	dec a
	ld [wPartySpecies], a ; the list's terminator
	ld a, 1
	ld [wFollowerPartySlot], a
	ret

endc
