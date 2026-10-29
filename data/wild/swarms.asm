; Swarms
; Each row says which mon swarms, in which form, where, and which encounters it replaces, and
; optionally an event flag the radio waits for before it offers the row, and a move every mon of
; the swarm knows. A row with a move but no flag passes SWARM_NO_GATE.
; Entries correspond to the SWARM_* constants and must stay in that order.
;
; Route 35 and Dark Cave Violet Entrance belong to the two vanilla swarms and host no others: Arnie's
; and Anthony's calls announce their swarm without checking it started, which is only safe because
; nothing else can already hold those maps.
;
; A swarm does not bring its own encounter table. It substitutes into the map's own slots
; (SWARM_GRASS_SLOTS / SWARM_WATER_SLOTS), keeping the level of whichever slot it displaces, so
; a swarm is route-appropriate wherever it is put and a row can be moved without retuning.

SwarmTable::
	table_width SWARM_ENTRY_LENGTH, SwarmTable
	swarm_def DUNSPARCE,  PLAIN_FORM,          DARK_CAVE_VIOLET_ENTRANCE,     SWARM_GRASS
	swarm_def YANMA,      PLAIN_FORM,          ROUTE_35,                      SWARM_GRASS

; From here on, the Collection Guild's radio station picks one row a day (DailySwarmBroadcast).
	; Johto
	; - Grass
	swarm_def MACHOP,     MACHOP_RB_FORM,      ROUTE_45,                      SWARM_GRASS
	swarm_def ZUBAT,      ZUBAT_RB_FORM,       UNION_CAVE_1F,                 SWARM_GRASS
	swarm_def GASTLY,     GASTLY_RB_FORM,      SPROUT_TOWER_2F,               SWARM_GRASS
	swarm_def KOFFING,    KOFFING_RB_FORM,     BURNED_TOWER_1F,               SWARM_GRASS
	; - Water
	swarm_def SHELLDER,   SHELLDER_RB_FORM,    ROUTE_40,                      SWARM_WATER
	swarm_def MAGIKARP,   MAGIKARP_RB_FORM,    LAKE_OF_RAGE,              	  SWARM_WATER
	swarm_def STARYU,     STARYU_RB_FORM,      CIANWOOD_CITY,	          SWARM_WATER

	; Kanto, post Elite Four
	; - Grass
	swarm_def JIGGLYPUFF, JIGGLYPUFF_RB_FORM,  ROUTE_3,                  	  SWARM_GRASS 
	swarm_def NIDORAN_M,  NIDORAN_M_RB_FORM,   ROUTE_2,                 	  SWARM_GRASS
	swarm_def NIDORAN_F,  NIDORAN_F_RB_FORM,   ROUTE_2,                  	  SWARM_GRASS
	swarm_def GEODUDE,    GEODUDE_RB_FORM,     ROCK_TUNNEL_1F,                SWARM_GRASS
	; - Water
	swarm_def PSYDUCK,    PSYDUCK_RB_FORM,     ROUTE_6,                       SWARM_WATER
	swarm_def TENTACOOL,  TENTACOOL_RB_FORM,   VERMILION_CITY,            	  SWARM_WATER
	swarm_def HORSEA,     HORSEA_RB_FORM,      ROUTE_12,                      SWARM_WATER

	; Team Rocket's, left behind as each operation falls. Offered once that part of the story is
	; over; each Rocket line swarms on one route only. Every one knows Thief.
	; - After the Mahogany hideout
	swarm_def GOLBAT,     GOLBAT_ROCKET_FORM,     ROUTE_42, SWARM_GRASS | SWARM_ROCKET, EVENT_CLEARED_ROCKET_HIDEOUT, THIEF
	swarm_def WEEZING,    WEEZING_ROCKET_FORM,    ROUTE_43, SWARM_GRASS | SWARM_ROCKET, EVENT_CLEARED_ROCKET_HIDEOUT, THIEF
	; - After the Radio Tower
	swarm_def CHARMELEON, CHARMELEON_ROCKET_FORM, ROUTE_37, SWARM_GRASS | SWARM_ROCKET, EVENT_CLEARED_RADIO_TOWER,    THIEF
	swarm_def ARBOK,      ARBOK_ROCKET_FORM,      ROUTE_39, SWARM_GRASS | SWARM_ROCKET, EVENT_CLEARED_RADIO_TOWER,    THIEF

	; Alternate-shiny swarms: a shiny here is an alternate shiny 4 times in 5 instead of 1 in 5.
	swarm_def SCYTHER,    PLAIN_FORM,             NATIONAL_PARK, SWARM_GRASS | SWARM_ALT_SHINY
	; - Below Blackthorn, once Clair is beaten
	swarm_def DRATINI,    PLAIN_FORM,             ROUTE_45, SWARM_WATER | SWARM_ALT_SHINY, EVENT_BEAT_CLAIR
	swarm_def MAGIKARP,   PLAIN_FORM,             LAKE_OF_RAGE, SWARM_WATER | SWARM_ALT_SHINY
	swarm_def MARILL,     PLAIN_FORM,             ROUTE_42, SWARM_GRASS | SWARM_ALT_SHINY


	assert_table_length NUM_SWARMS
