FishGroupNames:
; entries correspond to FISHGROUP_* constants; the Pokédex AREA page shows these
	table_width 2
	dw .Shore
	dw .Ocean
	dw .Lake
	dw .Pond
	dw .Dratini
	dw .QwilfishSwarm
	dw .Gyarados
	dw .Dratini2
	dw .WhirlIslands
	dw .Qwilfish
	assert_table_length NUM_FISHGROUPS

.Shore:         db "SHORE@"
.Ocean:         db "OCEAN@"
.Lake:          db "LAKE@"
.Pond:          db "POND@"
.Dratini:       db "DRATINI@"
.QwilfishSwarm: db "SWARM@"
.Gyarados:      db "GYARADOS@"
.Dratini2:      db "ROUTE 45@"
.WhirlIslands:  db "WHIRL@"
.Qwilfish:      db "QWILFISH@"
