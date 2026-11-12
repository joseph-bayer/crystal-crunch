; Overworld wild Pokemon: the mon that wander a route and start a *wild* battle when you step
; beside them. See docs/plan_overworld_wild_mon.md.

; wOverworldMonEncounters entries.
; The whole encounter -- species, form, shininess, level, DVs, held item -- is rolled once when the
; map is entered, and the battle reads it back instead of rolling again. That is the point of the
; struct: without it the overworld sprite and the battle roll separately and disagree, and a mon
; that looked ordinary in the grass turns up shiny once the battle starts.
rsreset
DEF OW_MON_SPECIES rw ; 0 ; a 16-bit index; 0 means the slot is empty
DEF OW_MON_FORM    rb ; 2 ; a cosmetic form, optionally | SHINY_MASK
DEF OW_MON_LEVEL   rb ; 3
DEF OW_MON_DVS     rw ; 4
DEF OW_MON_ITEM    rb ; 6 ; an 8-bit item ID
DEF OW_MON_PERKS   rb ; 7 ; OW_PERK_* flags, kept so a perk can still act during the battle
; A 16-bit move *index*, not an 8-bit ID: IDs are handed out from a recycled table and can be
; evicted between the roll and the battle, and the roll can be minutes old.
DEF OW_MON_MOVE    rw ; 8 ; NO_MOVE for none
DEF OW_MON_ENCOUNTER_LENGTH EQU _RS

; How close you have to get. Zero means the same tile: you walk *onto* one rather than up to it,
; which is why they do not block the player.
;
; It was 1, and that read badly. An object's map coordinates update when its step begins, not when
; the sprite arrives, so a wandering mon setting off towards you counted as adjacent while it was
; still visibly a tile away, and the battle started before it had moved. Standing on the tile has
; no such gap -- the player's own step has finished by the time the check runs.
DEF OW_MON_TRIGGER_DISTANCE EQU 0

; Per-entry perks, set in the area tables.
; shift_const, so each perk gets both a value for the tables (1, 2, 4, ...) and a matching _F bit
; number for the code. A plain 1, 2, 3 enumeration reads fine in the data and is a trap in the
; engine: `bit OW_PERK_EXTRA_SHINY, a` against value 2 tests bit 2, which is never the bit that
; was set, so the perk silently never fires and every mon rolls the ordinary odds.
	const_def
	shift_const OW_PERK_ALWAYS_ITEM ; skip the held item roll and always hold one
	shift_const OW_PERK_EXTRA_SHINY ; a better shiny rate again, on top of the one they all get

; Area tables (see data/wild/overworld_mons.asm). Fixed width, like the grass tables, so a time of
; day can be indexed rather than walked.
DEF NUM_OW_WILDMON EQU 4 ; choices per time of day
rsreset
DEF OW_WILDMON_WEIGHT  rb ; 0 ; out of 100 within its time of day
DEF OW_WILDMON_SPECIES rw ; 1
DEF OW_WILDMON_LEVEL   rb ; 3
DEF OW_WILDMON_FORM    rb ; 4
DEF OW_WILDMON_PERKS   rb ; 5
DEF OW_WILDMON_MOVE    rw ; 6 ; an extra move it always knows, or NO_MOVE
DEF OW_WILDMON_LENGTH EQU _RS

; map id, how many can be out at once, the chance each one shows up, then morn/day/nite rosters
DEF OW_WILDDATA_LENGTH EQU 2 + 1 + 1 + NUM_OW_WILDMON * OW_WILDMON_LENGTH * 3

; wOverworldMonRollFromSwarm for a population's member. Any other nonzero value is a swarm's row
; bit, so this has to sit above every one of those.
DEF OW_ROLL_FROM_POPULATION EQU $80
assert OW_ROLL_FROM_POPULATION >= 1 << NUM_OW_WILDMON, "OW_ROLL_FROM_POPULATION overlaps a swarm row bit"

; Remembered shinies (wRememberedShinies): the last few shinies the route rosters rolled, newest
; first. Each one comes back to its slot whenever its map is entered, until it is battled, so
; leaving a route doesn't lose it. The list is saved, so an entry keeps only what a later visit
; can't rebuild from the roster: where the mon came from, and its DVs. See
; docs/overworld_pokemon.md.
DEF NUM_REMEMBERED_SHINIES EQU 5
rsreset
DEF REMEMBERED_SHINY_MAP_GROUP  rb ; 0 ; 0 for an unused entry
DEF REMEMBERED_SHINY_MAP_NUMBER rb ; 1
DEF REMEMBERED_SHINY_RECIPE     rb ; 2 ; see below
DEF REMEMBERED_SHINY_DVS        rw ; 3
DEF REMEMBERED_SHINY_LENGTH EQU _RS

; The recipe byte: the slot, and the roster row it was rolled from. The row and the time of day's
; roster sit side by side, so that the two together are the row's place in the area table.
DEF REMEMBERED_SLOT_MASK    EQU %00000011 ; the 0-based slot
DEF REMEMBERED_WATER_F      EQU 2         ; set for the water table, clear for the grass one
DEF REMEMBERED_ROW_SHIFT    EQU 3
DEF REMEMBERED_ROW_MASK     EQU %00011000 ; the row within its roster, 0 to NUM_OW_WILDMON - 1
DEF REMEMBERED_ROSTER_SHIFT EQU 5
DEF REMEMBERED_ROSTER_MASK  EQU %01100000 ; MORN_F, DAY_F or NITE_F (evening shares the night's)
DEF REMEMBERED_ALT_SHINY_F  EQU 7         ; an alternate shiny
assert NUM_OW_WILDMON == 1 << (REMEMBERED_ROSTER_SHIFT - REMEMBERED_ROW_SHIFT), \
	"the recipe's row field has to be exactly one roster wide"

DEF REMEMBERED_SHINIES_SAVE_MAGIC EQU $5e7a ; marks a saved copy of the list; anything else loads as none


; Populations (see data/wild/mon_populations.asm and docs/overworld_pokemon.md). A standing
; group of wandering mon on a few special maps, which reshuffles when you battle one rather than
; when you leave. A map has a population or an area roster, never both.
;
; The mode says what a battle rerolls. POP_REROLL_STATS also means one species per visit: the
; whole population is that species until you leave.
	const_def
	const POP_REROLL_SPECIES ; every member draws a new species after a battle
	const POP_REROLL_STATS   ; every member keeps its species and draws new DVs, shininess, item, form

DEF NUM_POP_MON EQU 10     ; the most entries a roster can hold; short ones are padded
DEF MAX_SPAWN_AREAS EQU 8  ; rectangles a member may be placed in; none listed means the whole map

; weight, species, level range, form, perks -- the route tables' columns plus the contest's level
; range, and no extra-move column. Weights are out of 100 like the route tables.
rsreset
DEF POP_MON_WEIGHT    rb ; 0
DEF POP_MON_SPECIES   rw ; 1 ; a 16-bit index; 0 ends the roster early
DEF POP_MON_MIN_LEVEL rb ; 3
DEF POP_MON_MAX_LEVEL rb ; 4
DEF POP_MON_FORM      rb ; 5
DEF POP_MON_PERKS     rb ; 6 ; OW_PERK_* flags, or 0; the engine adds none of its own
DEF POP_MON_LENGTH EQU _RS

; In a pop_mon form column: not a form, but "roll one the way a grass encounter does", from
; WildFormTable in the battle core. A species with no entry there comes out plain. Bit 6 is free
; between FORM_MASK and SHINY_MASK, so this cannot be mistaken for either.
DEF POP_WILD_FORM_F EQU 6
DEF POP_WILD_FORM EQU 1 << POP_WILD_FORM_F

DEF SPAWN_AREA_LENGTH EQU 4 ; x1, y1, x2, y2 in map tiles, inclusive; all zero when unused

; Placement. How many tiles to try before leaving a member on its object_event tile -- bounded,
; never a search, so a map with nowhere valid to stand cannot spin with the LCD off. And how close
; to the player a member may land: none within this many tiles either way. Members wander with
; NOCLIP, and one placed adjacent walks onto you before you have taken a step.
DEF POP_PLACE_TRIES EQU 32
DEF POP_PLAYER_MARGIN EQU 2

; map id, mode, how many are out at once, the spawn areas, then the roster
DEF POP_DATA_LENGTH EQU 2 + 1 + 1 + MAX_SPAWN_AREAS * SPAWN_AREA_LENGTH + NUM_POP_MON * POP_MON_LENGTH
