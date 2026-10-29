# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

"Crystal For Friends" — a Pokémon Crystal ROM hack built on the **CrystalShireEngine** (CSE), which is itself a fork of **pret/pokecrystal**. Game Boy Color assembly (RGBDS/SM83), with C build tools and Python lint utilities.

Because it is a pokecrystal fork, upstream pokecrystal/pret documentation and wiki tutorials usually apply — but CSE changes several core representations (notably 16-bit species/move/item indexes and 384-tile tilesets), so **verify against this tree before trusting a vanilla tutorial**.

`AGENTS.md` in the repo root holds condensed bot-facing rules. Per its own precedence note: a deeper-path `AGENTS.md` overrides the root one, and human reviewer instructions override everything.

## Toolchain

- **RGBDS 0.9.3 exactly** (pinned in `.rgbds-version`; CI checks out `gbdev/rgbds` at `v0.9.3`; `rgbdscheck.asm` enforces it at assembly time). Newer versions are not assumed to work.
- **GNU Make** + a C compiler. This checkout builds under **Cygwin** (`make` reports `x86_64-pc-cygwin`; `tools/*.exe` are prebuilt).
- **Python 3** for `utils/*.py`.
- `rgbasm` is not necessarily on the default PATH of a non-login shell — check with `rgbasm -V` before assuming a build failure is a code problem.

## Build

```bash
make crystal            # pokecrystal.gbc          (main ROM)
make crystal_debug      # pokecrystal_debug.gbc    (assembles with -D _DEBUG)
make crystal_vc         # pokecrystal.patch        (Virtual Console patch, -D _CRYSTAL_VC)
make all                # all three
make crystal_test       # pokecrystal_test.gbc     (debug + -D _TEST, for make test; not in all)
make -j"$(nproc)"       # parallel build
make clean              # tidy + delete generated graphics (.2bpp/.1bpp/.lz/.gbcpal, generated bitmask.asm/frames.asm)
make tidy               # delete ROMs, .o, .sym, .map only
make tools              # rebuild tools/ alone
```

Each ROM variant compiles the *same* sources into its own object set (`*.o`, `*_debug.o`, `*_vc.o`, `*_test.o`) with different `-D` flags — so a change guarded by `_DEBUG` or `_TEST` still has to assemble in all four.

Assembler flags are `-Q8 -P includes.asm -Weverything -Wtruncation=1`. `-P includes.asm` preincludes every macro and constant file into every translation unit, which is why `.asm` files rarely include constants themselves. **Adding a new constants or macros file requires registering it in `includes.asm`** — note the ordering constraint there (`16_bit_locking_constants.asm` must come after the translation constants).

VS Code tasks exist for these (`Build Debug ROM` is the default build task). Debugging runs `pokecrystal_debug.gbc` under the **Emulicious** debugger (`.vscode/launch.json`, port 58870).

## Verification

Correctness is enforced by assemble-time asserts, linker layout, lint scripts, and scripted in-game tests. The gates are:

```bash
make -j"$(nproc)"            # must assemble AND link; asserts catch layout and table mistakes
python utils/optimize.py     # peephole/optimization lint; accepts paths, defaults to '.'
python utils/farcheck.py     # flags farcall/farjp to labels in the same bank (and vice versa)
python utils/unreferenced.py # finds unreferenced labels
make test                    # builds pokecrystal_test.gbc and runs tests/ under PyBoy (pip install pyboy pytest)
```

The tests (`tests/`, see `tests/README.md`) drive the `crystal_test` ROM — the debug ROM plus `-D _TEST`, whose `Random` is a fixed-seed sequence — from a scripted new game, and check memory rather than pixels, since PyBoy draws this hack's backgrounds wrong. They are not run in CI yet.

CI (`.github/workflows/`) runs two jobs:

1. **CI** — builds with rgbds 0.9.3 and **fails if the build dirties the working tree** (`git diff-index HEAD`). Generated artifacts must stay gitignored; never commit build output.
2. **Assembly-optimize** — runs `utils/optimize.py` on *changed* `.asm` files only and **fails the build on any finding**.

The `AGENTS.md` workflow for avoiding optimize.py regressions: snapshot `python utils/optimize.py > .opt.old` before changes, re-run into `.opt.new` after, and `diff -u` the two. Delete `.opt.*` before committing — they must never be committed.

Since CI only lints changed files, a clean `optimize.py` run on *your* changed files is the bar, not a clean run repo-wide.

**Every bug fix gets a regression test.** When you fix a bug, add a scripted test for it under `tests/` in the same change, so `make test` catches it if it comes back. If the harness can't express it yet, say so and keep it on the list of tests to write.

## Style

- **Tabs to indent, spaces only to align** (`.vscode/settings.json` sets `tabSize: 8`, `insertSpaces: false`). `.gitattributes` normalizes all text to LF.
- Follow pret/pokecrystal `STYLE.md`.
- Use **`jmp`**, not raw `jp`. `jmp` (defined in `macros/asserts.asm`) is `jp` plus an assert that warns when the target is within `jr` range — resolve all such warnings by switching to `jr`.
- `farcall`/`farjp` similarly warn when the target is in the same bank or in ROM0; use a plain `call`/`jmp` there.

## Architecture

### Bank layout is explicit and manual

`layout.link` assigns every named `SECTION` to a specific bank. `main.asm`, `home.asm`, `audio.asm`, `ram.asm` and the `gfx/*.asm` files are thin files that `INCLUDE` the real sources into those sections. **Adding a new source file means adding an `INCLUDE` under some section** in one of those aggregator files — a file that nothing includes is silently absent from the ROM.

Banks fill up. If the linker reports a section overflow, the fix is a layout/section decision (move code to another bank and reach it via `farcall`), not a code-size micro-optimization.

`tools/scan_includes` computes make dependencies, and `tools/bankends` validates bank ends post-link.

### 16-bit species / move / item indexes (the biggest departure from vanilla)

CSE replaces vanilla's 8-bit species/move/item bytes with a **16-bit index / 8-bit ID indirection layer**. Two distinct concepts:

- **Index** (16-bit, in `hl`) — the real, global identifier. Data tables are indexed by this.
- **ID** (8-bit, in `a`) — a *dynamically allocated* handle into a runtime conversion table, used where the original 8-bit game structures still need a byte.

Convert only through these home helpers — never touch the conversion tables directly:

| Helper | In | Out | Clobbers |
|---|---|---|---|
| `GetPokemonIndexFromID` | `a` | `hl` | `a` |
| `GetPokemonIDFromIndex` | `hl` | `a` | `hl` |
| `GetMoveIndexFromID` | `a` | `hl` | `a` |
| `GetMoveIDFromIndex` | `hl` | `a` | `hl` |
| `GetItemIndexFromID` | `a` | `hl` | `a` |
| `GetItemIDFromIndex` | `hl` | `a` | `hl` |

The ID tables are a **garbage-collected cache with a fixed number of slots** (`constants/16_bit_translation_constants.asm`: `MON_TABLE_ENTRIES`, `MOVE_TABLE_ENTRIES`, …). IDs can be *evicted*. To keep an ID alive across a screen or script, it must occupy a **locked slot** — the named slots in `constants/16_bit_locking_constants.asm` (`LOCKED_MON_ID_MAP_1`, `LOCKED_MON_ID_DEX_SELECTED`, `LOCKED_MOVE_ID_BATTLE_TOWER_*`, …). Those files assert that you have not exceeded the locked-slot budget. Values `>= *_MINIMUM_RESERVED_INDEX` bypass the table entirely so sentinels like `$FF` keep their meaning.

Supporting code lives in `engine/16/` (`table_functions.asm`, `macros.asm`), `home/16bit.asm`, and `macros/wram_16bit.asm`.

Practical consequence: data files store species as **`dw`, not `db`** (see `data/trainers/parties.asm`).

### Indirect tables

`macros/indirection.asm` defines a compact bank-crossing table format (`indirect_table` / `indirect_entries` / `indirect_table_end`) read at runtime by `LoadIndirectPointer` and `LoadDoubleIndirectPointer` in `home/indirection.asm`. Entries carry a bank byte plus an address, so tables can span banks; the macros assert that the declared entry count and size match the referenced data block.

### Cosmetic forms

Forms are this hack's signature feature. A Pokémon's form lives in the `MON_FORM` / `SAVEMON_FORM` byte, bit-packed (`constants/pokemon_data_constants.asm`):

- `FORM_MASK  EQU %00011111` — the form number (`PLAIN_FORM` = 0)
- `SHINY_MASK EQU %10000000` — **shininess is a stored flag, not derived from DVs** (a change from vanilla)

Form numbers per species are `const`-enumerated in `constants/pokemon_constants.asm` (`PIKACHU_SURF_FORM`, `SCYTHER_TEAL_FORM`, …), each with a `NUM_<SPECIES>_FORMS` count and sometimes a `NUM_<SPECIES>_WILD_FORMS` subset limiting which forms occur in the wild.

Form data uses a consistent **two-level table** pattern: a master table with one `dw` per species (0 = use the species' ordinary data for every form, else a pointer to that species' per-form table), ending in `assert_table_length NUM_POKEMON`. Every loader falls back on a 0 row, so a species has a row only in the tables where a form differs: a recolor needs only the palette table; a redrawn sprite needs pics, animation, idle, bitmask and frame tables together; icons, symbols and dimensions only when a form has its own. Where a species does have a per-form table, adding a form means extending **every** table it already has, in the same form order:

- `constants/pokemon_constants.asm` — the form const + `NUM_*_FORMS`
- `gfx/pics.asm` — `INCBIN` the new front/back pic under a `Pics N` section
- `data/pokemon/cosmetic_form_pic_pointers.asm` — `dba` front/back pairs, `table_width 3 * 2`
- `data/pokemon/cosmetic_form_palette_pointers.asm` + `data/pokemon/cosmetic_palettes.asm`
- `data/pokemon/cosmetic_form_icon_pointers.asm` — party/box/overworld icons
- `data/pokemon/cosmetic_form_symbols.asm` — the marker shown in battle/stats/PC
- `gfx/pokemon/cosmetic_form_{anim,bitmask,frame,dimensions}_pointers.asm` — pic animation data (`dimensions` may be null if all forms share dimensions)

`docs/adding_cosmetic_forms.md` is the step-by-step walkthrough, including how a form gets onto a Pokémon (trainer parties, wandering mon, `givepoke`, `WildFormTable`).

Most per-form tables carry an `assert_table_length NUM_<SPECIES>_FORMS`, so a missed table tends to fail the build rather than corrupt at runtime — but only for the tables that declare it.

Trainers can specify forms: `TRAINERTYPE_FORM` (`constants/trainer_data_constants.asm`) is a bit flag, combinable with `TRAINERTYPE_MOVES`/`TRAINERTYPE_ITEM`. A form-typed party entry is `db level` / `dw SPECIES` / `db FORM | SHINY_MASK`. Parties use the `next_list_item` macro (`macros/lists.asm`), which emits self-relative offsets — entries must stay in the enumerated trainer order.

### Graphics pipeline

Generated files under `gfx/` are not committed: `.png` is the source, and Make derives `.2bpp`/`.1bpp` (via `rgbgfx`), `.gbcpal` (via `rgbgfx -p` + `tools/gbcpal`), `.lz` (via `tools/lzcomp`), and for Pokémon front pics also `.dimensions`, `front.animated.2bpp`, `front.animated.tilemap`, `bitmask.asm` and `frames.asm` (via `tools/pokemon_animation*`). `gfx/pokemon/unown/bitmask.asm` and `frames.asm` are the committed exceptions.

Per-file `rgbgfx`/`tools/gfx` flags (`--columns`, `--trim-whitespace`, `--remove-duplicates`, `--reverse` palettes, …) are set as **target-specific variables in the Makefile**. A new sprite that needs non-default handling gets a Makefile line, not a changed source PNG.

Mon pics resolve colors from `normal.gbcpal`, which `tools/gbcpal` builds by merging the front and back `.gbcpal` — so front and back sprites of one form must share a palette. Shiny palettes are hand-written `.pal` files, not generated.

Form sprite directories are siblings named `<species>_<form>` (`gfx/pokemon/pikachu_surf/`, `gfx/pokemon/scyther_teal/`).

### Maps

Map blocks are **`.ablk`**, not vanilla's `.blk` — CSE's expanded tileset format (384 tiles, per-block tile attributes). `maps/` holds ~253 maps, each a `.asm` (events/scripts) plus a `.ablk` (block layout). Map metadata is split across `data/maps/` — notably `maps.asm` (headers), `attributes.asm` (dimensions/connections, split out from headers by CSE), `blocks.asm` (the `INCBIN`s), `scripts.asm`, `scenes.asm`, `landmarks.asm`.

`docs/adding_maps.md` covers adding a new map and joining maps by warp or connection, including
where this fork diverges from the pret map tutorials. `docs/adding_tilesets.md` is the companion for
the tileset side — the 384-tile split across VRAM banks, blocks, attributes, collision, animations
and bank room.

`docs/` holds three kinds of document:

- **Walkthroughs for adding content**, written against this tree rather than vanilla: `adding_maps.md`, `adding_tilesets.md`, `adding_cosmetic_forms.md`.
- **Feature guides** for the fork's own systems: `overworld_pokemon.md` (wandering wild Pokémon, populations, their colors and save behavior), `following_pokemon.md`, `newbox_format.md`.
- **Scripting command sets**: `event_commands.md`, `map_event_scripts.md`, `map_setup_scripts.md`, `movement_commands.md`, `text_commands.md`, `battle_anim_commands.md`, `move_effect_commands.md`, `music_commands.md`, `menus.md`, `pic_animations.md`, `vc_patch.md`. Consult these before hand-writing script bytes.

Working notes — specs and plans for in-flight work — go in `plans/`, which is gitignored. Nothing tracked should link to a file there.

### Other CSE divergences worth knowing

- **EVs replace stat experience.**
- **Bill's PC is fully rewritten** ("newbox", `engine/pc/`, `docs/newbox_format.md`); the bag is rewritten too ("newbag") with expandable pockets.
- **60fps overworld / CGB double-speed** is on — timing-sensitive code and `home/double_speed.asm` matter.
- `farcall` preserves all registers (Polished Crystal behavior), unlike vanilla.

### Ported-data tooling

`tools/joe_tools/` holds one-off Python importers used to bring Crystal Legacy data into this fork's 16-bit formats (`crystal_legacy_parties_to_16_bit`, `crystal_legacy_evos_attacks_to_16_bit`, `crystal_legacy_encounters_to_16_bit`, `crystal_legacy_move_importer`, `crystal_legacy_base_stat_files`) plus `encounter_guide` and `rocket_teams_analyzer`. These are conversion aids, not part of the ROM build — see `README_pokemon_extractor.md`.

## Gameplay design constants

Rebalance knobs are centralized as named constants rather than magic numbers — e.g. shiny rates (`SHINY_NUMERATOR`, `GIFT_SHINY_NUMERATOR`, `SHINY_EGG_ONE_SHINY_PARENT_NUMERATOR`, …) in `constants/pokemon_data_constants.asm`, with comments spelling out the resulting odds and whether a preceding 1/256 check applies. `README.md` documents the intended player-facing balance (encounter rates, breeding odds, form acquisition methods) and is the authority on design intent; keep it in sync when changing these.
