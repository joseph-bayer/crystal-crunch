"""The Battle Tower's reward is the vitamin the receptionist chose, however long it waits.

The receptionist chooses the reward as the challenge starts, and hands it over after the seventh
win, possibly sessions later. It used to be saved as an 8-bit item ID, which the item ID collector
didn't count as in use, so a save after a few newer IDs had been claimed freed it: the reward came
out as an emptied slot (a crash) or whatever item reused it."""

import pytest

from harness import alt_shiny as A
from test_mystery_gift import claim_item_ids, item_index, item_index_of_id, sram, set_sram, CHURN
from test_registered_item import save_game

VITAMINS = ["HP_UP", "PROTEIN", "IRON", "CARBOS"] # the four the tower chooses from, in order
BATTLETOWER_WON_CHALLENGE = 3
RECEPTIONIST_SPOT = ("BATTLE_TOWER_1F", 7, 7) # below the receptionist
REWARD_SAVED = 0xf0 # the saved reward: this, plus which of the four


def bag_items(game):
	count = game.peek("wNumItems")
	raw = game.peek("wItems", 0, count * 3) if count else []
	return {raw[i] << 8 | raw[i + 1]: raw[i + 2] for i in range(0, len(raw), 3)}


def chosen_vitamin(game):
	"""The vitamin the saved reward names right now: by its place in the four, or, as older
	builds saved it, by its 8-bit ID."""
	saved = sram(game, "sBattleTowerReward")
	if saved >= REWARD_SAVED:
		return item_index(VITAMINS[saved - REWARD_SAVED])
	return item_index_of_id(game, saved)


def choose_reward(game):
	"""Run the receptionist's choice, then carry the saved reward and the ID table it may have
	claimed from back into the paused game."""
	paused = game.save_state()
	A.call(game, "BattleTower_RandomlyChooseReward")
	saved = sram(game, "sBattleTowerReward")
	bank, start = game.pyboy.symbol_lookup("wItemIndexTable")
	_, end = game.pyboy.symbol_lookup("wItemIndexTableEnd")
	table = [game.pyboy.memory[bank, address] for address in range(start, end)]
	game.load_state(paused)
	for offset, value in enumerate(table):
		game.pyboy.memory[bank, start + offset] = value
	set_sram(game, "sBattleTowerReward", saved)


def collect_reward(game, seen=None):
	"""With the challenge won, talk to the receptionist. Returns the screen if the game crashed;
	`seen`, a list, collects every screen of text on the way."""
	set_sram(game, "sBattleTowerChallengeState", BATTLETOWER_WON_CHALLENGE)
	game.warp(*RECEPTIONIST_SPOT)
	game.press("up", after=20)
	game.press("a", after=20)
	for presses in range(60):
		text = game.screen_text()
		if seen is not None:
			seen.append(text)
		if "Game Boy Color" in text:
			return text
		game.press("a", after=20)
		if presses > 5 and game.peek("wScriptRunning") == 0 and game.peek("wWindowStackSize") == 0:
			game.wait(120)
			return game.screen_text() if "Game Boy Color" in game.screen_text() else None
	raise AssertionError("the receptionist's script never finished:\n" + game.screen_text())


def test_reward_survives_a_save(game):
	choose_reward(game)
	reward = chosen_vitamin(game)
	assert reward in [item_index(name) for name in VITAMINS]
	claim_item_ids(game, CHURN)
	save_game(game) # runs the ID collector, as a save between battles does

	before = bag_items(game).get(reward, 0)
	crash = collect_reward(game)
	assert crash is None, "collecting the reward crashed:\n" + crash
	assert bag_items(game).get(reward, 0) == before + 5


# A reward already waiting in a save from an older build holds an 8-bit item ID.

def stale_reward_id(game, stale):
	"""An older build's reward ID that no longer names a vitamin: a freed slot, or a reused one."""
	if stale == "empty":
		_, start = game.pyboy.symbol_lookup("wItemIndexTableEntries")
		_, end = game.pyboy.symbol_lookup("wItemIndexTableEntriesEnd")
		entries = game.peek("wItemIndexTableEntries", 0, end - start)
		return next(n for n in range(len(entries) // 2) if entries[2 * n] == entries[2 * n + 1] == 0) + 1
	return A.item_id(game, "POTION")


def test_old_save_reward_still_valid(game):
	"""An ID that still names one of the four is honored."""
	set_sram(game, "sBattleTowerReward", A.item_id(game, "PROTEIN"))
	before = bag_items(game).get(item_index("PROTEIN"), 0)
	assert collect_reward(game) is None
	assert bag_items(game).get(item_index("PROTEIN"), 0) == before + 5


# Different random sequences, so a reward that was rolled again rather than fixed would show.
SEEDS = [0x1234, 0x5678, 0x9abc]


@pytest.mark.parametrize("seed", SEEDS)
@pytest.mark.parametrize("stale", ["empty", "reused"])
def test_old_save_reward_lost(game, stale, seed):
	"""An ID that was freed (an empty slot) or reused by something else gives HP Up, whatever the
	random sequence, and nothing crashes."""
	set_sram(game, "sBattleTowerReward", stale_reward_id(game, stale))
	game.seed_random(seed)
	before = {name: bag_items(game).get(item_index(name), 0) for name in VITAMINS}
	crash = collect_reward(game)
	assert crash is None, "collecting the reward crashed:\n" + crash
	gained = {name: bag_items(game).get(item_index(name), 0) - before[name] for name in VITAMINS}
	assert gained == {"HP_UP": 5, "PROTEIN": 0, "IRON": 0, "CARBOS": 0}, gained


# A full pack: the receptionist keeps the reward, and the same one comes after making room.

MAX_ITEMS = 50


def fill_items_pocket(game):
	"""Fill the Items pocket with fifty different items, one each, none of them a vitamin."""
	vitamins = {item_index(name) for name in VITAMINS}
	indexes = [i for i in range(1, 0x80) if i not in vitamins][:MAX_ITEMS]
	for slot, index in enumerate(indexes):
		game.poke("wItems", index >> 8, slot * 3)
		game.poke("wItems", index & 0xff, slot * 3 + 1)
		game.poke("wItems", 1, slot * 3 + 2)
	game.poke("wItems", 0xff, MAX_ITEMS * 3)
	game.poke("wNumItems", MAX_ITEMS)


def make_room(game):
	game.poke("wNumItems", MAX_ITEMS - 1)
	game.poke("wItems", 0xff, (MAX_ITEMS - 1) * 3)


@pytest.mark.parametrize("saved, reward", [("current", "PROTEIN"), ("older build, lost", "HP_UP")])
def test_full_pack_keeps_the_reward(game, saved, reward):
	if saved == "current":
		set_sram(game, "sBattleTowerReward", REWARD_SAVED + VITAMINS.index("PROTEIN"))
	else:
		set_sram(game, "sBattleTowerReward", stale_reward_id(game, "reused"))
	fill_items_pocket(game)
	full_pack = bag_items(game)

	seen = []
	assert collect_reward(game, seen) is None
	assert any("stuffed full" in text for text in seen), "the receptionist didn't say the pack is full"
	assert bag_items(game) == full_pack, "the pack changed"
	assert sram(game, "sBattleTowerChallengeState") == BATTLETOWER_WON_CHALLENGE
	assert sram(game, "sBattleTowerReward") == REWARD_SAVED + VITAMINS.index(reward)

	make_room(game)
	assert collect_reward(game) is None
	assert bag_items(game).get(item_index(reward), 0) == 5
