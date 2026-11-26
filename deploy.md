# Deploying a release

How to release a version of Crystal Crunch, then update the Crystal Crunch Starter Injector (the
`crystal-crunch-starter-injector` repository) so it works with that release.

Do the two parts in this order, from the same build. The injector only accepts a ROM whose SHA1
matches the data it was given, so its data has to come from the exact ROM players will patch
to. Any rebuild in between, even with no source changes, means exporting again.

## 1. The hack

1. **Get the tree ready.** Put everything for the release on the release branch, with nothing
   uncommitted. The build must pass, and so must `python utils/optimize.py` on the changed files
   and `make test`. On a machine with little memory, run the tests as
   `python -m pytest -n 4 tests`.
2. **Tag it.** Tags so far are `v1.0` through `v1.2.3`, so a 2.0 release is tagged `v2.0`.
   The file names come from `git describe --tags --always --dirty`, so build on the tag with a
   clean tree. Otherwise the files are named `...-dirty` or `...-g<hash>`.
3. **Have the base ROM.** `baserom.gbc` must be at the root of the checkout you build in. It's
   Pokémon Crystal 1.1, SHA1 `f2f52230b536214ef7c9924f483392993e226cfb`. A worktree has its own
   root, so either copy it in or pass its path: `make release BASEROM=../CrystalShireEngine-core/baserom.gbc`.
4. **Build the release.**
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
5. **Publish it.** Create a GitHub release for the tag and upload the `.bps` and the `.patch`.
   The README's download links point at the latest release.
6. **Keep this build.** Leave `pokecrystal.gbc` and `pokecrystal.sym` as they are for part 2. A
   patched copy of the base ROM is byte for byte this file.

## 2. The starter injector

The injector lives in its own repository, beside this one. It needs three things from each
release: the game data it checks packs against, the injection map of the release ROM, and the
game's art for its previews. All three go into the injector's `data/<release>/`.

1. **Export the release's data**, from this checkout, with the build from part 1 still in place:
   ```sh
   python utils/export_injector_data.py --release 2.0 \
       --out ../../crystal-crunch-starter-injector/data/2.0 \
       --rom pokecrystal.gbc --rgbasm "$(which rgbasm)"
   ```
   This writes `game.json`, `inject.json` and `art/`, and replaces the folder's art.
2. **Check that the map matches the ROM.** The `sha1` in `inject.json` must equal the release
   ROM's:
   ```sh
   sha1sum pokecrystal.gbc
   grep '"sha1"' ../../crystal-crunch-starter-injector/data/2.0/inject.json
   ```
   It should also match `release/crystal-crunch-<version>.inject.json`; `diff` the two.
3. **A new release number** (2.1, say) also needs:
   - `data/2.1/` as the export's `--out`;
   - `RELEASE` in `web/src/App.tsx`;
   - `DEFAULT_RELEASE` in `src/cli/main.ts`;
   - the `--release` examples in the injector's README;
   - `PATCH_URL` in `web/src/App.tsx`, if the releases page moved.

   The page works with one release at a time: a ROM patched with an older release is refused,
   with the message to patch a fresh one. An older `data/<release>/` can stay but goes unused.
4. **A change to the data's shape.** If the export's or the map's format changed, raise
   `FORMAT` in `utils/export_injector_data.py` or `utils/injection_map.py`, and `GAME_FORMAT` or
   the map reader in the injector's `src/core/` to match. The page refuses data of a format it
   doesn't know.
5. **Test both sides.**
   - Here:
     ```sh
     RGBASM="$(which rgbasm)" python -m pytest -n 4 tests/test_injector.py tests/test_injected_starter.py tests/test_injector_export.py
     ```
     These inject the injector's test packs into the test ROM, so the injector has to be at
     `../../crystal-crunch-starter-injector`, or at `STARTER_INJECTOR_DIR`.
   - In the injector: `npm test` and `npm run typecheck`. Its injection tests use this checkout's
     test ROM. They look for it at `../crystal_for_friends/cse-starter-injector` unless
     `CRUNCH_DIR` names another checkout, and they're skipped when nothing is there.
6. **Try it end to end.** Patch a fresh copy of the base ROM with the release's `.bps`. Then
   build and serve the page from the injector's folder:
   ```sh
   npm run build
   npm start
   ```
   Load the patched ROM: it should say it loaded a clean Crystal Crunch ROM of the release.
   Inject a starter, download, and start a new game.
7. **Publish the page.** `npm run build` writes the page to `web/dist/`. It isn't on GitHub
   Pages yet, and the Crystal Tool Suite doesn't list it yet. Until both are set up, it's served
   locally (`npm start`) or as the launcher's development copy.

## After a release

Any change to the game changes the ROM's SHA1, and the injector refuses the new ROM until its
data is exported again. That applies to a release and to a development build alike. While
developing, rebuild and export again after each change you want to inject into.
