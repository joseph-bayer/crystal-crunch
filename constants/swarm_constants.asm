; Swarms
; One row of SwarmTable (data/wild/swarms.asm) per constant, in the same order.
;
; The ids are 1-based because wActiveSwarms stores them directly and uses 0 for an empty slot.

; Which encounters a swarm replaces. A grass swarm never touches a map's surf slots or its
; swimming overworld mon, and a water swarm never touches its grass ones. Fishing is a separate
; mechanism (wFishingSwarmFlag) and is not swarmed either way.
	const_def
	const SWARM_GRASS ; 0
	const SWARM_WATER ; 1
DEF SWARM_TERRAIN_MASK EQU %00000001
; OR'd into a row's terrain: Team Rocket's mon, left behind when a Rocket operation fell. The
; radio announces these with their own lines. Anything reading the terrain masks this off.
DEF SWARM_ROCKET_F EQU 7
DEF SWARM_ROCKET EQU 1 << SWARM_ROCKET_F
	assert !(SWARM_ROCKET & SWARM_TERRAIN_MASK), "SWARM_ROCKET overlaps the terrain"
; OR'd into a row's terrain: its shinies are alternate shinies SWARM_ALT_SHINY_NUMERATOR times in
; ALT_SHINY_DENOMINATOR instead of ALT_SHINY_NUMERATOR.
DEF SWARM_ALT_SHINY_F EQU 6
DEF SWARM_ALT_SHINY EQU 1 << SWARM_ALT_SHINY_F
	assert !(SWARM_ALT_SHINY & (SWARM_TERRAIN_MASK | SWARM_ROCKET)), "SWARM_ALT_SHINY overlaps another terrain bit"

; A row's story gate when it has none (event flag 0 is a real flag)
DEF SWARM_NO_GATE EQU -1

	const_def 1
; The two vanilla swarms, kept because their phone calls still start them. They are enumerated
; first so that FIRST_STUDIED_SWARM can exclude them from the Collection Guild's milestones
; without a flag on every row.
	const SWARM_DUNSPARCE ; 1
	const SWARM_YANMA     ; 2
DEF FIRST_STUDIED_SWARM EQU const_value
; Everything below counts towards the Guild. Append only -- the Guild's record is a bitfield
; indexed by these ids, so inserting a row would shift every later player's progress.
	const SWARM_MACHOP_RB     ; 3
	const SWARM_ZUBAT_RB      ; 4
	const SWARM_GASTLY_RB     ; 5
	const SWARM_KOFFING_RB    ; 6
	const SWARM_SHELLDER_RB   ; 7
	const SWARM_MAGIKARP_RB   ; 8
	const SWARM_STARYU_RB     ; 9
	const SWARM_JIGGLYPUFF_RB ; 10
	const SWARM_NIDORAN_M_RB  ; 11
	const SWARM_NIDORAN_F_RB  ; 12
	const SWARM_GEODUDE_RB    ; 13
	const SWARM_PSYDUCK_RB    ; 14
	const SWARM_TENTACOOL_RB  ; 15
	const SWARM_HORSEA_RB     ; 16
	const SWARM_GOLBAT_ROCKET     ; 17
	const SWARM_WEEZING_ROCKET    ; 18
	const SWARM_CHARMELEON_ROCKET ; 19
	const SWARM_ARBOK_ROCKET      ; 20
	const SWARM_SCYTHER_ALT_SHINY ; 21
	const SWARM_DRATINI_ALT_SHINY ; 22
	const SWARM_MAGIKARP_ALT_SHINY ; 23
	const SWARM_MARILL_ALT_SHINY ; 24
DEF NUM_SWARMS EQU const_value - 1

DEF MAX_ACTIVE_SWARMS EQU 3 ; Arnie's call, Anthony's call, and the radio's daily roll

; How much of a swarming map's encounters the swarm takes. It substitutes into the map's own
; slots rather than bringing a table of its own, and those slots have fixed odds (see
; data/wild/probabilities.asm), so the rate is expressed as which slots it takes. The assert
; beside each probability table checks the masks still add up to this if either is retuned.
; For comparison: the vanilla Dunsparce swarm was 40%, and Yanma's 30%.
DEF SWARM_ENCOUNTER_RATE EQU 60 ; percent
DEF SWARM_GRASS_SLOTS EQU %00000011 ; slots 0-1, 30% + 30%
DEF SWARM_WATER_SLOTS EQU %00000001 ; slot 0, 60%

; Set to TRUE to make every swarm mon shiny in a _DEBUG build, grass and overworld alike. Only
; the swarm's own mon are affected, so the route's other mon double as a control.
DEF SWARM_DEBUG_FORCE_SHINY EQU FALSE

; After a battle against a swarm's wandering mon, a rerolled mon that would respawn within this
; many tiles of the player is left out of that reload. 0 is the player's own tile, which is all
; the instant-battle hazard needs -- a battle only starts from the same tile
; (OW_MON_TRIGGER_DISTANCE). Wider would often suppress the very mon you just fought, since it
; had wandered close to its own spawn point.
DEF SWARM_RESPAWN_MARGIN EQU 0
