# Following Pokémon

How the follow-mons feature was brought into this hack, what was changed to make it work with the
CrystalShireEngine, the bugs that came out of the gap between the two engines, and how follower
graphics and palettes actually get chosen.

Source: `fellowship-of-the-roms/pokecrystal`, branch `follow-mons`, tip `28da8e085`.


## Contents

- [Why the merge was done as a patch](#why-the-merge-was-done-as-a-patch)
- [Decisions made along the way](#decisions-made-along-the-way)
- [Where the code lives](#where-the-code-lives)
- [Bugs found and fixed](#bugs-found-and-fixed)
- [Bugs from the source branch](#bugs-from-the-source-branch)
- [The tile budget](#the-tile-budget)
- [Choosing your follower](#choosing-your-follower)
- [Follower graphics](#follower-graphics)
- [Follower palettes](#follower-palettes)
- [Known gaps](#known-gaps)
- [TODO](#todo)


## Why the merge was done as a patch

The follow-mons branch lives in a different repository. Git had no common ancestor to compare
against, so it could not tell "you changed this line" from "they changed this line" — it treated
every shared file as though both sides had invented it from scratch. A plain `git merge` produced
**1,020 conflicts**. Resolving those by hand would have meant re-deriving the whole engine from a
diff.

Also worth recording, because it shaped the work: the branch is **not** based on pokecrystal16. It
sits on plain pokecrystal, so every species reference in the feature was an 8-bit number. Converting
those to CSE's 16-bit index scheme became the substance of the port rather than a detail.

What was done instead:

1. Abort the merge, rescue the in-progress work, start a fresh branch.
2. Diff only the commit range that *is* the feature (`8565401a8..28da8e085`) and apply it as a patch
   with a three-way fallback. Everything before that range — the GDMA routine, dynamic sprite
   reload — was already in CSE.
3. Exclude the files where CSE already does the job better (see below), which removed a large slice
   of the conflicts outright.
4. Hand-resolve the remaining **22** conflicts. Most followed one rule: keep CSE's version, append
   the follower's additions after it. A lot of the noise was cosmetic — CSE writes `jmp` where
   vanilla writes `jp`.
5. Rewrite the parts that assume 8-bit species.

Result: 360 files changed, and all three ROM targets build with zero `utils/optimize.py` findings on
changed files.


## Decisions made along the way

| Decision | Reasoning |
| --- | --- |
| Dropped the feature's party-menu icon rewrite | It rebuilds menu icons out of the follower sprites. CSE already has colored, shiny-aware, cosmetic-form-aware icons. Taking the feature's version would have deleted that work. |
| Pinned the follower's species ID | CSE converts species between a real 16-bit index and a temporary 8-bit handle drawn from a small recycled table. Handles get evicted. The follower's now occupies a reserved slot (`LOCKED_MON_ID_FOLLOWER`) so a long walk cannot silently swap its sprite. |
| Appended script commands rather than renumbering | Both engines added new script commands at the same opcodes. The follower's nine were appended after CSE's, at `$b0`–`$b8`, so existing scripts keep working. |
| Reused CSE's icon palettes for the overworld | Instead of the feature's parallel palette table, the follower's colors came from `MonMenuIconPals`, already shiny-aware, mapped onto overworld palettes. **Since superseded** — followers now use the mon's own palette, see [Follower palettes](#follower-palettes). |
| Reserved map object slot 1 for the follower | The feature's design. CSE's object loading was adjusted to start map objects at slot 2. |
| Moved a ROM section rather than shrinking code | The feature overflowed bank 5 by 261 bytes. `"Load Map Part"` is only ever reached across banks, so it moved to a bank with room. |


## Where the code lives

| Path | Contents |
| --- | --- |
| `engine/events/follower.asm` | The follower's interaction table and all its dialogue scripts |
| `engine/overworld/overworld.asm` | `GetFollowingSprite` / `GetFollowerIconSprite` (builds the sprite), `_GetSpritePalette` (colors) |
| `engine/overworld/map_objects.asm` | `MovementFunction_FollowerObj` (the movement state machine), Poké Ball animation |
| `engine/overworld/player_object.asm` | `FollowObjTemplate`, `RefreshFollowingCoords`, warp/connection handling |
| `gfx/icons/*.png` | The party menu icons the follower is drawn from, 16×32 px = 8 tiles |
| `engine/overworld/map_object_action.asm` | `SetFacingFollowerStep` / `Run` / `Idle`, the two-frame cycle and the hop |
| `engine/gfx/color.asm` | `GetArrangedMonIconColors`, `LoadMonIconOBPal`, `WriteIconPalette` -- every icon surface resolves colors here |
| `engine/gfx/sprite_palettes.asm` | `CopySpritePal`'s `PAL_OW_FOLLOWER` branch and its time-of-day tinting |
| `data/pokemon/icon_palette_order.asm` | How each species arranges its two colors into an icon palette |
| `constants/ram_constants.asm` | `wFollowerFlags` bits |
| `engine/pokemon/party_menu.asm` | `PartyMenuToggleFollower` (SELECT) and `PlacePartyMonFollowerMark` (the star) |
| `engine/overworld/overworld.asm` | `GetFollowerMon` plus `SwapFollowerSlot` / `RemoveFollowerSlot` / `ValidateFollowerSlot`, the party-change fixups |
| `gfx/stats/party_menu_follower_mark.pal` | The one palette that lets a font tile be red |
| `engine/debug/fill_pc.asm` | Debug only: fills the PC with every species and form, for reviewing colors side by side |


## Bugs found and fixed

All of these assembled without warnings. Every one was found by playing the game.

**The follower vanished while walking.** CSE changed how a step starts: the caller passes the
animation to use in register `d`. Vanilla decides internally. The ported code passed nothing, which
means "stand still" — and an object told to stand still mid-step is skipped by the drawing routine.
Fixed by passing the walk animation, and the run animation when running shoes are active.

**NPCs turned into Poké Balls.** CSE uses the top bit of a sprite's tile number to pick a VRAM bank,
then strips it off. Vanilla has no such convention, so the ball's tile number meant one place to the
loader and another to the renderer, and the loader's copy landed on another character's graphics.
Fixed by encoding the tile the way CSE expects and parking the ball's 12 tiles in a genuinely free
gap.

**Garbage above talking NPCs and under jumping sprites.** The feature forces every temporary object
(speech bubbles, jump shadows) into VRAM bank 1. Harmless in vanilla, which has no banks; in CSE it
overrode the convention above and sent them into a region holding map tileset data, so they drew
scenery as sprites. Fixed by removing the override — CSE's own convention already handled it.

**The follower changed color after menus.** CSE assigns overworld palettes dynamically: one field
holds the *requested* color, and the engine decides which of the eight hardware slots to use. The
ported code wrote the requested color straight into the slot field. Fixed by writing to the request
field, plus a guard so it cannot recolor whatever else occupies that slot when no follower is out.

**The happy jump rendered the Pokémon as letters.** Not corruption — it was reading the font,
exactly as stored. While a text box is open, the font occupies the same tiles as walking frames and
shadows. Every other follower reaction animates *before* opening its box; this one opened the box
first. Fixed by reordering.

**The follower stopped hopping ledges after any scripted movement.** This one is upstream's, and
took two attempts — see [Bugs from the source branch](#bugs-from-the-source-branch).

Also fixed in passing: the paralysis reaction had `writetext` with no `opentext` and no `closetext`,
so it would have drawn text with no window.


## The tile budget

Three of the bugs above are the same constraint wearing different hats. Sprite graphics live in a
small, fixed area of video memory, and every object gets a hard-wired 12-tile slot based on its slot
number. Adding the follower added a fourteenth object, which pushed the arithmetic past what the old
split allowed.

| Region | Bank 0 | Bank 1 | Holds |
| --- | --- | --- | --- |
| Standing frames | `$00`–`$6b` | `$00`–`$3b` | 9 objects / 5 objects |
| Walking frames | `$80`–`$eb` | `$40`–`$7b` | The same objects, in motion |
| Poké Ball | `$6c`–`$77` | — | Follower recall animation |
| Emotes, shadow, grass | `$f8`–`$ff` | — | Speech bubbles, jump shadow |

The number tying it together is `FIRST_VRAM1_OBJECT_STRUCT` — where objects switch from bank 0 to
bank 1. Set it too low and bank 1's standing and walking frames collide; too high and there is no
contiguous gap left for the Poké Ball. With 14 object structs, only `9` works.

**Do not change `NUM_OBJECT_STRUCTS` without redoing this arithmetic.**


## Choosing your follower

The player picks. **SELECT on a party member makes it your follower; SELECT on the one already
marked clears the choice and nobody follows.**

`NewGame` writes slot 1 before the player has any Pokémon at all, which is the cheapest way to say
"the first one you are given follows you" — `GetFollowerMon` shows nobody while the party is empty,
then the starter lands in slot 1 and walks out of the lab behind you. Elm's aide explains the
button on the way out, after handing over the Potion (`AideText_FollowerTip` in
`maps/ElmsLab.asm`).

### Where the choice is stored

One byte, `wFollowerPartySlot`: `0` for nobody, otherwise a **1-based party slot**. It sits in the
saved block right after `wFollowerFlags`.

The original plan was to reuse a spare byte next to `wBikeFlags` so the save layout would not
shift. That turned out not to be worth the indirection: the follower port had *already* inserted
`wFollowerFlags` and the movement queue into the same region, so saves from before the feature were
invalid regardless. **Adding a byte here shifts everything after it, so a save made against an
earlier build of this hack will not read correctly** — that is the cost of the straightforward
placement, and it is only payable once per save-layout change.

The alternative was a bit on the mon's `MON_FORM` byte, where `%00100000` and `%01000000` were
free. That travels with the mon through every reorder and deposit with no fixups at all, which is
genuinely tempting — but a form byte gets copied wholesale into the PC, into trades and into bred
eggs, so a traded mon could arrive in someone else's game already flagged as their follower. A
stored slot's worst case is that it points at the wrong party member, which the player can correct
in two button presses; the form bit's worst case is mon data leaving the game with a stray bit set.
`%01000000` is now reserved for alternate shinies instead (`ALT_SHINY_MASK`).

### Keeping the slot pointed at the right mon

A stored slot number is only correct until the party changes under it, so five call sites maintain
it. All three helpers live in `engine/overworld/overworld.asm`:

| Event | Call site | What happens |
| --- | --- | --- |
| Reorder in the party menu | `switchpartymons.asm` | `SwapFollowerSlot` — swaps the stored slot when it is one of the two |
| Reorder in Bill's PC | `bills_pc.asm` | `SwapFollowerSlot` again, so the choice survives a shuffle |
| Release, trade, day-care | `RemoveMonFromParty` | `RemoveFollowerSlot` — clears to slot 1 if it was the mon leaving, decrements if it was after it |
| Deposit to the PC | `bills_pc.asm` | `ValidateFollowerSlot` — the deposited mon is shifted to the end first, so this catches it there |
| Withdraw | — | Nothing. New party members land at the end |

`RemoveMonFromParty` is the single funnel for every path that takes a mon out of the party — NPC
trades, link trades, Shuckie, mail, day-care and release all reach it — which is why one call there
covers four of the rules.

### The rules, and why

- **Deposited, released, day-cared or traded away → the follower defaults to slot 1.** Somebody
  should be out; falling back to nobody would read as a bug.
- **A fainted follower keeps its slot but stays in its ball.** `GetFollowerMon` returns 0 for it, so
  nobody is drawn, and it comes back out when healed without the player re-choosing.
- **There is no fallback to "the first living mon".** That is what the old `GetFirstAliveMon` did.
  Once the choice is the player's, quietly substituting a different Pokémon is worse than showing
  nobody — so `GetFollowerMon` returns 0 for an empty party, no selection, or a fainted selection,
  and never guesses.
- **Eggs can be chosen**, and walk around in the overworld. `LoadOverworldMonIcon` already has an
  egg icon, so this cost nothing and is funny.

### The marker

`PlacePartyMonFollowerMark` is a new `PARTYMENUQUALITY_FOLLOWER` entry in the party menu's quality
jumptable, modelled on `PlacePartyMonGender` — walk the party, step two rows per mon, draw at
`FOLLOWER_MARK_X`, `FOLLOWER_MARK_Y`. Unlike the gender symbol it does **not** skip eggs.

The glyph is `"★"` (tile `$C3`), placed on the entry's second row under the first letter of the
nickname, and it is red. The name row has no free cell: a ten-letter nickname fills columns 3–12 and
the HP digits 13–19, so a star on that row covers a letter of any long name.
Getting it red took a dedicated palette. Font tiles are 1bpp and ink with **color index 3**, which
is black in every palette the party menu otherwise loads — including `PREDEFPAL_HP_RED`, whose red
sits at index 2 because the HP bar tiles ink with *that* index. So
`gfx/stats/party_menu_follower_mark.pal` occupies BG palette slot `FOLLOWER_MARK_PAL` with red at
both 2 and 3, loaded by `InitFollowerMarkBGPal`, and the routine writes the slot number into
`wAttrmap` by hand at the same offset it wrote the tile.

That palette's red is `22, 00, 00` rather than the overworld's `30, 10, 06`. Muting a red here
means **lowering the red channel, not raising green and blue** — the overworld value's non-zero
green and blue wash the hue toward salmon against the menu's white paper.

### Letting SELECT through

Two things were in the way, and both were quiet rather than loud.

`PartyMenu2DMenuData` ends with an accepted-buttons byte, but `InitPartyMenuWithCancel` overwrites
`wMenuJoypadFilter` *after* `Load2DMenuData` returns — so editing the data table did nothing. The
filter is set to `PAD_A | PAD_B | PAD_SELECT` in the routine itself.

`PartyMenuSelect` then tests `B_PAD_SELECT` on `hJoyLast`, calls `PartyMenuToggleFollower`, and
**loops** rather than returning, so choosing a follower is not choosing a menu entry.
`PartyMenuToggleFollower` ignores the CANCEL row, toggles off if the cursor is already on the
follower, plays `SFX_READ_TEXT_2` and redraws so the star moves with the choice.

The jumptable was the other trap: adding `PARTYMENUQUALITY_FOLLOWER` to the constants without
putting the entry in the same position in `.Jumptable` sent the party menu into the mobile-battle
routine, which garbled the fifth slot and the area above every HP bar. The constants now live in
`constants/menu_constants.asm` so the table can carry `assert_table_length NUM_PARTYMENUQUALITIES`
and fail the build instead.


## Follower graphics

The follower is drawn from the same party menu icon the menus use. It has no artwork of its own.

### How a sprite gets built

`GetFollowingSprite` runs when the overworld needs the follower's graphics:

1. Pick the follower: `GetFollowerMon` reads the player's choice out of `wFollowerPartySlot` and
   returns nobody if the party is empty, nothing is selected, or the selection has fainted — see
   [Choosing your follower](#choosing-your-follower). Its 8-bit species handle goes in
   `wFollowerSpriteID` and is locked so it cannot be evicted; its 1-based party slot goes in
   `wFollowerPartyNum`.
2. Copy that member's form byte into `wForm`, then call `LoadOverworldMonIcon` — the same routine
   the day-care mons use. It returns the icon's graphics, bank, and length.
3. `GetFollowerIconSprite` assembles a 24-tile overworld sprite from it in `wDecompressScratch`.

Step 3 works because the two layouts line up. A menu icon is 8 tiles: two 2×2 frames, each stored
top-left, top-right, bottom-left, bottom-right. An overworld sprite wants 12 standing tiles — facing
down at `$00`, up at `$04`, left/right at `$08` — followed by the same 12 walking tiles at `+$80`,
in that identical order. So:

- **frame 1** is copied into all three standing facings,
- **frame 2** into all three walking facings,
- then the **down-facing** copies of both are mirrored in place, so walking towards the camera reads
  as a different pose from walking away rather than being identical.

The engine's own walk cycle then alternates the two frames, with no changes to the movement code.

Mirroring is done in software (`.MirrorFrameInPlace`): the two columns swap and every byte's bits
are reversed, since horizontal flipping of 2bpp data is a bit reversal. It runs once per sprite
load, not per frame.

### Forms, Unown and eggs come free

Because the lookup goes through `LoadOverworldMonIcon`, anything the icon system knows about works
without extra tables: cosmetic forms (that is what the `wForm` write feeds), Unown letters, and eggs
(`IconPointers` carries an `EGG is -3` entry ahead of the table). There is no separate follower
graphics table to keep in sync, and no per-form artwork to draw.

### The two-frame walk cycle, the idle, and the hop

The engine's normal walk cycle has four steps: standing, walking, standing, then **the walking frame
mirrored**. That last one is fine for hand-drawn NPC art but flips a mon icon left-to-right
mid-stride. `SetFacingFollowerStep` and `SetFacingFollowerRun` mask the step frame to one bit
instead of two, so the follower alternates only the first two. They are wired up as
`OBJECT_ACTION_FOLLOWER_STEP` and `OBJECT_ACTION_FOLLOWER_RUN`, chosen in
`MovementFunction_FollowerObj` according to the step speed.

Standing still, `OBJECT_ACTION_FOLLOWER_IDLE` keeps those two frames cycling off the object's own
counter -- one flip every 16 frames -- so a waiting follower animates the way a hovered party menu
icon does. The follower's movement function used to simply return when it had nowhere to go,
leaving whatever action was last set and freezing the icon on one frame. A follower frozen by a
script still uses `OBJECT_ACTION_STAND` and stays genuinely still.

While walking, `OBJECT_SPRITE_Y_OFFSET` lifts the sprite a pixel to turn the frame swap into a
hop. It has to lift the **standing** frame, not the walking one: an icon's second frame is a
squash with the feet planted -- both frames end on the same bottom row and the second begins one
or two rows lower -- so lifting the squashed frame merely cancels the squash, leaving the top
still while the bottom rises. Lifting the extended frame instead reads as squash, then spring.
Actions run after step functions and a normal step never touches the sprite offset (only jumps do,
and they use their own actions), so the two never fight; the idle action clears the offset.

## Follower palettes

### How a color gets chosen

The follower is colored from **the mon's own palette** -- the same two colors its battle sprite
uses -- not from the overworld's shared color set. `_GetSpritePalette`:

1. Point at the follower's `MON_FORM` byte and call `GetMonNormalOrShinyPalettePointer`, which
   resolves species, cosmetic form and shininess in one step and returns a pointer to two colors
   in `data/pokemon/palettes.asm` or `data/pokemon/cosmetic_palettes.asm`.
2. Hand the two colors to `StoreFollowerPalette`, which keeps them in `wFollowerPalette` and, if
   they changed, frees whichever hardware slot was holding the old ones.
3. Return `PAL_OW_FOLLOWER`, a reserved index that sits past every counted `PAL_OW_*` range.
4. `CopySpritePal` special-cases that index: instead of indexing a palette table it reads
   `wFollowerPalette` and builds white / color 1 / color 2 / black, the same shape every mon pic
   uses. It reads those bytes before switching WRAM banks -- they do not live in the palette
   bank, so anything left unread by then comes back as zeroes and the follower renders black.

Step 2 matters. `MarkUsedPal` dedupes by palette index, so without the invalidation it would see
`PAL_OW_FOLLOWER` already loaded after a party change and keep showing the previous mon's colors.

### Time of day

`PAL_OW_FOLLOWER` sits above the range `CopySpritePal` gives morn/day/nite/eve variants to, so the
tinting is done in the follower branch itself, by `.TimeOfDayAdjust`.

It only has two cases to handle. Comparing the daytimes in `gfx/overworld/npc_sprites.pal`, morn,
day and eve leave a sprite's own two colors essentially untouched -- nearly all the difference
between them lives in color 0, which an OBJ palette never draws. So:

- **Night** halves red and green and keeps about seven eighths of blue, which is close to what the
  authored palettes do (day `31,19,10` becomes `16,09,09`; the formula gives `15,09,09`). It is a
  cool darkening rather than an even dim, so the follower matches the NPCs beside it.
- **An unlit cave** takes the character silhouette straight out of `DarknessOBPalette` and ignores
  the mon's colors entirely. That table is not uniform -- items use a darker row than characters --
  so the follower reads the character entry.

The catch is that `MarkUsedPal` dedupes by palette index and would happily leave stale colors on
screen through a sunset. `InvalidateFollowerPalette` frees the slot, and `timeofday_pals.asm` calls
it immediately before its existing `CheckForUsedObjPals`.

### What this costs

- **One of the eight hardware OBJ slots is now permanently the follower's**, on every map. Every
  NPC on screen competes for the remaining seven. Busy maps are where to look for regressions.
- **The night tint is a formula, not authored art.** It will not match a hand-made palette for
  every mon, and a shiny whose colors are already dark may go close to black once halved.

### Do shiny followers show shiny colors?

Yes, and they are now the mon's **true** shiny colors rather than a shiny icon color.
`GetMonNormalOrShinyPalettePointer` checks the shiny bit in the form byte and advances to the
shiny pair of the same table the battle sprite reads.

This also removed a whole class of invisible-shiny bug: `menu_icon_pals.asm` listed the same
color for normal and shiny on 38 of 255 species, so those looked identical shiny or not. The mon
palette tables always carry a distinct shiny pair.

### Rearranging the two colors

An icon reuses the mon's two pic colors, but icon art is not always shaded the same way round, so
`data/pokemon/icon_palette_order.asm` carries one byte per species saying how to arrange them:
`ICON_PAL_SWAP` exchanges the pair, and `ICON_PAL_OFFWHITE` replaces whichever color lands in the
light slot with white. They combine, which is how a species picks *which* of its two colors
survives. Per-form exceptions go in a short scanned list ahead of it.

It started as a sparse exception list and became dense once about half the dex wanted an entry --
at that point 251 bytes and a direct index beat 348 bytes and a linear scan.

### Cosmetic forms

Form colors come free, because `GetMonNormalOrShinyPalettePointer` consults
`CosmeticFormPalettePointersTable` before falling back to the per-species table. A blue Smeargle
follower is blue; a teal Scyther is teal. Forms that differ only in shape (Unown letters, Magikarp
sizes) have no entry in that table and correctly fall back to the species' colors.

### Where else the same palettes are used

All three surfaces now read the mon palette tables rather than the eight shared icon colors:

| Surface | How it applies the color |
| --- | --- |
| Party menu | `InitPartyMenuMonOBPals` gives each party slot the OBJ palette of its own number, holding that mon's colors; `LoadPartyMenuMonIconColors` writes the slot number into OAM |
| Box (Bill's PC) | `WriteIconPaletteData` -> `GetMonPalInBCDE` copies the two **RGB values** into a per-slot palette (`wBillsPC_MonPals*`) |
| Overworld follower | `PAL_OW_FOLLOWER` plus `wFollowerPalette`, as above |

The party menu can do this because it only needs six palettes at once, one per slot. The red the
held-item indicator wants used to be palette 0; it now lives at `PARTY_MENU_ITEM_PAL` (6), since
palette 0 belongs to the first party mon.

Every icon surface now resolves through `GetArrangedMonIconColors`. The single-icon screens --
naming, move list, and the Pokegear's Fly map -- share `SetSingleMonIconColor`, which loads
`MENU_MON_ICON_PAL`; the trade screen uses `TRADE_MON_ICON_PAL` instead, because its palette 7 is
the trade tube. `MonMenuIconPals`, `GetMenuMonIconPalette` and `SetMenuMonIconColor` are dead as a
result, kept only until the converted screens have been eyeballed.

Two of those were quietly broken before the conversion rather than by it. The Fly map read
`wCurPartySpecies`, which nothing on that screen sets, and `_CGB_PokegearPals` only defines OBJ
palettes 0 and 1 -- so the icon picked an undefined palette left over from the overworld. The
trade screen had no form byte at all (the animation still carries a `TODO: load wForm`) and fed
the mon's *DVs* to the shiny check, so any mon whose first DV byte had bit 7 set came out shiny.

## Bugs from the source branch

These are defects in `follow-mons` itself rather than artifacts of porting it here — they would
reproduce on plain pokecrystal. Written up so they can be contributed back.

### 1. The follower stops hopping ledges after any scripted movement

**Symptom.** Talk to a happy follower so it jumps for joy, or trigger any cutscene that moves it,
and from then on it walks over ledges instead of hopping them, and stops sliding on ice. Crossing
into a new map fixes it.

**Cause.** `Movement_step_end`, which ends every `applymovement`, calls `RestoreDefaultMovement`,
and that reads the movement type back out of the object's *map object* entry. `FollowObjTemplate` in
`engine/overworld/player_object.asm` declares `SPRITEMOVEDATA_FOLLOWNOTEXACT`, which is plain
following with no ledge-hop or slide handling. The richer `SPRITEMOVEDATA_FOLLOWEROBJ` state machine
is only ever installed at runtime, by `RefreshFollowingCoords`, which runs during map setup. So each
of the 50-plus `applymovement FOLLOWER` sites silently downgrades the follower until the next map
load. A scripted movement also leaves `wFollowerNextMovement` wherever its sequence stopped.

The author appears to have hit this: `maps/NewBarkTown.asm` carries a `callasm .follower_movement_fix`
that zeroes `wFollowerNextMovement` right after an `applymovement FOLLOWER`, commented "hacky fix".

**Fix.** Two parts. Changing `FollowObjTemplate` to `SPRITEMOVEDATA_FOLLOWEROBJ` makes
`RestoreDefaultMovement` return the right mode, and is the correct default — but on its own it did
not clear the symptom in testing, so the state is also restored explicitly. Added to
`engine/events/follower.asm`:

```asm
RestoreFollowerAfterMovement:
	xor a
	ld [wFollowerNextMovement], a
	ld a, FOLLOWER
	call GetObjectStruct
	ld hl, OBJECT_MOVEMENT_TYPE
	add hl, bc
	ld [hl], SPRITEMOVEDATA_FOLLOWEROBJ
	ret
```

called with `callasm RestoreFollowerAfterMovement` immediately after each `applymovement FOLLOWER`
in that file. For upstream the cleaner form would be to perform this restore inside
`Movement_step_end` (or `RestoreDefaultMovement`) whenever the object is the follower, which would
cover the map scripts too and let the NewBarkTown hack be deleted.

### 2. The joy-jump animation renders the Pokemon as font tiles

**Symptom.** Talking to a happy follower makes it jump — as letters, with digits for a shadow.

**Cause.** `DefaultInteraction` runs `opentext` *before*
`applymovement FOLLOWER, .followerjumptest`. While a text box is open the font occupies vTiles1,
which is the same region that holds objects' walking frames and the emote and shadow tiles. The jump
uses walking frames and spawns a shadow, so both read the font. Every other interaction in the file
emotes *before* opening its box.

**Fix.** Move `followcry` and the `applymovement` ahead of `opentext`, and give the `.give_item`
branch its own `opentext`.

### 3. ParalyzeInteraction has no text box

**Symptom.** Talking to a paralyzed follower draws text with no window.

**Cause.** The script is `showemote` / `writetext` / `end` — missing `opentext` and `closetext`,
unlike every sibling interaction.

**Fix.** Add `opentext`, `followcry` and `closetext` to match the others.

### 4. SPRITE_FOLLOWER has no OverworldSprites entry

**Symptom.** Latent; needs the follower object present with no usable party member.

**Cause.** The branch changes `data/sprites/sprites.asm` to
`assert_table_length NUM_OVERWORLD_SPRITES - 1`, deliberately leaving `SPRITE_FOLLOWER` without a
table entry because `GetFollowingSprite` intercepts it first. But when there is no follower species
that interception falls through to `GetMonSprite` and then to the table lookup, which indexes one
entry past the end of `OverworldSprites` — yielding a garbage pointer *and* a garbage tile count for
the VRAM copy that follows.

**Fix.** Return the engine's existing "no sprite" fallback when the party yields no follower, instead
of falling through to the table.

### 5. _SetPlayerPalette is dead code that would corrupt memory

In upstream's `engine/overworld/map_objects.asm`. Nothing calls it. It contains `ld bc, 0 ; debug?`
followed by `ld hl, OBJECT_DIRECTION` / `add hl, bc`, so it would read and write near address `$0008`
rather than an object struct. Harmless while unreferenced; worth deleting before someone wires it up.
It never reached this repo — the merge dropped it — so there is nothing to fix on our side.

### 6. CheckFollowerLoaded is stubbed out

In `engine/overworld/player_object.asm` the routine opens with `xor a` / `ret`, making the loop below
it unreachable and the follower unconditionally spawned. Looks like leftover debugging.

### 7. The follower vanishes next to a pacing NPC

**Symptom.** Stand still where an NPC's patrol route crosses the follower's tile — the blue-shirted
woman in southern Cherrygrove is a reliable spot — and after a few of her passes the follower
disappears. The graphics are still in VRAM; it simply stops being drawn.

**Cause.** `HideFollowerIfNPCBump` hides the follower whenever an NPC would walk into it, setting
`FOLLOWER_INVISIBLE_F` and `FOLLOWER_INVISIBLE_ONE_STEP_F` so the NPC can pass through. The matching
restore lives in `CheckFollowerInvisOneStep`, which begins `cp PLAYER` / `ret nz` — so it only runs
while the *player* is taking a step. Stand still and nothing ever puts the follower back.

The author clearly intended a different condition: the restore contains a commented-out call to
`IsObjectStandingOnSomeoneElse` with its `ret c` still live underneath, guarding on a carry flag
nothing sets any more.

**Fix.** Added `TryRestoreHiddenFollower`, called from `MovementFunction_FollowerObj` so it runs
every frame the follower is idle rather than only on player steps. It restores visibility once
`IsNPCAtCoord` reports nothing else on the follower's tile — the check the commented-out code was
reaching for. `IsNPCAtCoord` already excludes the calling object, so the follower does not detect
itself. The dead `ret c` and its commented block were removed.

### 8. FrozenInteraction emotes on the player

It uses `showemote EMOTE_SHOCK, PLAYER, 40` where its siblings target `FOLLOWER`. Possibly
deliberate — flagged as a question rather than a defect.

### Not a bug upstream, but worth telling them

`InitSprite` gains a branch forcing every temporary object (`OBJECT_SPRITE == -1`) into `OAM_BANK1`.
Vanilla has no VRAM-bank-1 objects, so it does nothing there — but it silently breaks any engine
that does put objects in bank 1, by hijacking emotes and jump shadows. Worth a comment upstream
explaining what it is for.


## Known gaps

- **Follower speed on a bicycle is untested.** The animation timings came from vanilla, which has
  neither running shoes nor a 60fps overworld.
- **The Poké Ball recall animation shares a tile region with map graphics** that vary by tileset. It
  looks correct where it has been tested; worth a look on unusual maps.
- **Icons always face the camera.** A follower walking away from you still faces forwards; the
  mirrored down-facing frames are the only cue to travel direction.
- **`FrozenInteraction` shows its emote above the player**, not the follower, unlike its siblings.
  Possibly deliberate; flagged in case it is not.
- **The follower now owns one of the eight hardware OBJ palettes on every map.** Maps that already
  used all eight will lose a color. Worth watching in Goldenrod, the Celadon department store and
  the underground.
- **Deselecting a follower makes it vanish rather than returning to its Poké Ball.** The recall
  animation already exists for warps and should be reused here.

## TODO

- **Delete the dead icon path.** `MonMenuIconPals` (~255 bytes), `GetMenuMonIconPalette` and
  `SetMenuMonIconColor` have no callers left. Held back only so the converted screens can be
  compared against the old behaviour; remove once they have been checked.
- **Audit which forms want their own shiny colors.** Several forms still reuse their base form's
  `shiny.pal`, so they are indistinguishable from each other when shiny even though they now
  differ normally. All four Pikachu forms share `pikachu/shiny.pal`, for instance. Data, not code.
- **Pikachu RB is a plain icon in RB colors.** `PikachuIconPointers` maps the RB form back to
  `PikachuPlainIcon` while `PikachuPalettes` gives it its own paler yellow. That may be intended;
  it only became visible once icons stopped using the eight shared colors. Surf and Fly were the
  same kind of mismatch in reverse -- greyscale artwork with no palette pointing at Pikachu's --
  and now take Pikachu's colors outright.
