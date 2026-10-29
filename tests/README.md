# Regression tests

Scripted in-game tests: PyBoy plays the test ROM with fixed inputs, and each test checks memory
(event flags, map objects, and so on) at the end.

## Running them

```bash
pip install pyboy pytest   # once
make test                  # builds pokecrystal_test.gbc, then runs every test
```

`make test` must pass before a commit. To run one file or one test:

```bash
make crystal_test
python -m pytest tests/test_legendary_respawn.py
python -m pytest tests -k caught
```

Set `TEST_ROM` to test another build of the ROM; its `.sym` must sit beside it.

## The test ROM

`make crystal_test` builds `pokecrystal_test.gbc`: the debug ROM (with its debug NPCs and menus)
plus `-D _TEST`, which makes `Random` a fixed sequence that VBlank doesn't touch. A random result
then depends only on how many numbers the game has asked for, not on the frame, so a test whose
inputs shift by a frame still sees the same encounters and rolls. The other ROMs are unchanged.

The harness also freezes the emulated clock, so every run sees the same time of day.

## How a test starts

Each run plays a new game to the bedroom (every question on its default: boy, 10:00, the first
name) and caches that start in `tests/.cache/`, keyed by the ROM's hash. Tests load it, then set
what they need directly: event flags by name, warps by map constant, debug menus by their
on-screen text. Nothing is tied to a saved file or a state from another build.

## Writing a test

A test is a function taking the `game` fixture (`tests/harness/game.py`):

- `game.set_event_flag("EVENT_...")`, `game.event_flag("EVENT_...")`
- `game.warp("MAP_CONSTANT", x, y)`, `game.current_map()`, `game.position()`
- `game.object_shown("MapFile", "MAPFILE_OBJECT_CONST")`
- `game.peek("wSymbol")`, `game.poke("wSymbol", value)`
- `game.press("a")`, `game.step("left", 3)`, `game.wait(frames)`
- `game.wait_for_text("...")`, `game.choose("MENU ITEM")`, `game.screen_text()`

Check memory, not pixels: PyBoy draws this hack's backgrounds wrong, but `wTilemap` and the
game's variables are exact.

When a test fails, `tests/.cache/failures/` gets its state, a screenshot and the screen's text.
