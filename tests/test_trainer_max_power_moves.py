"""A trainer's Pokémon uses Return, Frustration and Hidden Power at their max power. A wild Pokémon,
a link opponent's and the player's own use happiness (Return, Frustration) or their Hidden Power
level as before.

These call the move-power routines directly (see harness.alt_shiny.call) with the battle state
poked in, so no battle has to be played out."""

import pytest

from harness import alt_shiny as A
from harness import constants

WILD_BATTLE = 1
TRAINER_BATTLE = 2
LINK_COLOSSEUM = constants._consts(constants.ROOT / "constants" / "serial_constants.asm")["LINK_COLOSSEUM"]

PLAYER_TURN = 0
ENEMY_TURN = 1

BASE_HAPPINESS = 70
MAX_POWER = 102 # HAPPINESS_MOVE_MAX_POWER: 255 * 10 / 25
RETURN_AT_BASE = BASE_HAPPINESS * 10 // 25 # 28
FRUSTRATION_AT_BASE = (255 - BASE_HAPPINESS) * 10 // 25 # 74

HIDDEN_POWER_MIN_POWER = 20
HIDDEN_POWER_MAX_POWER = 70
HIDDEN_POWER_UNOWN_MAX_POWER = 120


def set_battle(game, turn, mode, link=0, happiness=BASE_HAPPINESS):
	game.poke("hBattleTurn", turn)
	game.poke("wBattleMode", mode)
	game.poke("wLinkMode", link)
	game.poke("wBattleMonHappiness", happiness)
	game.poke("wEnemyMonHappiness", happiness)


def power(game, routine):
	"""The power a move command leaves in d."""
	return A.call(game, routine)["de"] >> 8


@pytest.fixture
def battle_game(game):
	state = game.save_state()
	yield game
	game.load_state(state)
	game.poke("wLinkMode", 0)


def test_trainer_return_and_frustration_hit_at_max_power(battle_game):
	game = battle_game
	set_battle(game, ENEMY_TURN, TRAINER_BATTLE)
	assert power(game, "BattleCommand_HappinessPower") == MAX_POWER
	assert power(game, "BattleCommand_FrustrationPower") == MAX_POWER


@pytest.mark.parametrize("case", ["wild", "link opponent", "player in a trainer battle"])
def test_others_use_happiness(battle_game, case):
	game = battle_game
	if case == "wild":
		set_battle(game, ENEMY_TURN, WILD_BATTLE)
	elif case == "link opponent":
		set_battle(game, ENEMY_TURN, TRAINER_BATTLE, link=LINK_COLOSSEUM)
	else:
		set_battle(game, PLAYER_TURN, TRAINER_BATTLE)
	assert power(game, "BattleCommand_HappinessPower") == RETURN_AT_BASE
	assert power(game, "BattleCommand_FrustrationPower") == FRUSTRATION_AT_BASE


def test_player_happiness_still_sets_the_power(battle_game):
	game = battle_game
	set_battle(game, PLAYER_TURN, TRAINER_BATTLE, happiness=255)
	assert power(game, "BattleCommand_HappinessPower") == MAX_POWER
	assert power(game, "BattleCommand_FrustrationPower") == 1 # never below 1
	set_battle(game, PLAYER_TURN, TRAINER_BATTLE, happiness=0)
	assert power(game, "BattleCommand_HappinessPower") == 1
	assert power(game, "BattleCommand_FrustrationPower") == MAX_POWER


@pytest.mark.parametrize("species, top", [("PIDGEY", HIDDEN_POWER_MAX_POWER), ("UNOWN", HIDDEN_POWER_UNOWN_MAX_POWER)])
def test_hidden_power_trainer_max_wild_min(battle_game, species, top):
	game = battle_game
	game.poke("wEnemyMonSpecies", A.species_id(game, species))
	set_battle(game, ENEMY_TURN, TRAINER_BATTLE)
	assert A.call(game, "GetUserHiddenPowerPower")["a"] == top
	set_battle(game, ENEMY_TURN, WILD_BATTLE)
	assert A.call(game, "GetUserHiddenPowerPower")["a"] == HIDDEN_POWER_MIN_POWER
