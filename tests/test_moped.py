"""The MOPED: a key item used like the BICYCLE, with the bike's rules and music, that builds up from a
stop to 2 frames a tile (the bike's 4, walking's 16) and animates as the bike does: the walk cycle while
moving, the standing frame when stopped. The debug radio gives it."""

import pytest

from harness import constants
from harness import alt_shiny as A
from harness import followers as F
from test_registered_item import key_item_index, register

PLAYER_NORMAL = 0
PLAYER_BIKE = 1
PLAYER_MOPED = 3
RIDING = {"BICYCLE": PLAYER_BIKE, "MOPED": PLAYER_MOPED}

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
	assert game.peek("wMapMusic") == music("MUSIC_BICYCLE")
	assert game.peek("wPlayerSprite") == sprite("SPRITE_CHRIS_MOPED")


@pytest.mark.parametrize("item, state, boy, girl", [
	("BICYCLE", PLAYER_BIKE, "SPRITE_CHRIS_BIKE", "SPRITE_KRIS_BIKE"),
	("MOPED", PLAYER_MOPED, "SPRITE_CHRIS_MOPED", "SPRITE_KRIS_MOPED"),
])
@pytest.mark.parametrize("gender", ["boy", "girl"])
def test_select_gets_on_and_off(game, item, state, boy, girl, gender):
	"""Registered to SELECT: on, with the bike music and the riding sprite; off again, with the
	walking sprite and the map's music. The bike is checked the same way, so it hasn't changed."""
	if gender == "girl":
		game.poke("wPlayerGender", FEMALE)
	game.warp(*ROUTE_30)
	map_music = game.peek("wMapMusic")
	assert map_music != music("MUSIC_BICYCLE")
	walking = game.peek("wPlayerSprite")

	ride(game, item)
	assert game.peek("wPlayerState") == state
	assert game.peek("wMapMusic") == music("MUSIC_BICYCLE")
	assert game.peek("wPlayerSprite") == sprite(boy if gender == "boy" else girl)

	press_select(game)
	assert game.peek("wPlayerState") == PLAYER_NORMAL
	assert game.peek("wPlayerSprite") == walking
	assert game.peek("wMapMusic") == map_music


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


def test_cycling_road_puts_the_moped_rider_on_the_bike(game):
	"""The Cycling Road forces the bike as it always has, so the moped never rides it."""
	ride(game, "MOPED")
	F.start_warp(game, "ROUTE_17", 9, 6) # not game.warp: the road's slope carries the player off the spot
	game.wait(200)
	assert game.in_map("ROUTE_17")
	assert game.peek("wPlayerState") == PLAYER_BIKE
	assert game.peek("wPlayerSprite") == sprite("SPRITE_CHRIS_BIKE")


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

def step_lengths(game, plan):
	"""Ride by `plan`, a list of (direction, steps): hold each direction until that many more steps
	have started. Returns each step's length in frames, read as it starts."""
	pyboy = game.pyboy
	lengths = []
	was_stepping = False
	for direction, steps in plan:
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
	return lengths


# From a stop the moped builds up: 2 tiles at the running shoes' 8 frames, 2 at the bike's 4, then 2.
RAMP = [8, 8, 4, 4]
# Route 29's east end: open ground east into New Bark Town, and the row below it.
ROUTE_29_EAST = ("ROUTE_29", 46, 8)
# Route 26, above a ledge: nine tiles of run-up, the hop at (9, 58), open ground below.
ROUTE_26_ABOVE_LEDGE = ("ROUTE_26", 9, 50)


def test_moped_rides_two_frames_a_tile(game):
	ride(game, "MOPED", ROUTE_29_EAST)
	assert step_lengths(game, [("right", 10)]) == RAMP + [2] * 6


def test_letting_go_starts_it_over(game):
	ride(game, "MOPED", ROUTE_29_EAST)
	assert step_lengths(game, [("right", 6)]) == RAMP + [2, 2]
	game.wait(30)
	assert step_lengths(game, [("left", 5)]) == RAMP + [2]


def test_getting_on_again_starts_slow(game):
	ride(game, "MOPED", ROUTE_29_EAST)
	step_lengths(game, [("right", 6)])
	press_select(game) # off
	press_select(game) # on
	assert game.peek("wPlayerState") == PLAYER_MOPED
	assert step_lengths(game, [("left", 5)]) == RAMP + [2]


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
	assert step_lengths(game, [("right", 6), ("down", 1), ("right", 2)]) == RAMP + [2] * 5


def test_hopping_a_ledge_keeps_the_speed(game):
	ride(game, "MOPED", ROUTE_26_ABOVE_LEDGE)
	assert step_lengths(game, [("down", 11)]) == RAMP + [2] * 4 + [16, 2, 2]


def test_a_map_edge_keeps_the_speed(game):
	ride(game, "MOPED", ROUTE_29_EAST)
	lengths = step_lengths(game, [("right", 15)]) # to New Bark Town's (1, 8)
	assert game.in_map("NEW_BARK_TOWN")
	assert lengths == RAMP + [2] * 11, lengths


def test_bike_still_rides_four_frames_a_tile(game):
	ride(game, "BICYCLE")
	times = frames_per_tile(game, "up")
	assert min(times) == 4, times
	assert sorted(times)[len(times) // 2] == 4, times


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

@pytest.mark.parametrize("item, start, direction, frames", [
	("BICYCLE", ROUTE_30, "up", {0, 1, 2, 3}),
	("MOPED", ROUTE_30, "up", {0, 1}),
	("MOPED", ("ROUTE_26", 9, 50), "down", {0, 1}),
])
def test_animates_only_while_moving(game, item, start, direction, frames):
	"""The walk cycle while moving, frame 0 standing still. The bike's cycle has the walking frame
	mirrored (frame 3); the moped never mirrors, its down and up frames aren't symmetrical."""
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
	assert before == {0}, before
	assert moving == frames, moving
	assert after == {0}, after


@pytest.mark.parametrize("item", ["MOPED", "BICYCLE"])
def test_animates_at_one_pace_while_building_up(game, item):
	"""From a stop, through the moped's running-shoe and bike speeds to its own: the walk cycle
	changes frame every 8 frames throughout, as the bike's does. The running shoes' own animation,
	twice as fast, isn't used on the moped."""
	ride(game, item, ROUTE_29_EAST)
	pyboy = game.pyboy
	pyboy.button_press("right")
	frames = []
	while len(frames) < 40: # the build-up and a few full-speed tiles, short of New Bark Town
		pyboy.tick(1, False)
		if F.object_field(game, 0, OBJECT_WALKING) != STANDING or frames:
			frames.append(facing_frame(game))
	pyboy.button_release("right")
	runs = [1]
	for a, b in zip(frames, frames[1:]):
		if a == b:
			runs[-1] += 1
		else:
			runs.append(1)
	held = runs[1:-1] # the first and last are cut off by the start and end of the count
	assert len(held) >= 4 and min(held) >= 8, runs


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
