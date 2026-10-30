"""Bugs that showed with nobody following (wFollowerPartySlot 0, or a fainted follower), reported
after v1.0. With nobody following, the follower's object struct is empty: sprite 0, at map
coordinates 0, 0.

* Right-facing trainers never saw the player. The check for a follower standing between a trainer
  and the player compared only the column, so the empty struct's column 0 -- left of everything --
  counted as standing between the player and every trainer looking right. A hidden follower (Surf
  leaves its last position behind) could block a trainer the same way; now it never does.
* A heal (the Pokémon Center nurse, Mr. Pokémon) froze for about four seconds and garbled every
  sprite on screen until a menu or a warp reloaded them. appearfollower made the empty follower
  object appear, loading tiles for sprite 0 over everyone's, and then waited on a script delay of
  0, which wraps around to 256 frames.

The debug radio's party is Mewtwo, Mew, Lanturn, a beta Kingdra (level 50), Ditto and Ampharos."""

import pytest

from harness import alt_shiny
from harness import followers as F

# Trainers facing right, and where to walk up past them. Each sees 3 tiles.
JOEY = ("ROUTE_30", (4, 33), 28) # Youngster Joey at (2, 28)
ABE = ("VIOLET_GYM", (4, 14), 10) # Bird Keeper Abe at (2, 10)

# OW_* directions (constants/map_object_constants.asm)
OW_RIGHT = 3 << 2
OW_LEFT = 2 << 2
OW_UP = 1 << 2
FOLLOWER_INVISIBLE = 1 << 0 # wFollowerFlags
Z_FLAG = 0x80
MAP_BORDER = 4

# VRAM: sprite tiles are the first 256 tiles of each bank. The heal machine's balls and the
# monitor's light use bank 0 tiles $7c and up; nothing in the heal should touch anyone else's.
HEAL_MACHINE_FIRST_TILE = 0x7c
TILE_SIZE = 16

# A heal's last text, then the follower comes back out (or nobody does).
GOODBYE = "again."
GOODBYE_TO_DONE_FRAMES = 120


def follow(game, slot):
	F.take_radio_items(game)
	game.poke("wFollowerPartySlot", slot)


@pytest.mark.parametrize("follower_slot", [0, 1], ids=["nobody", "follower"])
@pytest.mark.parametrize("trainer", [JOEY, ABE], ids=["joey", "abe"])
def test_right_facing_trainer_sees_the_player(game, trainer, follower_slot):
	map_name, start, trainer_row = trainer
	follow(game, follower_slot)
	game.set_event_flag("EVENT_ROUTE_30_YOUNGSTER_JOEY", False)
	game.set_event_flag("EVENT_ROUTE_30_BATTLE", True) # past the Route 30 scene that hides Joey
	game.warp(map_name, *start)

	game.pyboy.button_press("up")
	for _ in range(300):
		game.wait(1)
		if game.peek("wScriptRunning") or game.position()[1] < trainer_row:
			break
	game.pyboy.button_release("up")

	assert game.peek("wScriptRunning"), "walked up past the trainer at %s without being seen" % (game.position(),)
	assert game.position()[1] == trainer_row, "stopped at %s, not in the trainer's row" % (game.position(),)


def between(game, follower_offset, direction, sprite=True, hidden=None):
	"""Run CheckFollowerBetweenObjectAndPlayer with the follower at the player's position plus
	follower_offset, for an object facing `direction`. True when it says the follower is between.
	hidden: "flags" hides it the follower system's way (wFollowerFlags), "object" by its object's
	own flag. Both are put back afterwards."""
	x, y = game.peek("wPlayerMapX"), game.peek("wPlayerMapY")
	base = F.FOLLOWER_STRUCT * F.OBJECT_LENGTH
	game.poke("wObjectStructs", x + follower_offset[0], base + F.OBJECT_MAP_X)
	game.poke("wObjectStructs", y + follower_offset[1], base + F.OBJECT_MAP_Y)
	if not sprite:
		game.poke("wObjectStructs", 0, base + F.OBJECT_SPRITE)
	follower_flags = game.peek("wFollowerFlags")
	object_flags = game.peek("wObjectStructs", base + F.OBJECT_FLAGS1)
	if hidden == "flags":
		game.poke("wFollowerFlags", follower_flags | FOLLOWER_INVISIBLE)
	elif hidden == "object":
		game.poke("wObjectStructs", object_flags | F.INVISIBLE, base + F.OBJECT_FLAGS1)
	result = alt_shiny.call(game, "CheckFollowerBetweenObjectAndPlayer", bc=direction)
	game.poke("wFollowerFlags", follower_flags)
	game.poke("wObjectStructs", object_flags, base + F.OBJECT_FLAGS1)
	return bool(result["f"] & Z_FLAG)


def test_follower_blocks_a_trainer_only_from_between(game):
	follow(game, 1)
	game.warp("ROUTE_30", 4, 33)
	game.wait(30)
	assert between(game, (-1, 0), OW_RIGHT), "a follower just left of the player stands between them and a trainer on the left"
	assert between(game, (1, 0), OW_LEFT)
	assert not between(game, (-1, 1), OW_RIGHT), "a follower below and to the left is not in the trainer's row"
	assert not between(game, (1, 0), OW_RIGHT), "a follower on the far side is not between"
	assert not between(game, (-1, 0), OW_RIGHT, sprite=False), "with nobody following, nothing stands between"


@pytest.mark.parametrize("hidden", ["flags", "object"])
def test_hidden_follower_never_blocks_a_trainer(game, hidden):
	"""Surf recalls the follower but leaves its last position behind; standing there hidden, it
	used to block a trainer whose line of sight ran through that tile."""
	follow(game, 1)
	game.warp("ROUTE_30", 4, 33)
	game.wait(30)
	assert between(game, (-1, 0), OW_RIGHT), "shown, it does block from between"
	assert not between(game, (-1, 0), OW_RIGHT, hidden=hidden), "a hidden follower blocked a trainer"
	assert not between(game, (0, 1), OW_UP, hidden=hidden), "a hidden follower blocked a trainer"


def sprite_tiles(game):
	tiles = {}
	for bank in (0, 1):
		for tile in range(256):
			if bank == 0 and tile >= HEAL_MACHINE_FIRST_TILE:
				continue
			start = 0x8000 + tile * TILE_SIZE
			tiles[bank, tile] = bytes(game.pyboy.memory[bank, start + i] for i in range(TILE_SIZE))
	return tiles


def heal_at_the_nurse(game):
	"""Talk to Cherrygrove's nurse from (3, 3) and say yes. Returns how many frames the script ran
	on after its goodbye."""
	game.press("up")
	game.press("a")
	goodbye_frame = None
	for frame in range(0, 3000, 10):
		game.wait(10)
		if F.script_done(game):
			break
		text = game.screen_text()
		if "YES" in text and "NO" in text:
			game.choose("YES")
		elif GOODBYE in text:
			goodbye_frame = goodbye_frame or frame
			game.press("a")
		elif "▼" in text:
			game.press("a")
	else:
		raise AssertionError("the nurse's script never finished. The screen:\n" + game.screen_text())
	assert goodbye_frame is not None, "never saw the nurse's goodbye"
	return frame - goodbye_frame


def changed_tiles(before, after, allowed=()):
	return sorted(key for key in before if before[key] != after[key] and key[1] not in allowed)


@pytest.mark.parametrize("follower_slot", [0, 1], ids=["nobody", "follower"])
def test_nurse_heal_leaves_sprites_alone(game, follower_slot):
	follow(game, follower_slot)
	game.warp("CHERRYGROVE_POKECENTER_1F", 3, 3)
	before = sprite_tiles(game)

	after_goodbye = heal_at_the_nurse(game)

	assert after_goodbye <= GOODBYE_TO_DONE_FRAMES, (
		"the script took %d frames to end after the goodbye" % after_goodbye)
	changed = changed_tiles(before, sprite_tiles(game))
	assert not changed, "the heal changed sprite tiles (bank, tile): %s" % changed[:20]


# The follower's own tiles: VRAM bank 0, $0c-$17 standing and $8c-$97 walking
FOLLOWER_TILES = set(range(0x0c, 0x18)) | set(range(0x8c, 0x98))


def test_fainted_follower_comes_back_after_a_heal(game):
	"""A fainted follower is left in its ball, with its object cleared the same way as for nobody.
	The heal brings it back, and only its own tiles change."""
	follow(game, 1)
	game.poke("wPartyMon1HP", 0, 0)
	game.poke("wPartyMon1HP", 0, 1)
	game.warp("CHERRYGROVE_POKECENTER_1F", 3, 3)
	assert F.object_field(game, F.FOLLOWER_STRUCT, F.OBJECT_SPRITE) == 0, "a fainted follower should stay in its ball"
	before = sprite_tiles(game)

	after_goodbye = heal_at_the_nurse(game)
	game.wait(60)

	assert after_goodbye <= GOODBYE_TO_DONE_FRAMES
	assert game.peek("wPartyMon1HP", 1), "the heal should have healed it"
	assert F.object_field(game, F.FOLLOWER_STRUCT, F.OBJECT_SPRITE), "the healed follower didn't come back out"
	assert not F.object_field(game, F.FOLLOWER_STRUCT, F.OBJECT_FLAGS1) & F.INVISIBLE, "the healed follower is hidden"
	changed = changed_tiles(before, sprite_tiles(game), FOLLOWER_TILES)
	assert not changed, "the heal changed other sprites' tiles (bank, tile): %s" % changed[:20]


@pytest.mark.parametrize("follower_slot", [0, 1], ids=["nobody", "follower"])
def test_script_moving_the_follower_finishes_with_nobody(game, follower_slot):
	"""getfollowerdirection reads the empty follower struct as LEFT, so with nobody following,
	Elm's aide in Violet's Pokémon Center sends a follower that isn't there around the player.
	The movement has to be skipped, not waited on."""
	follow(game, follower_slot)
	game.set_event_flag("EVENT_ELMS_AIDE_IN_VIOLET_POKEMON_CENTER", False)
	game.warp("VIOLET_POKECENTER_1F", 4, 4) # below the aide
	game.press("up")
	game.press("a")
	for _ in range(150):
		game.wait(10)
		if F.script_done(game):
			break
		text = game.screen_text()
		if "YES" in text and "NO" in text:
			game.choose("NO")
		elif "│" in text: # a text box is up
			game.press("a")
	assert F.script_done(game), "the aide's script never finished. The screen:\n" + game.screen_text()



def press_through_script(game, until=None, frames=3000, choose=lambda text: "YES"):
	"""Press A through a script's text, answering each YES/NO with choose(screen text), until the
	script ends or until(screen text) holds."""
	for _ in range(0, frames, 10):
		game.wait(10)
		text = game.screen_text()
		if until and until(text):
			return
		if F.script_done(game):
			assert not until, "the script ended early. The screen:\n" + text
			return
		if "YES" in text and "NO" in text:
			game.choose(choose(text))
		elif "│" in text: # a text box is up
			game.press("a")
	raise AssertionError("the script never got there. The screen:\n" + game.screen_text())


def pick_chikorita(game):
	game.warp("ELMS_LAB", 8, 4) # below Chikorita's ball
	before = sprite_tiles(game)
	game.press("up")
	game.press("a")
	press_through_script(game, choose=lambda text: "NO" if "received?" in text else "YES") # no nickname
	return set(changed_tiles(before, sprite_tiles(game), FOLLOWER_TILES))


def test_starter_follows_when_nobody_was_set(game):
	"""The first mon into an empty party follows you, whatever the follower choice says. With the
	choice left at nobody, Elm's starter used to stay in its ball while the scene made the empty
	follower object appear, garbling every sprite. Compared with a new game's choice (slot 1)."""
	game.poke("wElmsLabSceneID", 1) # SCENE_ELMSLAB_CANT_LEAVE: met Elm, the starters are out
	game.set_event_flag("EVENT_COP_IN_ELMS_LAB", True)
	game.set_event_flag("EVENT_CHIKORITA_POKEBALL_IN_ELMS_LAB", False)
	start = game.save_state()
	game.poke("wFollowerPartySlot", 1)
	as_a_new_game = pick_chikorita(game)

	game.load_state(start)
	game.poke("wFollowerPartySlot", 0)
	changed = pick_chikorita(game)

	assert game.peek("wPartyCount") == 1
	assert game.peek("wFollowerPartySlot") == 1, "the starter should follow"
	assert F.object_field(game, F.FOLLOWER_STRUCT, F.OBJECT_SPRITE), "the starter isn't out"
	extra = sorted(changed - as_a_new_game)
	assert not extra, "the scene changed other sprites' tiles (bank, tile): %s" % extra[:20]


def well_scene_changed_tiles(game):
	"""Talk to the beaten grunt in Slowpoke Well B1F, whose scene hides the follower, moves it and
	shows it again, and return the sprite tiles that changed by the time Kurt speaks (the scene
	ends by healing the party, which would bring a fainted follower back)."""
	game.warp("SLOWPOKE_WELL_B1F", 5, 3) # below the grunt
	before = sprite_tiles(game)
	game.press("up")
	game.press("a")
	press_through_script(game, until=lambda text: "│" in text and "KURT" in text)
	return set(changed_tiles(before, sprite_tiles(game), FOLLOWER_TILES))


@pytest.mark.parametrize("case", ["nobody", "fainted"])
def test_slowpoke_well_scene_with_no_follower_out(game, case):
	"""The Slowpoke Well scene shows the follower with plain appear FOLLOWER. With nobody out
	(none chosen, or the choice fainted) it made the empty follower object appear and garbled
	every sprite. Compared with the same scene with a follower out, nothing else may change."""
	follow(game, 1)
	game.set_event_flag("EVENT_BEAT_ROCKET_GRUNTM_1") # talking to him now plays the scene
	start = game.save_state()
	with_follower = well_scene_changed_tiles(game)

	game.load_state(start)
	if case == "nobody":
		game.poke("wFollowerPartySlot", 0)
	else:
		game.poke("wPartyMon1HP", 0, 0)
		game.poke("wPartyMon1HP", 0, 1)
	changed = well_scene_changed_tiles(game)

	assert F.object_field(game, F.FOLLOWER_STRUCT, F.OBJECT_SPRITE) == 0, "nobody should be out"
	extra = sorted(changed - with_follower)
	assert not extra, "the scene changed sprite tiles (bank, tile): %s" % extra[:20]
