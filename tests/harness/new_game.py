"""The start every test shares: a new game, played by script to the bedroom, cached per ROM.

Nothing here depends on a saved file or state from another build: the cache is keyed by the ROM's
own hash, so a rebuild simply plays the intro again (about a second)."""

import hashlib
from pathlib import Path

from . import constants
from .game import Game, HarnessTimeout

CACHE = constants.ROOT / "tests" / ".cache"

# Bump when the script below changes, so old cached starts are not reused.
SCRIPT_VERSION = 1

MAPSTATUS_HANDLE = 2
MAX_PRESSES = 400


def _idle_in(game, map_name):
	return (game.in_map(map_name)
		and game.peek("wMapStatus") == MAPSTATUS_HANDLE
		and game.peek("wScriptRunning") == 0
		and game.peek("wWindowStackSize") == 0)


def play_intro(game):
	"""Press A from power-on until the player stands in the bedroom with nothing running. Every
	question takes its default: boy, 10:00, and the first name the naming screen builds."""
	game.wait(400)
	for _ in range(MAX_PRESSES):
		game.press("a")
		if _idle_in(game, "PLAYERS_HOUSE_2F"):
			game.wait(60)
			if _idle_in(game, "PLAYERS_HOUSE_2F"):
				return
	raise HarnessTimeout("the intro never reached the bedroom. The screen:\n" + game.screen_text())


def new_game_state(rom):
	"""The bedroom start for this ROM, from the cache or by playing the intro."""
	rom = Path(rom)
	digest = hashlib.sha1(rom.read_bytes()).hexdigest()[:16]
	path = CACHE / ("new_game-%s-v%d.state" % (digest, SCRIPT_VERSION))
	if path.exists():
		return path.read_bytes()
	game = Game(rom)
	try:
		play_intro(game)
		state = game.save_state()
	finally:
		game.close()
	CACHE.mkdir(parents=True, exist_ok=True)
	path.write_bytes(state)
	return state
