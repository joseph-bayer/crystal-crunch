# The Pokédex

The Pokédex is Nayru62's "Nayru's Pokédex", ported from `Nayru62/pokecrystal16`
(`newbox_NayrusPokedex`) with the later fixes from `Nayru62/pokecrystal` (`8.0_Nayrus_Pokedex`).
This page covers where its pages get their data and how to extend the AREA page.

## Where the code lives

| File | Bank (section) | What |
|---|---|---|
| `engine/pokedex/pokedex.asm` | `$7a` ("Pokedex") | The list, search, options and color screens, the entry screen's tabs and input |
| `engine/pokedex/pokedex_2.asm` | `$7d` ("Pokedex 2") | INFO text, shared page helpers, the `DEXENTRY_*` page constants; INCLUDEs every page below |
| `engine/pokedex/pokedex_stats_page.asm` | `$7d` | STAT |
| `engine/pokedex/pokedex_moves_page.asm` | `$7d` | MOVES: level-up, FIELD, egg, TM/HM and tutor rows |
| `engine/pokedex/pokedex_evolution_page.asm` | `$7d` | EVO |
| `engine/pokedex/pokedex_pics_page.asm` | `$7d` | PICS |
| `engine/pokedex/pokedex_area_page.asm` | `$7d` | AREA, and the extra nests for the Town Map |
| `engine/pokedex/pokedex_pals.asm` | `$7d` | The pages' palettes and attributes, type colors (`gfx/type_pals.asm`) |
| `engine/pokedex/dex_forms.asm` | `$7d` | The record of forms and alternate shinies met, its save copies, the display form byte, and the PICS page's forms and shiny glyphs |
| `engine/pokegear/clock_card.asm` | `$7d` ("Pokegear Clock Card") | The clock card's time of day, place and fishing group |
| `gfx/pokedex/*.png`, `gfx/pokedex_type_tiles.asm` | `$7a` ("Pokedex Graphics") | Tab bar, page numbers, symbols, type tiles |

The CGB layouts `SCGB_POKEDEX`, `SCGB_POKEDEX_EVO` and `SCGB_POKEDEX_PICS` stay in
`engine/gfx/cgb_layouts.asm` and call `pokedex_pals.asm` for everything only the dex uses.

## Pages and their data

The tab bar wraps: **Left** on INFO goes to PICS and **Right** on PICS to INFO (`Pokedex_MoveArrowCursor`
wraps a Left/Right cursor; the Up/Down menus stop at their ends). Opening an entry or moving to the
next one plays the cry without waiting for it (`PlayMonCry2`), so buttons work during it.

- **STAT** reads the base data (`GetBaseData`). Wild held items are 16-bit item indexes; the odds
  printed beside them (40% and 10%) are the battle engine's (`engine/battle/core.asm`).
- **MOVES**
  - Level-up moves: `EvosAttacksPointers`, after the evolutions (`Pokedex_SkipEvolutions` matches
    `SkipEvolutions` in `engine/pokemon/evolve.asm`).
  - FIELD: `Field_Moves_List`, the moves `data/mon_menu.asm` offers outside battle. Each gets a row
    for learning it by level and a row for its TM, HM or tutor (from the move's `*_TMNUM`).
  - EGG: the first evolution stage's `EggMovePointers` list.
  - TM/HM and tutor rows walk the TM/HM/tutor flags and print `TMnn`, `HMnn` or `MT`.
- **EVO** reads the evolution rows; item parameters are 16-bit item indexes. Species the player
  hasn't seen show as `?????` with the `???` type tile.
- **PICS** draws the plain form, and **Left**/**Right** step through the forms met (below);
  **Select** steps the shiny toggle. Buttons work from the first frame: the front pic animates, and cries, a step a frame inside
  the page loop (`Pokedex_PicsPageFrame`).
  Its own tiles sit in VRAM bank 1 above the front pic's animation frames (`DEXPICS_*` in
  `constants/icon_constants.asm`), so a front pic and its frames may take up to
  `DEXPICS_MAX_FRONTPIC_TILES` (201) tiles; a data test checks every sprite. Leaving PICS reloads
  the inverted font those tiles go over.
- **Colors and shininess** go through `wPokedexDisplayForm` (`GetPokedexDisplayForm`): the form the
  PICS page shows (`wPokedexViewForm`, 0 everywhere else), `| SHINY_MASK` when the shiny toggle is
  on, and `| ALT_SHINY_MASK` when it is on the alternate step and the species' alternate has been
  seen (`wPokedexAltSeen`). `GetMonNormalOrShinyPalettePointer` and the pic loaders (through
  `wForm`) take it from there.
- **Saved settings**: `wPokedexShinyToggle` and `wCurPokedexColor` are the last two bytes of the
  options block (`wOptions` to `wOptionsEnd`, defaults in `data/default_options.asm`). The toggle's
  bit 0 is shiny (`POKEDEX_SHINY_F`) and bit 1 the alternate step (`POKEDEX_ALT_SHINY_F`). Everything
  else is page state in the dex's WRAM union.

## Forms and alternate shinies

The dex shows a species' cosmetic forms (Unown's letters included) and its alternate shiny once
the player has met them. The plain form shows whenever the species has been seen, as it always has.

**The record.** `wDexForms` (WRAMX bank 5) holds four flag arrays: `wDexFormsSeen` and
`wDexFormsCaught`, one flag per non-plain form, and `wDexAltShiniesSeen` and `wDexAltShiniesCaught`,
one flag per row of `AltShinyPalettes`. A form's flag is numbered by `DexFormFlagRows`
(`engine/pokedex/dex_forms.asm`): the counts of the rows before its row, plus its place in the row.
Both lists are in save order, so they only ever grow at the end (see
`docs/adding_cosmetic_forms.md`). Capacities: `DEX_FORM_FLAG_CAPACITY` (160) and
`DEX_ALT_SHINY_CAPACITY` (16), asserted.

**What records it.** `DexRecordForm*` (`a` = the species ID, every register kept), beside each
place that marks a species seen or caught:

| Event | Records | Form byte from |
|---|---|---|
| An enemy sent out or loaded in battle, an Elite Four seat's mon | seen | `wEnemyMonForm` |
| A catch; a gift or NPC trade (`GeneratePartyMonStats`); sent to the PC (`SendMonIntoBox`) | caught | `wEnemyMonForm` |
| A link trade (`AddTempmonToParty`); an evolution | caught | `wTempMonForm` |
| A hatch | caught | the hatched party mon |

Caught sets seen too. A shiny with `ALT_SHINY_MASK` records its species' alternate flag, if it has
one. `GiveEgg` holds the record off (`DexFormsHoldOn`/`Off`) while it adds the egg, as it takes back
the species flags. Game Corner prizes are plain, and wanderers seen on the map don't count until
battled.

**Saving.** The record isn't in `wGameData`: it has its own SRAM copies, `sDexForms` (bank 1) and
`sBackupDexForms` (bank 0), each a magic word (`DEX_FORMS_SAVE_MAGIC`), the record and a checksum.
`SavePokemonData`, `SaveBackupPokemonData`, `LoadPokemonData` and `LoadBackupPokemonData` save and
load it with the Pokémon data, so every save, load and reload path carries it. A copy without the
magic or with a bad checksum, as in every save from before it, loads as nothing met. A new game
clears it (`_ResetWRAM`).

**The PICS page.**
- **Left**/**Right** step through the forms the dex may show (`Pokedex_StepViewForm`): the plain
  form and each form seen, skipping the forms in `DexFormsLookPlain`, which keep an evolution line's
  form number but are drawn as the plain form. The pics, icon, colors, label and marks change in place (`Pokedex_PicsSwapForm`).
- `FORM ◀n/m▶` under the name when there is more than one to show: the form shown is the n-th of m
  (the ◀ is a ▶ the attrmap flips).
- Up/Down and leaving the page go back to the plain form.
- The caught ball follows the look shown: the species caught for the plain form, the form caught
  for any other, and the alternate caught too while the alternate is shown.

**The shiny toggle** (Select, on the entry screen and PICS) steps off, shiny, alternate, off; the
alternate step only when the species' alternate has been seen. The glyph is `<DEX_⁂>` for shiny and
`<ALT_SHINY>` for the alternate (`Pokedex_PlaceShinyGlyph`).

`tests/test_dex_forms.py` and `tests/test_data_dex_forms.py` cover the record, the PICS page and the
save; the helpers are in `tests/harness/dex_forms.py`.

## The AREA page

Each category in `AreaCategories` (`engine/pokedex/pokedex_area_page.asm`) walks one data source
and calls `Pokedex_AreaRowIfAny` (or `Pokedex_AreaRow`) for every place the species turns up.
A place is two rows: its name, then its odds in one of the `AREA_FORMAT_*` layouts. Three places
fit a page; A pages on, then moves to the next category with places, wrapping round.

| Category | Source |
|---|---|
| Johto / Kanto walking | `JohtoGrassWildMons`, `KantoGrassWildMons`, odds from `GrassMonProbTable` |
| Johto / Kanto surfing | `JohtoWaterWildMons`, `KantoWaterWildMons`, odds from `WaterMonProbTable` |
| Fishing | `FishGroups` and `TimeFishGroups`, one place per fishing group (names in `data/wild/fish_group_names.asm`) |
| Headbutt / Rock Smash | `TreeMonMaps` / `RockMonMaps` and their `TreeMons` sets |
| Bug-Catching Contest | `ContestMons` |
| Roaming | `wRoamMon1`-`3`, where each one is now |
| Wandering | `OverworldWildMonsGrass`, `OverworldWildMonsWater` and `MonPopulations` |

Rules every category keeps:

- **Compare 16-bit species indexes** (`Pokedex_AreaIsSpecies`), never convert table entries to IDs:
  a scan over every table would fill the ID table and evict IDs held elsewhere
  (`tests/test_pokedex.py::test_area_pages_allocate_no_ids`).
- **Secret places stay secret**: a map whose landmark is `LANDMARK_SPECIAL` (the Mystery Islands)
  or a hidden landmark (Apricorn Forest and Clearing) is never listed.
- **No swarms, gifts, trades or events** are listed.
- **Place names** are the landmark's name plus a floor from `data/maps/dex_floor_names.asm`, which
  has a row for every map in the wild tables whose constant names a floor
  (`tests/test_data_pokedex.py` checks it, and that each name fits the page).

### Adding a category

1. Add a `DEXENTRY_AREA_*` constant in `engine/pokedex/pokedex_2.asm`, between
   `DEXENTRY_AREA_FIRST` and the last one, in the order the page should show it.
2. Write its routine: walk the source, put the map in `wPokedexAreaMap` (a group of 0 and a name in
   `wPokedexAreaNamePtr` for a place that isn't a map), the odds in `wPokedexAreaValues`, and call
   `Pokedex_AreaRowIfAny` with an `AREA_FORMAT_*`. Return `ROWS_FULL` as soon as a call does, else
   0. Read data from other banks with `Pokedex_AreaCopyRecord`, `GetFarByte` or `GetFarWord`.
3. Add its row to `AreaCategories`: the routine and the two lines of its title (11 and 9 tiles).
4. If its places belong on the Town Map's nest view, call the routine from
   `Pokedex_FindMoreNests` too; in nest mode `Pokedex_AreaRow` adds the landmark instead.
5. If its maps can name floors, add them to `data/maps/dex_floor_names.asm` and to
   `WILD_MAP_TABLES` in `tests/test_data_pokedex.py`.
