"""Three bugs from CrystalShireEngine's automated "Optimize" commits, found by auditing them after
Substitute's (tests/test_substitute.py). Each rewrite kept a value but changed a flag or register
that the next lines still read.

* Card Flip: "Play again? YES" counted the round with `inc [hl]` but then compared the stale a
  (from the YES/NO box) with 12, so the deck never reshuffled and later rounds drew cards past its
  end, writing into memory by garbage card values.
* The Lucky Number Show: `ld c, a / ld a, FRIDAY / sub c` became `cpl / add FRIDAY + 1`, the same
  value with the opposite carry, so the countdown to Friday was 7 days too long, or 255 days from a
  Saturday.
* The AI's switch scoring: .DecreaseScore came to clobber hl, so with no known player moves, the
  check of the player's second type read the AI's own score bytes as the enemy's types.

Each routine is called directly with its inputs set by hand, from the bedroom of a new game."""

import pytest

from harness import constants
from harness.alt_shiny import call

# Card Flip
CARDFLIP_RESHUFFLE_AT = 12

# Weekdays (constants/wram_constants.asm order): SUNDAY is 0, FRIDAY 5, SATURDAY 6
DAYS_UNTIL_FRIDAY = {0: 5, 1: 4, 2: 3, 3: 2, 4: 1, 5: 7, 6: 6}

# AI switch scoring
NUM_MOVES = 4


def type_const(name):
	return constants._consts(constants.ROOT / "constants" / "type_constants.asm")[name]


@pytest.mark.parametrize("played, reshuffled", [(CARDFLIP_RESHUFFLE_AT - 1, True), (5, False)])
def test_card_flip_reshuffles_after_12_cards(game, played, reshuffled):
	game.poke("wCardFlipNumCardsPlayed", played)
	# YES to "Play again?" (the box starts on YES). Only the count matters, and the shuffled text
	# can hold the routine past the frames given, so it isn't waited out.
	call(game, "_CardFlip.PlayAgain", press_a_every=20, must_return=False, frames=1500)
	if reshuffled:
		assert game.peek("wCardFlipNumCardsPlayed") == 0, "the deck should be reshuffled"
	else:
		assert game.peek("wCardFlipNumCardsPlayed") == played + 1


CARDFLIP_DECK_SIZE = 24


def test_card_flip_many_rounds(game, new_game):
	"""Forty rounds of "Play again? YES": the count never passes the last card, and each reshuffle
	deals a full deck (every card once) with an empty discard pile, so no round reads past it.

	The reshuffle round prints its text with the sound engine busy, and the harness can't tell when
	it has returned, so the game is reloaded after one with the deck, discards and count carried
	over."""
	call(game, "CardFlip_ShuffleDeck")
	reshuffles = 0
	for _ in range(40):
		before = game.peek("wCardFlipNumCardsPlayed")
		call(game, "_CardFlip.PlayAgain", press_a_every=20, must_return=False, frames=1500)
		played = game.peek("wCardFlipNumCardsPlayed")
		assert played < CARDFLIP_RESHUFFLE_AT, "the deck went past its last card"
		if played:
			assert played == before + 1
			continue
		reshuffles += 1
		assert before == CARDFLIP_RESHUFFLE_AT - 1
		deck = game.peek("wDeck", 0, CARDFLIP_DECK_SIZE)
		discards = game.peek("wDiscardPile", 0, CARDFLIP_DECK_SIZE)
		assert sorted(deck) == list(range(CARDFLIP_DECK_SIZE)), "the reshuffled deck isn't whole"
		assert not any(discards)
		game.load_state(new_game)
		for i, card in enumerate(deck):
			game.poke("wDeck", card, i)
		for i in range(CARDFLIP_DECK_SIZE):
			game.poke("wDiscardPile", 0, i)
		game.poke("wCardFlipNumCardsPlayed", 0)
	assert reshuffles == 40 // CARDFLIP_RESHUFFLE_AT


@pytest.mark.parametrize("weekday", sorted(DAYS_UNTIL_FRIDAY))
def test_lucky_number_show_waits_until_friday(game, weekday):
	"""The countdown the show stores is the days to next Friday."""
	game.poke("wCurDay", weekday)
	call(game, "RestartLuckyNumberCountdown")
	assert game.peek("wLuckyNumberDayTimer") == DAYS_UNTIL_FRIDAY[weekday]


@pytest.mark.parametrize("weekday", sorted(DAYS_UNTIL_FRIDAY))
def test_lucky_number_countdown_to_friday(game, weekday):
	game.poke("wCurDay", weekday)
	days = call(game, "RestartLuckyNumberCountdown.GetDaysUntilNextFriday")["a"]
	assert days == DAYS_UNTIL_FRIDAY[weekday]


def switch_score(game, player_types, enemy_types):
	"""The AI's switch score with no known player moves (the type-only path)."""
	game.poke("wPlayerUsedMoves", 0)
	for slot in range(NUM_MOVES):
		game.poke("wEnemyMonMoves", 0, slot)
	game.poke("wBattleMonType1", type_const(player_types[0]))
	game.poke("wBattleMonType2", type_const(player_types[1]))
	game.poke("wEnemyMonType1", type_const(enemy_types[0]))
	game.poke("wEnemyMonType2", type_const(enemy_types[1]))
	call(game, "CheckPlayerMoveTypeMatchups")
	return game.peek("wEnemyAISwitchScore")


def test_ai_switch_checks_the_second_type_against_the_enemy(game):
	# Water and Rock are each super effective on Fire, so a Water/Rock player counts against the
	# enemy twice; a pure Water one once, as its second type isn't checked again.
	twice = switch_score(game, ("WATER", "ROCK"), ("FIRE", "FIRE"))
	once = switch_score(game, ("WATER", "WATER"), ("FIRE", "FIRE"))
	assert twice == once - 1
