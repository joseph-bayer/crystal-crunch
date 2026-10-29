"""The Red Gyarados on the Lake of Rage keeps its vanilla look and movement (5f7146f06).

It had been moved onto a wandering-mon slot (SPRITE_OW_MON_1, standing still facing down), which
dropped its vanilla bobbing. It's back to SPRITE_GYARADOS with SPRITEMOVEDATA_WANDER and no radius,
so it stays on its tile and turns, in the NPC red."""

from harness import constants, overworld

GYARADOS = ("LakeOfRage", "LAKEOFRAGE_GYARADOS", (18, 22))
SHORE = (20, 26)

SPRITEMOVEDATA_WANDER = 0x02
PAL_OW_RED = 0x00
OBJECT_DIRECTION = 0x08
OBJECT_PAL_INDEX = 0x21

WATCH_FRAMES = 900
SEED = 0x0001


def test_red_gyarados_bobs_in_place(game):
	map_file, const, spot = GYARADOS
	game.set_event_flag("EVENT_LAKE_OF_RAGE_RED_GYARADOS", False)
	game.seed_random(SEED)
	game.warp("LAKE_OF_RAGE", *SHORE)

	struct = overworld.struct_for_object(game, map_file, const)
	assert struct is not None, "the Red Gyarados should be on the lake"
	sprites = constants._consts(constants.ROOT / "constants" / "sprite_constants.asm")
	assert overworld.struct_field(game, struct, overworld.OBJECT_SPRITE) == sprites["SPRITE_GYARADOS"]
	assert overworld.struct_field(game, struct, overworld.OBJECT_MOVEMENT_TYPE) == SPRITEMOVEDATA_WANDER
	assert overworld.struct_field(game, struct, OBJECT_PAL_INDEX) == PAL_OW_RED

	directions = set()
	for _ in range(0, WATCH_FRAMES, 5):
		game.wait(5)
		assert overworld.struct_position(game, struct) == spot, "the Red Gyarados left its tile"
		directions.add(overworld.struct_field(game, struct, OBJECT_DIRECTION))

	assert len(directions) > 1, "the Red Gyarados never turned"
