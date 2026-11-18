SECTION "Evolutions and Attacks 2", ROMX

EvosAttacksPointers2::
	dw ChikoritaEvosAttacks
	dw BayleefEvosAttacks
	dw MeganiumEvosAttacks
	dw CyndaquilEvosAttacks
	dw QuilavaEvosAttacks
	dw TyphlosionEvosAttacks
	dw TotodileEvosAttacks
	dw CroconawEvosAttacks
	dw FeraligatrEvosAttacks
	dw SentretEvosAttacks
	dw FurretEvosAttacks
	dw HoothootEvosAttacks
	dw NoctowlEvosAttacks
	dw LedybaEvosAttacks
	dw LedianEvosAttacks
	dw SpinarakEvosAttacks
	dw AriadosEvosAttacks
	dw CrobatEvosAttacks
	dw ChinchouEvosAttacks
	dw LanturnEvosAttacks
	dw PichuEvosAttacks
	dw CleffaEvosAttacks
	dw IgglybuffEvosAttacks
	dw TogepiEvosAttacks
	dw TogeticEvosAttacks
	dw NatuEvosAttacks
	dw XatuEvosAttacks
	dw MareepEvosAttacks
	dw FlaaffyEvosAttacks
	dw AmpharosEvosAttacks
	dw BellossomEvosAttacks
	dw MarillEvosAttacks
	dw AzumarillEvosAttacks
	dw SudowoodoEvosAttacks
	dw PolitoedEvosAttacks
	dw HoppipEvosAttacks
	dw SkiploomEvosAttacks
	dw JumpluffEvosAttacks
	dw AipomEvosAttacks
	dw SunkernEvosAttacks
	dw SunfloraEvosAttacks
	dw YanmaEvosAttacks
	dw WooperEvosAttacks
	dw QuagsireEvosAttacks
	dw EspeonEvosAttacks
	dw UmbreonEvosAttacks
	dw MurkrowEvosAttacks
	dw SlowkingEvosAttacks
	dw MisdreavusEvosAttacks
	dw UnownEvosAttacks
	dw WobbuffetEvosAttacks
	dw GirafarigEvosAttacks
	dw PinecoEvosAttacks
	dw ForretressEvosAttacks
	dw DunsparceEvosAttacks
	dw GligarEvosAttacks
	dw SteelixEvosAttacks
	dw SnubbullEvosAttacks
	dw GranbullEvosAttacks
	dw QwilfishEvosAttacks
	dw ScizorEvosAttacks
	dw ShuckleEvosAttacks
	dw HeracrossEvosAttacks
	dw SneaselEvosAttacks
	dw TeddiursaEvosAttacks
	dw UrsaringEvosAttacks
	dw SlugmaEvosAttacks
	dw MagcargoEvosAttacks
	dw SwinubEvosAttacks
	dw PiloswineEvosAttacks
	dw CorsolaEvosAttacks
	dw RemoraidEvosAttacks
	dw OctilleryEvosAttacks
	dw DelibirdEvosAttacks
	dw MantineEvosAttacks
	dw SkarmoryEvosAttacks
	dw HoundourEvosAttacks
	dw HoundoomEvosAttacks
	dw KingdraEvosAttacks
	dw PhanpyEvosAttacks
	dw DonphanEvosAttacks
	dw Porygon2EvosAttacks
	dw StantlerEvosAttacks
	dw SmeargleEvosAttacks
	dw TyrogueEvosAttacks
	dw HitmontopEvosAttacks
	dw SmoochumEvosAttacks
	dw ElekidEvosAttacks
	dw MagbyEvosAttacks
	dw MiltankEvosAttacks
	dw BlisseyEvosAttacks
	dw RaikouEvosAttacks
	dw EnteiEvosAttacks
	dw SuicuneEvosAttacks
	dw LarvitarEvosAttacks
	dw PupitarEvosAttacks
	dw TyranitarEvosAttacks
	dw LugiaEvosAttacks
	dw HoOhEvosAttacks
	dw CelebiEvosAttacks
.IndirectEnd::

ChikoritaEvosAttacks:
	dbbw EVOLVE_LEVEL, 16, BAYLEEF
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 1, GROWL
	dbw 6, RAZOR_LEAF
	dbw 9, LEECH_SEED
	dbw 12, REFLECT
	dbw 15, POISONPOWDER
	dbw 21, MEGA_DRAIN
	dbw 23, SYNTHESIS
	dbw 31, BODY_SLAM
	dbw 36, GIGA_DRAIN
	dbw 41, LIGHT_SCREEN
	dbw 45, SOLARBEAM
	dbw 46, SUNNY_DAY
	dbw 50, SAFEGUARD
	db 0 ; no more level-up moves

BayleefEvosAttacks:
	dbbw EVOLVE_LEVEL, 32, MEGANIUM
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 1, GROWL
	dbw 1, RAZOR_LEAF
	dbw 1, REFLECT
	dbw 15, POISONPOWDER
	dbw 21, MEGA_DRAIN
	dbw 23, SYNTHESIS
	dbw 31, BODY_SLAM
	dbw 36, GIGA_DRAIN
	dbw 41, LIGHT_SCREEN
	dbw 45, SOLARBEAM
	dbw 46, SUNNY_DAY
	dbw 50, SAFEGUARD
	db 0 ; no more level-up moves

MeganiumEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 1, GROWL
	dbw 1, RAZOR_LEAF
	dbw 1, REFLECT
	dbw 15, POISONPOWDER
	dbw 21, MEGA_DRAIN
	dbw 23, SYNTHESIS
	dbw 31, BODY_SLAM
	dbw 36, GIGA_DRAIN
	dbw 41, LIGHT_SCREEN
	dbw 45, SOLARBEAM
	dbw 46, SUNNY_DAY
	dbw 50, SAFEGUARD
	db 0 ; no more level-up moves

CyndaquilEvosAttacks:
	dbbw EVOLVE_LEVEL, 14, QUILAVA
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 1, LEER
	dbw 6, SMOKESCREEN
	dbw 7, EMBER
	dbw 16, DEFENSE_CURL
	dbw 21, QUICK_ATTACK
	dbw 24, FLAME_WHEEL
	dbw 32, SWIFT
	dbw 38, FLAMETHROWER
	dbw 50, FIRE_BLAST
	db 0 ; no more level-up moves

QuilavaEvosAttacks:
	dbbw EVOLVE_LEVEL, 36, TYPHLOSION
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 1, LEER
	dbw 1, SMOKESCREEN
	dbw 1, EMBER
	dbw 16, DEFENSE_CURL
	dbw 21, QUICK_ATTACK
	dbw 24, FLAME_WHEEL
	dbw 32, SWIFT
	dbw 38, FLAMETHROWER
	dbw 50, FIRE_BLAST
	db 0 ; no more level-up moves

TyphlosionEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 1, LEER
	dbw 1, SMOKESCREEN
	dbw 1, EMBER
	dbw 16, DEFENSE_CURL
	dbw 21, QUICK_ATTACK
	dbw 24, FLAME_WHEEL
	dbw 32, SWIFT
	dbw 38, FLAMETHROWER
	dbw 50, FIRE_BLAST
	db 0 ; no more level-up moves

TotodileEvosAttacks:
	dbbw EVOLVE_LEVEL, 18, CROCONAW
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 7, WATER_GUN
	dbw 12, RAGE
	dbw 21, BITE
	dbw 28, SCARY_FACE
	dbw 37, SLASH
	dbw 45, SCREECH
	dbw 50, HYDRO_PUMP
	dbw 55, CRUNCH
	db 0 ; no more level-up moves

CroconawEvosAttacks:
	dbbw EVOLVE_LEVEL, 30, FERALIGATR
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 1, WATER_GUN
	dbw 1, RAGE
	dbw 21, BITE
	dbw 28, SCARY_FACE
	dbw 37, SLASH
	dbw 45, SCREECH
	dbw 50, HYDRO_PUMP
	dbw 55, CRUNCH
	db 0 ; no more level-up moves

FeraligatrEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 7, WATER_GUN
	dbw 12, RAGE
	dbw 21, BITE
	dbw 28, SCARY_FACE
	dbw 37, SLASH
	dbw 45, SCREECH
	dbw 50, HYDRO_PUMP
	dbw 55, CRUNCH
	db 0 ; no more level-up moves

SentretEvosAttacks:
	dbbw EVOLVE_LEVEL, 15, FURRET
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 4, DEFENSE_CURL
	dbw 6, QUICK_ATTACK
	dbw 9, THIEF
	dbw 12, FURY_SWIPES
	dbw 16, HEADBUTT
	dbw 20, DIG
	dbw 25, PURSUIT
	dbw 30, EXTREMESPEED
	dbw 35, REST
	dbw 40, AMNESIA
	db 0 ; no more level-up moves

FurretEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, THIEF
	dbw 1, SCRATCH
	dbw 1, TACKLE
	dbw 1, DEFENSE_CURL
	dbw 6, QUICK_ATTACK
	dbw 12, FURY_SWIPES
	dbw 16, HEADBUTT
	dbw 20, DIG
	dbw 25, PURSUIT
	dbw 30, EXTREMESPEED
	dbw 35, REST
	dbw 40, AMNESIA
	dbw 45, DOUBLE_EDGE
	dbw 50, BATON_PASS
	db 0 ; no more level-up moves

HoothootEvosAttacks:
	dbbw EVOLVE_LEVEL, 20, NOCTOWL
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 1, GROWL
	dbw 6, PECK
	dbw 10, FORESIGHT
	dbw 14, HYPNOSIS
	dbw 20, PSYBEAM
	dbw 24, WING_ATTACK
	dbw 28, REFLECT
	dbw 28, LIGHT_SCREEN
	dbw 32, MIRROR_COAT
	dbw 36, TAKE_DOWN
	dbw 40, PSYCHIC_M
	dbw 45, DREAM_EATER
	dbw 50, FUTURE_SIGHT
	db 0 ; no more level-up moves

NoctowlEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 1, GROWL
	dbw 1, PECK
	dbw 1, FORESIGHT
	dbw 14, HYPNOSIS
	dbw 20, PSYBEAM
	dbw 24, WING_ATTACK
	dbw 28, REFLECT
	dbw 28, LIGHT_SCREEN
	dbw 32, MIRROR_COAT
	dbw 36, TAKE_DOWN
	dbw 40, PSYCHIC_M
	dbw 45, DREAM_EATER
	dbw 50, FUTURE_SIGHT
	db 0 ; no more level-up moves

LedybaEvosAttacks:
	dbbw EVOLVE_LEVEL, 18, LEDIAN
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 6, LEECH_LIFE
	dbw 8, SUPERSONIC
	dbw 15, COMET_PUNCH
	dbw 20, LIGHT_SCREEN
	dbw 20, REFLECT
	dbw 22, SAFEGUARD
	dbw 26, BATON_PASS
	dbw 31, AGILITY
	dbw 36, GIGA_DRAIN
	dbw 42, SWIFT
	dbw 50, DOUBLE_EDGE
	db 0 ; no more level-up moves

LedianEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 1, LEECH_LIFE
	dbw 1, SUPERSONIC
	dbw 15, COMET_PUNCH
	dbw 18, LIGHT_SCREEN
	dbw 18, REFLECT
	dbw 24, SAFEGUARD
	dbw 26, BATON_PASS
	dbw 31, AGILITY
	dbw 36, GIGA_DRAIN
	dbw 42, SWIFT
	dbw 50, DOUBLE_EDGE
	db 0 ; no more level-up moves

SpinarakEvosAttacks:
	dbbw EVOLVE_LEVEL, 21, ARIADOS
	db 0 ; no more evolutions
	dbw 1, POISON_STING
	dbw 1, STRING_SHOT
	dbw 6, SCARY_FACE
	dbw 9, LEECH_LIFE
	dbw 12, CONSTRICT
	dbw 17, NIGHT_SHADE
	dbw 21, TWINEEDLE
	dbw 25, FURY_SWIPES
	dbw 33, SPIDER_WEB
	dbw 38, GIGA_DRAIN
	dbw 43, PSYCHIC_M
	dbw 47, MEGAHORN
	dbw 53, AGILITY
	db 0 ; no more level-up moves

AriadosEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, POISON_STING
	dbw 1, STRING_SHOT
	dbw 1, SCARY_FACE
	dbw 1, LEECH_LIFE
	dbw 12, CONSTRICT
	dbw 17, NIGHT_SHADE
	dbw 21, TWINEEDLE
	dbw 25, FURY_SWIPES
	dbw 33, SPIDER_WEB
	dbw 38, GIGA_DRAIN
	dbw 43, PSYCHIC_M
	dbw 47, MEGAHORN
	dbw 53, AGILITY
	db 0 ; no more level-up moves

CrobatEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCREECH
	dbw 1, LEECH_LIFE
	dbw 1, SUPERSONIC
	dbw 1, GUST
	dbw 12, BITE
	dbw 19, CONFUSE_RAY
	dbw 22, WING_ATTACK
	dbw 27, SLUDGE
	dbw 36, SLUDGE_BOMB
	dbw 42, MEAN_LOOK
	dbw 48, HAZE
	db 0 ; no more level-up moves

ChinchouEvosAttacks:
	dbbw EVOLVE_LEVEL, 27, LANTURN
	db 0 ; no more evolutions
	dbw 1, BUBBLE
	dbw 1, SUPERSONIC
	dbw 5, THUNDER_WAVE
	dbw 11, FLAIL
	dbw 17, WATER_GUN
	dbw 20, SPARK
	dbw 29, CONFUSE_RAY
	dbw 35, THUNDERBOLT
	dbw 40, TAKE_DOWN
	dbw 45, RAIN_DANCE
	dbw 49, THUNDER
	dbw 54, HYDRO_PUMP
	db 0 ; no more level-up moves

LanturnEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, BUBBLE
	dbw 1, SUPERSONIC
	dbw 1, THUNDER_WAVE
	dbw 11, FLAIL
	dbw 17, WATER_GUN
	dbw 20, SPARK
	dbw 29, CONFUSE_RAY
	dbw 35, THUNDERBOLT
	dbw 40, TAKE_DOWN
	dbw 45, RAIN_DANCE
	dbw 49, THUNDER
	dbw 54, HYDRO_PUMP
	db 0 ; no more level-up moves

PichuEvosAttacks:
	dbbw EVOLVE_HAPPINESS, TR_ANYTIME, PIKACHU
	db 0 ; no more evolutions
	dbw 1, THUNDERSHOCK
	dbw 1, CHARM
	dbw 6, TAIL_WHIP
	dbw 8, THUNDER_WAVE
	dbw 11, SWEET_KISS
	db 0 ; no more level-up moves

CleffaEvosAttacks:
	dbbw EVOLVE_HAPPINESS, TR_ANYTIME, CLEFAIRY
	db 0 ; no more evolutions
	dbw 1, POUND
	dbw 1, CHARM
	dbw 6, ENCORE
	dbw 8, SING
	dbw 13, SWEET_KISS
	db 0 ; no more level-up moves

IgglybuffEvosAttacks:
	dbbw EVOLVE_HAPPINESS, TR_ANYTIME, JIGGLYPUFF
	db 0 ; no more evolutions
	dbw 1, SING
	dbw 1, CHARM
	dbw 6, DEFENSE_CURL
	dbw 9, POUND
	dbw 14, SWEET_KISS
	db 0 ; no more level-up moves

TogepiEvosAttacks:
	dbbw EVOLVE_HAPPINESS, TR_ANYTIME, TOGETIC
	db 0 ; no more evolutions
	dbw 1, GROWL
	dbw 1, CHARM
	dbw 5, METRONOME
	dbw 11, RETURN
	dbw 18, SWEET_KISS
	dbw 25, ENCORE
	dbw 31, SAFEGUARD
	dbw 38, DOUBLE_EDGE
	dbw 43, TRI_ATTACK
	db 0 ; no more level-up moves

TogeticEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, GROWL
	dbw 1, CHARM
	dbw 5, METRONOME
	dbw 18, SWEET_KISS
	dbw 25, ENCORE
	dbw 27, WING_ATTACK
	dbw 31, SAFEGUARD
	dbw 38, DOUBLE_EDGE
	dbw 43, TRI_ATTACK
	db 0 ; no more level-up moves

NatuEvosAttacks:
	dbbw EVOLVE_LEVEL, 25, XATU
	db 0 ; no more evolutions
	dbw 1, LEER
	dbw 1, PECK
	dbw 5, CONFUSION
	dbw 10, NIGHT_SHADE
	dbw 20, TELEPORT
	dbw 25, PSYBEAM
	dbw 30, RECOVER
	dbw 35, PSYCHIC_M
	dbw 40, WING_ATTACK
	dbw 45, FUTURE_SIGHT
	dbw 50, CONFUSE_RAY
	db 0 ; no more level-up moves

XatuEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, LEER
	dbw 1, PECK
	dbw 1, CONFUSION
	dbw 1, NIGHT_SHADE
	dbw 20, TELEPORT
	dbw 25, PSYBEAM
	dbw 30, RECOVER
	dbw 35, PSYCHIC_M
	dbw 40, WING_ATTACK
	dbw 45, FUTURE_SIGHT
	dbw 50, CONFUSE_RAY
	db 0 ; no more level-up moves

MareepEvosAttacks:
	dbbw EVOLVE_LEVEL, 15, FLAAFFY
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 1, GROWL
	dbw 7, THUNDERSHOCK
	dbw 18, THUNDER_WAVE
	dbw 27, COTTON_SPORE
	dbw 39, LIGHT_SCREEN
	dbw 47, THUNDERBOLT
	dbw 55, THUNDER
	db 0 ; no more level-up moves

FlaaffyEvosAttacks:
	dbbw EVOLVE_LEVEL, 30, AMPHAROS
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 1, GROWL
	dbw 1, THUNDERSHOCK
	dbw 18, THUNDER_WAVE
	dbw 27, COTTON_SPORE
	dbw 39, LIGHT_SCREEN
	dbw 47, THUNDERBOLT
	dbw 55, THUNDER
	db 0 ; no more level-up moves

AmpharosEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 1, GROWL
	dbw 1, THUNDERSHOCK
	dbw 1, THUNDER_WAVE
	dbw 27, COTTON_SPORE
	dbw 30, THUNDERPUNCH
	dbw 39, LIGHT_SCREEN
	dbw 47, THUNDERBOLT
	dbw 55, THUNDER
	db 0 ; no more level-up moves

BellossomEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, ABSORB
	dbw 1, SWEET_SCENT
	dbw 1, POISONPOWDER
	dbw 1, STUN_SPORE
	dbw 18, SLEEP_POWDER
	dbw 21, MEGA_DRAIN
	dbw 24, CHARM
	dbw 32, GIGA_DRAIN
	dbw 35, MOONLIGHT
	dbw 44, PETAL_DANCE
	dbw 50, SOLARBEAM
	db 0 ; no more level-up moves

MarillEvosAttacks:
	dbbw EVOLVE_LEVEL, 18, AZUMARILL
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 3, DEFENSE_CURL
	dbw 6, TAIL_WHIP
	dbw 10, WATER_GUN
	dbw 15, ROLLOUT
	dbw 18, BUBBLEBEAM
	dbw 28, RAIN_DANCE
	dbw 36, DOUBLE_EDGE
	dbw 44, HYDRO_PUMP
	db 0 ; no more level-up moves

AzumarillEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 1, DEFENSE_CURL
	dbw 1, TAIL_WHIP
	dbw 1, WATER_GUN
	dbw 15, ROLLOUT
	dbw 18, BUBBLEBEAM
	dbw 28, RAIN_DANCE
	dbw 36, DOUBLE_EDGE
	dbw 44, HYDRO_PUMP
	db 0 ; no more level-up moves

SudowoodoEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, ROCK_THROW
	dbw 1, MIMIC
	dbw 10, FLAIL
	dbw 19, LOW_KICK
	dbw 28, ROCK_SLIDE
	dbw 31, COUNTER
	dbw 36, FAINT_ATTACK
	dbw 46, THRASH
	db 0 ; no more level-up moves

PolitoedEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, BUBBLE
	dbw 1, MIST
	dbw 1, HYPNOSIS
	dbw 1, PERISH_SONG
	dbw 10, WATER_GUN
	dbw 14, DOUBLESLAP
	dbw 20, BUBBLEBEAM
	dbw 25, RAIN_DANCE
	dbw 31, BODY_SLAM
	dbw 34, PERISH_SONG
	dbw 36, ICE_BEAM
	dbw 40, LIGHT_SCREEN
	dbw 45, HYDRO_PUMP
	dbw 51, SWAGGER
	db 0 ; no more level-up moves

HoppipEvosAttacks:
	dbbw EVOLVE_LEVEL, 18, SKIPLOOM
	db 0 ; no more evolutions
	dbw 1, SPLASH
	dbw 1, GUST
	dbw 3, TACKLE
	dbw 5, SYNTHESIS
	dbw 5, TAIL_WHIP
	dbw 7, ABSORB
	dbw 10, POISONPOWDER
	dbw 14, STUN_SPORE
	dbw 17, SLEEP_POWDER
	dbw 19, MEGA_DRAIN
	dbw 21, LEECH_SEED
	dbw 24, PROTECT
	dbw 31, COTTON_SPORE
	dbw 36, GIGA_DRAIN
	db 0 ; no more level-up moves

SkiploomEvosAttacks:
	dbbw EVOLVE_LEVEL, 27, JUMPLUFF
	db 0 ; no more evolutions
	dbw 1, SPLASH
	dbw 1, GUST
	dbw 1, TACKLE
	dbw 1, SYNTHESIS
	dbw 5, TAIL_WHIP
	dbw 7, ABSORB
	dbw 10, POISONPOWDER
	dbw 14, STUN_SPORE
	dbw 17, SLEEP_POWDER
	dbw 19, MEGA_DRAIN
	dbw 21, LEECH_SEED
	dbw 24, PROTECT
	dbw 31, COTTON_SPORE
	dbw 36, GIGA_DRAIN
	db 0 ; no more level-up moves

JumpluffEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SPLASH
	dbw 1, GUST
	dbw 1, TACKLE
	dbw 1, SYNTHESIS
	dbw 5, TAIL_WHIP
	dbw 7, ABSORB
	dbw 10, POISONPOWDER
	dbw 14, STUN_SPORE
	dbw 17, SLEEP_POWDER
	dbw 19, MEGA_DRAIN
	dbw 21, LEECH_SEED
	dbw 24, PROTECT
	dbw 31, COTTON_SPORE
	dbw 36, GIGA_DRAIN
	db 0 ; no more level-up moves

AipomEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, TAIL_WHIP
	dbw 6, SAND_ATTACK
	dbw 12, BATON_PASS
	dbw 19, LOW_KICK
	dbw 27, SWIFT
	dbw 36, SCREECH
	dbw 46, AGILITY
	db 0 ; no more level-up moves

SunkernEvosAttacks:
	dbww EVOLVE_ITEM, SUN_STONE, SUNFLORA
	db 0 ; no more evolutions
	dbw 1, ABSORB
	dbw 4, GROWTH
	dbw 10, MEGA_DRAIN
	dbw 15, RAZOR_LEAF
	dbw 19, SUNNY_DAY
	dbw 25, SYNTHESIS
	dbw 31, PETAL_DANCE
	dbw 36, SOLARBEAM
	dbw 50, GIGA_DRAIN
	db 0 ; no more level-up moves

SunfloraEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, ABSORB
	dbw 1, POUND
	dbw 1, GROWTH
	dbw 10, MEGA_DRAIN
	dbw 15, RAZOR_LEAF
	dbw 19, SUNNY_DAY
	dbw 25, SYNTHESIS
	dbw 31, PETAL_DANCE
	dbw 36, SOLARBEAM
	dbw 50, GIGA_DRAIN
	db 0 ; no more level-up moves

YanmaEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 1, FORESIGHT
	dbw 7, QUICK_ATTACK
	dbw 13, DOUBLE_TEAM
	dbw 19, WING_ATTACK
	dbw 25, TWINEEDLE
	dbw 30, TWISTER
	dbw 28, DETECT
	dbw 31, SUPERSONIC
	dbw 37, SONICBOOM
	dbw 43, SCREECH
	db 0 ; no more level-up moves

WooperEvosAttacks:
	dbbw EVOLVE_LEVEL, 20, QUAGSIRE
	db 0 ; no more evolutions
	dbw 1, WATER_GUN
	dbw 1, TAIL_WHIP
	dbw 5, MUD_SLAP
	dbw 11, SLAM
	dbw 16, BUBBLEBEAM
	dbw 20, MAGNITUDE
	dbw 23, AMNESIA
	dbw 33, EARTHQUAKE
	dbw 41, RAIN_DANCE
	dbw 51, MIST
	dbw 51, HAZE
	db 0 ; no more level-up moves

QuagsireEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, WATER_GUN
	dbw 1, TAIL_WHIP
	dbw 5, MUD_SLAP
	dbw 11, SLAM
	dbw 16, BUBBLEBEAM
	dbw 20, MAGNITUDE
	dbw 23, AMNESIA
	dbw 33, EARTHQUAKE
	dbw 41, RAIN_DANCE
	dbw 51, MIST
	dbw 51, HAZE
	db 0 ; no more level-up moves

EspeonEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 1, TAIL_WHIP
	dbw 8, SAND_ATTACK
	dbw 12, GROWL
	dbw 16, DOUBLE_KICK
	dbw 20, CONFUSION
	dbw 23, QUICK_ATTACK
	dbw 26, SWIFT
	dbw 30, PSYBEAM
	dbw 36, PSYCHIC_M
	dbw 42, PSYCH_UP
	dbw 47, MORNING_SUN
	dbw 52, REFLECT
	db 0 ; no more level-up moves

UmbreonEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 1, TAIL_WHIP
	dbw 8, SAND_ATTACK
	dbw 12, GROWL
	dbw 16, DOUBLE_KICK
	dbw 20, PURSUIT
	dbw 23, QUICK_ATTACK
	dbw 26, CONFUSE_RAY
	dbw 30, FAINT_ATTACK
	dbw 36, CURSE
	dbw 42, MEAN_LOOK
	dbw 47, MOONLIGHT
	dbw 52, SCREECH
	db 0 ; no more level-up moves

MurkrowEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, PECK
	dbw 11, PURSUIT
	dbw 16, HAZE
	dbw 22, WING_ATTACK
	dbw 26, NIGHT_SHADE
	dbw 31, FAINT_ATTACK
	dbw 36, DRILL_PECK
	dbw 41, MEAN_LOOK
	db 0 ; no more level-up moves

SlowkingEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, CURSE
	dbw 1, TACKLE
	dbw 1, GROWL
	dbw 1, WATER_GUN
  dbw 1, AMNESIA
	dbw 18, CONFUSION
	dbw 24, DISABLE
	dbw 29, PSYBEAM
	dbw 34, HEADBUTT
	dbw 41, SWAGGER
	dbw 45, PSYCHIC_M
	dbw 50, FUTURE_SIGHT
	db 0 ; no more level-up moves

MisdreavusEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, PSYWAVE
	dbw 1, GROWL
	dbw 4, NIGHT_SHADE
	dbw 8, SPITE
	dbw 12, CONFUSE_RAY
	dbw 19, MEAN_LOOK
	dbw 24, SCREECH
	dbw 27, SHADOW_BALL
	dbw 32, PSYBEAM
	dbw 36, PAIN_SPLIT
	dbw 41, SING
	dbw 46, PERISH_SONG
	db 0 ; no more level-up moves

UnownEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, HIDDEN_POWER
	db 0 ; no more level-up moves

WobbuffetEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, COUNTER
	dbw 1, MIRROR_COAT
	dbw 1, SAFEGUARD
	dbw 1, DESTINY_BOND
	db 0 ; no more level-up moves

GirafarigEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 1, GROWL
	dbw 1, CONFUSION
	dbw 1, STOMP
	dbw 7, CONFUSION
	dbw 13, STOMP
	dbw 20, AGILITY
	dbw 21, PSYBEAM
	dbw 30, BATON_PASS
	dbw 41, PSYCHIC_M
	dbw 46, CRUNCH
	db 0 ; no more level-up moves

PinecoEvosAttacks:
	dbbw EVOLVE_LEVEL, 25, FORRETRESS
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 1, HARDEN
	dbw 7, PIN_MISSILE
	dbw 12, PROTECT
	dbw 15, MEGA_DRAIN
	dbw 19, TAKE_DOWN
	dbw 22, RAPID_SPIN
	dbw 25, SELFDESTRUCT
	dbw 29, BIDE
	dbw 39, EXPLOSION
	dbw 44, SPIKES
	dbw 54, DOUBLE_EDGE
	db 0 ; no more level-up moves

ForretressEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 1, HARDEN
	dbw 1, PIN_MISSILE
	dbw 1, PROTECT
	dbw 15, MEGA_DRAIN
	dbw 19, TAKE_DOWN
	dbw 22, RAPID_SPIN
	dbw 25, SELFDESTRUCT
	dbw 29, BIDE
	dbw 33, SPIKE_CANNON
	dbw 39, EXPLOSION
	dbw 44, SPIKES
	dbw 54, DOUBLE_EDGE
	db 0 ; no more level-up moves

DunsparceEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, RAGE
	dbw 1, TACKLE
	dbw 5, DEFENSE_CURL
	dbw 13, GLARE
	dbw 15, DIG
	dbw 18, SPITE
	dbw 26, PURSUIT
	dbw 30, SCREECH
	dbw 33, BODY_SLAM
	db 0 ; no more level-up moves

GligarEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, POISON_STING
	dbw 6, SAND_ATTACK
	dbw 13, HARDEN
	dbw 16, MUD_SLAP
	dbw 20, QUICK_ATTACK
	dbw 24, WING_ATTACK
	dbw 28, FAINT_ATTACK
	dbw 36, SLASH
	dbw 38, EARTHQUAKE
	dbw 44, SCREECH
	dbw 52, GUILLOTINE
	db 0 ; no more level-up moves

SteelixEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, ROCK_SLIDE
	dbw 1, TACKLE
	dbw 1, SCREECH
	dbw 1, BIND
  dbw 1, SLAM
	dbw 12, ROCK_THROW
	dbw 18, DIG
	dbw 23, HARDEN
	dbw 27, RAGE
	dbw 36, SANDSTORM
	dbw 40, IRON_TAIL
	dbw 45, EARTHQUAKE
	dbw 49, CRUNCH
	db 0 ; no more level-up moves

SnubbullEvosAttacks:
	dbbw EVOLVE_LEVEL, 23, GRANBULL
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 1, SCARY_FACE
	dbw 4, TAIL_WHIP
	dbw 8, CHARM
	dbw 13, BITE
	dbw 19, LICK
	dbw 23, RAGE
	dbw 28, ROAR
	dbw 39, CRUNCH
	dbw 44, THRASH
	db 0 ; no more level-up moves

GranbullEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 1, SCARY_FACE
	dbw 4, TAIL_WHIP
	dbw 8, CHARM
	dbw 13, BITE
	dbw 19, LICK
	dbw 23, RAGE
	dbw 28, ROAR
	dbw 39, CRUNCH
	dbw 44, THRASH
	db 0 ; no more level-up moves

QwilfishEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, BUBBLE
	dbw 1, TACKLE
	dbw 1, POISON_STING
	dbw 6, WATER_GUN
	dbw 10, HARDEN
	dbw 10, MINIMIZE
	dbw 14, SPIKES
	dbw 20, SLUDGE
	dbw 26, PIN_MISSILE
	dbw 30, BUBBLEBEAM
	dbw 32, PROTECT
	dbw 36, TOXIC
	dbw 45, SLUDGE_BOMB
	dbw 50, HYDRO_PUMP
	db 0 ; no more level-up moves

ScizorEvosAttacks:
    db 0 ; no more evolutions
	dbw 1, QUICK_ATTACK
  dbw 1, WING_ATTACK
	dbw 1, LEER
	dbw 6, FOCUS_ENERGY
	dbw 12, PURSUIT
	dbw 16, CUT
	dbw 18, FALSE_SWIPE
	dbw 24, DOUBLE_TEAM
	dbw 30, METAL_CLAW
	dbw 36, SLASH
	dbw 42, TWINEEDLE
	dbw 48, SWORDS_DANCE
	dbw 54, AGILITY
    db 0 ; no more level-up moves

ShuckleEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, CONSTRICT
	dbw 1, WITHDRAW
	dbw 7, WRAP
	dbw 10, ACID
	dbw 13, ENCORE
	dbw 19, DEFENSE_CURL
	dbw 21, ROLLOUT
	dbw 23, SAFEGUARD
	dbw 27, SANDSTORM
	dbw 31, ACID_ARMOR
	dbw 34, BIDE
	dbw 37, REST
	dbw 40, PROTECT
	db 0 ; no more level-up moves

HeracrossEvosAttacks:
    db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 1, LEER
	dbw 5, PIN_MISSILE
	dbw 9, HORN_ATTACK
	dbw 12, ENDURE
	dbw 18, FURY_ATTACK
	dbw 25, COUNTER
	dbw 35, TAKE_DOWN
	dbw 44, REVERSAL
	dbw 45, MEGAHORN
	dbw 50, CROSS_CHOP
    db 0 ; no more level-up moves

SneaselEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 9, QUICK_ATTACK
	dbw 13, FURY_SWIPES
	dbw 17, SCREECH
	dbw 20, ICY_WIND
	dbw 25, FAINT_ATTACK
	dbw 33, ICE_PUNCH
	dbw 38, METAL_CLAW
	dbw 41, AGILITY
	dbw 43, SLASH
	dbw 47, BEAT_UP
	dbw 51, BLIZZARD
	db 0 ; no more level-up moves

TeddiursaEvosAttacks:
	dbbw EVOLVE_LEVEL, 30, URSARING
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 8, LICK
	dbw 15, FURY_SWIPES
	dbw 22, FAINT_ATTACK
	dbw 29, REST
	dbw 34, SNORE
	dbw 39, SLASH
	dbw 45, SUBMISSION
	dbw 50, THRASH
	db 0 ; no more level-up moves

UrsaringEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SCRATCH
	dbw 1, LEER
	dbw 1, LICK
	dbw 1, FURY_SWIPES
	dbw 22, FAINT_ATTACK
	dbw 29, REST
	dbw 34, SNORE
	dbw 39, SLASH
	dbw 45, SUBMISSION
	dbw 50, THRASH
	db 0 ; no more level-up moves

SlugmaEvosAttacks:
	dbbw EVOLVE_LEVEL, 27, MAGCARGO
	db 0 ; no more evolutions
	dbw 1, SMOG
	dbw 8, EMBER
	dbw 13, ROCK_THROW
	dbw 18, HARDEN
	dbw 25, FLAME_WHEEL
	dbw 29, AMNESIA
	dbw 36, FLAMETHROWER
	dbw 41, ROCK_SLIDE
	dbw 46, BODY_SLAM
	dbw 50, FIRE_BLAST
	db 0 ; no more level-up moves

MagcargoEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SMOG
	dbw 1, EMBER
	dbw 1, ROCK_THROW
	dbw 1, HARDEN
	dbw 25, FLAME_WHEEL
	dbw 29, AMNESIA
	dbw 36, FLAMETHROWER
	dbw 41, ROCK_SLIDE
	dbw 46, BODY_SLAM
	dbw 50, EARTHQUAKE
	dbw 56, FIRE_BLAST
	db 0 ; no more level-up moves

SwinubEvosAttacks:
	dbbw EVOLVE_LEVEL, 33, PILOSWINE
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 8, POWDER_SNOW
	dbw 14, MUD_SLAP
	dbw 18, ENDURE
	dbw 21, ICY_WIND
	dbw 28, TAKE_DOWN
	dbw 39, EARTHQUAKE
	dbw 42, MIST
	dbw 50, BLIZZARD
	dbw 55, AMNESIA
	db 0 ; no more level-up moves

PiloswineEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, HORN_ATTACK
	dbw 1, POWDER_SNOW
	dbw 1, ENDURE
	dbw 1, MUD_SLAP
	dbw 21, ICY_WIND
	dbw 28, TAKE_DOWN
	dbw 33, FURY_ATTACK
	dbw 39, EARTHQUAKE
	dbw 42, MIST
	dbw 50, BLIZZARD
	dbw 55, AMNESIA
	db 0 ; no more level-up moves

CorsolaEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 1, BUBBLE
	dbw 7, HARDEN
	dbw 13, WATER_GUN
	dbw 18, ANCIENTPOWER
	dbw 19, RECOVER
	dbw 23, SPIKES
	dbw 25, BUBBLEBEAM
	dbw 31, SPIKE_CANNON
	dbw 37, MIRROR_COAT
	dbw 45, HYDRO_PUMP
	db 0 ; no more level-up moves

RemoraidEvosAttacks:
	dbbw EVOLVE_LEVEL, 25, OCTILLERY
	db 0 ; no more evolutions
	dbw 1, WATER_GUN
	dbw 11, LOCK_ON
	dbw 22, PSYBEAM
	dbw 22, AURORA_BEAM
	dbw 22, BUBBLEBEAM
	dbw 28, FOCUS_ENERGY
	dbw 33, ICE_BEAM
	dbw 44, HYDRO_PUMP
	dbw 55, HYPER_BEAM
	db 0 ; no more level-up moves

OctilleryEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, WATER_GUN
	dbw 11, CONSTRICT
	dbw 22, PSYBEAM
	dbw 22, AURORA_BEAM
	dbw 22, BUBBLEBEAM
	dbw 25, OCTAZOOKA
	dbw 28, FOCUS_ENERGY
	dbw 33, ICE_BEAM
	dbw 44, HYDRO_PUMP
	dbw 55, HYPER_BEAM
	db 0 ; no more level-up moves

DelibirdEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, PRESENT
	db 0 ; no more level-up moves

MantineEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 1, BUBBLE
	dbw 10, SUPERSONIC
	dbw 18, BUBBLEBEAM
	dbw 20, CONFUSE_RAY
	dbw 25, WING_ATTACK
	dbw 30, TAKE_DOWN
	dbw 40, AGILITY
	dbw 45, MIRROR_COAT
	dbw 49, HYDRO_PUMP
	db 0 ; no more level-up moves

SkarmoryEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, LEER
	dbw 1, PECK
	dbw 13, SAND_ATTACK
	dbw 17, SPIKES
	dbw 19, SWIFT
	dbw 25, AGILITY
	dbw 28, WING_ATTACK
	dbw 31, STEEL_WING
	dbw 37, FURY_ATTACK
	dbw 41, DRILL_PECK
	db 0 ; no more level-up moves

	HoundourEvosAttacks:
	dbbw EVOLVE_LEVEL, 24, HOUNDOOM
	db 0 ; no more evolutions
	dbw 1, LEER
	dbw 1, EMBER
	dbw 7, ROAR
	dbw 12, BITE
	dbw 17, SMOG
	dbw 22, FLAME_WHEEL
	dbw 30, FAINT_ATTACK
	dbw 39, FLAMETHROWER
	dbw 48, CRUNCH
	db 0 ; no more level-up moves
	
HoundoomEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, LEER
	dbw 1, EMBER
	dbw 1, ROAR
	dbw 1, BITE
	dbw 17, SMOG
	dbw 22, FLAME_WHEEL
	dbw 30, FAINT_ATTACK
	dbw 39, FLAMETHROWER
	dbw 48, CRUNCH
	db 0 ; no more level-up moves

KingdraEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, BUBBLE
	dbw 1, SMOKESCREEN
	dbw 1, LEER
	dbw 1, WATER_GUN
	dbw 22, BUBBLEBEAM
	dbw 29, TWISTER
	dbw 36, DRAGONBREATH
	dbw 40, AGILITY
	dbw 51, HYDRO_PUMP
	db 0 ; no more level-up moves

PhanpyEvosAttacks:
	dbbw EVOLVE_LEVEL, 25, DONPHAN
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 1, GROWL
	dbw 7, MUD_SLAP
	dbw 9, DEFENSE_CURL
	dbw 14, MAGNITUDE
	dbw 17, FLAIL
	dbw 25, TAKE_DOWN
	dbw 33, ROLLOUT
	dbw 36, ENDURE
	dbw 40, EARTHQUAKE
	dbw 48, DOUBLE_EDGE
	db 0 ; no more level-up moves

DonphanEvosAttacks:
	db 0 ; no more evolutionsFras
	dbw 1, HORN_ATTACK
	dbw 1, GROWL
	dbw 1, MUD_SLAP
	dbw 1, DEFENSE_CURL
	dbw 14, MAGNITUDE
	dbw 17, FLAIL
	dbw 25, FURY_ATTACK
	dbw 33, ROLLOUT
	dbw 36, RAPID_SPIN
	dbw 40, EARTHQUAKE
	dbw 48, DOUBLE_EDGE
	db 0 ; no more level-up moves

Porygon2EvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SHARPEN
	dbw 1, CONVERSION2
	dbw 1, TACKLE
	dbw 1, CONVERSION
	dbw 9, AGILITY
	dbw 12, PSYBEAM
	dbw 20, RECOVER
	dbw 24, DEFENSE_CURL
	dbw 32, LOCK_ON
	dbw 36, TRI_ATTACK
	dbw 44, ZAP_CANNON
	dbw 50, HYPER_BEAM
	db 0 ; no more level-up moves

StantlerEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 8, LEER
	dbw 13, STOMP
	dbw 15, HYPNOSIS
	dbw 18, CONFUSE_RAY
	dbw 23, PURSUIT
	dbw 28, TAKE_DOWN
	dbw 33, REFLECT
	dbw 37, LIGHT_SCREEN
	dbw 40, DOUBLE_EDGE
	dbw 45, DREAM_EATER
	db 0 ; no more level-up moves

SmeargleEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, SKETCH
	dbw 11, SKETCH
	dbw 21, SKETCH
	dbw 31, SKETCH
	dbw 41, SKETCH
	dbw 51, SKETCH
	dbw 61, SKETCH
	dbw 71, SKETCH
	dbw 81, SKETCH
	dbw 91, SKETCH
	db 0 ; no more level-up moves

TyrogueEvosAttacks:
	dbbbw EVOLVE_STAT, 20, ATK_LT_DEF, HITMONCHAN
	dbbbw EVOLVE_STAT, 20, ATK_GT_DEF, HITMONLEE
  dbbbw EVOLVE_STAT, 20, ATK_EQ_DEF, HITMONTOP
	db 0 ; no more evolutions
	dbw 1, TACKLE
	db 0 ; no more level-up moves

HitmontopEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, FOCUS_ENERGY
	dbw 20, PURSUIT
	dbw 20, QUICK_ATTACK
	dbw 20, ROLLING_KICK
	dbw 25, RAPID_SPIN
	dbw 31, COUNTER
	dbw 37, AGILITY
	dbw 43, DETECT
	dbw 45, TRIPLE_KICK
	db 0 ; no more level-up moves

SmoochumEvosAttacks:
	dbbw EVOLVE_LEVEL, 30, JYNX
	db 0 ; no more evolutions
	dbw 1, POWDER_SNOW
	dbw 1, LICK
	dbw 1, POUND
	dbw 7, SWEET_KISS
	dbw 17, ICY_WIND
	dbw 21, CONFUSION
	dbw 25, SING
	dbw 30, ICE_PUNCH
	dbw 33, MEAN_LOOK
	dbw 37, PSYCHIC_M
	dbw 45, PERISH_SONG
	dbw 49, BLIZZARD
	db 0 ; no more level-up moves

ElekidEvosAttacks:
	dbbw EVOLVE_LEVEL, 30, ELECTABUZZ
	db 0 ; no more evolutions
	dbw 1, THUNDERSHOCK
	dbw 1, LEER
	dbw 7, QUICK_ATTACK
	dbw 17, SPARK
	dbw 21, LIGHT_SCREEN
	dbw 25, SWIFT
	dbw 30, THUNDERPUNCH
	dbw 36, SCREECH
	dbw 42, THUNDERBOLT
	dbw 52, THUNDER
	db 0 ; no more level-up moves

MagbyEvosAttacks:
	dbbw EVOLVE_LEVEL, 30, MAGMAR
	db 0 ; no more evolutions
	dbw 1, EMBER
	dbw 1, LEER
	dbw 7, SMOG
	dbw 17, FLAME_WHEEL
	dbw 21, SMOKESCREEN
	dbw 25, POISON_GAS
	dbw 30, FIRE_PUNCH
	dbw 33, SUNNY_DAY
	dbw 41, FLAMETHROWER
	dbw 49, CONFUSE_RAY
	dbw 57, FIRE_BLAST
	db 0 ; no more level-up moves

MiltankEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, TACKLE
	dbw 4, GROWL
	dbw 8, DEFENSE_CURL
	dbw 13, STOMP
	dbw 19, MILK_DRINK
	dbw 26, BIDE
	dbw 34, ROLLOUT
	dbw 43, BODY_SLAM
	dbw 53, HEAL_BELL
	dbw 58, DOUBLE_EDGE
	db 0 ; no more level-up moves

BlisseyEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, POUND
	dbw 4, GROWL
	dbw 7, TAIL_WHIP
	dbw 10, SOFTBOILED
	dbw 13, DOUBLESLAP
	dbw 18, MINIMIZE
	dbw 23, SING
	dbw 28, EGG_BOMB
	dbw 33, DEFENSE_CURL
	dbw 40, LIGHT_SCREEN
	dbw 47, DOUBLE_EDGE
	db 0 ; no more level-up moves

RaikouEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, BITE
	dbw 1, LEER
	dbw 11, SPARK
	dbw 21, QUICK_ATTACK
	dbw 31, THUNDERBOLT
	dbw 41, CRUNCH
	dbw 51, REFLECT
	dbw 61, THUNDER
	db 0 ; no more level-up moves

EnteiEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, BITE
	dbw 1, LEER
	dbw 11, FLAME_WHEEL
	dbw 21, STOMP
	dbw 31, FLAMETHROWER
	dbw 41, CRUNCH
	dbw 51, LIGHT_SCREEN
	dbw 61, FIRE_BLAST
	dbw 71, SWAGGER
	db 0 ; no more level-up moves

SuicuneEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, BITE
	dbw 1, LEER
	dbw 11, BUBBLEBEAM
	dbw 21, RAIN_DANCE
	dbw 31, ICE_BEAM
	dbw 41, REFLECT
	dbw 51, LIGHT_SCREEN
	dbw 61, HYDRO_PUMP
	dbw 71, MIRROR_COAT
	db 0 ; no more level-up moves

LarvitarEvosAttacks:
	dbbw EVOLVE_LEVEL, 30, PUPITAR
	db 0 ; no more evolutions
	dbw 1, LEER
	dbw 1, BITE
	dbw 8, ROCK_THROW
	dbw 11, SANDSTORM
	dbw 15, SCREECH
	dbw 26, THRASH
	dbw 34, SCARY_FACE
	dbw 40, ROCK_SLIDE
	dbw 50, CRUNCH
	dbw 55, EARTHQUAKE
	dbw 57, HYPER_BEAM
	db 0 ; no more level-up moves

PupitarEvosAttacks:
	dbbw EVOLVE_LEVEL, 55, TYRANITAR
	db 0 ; no more evolutions
	dbw 1, LEER
	dbw 1, BITE
	dbw 1, ROCK_THROW
	dbw 1, SANDSTORM
	dbw 15, SCREECH
	dbw 26, THRASH
	dbw 34, SCARY_FACE
	dbw 40, ROCK_SLIDE
	dbw 50, CRUNCH
	dbw 55, EARTHQUAKE
	dbw 65, HYPER_BEAM
	db 0 ; no more level-up moves

TyranitarEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, LEER
	dbw 1, BITE
	dbw 1, ROCK_THROW
	dbw 1, SANDSTORM
	dbw 15, SCREECH
	dbw 26, THRASH
	dbw 34, SCARY_FACE
	dbw 40, ROCK_SLIDE
	dbw 50, CRUNCH
	dbw 55, EARTHQUAKE
	dbw 65, HYPER_BEAM
	db 0 ; no more level-up moves

LugiaEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, GUST
	dbw 11, SAFEGUARD
	dbw 22, RECOVER
	dbw 33, AEROBLAST
	dbw 44, ANCIENTPOWER
	dbw 55, RAIN_DANCE
	dbw 66, HYDRO_PUMP
	dbw 77, WHIRLWIND
	dbw 88, SWIFT
	dbw 99, FUTURE_SIGHT
	db 0 ; no more level-up moves

HoOhEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, GUST
	dbw 11, SAFEGUARD
	dbw 22, RECOVER
	dbw 33, SACRED_FIRE
	dbw 44, ANCIENTPOWER
	dbw 55, SUNNY_DAY
	dbw 66, FIRE_BLAST
	dbw 77, WHIRLWIND
	dbw 88, SWIFT
	dbw 99, FUTURE_SIGHT
	db 0 ; no more level-up moves

CelebiEvosAttacks:
	db 0 ; no more evolutions
	dbw 1, LEECH_SEED
	dbw 1, CONFUSION
	dbw 1, RECOVER
	dbw 10, SAFEGUARD
	dbw 20, MEGA_DRAIN
	dbw 25, ANCIENTPOWER
	dbw 30, PSYBEAM
	dbw 35, GIGA_DRAIN
	dbw 40, PSYCHIC_M
	dbw 45, HEAL_BELL
	dbw 50, BATON_PASS
	dbw 55, FUTURE_SIGHT
	dbw 60, PERISH_SONG
	db 0 ; no more level-up moves

ENDSECTION
