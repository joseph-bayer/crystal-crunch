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

; Remembered shinies (wRememberedShinies): the last few shinies the wandering mon rolled -- a
; route's own, a swarm's or a population's -- newest first. Each one comes back to its slot
; whenever its map is entered or reshuffled, until it is battled. The list is saved, so an entry
; keeps only where the mon came from: which table, and which row of it. Everything else is rebuilt
; from that row, and the DVs are rolled again. See docs/overworld_pokemon.md.
DEF NUM_REMEMBERED_SHINIES EQU 5
rsreset
DEF REMEMBERED_SHINY_MAP_GROUP  rb ; 0 ; 0 for an unused entry
DEF REMEMBERED_SHINY_MAP_NUMBER rb ; 1
DEF REMEMBERED_SHINY_SOURCE     rb ; 2 ; the slot, the kind, alt shiny, and the kind's high bits
DEF REMEMBERED_SHINY_INDEX      rb ; 3 ; the kind's low bits
DEF REMEMBERED_SHINY_LENGTH EQU _RS

; The source byte.
DEF REMEMBERED_SLOT_MASK   EQU %00000011 ; the 0-based slot
DEF REMEMBERED_KIND_SHIFT  EQU 2
DEF REMEMBERED_KIND_MASK   EQU %00001100 ; one of the REMEMBERED_* kinds below
DEF REMEMBERED_ALT_SHINY_F EQU 4         ; an alternate shiny
DEF REMEMBERED_HIGH_SHIFT  EQU 5
DEF REMEMBERED_HIGH_MASK   EQU %11100000 ; the kind's own high bits

; What each kind keeps, in the index byte and the source byte's high bits:
; - A route's grass or water roster: index = time-of-day roster * NUM_OW_WILDMON + row, the row's
;   place in the area table. The high bits are unused.
; - A swarm: index = the low 8 bits of its SWARM_* id; high bit 0 = the id's bit 8; high bits 1-2 =
;   the time-of-day roster it rolled from, whose heaviest row gives the level.
; - A population: index bits 0-4 = the form number it rolled (a wild colour, an Unown letter);
;   index bits 5-7 = its pop_mon row's low 3 bits; the high bits = that row's high 3 bits.
	const_def
	const REMEMBERED_ROUTE_GRASS ; 0
	const REMEMBERED_ROUTE_WATER ; 1
	const REMEMBERED_SWARM       ; 2
	const REMEMBERED_POPULATION  ; 3
assert const_value <= 1 << (REMEMBERED_ALT_SHINY_F - REMEMBERED_KIND_SHIFT), "too many remembered kinds"
DEF REMEMBERED_SWARM_ID_HIGH_F   EQU REMEMBERED_HIGH_SHIFT     ; the swarm id's bit 8
DEF REMEMBERED_SWARM_ROSTER_SHIFT EQU REMEMBERED_HIGH_SHIFT + 1
DEF REMEMBERED_SWARM_ROSTER_MASK EQU %11000000
DEF REMEMBERED_POP_ROW_LOW_SHIFT EQU 5
DEF REMEMBERED_POP_FORM_MASK     EQU %00011111
DEF MAX_REMEMBERED_SWARM_ID      EQU (1 << 9) - 1
DEF MAX_REMEMBERED_POP_ROWS      EQU 1 << 6

DEF REMEMBERED_SHINIES_SAVE_MAGIC EQU $5e7b ; marks a saved copy of the list; anything else loads as none


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
