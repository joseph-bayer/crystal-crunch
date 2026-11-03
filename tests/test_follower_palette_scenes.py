"""Two more scenes that wrote wObject1Palette, the original game's way of coloring an object that
was in object struct 1. Here struct 1 is the follower, and objects get their palette slots
dynamically.

- The Battle Tower battle room colored its opponent with OBJ palette 1: the opponent loader copied
  the trainer's colors into slot 1 and the script pointed struct 1 at it. The opponent already has
  its own slot, so all this did was paint the follower (whose colors usually live in slot 1) in
  the opponent's colors.
- The S.S. Aqua captain's cabin pointed struct 1 at slot 1 as the granddaughter reappears. Every
  object there already has its own slot, so it only moved the follower to slot 1. The rescan as
  the scene fades back in puts the follower back in its own slot, and the screen is black between
  the two, so nothing showed; the test watches the byte itself."""

from harness import legendaries as L
from harness import followers as F

OBJECT_PALETTE = 0x06
OAM_PALETTE = 0b111
FOLLOWER_COLORS = slice(2, 6) # the follower's two colors in its 4-color OBJ palette


def slot(game, struct):
	return F.object_field(game, struct, OBJECT_PALETTE) & OAM_PALETTE


def obj_palette(game, number):
	return game.peek("wOBPals1", number * 8, 8)


def visible_structs(game):
	return [s for s in range(F.NUM_OBJECT_STRUCTS) if F.object_field(game, s, F.OBJECT_SPRITE)]


def assert_everyone_in_their_own_colors(game):
	for struct in visible_structs(game):
		wanted = F.object_field(game, struct, F.OBJECT_PAL_INDEX)
		assert game.peek("wLoadedObjPal0", slot(game, struct)) == wanted, \
			"struct %d is drawn with slot %d, which doesn't hold its colors" % (struct, slot(game, struct))
	follower = obj_palette(game, slot(game, F.FOLLOWER_STRUCT))
	assert follower[FOLLOWER_COLORS] == F.follower_colors(game), "the follower is in someone else's colors"


def run_until(game, condition, frames=3000, press_every=30):
	for frame in range(frames):
		game.wait(1)
		if condition():
			return
		if "│" in game.screen_text() and frame % press_every == 0:
			game.pyboy.button("a", 3)
	raise AssertionError("timed out. The screen:\n" + game.screen_text())


def test_battle_tower_opponent_leaves_the_follower_alone(game):
	L.get_ready(game, radio=True, badges=False)
	F.start_warp(game, "BATTLE_TOWER_BATTLE_ROOM", 4, 7)
	# The opponent has walked in and is about to speak.
	run_until(game, lambda: "│" in game.screen_text() and game.peek("wScriptRunning") != 0
		and len(visible_structs(game)) >= 4, press_every=10**9)
	assert_everyone_in_their_own_colors(game)


def move_follower_colors(game, to_slot):
	"""Put the follower's colors in another OBJ palette slot, as happens when something else
	loaded first, and leave a different palette in its old one."""
	old = slot(game, F.FOLLOWER_STRUCT)
	follower_index = game.peek("wLoadedObjPal0", old)
	colors = obj_palette(game, old)
	for symbol in ("wOBPals1", "wOBPals2"):
		for i, value in enumerate(colors):
			game.poke(symbol, value, to_slot * 8 + i)
	game.poke("wLoadedObjPal0", follower_index, to_slot)
	other = F.object_field(game, 2, F.OBJECT_PAL_INDEX) # another object's color stands in
	game.poke("wLoadedObjPal0", other, old)
	for symbol in ("wOBPals1", "wOBPals2"):
		for i, value in enumerate(obj_palette(game, slot(game, 2))):
			game.poke(symbol, value, old * 8 + i)
	byte = F.object_field(game, F.FOLLOWER_STRUCT, OBJECT_PALETTE)
	game.poke("wObjectStructs", (byte & ~OAM_PALETTE) | to_slot,
		F.FOLLOWER_STRUCT * F.OBJECT_LENGTH + OBJECT_PALETTE)


def test_captains_cabin_scene_leaves_the_follower_alone(game):
	L.get_ready(game, radio=True, badges=False)
	for flag in ["EVENT_FAST_SHIP_CABINS_SE_SSE_CAPTAINS_CABIN_TWIN_1",
			"EVENT_FAST_SHIP_PASSENGERS_FIRST_TRIP", "EVENT_FAST_SHIP_PASSENGERS_EASTBOUND",
			"EVENT_FAST_SHIP_PASSENGERS_WESTBOUND"]:
		game.set_event_flag(flag)
	game.set_event_flag("EVENT_FAST_SHIP_CABINS_SE_SSE_CAPTAINS_CABIN_TWIN_2", False)
	game.set_event_flag("EVENT_FAST_SHIP_CABINS_SE_SSE_GENTLEMAN", False)
	game.warp("FAST_SHIP_CABINS_SE_SSE_CAPTAINS_CABIN", 2, 26) # below the granddaughter
	assert_everyone_in_their_own_colors(game)
	twin_color = F.object_field(game, 3, F.OBJECT_PAL_INDEX)
	move_follower_colors(game, 4)
	assert_everyone_in_their_own_colors(game)

	follower_byte = F.object_field(game, F.FOLLOWER_STRUCT, OBJECT_PALETTE)
	seen = set()

	def scene_reached_grandpa():
		seen.add(F.object_field(game, F.FOLLOWER_STRUCT, OBJECT_PALETTE))
		return "playing" in game.screen_text() # back in her grandpa's cabin

	game.press("up", after=20)
	game.press("a", after=20)
	run_until(game, scene_reached_grandpa)
	assert seen == {follower_byte}, "the scene rewrote the follower's palette byte: %s" % sorted(seen)
	assert_everyone_in_their_own_colors(game)
	twin = [s for s in visible_structs(game)
		if F.object_field(game, s, 1) == 4] # map object 4 is the granddaughter after the scene
	assert twin and F.object_field(game, twin[0], F.OBJECT_PAL_INDEX) == twin_color, \
		"the granddaughter should look as she did before"
