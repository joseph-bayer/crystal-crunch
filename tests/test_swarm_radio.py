"""The Collection Guild's swarm report: on 6.0 in Johto and Kanto, two picks a day.

The day's pick is announced from midnight to EVE_HOUR (5 PM) and the evening's from then to
midnight. Each starts when heard and runs until midnight. Neither repeats a pick from the last two
days, the other pick of the day, or the other pick's map and terrain. Arnie's and Anthony's phone
swarms and both picks can all run at once.

The swarms are saved in SRAM blocks of their own (sSwarmState). A save from before them keeps its
swarms in wPlayerData's old bytes (wV1*), which loading brings across."""

import pytest

from harness import Game, constants
from harness.new_game import play_intro
from harness.alt_shiny import call, species_id
from harness.forms import press_until, wait_until
from harness.data import global_constants

from test_alt_shiny import swarm_ids, swarm_rows

C = global_constants().values
CARRY = 0x10
MAX_ACTIVE_SWARMS = C["MAX_ACTIVE_SWARMS"]
NUM_SWARM_PICKS = C["NUM_SWARM_PICKS"]
NUM_SWARM_HISTORY = C["NUM_SWARM_HISTORY"]
DAY, EVENING = C["SWARM_PICK_DAY"], C["SWARM_PICK_EVENING"]
EVE_HOUR = C["EVE_HOUR"]

POKEGEAR = 1 << 7 # POKEGEAR_OBTAINED_F, after a const_skip the constants reader doesn't follow
MAP_CARD = 1 << C["POKEGEAR_MAP_CARD_F"]
RADIO_CARD = 1 << C["POKEGEAR_RADIO_CARD_F"]
POKEGEARCARD_MAP = 1 # engine/pokegear/pokegear.asm
POKEGEARCARD_RADIO = 3

SWARM_STATION = "Guild Swarm News"
SEEDS = range(1, 301)

# Unlock every row that has a story gate, so the pool is as wide as it gets
STORY_FLAGS = ("EVENT_BEAT_ELITE_FOUR", "EVENT_CLEARED_ROCKET_HIDEOUT", "EVENT_CLEARED_RADIO_TOWER",
	"EVENT_MET_UNION_CAVE_LAPRAS")


def ids():
	return swarm_ids()


def places():
	"""{SWARM_* id: (map, water?)}"""
	return {i: (row[1], "SWARM_WATER" in row[2]) for i, row in enumerate(swarm_rows(), 1)}


def set_hour(game, hour):
	"""Move the clock to this hour of today, through the game's own start-hour offset."""
	call(game, "UpdateTime")
	now = game.peek("hHours")
	game.poke("wStartHour", (game.peek("wStartHour") + hour - now) % 24)
	call(game, "UpdateTime")
	assert game.peek("hHours") == hour


def swarm_state(game):
	active = game.peek("wActiveSwarms", 0, MAX_ACTIVE_SWARMS)
	picks = game.peek("wDailySwarms", 0, NUM_SWARM_PICKS)
	history = game.peek("wSwarmHistory", 0, NUM_SWARM_HISTORY)
	return active, picks, history


def set_swarm_state(game, active=(), picks=(), history=()):
	for symbol, values, length in (("wActiveSwarms", active, MAX_ACTIVE_SWARMS),
			("wDailySwarms", picks, NUM_SWARM_PICKS), ("wSwarmHistory", history, NUM_SWARM_HISTORY)):
		values = list(values) + [0] * (length - len(values))
		for i, value in enumerate(values):
			game.poke(symbol, value, i)


def broadcast(game):
	"""The top of the report's loop: which pick it chose, and whether it has a swarm to announce."""
	announced = bool(call(game, "DailySwarmBroadcast")["f"] & CARRY)
	return game.peek("wSwarmRadioPick"), announced


def unlock_every_row(game):
	for flag in STORY_FLAGS:
		game.set_event_flag(flag)


# The station

def radio_channels(game):
	"""{frequency: routine} from RadioChannels in the ROM."""
	bank, address = game.pyboy.symbol_lookup("RadioChannels")
	names = {}
	for line in game.rom.with_suffix(".sym").read_text(encoding="utf-8", errors="replace").splitlines():
		parts = line.split()
		if len(parts) == 2 and ":" in parts[0]:
			sym_bank, sym_address = (int(x, 16) for x in parts[0].split(":"))
			if sym_bank == bank:
				names.setdefault(sym_address, parts[1])
	channels = {}
	while True:
		knob = game.pyboy.memory[bank, address]
		if knob == 0xff:
			return channels
		pointer = game.pyboy.memory[bank, address + 1] | game.pyboy.memory[bank, address + 2] << 8
		channels[(knob + 2) / 4] = names.get(pointer, hex(pointer))
		address += 3


def test_the_station_is_on_6_0(game):
	channels = radio_channels(game)
	assert channels.get(6.0) == "LoadStation_SwarmRadio"
	assert 12.5 not in channels, "12.5 should be static now"
	assert list(channels) == sorted(channels), "RadioChannels should stay in frequency order"


def open_radio(game, flags=POKEGEAR | RADIO_CARD | MAP_CARD):
	game.poke("wPokegearFlags", flags)
	game.press("start", after=40)
	game.choose("GEAR")
	wait_until(game, lambda: "EXIT" not in game.screen_text(), "the Pokégear", timeout=300)
	for _ in range(4):
		game.press("right", after=60)
		if game.peek("wPokegearCard") == POKEGEARCARD_RADIO:
			break
	assert game.peek("wPokegearCard") == POKEGEARCARD_RADIO, "the radio never showed"


def tune(game, frequency):
	"""Turn the dial to a frequency: one step below it, then up once, so the station loads."""
	game.poke("wRadioTuningKnob", int(frequency * 4 - 2) - 2)
	game.press("up", hold=4, after=30)
	assert game.peek("wRadioTuningKnob") == int(frequency * 4 - 2)


@pytest.mark.parametrize("region", ["johto", "kanto"])
def test_tuning_6_0_announces_and_starts_the_swarm(game, region):
	"""On 6.0 in either region the report plays, rolls the day's pick and starts it on the line
	that names the place. 12.5 has nothing."""
	unlock_every_row(game)
	if region == "kanto":
		game.warp("VIRIDIAN_CITY", 10, 10)
	set_swarm_state(game)
	open_radio(game)
	tune(game, 12.5)
	game.wait(120)
	assert SWARM_STATION not in game.screen_text()
	assert game.peek("wDailySwarms", DAY) == 0
	tune(game, 6.0)
	wait_until(game, lambda: SWARM_STATION in game.screen_text(), "the station's name", timeout=120)
	pick = game.peek("wDailySwarms", DAY)
	assert pick, "tuning in should roll the day's pick"
	assert game.peek("wDailySwarms", EVENING) == 0, "10 AM is the day's"
	wait_until(game, lambda: pick in game.peek("wActiveSwarms", 0, MAX_ACTIVE_SWARMS),
		"the swarm to start", timeout=3000)


# The two picks

@pytest.mark.parametrize("hour, pick", [(0, DAY), (3, DAY), (4, DAY), (10, DAY), (EVE_HOUR - 1, DAY),
	(EVE_HOUR, EVENING), (20, EVENING), (23, EVENING)])
def test_the_clock_chooses_the_pick(game, hour, pick):
	unlock_every_row(game)
	set_swarm_state(game)
	set_hour(game, hour)
	chosen, announced = broadcast(game)
	assert chosen == pick
	assert announced
	picks = game.peek("wDailySwarms", 0, NUM_SWARM_PICKS)
	assert picks[pick], "the pick should be rolled"
	assert not picks[1 - pick], "the other pick waits for its own time"


def test_each_pick_is_rolled_once_and_kept(game):
	unlock_every_row(game)
	set_swarm_state(game)
	set_hour(game, 10)
	broadcast(game)
	day = game.peek("wDailySwarms", DAY)
	set_hour(game, 18)
	broadcast(game)
	evening = game.peek("wDailySwarms", EVENING)
	assert evening and evening != day
	set_hour(game, 2) # night, but the day's pick
	assert broadcast(game) == (DAY, True)
	set_hour(game, 22)
	assert broadcast(game) == (EVENING, True)
	assert game.peek("wDailySwarms", 0, NUM_SWARM_PICKS) == [day, evening], "a pick stays until midnight"


def picks_over_seeds(game, history=(), other=0):
	"""The day's pick for each seed, with this history and this evening pick."""
	set_hour(game, 10)
	picked = []
	for seed in SEEDS:
		set_swarm_state(game, picks=[0, other], history=history)
		game.seed_random(seed)
		_, announced = broadcast(game)
		assert announced
		picked.append(game.peek("wDailySwarms", DAY))
	return picked


def test_a_pick_skips_the_last_two_days_and_the_other_pick(game):
	"""Without any exclusions, then with four picks of history and an evening pick that shares a
	map and terrain with another row: exactly those rows drop out of what gets picked."""
	unlock_every_row(game)
	every = set(picks_over_seeds(game))
	n = ids()
	history = [n["SWARM_GOLBAT_ROCKET"], n["SWARM_MAGIKARP_RB"], n["SWARM_GEODUDE_RB"], n["SWARM_STARYU_RB"]]
	other = n["SWARM_NIDORAN_M_RB"]
	same_place = n["SWARM_NIDORAN_F_RB"]
	assert places()[other] == places()[same_place]
	for row in history + [other, same_place]:
		assert row in every, "the test's rows should be on offer to begin with"
	picked = set(picks_over_seeds(game, history, other))
	assert picked == every - set(history) - {other, same_place}


@pytest.mark.parametrize("first, second", [("SWARM_GOLBAT_ROCKET", "SWARM_MARILL_ALT_SHINY"),
	("SWARM_MAGIKARP_RB", "SWARM_MAGIKARP_ALT_SHINY")])
def test_the_evening_skips_the_days_map_and_terrain(game, first, second):
	"""Rows sharing a map and terrain: once one is the day's pick, the evening never rolls the other,
	which StartSwarm would refuse."""
	unlock_every_row(game)
	n = ids()
	set_hour(game, 18)
	for seed in SEEDS:
		set_swarm_state(game, picks=[n[first], 0])
		game.seed_random(seed)
		broadcast(game)
		evening = game.peek("wDailySwarms", EVENING)
		assert evening not in (n[first], n[second]), "seed %d" % seed
		assert places()[evening] != places()[n[first]], "seed %d" % seed


def test_both_picks_and_both_phone_swarms_run_at_once(game):
	n = ids()
	day, evening = n["SWARM_MACHOP_RB"], n["SWARM_SHELLDER_RB"]
	set_swarm_state(game, active=[n["SWARM_DUNSPARCE"], n["SWARM_YANMA"]], picks=[day, evening])
	game.poke("wSwarmRadioPick", DAY)
	call(game, "StartDailySwarm")
	game.poke("wSwarmRadioPick", EVENING)
	call(game, "StartDailySwarm")
	active, _, _ = swarm_state(game)
	assert sorted(active) == sorted([n["SWARM_DUNSPARCE"], n["SWARM_YANMA"], day, evening])


def test_midnight_ends_the_swarms_and_remembers_both_picks(game):
	"""The real daily reset, from a timer stamped yesterday."""
	set_swarm_state(game, active=[1, 2, 3, 4], picks=[5, 6], history=[7, 8, 9, 10])
	call(game, "UpdateTime")
	game.poke("wDailyResetTimer", 1)
	game.poke("wDailyResetTimer", (game.peek("wCurDay") - 1) % 140, 1)
	call(game, "CheckDailyResetTimer")
	active, picks, history = swarm_state(game)
	assert active == [0] * MAX_ACTIVE_SWARMS
	assert picks == [0] * NUM_SWARM_PICKS
	assert history == [5, 6, 7, 8], "today's two picks first, then yesterday's"


def test_the_map_shows_four_swarms_and_both_beasts(game):
	"""Four swarms and Raikou and Entei, all in Johto: the Pokégear map draws all six mon icons, in
	their own slots, beside the player's."""
	n = ids()
	set_swarm_state(game, active=[n["SWARM_DUNSPARCE"], n["SWARM_YANMA"], n["SWARM_MACHOP_RB"], n["SWARM_SHELLDER_RB"]])
	for roamer, species, map_name in (("wRoamMon1", "RAIKOU", "ROUTE_30"), ("wRoamMon2", "ENTEI", "ROUTE_31")):
		group, number = constants.maps()[map_name]
		game.poke(roamer + "Species", species_id(game, species))
		game.poke(roamer + "MapGroup", group)
		game.poke(roamer + "MapNumber", number)
		game.poke(roamer + "Form", 0)
	game.poke("wPokegearFlags", POKEGEAR | MAP_CARD)
	game.press("start", after=40)
	game.choose("GEAR")
	wait_until(game, lambda: "EXIT" not in game.screen_text(), "the Pokégear", timeout=300)
	for _ in range(4):
		game.press("right", after=60)
		if game.peek("wPokegearCard") == POKEGEARCARD_MAP:
			break
	assert game.peek("wPokegearCard") == POKEGEARCARD_MAP, "the map never showed"
	game.wait(120)
	assert game.peek("wMapIconCount") == 1 + 6, "the player and six mon"
	structs = {tuple(game.peek("wMapIcons", i * 3, 2)) for i in range(7)}
	assert len(structs) == 7 and (0, 0) not in structs, "each icon has its own sprite"



# The place line

RADIO_LINE = 18 # tiles a line of the report holds
TEXT_END = 0x50 # "@"


def place_line(game):
	"""The place the report names, from wStringBuffer1, as it reads on the radio: a landmark's
	breakable space (<BSP>, a line break only on the Town Map) prints as a space."""
	charmap = constants.charmap()
	text = []
	for byte in game.peek("wStringBuffer1", 0, C["STRING_BUFFER_LENGTH"]):
		if byte == TEXT_END:
			return "".join(text)
		text.append(" " if charmap[byte] == "<BSP>" else charmap[byte])
	raise AssertionError("wStringBuffer1 has no end: %s" % text)


def expected_places():
	"""{SWARM_* id: the place the report should name}: the landmark, and the map's floor as the
	Pokédex names it, for every row the radio can pick."""
	from test_data_pokedex import floor_rows, landmark_names, map_landmarks
	landmarks, names, floors = map_landmarks(), landmark_names(), dict(floor_rows())
	result = {}
	for swarm_id, row in enumerate(swarm_rows(), 1):
		if swarm_id < C["FIRST_STUDIED_SWARM"]:
			continue # the phone's swarms, never announced
		name = names[landmarks[row[1]]].replace("<BSP>", " ")
		if row[1] in floors:
			name += " " + floors[row[1]]
		result[swarm_id] = name
	return result


def test_every_floor_a_swarm_is_on_has_its_name():
	"""A swarm on a map whose constant names a floor gets that floor in the report, which needs its
	row in the Pokédex's floor table."""
	from test_data_pokedex import FLOOR, floor_rows
	floors = dict(floor_rows())
	missing = [row[1] for row in swarm_rows() if FLOOR.findall(row[1]) and row[1] not in floors]
	assert not missing


def test_the_report_names_the_floor(game):
	"""For every row the radio can pick, the place line is the landmark plus the floor, and it fits
	the line with its "!"."""
	places = expected_places()
	assert places[ids()["SWARM_ZUBAT_RB"]] == "UNION CAVE 1F"
	assert places[ids()["SWARM_GASTLY_RB"]] == "SPROUT TOWER 2F"
	assert places[ids()["SWARM_MACHOP_RB"]] == "ROUTE 45", "a map with one floor names none"
	set_hour(game, 10)
	game.poke("wSwarmRadioPick", DAY)
	for swarm_id, place in places.items():
		set_swarm_state(game, picks=[swarm_id, 0])
		assert broadcast(game) == (DAY, True)
		assert place_line(game) == place, "swarm %d" % swarm_id
		assert len(place) + len("!") <= RADIO_LINE, place


# Saving and loading

STATE = dict(active=[1, 2, 21, 7], picks=[21, 7], history=[3, 4, 5, 6])


def test_the_swarms_save_and_load(game):
	for save, load in (("SaveSwarmState", "LoadSwarmState"), ("SaveBackupSwarmState", "LoadBackupSwarmState")):
		set_swarm_state(game, **STATE)
		call(game, save)
		call(game, "ClearSwarmState")
		assert swarm_state(game) == ([0] * 4, [0] * 2, [0] * 4)
		call(game, load)
		assert swarm_state(game) == (STATE["active"], STATE["picks"], STATE["history"]), load


@pytest.mark.parametrize("damage", ["magic", "checksum"])
def test_a_save_without_the_block_brings_its_old_swarms_across(game, damage):
	"""A save from before the block (no magic) or a damaged copy (bad checksum): its three active
	slots, its one pick as the day's and its two days of history come from wPlayerData's old bytes,
	which are zeroed after."""
	set_swarm_state(game, **STATE)
	call(game, "SaveSwarmState")
	symbol = "sSwarmStateMagic" if damage == "magic" else "sSwarmStateChecksum"
	bank, address = game.pyboy.symbol_lookup(symbol)
	call(game, "OpenSRAM", a=bank)
	game.pyboy.memory[bank, address] ^= 0xff
	call(game, "CloseSRAM")
	old = [11, 12, 13, 14, 15, 16] # three slots, the pick, two days of history
	for i, value in enumerate(old):
		game.poke("wV1ActiveSwarms", value, i)
	call(game, "LoadSwarmState")
	assert swarm_state(game) == ([11, 12, 13, 0], [14, 0], [15, 16, 0, 0])
	assert game.peek("wV1ActiveSwarms", 0, len(old)) == [0] * len(old), "the old bytes are spare now"


def start_new_game_over_swarms(rom):
	"""From power-on to the bedroom of a new game, with another game's swarms left in WRAM when NEW
	GAME is chosen, as a soft reset after continuing leaves them. Returns the game in the bedroom."""
	game = Game(rom)
	game.wait(400)
	press_until(game, lambda: "NEW GAME" in game.screen_text(), "the title menu")
	set_swarm_state(game, **STATE)
	play_intro(game)
	return game


def test_a_new_game_starts_with_no_swarms(rom):
	"""wSwarmState is past wGameDataEnd, which a new game's clearing stops at."""
	game = start_new_game_over_swarms(rom)
	try:
		assert swarm_state(game) == ([0] * 4, [0] * 2, [0] * 4)
	finally:
		game.close()


@pytest.mark.parametrize("name", ["v1.0_cherrygrove.sav", "1.1_cherrygrove.sav"])
def test_a_v1_save_keeps_its_swarms(name):
	"""Both Cherrygrove saves were made with Dunsparce's and Yanma's swarms running."""
	from test_old_saves import continue_game, load

	game, data = load(name)
	try:
		continue_game(game)
		n = ids()
		active, picks, history = swarm_state(game)
		assert active == [n["SWARM_DUNSPARCE"], n["SWARM_YANMA"], 0, 0]
		assert picks == [0, 0] and history == [0] * 4
	finally:
		game.close()
