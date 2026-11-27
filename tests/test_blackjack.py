"""Blackjack at the Game Corners: dealing, A to hit and B to stand, leaving between hands, the
dealer drawing to 17, payouts, bets the player can't cover, the 9999-coin cap, the Coin Case check,
the screen (the bar and what it says, the felt, the message box, long hands), the sidebar (its
totals in small text, Meowth), cards sliding in, COIN counting down, the dealer in Goldenrod, and
the card machines staying Card Flip.

Most tests start the game by calling `special Blackjack` from the main loop, as the dealer's script
does.

Hands are rigged: at the bet prompt the deck is already shuffled, so a test writes the cards it
wants at the top of wBlackjackDeck. They are dealt you, dealer (face up), you, dealer (face down),
then one at a time as hits and the dealer's draws."""

import functools
import re
from pathlib import Path

import pytest

from harness import HarnessTimeout
from harness.alt_shiny import call, scratch_address
from harness.followers import take_radio_items
from harness.game import CURSOR

COIN_CASE_FLAG = 0x01 # its item index is $0101; key item flags go by the low byte

# Where the game is started from, beside Goldenrod's x=13 column of card machines
GOLDENROD_SPOT = (14, 9)

# vTiles2 tiles: the shared card parts (A-K, the rank mark, the outline), the deck's suits,
# pictures and back, then the felt and the buttons
RANK_TILES = 0x00 # + rank - 1
SUIT_TILES = 0x15 # + suit
PICTURE_TILES = 0x19 # + suit * 12
BACK_TILES = 0x49 # the whole card, 4x6
FELT_TILES = range(0x61, 0x71) # felt.png (a 2x2 pattern, then a blank 2x2, row by row), then its dealer's side copy
FELT_PNG_TILES, FELT_PNG_WIDTH = 8, 4
FELT_PATTERN = FELT_TILES[0] # its top left tile
FELT_BLANK = FELT_TILES[2]
DEALER_FELT = 8 # from a felt tile to its dealer's side copy
DEALER_FELT_ROWS = range(0, 8) # the dealer's side of the table
BUTTON_A, BUTTON_B = 0x71, 0x72
# a card's left corners over the card behind: the suits' top left (+ suit), the back's, then the
# bottom left, a face card's and the back's
OVERLAP_TILES = 0x73
OVERLAP_BACK, OVERLAP_BOTTOM_LEFT, OVERLAP_BACK_BOTTOM_LEFT = 0x77, 0x78, 0x79
TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT = 0x10, 0x12, 0x14 # card_parts.png's corners
# VRAM bank 1: card corners on the felt, your side's bottom left, top right, bottom right, then the dealer's
FELT_CORNERS, DEALER_CORNERS = 0x14, 3
BACK_CORNERS = FELT_CORNERS + DEALER_CORNERS * 2 # the back's top right and bottom right, bank 1
CORNER_OAM, CORNER_SPRITES = 24, 0x61 # after the sliding card's; the dealer's, then yours
# each corner's pixels outside the card, row by row
CORNER_PIXELS = {
	"top_left": [0b11000000, 0b10000000] + [0] * 6,
	"top_right": [0b00000011, 0b00000001] + [0] * 6,
	"bottom_left": [0] * 6 + [0b10000000, 0b11000000],
	"bottom_right": [0] * 6 + [0b00000001, 0b00000011],
}
BACK_PAL = 5
DECKS = Path(__file__).resolve().parent.parent / "gfx" / "blackjack" / "decks"
FELT_ROWS = range(0, 17) # above the bar on row 17
TABLE_WIDTH = 15 # the sidebar is columns 15-19
SIDEBAR_ATTR = 0x80 | 0x08 | 6 # drawn over sprites, VRAM bank 1, its palette
SMALL_FONT = " 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ▶?"
GFX = Path(__file__).resolve().parent.parent / "gfx" / "blackjack"
# VRAM bank 1: the totals' numbers, the bet menu, the sidebar's picture (5x12 tiles)
COINS_TILES, YOU_TILES, THEM_TILES, MENU_TILES, PROMPT_TILES, SHEET_TILES = \
	0x00, 0x05, 0x07, 0x09, 0x12, 0x20
COINS_ROW, TOTALS_ROW = 1, 4 # the coin count across row 1; YOU's and THEM's totals on row 4
YOU_X, THEM_X, MENU_X, MENU_ROWS, PROMPT_ROW = 15, 18, 16, (7, 8, 9), 6
MEOWTH_STILL, MEOWTH_IDLE, MEOWTH_CHEER, MEOWTH_BIG_CHEER, MEOWTH_SLUMP = range(5)
MEOWTH_FRAMES = [{0}, {0, 1}, {0, 1, 2, 3}, {0, 1, 4, 5}, {6}] # each state's (the cheers borrow idle's)
MEOWTH_TILES, MEOWTH_SPOT, MEOWTH_SIZE = 0x80, (15, 12), 5 # bank 1 tiles; top left corner
MESSAGE_ROW = 8
PLAYER_ROW = 10
MESSAGE_BOX = (0, 6, 19, 11) # the dialogue box's height, centred
TEXT_PAL, FELT_PAL = 7, 4
CORNER_ATTR = 0x08 | FELT_PAL # VRAM bank 1, the felt's palette
PLUS_TILE = 0x7a # the font has no "+"

PIKACHU, ODDISH, JIGGLYPUFF, POLIWAG = range(4)
ACE, JACK, QUEEN, KING = 1, 11, 12, 13

BETS = [10, 50, 100]

PAYOUT_FRAMES = 400


def card(rank, suit=PIKACHU):
	return suit << 4 | rank


def coins(game):
	high, low = game.peek("wCoins", 0, 2)
	return high << 8 | low


def set_coins(game, amount):
	game.poke("wCoins", amount >> 8)
	game.poke("wCoins", amount & 0xff, 1)


def give_coin_case(game, value=True):
	flags = game.peek("wKeyItemFlags")
	game.poke("wKeyItemFlags", flags | 1 << COIN_CASE_FLAG if value else flags & ~(1 << COIN_CASE_FLAG))


def open_machine(game, map_name="GOLDENROD_GAME_CORNER", spot=GOLDENROD_SPOT, facing="left"):
	game.warp(map_name, *spot)
	game.press(facing)
	game.press("a")


def launch(game):
	"""`special Blackjack`, started from the main loop in Goldenrod's Game Corner."""
	game.warp("GOLDENROD_GAME_CORNER", *GOLDENROD_SPOT)
	call(game, "Blackjack", must_return=False, frames=1, from_main_loop=True)


def start(game, start_coins=500):
	"""Into the game, past the title screen with the deck it opens on."""
	to_the_title(game, start_coins)
	your_turns(game)
	game.press("a", hold=4, after=10)
	wait_for_bet(game)


def your_turns(game):
	"""How many frames the game has spent reading A and B on your turn, counted by a hook."""
	if not hasattr(game, "blackjack_turns"):
		game.blackjack_turns = [0]
		bank, address = game.pyboy.symbol_lookup("Blackjack_AskHitOrStand.loop")
		game.pyboy.hook_register(bank, address, lambda n: n.__setitem__(0, n[0] + 1),
			game.blackjack_turns)
	return game.blackjack_turns[0]


def in_the_game(game):
	"""The coin count's tiles are on screen in the sidebar."""
	return tile_row(game, COINS_ROW)[15:] == [COINS_TILES + c for c in range(5)] \
		and attr_row(game, COINS_ROW)[15] == SIDEBAR_ATTR


def bet_menu_loops(game):
	"""How many frames the game has spent in the bet menu's loop, counted by a hook."""
	if not hasattr(game, "blackjack_bets"):
		game.blackjack_bets = [0]
		bank, address = game.pyboy.symbol_lookup("Blackjack_AskBet.loop")
		game.pyboy.hook_register(bank, address, lambda n: n.__setitem__(0, n[0] + 1),
			game.blackjack_bets)
	return game.blackjack_bets[0]


def wait_for_bet(game, timeout=1200):
	"""Wait until the bet menu is reading buttons."""
	count = bet_menu_loops(game)
	wait_until(game, lambda: bet_menu_loops(game) > count + 1, "the bet menu", timeout)


def left_the_game(game, timeout=600):
	"""Whether the game closed and the Game Corner came back within `timeout` frames."""
	for _ in range(0, timeout, 5):
		if not in_the_game(game) and game.peek("wWindowStackSize") == 0:
			game.wait(60)
			return game.in_map("GOLDENROD_GAME_CORNER") and not in_the_game(game)
		game.wait(5)
	return False


def rig(game, *cards):
	for i, value in enumerate(cards):
		game.poke("wBlackjackDeck", value, i)
	game.poke("wBlackjackDeckPos", 0)


def wait_for_menu(game, open=True, timeout=1200):
	"""Wait for the bet menu to be up and reading buttons, or (open=False) to be gone."""
	if open:
		wait_for_bet(game, timeout)
	else:
		wait_until(game, lambda: game.peek("wBlackjackBar") != 1, "the bet menu closing", timeout)


def pick(game, index):
	"""Choose the index-th item (from 0) of the bet window, which opens on the bet last picked."""
	wait_for_menu(game)
	game.wait(10)
	at = game.peek("wBlackjackBetChoice") - 1
	for _ in range(abs(index - at)):
		game.press("down" if index > at else "up", hold=4, after=10)
	game.press("a", hold=4, after=10)
	wait_for_menu(game, open=False)


def bet(game, amount):
	pick(game, BETS.index(amount))


def hand(game, who):
	count = game.peek("wBlackjack%sCount" % who)
	return game.peek("wBlackjack%sHand" % who, 0, count) if count else []


DEAL_SETTLE = 40 # past a dealt card's pause, so the next press is read


def wait_until(game, check, what, timeout=600):
	for _ in range(0, timeout, 5):
		if check():
			return
		game.wait(5)
	raise HarnessTimeout("%s never happened. The screen:\n%s" % (what, game.screen_text()))


def wait_for_turn(game):
	"""Wait until the game is reading A and B on your turn."""
	count = your_turns(game)
	wait_until(game, lambda: your_turns(game) > count + 1, "your turn")


def hit(game):
	"""A, and wait for the card."""
	wait_for_turn(game)
	count = game.peek("wBlackjackPlayerCount")
	game.press("a")
	wait_until(game, lambda: game.peek("wBlackjackPlayerCount") > count, "a hit")
	game.wait(DEAL_SETTLE)


def stand(game):
	"""B, and wait for the dealer to turn the hole card."""
	wait_for_turn(game)
	game.press("b")
	wait_until(game, lambda: not game.peek("wBlackjackHoleHidden"), "standing")


def stand_or_done(game):
	"""Stand if the hand asks, then wait until it is over and the coins are counted."""
	count = your_turns(game)
	for _ in range(0, 1200, 5):
		if game.peek("wBlackjackHoleHidden") == 0:
			break
		if your_turns(game) > count + 1:
			stand(game)
			break
		game.wait(5)
	game.wait(PAYOUT_FRAMES)


def bar(game):
	"""The bottom bar's two labels, as (A)'s word and (B)'s, or None for a blank bar."""
	line, row = game.screen_lines()[17], tile_row(game, 17)
	if line.strip() == "" and BUTTON_A not in row:
		return None
	assert row[1] == BUTTON_A and row[11] == BUTTON_B, row
	return line[2:11].strip(), line[12:].strip()


def wait_for_bar(game, labels):
	"""Wait for the bar to show labels, then past the frames it takes to reach the screen, while the
	game isn't reading buttons yet."""
	wait_until(game, lambda: bar(game) == labels, "the %s/%s bar" % labels)
	game.wait(10)


def answer_leave(game, yes):
	"""Answer "Leave the table?", which the last press asked."""
	game.wait_for_text("Leave the table?")
	wait_for_bar(game, ("YES", "NO"))
	game.press("a" if yes else "b", hold=4, after=10)


def message(game):
	"""The message row, with the game's own "+" tile read as "+"."""
	line = game.screen_lines()[MESSAGE_ROW]
	row = game.peek("wTilemap", MESSAGE_ROW * 20, 20)
	return "".join("+" if t == PLUS_TILE else c for t, c in zip(row, line))


def result(game, text):
	"""Wait for the result, then for the coins to finish counting."""
	wait_until(game, lambda: text in message(game), "the result %r" % text, timeout=1200)
	game.wait(PAYOUT_FRAMES)


# The rules, by the routine that totals a hand

@pytest.mark.parametrize("cards, total", [
	([ACE, KING], 21),
	([ACE, ACE], 12),
	([ACE, 6], 17),
	([ACE, 6, 10], 17),
	([ACE, 5, ACE], 17),
	([ACE, 9, ACE], 21),
	([5, 6], 11),
	([JACK, QUEEN], 20),
	([KING, QUEEN, 2], 22),
	([ACE, ACE, ACE, ACE, 2, 2, 2, 2, 3, 3, 3], 21),
	([], 0),
])
def test_hand_total(game, cards, total):
	address = scratch_address(game, 0)
	for i, rank in enumerate(cards):
		game.pyboy.memory[address + i] = card(rank, i % 4)
	assert call(game, "Blackjack_HandTotal", hl=address, bc=len(cards))["a"] == total


# Playing hands

SHOE, CUT = 104, 78 # two decks; reshuffled before the next hand once 78 are dealt


def full_shoe():
	return sorted(card(rank, suit) for _ in range(2) for suit in range(4) for rank in range(ACE, KING + 1))


def rig_at(game, pos, *cards):
	"""Put these cards next in the shoe, from place pos."""
	for i, value in enumerate(cards):
		game.poke("wBlackjackDeck", value, pos + i)
	game.poke("wBlackjackDeckPos", pos)


def test_the_shoe_is_two_shuffled_decks(game):
	start(game)
	shoe = game.peek("wBlackjackDeck", 0, SHOE)
	assert sorted(shoe) == full_shoe()
	assert shoe != sorted(shoe) and shoe[:SHOE // 2] != shoe[SHOE // 2:]
	assert game.peek("wBlackjackDeckPos") == 0


def test_the_shoe_carries_on_between_hands(game):
	start(game)
	shoe = game.peek("wBlackjackDeck", 0, SHOE)
	bet(game, 10)
	stand_or_done(game)
	dealt = game.peek("wBlackjackDeckPos")
	assert dealt >= 4
	game.press("a")
	wait_for_bet(game)
	assert game.peek("wBlackjackDeck", 0, SHOE) == shoe
	assert game.peek("wBlackjackDeckPos") == dealt


def test_the_shoe_is_reshuffled_past_the_cut_card(game):
	start(game)
	rig_at(game, CUT - 4, card(10), card(10), card(7), card(9))
	bet(game, 10)
	stand(game)
	result(game, "You lose.")
	assert game.peek("wBlackjackDeckPos") == CUT
	sounds = record_sounds(game)
	game.press("a", hold=4, after=10)
	game.wait_for_text("Shuffling the")
	lines = game.screen_lines()
	assert lines[8][1:].startswith("Shuffling the") and lines[10][1:].startswith("shoe.")
	wait_for_bet(game)
	assert game.peek("wBlackjackDeckPos") == 0
	assert sorted(game.peek("wBlackjackDeck", 0, SHOE)) == full_shoe()
	assert sounds.count(sfx_constants()["SFX_DEAL_CARD"]) == 6, "a riffle of deal sounds"


def test_no_reshuffle_before_the_cut_card(game):
	start(game)
	rig_at(game, CUT - 5, card(10), card(10), card(7), card(9))
	bet(game, 10)
	stand(game)
	result(game, "You lose.")
	assert game.peek("wBlackjackDeckPos") == CUT - 1
	game.press("a", hold=4, after=10)
	wait_for_bet(game)
	assert game.peek("wBlackjackDeckPos") == CUT - 1


def test_deals_you_then_the_dealer_with_the_hole_card_down(game):
	start(game)
	rig(game, card(10, ODDISH), card(9, POLIWAG), card(6, PIKACHU), card(KING, JIGGLYPUFF))
	bet(game, 10)
	wait_for_turn(game)
	assert hand(game, "Player") == [card(10, ODDISH), card(6, PIKACHU)]
	assert hand(game, "Dealer") == [card(9, POLIWAG), card(KING, JIGGLYPUFF)]
	assert game.peek("wBlackjackHoleHidden")
	assert game.peek("wBlackjackBet") == 10
	assert coins(game) == 490
	assert sidebar_lines(game)[0] == ["COIN", "490"]


def test_hit_then_stand_and_win(game):
	start(game)
	rig(game, card(10), card(10), card(6), card(7), card(4))
	bet(game, 50)
	hit(game)
	stand(game)
	result(game, "You win! +50")
	assert hand(game, "Player") == [card(10), card(6), card(4)]
	assert hand(game, "Dealer") == [card(10), card(7)]
	assert coins(game) == 550


def test_twenty_one_stands_by_itself(game):
	start(game)
	rig(game, card(5), card(10), card(6), card(8), card(KING))
	bet(game, 10)
	hit(game)
	result(game, "You win! +10")
	assert hand(game, "Player") == [card(5), card(6), card(KING)]
	assert coins(game) == 510


def test_bust_loses_and_the_dealer_doesnt_draw(game):
	start(game)
	rig(game, card(10), card(5), card(6), card(6), card(KING), card(10))
	bet(game, 50)
	hit(game)
	result(game, "Bust! You lose.")
	assert hand(game, "Player") == [card(10), card(6), card(KING)]
	assert hand(game, "Dealer") == [card(5), card(6)]
	assert not game.peek("wBlackjackHoleHidden")
	assert coins(game) == 450


def test_dealer_stands_on_soft_17(game):
	start(game)
	rig(game, card(10), card(2), card(8), card(4), card(ACE), card(10))
	bet(game, 10)
	stand(game)
	result(game, "You win! +10")
	assert hand(game, "Dealer") == [card(2), card(4), card(ACE)]
	assert coins(game) == 510


def test_dealer_draws_below_17_and_busts(game):
	start(game)
	rig(game, card(10), card(10), card(2), card(2), card(3), card(10))
	bet(game, 100)
	stand(game)
	result(game, "Dealer busts! +100")
	assert hand(game, "Dealer") == [card(10), card(2), card(3), card(10)]
	assert coins(game) == 600


def test_lower_total_loses(game):
	start(game)
	rig(game, card(10), card(10), card(7), card(9))
	bet(game, 50)
	stand(game)
	result(game, "You lose.")
	assert hand(game, "Dealer") == [card(10), card(9)]
	assert coins(game) == 450


def test_equal_totals_push(game):
	start(game)
	rig(game, card(10), card(QUEEN), card(8), card(8))
	bet(game, 100)
	stand(game)
	result(game, "Push. Bet back.")
	assert coins(game) == 500


def test_blackjack_pays_3_to_2(game):
	start(game)
	rig(game, card(ACE), card(10), card(KING), card(7))
	bet(game, 50)
	result(game, "Blackjack! +75")
	assert coins(game) == 575
	assert not game.peek("wBlackjackHoleHidden")


def test_dealer_blackjack_wins_at_once(game):
	start(game)
	rig(game, card(10), card(ACE), card(9), card(QUEEN), card(2))
	bet(game, 50)
	result(game, "Dealer blackjack!")
	assert your_turns(game) == 0, "no turn for you"
	assert hand(game, "Player") == [card(10), card(9)]
	assert coins(game) == 450


def test_both_blackjack_push(game):
	start(game)
	rig(game, card(ACE), card(KING), card(JACK), card(ACE))
	bet(game, 100)
	result(game, "Push. Bet back.")
	assert coins(game) == 500


def test_next_hand_starts_fresh(game):
	start(game)
	rig(game, card(10), card(10), card(7), card(9))
	bet(game, 10)
	stand(game)
	result(game, "You lose.")
	game.press("a")
	wait_for_bet(game)
	assert hand(game, "Player") == []
	assert hand(game, "Dealer") == []
	assert game.peek("wBlackjackDeckPos") == 4, "the shoe carries on"
	rig(game, card(10), card(10), card(9), card(7))
	bet(game, 10)
	stand(game)
	result(game, "You win! +10")
	assert coins(game) == 500


# Coins

def test_bet_you_cant_cover_is_refused(game):
	start(game, start_coins=25)
	bet(game, 50)
	game.wait_for_text("Not enough coins.")
	game.wait(60)
	assert coins(game) == 25
	assert game.peek("wBlackjackPlayerCount") == 0
	game.press("a")
	wait_for_bet(game)
	rig(game, card(10), card(10), card(9), card(7))
	bet(game, 10)
	stand(game)
	result(game, "You win! +10")
	assert coins(game) == 35


def test_bet_of_all_your_coins(game):
	start(game, start_coins=50)
	rig(game, card(10), card(10), card(7), card(9))
	bet(game, 50)
	stand(game)
	result(game, "You lose.")
	assert coins(game) == 0


def test_winnings_stop_at_9999(game):
	start(game, start_coins=9990)
	rig(game, card(ACE), card(10), card(KING), card(7))
	bet(game, 100)
	result(game, "Blackjack! +150")
	assert coins(game) == 9999


def test_needs_a_coin_case(game):
	give_coin_case(game, False)
	set_coins(game, 100)
	launch(game)
	game.wait_for_text("COIN CASE.")
	game.wait(120)
	assert not in_the_game(game)
	assert coins(game) == 100


def test_needs_coins(game):
	give_coin_case(game)
	set_coins(game, 0)
	launch(game)
	game.wait_for_text("You have no coins.")
	game.wait(120)
	assert not in_the_game(game)


def test_leave_from_the_bet_window(game):
	start(game)
	game.wait(10)
	game.press("b", hold=4, after=10)
	answer_leave(game, yes=False)
	wait_for_bet(game)
	assert in_the_game(game)
	game.wait(10)
	game.press("b", hold=4, after=10)
	answer_leave(game, yes=True)
	assert left_the_game(game)
	assert coins(game) == 500


def test_b_in_the_bet_window_asks_to_leave(game):
	start(game)
	wait_for_menu(game)
	game.wait(10)
	game.press("b", hold=4, after=10)
	answer_leave(game, yes=True)
	assert left_the_game(game)
	assert coins(game) == 500


def test_leaving_after_a_result_keeps_the_winnings(game):
	start(game)
	rig(game, card(10), card(10), card(9), card(7))
	bet(game, 100)
	stand(game)
	result(game, "You win! +100")
	game.press("b", hold=4, after=10)
	answer_leave(game, yes=True)
	assert left_the_game(game)
	assert coins(game) == 600


def test_no_puts_the_result_back(game):
	start(game)
	rig(game, card(10), card(10), card(9), card(7))
	bet(game, 10)
	stand(game)
	result(game, "You win! +10")
	game.press("b", hold=4, after=10)
	answer_leave(game, yes=False)
	wait_until(game, lambda: "You win! +10" in message(game), "the result again")
	assert bar(game) == ("BET", "LEAVE")
	game.press("a", hold=4, after=10)
	wait_for_bet(game)


def test_leave_after_not_enough_coins(game):
	start(game, start_coins=25)
	bet(game, 50)
	game.wait_for_text("Not enough coins.")
	wait_for_bar(game, ("BET", "LEAVE"))
	game.press("b", hold=4, after=10)
	answer_leave(game, yes=True)
	assert left_the_game(game)
	assert coins(game) == 25


def test_no_puts_not_enough_coins_back(game):
	start(game, start_coins=25)
	bet(game, 50)
	game.wait_for_text("Not enough coins.")
	wait_for_bar(game, ("BET", "LEAVE"))
	game.press("b", hold=4, after=10)
	answer_leave(game, yes=False)
	wait_until(game, lambda: "Not enough coins." in message(game), "the message again")
	assert bar(game) == ("BET", "LEAVE")
	game.press("a", hold=4, after=10)
	wait_for_bet(game)


def test_start_does_nothing(game):
	start(game)
	wait_for_menu(game)
	game.wait(10)
	before = bet_menu_loops(game)
	game.press("start", hold=4, after=60)
	assert bet_menu_loops(game) > before + 30 and "Leave the table?" not in game.screen_text(), \
		"still in the bet menu"
	rig(game, card(10), card(10), card(6), card(7), card(4))
	bet(game, 50)
	wait_for_turn(game)
	game.press("start", hold=4, after=60)
	assert "Leave the table?" not in game.screen_text()
	assert bar(game) == ("HIT", "STAND")
	hit(game)
	stand(game)
	result(game, "You win! +50")
	assert coins(game) == 550


def test_the_bet_window_opens_on_the_last_bet(game):
	start(game)
	rig(game, card(10), card(10), card(7), card(9))
	bet(game, 50)
	stand(game)
	result(game, "You lose.")
	game.press("a", hold=4, after=10)
	wait_for_menu(game)
	game.wait(10)
	assert game.peek("wMenuCursorY") == BETS.index(50) + 1
	assert bet_menu(game) == ["10", "▶50", "100"]


def test_b_stands_and_a_hits_without_a_menu(game):
	start(game)
	rig(game, card(10), card(10), card(5), card(8), card(2))
	bet(game, 10)
	wait_for_turn(game)
	assert CURSOR not in game.screen_text(), "no HIT/STAND menu"
	hit(game)
	assert hand(game, "Player") == [card(10), card(5), card(2)]
	stand(game)
	result(game, "You lose.")


# The board

def tile_row(game, row):
	return game.peek("wTilemap", row * 20, 20)


def attr_row(game, row):
	return game.peek("wAttrmap", row * 20, 20)


def box(rows, left, top, right, bottom):
	return [r[left:right + 1] for r in rows[top:bottom + 1]]


def screen_attrs(game):
	"""The palettes on screen, from the BG map's attributes in VRAM rather than wAttrmap: a menu
	that only sends its tiles leaves wAttrmap right and the screen wrong."""
	low, high = game.peek("hBGMapAddress", 0, 2)
	base = high << 8 | low
	return [[game.pyboy.memory[1, base + r * 32 + c] & 7 for c in range(20)] for r in range(18)]


def is_white_box(game, left, top, right, bottom):
	white = [TEXT_PAL] * (right - left + 1)
	for attrs in ([attr_row(game, r) for r in range(18)], screen_attrs(game)):
		if not all(a == white for a in box(attrs, left, top, right, bottom)):
			return False
	return True


def small_font_rows():
	"""Each small-font character's 8 rows, as 4-bit numbers (bit 3 the leftmost pixel)."""
	from PIL import Image
	im = Image.open(GFX / "small_font.png").convert("L")
	return {ch: [sum(8 >> x for x in range(4) if im.getpixel((i * 4 + x, y)) < 128) for y in range(8)]
		for i, ch in enumerate(SMALL_FONT)}


def png_tile(name, index):
	"""Tile `index`, row by row, of a 4-grey PNG in gfx/blackjack, as 2bpp: white is colour 0, black 3."""
	from PIL import Image
	im = Image.open(GFX / name).convert("L")
	width = im.size[0] // 8
	left, top = index % width * 8, index // width * 8
	out = bytearray()
	for y in range(8):
		row = [round((255 - im.getpixel((left + x, top + y))) / 85) for x in range(8)]
		out.append(sum((c & 1) << (7 - x) for x, c in enumerate(row)))
		out.append(sum((c >> 1) << (7 - x) for x, c in enumerate(row)))
	return bytes(out)


def sheet_tile(index):
	"""Cell `index` of sidebar.png, the sidebar's picture, row by row."""
	return png_tile("sidebar.png", index)


def bank1_bg_tile(game, tile):
	"""A BG tile in VRAM bank 1, $00-$7f in vTiles2 and $80-$ff in vTiles1."""
	base = (0x9000 if tile < 0x80 else 0x8000) + tile * 16
	return bytes(game.pyboy.memory[1, base + i] for i in range(16))


def shows_sheet(game, row, col):
	"""Whether the sidebar's cell shows its own art from sidebar.png."""
	return bank1_bg_tile(game, tile_row(game, row)[col]) == sheet_tile(row * 5 + col - 15)


def over_art(art, left, right, font, white=False):
	"""Two characters drawn over an art tile, as the game does: black (colour 3) sets both planes,
	white (colour 0) clears them."""
	out = bytearray()
	for r in range(8):
		ink = font[left][r] << 4 | font[right][r]
		if white:
			out += bytes([art[2 * r] & ~ink & 0xff, art[2 * r + 1] & ~ink & 0xff])
		else:
			out += bytes([art[2 * r] | ink, art[2 * r + 1] | ink])
	return bytes(out)


def read_cells(game, vram_tile, art_tile, tiles, alphabet, white=False):
	"""The characters drawn over `tiles` tiles of art, from VRAM bank 1."""
	font = small_font_rows()
	text = ""
	for t in range(tiles):
		base = 0x9000 + (vram_tile + t) * 16
		shown = bytes(game.pyboy.memory[1, base + i] for i in range(16))
		art = sheet_tile(art_tile + t)
		pairs = [a + b for a in alphabet for b in alphabet if over_art(art, a, b, font, white) == shown]
		assert pairs, ("nothing in the small font draws tile", vram_tile + t)
		text += pairs[0]
	return text


def coins_cells(game):
	"""The coin count's row as drawn, white over the panel under COINS."""
	return read_cells(game, COINS_TILES, COINS_ROW * 5, 5, " 0123456789", white=True)


YOU_NUDGE, THEM_NUDGE, PROMPT_NUDGE = (2, 1), (-1, 1), (1, 0) # pixels right and down


def field_bytes(text, art_tile, white=False, nudge=(0, 0)):
	"""What the game draws for `text` over art tiles from `art_tile`, two characters a tile,
	nudged (right, down) in pixels: the ink is worked out for the whole field, moved, then drawn."""
	font = small_font_rows()
	tiles = len(text) // 2
	dx, dy = nudge
	rows = []
	for r in range(8):
		g = r - dy
		row = 0
		for t in range(tiles):
			ink = font[text[2 * t]][g] << 4 | font[text[2 * t + 1]][g] if 0 <= g < 8 else 0
			row = row << 8 | ink
		bits = tiles * 8
		row = (row >> dx if dx > 0 else row << -dx) & ((1 << bits) - 1)
		rows.append([(row >> (8 * (tiles - 1 - t))) & 0xff for t in range(tiles)])
	out = bytearray()
	for t in range(tiles):
		art = sheet_tile(art_tile + t)
		for r in range(8):
			ink = rows[r][t]
			if white:
				out += bytes([art[2 * r] & ~ink & 0xff, art[2 * r + 1] & ~ink & 0xff])
			else:
				out += bytes([art[2 * r] | ink, art[2 * r + 1] | ink])
	return bytes(out)


def centred(number, cells):
	digits = str(number) if number else ""
	start = (cells - len(digits)) // 2
	return " " * start + digits + " " * (cells - start - len(digits))


def total_cells(game, who):
	"""YOU's or THEM's total as drawn, white over its panel and nudged into it."""
	tiles, x, nudge = (YOU_TILES, YOU_X, YOU_NUDGE) if who == "YOU" else (THEM_TILES, THEM_X, THEM_NUDGE)
	shown = bytes(game.pyboy.memory[1, 0x9000 + tiles * 16 + i] for i in range(32))
	for n in range(32):
		text = centred(n, 4)
		if field_bytes(text, TOTALS_ROW * 5 + x - 15, white=True, nudge=nudge) == shown:
			return text
	raise AssertionError(("no total draws", who))


def sidebar_lines(game):
	"""The coin count and the dealer's and your totals, read back from their tiles, as
	[label, number] (the labels are in the art)."""
	return [["COIN"] + coins_cells(game).split(), ["DEALER"] + total_cells(game, "THEM").split(),
		["YOU"] + total_cells(game, "YOU").split()]


def test_the_totals_are_centred_in_white_under_you_and_them(game):
	start(game)
	rig(game, card(10), card(7), card(2), card(KING))
	bet(game, 10)
	wait_for_turn(game)
	assert total_cells(game, "YOU") == " 12 "
	assert total_cells(game, "THEM") == " 7  ", "an odd count sits half a character left"


def test_bet_is_a_pixel_in_from_the_edge(game):
	start(game)
	wait_for_menu(game)
	shown = bytes(game.pyboy.memory[1, 0x9000 + PROMPT_TILES * 16 + i] for i in range(32))
	assert shown == field_bytes("BET?", PROMPT_ROW * 5, nudge=PROMPT_NUDGE)


def test_the_totals_are_nudged_into_their_panels(game):
	"""YOU's two pixels right and one down, THEM's a pixel left and down: checked pixel for pixel."""
	start(game)
	rig(game, card(10), card(7), card(2), card(KING))
	bet(game, 10)
	wait_for_turn(game)
	you = bytes(game.pyboy.memory[1, 0x9000 + YOU_TILES * 16 + i] for i in range(32))
	them = bytes(game.pyboy.memory[1, 0x9000 + THEM_TILES * 16 + i] for i in range(32))
	assert you == field_bytes(" 12 ", TOTALS_ROW * 5 + YOU_X - 15, white=True, nudge=(2, 1))
	assert them == field_bytes(" 7  ", TOTALS_ROW * 5 + THEM_X - 15, white=True, nudge=(-1, 1))


@pytest.mark.parametrize("amount, cells", [
	(500, "   500    "), # an odd count sits half a character left
	(9999, "   9999   "),
	(50, "    50    "),
	(7, "    7     "),
])
def test_the_coin_count_is_centred_in_white(game, amount, cells):
	start(game, start_coins=amount)
	wait_for_menu(game)
	assert coins_cells(game) == cells


def bet_menu(game):
	"""The bet menu's three rows, read back from their tiles, with "▶" by the cursor's."""
	rows = []
	for k, row in enumerate(MENU_ROWS):
		cells = read_cells(game, MENU_TILES + k * 3, row * 5 + MENU_X - 15, 3, " 0123456789▶")
		rows.append(cells.replace(" ", ""))
	return rows


def test_no_top_bar_and_the_bottom_bar(game):
	start(game)
	assert set(tile_row(game, 0)[:TABLE_WIDTH]) <= set(FELT_TILES), "felt where the top bar was"
	assert attr_row(game, 0)[:TABLE_WIDTH] == [FELT_PAL] * TABLE_WIDTH
	assert attr_row(game, 17) == [TEXT_PAL] * 20
	assert "DEALER" not in game.screen_text() and "YOU" not in game.screen_text(), \
		"the totals are in the sidebar's small text, not the font"


def test_the_sidebar_shows_the_totals(game):
	start(game)
	wait_for_menu(game)
	assert sidebar_lines(game) == [["COIN", "500"], ["DEALER"], ["YOU"]]
	rig(game, card(10), card(7), card(2), card(KING))
	bet(game, 50)
	wait_for_turn(game)
	assert sidebar_lines(game) == [["COIN", "450"], ["DEALER", "7"], ["YOU", "12"]], \
		"the dealer's face-up card alone while the hole is down"
	stand(game)
	result(game, "You lose.")
	assert sidebar_lines(game) == [["COIN", "450"], ["DEALER", "17"], ["YOU", "12"]]


def test_the_sidebar_counts_coins(game):
	start(game, start_coins=9990)
	rig(game, card(10), card(10), card(9), card(7))
	bet(game, 100)
	stand(game)
	result(game, "You win! +100")
	assert sidebar_lines(game)[0] == ["COIN", "9999"]


def screen_attr_bytes(game):
	low, high = game.peek("hBGMapAddress", 0, 2)
	base = high << 8 | low
	return [[game.pyboy.memory[1, base + r * 32 + c] for c in range(20)] for r in range(18)]


def test_the_sidebar_is_drawn_over_sprites(game):
	start(game)
	wait_for_menu(game)
	for attrs in ([attr_row(game, r) for r in range(18)], screen_attr_bytes(game)):
		for r in FELT_ROWS:
			assert attrs[r][TABLE_WIDTH:] == [SIDEBAR_ATTR] * 5, r


def meowth_frame_on_screen(game):
	"""The frame Meowth is on (wBlackjackMeowthFrame), checked against the screen: each of
	Meowth's 5x5 cells shows a tile of VRAM bank 1 from $80 holding that cell of the frame in
	meowth.png."""
	x, y = MEOWTH_SPOT
	frame = game.peek("wBlackjackMeowthFrame")
	for r in range(MEOWTH_SIZE):
		for c in range(MEOWTH_SIZE):
			tile = tile_row(game, y + r)[x + c]
			assert tile >= MEOWTH_TILES, (r, c, tile)
			cell = frame * MEOWTH_SIZE * MEOWTH_SIZE + r * MEOWTH_SIZE + c
			assert bank1_bg_tile(game, tile) == png_tile("meowth.png", cell), ("frame", frame, r, c)
	return frame


def meowth_frames_over_time(game, frames=160):
	"""The frames shown, in order, with repeats dropped."""
	seen = []
	for _ in range(0, frames, 2):
		frame = meowth_frame_on_screen(game)
		if not seen or seen[-1] != frame:
			seen.append(frame)
		game.wait(2)
	return seen


def assert_back_and_forth(seen, first):
	assert set(seen) == {first, first + 1, first + 2}, seen
	assert all(abs(a - b) == 1 for a, b in zip(seen, seen[1:])), ("1 2 3 2, never 3 to 1", seen)


def test_meowth_idles_while_betting(game):
	start(game)
	wait_for_menu(game)
	assert game.peek("wBlackjackMeowth") == MEOWTH_IDLE
	assert set(meowth_frames_over_time(game)) == {0, 1}


@pytest.mark.parametrize("cards, text, state", [
	([card(10), card(10), card(9), card(7)], "You win! +10", MEOWTH_CHEER),
	([card(10), card(10), card(6), card(6), card(KING)], "Dealer busts! +10", MEOWTH_CHEER),
	([card(ACE), card(10), card(KING), card(7)], "Blackjack! +15", MEOWTH_BIG_CHEER),
	([card(10), card(10), card(7), card(9)], "You lose.", MEOWTH_SLUMP),
	([card(10), card(ACE), card(7), card(KING)], "Dealer blackjack!", MEOWTH_SLUMP),
	([card(10), card(10), card(9), card(9)], "Push. Bet back.", MEOWTH_STILL),
])
def test_meowth_reacts_to_the_result(game, cards, text, state):
	start(game)
	rig(game, *cards)
	bet(game, 10)
	stand_or_done(game)
	wait_until(game, lambda: text in message(game), "the result %r" % text)
	game.wait(100)
	assert game.peek("wBlackjackMeowth") == state, "held while the result is up"
	seen = meowth_frames_over_time(game)
	assert set(seen) == MEOWTH_FRAMES[state], seen
	game.press("a", hold=4, after=10)
	wait_for_menu(game)
	assert game.peek("wBlackjackMeowth") == MEOWTH_IDLE, "idling again in the bet window"


def meowth_runs(game, frames=240):
	"""Meowth's frames, sampled every frame, as (frame, how many frames it stayed up), without the
	first and last runs, which the sampling cuts short."""
	runs = []
	for _ in range(frames):
		frame = meowth_frame_on_screen(game)
		if runs and runs[-1][0] == frame:
			runs[-1][1] += 1
		else:
			runs.append([frame, 1])
		game.wait(1)
	return [tuple(r) for r in runs[1:-1]]


def assert_cycle(runs, frames, lengths):
	"""The runs go round frames in order, each lasting its length, give or take two frames (a copy
	can land a frame late)."""
	def fits(start):
		return all(frame == frames[(start + i) % len(frames)]
			and abs(length - lengths[(start + i) % len(frames)]) <= 2
			for i, (frame, length) in enumerate(runs))
	# a frame can come round twice in a cycle, so try each place the first run could be
	assert any(fits(k) for k, f in enumerate(frames) if f == runs[0][0]), runs


def test_meowth_jumps_when_you_win(game):
	start(game)
	rig(game, card(10), card(10), card(9), card(7))
	bet(game, 10)
	stand(game)
	# once the message is typed and the coins counted: Meowth doesn't move while text prints
	result(game, "You win! +10")
	assert game.peek("wBlackjackMeowth") == MEOWTH_CHEER
	# idle 1 1, idle 2 2, happy 1, happy 2, happy 1, at 6 frames a step
	assert_cycle(meowth_runs(game), [0, 1, 2, 3, 2], [12, 12, 6, 6, 6])


def test_meowth_jumps_higher_for_blackjack(game):
	start(game)
	rig(game, card(ACE), card(10), card(KING), card(7))
	bet(game, 10)
	result(game, "Blackjack! +15")
	assert game.peek("wBlackjackMeowth") == MEOWTH_BIG_CHEER
	# idle 1 1, idle 2 2, very happy 1, very happy 2, very happy 1, at 4 frames a step
	assert_cycle(meowth_runs(game), [0, 1, 4, 5, 4], [8, 8, 4, 4, 4])


def test_meowth_idles_on_two_frames(game):
	start(game)
	wait_for_menu(game)
	# 1 1 2 at 16 frames a step
	assert_cycle(meowth_runs(game), [0, 1], [32, 16])


def test_meowth_slumps_on_one_frame(game):
	start(game)
	rig(game, card(10), card(10), card(7), card(9))
	bet(game, 10)
	stand(game)
	wait_until(game, lambda: game.peek("wBlackjackMeowth") == MEOWTH_SLUMP, "the slump")
	assert meowth_frames_over_time(game) == [6]


def test_meowth_idles_on_your_turn_and_sits_still_for_the_dealer(game):
	start(game)
	rig(game, card(10), card(10), card(6), card(6), card(4))
	bet(game, 10)
	wait_for_turn(game)
	assert game.peek("wBlackjackMeowth") == MEOWTH_IDLE, "deciding to hit or stand"
	assert set(meowth_frames_over_time(game)) == {0, 1}
	stand(game)
	assert game.peek("wBlackjackMeowth") == MEOWTH_STILL, "the dealer's turn"
	assert meowth_frame_on_screen(game) == 0

def test_the_bar_says_what_a_and_b_do(game):
	start(game, start_coins=60)
	wait_for_menu(game)
	assert bar(game) == ("DEAL", "LEAVE")
	# 16 against the dealer's 16, who draws a 4
	rig(game, card(10), card(10), card(6), card(6), card(4))
	bet(game, 50)
	wait_for_turn(game)
	assert bar(game) == ("HIT", "STAND")
	stand(game)
	assert bar(game) is None, "nothing to press while the dealer plays"
	result(game, "You lose.")
	assert bar(game) == ("BET", "LEAVE")
	assert game.screen_lines()[17][18:] == "  ", "no blinking cursor"
	game.press("a", hold=4, after=10)
	bet(game, 50)
	game.wait_for_text("Not enough coins.")
	wait_for_bar(game, ("BET", "LEAVE"))
	game.press("b", hold=4, after=10)
	game.wait_for_text("Leave the table?")
	wait_for_bar(game, ("YES", "NO"))


def check_felt(game, rows):
	"""The felt pattern on these rows of the table: bands two rows tall from the top, blank but for
	a 2x2 pattern every sixth column lined up with the table's right edge (columns 1, 7, 13 in the
	first band, 4 and 10 in the next, alternating), and the last row plain; the dealer's side (rows
	0-7) in the copies with the greens swapped. Returns the patterns seen (by their top left tile)."""
	seen = set()
	tiles = {r: tile_row(game, r)[:TABLE_WIDTH] for r in rows}
	for r in rows:
		side = DEALER_FELT if r in DEALER_FELT_ROWS else 0
		if r == FELT_ROWS[-1]:
			assert tiles[r] == [FELT_BLANK + side] * TABLE_WIDTH
			assert attr_row(game, r)[:TABLE_WIDTH] == [FELT_PAL] * TABLE_WIDTH
			continue
		band, lower = divmod(r, 2)
		first = 1 if band % 2 == 0 else 4
		for x, t in enumerate(tiles[r]):
			if x % 6 == first and x < TABLE_WIDTH - 1:
				top_left = t - FELT_PNG_WIDTH if lower else t
				assert top_left == FELT_PATTERN + side, (r, x, t)
				assert tiles[r][x + 1] == t + 1, (r, x)
				if not lower and r + 1 in tiles:
					assert tiles[r + 1][x] == t + FELT_PNG_WIDTH, (r, x)
				seen.add(top_left)
			elif x % 6 == (first + 1) % 6 and x > 0:
				pass # the pattern's right half, checked with its left
			else:
				assert t == FELT_BLANK + side, (r, x, t)
		assert attr_row(game, r)[:TABLE_WIDTH] == [FELT_PAL] * TABLE_WIDTH, r
	return seen


def test_felt_is_a_staggered_pattern(game):
	start(game)
	clear_rows = list(FELT_ROWS) # nothing on the table while betting
	assert check_felt(game, clear_rows) == {FELT_PATTERN, FELT_PATTERN + DEALER_FELT}, "both sides show"
	felt = [tile_row(game, r)[:TABLE_WIDTH] for r in clear_rows]
	rig(game, card(10), card(10), card(9), card(7))
	bet(game, 10)
	stand(game)
	result(game, "You win! +10")
	game.press("a")
	wait_for_bet(game)
	assert [tile_row(game, r)[:TABLE_WIDTH] for r in clear_rows] == felt, "the same tiles after a hand"


def swap_colours_0_and_1(tiles):
	"""2bpp tiles with colours 0 and 1 swapped: the low plane flipped where the high plane is clear."""
	out = bytearray(tiles)
	for i in range(0, len(out), 2):
		out[i] ^= ~out[i + 1] & 0xff
	return bytes(out)


def test_the_dealers_side_has_the_greens_swapped(game):
	start(game)
	felt = (GFX / "felt.2bpp").read_bytes()
	assert len(felt) == FELT_PNG_TILES * 16
	assert vram_tiles(game, FELT_TILES[0], FELT_PNG_TILES) == felt, "felt.png as drawn"
	dealer = vram_tiles(game, FELT_TILES[0] + DEALER_FELT, FELT_PNG_TILES)
	assert dealer == swap_colours_0_and_1(felt), "and again with colours 0 and 1 swapped"
	assert dealer != felt
	assert swap_colours_0_and_1(bytes([0b10100000, 0b11000000])) == bytes([0b10011111, 0b11000000]), \
		"0 and 1 swap, 2 and 3 stay"


def test_betting_is_in_the_sidebar(game):
	start(game)
	wait_for_menu(game)
	assert bet_menu(game) == ["▶10", "50", "100"]
	for k, row in enumerate(MENU_ROWS):
		assert tile_row(game, row)[MENU_X:MENU_X + 3] == [MENU_TILES + k * 3 + c for c in range(3)]
	assert tile_row(game, PROMPT_ROW)[15:17] == [PROMPT_TILES, PROMPT_TILES + 1], "above the bets"
	assert tile_row(game, 2)[:TABLE_WIDTH] == tile_row(game, 2)[:TABLE_WIDTH] and \
		"Your bet?" not in game.screen_text() and CURSOR not in game.screen_text(), \
		"no prompt and no menu on the table"
	game.press("down", hold=4, after=10)
	game.press("down", hold=4, after=10)
	assert bet_menu(game) == ["10", "50", "▶100"]
	game.press("down", hold=4, after=10)
	assert bet_menu(game) == ["10", "50", "▶100"], "no further than the last bet"
	game.press("up", hold=4, after=10)
	assert bet_menu(game) == ["10", "▶50", "100"]
	rig(game, card(10), card(10), card(6), card(7))
	game.press("a", hold=4, after=10)
	wait_for_turn(game)
	assert game.peek("wBlackjackBet") == 50
	for row in MENU_ROWS:
		for col in range(MENU_X, MENU_X + 3):
			assert shows_sheet(game, row, col), ("the menu goes when the hand is dealt", row, col)
	for col in (15, 16):
		assert shows_sheet(game, PROMPT_ROW, col), col


def test_the_sidebar_is_the_picture_around_the_numbers(game):
	start(game)
	wait_for_menu(game)
	for row in range(12):
		for col in range(15, 20):
			coins = row == COINS_ROW
			number = row == TOTALS_ROW and col in (YOU_X, YOU_X + 1, THEM_X, THEM_X + 1)
			menu = row in MENU_ROWS and MENU_X <= col < MENU_X + 3
			prompt = row == PROMPT_ROW and col < 17
			if not coins and not number and not menu and not prompt:
				assert shows_sheet(game, row, col), (row, col)
				assert SHEET_TILES <= tile_row(game, row)[col] < MEOWTH_TILES, (row, col)


def test_the_sidebar_and_meowth_keep_each_tile_once(game):
	"""sidebar.png and meowth.png are built with each different tile once, all in VRAM bank 1 from
	the start: the sheet from $20, every Meowth frame's tiles from $80."""
	sheet = (GFX / "sidebar.2bpp").read_bytes()
	meowth = (GFX / "meowth.2bpp").read_bytes()
	for data in (sheet, meowth):
		tiles = [data[i:i + 16] for i in range(0, len(data), 16)]
		assert len(set(tiles)) == len(tiles)
	assert len(sheet) // 16 < 60 and len(meowth) // 16 < 7 * 25
	start(game)
	assert b"".join(bank1_bg_tile(game, SHEET_TILES + t) for t in range(len(sheet) // 16)) == sheet
	before = b"".join(bank1_bg_tile(game, MEOWTH_TILES + t) for t in range(len(meowth) // 16))
	assert before == meowth
	frame = meowth_frame_on_screen(game)
	rig(game, card(ACE), card(10), card(KING), card(7))
	bet(game, 10)
	for _ in range(60):
		game.wait(5)
		if meowth_frame_on_screen(game) != frame:
			break
	else:
		raise AssertionError("Meowth never changed frame")
	after = b"".join(bank1_bg_tile(game, MEOWTH_TILES + t) for t in range(len(meowth) // 16))
	assert after == before, "a frame change only moves the tilemap"


def in_the_message_box(game, text):
	"""Whether text is on the message box's first line, in a white box the dialogue box's size."""
	lines = game.screen_lines()
	left, top, right, bottom = MESSAGE_BOX
	return (message(game)[1:].startswith(text)
		and lines[top][left] == "┌" and lines[bottom][right] == "┘"
		and all(line[left] == "│" for line in lines[top + 1:bottom])
		and is_white_box(game, *MESSAGE_BOX))


def test_bet_you_cant_cover_says_so_in_the_message_box(game):
	start(game, start_coins=25)
	bet(game, 50)
	game.wait_for_text("Not enough coins.")
	game.wait(30)
	assert in_the_message_box(game, "Not enough coins.")
	assert game.peek("wBlackjackBar") != 1, "the bet menu is down"


def test_results_show_in_the_message_box(game):
	start(game)
	rig(game, card(10), card(10), card(9), card(7))
	bet(game, 100)
	stand(game)
	result(game, "You win! +100")
	assert in_the_message_box(game, "You win! +100")
	game.press("a", hold=4, after=10)
	wait_for_menu(game)
	assert attr_row(game, 7)[:6] == [FELT_PAL] * 6, "the box goes with the message"
	assert attr_row(game, 7)[TABLE_WIDTH:] == [SIDEBAR_ATTR] * 5, "and the sidebar comes back"


def screen_cells(game, rows, cols):
	"""Each cell's (tile, attribute) in the BG map in VRAM, as the screen shows it."""
	low, high = game.peek("hBGMapAddress", 0, 2)
	base = high << 8 | low
	return {(r, c): (game.pyboy.memory[0, base + r * 32 + c], game.pyboy.memory[1, base + r * 32 + c])
		for r in rows for c in cols}


def test_the_sidebar_never_shows_half_redrawn_under_the_message_box(game):
	"""The message box closing over the sidebar: each cell shows either the box (its tile and the
	text palette) or the sidebar (its tile and the sidebar's attribute), never one's tile with the
	other's attribute, which draws garbage from the wrong VRAM bank for a few frames."""
	start(game, start_coins=10)
	rig(game, card(10), card(10), card(7), card(9))
	bet(game, 10)
	stand(game)
	result(game, "You lose.")
	game.press("a", hold=4, after=10)
	bet(game, 10)
	game.wait_for_text("Not enough coins.")
	wait_for_bar(game, ("BET", "LEAVE"))
	rows, cols = range(MESSAGE_BOX[1], MESSAGE_BOX[3] + 1), range(TABLE_WIDTH, 20)
	box = screen_cells(game, rows, cols)
	game.press("a", hold=2, after=0)
	seen = []
	for _ in range(120):
		seen.append(screen_cells(game, rows, cols))
		game.wait(1)
	sidebar = seen[-1]
	assert all(a == SIDEBAR_ATTR for _, a in sidebar.values()), "the sidebar again at the end"
	for frame, cells in enumerate(seen):
		for cell, now in cells.items():
			assert now in (box[cell], sidebar[cell]), (frame, cell, now, box[cell], sidebar[cell])


def test_the_sidebar_never_shows_half_redrawn_as_the_box_opens(game):
	start(game, start_coins=10)
	rows, cols = range(MESSAGE_BOX[1], MESSAGE_BOX[3] + 1), range(TABLE_WIDTH, 20)
	wait_for_menu(game)
	sidebar = screen_cells(game, rows, cols)
	game.wait(10)
	game.press("down", hold=4, after=10)
	game.press("a", hold=2, after=0)
	seen = []
	for _ in range(120):
		seen.append(screen_cells(game, rows, cols))
		game.wait(1)
	box = seen[-1]
	assert all(a & 7 == TEXT_PAL for _, a in box.values()), "the box at the end"
	space = 0x7f # the box is drawn empty and its message typed in after
	for frame, cells in enumerate(seen):
		for cell, now in cells.items():
			empty_box = (space, box[cell][1])
			assert now in (sidebar[cell], box[cell], empty_box), (frame, cell, now, sidebar[cell], box[cell])


def test_leave_the_table_asks_in_the_message_box(game):
	start(game)
	rig(game, card(10), card(10), card(9), card(7))
	bet(game, 10)
	stand(game)
	result(game, "You win! +10")
	game.press("b", hold=4, after=10)
	game.wait_for_text("Leave the table?")
	game.wait(30)
	assert in_the_message_box(game, "Leave the table?")
	assert CURSOR not in game.screen_text(), "no YES/NO box"
	assert bar(game) == ("YES", "NO")


def test_a_seventh_card_goes_in_the_sixth_spot(game):
	start(game)
	# A A A A 2 2 2 is 20: seven cards and still under 21
	cards = [ACE, ACE, ACE, ACE, 2, 2, 2]
	rig(game, card(cards[0]), card(10), card(cards[1]), card(7), *map(card, cards[2:]))
	bet(game, 10)
	for _ in cards[2:]:
		hit(game)
	wait_for_turn(game)
	assert hand(game, "Player") == list(map(card, cards))
	# Card n's rank shows one column right of its left edge, at column 2 + 2n.
	ranks = tile_row(game, PLAYER_ROW + 1)[2:14:2]
	assert ranks == [RANK_TILES + rank - 1 for rank in cards[:5] + cards[6:]]
	assert attr_row(game, PLAYER_ROW)[TABLE_WIDTH] == SIDEBAR_ATTR, "the 6th spot ends at column 14"


# The deck

def card_box(game, rows, x, y):
	return [r[x:x + 4] for r in rows[y:y + 6]]


def test_the_hole_card_is_the_decks_whole_back(game):
	start(game)
	rig(game, card(10), card(9), card(6), card(KING))
	bet(game, 10)
	wait_for_turn(game)
	tiles = [tile_row(game, r) for r in range(18)]
	attrs = [attr_row(game, r) for r in range(18)]
	# the dealer's second card, from column 3, with its corners over the first card and the felt
	back = [[BACK_TILES + r * 4 + c for c in range(4)] for r in range(6)]
	back[0][0], back[5][0] = OVERLAP_BACK, OVERLAP_BACK_BOTTOM_LEFT
	back[0][3], back[5][3] = BACK_CORNERS, BACK_CORNERS + 1
	assert card_box(game, tiles, 3, 1) == back
	pals = [[BACK_PAL] * 4 for _ in range(6)]
	pals[0][3] = pals[5][3] = BACK_PAL | 8 # the back's own corners, in VRAM bank 1
	assert card_box(game, attrs, 3, 1) == pals


@pytest.mark.parametrize("suit", [PIKACHU, ODDISH, JIGGLYPUFF, POLIWAG])
def test_each_suit_has_its_picture_and_palette(game, suit):
	start(game)
	rig(game, card(10), card(9), card(KING, suit), card(7))
	bet(game, 10)
	wait_for_turn(game)
	tiles = [tile_row(game, r) for r in range(18)]
	attrs = [attr_row(game, r) for r in range(18)]
	face = card_box(game, tiles, 3, PLAYER_ROW) # your second card, the top one
	assert face[0][0] == OVERLAP_TILES + suit, "its suit, in the corner over the first card"
	assert face[1][1] == RANK_TILES + KING - 1
	assert face[2:5] == [[PICTURE_TILES + suit * 12 + r * 4 + c for c in range(4)] for r in range(3)]
	pals = [[suit] * 4 for _ in range(6)]
	pals[0][3] = pals[5][3] = CORNER_ATTR # the right corners, on the felt
	assert card_box(game, attrs, 3, PLAYER_ROW) == pals


def vram_tiles(game, first, count):
	start = 0x9000 + first * 16 # vTiles2
	return bytes(game.pyboy.memory[0, start + i] for i in range(count * 16))


def deck_palettes(deck):
	"""deck.pal's colors as the game stores them: 15-bit, little-endian."""
	text = (DECKS / deck / "deck.pal").read_text(encoding="utf-8")
	out = bytearray()
	for r, g, b in re.findall(r"RGB\s+(\d+),\s*(\d+),\s*(\d+)", text):
		word = int(r) | int(g) << 5 | int(b) << 10
		out += bytes([word & 0xff, word >> 8])
	return bytes(out)


def test_the_game_uses_the_french_deck(game):
	start(game)
	for name, first, count in (("suits", SUIT_TILES, 4), ("pictures", PICTURE_TILES, 48),
			("back", BACK_TILES, 24)):
		built = (DECKS / "french" / (name + ".2bpp")).read_bytes()
		assert vram_tiles(game, first, count) == built, name
	pals = bytes(game.peek("wBGPals1", 0, 8 * 8))
	expected = deck_palettes("french")
	assert pals[:4 * 8] == expected[:4 * 8], "the suits' palettes"
	assert pals[BACK_PAL * 8:BACK_PAL * 8 + 8] == expected[4 * 8:], "the back's palette"


# The card machines

def record_sounds(game):
	"""The sound effects the game plays from now on, by number, as a list that fills as it runs."""
	sounds = []
	bank, address = game.pyboy.symbol_lookup("PlaySFX")
	registers = game.pyboy.register_file
	game.pyboy.hook_register(bank, address, lambda s: s.append(registers.D << 8 | registers.E), sounds)
	return sounds


def test_each_dealt_card_makes_the_deal_sound(game):
	start(game)
	rig(game, card(10), card(10), card(9), card(7))
	sounds = record_sounds(game)
	bet(game, 10)
	wait_for_turn(game)
	assert sounds.count(sfx_constants()["SFX_DEAL_CARD"]) == 4, sounds


def test_the_deal_sound_is_peck_at_full_volume():
	text = (Path(__file__).resolve().parent.parent / "audio" / "sfx.asm").read_text(encoding="utf-8")
	peck = re.search(r"^Sfx_Peck_Ch8:\n\tnoise_note (\d+), (\d+), (-?\d+), (\d+)", text, re.M).groups()
	deal = re.search(r"^Sfx_DealCard:.*?noise_note (\d+), (\d+), (-?\d+), (\d+)", text, re.M | re.S).groups()
	assert deal == (peck[0], "15", peck[2], peck[3]), (peck, deal)


def test_turning_the_hole_card_is_silent(game):
	start(game)
	rig(game, card(10), card(10), card(9), card(7))
	bet(game, 10)
	wait_for_turn(game)
	sounds = record_sounds(game)
	stand(game)
	result(game, "You win! +10")
	assert sfx_constants()["SFX_CHOOSE_A_CARD"] not in sounds, sounds


def sfx_constants():
	text = (Path(__file__).resolve().parent.parent / "constants" / "sfx_constants.asm").read_text(
		encoding="utf-8")
	return {name: i for i, name in enumerate(re.findall(r"^\s*const (SFX_\w+)", text, re.M))}


def test_coins_count_down_when_the_bet_is_taken(game):
	start(game)
	rig(game, card(10), card(10), card(9), card(7))
	pick_up_to(game, 100)
	seen = set()
	for _ in range(300):
		seen.add(coins(game))
		game.wait(1)
	assert coins(game) == 400
	assert len({c for c in seen if 400 < c < 500}) >= 15, sorted(seen)


def pick_up_to(game, amount):
	"""Move the bet window's cursor to amount and press A, without waiting for the window to close."""
	wait_for_menu(game)
	game.wait(10)
	at, index = game.peek("wBlackjackBetChoice") - 1, BETS.index(amount)
	for _ in range(abs(index - at)):
		game.press("down" if index > at else "up", hold=4, after=10)
	game.press("a", hold=4, after=1)


def oam(game):
	"""The shadow OAM's 40 entries as (y, x, tile, attributes)."""
	raw = game.peek("wShadowOAM", 0, 160)
	return [tuple(raw[i:i + 4]) for i in range(0, 160, 4)]


def card_tiles(rank, suit):
	"""A face-up card's 24 tiles, row by row."""
	return ([SUIT_TILES + suit, 0x0f, 0x0f, 0x10, 0x0d, RANK_TILES + rank - 1, 0x0e, 0x11]
		+ [PICTURE_TILES + suit * 12 + i for i in range(12)] + [0x12, 0x13, 0x13, 0x14])


def test_a_dealt_card_slides_out_from_behind_the_sidebar(game):
	start(game)
	rig(game, card(9, ODDISH), card(10), card(9), card(7))
	pick_up_to(game, 10)
	wanted = card_tiles(9, ODDISH)
	path, blank_bar = [], True
	for _ in range(400):
		sprites = oam(game)[:24]
		if [t for _, _, t, _ in sprites] == wanted:
			assert all(a & 7 == ODDISH for _, _, _, a in sprites), "in the card's palette"
			path.append(sprites[0][:2])
			blank_bar = blank_bar and bar(game) is None
		elif path:
			break
		game.wait(1)
	assert len(path) >= 8, path
	ys, xs = [p[0] for p in path], [p[1] for p in path]
	# OAM coordinates are 16 down and 8 right of the screen's; 8-bit, so above the top wraps
	screen_y = [(y - 16 + 128) % 256 - 128 for y in ys]
	assert xs == sorted(xs, reverse=True) and xs[0] > xs[-1], "moves left"
	assert screen_y == sorted(screen_y) and screen_y[0] < screen_y[-1], "moves down"
	assert xs[0] - 8 >= TABLE_WIDTH * 8 - 12 and screen_y[0] <= 8 + 8, \
		"starts at the sidebar's edge, at the top of the table"
	assert (screen_y[-1], xs[-1] - 8) == (PLAYER_ROW * 8, 8), "ends on its spot"
	assert blank_bar, "nothing to press while it slides"
	wait_until(game, lambda: game.peek("wBlackjackPlayerCount") >= 1 and all(
		y == 0 or y >= 160 for y, _, _, _ in oam(game)[:CORNER_OAM]), "the sprites going")
	assert tile_row(game, PLAYER_ROW)[1:5] == wanted[:3] + [FELT_CORNERS + 1], "drawn where it landed"


def test_the_hole_card_slides_in_face_down(game):
	start(game)
	rig(game, card(10), card(10), card(9), card(7))
	pick_up_to(game, 10)
	back = [BACK_TILES + i for i in range(24)]
	for _ in range(600):
		sprites = oam(game)[:24]
		if [t for _, _, t, _ in sprites] == back:
			assert all(a & 7 == BACK_PAL for _, _, _, a in sprites)
			return
		game.wait(1)
	raise AssertionError("the hole card never slid in face down")


def test_sliding_cards_use_recoloured_copies(game):
	start(game)
	count = FELT_TILES[0] - RANK_TILES # every card tile, up to the felt
	bg = vram_tiles(game, RANK_TILES, count)
	sprites = bytes(game.pyboy.memory[0, 0x8000 + i] for i in range(count * 16))
	expected = bytearray()
	for i in range(0, len(bg), 2):
		low, high = bg[i], bg[i + 1]
		expected += bytes([(~low | high) & 0xff, low])
	for tile, corner in sliding_corners():
		expected[tile * 16:tile * 16 + 16] = clear_corner(expected[tile * 16:tile * 16 + 16], corner)
	assert sprites == bytes(expected), \
		"white and grey to 1, the colour to 2, black stays 3, and the corners see-through"
	obj = bytes(game.peek("wOBPals1", 0, 8 * 8))
	deck = deck_palettes("french")
	for pal in list(range(4)) + [BACK_PAL]:
		src = deck[pal * 8:pal * 8 + 8] if pal < 4 else deck[4 * 8:5 * 8]
		white, colour, black = src[0:2], src[2:4], src[6:8]
		assert obj[pal * 8 + 2:pal * 8 + 8] == white + colour + black, pal


def sliding_corners():
	"""Each card corner tile (as an offset from the first card tile) and which corner it is."""
	back = BACK_TILES - RANK_TILES
	return ([(SUIT_TILES - RANK_TILES + s, "top_left") for s in range(4)]
		+ [(TOP_RIGHT, "top_right"), (BOTTOM_LEFT, "bottom_left"), (BOTTOM_RIGHT, "bottom_right"),
			(back, "top_left"), (back + 3, "top_right"), (back + 20, "bottom_left"),
			(back + 23, "bottom_right")])


# Card corners

def pixels(tile):
	"""A 2bpp tile's colours, row by row, left to right."""
	return [[(tile[r * 2] >> (7 - x) & 1) | (tile[r * 2 + 1] >> (7 - x) & 1) << 1 for x in range(8)]
		for r in range(8)]


def change_corner(tile, corner, how, edge_only=False):
	"""tile with each row changed by how(low, high, outside) -> (low, high)."""
	rows = CORNER_PIXELS[corner]
	if edge_only: # only the edge row's
		edge = 0 if corner.startswith("top") else 7
		rows = [m if r == edge else 0 for r, m in enumerate(rows)]
	out = bytearray(tile)
	for r, m in enumerate(rows):
		out[r * 2], out[r * 2 + 1] = how(out[r * 2], out[r * 2 + 1], m)
	return bytes(out)


def clear_corner(tile, corner):
	return change_corner(tile, corner, lambda low, high, m: (low & ~m & 0xff, high & ~m & 0xff))


def black_corner(tile, corner):
	return change_corner(tile, corner, lambda low, high, m: (low | m, high | m), edge_only=True)


def felt_corner(tile, corner, dealer):
	"""In the felt's palette: white to 2, grey to 3, outside to the side's green (dealer 0, yours 1)."""
	if dealer:
		return change_corner(tile, corner, lambda low, high, m: (high & ~m & 0xff, ~m & 0xff))
	return change_corner(tile, corner, lambda low, high, m: (high | m, ~m & 0xff))


def art_tile(path, index):
	data = path.read_bytes()
	return data[index * 16:index * 16 + 16]


CARD_PARTS = GFX / "card_parts.2bpp"


def test_the_card_art_has_the_corners_the_code_expects():
	"""The code changes the 3 pixels outside each rounded corner; they're the card's white (0),
	with the black outline (3) just inside them, and card_parts.png's corners only white and black."""
	tiles = [(art_tile(CARD_PARTS, t), c) for t, c in
		((TOP_RIGHT, "top_right"), (BOTTOM_LEFT, "bottom_left"), (BOTTOM_RIGHT, "bottom_right"))]
	for t, _ in tiles:
		assert {p for row in pixels(t) for p in row} == {0, 3}, "white and black only"
	for deck in ("french", "spaceworld"):
		tiles += [(art_tile(DECKS / deck / "suits.2bpp", s), "top_left") for s in range(4)]
		back = DECKS / deck / "back.2bpp"
		tiles += [(art_tile(back, 0), "top_left"), (art_tile(back, 3), "top_right"),
			(art_tile(back, 20), "bottom_left"), (art_tile(back, 23), "bottom_right")]
	for t, corner in tiles:
		px = pixels(t)
		for r, m in enumerate(CORNER_PIXELS[corner]):
			for x in range(8):
				if m >> (7 - x) & 1:
					assert px[r][x] == 0, (corner, r, x)
		edge = px[0] if corner.startswith("top") else px[7]
		inside = [x for x in range(8) if not CORNER_PIXELS[corner][0 if corner.startswith("top") else 7] >> (7 - x) & 1]
		assert all(edge[x] == 3 for x in inside), (corner, "the black outline runs along the edge")


@pytest.mark.parametrize("deck", ["french", "spaceworld"])
def test_backs_leave_colour_2_to_the_felt(deck):
	"""A back's colour 2 is the felt's green behind its corners (and a sliding card shows colour 2
	as white), so back.png has no dark grey: only its card (white), pattern (light grey) and black."""
	from PIL import Image
	im = Image.open(DECKS / deck / "back.png").convert("L")
	assert {v for _, v in im.getcolors()} <= {255, 170, 0}


def test_the_backs_corners_on_the_felt(game):
	"""The back's right corners are its own tiles in VRAM bank 1, the pixels outside the card in
	colour 2, which is the dealer's green."""
	start(game)
	back = DECKS / "french" / "back.2bpp"
	shown = bytes(game.pyboy.memory[1, 0x9000 + BACK_CORNERS * 16 + i] for i in range(32))
	colour_2 = lambda low, high, m: (low & ~m & 0xff, high | m)
	expected = change_corner(art_tile(back, 3), "top_right", colour_2) + \
		change_corner(art_tile(back, 23), "bottom_right", colour_2)
	assert shown == expected
	pals = bytes(game.peek("wBGPals1", 0, 8 * 8))
	assert pals[BACK_PAL * 8 + 4:BACK_PAL * 8 + 6] == pals[FELT_PAL * 8:FELT_PAL * 8 + 2], "the dealer's green"


def test_the_overlap_corners_carry_on_the_outline_behind(game):
	start(game)
	suits = DECKS / "french" / "suits.2bpp"
	back = DECKS / "french" / "back.2bpp"
	expected = b"".join([black_corner(art_tile(suits, s), "top_left") for s in range(4)]
		+ [black_corner(art_tile(back, 0), "top_left"),
			black_corner(art_tile(CARD_PARTS, BOTTOM_LEFT), "bottom_left"),
			black_corner(art_tile(back, 20), "bottom_left")])
	assert vram_tiles(game, OVERLAP_TILES, 7) == expected
	assert black_corner(bytes(16), "top_left")[:2] == bytes([0b11000000, 0b11000000]), "two black pixels on the edge row"


def test_the_felt_corners_show_each_sides_green(game):
	start(game)
	shown = bytes(game.pyboy.memory[1, 0x9000 + FELT_CORNERS * 16 + i] for i in range(6 * 16))
	expected = b""
	for dealer in (False, True):
		for t, corner in ((BOTTOM_LEFT, "bottom_left"), (TOP_RIGHT, "top_right"), (BOTTOM_RIGHT, "bottom_right")):
			expected += felt_corner(art_tile(CARD_PARTS, t), corner, dealer)
	assert shown == expected
	yours, dealers = pixels(shown[16:32]), pixels(shown[3 * 16 + 16:4 * 16 + 16])
	assert yours[0][6:] == [1, 1] and dealers[0][6:] == [0, 0], "outside: your green, the dealer's"
	assert yours[0][:6] == [3] * 6 and yours[1][0] == 2, "the outline black (3) and white (2)"


def test_the_felt_palette_has_the_cards_white_and_black(game):
	start(game)
	pals = bytes(game.peek("wBGPals1", 0, 8 * 8))
	deck = deck_palettes("french")
	felt = pals[FELT_PAL * 8:FELT_PAL * 8 + 8]
	assert felt[4:6] == deck[0:2] and felt[6:8] == deck[6:8], "colours 2 and 3: the cards' white and black"
	obj = bytes(game.peek("wOBPals1", 0, 8 * 8))
	assert obj[FELT_PAL * 8 + 2:FELT_PAL * 8 + 6] == felt[0:4], "the corner sprites: the felt's greens"


def test_card_corners_on_the_table(game):
	start(game)
	rig(game, card(2), card(10), card(3, ODDISH), card(7), card(4, JIGGLYPUFF))
	bet(game, 10)
	hit(game)
	wait_for_turn(game)
	tiles = [tile_row(game, r) for r in range(18)]
	attrs = [attr_row(game, r) for r in range(18)]
	top, bottom = PLAYER_ROW, PLAYER_ROW + 5
	# your first card: its suit in the corner, its bottom left on the felt
	assert (tiles[top][1], attrs[top][1]) == (SUIT_TILES + PIKACHU, PIKACHU)
	assert (tiles[bottom][1], attrs[bottom][1]) == (FELT_CORNERS, CORNER_ATTR)
	# the next two: left corners over the card behind
	for x, suit in ((3, ODDISH), (5, JIGGLYPUFF)):
		assert (tiles[top][x], attrs[top][x]) == (OVERLAP_TILES + suit, suit)
		assert (tiles[bottom][x], attrs[bottom][x]) == (OVERLAP_BOTTOM_LEFT, suit)
	# the last one's right corners on the felt; the others' are covered
	assert (tiles[top][8], attrs[top][8]) == (FELT_CORNERS + 1, CORNER_ATTR)
	assert (tiles[bottom][8], attrs[bottom][8]) == (FELT_CORNERS + 2, CORNER_ATTR)
	assert tiles[top][4] == tiles[top][6] == 0x0f and tiles[bottom][4] == 0x13
	# the dealer's: the first card's bottom left, the hole card's corners
	assert (tiles[6][1], attrs[6][1]) == (FELT_CORNERS + DEALER_CORNERS, CORNER_ATTR)
	assert tiles[1][3] == OVERLAP_BACK and tiles[6][3] == OVERLAP_BACK_BOTTOM_LEFT
	assert tiles[1][6] == BACK_CORNERS and tiles[6][6] == BACK_CORNERS + 1
	assert attrs[1][6] == attrs[6][6] == BACK_PAL | 8


def corner_sprites(game):
	return oam(game)[CORNER_OAM:CORNER_OAM + 2]


def test_the_first_cards_top_left_corners_are_sprites(game):
	start(game)
	shown = bytes(game.pyboy.memory[0, 0x8000 + CORNER_SPRITES * 16 + i] for i in range(32))
	assert pixels(shown[:16])[0][:2] == [1, 1] and pixels(shown[:16])[1][:2] == [1, 0], "the dealer's: colour 1"
	assert pixels(shown[16:])[0][:2] == [2, 2] and pixels(shown[16:])[1][:2] == [2, 0], "yours: colour 2"
	assert sum(p for row in pixels(shown[:16]) for p in row) == 3, "just the three pixels"
	assert all(y == 0 for y, _, _, _ in corner_sprites(game)), "none on an empty table"
	rig(game, card(10), card(10), card(9), card(7))
	bet(game, 10)
	wait_for_turn(game)
	dealer, yours = corner_sprites(game)
	assert dealer == (1 * 8 + 16, 1 * 8 + 8, CORNER_SPRITES, FELT_PAL)
	assert yours == (PLAYER_ROW * 8 + 16, 1 * 8 + 8, CORNER_SPRITES + 1, FELT_PAL)
	stand(game)
	result(game, "You win! +10")
	dealer, yours = corner_sprites(game)
	assert yours[0] == 0, "yours hides under the message box"
	assert dealer[0] == 1 * 8 + 16, "the dealer's stays"
	game.press("a")
	wait_for_bet(game)
	assert all(y == 0 for y, _, _, _ in corner_sprites(game)), "gone with the cards"


def test_each_deck_counts_its_back_colours(game):
	bank, address = game.pyboy.symbol_lookup("BlackjackDecks")
	for i, deck in enumerate(["french", "spaceworld"]):
		count = game.pyboy.memory[bank, address + i * 9 + 8]
		assert count == len(deck_palettes(deck)) // 8 - 4 >= 1, deck


# Each blackjack table: the dealer behind it, and the square in front of its top's middle, among
# its legs
BLACKJACK_TABLES = {
	"GOLDENROD_GAME_CORNER": {"dealer": (10, 1), "front": (10, 3)},
	"CELADON_GAME_CORNER": {"dealer": (12, 1), "front": (12, 3)},
}


def ask_the_dealer(game, warp=True, map_name="GOLDENROD_GAME_CORNER"):
	"""A on the middle of a blackjack table's front, and YES to the dealer, up to the title screen."""
	if warp:
		game.warp(map_name, *BLACKJACK_TABLES[map_name]["front"])
	game.press("up") # the middle of the table's top
	game.press("a")
	game.wait_for_text("Care for a game")
	game.wait(30)
	game.press("a", hold=4, after=30) # YES
	wait_for_title(game)


def test_the_goldenrod_dealer_starts_the_game(game):
	give_coin_case(game)
	set_coins(game, 100)
	ask_the_dealer(game)
	game.press("a", hold=4, after=10)
	wait_for_bet(game)
	assert in_the_game(game)


@pytest.mark.parametrize("map_name, spot, facing", [
	("GOLDENROD_GAME_CORNER", (14, 9), "left"),
	("GOLDENROD_GAME_CORNER", (17, 9), "right"),
	("CELADON_GAME_CORNER", (5, 7), "right"),
	("CELADON_GAME_CORNER", (2, 7), "left"),
])
def test_card_machines_play_card_flip(game, map_name, spot, facing):
	give_coin_case(game)
	set_coins(game, 100)
	open_machine(game, map_name, spot, facing)
	game.wait_for_text("Play with three")


def test_the_debug_radio_gives_the_coin_case_and_coins(game):
	give_coin_case(game, False)
	set_coins(game, 0)
	take_radio_items(game)
	assert game.peek("wKeyItemFlags") & 1 << COIN_CASE_FLAG
	assert coins(game) == 1000


def music_constants():
	text = (Path(__file__).resolve().parent.parent / "constants" / "music_constants.asm").read_text(
		encoding="utf-8")
	return {name: i for i, name in enumerate(re.findall(r"^\s*const (MUSIC_\w+)", text, re.M))}


def music(game):
	low, high = game.peek("wMusicID", 0, 2)
	return high << 8 | low


def test_ronalds_theme_plays_at_the_table(game):
	songs = music_constants()
	start(game)
	assert music(game) == songs["MUSIC_TCG_RONALD"]
	game.wait(10)
	game.press("b", hold=4, after=10)
	answer_leave(game, yes=True)
	assert left_the_game(game)
	assert music(game) == songs["MUSIC_GAME_CORNER"], "the Game Corner's music again"


def test_ronalds_theme_is_converted_from_poketcg():
	text = (Path(__file__).resolve().parent.parent / "audio" / "music" / "tcgronald.asm").read_text(
		encoding="utf-8")
	assert text.startswith("Music_TcgRonald:\n\tchannel_count 4\n")


# The title screen

TITLE_TILES = 24 + 17 # the felt pattern's 6x4 tiles, then a tile for each cell of text
TITLE_TEXT_TILES = 24
TITLE_LINES = {"start": (7, 10, 0, 6), "label": (8, 12, 6, 3), "deck": (6, 13, 9, 8)} # x, y, first cell, cells
# The logo: Meowth centred on top of the sign, its two frames taking turns; tiles from $80
TITLE_SIGN = (5, 6, 10, 2) # x, y, width, height
TITLE_MEOWTH = (8, 3, 4, 3)
TITLE_MEOWTH_FRAMES = 45 # how long each of Meowth's frames stays up
# logo.png: Meowth's two frames side by side, centred over the sign
LOGO_PNG_SIZE = (10, 5)
LOGO_MEOWTH_PNG_X = (1, 5) # each frame's first column
LOGO_SIGN_PNG_Y = 3
LOGO_BACKGROUND = bytes([0x00, 0xff] * 8) # a tile of plain dark grey, colour 2


@functools.cache
def logo_png_cells(left, top, width, height):
	"""A box of logo.png's tiles, row by row, each as 2bpp."""
	return tuple(tuple(png_tile("logo.png", (top + r) * LOGO_PNG_SIZE[0] + left + c) for c in range(width))
		for r in range(height))


def title_bg_cells(game, x, y, width, height):
	"""What a box of the logo's cells shows on screen, row by row: each cell's tile from the BG map
	in VRAM, as 2bpp from VRAM bank 0 ($80 on, the same in both of the title's tile sets)."""
	low, high = game.peek("hBGMapAddress", 0, 2)
	base = high << 8 | low
	rows = []
	for r in range(height):
		row = []
		for c in range(width):
			tile = game.pyboy.memory[0, base + (y + r) * 32 + x + c]
			assert tile >= 0x80, (x + c, y + r, tile)
			row.append(bytes(game.pyboy.memory[0, 0x8000 + tile * 16 + i] for i in range(16)))
		rows.append(tuple(row))
	return tuple(rows)


def title_meowth_on_screen(game):
	"""Which of logo.png's two Meowth frames is in Meowth's cells on screen, the whole frame."""
	_, _, w, h = TITLE_MEOWTH
	shown = title_bg_cells(game, *TITLE_MEOWTH)
	for frame, left in enumerate(LOGO_MEOWTH_PNG_X):
		if shown == logo_png_cells(left, 0, w, h):
			return frame
	raise AssertionError("Meowth's cells aren't one of logo.png's frames, whole")


def title_loops(game):
	"""How many frames the title screen has spent in its loop, counted by a hook. Each time, the
	moving tiles on screen and the felt's step are noted, between steps, in game.title_snapshot."""
	if not hasattr(game, "blackjack_titles"):
		game.blackjack_titles = [0]
		game.title_snapshot = None
		bank, address = game.pyboy.symbol_lookup("Blackjack_Title.loop")

		def hook(n):
			n[0] += 1
			shown = 0x8000 if game.pyboy.memory[0xff40] & 0x10 else 0x9000
			game.title_snapshot = (game.peek("wBlackjackTitleShift"),
				bytes(game.pyboy.memory[0, shown + i] for i in range(TITLE_TILES * 16)))
		game.pyboy.hook_register(bank, address, hook, game.blackjack_titles)
	return game.blackjack_titles[0]


def wait_for_title(game, timeout=600):
	count = title_loops(game)
	wait_until(game, lambda: title_loops(game) > count + 1, "the title screen", timeout)


def small_glyph(char):
	"""A small-font character's 8 rows, 4 bits each (bit 3 the leftmost pixel): "◀" is "▶" with its
	three columns the other way round."""
	if char == "◀":
		return [(row & 0b0100) | (row >> 2 & 0b0010) | (row << 2 & 0b1000) for row in small_glyph("▶")]
	return small_font_rows()[char]


def title_cells(text, x, cells):
	"""What the title draws for a line: each cell's 8 rows of letter pixels, then of shadow. The
	line is centred on the screen to the pixel, 4 pixels a character, its last gap left out."""
	width = cells * 8
	start = 80 - 2 * len(text) - x * 8
	ink = [[0] * width for _ in range(8)]
	for n, char in enumerate(text):
		for r, row in enumerate(small_glyph(char)):
			for px in range(4):
				if row & 8 >> px:
					ink[r][start + n * 4 + px] = 1
	shadow = [[0] * width for _ in range(8)]
	for r in range(1, 8):
		for px in range(1, width):
			shadow[r][px] = int(ink[r - 1][px - 1] and not ink[r][px])
	out = []
	for c in range(cells):
		rows = lambda bits: [sum(bits[r][c * 8 + px] << (7 - px) for px in range(8)) for r in range(8)]
		out.append((rows(ink), rows(shadow)))
	return out


def title_masks(game, line):
	"""Each cell of a line as the game drew it: its letter rows and shadow rows."""
	x, _, first, cells = TITLE_LINES[line]
	data = game.peek("wDecompressScratch", 0x480 + first * 16, cells * 16)
	return [(data[c * 16:c * 16 + 16:2], data[c * 16 + 1:c * 16 + 16:2]) for c in range(cells)]


def title_line(game, line):
	"""A line of the title's text: the text whose drawing, letters, shadow and place, is what the
	game drew."""
	x, _, _, cells = TITLE_LINES[line]
	masks = title_masks(game, line)
	chars = " ABCDEFGHIJKLMNOPQRSTUVWXYZ▶◀"
	for length in range(1, 15):
		start = 80 - 2 * length - x * 8
		if start < 0:
			break
		text = ""
		for n in range(length):
			px = start + n * 4
			rows = []
			for r in range(8):
				value = 0
				for b in range(4):
					p = px + b
					if p < cells * 8 and masks[p // 8][0][r] >> (7 - p % 8) & 1:
						value |= 8 >> b
				rows.append(value)
			found = [ch for ch in chars if small_glyph(ch) == rows]
			if not found:
				break
			text += found[0]
		else:
			if [tuple(map(list, cell)) for cell in title_cells(text, x, cells)] == \
					[tuple(map(list, cell)) for cell in masks]:
				return text
	raise AssertionError("the %s line isn't text the title draws" % line)


def title_deck(game):
	return game.peek("wBlackjackTitleDeck")


def to_the_title(game, start_coins=500):
	give_coin_case(game)
	set_coins(game, start_coins)
	launch(game)
	wait_for_title(game)


def tap(game, button):
	game.press(button, hold=4, after=10)


def felt_model(shift):
	"""The felt's 24 pattern tiles moved `shift` pixels left and down, from felt.png's tiles."""
	felt = (GFX / "felt.2bpp").read_bytes()

	def pixels(tile):
		data = felt[tile * 16:tile * 16 + 16]
		return [[(data[r * 2] >> (7 - x) & 1) | (data[r * 2 + 1] >> (7 - x) & 1) << 1
			for x in range(8)] for r in range(8)]
	texture = [[0] * 48 for _ in range(32)]
	for ty in range(4):
		paw = (1, 4)[ty // 2] # the table's bands: paws at columns 1, 7, 13 and 4, 10
		for tx in range(6):
			tile = (ty % 2) * FELT_PNG_WIDTH + tx - paw if tx in (paw, paw + 1) else 2
			for r, row in enumerate(pixels(tile)):
				texture[ty * 8 + r][tx * 8:tx * 8 + 8] = row
	tiles = []
	for ty in range(4):
		for tx in range(6):
			tiles.append([[texture[(ty * 8 + r - shift) % 32][(tx * 8 + x + shift) % 48]
				for x in range(8)] for r in range(8)])
	return tiles


def to_2bpp(tile):
	out = bytearray()
	for row in tile:
		out.append(sum((c & 1) << (7 - x) for x, c in enumerate(row)))
		out.append(sum((c >> 1) << (7 - x) for x, c in enumerate(row)))
	return bytes(out)


def deck_line_shown(game):
	"""Whether the title shows the DECK label and the deck's line: both or neither."""
	shown = []
	for line in ("label", "deck"):
		x, y, first, cells = TITLE_LINES[line]
		shown.append(tile_row(game, y)[x:x + cells] == [TITLE_TEXT_TILES + first + c for c in range(cells)])
	assert shown[0] == shown[1], shown
	return shown[0]


def test_the_title_screen_comes_first(game):
	to_the_title(game)
	assert not in_the_game(game)
	assert title_line(game, "start") == "PUSH START"
	assert not deck_line_shown(game), "no deck to pick with one deck"
	assert title_deck(game) == 0


@pytest.mark.parametrize("decks", [1, 2])
def test_the_title_screen_layout(game, decks):
	"""The logo (Meowth on top of the sign), START, and with more than one deck the DECK label and
	the deck's line; the felt everywhere else, beside Meowth too."""
	if decks == 2:
		game.set_event_flag("EVENT_BLACKJACK_SPACEWORLD_DECK")
	to_the_title(game)
	tiles = [tile_row(game, r) for r in range(18)]
	attrs = [attr_row(game, r) for r in range(18)]
	for x, y, w, h in (TITLE_SIGN, TITLE_MEOWTH):
		assert all(t >= 0x80 for row in box(tiles, x, y, x + w - 1, y + h - 1) for t in row)
		assert box(attrs, x, y, x + w - 1, y + h - 1) == [[1] * w for _ in range(h)], "the logo's palette"
	x, y, w, h = TITLE_SIGN
	assert title_bg_cells(game, *TITLE_SIGN) == logo_png_cells(0, LOGO_SIGN_PNG_Y, w, h), "the sign"
	assert title_meowth_on_screen(game) in (0, 1)
	lines = {line: TITLE_LINES[line] for line in (("start", "label", "deck") if decks == 2 else ("start",))}
	for line, (x, y, first, cells) in lines.items():
		assert tiles[y][x:x + cells] == [TITLE_TEXT_TILES + first + c for c in range(cells)], line
	for y in range(18):
		for x in range(20):
			in_logo = any(lx <= x < lx + lw and ly <= y < ly + lh for lx, ly, lw, lh in (TITLE_SIGN, TITLE_MEOWTH))
			in_text = any(ty == y and tx <= x < tx + cells for tx, ty, _, cells in lines.values())
			if not in_logo and not in_text:
				assert tiles[y][x] == (y % 4) * 6 + x % 6, (x, y)
				assert attrs[y][x] == 0, (x, y)
	logo = (GFX / "logo.2bpp").read_bytes()
	assert logo[:16] == LOGO_BACKGROUND, "logo.2bpp's tile 0, left out, is the background"
	assert bytes(game.pyboy.memory[0, 0x8800 + i] for i in range(len(logo) - 16)) == logo[16:]


def test_the_logo_keeps_only_the_tiles_it_needs(game):
	"""logo.png is Meowth's two frames over the sign, with plain background only in the corners
	beside the frames; VRAM gets each different tile of the art once, and no plain background."""
	width, height = LOGO_PNG_SIZE
	frames_left, frames_right = LOGO_MEOWTH_PNG_X[0], LOGO_MEOWTH_PNG_X[-1] + TITLE_MEOWTH[2]
	art = set()
	for r in range(height):
		for c in range(width):
			tile = png_tile("logo.png", r * width + c)
			if r < LOGO_SIGN_PNG_Y and not frames_left <= c < frames_right:
				assert tile == LOGO_BACKGROUND, ("beside the frames", c, r)
			else:
				assert tile != LOGO_BACKGROUND, ("art", c, r)
				art.add(tile)
	to_the_title(game)
	count = len((GFX / "logo.2bpp").read_bytes()) // 16 - 1
	loaded = [bytes(game.pyboy.memory[0, 0x8800 + t * 16 + i] for i in range(16)) for t in range(count)]
	assert len(set(loaded)) == count and set(loaded) == art


def test_the_logos_meowth_takes_turns(game):
	"""Meowth sits centred on top of the sign, the logo centred on the screen, and logo.png's two
	frames take turns there, a whole frame at a time, every TITLE_MEOWTH_FRAMES frames."""
	x, y, w, h = TITLE_MEOWTH
	sx, sy, sw, sh = TITLE_SIGN
	assert y + h == sy and (x - sx) * 2 + w == sw and sx * 2 + sw == 20
	assert sy + sh <= TITLE_LINES["start"][1], "above START"
	to_the_title(game)
	seen = []
	for _ in range(TITLE_MEOWTH_FRAMES * 6):
		seen.append(title_meowth_on_screen(game))
		game.wait(1)
	changes = [i for i in range(1, len(seen)) if seen[i] != seen[i - 1]]
	assert len(changes) >= 5, seen
	assert all(b - a == TITLE_MEOWTH_FRAMES for a, b in zip(changes, changes[1:])), changes
	assert set(seen) == {0, 1}


def test_the_logos_corners_are_covered_in_felt_green(game):
	"""Meowth's box has a card's top corners, drawn in the box's background colour; two sprites
	cover them in the felt's plain green, the right one the left one flipped."""
	x, y, w, h = TITLE_MEOWTH
	corner = TITLE_TILES # the sprites' tile, after the felt's copy in vTiles0
	to_the_title(game)
	oam = [game.pyboy.memory[0xfe00 + i] for i in range(8)]
	assert oam[:4] == [y * 8 + 16, x * 8 + 8, corner, 4]
	assert oam[4:] == [y * 8 + 16, (x + w - 1) * 8 + 8, corner, 4 | 0x20], "flipped"
	tile = bytes(game.pyboy.memory[0, 0x8000 + corner * 16 + i] for i in range(16))
	mask = [0b11000000, 0b10000000] + [0] * 6
	assert tile[1::2] == bytes(mask) and not any(tile[0::2]), "those pixels in colour 2"
	for left in LOGO_MEOWTH_PNG_X:
		for c, flip in ((0, False), (w - 1, True)):
			png = logo_png_cells(left + c, 0, 1, 1)[0][0]
			background = [png[2 * r + 1] & ~png[2 * r] & 0xff for r in range(8)]
			want = [int("{:08b}".format(m)[::-1], 2) for m in mask] if flip else mask
			assert [b & (0xc0 if not flip else 0x03) for b in background[:2]] + [0] * 6 == want, (left, c)
	plain = felt_plain_colour(game)
	felt = bytes(game.peek("wBGPals1", plain * 2, 2))
	assert bytes(game.peek("wOBPals1", 4 * 8 + 4, 2)) == felt, "colour 2 is the felt's plain green"


def felt_plain_colour(game):
	"""The colour most of the title's felt tiles are: its plain green, the paws being the other."""
	counts = [0] * 4
	for t in range(24):
		data = [game.pyboy.memory[0, 0x9000 + t * 16 + i] for i in range(16)]
		for r in range(8):
			for b in range(8):
				counts[(data[2 * r] >> b & 1) | (data[2 * r + 1] >> b & 1) << 1] += 1
	return counts.index(max(counts))


def test_the_title_screen_palettes(game):
	to_the_title(game)
	pals = bytes(game.peek("wBGPals1", 0, 16))
	text = (GFX / "blackjack.pal").read_text(encoding="utf-8")
	colours = []
	for r, g, b in re.findall(r"RGB\s+(\d+),\s*(\d+),\s*(\d+)", text):
		word = int(r) | int(g) << 5 | int(b) << 10
		colours.append(bytes([word & 0xff, word >> 8]))
	assert pals[:4] == colours[0] + colours[1], "your side's greens"
	assert pals[4:8] == bytes([0xff, 0x7f, 0, 0]), "white for the text, then black"
	assert pals[8:16] == b"".join(colours[8:12]), "the logo in the sidebar's palette"


def test_left_and_right_do_nothing_with_one_deck(game):
	to_the_title(game)
	for button in ("right", "left"):
		tap(game, button)
		assert title_deck(game) == 0
		assert not deck_line_shown(game)


def test_left_and_right_pick_an_unlocked_deck(game):
	game.set_event_flag("EVENT_BLACKJACK_SPACEWORLD_DECK")
	to_the_title(game)
	assert deck_line_shown(game)
	assert title_line(game, "label") == "DECK"
	assert title_line(game, "deck") == "◀ DEFAULT ▶", "the arrows next to the name"
	tap(game, "right")
	assert title_deck(game) == 1
	assert title_line(game, "deck") == "◀ SPACEWORLD ▶"
	tap(game, "right")
	assert title_deck(game) == 0, "round past the last"
	tap(game, "left")
	assert title_deck(game) == 1, "round past the first"
	tap(game, "left")
	assert title_deck(game) == 0


def test_a_plays_the_deck_shown(game):
	game.set_event_flag("EVENT_BLACKJACK_SPACEWORLD_DECK")
	to_the_title(game)
	tap(game, "right")
	tap(game, "a")
	wait_for_bet(game)
	assert in_the_game(game)
	for name, first, count in (("suits", SUIT_TILES, 4), ("pictures", PICTURE_TILES, 48),
			("back", BACK_TILES, 24)):
		built = (DECKS / "spaceworld" / (name + ".2bpp")).read_bytes()
		assert vram_tiles(game, first, count) == built, name
	pals = bytes(game.peek("wBGPals1", 0, 8 * 8))
	expected = deck_palettes("spaceworld")
	assert pals[:4 * 8] == expected[:4 * 8], "the suits' palettes"
	assert pals[BACK_PAL * 8:BACK_PAL * 8 + 8] == expected[4 * 8:4 * 8 + 8], "the back's palette"
	assert game.pyboy.memory[0xff40] & 0x10 == 0, "the table's tiles in vTiles2"


def test_start_plays_too(game):
	to_the_title(game)
	tap(game, "start")
	wait_for_bet(game)
	assert in_the_game(game)


def test_b_on_the_title_goes_back_to_the_map(game):
	to_the_title(game)
	tap(game, "b")
	assert left_the_game(game)
	assert coins(game) == 500
	assert game.pyboy.memory[0xff40] & 0x10 == 0, "vTiles2 for the map again"
	font = (Path(__file__).resolve().parent.parent / "gfx" / "font" / "font.1bpp").read_bytes()
	tile_a = bytes(game.pyboy.memory[0, 0x8800 + i] for i in range(16))
	assert tile_a == bytes(b for row in font[:8] for b in (row, row)), "the font is back"


def test_the_deck_is_remembered(game):
	game.set_event_flag("EVENT_BLACKJACK_SPACEWORLD_DECK")
	give_coin_case(game)
	set_coins(game, 500)
	ask_the_dealer(game)
	tap(game, "right")
	tap(game, "a")
	wait_for_bet(game)
	assert game.event_flag("EVENT_BLACKJACK_DECK_BIT_0")
	assert not game.event_flag("EVENT_BLACKJACK_DECK_BIT_1")
	game.wait(10)
	game.press("b", hold=4, after=10)
	answer_leave(game, yes=True)
	assert left_the_game(game)
	ask_the_dealer(game, warp=False)
	assert title_deck(game) == 1
	assert title_line(game, "deck") == "◀ SPACEWORLD ▶"


def test_a_locked_deck_isnt_remembered(game):
	game.set_event_flag("EVENT_BLACKJACK_DECK_BIT_0") # SPACEWORLD, still locked
	to_the_title(game)
	assert title_deck(game) == 0
	assert not deck_line_shown(game)


def test_a_deck_past_the_last_isnt_remembered(game):
	game.set_event_flag("EVENT_BLACKJACK_SPACEWORLD_DECK")
	game.set_event_flag("EVENT_BLACKJACK_DECK_BIT_0")
	game.set_event_flag("EVENT_BLACKJACK_DECK_BIT_1") # deck 3
	to_the_title(game)
	assert title_deck(game) == 0


def test_picking_default_clears_the_remembered_deck(game):
	game.set_event_flag("EVENT_BLACKJACK_SPACEWORLD_DECK")
	game.set_event_flag("EVENT_BLACKJACK_DECK_BIT_0")
	to_the_title(game)
	assert title_deck(game) == 1
	tap(game, "left")
	tap(game, "a")
	wait_for_bet(game)
	assert not game.event_flag("EVENT_BLACKJACK_DECK_BIT_0")
	assert not game.event_flag("EVENT_BLACKJACK_DECK_BIT_1")


def test_the_felt_moves_left_and_down_every_two_frames(game):
	to_the_title(game)
	game.wait(4)
	first, _ = game.title_snapshot
	game.wait(40)
	shift, tiles = game.title_snapshot
	assert (shift - first) % 32 in (19, 20, 21), "a step every 2 frames"
	model = felt_model(shift)
	for t in range(24):
		assert tiles[t * 16:t * 16 + 16] == to_2bpp(model[t]), "felt tile %d" % t


def test_the_text_is_white_over_the_moving_felt(game):
	"""Each cell of text is the felt tile under it, with the letters in white (colour 2) and their
	shadow, a pixel down and right, in black (colour 3)."""
	game.set_event_flag("EVENT_BLACKJACK_SPACEWORLD_DECK")
	to_the_title(game)
	game.wait(23)
	shift, tiles = game.title_snapshot
	model = felt_model(shift)
	for line, (x, y, first, cells) in TITLE_LINES.items():
		drawn = title_cells(title_line(game, line), x, cells)
		for c in range(cells):
			under = [row[:] for row in model[(y % 4) * 6 + (x + c) % 6]]
			ink, shadow = drawn[c]
			for r in range(8):
				for px in range(8):
					if shadow[r] >> (7 - px) & 1:
						under[r][px] = 3
					if ink[r] >> (7 - px) & 1:
						under[r][px] = 2
			tile = TITLE_TEXT_TILES + first + c
			assert tiles[tile * 16:tile * 16 + 16] == to_2bpp(under), (line, c)


def test_the_title_text_is_the_small_font_with_a_shadow(game):
	game.set_event_flag("EVENT_BLACKJACK_SPACEWORLD_DECK")
	to_the_title(game)
	tap(game, "right")
	masks = title_masks(game, "deck")
	x, _, _, cells = TITLE_LINES["deck"]
	assert [tuple(map(list, cell)) for cell in masks] == \
		[tuple(map(list, cell)) for cell in title_cells("◀ SPACEWORLD ▶", x, cells)]
	assert any(any(shadow) for _, shadow in masks), "a shadow"
	assert small_glyph("◀")[1:6] == [0b0010, 0b0110, 0b1110, 0b0110, 0b0010]


def test_ronalds_theme_plays_on_the_title(game):
	to_the_title(game)
	game.wait(10)
	assert music(game) == music_constants()["MUSIC_TCG_RONALD"]


# The janitor stands at (9, 1), his trash can at (8, 1) beside him
BELOW_JANITOR = (9, 2)
BELOW_TRASH_CAN = (8, 2)


def test_the_celadon_janitor_gives_the_spaceworld_deck(game):
	"""The janitor beside the trash can in Celadon Game Corner gives the SPACEWORLD deck once; the
	title then has two decks to pick from."""
	assert not game.event_flag("EVENT_BLACKJACK_SPACEWORLD_DECK")
	game.warp("CELADON_GAME_CORNER", *BELOW_JANITOR)
	game.press("up") # he stands right of his trash can
	game.press("a")
	game.wait_for_text("janitor")
	for _ in range(30):
		if "received" in game.screen_text():
			break
		game.press("a", hold=4, after=30)
	else:
		raise AssertionError("no deck given. The screen:\n%s" % game.screen_text())
	game.wait_for_text("SPACEWORLD")
	for _ in range(30):
		if game.event_flag("EVENT_BLACKJACK_SPACEWORLD_DECK"):
			break
		game.wait(10)
	else:
		raise AssertionError("the deck's flag never set")
	game.press("a", hold=4, after=60)
	game.press("a")
	game.wait_for_text("the only")
	assert "received" not in game.screen_text(), "only once"
	for _ in range(10):
		if "prototype" in game.screen_text():
			break
		game.wait(30)
		game.press("a", hold=4, after=30)
	game.wait_for_text("prototype")
	game.press("a", hold=4, after=60)
	give_coin_case(game)
	set_coins(game, 100)
	ask_the_dealer(game)
	assert deck_line_shown(game)


def test_the_celadon_janitors_trash_can(game):
	game.warp("CELADON_GAME_CORNER", *BELOW_TRASH_CAN)
	game.press("up")
	game.press("a")
	game.wait_for_text("nothing in")


def test_the_celadon_cafe_trash_can_is_where_it_was(game):
	"""The Game Corner's trash can, on its block's left, is a block of its own: the Cafe's block, on
	the right, is as it was, the Leftovers in it where its event is."""
	game.warp("CELADON_CAFE", 7, 2)
	game.press("up")
	game.press("a")
	game.wait_for_text("found")
	game.wait_for_text("LEFTOVERS")


def test_the_celadon_game_corners_left_poster_reads(game):
	game.warp("CELADON_GAME_CORNER", 11, 1)
	game.press("up")
	game.press("a")
	game.wait_for_text("Hey!")


@pytest.mark.parametrize("map_name", list(BLACKJACK_TABLES))
def test_each_table_starts_blackjack(game, map_name):
	give_coin_case(game)
	set_coins(game, 100)
	ask_the_dealer(game, map_name=map_name)
	assert not in_the_game(game), "the title screen"


@pytest.mark.parametrize("map_name", list(BLACKJACK_TABLES))
@pytest.mark.parametrize("side", [-1, 1])
def test_the_dealer_from_the_side_sends_you_to_the_front(game, map_name, side):
	x, y = BLACKJACK_TABLES[map_name]["dealer"]
	game.warp(map_name, x + side, y)
	game.press("left" if side > 0 else "right")
	game.press("a")
	game.wait_for_text("like to") # the screen reads "'d" as a space
	for _ in range(6):
		if "table." in game.screen_text():
			break
		game.wait(30)
		game.press("a", hold=4, after=30)
	game.wait_for_text("table.")
	assert "Care for a game" not in game.screen_text()


@pytest.mark.parametrize("map_name", list(BLACKJACK_TABLES))
def test_the_tables_are_solid(game, map_name):
	"""The table's top, three squares across, stops the player; its legs' row is walkable."""
	fx, fy = BLACKJACK_TABLES[map_name]["front"]
	for x in (fx - 1, fx, fx + 1):
		game.warp(map_name, x, fy)
		game.press("up")
		game.press("up")
		game.wait(20)
		assert game.position() == (x, fy), (map_name, x)


def pal_lines(path):
	"""Each line of a .pal file with RGB on it, as its 4 colours in the game's 2-byte form."""
	lines = []
	for line in Path(path).read_text(encoding="utf-8").splitlines():
		if "RGB" not in line:
			continue
		values = [int(v) for v in re.findall(r"\d+", line.split(";")[0])]
		lines.append(b"".join(bytes([(r | g << 5 | b << 10) & 0xff, (r | g << 5 | b << 10) >> 8])
			for r, g, b in zip(values[0::3], values[1::3], values[2::3])))
	return lines


@pytest.mark.parametrize("map_name", list(BLACKJACK_TABLES))
def test_the_tables_felt_takes_the_water_slot(game, map_name):
	"""The felt's palette is green with gray's white, in the water slot, and it stays put."""
	game.warp(map_name, *BLACKJACK_TABLES[map_name]["front"])
	pals = bytes(game.peek("wBGPals1", 0, 8 * 8))
	gray, green, water = pals[0:8], pals[2 * 8:3 * 8], pals[3 * 8:4 * 8]
	assert water == gray[0:2] + green[2:8], "green, with gray's white"
	table = pal_lines(Path(__file__).resolve().parent.parent / "gfx" / "tilesets" / "game_corner_table.pal")
	assert water in table, "a line of game_corner_table.pal"
	game.wait(120)
	assert bytes(game.peek("wBGPals1", 3 * 8, 8)) == water, "not animated"


def test_other_game_corner_tileset_maps_keep_their_water(game):
	game.warp("VERMILION_GYM", 5, 16)
	table = pal_lines(Path(__file__).resolve().parent.parent / "gfx" / "tilesets" / "game_corner_table.pal")
	assert bytes(game.peek("wBGPals1", 3 * 8, 8)) not in table


def test_goldenrods_old_drink_is_gone(game):
	game.warp("GOLDENROD_GAME_CORNER", 13, 1)
	game.press("left")
	game.press("a")
	game.wait(60)
	assert "drink" not in game.screen_text()


