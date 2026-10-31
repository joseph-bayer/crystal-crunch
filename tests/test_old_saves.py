"""Saves from earlier releases keep loading (tests/fixtures/saves/README.md).

Each save is continued in the current build, and the three saved blocks it lands in WRAM are
compared with the save's own copies of them: they must match, apart from what continuing a game
changes by itself. Then the player walks, and in the save made before Elm's starter, picks it."""

import pytest

from harness import Game, constants, rom_path
from harness import followers as F

SAVES = constants.ROOT / "tests" / "fixtures" / "saves"
SRAM_BANK_SIZE = 0x2000
SRAM_START = 0xa000
MAPSTATUS_HANDLE = 2

# The saved WRAM blocks and their copies in the save
BLOCKS = [("wPlayerData", "sPlayerData"), ("wCurMapData", "sCurMapData"), ("wPokemonData", "sPokemonData")]

# What continuing changes by itself (the releases that made these saves do the same): the play
# clock runs, the map's sprites take up their animation, spawning the player sets its facing (saved
# as $ff), and the roaming Pokémon note the map you're on. Loading the map also points at its warp,
# coord and bg event tables afresh (ReadMapEvents), and those move in ROM whenever the map's script
# changes, as the bedroom's debug script does.
CHANGES_ON_CONTINUE = ("wGameTime", "wObject", "wPlayerFacing", "wRoamMons_CurMap",
	"wCurMapWarpEventsPointer", "wCurMapCoordEventsPointer", "wCurMapBGEventsPointer")

CHERRYGROVE = ["v1.0_cherrygrove.sav", "1.1_cherrygrove.sav"]


def continue_game(game):
	"""From power-on, CONTINUE the saved game and wait until the player can move."""
	game.wait(400)
	for _ in range(30):
		if "CONTINUE" in game.screen_text():
			break
		game.press("a", after=30)
	assert "CONTINUE" in game.screen_text(), "no CONTINUE: the save wasn't accepted\n" + game.screen_text()
	game.choose("CONTINUE")
	game.wait(55)
	game.press("a", hold=6, after=10) # past the save's summary
	for _ in range(100):
		game.wait(10)
		if game.peek("wMapStatus") == MAPSTATUS_HANDLE:
			break
	game.wait(240)
	assert game.peek("wMapStatus") == MAPSTATUS_HANDLE, "never reached the map:\n" + game.screen_text()
	assert game.peek("wScriptRunning") == 0 and game.peek("wWindowStackSize") == 0


def saved_block(data, game, symbol, length):
	bank, address = game.pyboy.symbol_lookup(symbol)
	offset = bank * SRAM_BANK_SIZE + address - SRAM_START
	return list(data[offset:offset + length])


def wram_block(game, symbol, length):
	return game.peek(symbol, 0, length)


def label_at(game, symbol, offset):
	"""The name of the WRAM label at or before symbol + offset."""
	bank, start = game.pyboy.symbol_lookup(symbol)
	best = (start, symbol)
	for line in game.rom.with_suffix(".sym").read_text(encoding="utf-8", errors="replace").splitlines():
		parts = line.split()
		if len(parts) != 2 or ":" not in parts[0]:
			continue
		sym_bank, sym_address = parts[0].split(":")
		try:
			sym_bank, sym_address = int(sym_bank, 16), int(sym_address, 16)
		except ValueError:
			continue
		if sym_bank == bank and best[0] < sym_address <= start + offset:
			best = (sym_address, parts[1])
	return best[1]


def load(name):
	path = SAVES / name
	game = Game(rom_path(), save=path)
	return game, path.read_bytes()


@pytest.fixture
def close_after():
	games = []
	yield games.append
	for game in games:
		game.close()


@pytest.mark.parametrize("name", CHERRYGROVE + ["v1.0_before_starter.sav"])
def test_saved_data_comes_back(name, close_after):
	game, data = load(name)
	close_after(game)
	continue_game(game)
	for wram, sram in BLOCKS:
		length = game._address(wram + "End")[1] - game._address(wram)[1]
		saved = saved_block(data, game, sram, length)
		loaded = wram_block(game, wram, length)
		changed = sorted({label_at(game, wram, i) for i, (a, b) in enumerate(zip(saved, loaded)) if a != b})
		unexpected = [label for label in changed if not label.startswith(CHANGES_ON_CONTINUE)]
		assert not unexpected, "%s: %s changed on loading" % (wram, unexpected)


@pytest.mark.parametrize("name", CHERRYGROVE)
def test_continue_in_cherrygrove(name, close_after):
	game, _ = load(name)
	close_after(game)
	continue_game(game)
	assert game.in_map("CHERRYGROVE_CITY")
	assert game.position() == (17, 8)
	assert game.peek("wPartyCount") == 6
	assert game.peek("wFollowerPartySlot") == 1
	assert F.object_field(game, F.FOLLOWER_STRUCT, F.OBJECT_SPRITE), "the follower isn't out"
	game.press("left", hold=8, after=40)
	game.press("left", hold=8, after=40)
	assert game.position() == (15, 8), "the player should be able to walk"


def test_starter_from_a_save_made_before_it(close_after):
	"""A v1.0 save with an empty party and nobody chosen to follow: Elm's starter joins and follows,
	and the scene changes only what it does in a new game (tests/test_nobody_following.py)."""
	import test_nobody_following as T

	game, _ = load("v1.0_before_starter.sav")
	close_after(game)
	continue_game(game)
	assert game.peek("wPartyCount") == 0
	assert game.peek("wFollowerPartySlot") == 0
	game.poke("wElmsLabSceneID", 1) # SCENE_ELMSLAB_CANT_LEAVE: met Elm, the starters are out
	game.set_event_flag("EVENT_COP_IN_ELMS_LAB", True)
	game.set_event_flag("EVENT_CHIKORITA_POKEBALL_IN_ELMS_LAB", False)
	start = game.save_state()
	game.poke("wFollowerPartySlot", 1)
	as_a_new_game = T.pick_chikorita(game)
	game.load_state(start)
	changed = T.pick_chikorita(game)
	assert game.peek("wPartyCount") == 1
	assert game.peek("wFollowerPartySlot") == 1, "the starter should follow"
	assert F.object_field(game, F.FOLLOWER_STRUCT, F.OBJECT_SPRITE), "the starter isn't out"
	extra = sorted(changed - as_a_new_game)
	assert not extra, "the scene changed other sprites' tiles (bank, tile): %s" % extra[:20]
