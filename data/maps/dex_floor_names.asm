; Floors the Pokédex AREA page adds to a landmark name, to tell the floors of one place apart.
; Every map in the wild tables whose constant names a floor has a row (tests/test_data_pokedex.py).

MACRO dex_floor
;\1: map; \2: its floor
	map_id \1
	db \2, "@"
ENDM

PokedexAreaFloors:
	dex_floor SPROUT_TOWER_2F,              "2F"
	dex_floor SPROUT_TOWER_3F,              "3F"
	dex_floor TIN_TOWER_2F,                 "2F"
	dex_floor TIN_TOWER_3F,                 "3F"
	dex_floor TIN_TOWER_4F,                 "4F"
	dex_floor TIN_TOWER_5F,                 "5F"
	dex_floor TIN_TOWER_6F,                 "6F"
	dex_floor TIN_TOWER_7F,                 "7F"
	dex_floor TIN_TOWER_8F,                 "8F"
	dex_floor TIN_TOWER_9F,                 "9F"
	dex_floor BURNED_TOWER_1F,              "1F"
	dex_floor BURNED_TOWER_B1F,             "B1F"
	dex_floor UNION_CAVE_1F,                "1F"
	dex_floor UNION_CAVE_B1F,               "B1F"
	dex_floor UNION_CAVE_B2F,               "B2F"
	dex_floor SLOWPOKE_WELL_B1F,            "B1F"
	dex_floor SLOWPOKE_WELL_B2F,            "B2F"
	dex_floor MOUNT_MORTAR_1F_OUTSIDE,      "1F"
	dex_floor MOUNT_MORTAR_1F_INSIDE,       "1F"
	dex_floor MOUNT_MORTAR_2F_INSIDE,       "2F"
	dex_floor MOUNT_MORTAR_B1F,             "B1F"
	dex_floor ICE_PATH_1F,                  "1F"
	dex_floor ICE_PATH_B1F,                 "B1F"
	dex_floor ICE_PATH_B2F_MAHOGANY_SIDE,   "B2F"
	dex_floor ICE_PATH_B2F_BLACKTHORN_SIDE, "B2F"
	dex_floor ICE_PATH_B3F,                 "B3F"
	dex_floor WHIRL_ISLAND_B1F,             "B1F"
	dex_floor WHIRL_ISLAND_B2F,             "B2F"
	dex_floor DRAGONS_DEN_B1F,              "B1F"
	dex_floor ROCK_TUNNEL_1F,               "1F"
	dex_floor ROCK_TUNNEL_B1F,              "B1F"
	dex_floor CERULEAN_CAVE_1F,             "1F"
	dex_floor CERULEAN_CAVE_2F,             "2F"
	dex_floor CERULEAN_CAVE_B1F,            "B1F"
	db 0 ; end
