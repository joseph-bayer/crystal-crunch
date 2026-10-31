# Saves from earlier releases

`tests/test_old_saves.py` loads these into the current build. They are the raw 32 KB cartridge RAM
(the `.sav` an emulator writes), made with each tag's own `pokecrystal_debug.gbc`, whose RAM layout
is the release build's.

| File | Tag | Made by |
|---|---|---|
| `v1.0_cherrygrove.sav` | `v1.0` | A new game; the debug radio's party and items; `wJohtoBadges` = `$0f` and ¥100,000 set by hand; warped to Cherrygrove (17, 8); saved from the start menu |
| `1.1_cherrygrove.sav` | `1.1` | The same steps |
| `v1.0_before_starter.sav` | `v1.0` | A new game, nothing else: an empty party, the follower choice set to nobody (`wFollowerPartySlot` 0), saved in the bedroom |

Replace them only on purpose: a save break between releases is a decision, not a test update.
