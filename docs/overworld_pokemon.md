# Overworld Pokémon

Pokémon standing in the world rather than in a battle: the ones that have always been there as map
objects, and the ones that now wander a route and can be walked into.

Two features, built in that order, sharing one mechanism.

## Contents

- [Why they used to be the wrong species](#why-they-used-to-be-the-wrong-species)
- [Mon slots](#mon-slots)
- [Colors](#colors)
- [Sprites are built from menu icons](#sprites-are-built-from-menu-icons)
- [Wandering wild Pokémon](#wandering-wild-pokémon)
- [The rolled encounter](#the-rolled-encounter)
- [The area tables](#the-area-tables)
- [Perks and balance knobs](#perks-and-balance-knobs)
- [Meeting one](#meeting-one)
- [Saving and loading](#saving-and-loading)
- [Populations](#populations)
- [Swarms](#swarms)
- [Roaming beasts](#roaming-beasts)
- [Checks](#checks)
- [Bugs worth remembering](#bugs-worth-remembering)
- [Known gaps](#known-gaps)


## Why they used to be the wrong species

Red and Blue had a handful of hand-drawn overworld Pokémon sprites, and Gold/Silver kept them: 35
species, listed in `data/sprites/sprite_mons.asm`. Any other species that needed to stand in a room
borrowed the closest one available. Blackthorn's Dratini was an Ekans, Mr. Fuji's Psyduck a Rhydon,
the four Miltank on Route 39 a herd of Tauros — **43 objects across 28 maps** showing the wrong
Pokémon.

That compromise made sense when a sprite was 12 tiles of bespoke artwork. It stopped making sense
here, because CSE draws overworld Pokémon from their **party menu icons**, which exist for all 251
species and every cosmetic form. The artwork was never the problem. The one-byte sprite id was.


## Mon slots

A map object's sprite field is one byte, which cannot hold a 16-bit species index — let alone a
cosmetic form or a shiny flag. So `SPRITE_OW_MON_1`..`_4` name a **slot**, and something else says
what the slot holds.

```asm
object_event  5,  5, SPRITE_OW_MON_1, SPRITEMOVEDATA_POKEMON, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, SomeScript, -1
```

`GetOverworldMonSlot` (`engine/overworld/overworld_mons.asm`) resolves one, and it looks in two
places:

1. **A rolled encounter**, if this map has one in that slot — see
   [wandering wild Pokémon](#wandering-wild-pokémon).
2. **`data/maps/overworld_mons.asm`**, a sparse table keyed by map, for the fixed NPCs. 54 maps,
   61 entries, about 350 bytes. It is scanned rather than cached, which keeps it out of WRAM and
   therefore out of the save.

The four slots fill in a fixed order — a map's static entries first, then its grass slots, then
its water ones — and `RollOverworldMons` starts rolling above whatever the static table already
owns. Without that, a roll into slot 1 would redraw the static mon that slot belongs to: the whole
Route 39 Miltank herd becoming whatever wandered in.

Objects may share a slot: the six Rocket Base Electrode and the four Route 39 Miltank each declare
one entry between them. Many maps with wandering mon sit at the four-slot ceiling; the ones below
it are held there by the [four-color limit](#four-pokémon-colors-per-map), by the object limit (on
Route 32), or by lack of room on the map. The Red
Gyarados is deliberately *not* a slot: it keeps vanilla's `SPRITE_GYARADOS` icon sprite in the NPC
red and `SPRITEMOVEDATA_POKEMON` bobbing, so the lake's three Magikarp share the map with it.

**Elm's starters are static entries whose shininess comes from the lab.** Their `ow_mon` rows carry
`ELMS_STARTER_FORM` (form bit 5, never stored) instead of a fixed form. `GetOverworldMonSlot`
resolves it through `IsStarterShiny`, which looks the species up in `StarterShinyFlags` and reads
the flag that `RollElmsLabStarters` set when the player walked in. The same marker on the starters'
`givepoke` makes GivePoke store that shininess and skip its gift roll, and `IsStarterShiny` also
makes Silver's stolen line shiny in rival battles. The leftover starter's wandering object shares
its table object's slot, so it carries the same shininess.

**`SpriteMons` still exists** and still earns its keep — 20 of its 35 entries are load-bearing for
room decorations, which map each doll to a `SPRITE_*`.


## Colors

Every overworld Pokémon is drawn in **its own colors**, the two its battle sprite uses, arranged by
`data/pokemon/icon_palette_order.asm`. The same treatment the follower gets, and it covers the
dolls and the day-care mons too.

`MarkUsedPal` dedupes by palette *index*, so each distinct mon on screen needs its own.
`ClaimOverworldMonPalette` hands one out from `PAL_OW_MON_1`..`_4`:

1. `_GetSpritePalette.is_pokemon` reads `wCurIcon` and `wForm`, which `GetMonSprite` has just
   filled in. A mon slot, a `SpriteMons` id, a doll's variable sprite and a day-care mon therefore
   all arrive by the same door.
2. `GetArrangedMonIconColors` turns those into two colors.
3. The claim searches `wOverworldMonPals` for those exact colors, reusing the index if they are
   already there. **Identical mon share an index**, which is what keeps six Electrode to one
   palette.
4. `CopySpritePal` reads the entry back and bookends it white and black, sharing the follower's
   code including its time-of-day tinting.

The table resets in `LoadMapObjects` — deliberately *not* in `ClearSavedObjPals`, which also runs
on returns from menus and battles where nothing reclaims, and an index left pointing at a cleared
entry would draw the mon black.

Two paths skip `LoadMapObjects` and rebuild the table themselves with `RefreshOverworldMonPalettes`,
which resets it and re-derives every standing wandering mon's colors: the continue path, and the
reload after a battle on a [population](#populations) map. Without the second, a species-mode
population claims a new entry per reshuffle, fills all four in a couple of battles, and every
later member falls back to palette 0 — red.

**The budget is eight hardware OBJ palettes and the follower permanently owns one.** That is why
`wOverworldMonPals` has only `NUM_OW_MON_PALS` = 4 entries.

### Four Pokémon colors per map

A map can show **four distinct Pokémon color pairs**, and the four are shared by everything that
takes one, not only the wandering mon.

- **What counts:** any object `GetMonSprite` draws as a Pokémon, with palette byte `0`:
  - the `SPRITE_OW_MON_1`..`_4` slots, wandering or static (each slot is one);
  - `SpriteMons` sprites, `SPRITE_UNOWN` to `SPRITE_HO_OH`, such as Vermilion's Machop;
  - the day-care mon, `SPRITE_DAY_CARE_MON_1` / `_2`;
  - Raikou, Entei and Suicune's own sprites, including Suicune's one-time sightings, since they
    share a visit with the wanderers;
  - dolls, through variable sprites (the player's room only).
- **What doesn't:** an object with its own palette byte skips the claim, as the Red Gyarados
  (`PAL_NPC_RED`) and the silver beast statues do. `SPRITE_SURF`, the big Snorlax, Lapras and Onix
  and the other ordinary sprites aren't Pokémon sprites to this code. The follower has its own
  index, `PAL_OW_FOLLOWER`.
- **When it's spent:** a claim happens when an object spawns, and the table only resets when the
  map loads (and on the two `RefreshOverworldMonPalettes` paths). So it counts every distinct mon
  that appears during one visit, not only the ones on screen together. An empty slot and an object
  hidden by its event flag claim nothing.
- **Past it:** no crash and no wrong graphics, but the fifth pair's mon is drawn in palette 0,
  **flat red**. A beast that misses keeps its classic sprite-table color, which looks normal. Which
  object misses depends on spawn order.

Two wanderers of one species share an entry, but the roll can't promise that, so each slot is
budgeted as one. A map's slots plus its other Pokémon sprites must come to four or fewer, which is
why Route 36 and Route 42 stop at three wanderers (Suicune), Route 34 at two (the day-care mon),
and Vermilion City and Cianwood City at three water mon (the Machop; Suicune). Both build checks in
[Checks](#checks) enforce it.

A second limit is per screen: when all eight hardware palettes are in use, `MarkUsedPal`
overwrites hardware slot 7, so some on-screen object shows the wrong colors until it scrolls
away. That depends on how many NPC colors share a screen with the mon, not on the mon alone.


## Sprites are built from menu icons

A party menu icon is **8 tiles**: two 2×2 frames. An overworld sprite is **12 standing + 12
walking**, with down at `$00`, up at `$04`, left/right at `$08`.

`ExpandMonIconToSprite` (`engine/overworld/overworld.asm`) bridges the two: frame 1 into all three
standing facings, frame 2 into all three walking facings, then the down-facing copies mirrored in
place so walking towards the camera reads differently from walking away. Mirroring is done in
software — a horizontal flip of 2bpp data is a bit reversal — once per sprite load.

It is shared with the follower, and `GetMonSprite.Mon` routes every overworld Pokémon through it.

A standing Pokémon (`SPRITEMOVEDATA_POKEMON`, the bounce) therefore alternates *standing up* and
*walking up*: the icon's two frames, unmirrored, as in the party menu. `SetFacingBounce` checks the
object's sprite for that; any other sprite on the bounce, such as the shaman house's campfire, keeps
flipping between its own down and up frames.


## Wandering wild Pokémon

A Pokémon that wanders a route. Walk onto it, or face it and press A, and it starts a **wild**
battle — with the mon you were looking at.

| Piece | Where |
| --- | --- |
| `OBJECTTYPE_WILDMON`, the proximity and talk triggers, the battle script | `engine/overworld/events.asm` |
| The roll, the masks, the battle setup | `engine/overworld/overworld_mons.asm` |
| Rosters | `data/wild/overworld_mons.asm` |
| Which water species ride on the surface | `data/wild/surface_mons.asm` |
| Struct, perks, table shape | `constants/overworld_mon_constants.asm` |
| Reading the roll instead of rolling | `engine/battle/core.asm`, in `LoadEnemyMon` |

An object opts in with `OBJECTTYPE_WILDMON`, a `SPRITE_OW_MON_*` sprite, palette byte `0` so it
takes the mon's own colors, and `SPRITEMOVEDATA_WANDER_NOCLIP` (or `SWIM_WANDER_NOCLIP` on water).
Its event flag is usually `-1`: whether one is standing there is decided by whether its slot holds
a mon, not by a flag.

**On water, a mon swims in it or rides on top by species.** `SWIM_WANDER_NOCLIP` sinks a mon to
the waist. The species listed in `SurfaceRidingMons` (`data/wild/surface_mons.asm`) — Tentacool,
Magikarp, Goldeen and the like — float instead: the water pass sets the slot's bit in
`wOverworldMonOnSurface`, and `CopySpriteMovementData` takes `OVERHEAD` back off its object. A
roster row has no say, so a new water row or a swarm can't get it wrong. Adding a floating species
is one line in that list.

**An Unown shows an unlocked letter, by species.** `RollOverworldMons.RollUnownLetter`, first in the
shared roll tail, gives any wandering Unown a random letter from the unlocked groups — the floor's
own pick, `GetUnownLetter` and `CheckUnownLetter` — whatever its row's form column says. With no
group unlocked it publishes the slot empty instead, which is also `ChooseWildEncounter`'s gate on
the floor: `CheckUnownLetter` rejects every letter then, and its retry loop would never end.

**A flag other than `-1` reads inverted on these objects.** Everywhere else in the game an event
flag hides an object once it is *set*; on an `OBJECTTYPE_WILDMON` object it does the opposite — the
mon appears only once that event has happened. `UpdateOverworldMonObjectMasks` checks it before
unmasking. The ordinary sense would be useless here, since an empty slot already hides these, and
the field was otherwise dead on them. It is how a roster waits for something: Slowpoke Well B1F
carries `EVENT_SLOWPOKE_WELL_ROCKETS`, so nothing wanders the well until the Rockets clear out.


## The rolled encounter

**The whole encounter is decided when the map is entered, and the battle reads it back rather than
generating its own.** That is the core of the design, not an optimisation.

`LoadEnemyMon` normally generates the form byte (which carries `SHINY_MASK`), the DVs and the held
item at the moment the battle starts — long after the sprite was drawn. Roll twice and they
disagree, so an ordinary-looking sprite turns into a shiny, or into a different cosmetic form, the
instant you touch it.

So `wOverworldMonEncounters` holds, per slot: species index, form byte, level, DVs, held item,
perks, and an extra move. `LoadEnemyMon` gains three branches, at the three points where it already
branched on `wBattleType` for roaming mon and the Bug Catching Contest. They do not test
`wBattleType`: `wOverworldMonBattleSlot` is non-zero exactly when the battle is against a wandering
mon, and testing that leaves the battle type free for the contest.

| What | Where | The `wOverworldMonBattleSlot` branch |
| --- | --- | --- |
| Held item | `.UpdateItem` | take the rolled item |
| DVs | `.GenerateDVs` | take the rolled DVs |
| Form and shininess | `.check_unown`, before the Unown letter roll | take the rolled form byte whole (`.overworld_mon_form`) |

The move is applied by `ApplyWildMonMove`, after `FillMoves` and before the PP fill so it gets
PP for free. The same routine gives a swarm's grass or surf mon its swarm's move, from
`wTempWildMonMove` (see [Swarms](#swarms)). If the mon already knows the move nothing changes;
otherwise it fills an empty slot, or replaces move 1, the earliest learned, if the mon already
knows four. **It is
stored as a 16-bit move index, not an 8-bit ID** — IDs come from a recycled table and can be
evicted, and the roll may be minutes old.

### When the roll happens

`RollOverworldMons` runs from `HandleNewMap`, which fires on warps, connections and fly — and
**not** on returning from a battle or closing a menu. That is what makes a route reroll when you
leave and come back, and hold still otherwise.

Getting this wrong is easy: `MAPCALLBACK_OBJECTS` and `LoadMapObjects` run on *every* map setup,
including the one after a battle, so rolling there would change the species of the mon you just
fled from while you watched.

### Hiding the ones that did not appear

A slot the roll leaves empty, and a slot whose mon has been battled, must not be drawn.

The obvious mechanism would be an `EVENT_TEMPORARY_UNTIL_MAP_RELOAD_*` flag, which clears on
exactly the right boundary — but **all eight are already spoken for** by Bill's house, the Dragon
Shrine, Goldenrod Underground, Kurt's house, Player's house, the ports, the Route 36 gate and the
link rooms. There is no ninth short of extending the reset and shifting every event flag in the
game.

So there is no flag. `UpdateOverworldMonObjectMasks` writes `wObjectMasks` directly, from
`LoadMapObjects` and **after** `LoadObjectMasks` has rebuilt the array. **A slot being empty is the
hidden state**, with nothing standing in for it, and the routine masks and unmasks so it is the
whole truth and can be called from anywhere.


## The area tables

`data/wild/overworld_mons.asm` holds **two** tables, `OverworldWildMonsGrass` and
`OverworldWildMonsWater`, the way `JohtoGrassWildMons` and `JohtoWaterWildMons` are two tables.
`RollOverworldMons` runs one pass over each — grass slots draw only from the grass table, water
slots only from the water one. A map appears in whichever tables it needs, and in both if it has
slots on both.

```asm
	def_ow_wildmons ROUTE_29
	db 2 ; how many can be out at once -- one SPRITE_OW_MON_n object each
	db 100 percent ; the chance each one shows up
	; morn
	ow_wildmon 30, PIDGEY,  3, PLAIN_FORM, 0, PURSUIT
	...
	end_ow_wildmons
```

A single blended roster was tried first and read badly: the water table concentrates its odds in
three fat entries and crowded the land mon out of a four-entry roster, so Tentacool turned up in
fields.

`ow_wildmon` is **weight, species, level, form, perks, move**. Weights are out of 100 within their
time of day; a block adding to less than 100 falls through to its last entry more often. Four
choices per time of day, fixed width so a daytime can be indexed rather than walked. Evening
shares the night roster, as the grass tables do.

The form byte takes a cosmetic form, `SHINY_MASK`, or both — so a roster can specify a Surfing
Pikachu, or one that is always shiny.

These are **separate from the grass and water tables** on purpose. The species overlap but nothing
else does: their own odds, a shorter list, a chance of nobody appearing, and per-entry forms,
perks and moves that a grass encounter has no field for.


## Perks and balance knobs

Every wandering Pokémon, as named constants in `constants/pokemon_data_constants.asm` beside the
other shiny rates:

| Constant | Value | Against |
| --- | --- | --- |
| `OVERWORLD_MON_SHINY_NUMERATOR` | 128/65536 = 1/512 | a grass encounter's 1/8192 |
| `OVERWORLD_MON_MIN_DV` | 6 of 15, as a floor on each DV | a free roll |
| `OVERWORLD_MON_NO_ITEM_CHANCE` | 20% | a grass encounter's 50% |

Per entry, an `OW_PERK_*` bit field:

- `OW_PERK_ALWAYS_ITEM` — skip the item roll
- `OW_PERK_EXTRA_SHINY` — `OVERWORLD_MON_EXTRA_SHINY_NUMERATOR`, currently 1/256

**The perks use `shift_const`**, giving each both a value for the tables and an `_F` bit number for
the code. That is not decoration: a plain `1, 2, 3` enumeration reads fine in the data and is a
trap in the engine, because `bit OW_PERK_EXTRA_SHINY, a` against value 2 tests bit 2, which is
never the bit that was set.

The extra-shiny roll deliberately **skips the 1/256 gate** that every other shiny roll uses.
Behind that gate no numerator can push a perk past about 1/257, so the perk would be a rounding
error rather than a reward. Its numerator is therefore out of 256, not 65536.

Adding a perk is one `shift_const` and one branch in the roller. The perks byte is carried into the
encounter struct, so a perk that has to act during the *battle* still has its flags to hand.


## Meeting one

Two triggers, sharing `TryClaimOverworldMonBattle`:

- **Walk onto it.** `OW_MON_TRIGGER_DISTANCE` is `0` — the same tile. They do not block the player
  (the player's bump check takes the same exit the follower uses), and `NOCLIP_OBJS` lets them walk
  onto *you*.
- **Face it and press A.** `.wildmon` in `ObjectEventTypeArray`.

The overlap check requires the mon to be **standing**, not mid-step. An object's map coordinates
change when a step *begins*, not when the sprite arrives, so without that a mon walking towards you
triggers while it is still visibly a tile away.

**Any finished battle spends it** — beaten, caught or run from, it is gone until the route is left
and re-entered. Two kinds of map reshuffle after a battle instead: a population (see
[Populations](#populations)) and a swarming route (see [Swarms](#swarms)). `wBattleResult` could tell those apart; nothing consults it, because there is
nothing to decide.

Two touches around the encounter: the player and the follower are hidden for the battle transition
so only the mon is on screen, and a route that rolled a shiny plays `SFX_SHINE` once, the first
frame the player has control.


## Saving and loading

`MapSetupScript_Continue` is a different path: it uses `LoadMapAttributes_SkipObjects` and never
calls `HandleNewMap` or `LoadMapObjects`. But **map objects are inside the save block and the
encounters are not**, so without help the wandering mon come back pointing at slots holding
whatever was left in WRAM.

`RollOverworldMonsOnContinue` is a mapsetup command added only to that script — it could not go in
`HandleContinueMap`, which `HandleNewMap` falls through into and would have rolled twice. It
rolls, updates the masks, and calls `RefreshOverworldMonPalettes`, which re-derives every wandering
mon's palette index; the palette state *is* saved, so otherwise a fresh Tentacool wears the
previous Pikachu's colors.

**Consequence: reloading a save rerolls the route**, the same as walking out and back. Reload
scumming for a shiny therefore works. Moving the encounter struct inside `wGameData` would close
that, at the cost of a save-layout shift.

Populations keep one thing across a save: each member's **species**, in `wPopulationSpecies`
inside `wPlayerData`. The continue roll restores those and rolls everything else afresh. See the
next section.


## Populations

A second kind of wandering mon, for a few special maps: a standing group that **reshuffles every
time you battle one of its members** rather than rerolling when you leave. Hidden Grove, the
Bug Catching Contest and the Ruins of Alph Inner Chamber use it. This is the map of where it lives.

| Piece | Where |
| --- | --- |
| Table: `def_population`, `spawn_area`, `pop_mon`, `end_population` | `data/wild/mon_populations.asm`, macros in `macros/asserts.asm` |
| Modes, row layout, `POP_WILD_FORM`, placement limits | `constants/overworld_mon_constants.asm` |
| The roll (`RollOverworldMons.RollPopulation`), the reroll, placement, the reload command | `engine/overworld/overworld_mons.asm` |
| Placement hook on every warp | `LoadMapObjects` in `engine/overworld/map_setup.asm` |
| Reroll hook and the contest branch | `OverworldMonBattleScript` in `engine/overworld/events.asm` |
| Reload command | `PlacePopulationAndSpawn` in `MapSetupScript_ReloadMap` |
| Saved species | `wPopulationSpecies` in `ram/wram.asm` |

How it differs from a route roster, in one line each:

- A map has a population **or** an area roster, never both; the population roll fills the slots
  and the grass and water tables are not consulted.
- **Placement**: members are scattered over authored rectangles (anywhere on the map when a
  population lists none), on land, clear of the player and of every other object, from a 16-bit xorshift seeded once per pass — the hardware RNG is nearly
  constant with the LCD off. The pass writes map objects only; `InitializeVisibleSprites` spawns.
- **Two modes.** `POP_REROLL_STATS`: one species for the visit, every battle rerolls level, DVs,
  shininess, item and form. `POP_REROLL_SPECIES`: every battle rerolls species too.
- **Per-row form and perks.** `POP_WILD_FORM` in the form column takes the random variant a grass
  encounter gets, at roll time, so sprite and battle agree. The engine imposes no perk.
- **The contest** runs on `NATIONAL_PARK_BUG_CONTEST`, so no gate is needed; while the contest
  timer runs a member battle takes `BATTLETYPE_CONTEST` and the contest's out-of-balls tail.
- **The Inner Chamber** holds four Unown, level 5, anywhere on its floor, alongside its floor
  encounters (4% per step). The gate and the letters are the Unown species rule (see
  [Wandering wild Pokémon](#wandering-wild-pokémon)), so they appear from the first solved puzzle —
  which drops you into the chamber, already populated — and every battle reshuffles the letters
  too. In debug builds the Super Nerd in the player's room unlocks the next letter group, relocks
  them all, or warps you to the chamber's door.


## Swarms

A swarm (`data/wild/swarms.asm`, constants in `constants/swarm_constants.asm`) takes over part of
a route's wandering mon as well as its grass or surf encounters. This section covers the wandering
side; the encounter side is `ApplySwarmToWildSlot` in `engine/overworld/wildmons.asm`.

| Piece | Where |
| --- | --- |
| Which rows a swarm takes | `RollOverworldMons.GetSwarmedRows` in `engine/overworld/overworld_mons.asm` |
| Substituting a taken row | the swarm branch of `RollOverworldMons.RollOneSlot` |
| Post-battle reroll | `RerollSwarmOverworldMons`, called from `OverworldMonBattleScript` |
| Respawn after the reroll | `PlacePopulationAndSpawn` in `MapSetupScript_ReloadMap`, gated on `wSwarmRespawnPending` |
| Keeping a respawn off the player's tile | `KeepSwarmClearOfPlayer`, margin `SWARM_RESPAWN_MARGIN` |

- **Which rows.** Per terrain pass, `GetSwarmedRows` takes the roster's heaviest rows while their
  combined weight moves nearer `SWARM_ENCOUNTER_RATE` (60%), and never all four, so one row always
  stays the route's own. Rows are weighted rather than fixed-odds slots, which is why this differs
  from the grass's slot masks.
- **A taken row** gets the swarm's species, form and move (the row's optional last argument in
  `swarm_def`, `NO_MOVE` for none) and keeps the row's level. It does not keep the row's perks or
  extra move, which belong to the species it displaced. A swarm's grass and surf mon get the same
  move: `ApplySwarmToWildSlot` puts it in `wTempWildMonMove`, which `ApplyWildMonMove` uses up. On
  water, whether it floats
  comes from its species, as for any water mon. Its shininess is rolled at `SWARM_SHINY_NUMERATOR`.
- **After a battle with one of its wandering mon**, a swarming route rerolls every slot, so standing
  in a swarm is a loop. The fought mon's slot is emptied again, so it doesn't reappear a tile or two
  from where it was met; it comes back with the next reroll. The reload's `PlacePopulationAndSpawn`
  respawns the route only when `wSwarmRespawnPending` says a reroll happened, so ordinary grass
  battles leave the wandering mon standing.
- **Respawning on the player.** A route's mon reappear at their map object's tile, so
  `KeepSwarmClearOfPlayer` empties any rerolled slot whose tile is the player's: it would start a
  battle at once. It comes back with the next reroll.
- **Roaming beasts** standing on a swarming route survive the reroll; see [Roaming beasts](#roaming-beasts).
- **Debug.** `SWARM_DEBUG_FORCE_SHINY` makes every swarm mon shiny in a debug build.


## Roaming beasts

Raikou and Entei are met as wandering mon, never in the grass. A beast on the player's route takes
one of its grass slots for the visit, and the battle against it is a roamer battle.

| Piece | Where |
| --- | --- |
| Placement after the grass pass, slot markers | `PlaceRoamingBeasts`, `wOverworldMonBeastSlots` in `engine/overworld/overworld_mons.asm` |
| Kept through a swarm reroll | `SaveRoamingBeasts` / `RestoreRoamingBeasts`, called from `RerollSwarmOverworldMons` |
| Roamer battle from a slot | `IsOverworldMonBattleBeast` in `SetUpOverworldMonBattle`; `EndOverworldMonBattle` forgets the slot |
| Moving, and holding still after battles | `UpdateRoamMons` / `UpdateRoamMonsAfterBattle` in `engine/overworld/wildmons.asm` |
| Shininess rolls | `RollBeastsAtBurnedTower`, `RollTinTowerSuicuneShiny`, `RollLegendaryShiny` in `engine/overworld/wildmons.asm` |
| Release, and the respawn after the Elite Four | `InitRoamRaikou` / `InitRoamEntei` in `engine/overworld/wildmons.asm`; `RespawnRoamingBeasts` in `engine/events/legendary_respawn.asm` refills a knocked-out, uncaught beast at L50 with a new shiny roll |
| Beast sprites in their own colors | `_GetSpritePalette.GetBeast` in `engine/overworld/overworld.asm` |
| Pokégear map icons | `PokegearMap_InitMonIcons` in `engine/pokegear/pokegear.asm`, icon slots 3 and 4 |
| Debug tools | the Super Nerd in the player's room, debug builds only (`PlayersHouseDebugBeastsScript`) |

How it works:

- **Placement.** After the grass pass, each beast whose roam struct names this map takes a random
  grass slot that rolled a mon. The encounter comes from the roam struct (species, level, DVs and
  form), with nothing kept from the row it displaces. Each placement rolls 1/512 for shininess,
  and a shiny stays shiny. With both beasts here and one slot, a coin toss picks which appears.
- **Moving.** `UpdateRoamMons` runs *before* `HandleNewMap` in the connection and door setup
  scripts, so the roll sees where the beasts are for this visit, and the Pokégear agrees with the
  sprite. Warps and Fly don't run it; Fly runs `JumpRoamMons`. After a battle, a roamer on the
  player's map holds still unless it is the one just fought.
- **The battle.** A beast's slot fights as `BATTLETYPE_ROAMING`: HP carries over, DVs are fixed
  at the first meeting, it flees on its first turn, and `BattleEnd_HandleRoamMons` moves it on or
  clears it. `LoadEnemyMon` checks for a roamer *before* the wanderer slot's DVs, since the battle
  is both.
- **Swarms.** A swarm's post-battle reroll leaves a beast standing: its slot and encounter are set
  aside, and put back in place of a fresh placement.
- **Shininess before the route.** The Burned Tower scene rolls all three beasts as they wake, so
  soft-resetting before it hunts them together. Suicune doesn't roam; its form lives in the
  otherwise unused `wRoamMon3Form`, gets one more roll as Tin Tower 1F loads, and its battle there
  takes it as stored.
- **Debug.** *FORCE SHINY* makes every legendary roll hit. *BEASTS FOLLOW* lands any beast that's
  out on each roaming route the player walks onto, since a roamer always leaves its route on a map
  change.

Known gaps:

- On Route 42 there is only one grass slot (Suicune's sighting holds it to three wanderers, two of
  them on water), so with both beasts there only one can be met that visit. The Pokégear still
  shows both. The same goes for Routes 33, 39 and 44, which also have one grass slot; Route 43
  has three.
- `KeepSwarmClearOfPlayer` can empty a beast's slot after a swarm battle if its spawn tile is the
  player's tile, which leaves it out for the rest of the visit.


## Checks

Getting a map's wandering mon wrong assembles cleanly and shows up only in play, as a slot that
never appears, a mon drawn red or a script moving the wrong object. Two layers catch it.

**Asserts in `object_event`** (`macros/scripts/maps.asm`), on every map, every build:

- **The object limit.** A map may have `NUM_OBJECTS - 2` = 17 objects; the player and the follower
  take the other two. An 18th fails the build.
- **The four-color limit.** `def_object_events` opens a per-map count, and each object with
  palette `0` whose sprite is a Pokémon sprite (`SPRITE_POKEMON` up to the last `SPRITE_OW_MON_n`,
  the two day-care ids, the three beast ids) adds one the first time its sprite id appears. More
  than `NUM_OW_MON_PALS` fails the build. This works inside one map file because each
  `SPRITE_OW_MON_n` is one slot, so a map's objects alone say how many slots it shows. Variable
  sprites (dolls) can't be resolved at assembly and are left out.

**`utils/ow_mon_check.py`**, by hand, like `utils/farcheck.py`:

```bash
python utils/ow_mon_check.py
```

It reads the map constants, `data/maps/attributes.asm`, every `maps/*.asm`, the static table, both
roster tables and the populations, prints one line per problem and exits 1, or prints nothing and
exits 0. It reports a map when:

- the highest `SPRITE_OW_MON_n` on it isn't static + grass + water (or static + population), capped
  at four;
- a rolled slot doesn't have exactly one `OBJECTTYPE_WILDMON` object;
- it has more than 17 objects;
- its slots plus its other palette-0 Pokémon sprites come to more than four;
- its `object_const_def` names wanderers `<MAP>_WILD_MON_n` and they don't match its wandering
  objects: one constant per wanderer, at the same index, numbered from 1. A list that stops short
  is harmless; one with a constant after a short list names the wrong object, which is how
  Cianwood's boarding script once moved a wanderer instead of the sailor.

The Bug Catching Contest names its members `NATIONALPARKBUGCONTEST_MEMBER_n`, not `_WILD_MON_n`,
so the constant check skips that map; the others still apply.

**Adding a wanderer** to a map is the roster's count byte, one `object_event` at the end of the
list, and one `const <MAP>_WILD_MON_n` at the end of `object_const_def`. On a map with both
terrains, adding a grass slot renumbers each water object's `SPRITE_OW_MON_n` up by one, since
slots fill grass first. Then build and run the lint.


## Bugs worth remembering

Every one of these assembled cleanly and was found by playing.

**Overworld Pokémon were drawn with the follower's form.** `GetMonSprite.pokemon_sprite` left `d`
at 0, which tells `LoadOverworldMonIcon` "`wForm` is already set" — but nothing set it for a map
object, so it held whatever wrote it last, and the follower is map object 1 and loads first. With a
Flying Pikachu following you, the Pikachu doll in your room came out flying. Fixed with an explicit
`PLAIN_FORM` write: a `SpriteMons` entry names a species and nothing else.

**The trigger never fired.** The distance check used `d` as scratch — and `de` was the caller's map
object pointer, so the next line read the sprite id through a half-overwritten pointer.

**Garbage when one turned.** Mon icons are 8 tiles and the loader copies 12 per facing, so "up"
got the icon's second frame and "left/right" got whatever followed in the icon table. Invisible on
a Pokémon that only faces the camera, which is why the static NPCs never showed it. Fixed by
routing everything through `ExpandMonIconToSprite`.

**It froze between steps.** `OBJECT_ACTION_FOLLOWER_IDLE` set in the movement function was not
enough: a *completed* step never reaches the movement function, because `StepFunction_ContinueWalk`
jumps straight into `RandomStepDuration_Slow`, which parks the object on `OBJECT_ACTION_STAND`.
`KeepOverworldMonAnimating` promotes that action every frame instead.

**The perk never fired.** See [perks](#perks-and-balance-knobs) — a bit number used as a value.


## Known gaps

- ~~**The Bug Catching Contest is not compatible.**~~ It is now: `BATTLETYPE_OVERWORLD_MON` is gone
  and the branches test `wOverworldMonBattleSlot`, so a wandering mon in the park can be fought as
  `BATTLETYPE_CONTEST`.
- **Reload scumming for a shiny works** on routes, as above. Not on a population map for the
  species — that is saved — but stats and shininess do reroll on a continue there, by decision.
- **They swim and walk with the follower's hop**, which suits a Sentret and may not suit a
  Tentacool.
- **A mon can be dodged.** If you step onto one that is mid-step and it steps away, no battle. It
  cannot soft-lock, because pressing A always works.
- **`OW_MON_DEBUG_FORCE_SHINY_SLOT`** in `engine/overworld/overworld_mons.asm` forces a slot shiny
  in `_DEBUG` builds. Testing a rate by walking in and out of a route a few hundred times is not a
  test; what needs checking is whether the sprite and the battle agree.
