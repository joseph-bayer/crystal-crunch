# Adding a cosmetic form

How to give a species a new look, worked for Golbat's Team Rocket form. A cosmetic form changes
what a Pokémon looks like and nothing else: same stats, moves, type and evolutions.

- [What a form is](#what-a-form-is)
- [The graphics](#the-graphics)
- [The constant](#the-constant)
- [The tables](#the-tables)
- [Putting the form on a Pokémon](#putting-the-form-on-a-pokémon)
- [Egg patterns](#egg-patterns)
- [Gotchas](#gotchas)
- [Checklist](#checklist)


## What a form is

A Pokémon's form lives in its `MON_FORM` byte (`SAVEMON_FORM` in the PC), packed as
(`constants/pokemon_data_constants.asm`):

| Bits | Mask | Meaning |
|---|---|---|
| 0-4 | `FORM_MASK` | the form number; 0 is `PLAIN_FORM` |
| 6 | `ALT_SHINY_MASK` | reserved, unread |
| 7 | `SHINY_MASK` | shiny; a stored flag here, not derived from DVs |

Form numbers are per species and 0-indexed, so a species can have up to 32. Every place that draws
a Pokémon looks the species up in a **master table** with one `dw` per species: 0 means "no forms,
use the ordinary data", anything else points at a **per-form table** for that species, indexed by
the form number. There are nine such master tables, one per kind of data, and each is consulted
independently: a species has a row only in the tables where a form differs from the species. A
recolor touches one table; a redrawn sprite touches five or more. See
[which tables a form needs](#which-tables-a-form-needs).

Pikachu (`PIKACHU_RB_FORM`) and Golbat (`GOLBAT_ROCKET_FORM`) are complete examples to copy from.


## The graphics

A form's art lives in a sibling directory named `gfx/pokemon/<species>_<form>/`, holding the same
files an ordinary species directory does:

| File | What |
|---|---|
| `front.png` | the front sprite, 56x56 (or 48x48 / 40x40, matching the species' pic size). Only the first frame: no animation strip |
| `back.png` | the back sprite, 48x48 |
| `anim.asm` | battle animation script; `endanim` alone is a still sprite |
| `anim_idle.asm` | the idle twitch; `endanim` alone for none |
| `shiny.pal` | optional; only if the form has its own shiny colors |

Make derives everything else: `.2bpp`, `.gbcpal`, `front.dimensions`, `front.animated.2bpp`,
`front.animated.tilemap`, `bitmask.asm` and `frames.asm`. None of that is committed.

**Four colors, and front and back must share them.** Each PNG is black, white and two mid-tones.
Make builds one `normal.gbcpal` from the front and back together, and fails with `more than 2
colors besides black and white` when the two disagree. Paint the back with exactly the front's
two mid-tones. The generated palette is sorted by brightness, so the lighter mid-tone lands in the
light slot whatever its hue.

**A form can skip the back sprite.** If the back is the species' own, leave `back.png` out, point
the form's back row at the species' backpic (`dba GolbatBackpic`) and give the front a Makefile
line so it takes its colors from the species' palette instead of a `normal.gbcpal` of its own,
which needs a back to build:

```make
gfx/pokemon/golbat_rocket/front.2bpp: gfx/pokemon/golbat_rocket/front.png gfx/pokemon/golbat/normal.gbcpal
gfx/pokemon/golbat_rocket/front.2bpp: rgbgfx += --colors gbc:$(word 2,$^)
```

That also means the front must be painted in the species' two mid-tones. The Egg has the same
lines for the same reason.

If the form should use the *species'* colors rather than its own, draw it in greys and point its
palette row at the species' `normal.gbcpal`, as Pikachu Surf and Fly do. See the comment in
`data/pokemon/cosmetic_palettes.asm`.

Animation scripts are in `docs/pic_animations.md`. A form whose front differs from the species'
usually cannot reuse the species' `anim.asm`, because frame numbers refer to tiles of its own
tilemap; copy and adjust, or start still.


## The constant

Forms are enumerated per species in `constants/pokemon_constants.asm`, after the Unown letters:

```asm
; Golbat forms
  const_def 0 ; Note that forms are now 0-indexed
  const GOLBAT_PLAIN_FORM   ; 0
  const GOLBAT_ROCKET_FORM  ; 1
DEF NUM_GOLBAT_FORMS EQU const_value ; 2
```

Append to an existing species' block, never insert: the number is stored in every save and party
entry. `NUM_<SPECIES>_FORMS` is what every per-form table asserts against, so a missed table fails
the build. A species that should only hand out *some* of its forms in the wild also declares
`NUM_<SPECIES>_WILD_FORMS`, see [random wild forms](#random-wild-forms).


## The tables

Nine master tables, each with a `dw 0 ; SPECIES (xx)` row per species. **Every one of them is
optional.** Each loader checks the species' row and, when it is 0, uses the species' ordinary data
for every form. So a species only gets a row, and a per-form table, in the tables where some form
actually differs from the species. Keep each per-form table in form order and end it in
`assert_table_length NUM_<SPECIES>_FORMS`.

| Data | Master table | Per-form entry | Where the labels live |
|---|---|---|---|
| Pics | `data/pokemon/cosmetic_form_pic_pointers.asm` | `dba Front` / `dba Back`, `table_width 3 * 2` | `gfx/pics.asm`, two `INCBIN`s in a `Pics N` section with room |
| Animation | `gfx/pokemon/cosmetic_form_anim_pointers.asm`, first table | `dw Anim` | `gfx/pokemon/cosmetic_anims.asm` |
| Idle animation | same file, second table | `dw AnimIdle` | `gfx/pokemon/cosmetic_idles.asm` |
| Bitmasks | `gfx/pokemon/cosmetic_form_bitmask_pointers.asm` | `dw Bitmask` | `gfx/pokemon/cosmetic_bitmasks.asm` |
| Frames | `gfx/pokemon/cosmetic_form_frame_pointers.asm` | `dw Frames` | `gfx/pokemon/cosmetic_frames.asm` |
| Palettes | `data/pokemon/cosmetic_form_palette_pointers.asm` | normal `INCBIN ... middle_colors` then shiny `INCLUDE`, `table_width COLOR_SIZE * 2 * 2` | `data/pokemon/cosmetic_palettes.asm` |
| Party icons | `data/pokemon/cosmetic_form_icon_pointers.asm` | `dw Icon`, `table_width 2, Label` | `gfx/cosmetic_icons.asm` |
| Symbol | `data/pokemon/cosmetic_form_symbols.asm` | `db 0` or `db "<GLYPH>"`, `table_width 1` | `constants/charmap.asm` |
| Dimensions | `gfx/pokemon/cosmetic_form_dimensions_pointers.asm` | `INCBIN ".../front.dimensions"` | `gfx/pokemon/cosmetic_dimensions.asm` |

### Which tables a form needs

Two kinds of form exist in the tree, and they need very different amounts of work.

**A recolor** keeps the species' sprite and only changes its two mid-tones. Scyther, Scizor,
Pinsir and Smeargle are recolors. They have **one** row: palettes. No new PNG, no pics, no
animation data; the species' sprite is drawn with the form's colors. The per-form palette table
is the species' `normal.gbcpal`/`shiny.pal` for form 0 and a hand-written `normal.pal` per form
(`gfx/pokemon/smeargle_blue/normal.pal`).

**A redraw** has its own front and back PNG. Pikachu, Shuckle, Magikarp, Unown and Golbat are
redraws. A redraw needs **five rows together**: pics, animation, idle, bitmasks and frames. They
are one unit because the battle animation runs on the form's own tilemap: `bitmask.asm` and
`frames.asm` are generated from the form's PNG, and the `anim.asm` frame numbers index them. Leave
any of the five at 0 and the species' data is applied to the form's tiles, which scrambles the
sprite the moment it animates. The idle row in particular has no check of its own: once the
animation row is set, the idle row is read unconditionally.

On top of either kind, three rows are taken only when they apply:

| Row | Take it when | Who has it |
|---|---|---|
| Palettes | a redraw uses different colors from the species (a redraw in the species' colors, or in greys, leaves it 0) | Pikachu and every recolor |
| Party icons | some form has its own icon | Pikachu (Surf, Fly), Unown, Snorlax (Apricorn), Igglybuff (Beta) |
| Symbol | some form shows a glyph beside its name | Pikachu (RB), Golbat (Rocket) |
| Dimensions | some form is a different pic size from the species | Pikachu, Magikarp |

So Golbat's Rocket form, a redrawn front in Golbat's own colors with a glyph, has pics, the four
animation tables and the symbol. Palettes, icons and dimensions stay 0 because the form keeps the
species' colors, icon and size.

### Notes on the odd ones

- **Pics.** The species' own front and back (`GolbatFrontpic`, `GolbatBackpic`) go in form 0's
  slot; only the new form needs new `INCBIN`s. The `Pics 19` section (bank 90) held 11 KB free in
  September 2026; the linker says if a section overflows, and the fix is another section, not a
  smaller sprite.
- **Animation, idle, bitmasks, frames.** Four aggregator files, one `Label: INCLUDE
  ".../file.asm"` line per form. Form 0 includes the species' own files. A form that reuses the
  species' PNG under another name can include the species' `anim.asm` too (Shuckle's neutral form
  does); a form with its own PNG usually cannot, because the frame numbers no longer match.
- **Palettes.** Row 0 is the species' own `normal.gbcpal` and `shiny.pal`. A form that has no
  shiny of its own reuses the species' `shiny.pal`. `middle_colors` (in `macros/gfx.asm`) takes
  the two mid-tones out of the generated palette. A redraw that should use the *species'* colors
  can either leave the master row 0, or, if the species needs the table for another form, point
  that form's row at the species' `normal.gbcpal` and draw it in greys (Pikachu Surf and Fly).
- **Icons.** The loader reads the master table, the per-form table and the icon tiles from
  **one bank** (`engine/gfx/mon_icons.asm`), the bank `gfx/cosmetic_icons.asm` sits in. The
  ordinary icons in `gfx/icons.asm` are elsewhere, so once a species has form icons, the form
  that keeps the species' icon needs a copy of that `INCBIN` in `gfx/cosmetic_icons.asm`
  (`PikachuPlainIcon`).
- **Symbol.** The character drawn beside the name in battle, on the stats screen and in the PC.
  Existing glyphs: `<ROCKET_LOGO>`, `<CARTRIDGE>`, `<ALT_SHINY>`, `★`. A new glyph is a tile in
  `gfx/font/font_battle_extra.png` plus a `charmap` line. `db 0` for no symbol; form 0 is normally 0.
- **Dimensions.** The loader falls back to the pic size in the base stats. Only Pikachu and
  Magikarp need it, because their forms differ in size.

`docs/newbox_format.md` and the PC do not need changes; they read `SAVEMON_FORM` and the same
tables.


## Putting the form on a Pokémon

The tables only say how a form looks. Something has to set the byte.

**Trainers.** In `data/trainers/parties.asm`, add `TRAINERTYPE_FORM` to the trainer's type and a
`db <FORM>` after *every* species in that party, `PLAIN_FORM` for the ones that stay ordinary.
Combinable with `TRAINERTYPE_ITEM` and `TRAINERTYPE_MOVES`; field order is level, species, form,
item, moves.

```asm
	db "GRUNT@", TRAINERTYPE_FORM
	db 26
	dw RATICATE
	db PLAIN_FORM
	db 26
	dw GOLBAT
	db GOLBAT_ROCKET_FORM
	db -1 ; end
```

**Wandering overworld mon.** The fourth column of `ow_wildmon` in `data/wild/overworld_mons.asm`,
and the fifth of `pop_mon` in `data/wild/mon_populations.asm`. `| SHINY_MASK` makes one always
shiny. `POP_WILD_FORM` in a `pop_mon` row rolls a random wild form instead. The battle takes the
wandering mon's form whole. See `docs/overworld_pokemon.md`.

**Gift Pokémon.** `givepoke SPECIES, level, item, FORM` in a map script; the fourth argument
defaults to `PLAIN_FORM`.

**Scripted battles.** `loadwildmon SPECIES, level, FORM` before `startbattle`; the third argument
defaults to `PLAIN_FORM` and may carry `| SHINY_MASK`. The clearing's Snorlax is the example.

**NPC trades.** The fourth column of `npctrade` in `data/events/npc_trades.asm`, right after the
offered species, is the form byte the received mon gets (`PLAIN_FORM`, or a form `| SHINY_MASK`).
Only the requested *species* is checked, never its form. Link trades need nothing: the whole party
struct goes over the cable, form byte included.

**Random wild forms.** Grass and water tables have no form column. A species listed in
`WildFormTable` (`engine/battle/core.asm`, near the end) gets a random form from 0 to the count
given there, `NUM_<SPECIES>_WILD_FORMS` where only some forms should occur in the wild. Species
not in the table are always plain in the grass.

**Evolution** does not touch the form byte (`engine/pokemon/evolve.asm` rewrites the species in
place), so the *number* carries over: a form 2 Scyther becomes a form 2 Scizor. That is why
Scyther's and Scizor's forms are numbered in parallel, Forest Green to Crimson and Teal to Dusty
Rose. If the evolved species has fewer forms than the number carried in, the lookup reads past its
table, so give both halves of an evolution pair the same count or handle it at evolution time.

**Breeding** hands out `PLAIN_FORM` unless the egg's species is handled in
`engine/events/daycare.asm`. Species listed in `MultiFormEggTable` there (Scyther and Pinsir
today) get simple inheritance: the egg takes the form of whichever parent is that species'
line, or a coin flip between the two when both are. Add a `dw SPECIES` row to pass a new
species' form down. Smeargle has its own mixing rules right after that table, which is how the
Purple, Orange and Green Smeargle in `README.md` come about.

For quick testing, a wandering-mon row on Route 29 at a high weight is the easiest way to meet the
form on a new game. The table there is fixed at four rows per time of day, so replace a row rather
than adding one, and mark it `; TESTING`.


## Egg patterns

An egg can be drawn with its own pattern, picked by the species inside it: an egg that will hatch
into Elekid has the Elekid pattern. This uses the same machinery as forms. Every master table has an
`EGG` row above its label (species -3), and filling it gives `EGG` a per-pattern table, exactly like a
species' per-form table. The only difference is where the number comes from. An egg's `MON_FORM` byte
is the inner mon's form (Scyther, Pinsir and the RB lines inherit one), so the pattern is never
stored. `GetMonDrawForm` (`home/pokemon.asm`) works it out each time an egg is drawn, from
`SpecialEggPatterns` and the species inside, and keeps the egg's own shiny bit. Every place that draws
a party, PC, trade or follower mon calls it and hands the result over in `wForm`, with `bc = wForm`
for the palette loaders. Nothing is saved, so eggs made before a pattern existed, or traded in, get
it too.

To add a pattern, worked for Elekid:

| What | Where |
|---|---|
| The art | `gfx/pokemon/egg_<species>/front.png`, the egg's 40x120 three-frame layout, plus a hand-written `shiny.pal`. No back sprite, no `anim.asm`: every pattern runs the egg's animation scripts |
| Makefile | two lines, like the egg's, so the front takes its colors from its own `front.gbcpal` |
| The icon | `gfx/icons/egg_<species>.png`, 16x32, four greys, `INCBIN` in `gfx/cosmetic_icons.asm` |
| The constant | `EGG_<SPECIES>_PATTERN` after the others in `constants/pokemon_constants.asm`; `NUM_EGG_PATTERNS` follows |
| Which eggs | a `dw SPECIES` / `db EGG_<SPECIES>_PATTERN` row in `SpecialEggPatterns` (`home/pokemon.asm`) |
| Pic | `INCBIN` in a `Pics N` section, then a row in `EggPicPointers` (`data/pokemon/cosmetic_form_pic_pointers.asm`), `dbw -1, -1` for the back |
| Icon | a row in `EggIconPointers` (`data/pokemon/cosmetic_form_icon_pointers.asm`) |
| Palettes | a row in `EggPalettes` (`data/pokemon/cosmetic_palettes.asm`): its `front.gbcpal` and `shiny.pal` |
| Frames and bitmask | `INCLUDE` the generated `frames.asm` in `gfx/pokemon/johto_frames.asm` and `bitmask.asm` in `gfx/pokemon/bitmasks.asm`, then rows in `EggFramesPointers` and `EggBitmasksPointers` (`engine/gfx/pic_animation.asm`) |

Every per-pattern table asserts `NUM_EGG_PATTERNS`, so a missed one fails the build. The `EGG` rows of
the animation, bitmask, frame, dimension and symbol tables stay 0: the egg animation loaders keep
their own egg branch, which picks frames and bitmasks by pattern, and a non-zero animation row would
send eggs down the form path instead.

## Gotchas

- **Mixed line endings.** `data/pokemon/cosmetic_form_symbols.asm` is CRLF for most of its length
  and LF at the end, and several aggregator files end without a newline. Scripts that match on
  exact text should normalise first.
- **The table order is the form order.** Every per-form table is indexed by the form number; a
  row out of order shows another form's palette on this form's sprite and asserts nothing.
- **One bank for icons.** See above; a `dw` to an icon in another bank draws garbage.
- **Front and back share a palette.** The most common build failure.
- **Form 0 is the species itself.** Its rows point at the ordinary files; never leave them 0
  inside a per-form table.
- **Nothing derives shininess from DVs.** A form is not shiny unless `SHINY_MASK` is set on the
  same byte; the shiny palette row is only used then.
- **README.** The cosmetic forms table in `README.md` is the player-facing list; add a row.


## Checklist

```
Always:
[ ] constants/pokemon_constants.asm                     <SPECIES>_<FORM>_FORM appended, NUM_<SPECIES>_FORMS
[ ] something sets the form: parties / ow_wildmon / pop_mon / givepoke / npctrade / WildFormTable / MultiFormEggTable
[ ] README.md                                           forms table
[ ] make all                                            three targets; asserts catch a short table

Recolor (species' sprite, new colors):
[ ] gfx/pokemon/<species>_<form>/normal.pal             two RGB lines
[ ] data/pokemon/cosmetic_form_palette_pointers.asm     master row
[ ] data/pokemon/cosmetic_palettes.asm                  normal + shiny per form

Redraw (its own PNG), all five together:
[ ] gfx/pokemon/<species>_<form>/front.png, back.png    same two mid-tones; anim.asm, anim_idle.asm
[ ] Makefile                                            only if there is no back.png: front takes the species' palette
[ ] gfx/pics.asm                                        Front/Back INCBIN in a Pics section with room
[ ] data/pokemon/cosmetic_form_pic_pointers.asm         master row + dba table
[ ] gfx/pokemon/cosmetic_form_anim_pointers.asm         both master rows + two tables
[ ] gfx/pokemon/cosmetic_anims.asm, cosmetic_idles.asm  one INCLUDE per form
[ ] gfx/pokemon/cosmetic_form_bitmask_pointers.asm      master row + table; cosmetic_bitmasks.asm
[ ] gfx/pokemon/cosmetic_form_frame_pointers.asm        master row + table; cosmetic_frames.asm

Only when a form differs in that way:
[ ] data/pokemon/cosmetic_form_palette_pointers.asm     redraw in colors other than the species'
[ ] data/pokemon/cosmetic_form_icon_pointers.asm        own party icon; then gfx/cosmetic_icons.asm, same bank
[ ] data/pokemon/cosmetic_form_symbols.asm              a glyph beside the name
[ ] gfx/pokemon/cosmetic_form_dimensions_pointers.asm   a different pic size
```
