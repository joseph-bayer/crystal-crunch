import re

import pytest

from harness import Game, new_game_state, rom_path
from harness.new_game import CACHE


@pytest.fixture(scope="session")
def rom():
	path = rom_path()
	if not path.exists():
		pytest.exit("%s is missing: build it with `make crystal_test` (or run `make test`)" % path)
	return path


@pytest.fixture(scope="session")
def new_game(rom):
	return new_game_state(rom)


@pytest.fixture
def game(request, rom, new_game):
	"""A game standing in the bedroom of a new game, beside the debug NPCs."""
	game = Game(rom)
	game.load_state(new_game)
	yield game
	report = getattr(request.node, "rep_call", None)
	if report is not None and report.failed:
		# Keep what the game looked like, to replay or look at.
		failures = CACHE / "failures"
		failures.mkdir(parents=True, exist_ok=True)
		name = re.sub(r"[^\w.-]+", "_", request.node.nodeid)
		(failures / (name + ".state")).write_bytes(game.save_state())
		game.screenshot(failures / (name + ".png"))
		(failures / (name + ".txt")).write_text(game.screen_text(), encoding="utf-8")
	game.close()


@pytest.hookimpl(hookwrapper=True)
def pytest_runtest_makereport(item, call):
	outcome = yield
	report = outcome.get_result()
	setattr(item, "rep_" + report.when, report)
