"""The MOPED: a key item used like the BICYCLE, with the bike's rules and its own music, that builds up from a
stop to the bike's 4 frames a tile, and to 2 while B is held (walking's 16). It plays its walk cycle while moving and, slower,
while standing, like an idling engine. Owning it puts you on it on the Cycling Road."""

import pytest

from harness import constants
from harness import alt_shiny as A
from harness import followers as F
from test_registered_item import key_item_index, register
from test_overworld_mons import pin_wanderer

PLAYER_NORMAL = 0
PLAYER_BIKE = 1
PLAYER_MOPED = 3
RIDING = {"BICYCLE": PLAYER_BIKE, "MOPED": PLAYER_MOPED}
RIDE_MUSIC = {"BICYCLE": "MUSIC_BICYCLE", "MOPED": "MUSIC_PUZZLE_TOTODILE"}

FEMALE = 1 << 0 # PLAYERGENDER_FEMALE_F

# Route 30, south of Youngster Joey: riding up stops at (4, 26) whatever the speed.
ROUTE_30 = ("ROUTE_30", 4, 33)
ROUTE_30_WALL = (4, 26)
# Route 29's east end: riding right crosses the connection into New Bark Town.
ROUTE_29 = ("ROUTE_29", 50, 8)
# Route 29, north of a ledge: riding down hops it.
ROUTE_29_ABOVE_LEDGE = ("ROUTE_29", 26, 8)
# The house on Route 30, an indoor map, entered from ROUTE_30 by its door.
BERRY_HOUSE = ("ROUTE_30_BERRY_HOUSE", 2, 7)


OBJECT_WALKING = 0x07
OBJECT_STEP_DURATION = 0x0a
OBJECT_FACING = 0x0d
STANDING = 0xff


def const(path, name):
	return constants._consts(constants.ROOT / path)[name]


def music(name):
	return const("constants/music_constants.asm", name)


def sprite(name):
	return F.sprites()[name]


def has_key_item(game, name):
	bit = key_item_index(name) & 0xff
	return bool(game.peek("wKeyItemFlags", bit // 8) & 1 << bit % 8)


def give_key_items(game, *names):
	"""The key items' flags, and the pocket's list as RefreshKeyItemsList would rebuild it (low
	bytes of the indexes, ended by -1) for a bag holding just these."""
	for i, name in enumerate(names):
		bit = key_item_index(name) & 0xff
		game.poke("wKeyItemFlags", game.peek("wKeyItemFlags", bit // 8) | 1 << bit % 8, bit // 8)
		game.poke("wKeyItems", bit, i)
	game.poke("wKeyItems", 0xff, len(names))
	game.poke("wNumKeyItems", len(names))


def idle(game):
	return (game.peek("wScriptRunning") == 0 and game.peek("wWindowStackSize") == 0
		and game.peek("wMapStatus") == 2)


def press_select(game):
	"""SELECT, then A through any text until the map is back."""
	game.press("select", after=60)
	for _ in range(20):
		if idle(game):
			return
		game.press("a", after=30)
	raise AssertionError("the map never came back. The screen:\n" + game.screen_text())


def ride(game, item, start=ROUTE_30):
	"""Warp to `start` and get on `item` with SELECT."""
	game.poke("wRepelEffect", 250) # no wild battles mid-measurement
	game.warp(*start)
	give_key_items(game, item)
	register(game, item)
	press_select(game)
	assert game.peek("wPlayerState") == RIDING[item], \
		"didn't get on the %s. The screen:\n%s" % (item, game.screen_text())


def facing_frame(game):
	"""The player's facing frame within its direction: 0 standing, 1 walking, 2 standing again,
	3 walking mirrored."""
	return game.peek("wPlayerFacing") & 3


def frames_per_tile(game, direction, tiles=6):
	"""Hold `direction` and time each tile: the frames between position changes."""
	pyboy = game.pyboy
	pyboy.button_press(direction)
	changes = []
	last = game.position()
	for frame in range(tiles * 40):
		pyboy.tick(1, False)
		if game.position() != last:
			last = game.position()
			changes.append(frame)
			if len(changes) > tiles:
				break
	pyboy.button_release(direction)
	return [b - a for a, b in zip(changes, changes[1:])]


def hold_until_stopped(game, direction, limit=900):
	"""Hold `direction` until the player stops moving (a wall); return the map and position."""
	pyboy = game.pyboy
	pyboy.button_press(direction)
	last = (game.current_map(), game.position())
	still = 0
	for _ in range(limit):
		pyboy.tick(1, False)
		now = (game.current_map(), game.position())
		still = still + 1 if now == last else 0
		last = now
		if still == 60:
			break
	pyboy.button_release(direction)
	game.wait(20)
	return last


# Getting on and off

def test_used_from_the_pack(game):
	"""The whole way: the Key Items pocket, MOPED, USE."""
	game.warp(*ROUTE_30)
	give_key_items(game, "BICYCLE", "MOPED")
	game.press("start", after=30)
	game.choose("PACK")
	game.wait(40)
	for _ in range(6):
		if "MOPED" in game.screen_text():
			break
		game.press("left", after=40)
	game.choose("MOPED")
	game.wait(20)
	game.choose("USE")
	game.wait_for_text("got on the")
	assert "MOPED." in game.screen_text()
	game.press("a", after=60)
	assert game.peek("wPlayerState") == PLAYER_MOPED
	assert game.peek("wMapMusic") == music("MUSIC_PUZZLE_TOTODILE")
	assert game.peek("wPlayerSprite") == sprite("SPRITE_CHRIS_MOPED")


@pytest.mark.parametrize("item, state, boy, girl", [
	("BICYCLE", PLAYER_BIKE, "SPRITE_CHRIS_BIKE", "SPRITE_KRIS_BIKE"),
	("MOPED", PLAYER_MOPED, "SPRITE_CHRIS_MOPED", "SPRITE_KRIS_MOPED"),
])
@pytest.mark.parametrize("gender", ["boy", "girl"])
def test_select_gets_on_and_off(game, item, state, boy, girl, gender):
	"""Registered to SELECT: on, with the ride's music and the riding sprite; off again, with the
	walking sprite and the map's music. The bike is checked the same way, so it hasn't changed."""
	if gender == "girl":
		game.poke("wPlayerGender", FEMALE)
	game.warp(*ROUTE_30)
	map_music = game.peek("wMapMusic")
	assert map_music != music("MUSIC_BICYCLE")
	walking = game.peek("wPlayerSprite")

	ride(game, item)
	assert game.peek("wPlayerState") == state
	assert game.peek("wMapMusic") == music(RIDE_MUSIC[item])
	assert game.peek("wPlayerSprite") == sprite(boy if gender == "boy" else girl)

	press_select(game)
	assert game.peek("wPlayerState") == PLAYER_NORMAL
	assert game.peek("wPlayerSprite") == walking
	assert game.peek("wMapMusic") == map_music


@pytest.mark.parametrize("item", ["BICYCLE", "MOPED"])
def test_ride_music_plays_after_a_warp(game, item):
	"""Warping to another outdoor map while riding, it plays the ride's music, not its own. (Crossing a
	map edge plays the new map's music on either ride, as it always has.)"""
	ride(game, item)
	game.warp(*ROUTE_29)
	assert game.peek("wPlayerState") == RIDING[item]
	assert game.peek("wMapMusic") == music(RIDE_MUSIC[item])


POKEGEAR_FLAGS = 1 << 7 | 1 << 1 | 1 << 0 # the Pokégear, its radio card and its map card
POKEGEARCARD_RADIO = 3
ENTER_MAP_MUSIC = 0xff # wPokegearRadioMusicPlaying: tuned off every station, the map music is off


@pytest.mark.parametrize("item", ["BICYCLE", "MOPED"])
def test_radio_off_brings_back_the_ride_music(game, item):
	"""In the Pokégear, tune the radio between stations (the music stops), then leave: the ride's
	music plays again."""
	ride(game, item)
	game.poke("wPokegearFlags", POKEGEAR_FLAGS)
	game.press("start", after=40)
	game.choose("GEAR")
	game.wait(120)
	for _ in range(8):
		if game.peek("wPokegearCard") == POKEGEARCARD_RADIO:
			break
		game.press("right", after=60)
	assert game.peek("wPokegearCard") == POKEGEARCARD_RADIO, "card %d" % game.peek("wPokegearCard")
	game.wait(60)
	for _ in range(40):
		if game.peek("wPokegearRadioMusicPlaying") == ENTER_MAP_MUSIC:
			break
		game.press("up", after=20)
	assert game.peek("wPokegearRadioMusicPlaying") == ENTER_MAP_MUSIC, "never tuned between stations"
	assert game.peek("wMusicID") == music("MUSIC_NONE")
	game.press("b", after=120)
	assert game.peek("wMusicID") == music(RIDE_MUSIC[item]), game.screen_text()
	assert game.peek("wMapMusic") == music(RIDE_MUSIC[item])


# Where it can be used: the bike's rules

@pytest.mark.parametrize("item", ["BICYCLE", "MOPED"])
def test_cant_be_used_indoors(game, item):
	"""The game starts in the bedroom, where neither can be ridden."""
	give_key_items(game, item)
	register(game, item)
	press_select(game)
	assert game.peek("wPlayerState") == PLAYER_NORMAL


@pytest.mark.parametrize("item", ["BICYCLE", "MOPED"])
def test_going_indoors_gets_off(game, item):
	ride(game, item)
	game.warp(*BERRY_HOUSE)
	assert game.peek("wPlayerState") == PLAYER_NORMAL


# The Cycling Road: owning the moped puts you on it there; the road doesn't push it downhill, and
# going up holds at the running shoes' speed.

CYCLING_ROAD = ("ROUTE_17", 9, 6)


def onto_cycling_road(game, items, riding):
	"""Ride `riding` while owning `items`, then warp onto the road."""
	ride(game, riding)
	give_key_items(game, *items)
	F.start_warp(game, *CYCLING_ROAD) # not game.warp: on the bike the slope carries the player off the spot
	game.wait(200)
	assert game.in_map("ROUTE_17")


@pytest.mark.parametrize("items, riding, state, boy", [
	(["MOPED"], "MOPED", PLAYER_MOPED, "SPRITE_CHRIS_MOPED"),
	(["BICYCLE", "MOPED"], "BICYCLE", PLAYER_MOPED, "SPRITE_CHRIS_MOPED"),
	(["BICYCLE"], "BICYCLE", PLAYER_BIKE, "SPRITE_CHRIS_BIKE"),
])
def test_cycling_road_puts_the_moped_owner_on_the_moped(game, items, riding, state, boy):
	"""Owning the moped puts you on it there, whatever you rode in on; without it, the bike."""
	onto_cycling_road(game, items, riding)
	assert game.peek("wPlayerState") == state
	assert game.peek("wPlayerSprite") == sprite(boy)
	assert game.peek("wMapMusic") == music("MUSIC_PUZZLE_TOTODILE" if state == PLAYER_MOPED else "MUSIC_BICYCLE")


# Coming onto the road the way a player does: on foot out of a gate (the door's map setup), or
# riding across Route 16's edge. Both pick the song through SpecialMapMusic, not PlayMapMusicBike.
ROAD_GATES = {"ROUTE_16_GATE": "ROUTE_16", "ROUTE_17_ROUTE_18_GATE": "ROUTE_17"}


def out_of_the_gate(game, gate, item):
	game.poke("wRepelEffect", 250)
	give_key_items(game, item)
	game.warp(gate, 1, 4)
	for _ in range(4):
		game.press("left", after=60)
		if game.in_map(ROAD_GATES[gate]):
			break
	game.wait(60)
	assert game.in_map(ROAD_GATES[gate])
	assert game.peek("wPlayerState") == RIDING[item]


@pytest.mark.parametrize("gate", list(ROAD_GATES))
@pytest.mark.parametrize("item", ["BICYCLE", "MOPED"])
def test_cycling_road_plays_the_ride_music_out_of_the_gate(game, gate, item):
	out_of_the_gate(game, gate, item)
	assert game.peek("wMapMusic") == music(RIDE_MUSIC[item])


@pytest.mark.parametrize("item", ["BICYCLE", "MOPED"])
def test_cycling_road_keeps_the_ride_music_across_route_16s_edge(game, item):
	out_of_the_gate(game, "ROUTE_16_GATE", item)
	for _ in range(20):
		game.press("down", after=16)
		if game.in_map("ROUTE_17"):
			break
	game.wait(60)
	assert game.in_map("ROUTE_17")
	assert game.peek("wMapMusic") == music(RIDE_MUSIC[item])


@pytest.mark.parametrize("item", ["BICYCLE", "MOPED"])
def test_other_map_edges_play_the_maps_music(game, item):
	"""Off the road, crossing a map edge on a ride plays the new map's song, as it always has."""
	ride(game, item, start=ROUTE_29)
	hold_until_stopped(game, "right")
	game.wait(60)
	assert game.in_map("NEW_BARK_TOWN")
	assert game.peek("wMapMusic") == music("MUSIC_NEW_BARK_TOWN")


@pytest.mark.parametrize("gate", ["ROUTE_16_GATE", "ROUTE_17_ROUTE_18_GATE"])
@pytest.mark.parametrize("items, passes", [
	(["MOPED"], True),
	(["BICYCLE"], True),
	(["BICYCLE", "MOPED"], True),
	([], False),
])
def test_cycling_road_gates_let_the_moped_through(game, gate, items, passes):
	"""Walking west onto the guard's check at x 5: either ride lets you on; with neither, he names
	both and sends you back a step."""
	game.warp(gate, 6, 4)
	if items:
		give_key_items(game, *items)
	pyboy = game.pyboy
	pyboy.button_press("left") # held: a tap only turns the player to face west
	for _ in range(60):
		pyboy.tick(1, False)
		if game.position() != (6, 4):
			break
	pyboy.button_release("left")
	game.wait(60)
	said = ""
	for _ in range(20):
		if idle(game):
			break
		said += game.screen_text()
		game.press("a", after=30)
	game.wait(30)
	assert game.position() == ((5, 4) if passes else (6, 4)), said
	if not passes:
		assert "BICYCLE or MOPED" in said.replace("\n", " "), said


def test_cycling_road_leaves_the_moped_standing(game):
	"""No D-pad on the moped: no push downhill."""
	onto_cycling_road(game, ["MOPED"], "MOPED")
	where = game.position()
	game.wait(120)
	assert game.position() == where


def test_cycling_road_still_rolls_the_bike_downhill(game):
	onto_cycling_road(game, ["BICYCLE"], "BICYCLE")
	x, y = game.position()
	game.wait(60)
	assert game.position()[1] > y


def test_moped_goes_up_the_cycling_road_at_the_running_shoes_speed(game):
	"""Up holds at 8 frames a tile, while the tiles still count: turning down goes straight on at full
	speed."""
	onto_cycling_road(game, ["MOPED"], "MOPED")
	assert step_lengths(game, [("down", 6)], b=True) == RAMP + [2, 2]
	game.wait(30)
	assert step_lengths(game, [("up", 5), ("down", 2)], b=True) == [8] * 5 + [2, 2]


def test_bike_still_goes_up_the_cycling_road_at_walking_speed(game):
	onto_cycling_road(game, ["BICYCLE"], "BICYCLE")
	game.wait(120) # rolled down a way: room to go up
	assert step_lengths(game, [("up", 3)]) == [16] * 3


def test_cant_get_off_the_moped_on_the_cycling_road(game):
	onto_cycling_road(game, ["MOPED"], "MOPED")
	register(game, "MOPED")
	press_select(game)
	assert game.peek("wPlayerState") == PLAYER_MOPED


@pytest.mark.parametrize("first, second", [("BICYCLE", "MOPED"), ("MOPED", "BICYCLE")])
def test_cant_switch_straight_between_them(game, first, second):
	"""On one, the other can't be used: get off first."""
	ride(game, first)
	give_key_items(game, first, second)
	game.poke("wWhichRegisteredItem", 2 << 6 | 2) # the Key Items pocket's second item
	game.poke("wRegisteredItem", A.item_id(game, second))
	press_select(game)
	assert game.peek("wPlayerState") == RIDING[first]


# Speed

def step_lengths(game, plan, b=False):
	"""Ride by `plan`, a list of (direction, steps) or (direction, steps, b): hold each direction (and
	B, if b) until that many more steps have started. Returns each step's length in frames, read as
	it starts."""
	pyboy = game.pyboy
	lengths = []
	was_stepping = False
	for segment in plan:
		direction, steps = segment[:2]
		hold_b = segment[2] if len(segment) > 2 else b
		if hold_b:
			pyboy.button_press("b")
		else:
			pyboy.button_release("b")
		pyboy.button_press(direction)
		goal = len(lengths) + steps
		for _ in range(steps * 40):
			pyboy.tick(1, False)
			stepping = F.object_field(game, 0, OBJECT_WALKING) != STANDING
			if stepping and not was_stepping:
				lengths.append(F.object_field(game, 0, OBJECT_STEP_DURATION) + 1)
			was_stepping = stepping
			if len(lengths) == goal:
				break
		pyboy.button_release(direction)
		assert len(lengths) == goal, "stuck at %s: %s" % (game.position(), lengths)
	pyboy.button_release("b")
	return lengths


# From a stop the moped builds up: 2 tiles at the running shoes' 8 frames, 2 at the bike's 4, then 2
# with B held (4 without).
RAMP = [8, 8, 4, 4]
# Route 29's east end: open ground east into New Bark Town, and the row below it.
ROUTE_29_EAST = ("ROUTE_29", 46, 8)
# Route 26, above a ledge: nine tiles of run-up, the hop at (9, 58), open ground below.
ROUTE_26_ABOVE_LEDGE = ("ROUTE_26", 9, 50)


def test_moped_rides_two_frames_a_tile(game):
	ride(game, "MOPED", ROUTE_29_EAST)
	assert step_lengths(game, [("right", 10)], b=True) == RAMP + [2] * 6


def test_moped_tops_out_at_the_bike_speed_without_b(game):
	ride(game, "MOPED", ROUTE_29_EAST)
	assert step_lengths(game, [("right", 10)]) == RAMP + [4] * 6


def test_pressing_b_at_bike_speed_goes_full_speed_on_the_next_tile(game):
	ride(game, "MOPED", ROUTE_29_EAST)
	assert step_lengths(game, [("right", 6), ("right", 3, True)]) == RAMP + [4, 4] + [2, 2, 2]


def test_b_in_the_build_up_changes_nothing_until_it_is_done(game):
	ride(game, "MOPED", ROUTE_29_EAST)
	assert step_lengths(game, [("right", 6, True)]) == RAMP + [2, 2]


def test_letting_go_of_b_coasts_four_tiles(game):
	ride(game, "MOPED", ROUTE_29_EAST)
	lengths = step_lengths(game, [("right", 6, True), ("right", 6)])
	assert lengths == RAMP + [2, 2] + [2, 2, 2, 2, 4, 4], lengths


def test_b_again_during_the_coast_keeps_full_speed(game):
	"""One tile of the coast, then B again: full speed, and a whole coast after letting go."""
	ride(game, "MOPED", ROUTE_29_EAST)
	lengths = step_lengths(game, [("right", 5, True), ("right", 1), ("right", 2, True), ("right", 5)])
	assert lengths == RAMP + [2] + [2] + [2, 2] + [2, 2, 2, 2, 4], lengths


def test_stopping_ends_the_coast(game):
	ride(game, "MOPED", ROUTE_29_EAST)
	step_lengths(game, [("right", 6)], b=True)
	game.wait(30)
	assert step_lengths(game, [("left", 6)]) == RAMP + [4, 4]


def test_letting_go_starts_it_over(game):
	ride(game, "MOPED", ROUTE_29_EAST)
	assert step_lengths(game, [("right", 6)], b=True) == RAMP + [2, 2]
	game.wait(30)
	assert step_lengths(game, [("left", 5)], b=True) == RAMP + [2]


def test_getting_on_again_starts_slow(game):
	ride(game, "MOPED", ROUTE_29_EAST)
	step_lengths(game, [("right", 6)], b=True)
	press_select(game) # off
	press_select(game) # on
	assert game.peek("wPlayerState") == PLAYER_MOPED
	assert step_lengths(game, [("left", 5)], b=True) == RAMP + [2]


def test_bumping_starts_it_over(game):
	ride(game, "MOPED")
	pyboy = game.pyboy
	pyboy.button_press("up")
	for _ in range(150):
		pyboy.tick(1, False)
	assert game.position() == ROUTE_30_WALL
	assert game.peek("wMopedRampTiles") == 0, "still holding UP into the wall"
	pyboy.button_release("up")


def test_turning_keeps_the_speed(game):
	ride(game, "MOPED", ROUTE_29_EAST)
	assert step_lengths(game, [("right", 6), ("down", 1), ("right", 2)], b=True) == RAMP + [2] * 5


def test_hopping_a_ledge_keeps_the_speed(game):
	ride(game, "MOPED", ROUTE_26_ABOVE_LEDGE)
	assert step_lengths(game, [("down", 11)], b=True) == RAMP + [2] * 4 + [16, 2, 2]


def test_a_map_edge_keeps_the_speed(game):
	ride(game, "MOPED", ROUTE_29_EAST)
	lengths = step_lengths(game, [("right", 15)], b=True) # to New Bark Town's (1, 8)
	assert game.in_map("NEW_BARK_TOWN")
	assert lengths == RAMP + [2] * 11, lengths


def test_bike_still_rides_four_frames_a_tile(game):
	ride(game, "BICYCLE")
	times = frames_per_tile(game, "up")
	assert min(times) == 4, times
	assert sorted(times)[len(times) // 2] == 4, times


def test_bike_ignores_b(game):
	ride(game, "BICYCLE", ROUTE_29_EAST)
	assert step_lengths(game, [("right", 6)], b=True) == [4] * 6


@pytest.mark.parametrize("start, direction, expected", [
	(ROUTE_30, "up", ("ROUTE_30",) + ROUTE_30_WALL),
	(ROUTE_29, "right", ("NEW_BARK_TOWN", 1, 8)),
	(ROUTE_29_ABOVE_LEDGE, "down", ("ROUTE_29", 26, 17)),
])
def test_moped_stops_and_crosses_where_the_bike_does(game, start, direction, expected):
	"""Two-frame steps still read the walls in time, cross a map connection and hop a ledge: the
	moped ends where walking and the bike do."""
	state = game.save_state()
	ends = {}
	for item in [None, "BICYCLE", "MOPED"]:
		game.load_state(state)
		if item:
			ride(game, item, start)
		else:
			game.warp(*start)
		ends[item] = hold_until_stopped(game, direction)
	group_number = constants.maps()[expected[0]]
	assert ends["MOPED"] == (group_number, expected[1:]), ends
	assert ends["MOPED"] == ends["BICYCLE"] == ends[None], ends


def test_follower_keeps_up(game):
	F.take_radio_items(game)
	game.poke("wFollowerPartySlot", 1)
	ride(game, "MOPED")
	assert F.object_field(game, F.FOLLOWER_STRUCT, F.OBJECT_SPRITE) == sprite("SPRITE_FOLLOWER")
	hold_until_stopped(game, "up")
	assert game.position() == ROUTE_30_WALL
	x, y = game.peek("wPlayerMapX"), game.peek("wPlayerMapY")
	fx = F.object_field(game, F.FOLLOWER_STRUCT, F.OBJECT_MAP_X)
	fy = F.object_field(game, F.FOLLOWER_STRUCT, F.OBJECT_MAP_Y)
	assert (fx, fy) == (x, y + 1), "the follower should be right behind the player"


# The animation

@pytest.mark.parametrize("item, start, direction, frames, standing", [
	("BICYCLE", ROUTE_30, "up", {0, 1, 2, 3}, {0}),
	("MOPED", ROUTE_30, "up", {0, 1}, {0, 1}),
	("MOPED", ("ROUTE_26", 9, 50), "down", {0, 1}, {0, 1}),
])
def test_animates_while_moving(game, item, start, direction, frames, standing):
	"""The walk cycle while moving. The bike's cycle has the walking frame mirrored (frame 3); the
	moped never mirrors, its down and up frames aren't symmetrical. Standing still, the bike holds
	frame 0 and the moped idles through its two."""
	ride(game, item, start)
	game.wait(30)
	before = set()
	for _ in range(30):
		game.wait(1)
		before.add(facing_frame(game))
	pyboy = game.pyboy
	pyboy.button_press(direction)
	moving = set()
	for _ in range(40):
		pyboy.tick(1, False)
		moving.add(facing_frame(game))
	pyboy.button_release(direction)
	game.wait(30)
	after = set()
	for _ in range(30):
		game.wait(1)
		after.add(facing_frame(game))
	assert before == standing, before
	assert moving == frames, moving
	assert after == standing, after


def held_frames(game, count):
	"""The player's facing frame for `count` frames, as runs: how long each frame was held."""
	runs = []
	last = None
	for _ in range(count):
		game.wait(1)
		frame = facing_frame(game)
		if frame == last:
			runs[-1] += 1
		else:
			runs.append(1)
		last = frame
	return runs[1:-1] # the first and last are cut off by the start and end of the count


def test_moped_idles_every_8_frames(game):
	"""Standing on the moped, the walk cycle keeps going at a frame change every 8 frames."""
	ride(game, "MOPED")
	game.wait(30)
	held = held_frames(game, 80)
	assert len(held) >= 8 and set(held) == {8}, held


def test_moped_idle_holds_while_the_menu_is_up(game):
	ride(game, "MOPED")
	game.wait(30)
	game.press("start", after=30)
	assert not idle(game)
	seen = set()
	for _ in range(40):
		game.wait(1)
		seen.add(facing_frame(game))
	assert seen == {0}, seen


@pytest.mark.parametrize("item, b, paces", [
	("MOPED", True, [4]),
	("MOPED", False, [4]),
	("BICYCLE", True, [4]),
	("BICYCLE", False, [4]),
])
def test_rides_animate_at_the_running_shoes_pace(game, item, b, paces):
	"""The bike's and the moped's walk cycles change frame every 4 frames, the running shoes' pace,
	at every speed, B or not."""
	ride(game, item, ROUTE_29_EAST)
	pyboy = game.pyboy
	if b:
		pyboy.button_press("b")
	pyboy.button_press("right")
	frames = []
	while len(frames) < 40: # the build-up and a few full-speed tiles, short of New Bark Town
		pyboy.tick(1, False)
		if F.object_field(game, 0, OBJECT_WALKING) != STANDING or frames:
			frames.append(facing_frame(game))
	pyboy.button_release("right")
	pyboy.button_release("b")
	runs = [1]
	for x, y in zip(frames, frames[1:]):
		if x == y:
			runs[-1] += 1
		else:
			runs.append(1)
	held = runs[1:-1] # the first and last are cut off by the start and end of the count
	assert len(held) >= 4, runs
	assert [pace for i, pace in enumerate(held) if i == 0 or held[i - 1] != pace] == paces, runs


# The follower while riding: in its ball

FOLLOWER_INVISIBLE_F = 0
FOLLOWER_IN_POKEBALL_F = 3
FOLLOWER_RIDING_F = 6


def follower_flags(game):
	return game.peek("wFollowerFlags")


def follower_hidden(game):
	flags = follower_flags(game)
	return (flags & (1 << FOLLOWER_INVISIBLE_F) and flags & (1 << FOLLOWER_IN_POKEBALL_F)
		and F.object_field(game, F.FOLLOWER_STRUCT, F.OBJECT_FLAGS1) & F.INVISIBLE)


def follower_shown(game):
	flags = follower_flags(game)
	return (F.object_field(game, F.FOLLOWER_STRUCT, F.OBJECT_SPRITE) == sprite("SPRITE_FOLLOWER")
		and not flags & (1 << FOLLOWER_INVISIBLE_F | 1 << FOLLOWER_IN_POKEBALL_F | 1 << FOLLOWER_RIDING_F)
		and not F.object_field(game, F.FOLLOWER_STRUCT, F.OBJECT_FLAGS1) & F.INVISIBLE)


def get_on(game, item):
	"""SELECT onto `item` where the player stands."""
	give_key_items(game, item)
	register(game, item)
	press_select(game)
	assert game.peek("wPlayerState") == RIDING[item]


def with_follower(game, start=ROUTE_30, step="up"):
	"""A follower out at `start`, past the first step that brings it out after the warp."""
	F.take_radio_items(game)
	game.poke("wFollowerPartySlot", 1)
	game.poke("wRepelEffect", 250)
	game.warp(*start)
	game.step(step)
	game.wait(30)
	assert follower_shown(game), "%02x" % follower_flags(game)


@pytest.mark.parametrize("item", ["BICYCLE", "MOPED"])
def test_follower_rides_in_its_ball(game, item):
	with_follower(game)
	get_on(game, item)
	game.wait(30)
	assert follower_hidden(game), "%02x" % follower_flags(game)
	assert follower_flags(game) & 1 << FOLLOWER_RIDING_F
	hold_until_stopped(game, "up")
	assert follower_hidden(game), "it stays in its ball while riding"
	press_select(game)
	game.wait(60)
	assert follower_shown(game), "out of its ball on getting off: %02x" % follower_flags(game)
	x, y = game.peek("wPlayerMapX"), game.peek("wPlayerMapY")
	fx = F.object_field(game, F.FOLLOWER_STRUCT, F.OBJECT_MAP_X)
	fy = F.object_field(game, F.FOLLOWER_STRUCT, F.OBJECT_MAP_Y)
	assert (fx, fy) == (x, y + 1), "right behind the player"


def test_follower_stays_in_its_ball_across_a_map_edge(game):
	with_follower(game, ROUTE_29, "left")
	get_on(game, "MOPED")
	hold_until_stopped(game, "right")
	assert game.in_map("NEW_BARK_TOWN")
	game.wait(30)
	assert follower_hidden(game), "%02x" % follower_flags(game)
	game.step("left")
	game.wait(30)
	assert follower_hidden(game), "a step on the new map doesn't bring it out"


@pytest.mark.parametrize("item", ["BICYCLE", "MOPED"])
def test_going_indoors_brings_the_follower_back(game, item):
	with_follower(game)
	get_on(game, item)
	game.warp(*BERRY_HOUSE)
	game.wait(30)
	assert game.peek("wPlayerState") == PLAYER_NORMAL
	assert not follower_flags(game) & (1 << FOLLOWER_RIDING_F | 1 << FOLLOWER_IN_POKEBALL_F)
	game.step("up")
	game.wait(30)
	assert follower_shown(game), "out on the first step, as after any door: %02x" % follower_flags(game)


def test_follower_picked_while_riding_waits(game):
	F.take_radio_items(game)
	game.poke("wFollowerPartySlot", 0)
	ride(game, "MOPED")
	game.press("start", hold=6, after=40) # START > POKéMON, SELECT on the first mon, back out
	game.choose("POKéMON")
	game.wait(60)
	game.press("select", hold=6, after=40)
	assert game.peek("wFollowerPartySlot") == 1
	for _ in range(10):
		if idle(game):
			break
		game.press("b", hold=6, after=40)
	# A follower picked from nobody only shows up at the next map load (true off the bike too);
	# riding on, it has to stay in its ball through that load.
	game.warp(*ROUTE_30)
	game.step("up")
	game.wait(30)
	assert game.peek("wPlayerState") == PLAYER_MOPED
	assert F.object_field(game, F.FOLLOWER_STRUCT, F.OBJECT_SPRITE) == sprite("SPRITE_FOLLOWER")
	assert follower_hidden(game), "%02x" % follower_flags(game)
	press_select(game)
	game.wait(60)
	assert follower_shown(game), "%02x" % follower_flags(game)


# Grass and map edges while riding

OBJECT_FLAGS1 = 0x04
OBJECT_STEP_TYPE = 0x09
OBJECT_1D = 0x1d # a tracking object's parent: the struct's address
STEP_TYPE_TRACKING_OBJECT = 0x13
# Route 29's grass patch north of the ledges: in from (22, 4), west along row 4 into the rock
# at (15, 4), down to the patch's bottom row, then west through it and over the ledge at x 9.
GRASS_START = ("ROUTE_29", 22, 4)
# Route 34's north end, below Goldenrod City.
ROUTE_34_NORTH = ("ROUTE_34", 10, 5)


def grass_shakes(game):
	"""{struct: the address of the object it shakes around} for each grass shake out."""
	return {s: F.object_field(game, s, OBJECT_1D) | F.object_field(game, s, OBJECT_1D + 1) << 8
		for s in range(F.NUM_OBJECT_STRUCTS)
		if F.object_field(game, s, F.OBJECT_SPRITE)
			and F.object_field(game, s, OBJECT_STEP_TYPE) == STEP_TYPE_TRACKING_OBJECT}


def ride_through_grass(game, item):
	"""Through the patch and out over the ledge; return the parents of every shake seen."""
	with_follower(game, GRASS_START, "left")
	if item:
		get_on(game, item)
	pyboy = game.pyboy
	parents = set()
	for button, frames in (("left", 120), ("down", 60), ("left", 240)):
		pyboy.button_press(button)
		for _ in range(frames):
			pyboy.tick(1, False)
			parents |= set(grass_shakes(game).values())
			if game.position()[0] <= 8:
				break
		pyboy.button_release(button)
	assert game.position()[0] <= 8, "never left the grass: %s" % (game.position(),)
	return parents


def struct_address(game, struct):
	bank, address = game._address("wObjectStructs")
	return address + struct * F.OBJECT_LENGTH


@pytest.mark.parametrize("item", ["BICYCLE", "MOPED"])
def test_grass_stops_shaking_after_the_ride(game, item):
	"""The moped's two-frame steps used to leave each shake with no time to count down, so every one
	stayed on screen until the next map."""
	assert ride_through_grass(game, item), "the grass never shook"
	game.wait(30)
	assert grass_shakes(game) == {}


@pytest.mark.parametrize("item", ["BICYCLE", "MOPED"])
def test_follower_in_its_ball_leaves_the_grass_still(game, item):
	parents = ride_through_grass(game, item)
	assert struct_address(game, 0) in parents, "the rider shakes it"
	assert struct_address(game, F.FOLLOWER_STRUCT) not in parents, "nothing walks behind"


def test_follower_out_still_shakes_the_grass(game):
	assert struct_address(game, F.FOLLOWER_STRUCT) in ride_through_grass(game, None)


@pytest.mark.parametrize("item", ["BICYCLE", "MOPED"])
def test_follower_in_its_ball_stays_unseen_across_a_map_edge(game, item):
	"""Route 34 into Goldenrod: crossing the edge gave the hidden follower the player's facing, and the
	sprite update before its own turn drew it a tile behind the player for two frames."""
	with_follower(game, ROUTE_34_NORTH, "down")
	get_on(game, item)
	pyboy = game.pyboy
	pyboy.button_press("up")
	frames_in_goldenrod = 0
	for _ in range(300):
		pyboy.tick(1, False)
		facing = F.object_field(game, F.FOLLOWER_STRUCT, OBJECT_FACING)
		assert facing == STANDING, "drawn on %s at %s" % (game.current_map(), game.position())
		if game.in_map("GOLDENROD_CITY"):
			frames_in_goldenrod += 1
			if frames_in_goldenrod == 30:
				break
	pyboy.button_release("up")
	assert frames_in_goldenrod == 30, "never reached Goldenrod"


# Ledges while riding

OBJECT_ACTION = 0x0b
OBJECT_ACTION_SHADOW = 7
# Route 5, from Cerulean City down: a ledge every four rows, hopped from (13, 4), (13, 8), (13, 12).
ROUTE_5_LEDGES = ("ROUTE_5", 13, 3)


def pin_wanderers_aside(game):
	"""Hold each wandering Pokemon still off column 13, so none walks into the run and starts a battle."""
	for i, s in enumerate(s for s in range(F.NUM_OBJECT_STRUCTS)
			if sprite("SPRITE_OW_MON_1") <= F.object_field(game, s, F.OBJECT_SPRITE) <= sprite("SPRITE_OW_MON_4")):
		pin_wanderer(game, s, (3, 2 + 2 * i))


def shadow_parents(game):
	"""The address of the object under each shadow out."""
	return {F.object_field(game, s, OBJECT_1D) | F.object_field(game, s, OBJECT_1D + 1) << 8
		for s in range(F.NUM_OBJECT_STRUCTS)
		if F.object_field(game, s, F.OBJECT_SPRITE)
			and F.object_field(game, s, OBJECT_ACTION) == OBJECT_ACTION_SHADOW}


def down_the_ledges(game, item):
	"""Down Route 5's three ledges in a row; return the parents of every shadow seen."""
	with_follower(game, ROUTE_5_LEDGES, "down")
	pin_wanderers_aside(game)
	if item:
		get_on(game, item)
	pyboy = game.pyboy
	parents = set()
	pyboy.button_press("down")
	for _ in range(600):
		pyboy.tick(1, False)
		parents |= shadow_parents(game)
		if game.position()[1] >= 16:
			break
	pyboy.button_release("down")
	game.wait(30)
	parents |= shadow_parents(game)
	assert game.position()[1] >= 16, "never got down the ledges: %s" % (game.position(),)
	return parents


@pytest.mark.parametrize("item", ["BICYCLE", "MOPED"])
def test_follower_in_its_ball_casts_no_shadow_down_ledges(game, item):
	"""The follower in its ball still hops each ledge a tile behind the rider, and every hop spawned
	a shadow, which dropped down the ledges behind the player with nothing above it."""
	parents = down_the_ledges(game, item)
	assert struct_address(game, 0) in parents, "the rider casts one"
	assert struct_address(game, F.FOLLOWER_STRUCT) not in parents, "nothing hops behind"


def test_follower_out_still_casts_a_shadow_down_ledges(game):
	assert struct_address(game, F.FOLLOWER_STRUCT) in down_the_ledges(game, None)
