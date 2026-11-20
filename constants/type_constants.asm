; TypeNames indexes (see data/types/names.asm)
; also used in:
; - PokedexTypeSearchConversionTable (see data/types/search_types.asm)
; - PokedexTypeSearchStrings (see data/types/search_strings.asm)
; - TypeMatchups (see data/types/type_matchups.asm)
; - TypeBoostItems (see data/types/type_boost_items.asm)
	const_def

DEF PHYSICAL EQU const_value
	const NORMAL
	const FIGHTING
	const FLYING
	const POISON
	const GROUND
	const ROCK
	const BIRD
	const BUG
	const DARK
	const STEEL
	const DRAGON

DEF UNUSED_TYPES EQU const_value
	const_next 19
	const CURSE_TYPE
DEF UNUSED_TYPES_END EQU const_value

DEF SPECIAL EQU const_value
	const FIRE
	const WATER
	const GRASS
	const ELECTRIC
	const PSYCHIC_TYPE
	const ICE
	const GHOST
DEF TYPES_END EQU const_value

DEF NUM_TYPES EQU TYPES_END + UNUSED_TYPES - UNUSED_TYPES_END - 1 ; discount BIRD

DEF POKEDEX_TYPE_STRING_LENGTH EQU 9

; Not a type: the Pokédex draws it as ??? (Unown's type, which varies by Pokémon, and an unseen
; Pokémon's types on the evolution page)
DEF DEX_UNKNOWN_TYPE EQU $ff
; the ??? row of gfx/pokedex/types_*.png and TypeIconPals
DEF DEX_TYPE_UNKNOWN EQU 18
