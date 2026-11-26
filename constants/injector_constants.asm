; Room the starter injector writes into: one of each per new species slot (NEW_MON_1 onward), in the
; bank its table needs. The plain build leaves it empty and points every slot at the shared
; placeholder; the injector fills a slot's room and repoints that slot's rows.
; Each size holds the game's own largest data of that kind, so every species in the game would fit.

; Pics are compressed literal-only: a 2-byte header per 512 bytes (Decompress reads at most 512 in
; one long command), then the $ff terminator.
DEF INJECTOR_FRONT_TILES EQU 165 ; unique tiles over every frame (Moltres's are the most)
DEF INJECTOR_FRONT_FRAMES EQU 10 ; the still pic and its animation frames
DEF INJECTOR_FRONT_ROOM EQU INJECTOR_FRONT_TILES * TILE_SIZE + 2 * ((INJECTOR_FRONT_TILES * TILE_SIZE + 511) / 512) + 1
DEF INJECTOR_BACK_ROOM EQU 6 * 6 * TILE_SIZE + 2 * ((6 * 6 * TILE_SIZE + 511) / 512) + 1

DEF INJECTOR_EVOLUTIONS EQU 6
DEF INJECTOR_LEVEL_UP_MOVES EQU 25
DEF INJECTOR_EGG_MOVES EQU 10
; up to 6 evolutions (the longest row is 6 bytes), 0, then (level, move) rows, 0
DEF INJECTOR_EVOS_ROOM EQU INJECTOR_EVOLUTIONS * 6 + 1 + INJECTOR_LEVEL_UP_MOVES * 3 + 1
DEF INJECTOR_EGG_MOVES_ROOM EQU (INJECTOR_EGG_MOVES + 1) * 2 ; then dw -1
; One existing species' evolutions and moves, rewritten with an extension's new evolutions added
DEF INJECTOR_EXTENSION_EVOS_ROOM EQU 96

DEF INJECTOR_ANIM_ROOM EQU 48
DEF INJECTOR_IDLE_ROOM EQU 32
DEF INJECTOR_BITMASK_ROOM EQU (INJECTOR_FRONT_FRAMES - 1) * (7 * 7 + 7) / 8
; a dw per animation frame, then each frame's bitmask number and the tiles it changes
DEF INJECTOR_FRAMES_ROOM EQU (INJECTOR_FRONT_FRAMES - 1) * (2 + 1 + 7 * 7)

; category and "@" (12), height and weight (4), two pages of three 18-character lines with their breaks
DEF INJECTOR_DEX_ENTRY_ROOM EQU 12 + 4 + 2 * 3 * (18 + 1)
DEF INJECTOR_ICON_ROOM EQU 8 * TILE_SIZE ; two 16x16 frames
DEF INJECTOR_CRY_ROOM EQU 192

assert NUM_CRIES - CRY_NEW_MON_1 == NUM_NEW_MONS, "a CRY_NEW_MON_* constant for each new species slot"
