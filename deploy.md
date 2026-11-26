# Deploying a release

How to release a version of Crystal Crunch, then update the Crystal Crunch Starter Injector so it
works with that release.

The project is two repositories:

- **crystal-crunch** (this one): the hack. Its build makes the ROM, the patches players download,
  and the data the starter injector needs.
- **crystal-crunch-starter-injector**: a web page, hosted on GitHub Pages, that puts a starter of
  the player's choice into their patched ROM.

Below, `<crystal-crunch>` and `<starter-injector>` stand for wherever you cloned each one.

Do the two parts in this order, from the same build. The injector only accepts a ROM whose SHA1
matches the data it was given, so its data has to come from the exact ROM players will patch to.
Any rebuild in between, even with no source changes, means exporting again.

## Before you start

- **For the hack:** [RGBDS](https://rgbds.gbdev.io/) 0.9.3 exactly, GNU Make, a C compiler and
  Python 3. The tests also need `pip install pyboy pytest pytest-xdist pytest-timeout` (see `tests/README.md`). `README.md` and
  `INSTALL.md` cover building.
- **For the injector:** Node 22.18 or later, and `npm install` once in `<starter-injector>`.
- **The base ROM:** Pokémon Crystal 1.1, saved as `baserom.gbc` at the root of
  `<crystal-crunch>`. Its SHA1 is `f2f52230b536214ef7c9924f483392993e226cfb`. To keep it
  somewhere else, pass its path, as in `make release BASEROM=<path to baserom.gbc>`.
- **For the cross-repository tests:** each repository's tests find the other through an
  environment variable. Set both:
  - `STARTER_INJECTOR_DIR=<starter-injector>`, for the hack's injector tests;
  - `CRUNCH_DIR=<crystal-crunch>`, for the injector's tests that inject into the hack's test ROM.

  Without them, the tests look in a default folder layout, and they're skipped if nothing is
  there.

## 1. The hack

1. **Get the tree ready.** Put everything for the release on the release branch, with nothing
   uncommitted. Check:
   - the build passes;
   - `python utils/optimize.py` finds nothing in the changed files;
   - `make test` passes. On a machine with little memory, run `python -m pytest -n 4 tests`
     instead of `make test`.
2. **Tag it.** Tags so far are `v1.0` through `v1.2.3`, so a 2.0 release is tagged `v2.0`.
   The release's file names come from `git describe --tags --always --dirty`, so build on the tag
   with a clean tree. Otherwise the files are named `...-dirty` or `...-g<hash>`.
3. **Build the release.**
   ```sh
   make clean
   make release
   ```
   This builds `pokecrystal.gbc`, then writes three files to `release/`:
   - `crystal-crunch-<version>.bps`, the patch players apply to their Crystal ROM. `make_bps.py`
     checks it by applying it to the base ROM.
   - `crystal-crunch-<version>.patch`, the 3DS Virtual Console patch.
   - `crystal-crunch-<version>.inject.json`, the starter injector's map of this exact ROM. It's
     for part 2 and isn't uploaded.
4. **Publish it.** On GitHub, create a release for the tag and upload the `.bps` and the
   `.patch`. The README's download links point at the latest release.
5. **Keep this build.** Leave `pokecrystal.gbc` and `pokecrystal.sym` as they are for part 2. A
   copy of the base ROM patched with the `.bps` is byte for byte this file.

## 2. The starter injector

The injector needs three things from each release: the game data it checks packs against, the
injection map of the release ROM, and the game's art for its previews. All three go into
`<starter-injector>/data/<release>/`.

1. **Export the release's data.** Run this in `<crystal-crunch>`, with the build from part 1
   still in place:
   ```sh
   python utils/export_injector_data.py --release 2.0 \
       --out <starter-injector>/data/2.0 \
       --rom pokecrystal.gbc --rgbasm "$(which rgbasm)"
   ```
   This writes `game.json`, `inject.json` and `art/`, replacing whatever art the folder had.
2. **Check that the map matches the ROM.** The `sha1` in `inject.json` must equal the release
   ROM's:
   ```sh
   sha1sum pokecrystal.gbc
   grep '"sha1"' <starter-injector>/data/2.0/inject.json
   ```
   The exported `inject.json` should also be identical to
   `release/crystal-crunch-<version>.inject.json`; `diff` the two.
3. **A new release number** (2.1, say) also needs, in `<starter-injector>`:
   - `data/2.1/` as the export's `--out`;
   - `RELEASE` in `web/src/App.tsx`;
   - `DEFAULT_RELEASE` in `src/cli/main.ts`;
   - the `--release` examples in its README;
   - `PATCH_URL` in `web/src/App.tsx`, if the releases page moved.

   The page works with one release at a time: a ROM patched with an older release is refused,
   with a message to patch a fresh copy. An older `data/<release>/` can stay, but goes unused.
4. **A change to the data's shape.** If the export's or the map's format changed, raise
   `FORMAT` in `utils/export_injector_data.py` or `utils/injection_map.py`. Then raise
   `GAME_FORMAT`, or change the map reader, in the injector's `src/core/` to match. The page
   refuses data in a format it doesn't know.
5. **Test both sides.**
   - In `<crystal-crunch>`:
     ```sh
     RGBASM="$(which rgbasm)" python -m pytest -n 4 tests/test_injector.py tests/test_injected_starter.py tests/test_injector_export.py
     ```
     These inject the injector's test packs into the test ROM and play the results.
   - In `<starter-injector>`, run `npm test` and `npm run typecheck`. With `CRUNCH_DIR` set,
     its injection tests use the hack's test ROM and the map the tests above wrote.
6. **Try it end to end.** Patch a fresh copy of the base ROM with the release's `.bps`. Then,
   in `<starter-injector>`, build and serve the page:
   ```sh
   npm run build
   npm start
   ```
   Load the patched ROM: the page should say it loaded a clean Crystal Crunch ROM of the
   release. Inject a starter, download the result, and start a new game.
7. **Publish the page.** Commit the new `data/<release>/`, and any release-number changes, in
   the injector's repository, then push to `main`. Its Pages workflow
   (`.github/workflows/pages.yml`) typechecks, tests, builds and publishes the page. Watch the
   run in the repository's Actions tab, then load the release ROM on the live page to check it.

   Publish the page after the release's `.bps` is up, so players never meet a page that refuses
   the only ROM they can make.

   The first time only: in the injector repository's Settings > Pages, set the source to
   "GitHub Actions".

## After a release

Any change to the game changes the ROM's SHA1. The injector then refuses the new ROM until its
data is exported again, for a release or a development build alike. While developing, rebuild
and export again after each change you want to inject into.
