"""The legendaries' respawn after the Elite Four, run through the debug Scientist's
STORY -> LEGENDS -> RESPAWN NOW, which calls the same script the Hall of Fame does.

A one-off that was knocked out, run from or blacked out to comes back; a caught one never does. The
battle tests play each ending against Zapdos; the table tests set the flags a battle leaves behind
for every legendary that stands on a map, then check the map after the respawn."""

import pytest

from harness import legendaries as L

TIN_TOWER_1F_NOOP = 1 # its scene after the first Suicune battle


# Each ending of a battle, played for real against Zapdos

ZAPDOS_SPOT = ("ROUTE_10_NORTH", (4, 10), "down")


def zapdos_shown(game):
	L.enter(game, "ROUTE_10_NORTH", 4, 10)
	return game.object_shown("Route10North", "ROUTE10NORTH_ZAPDOS")


@pytest.mark.parametrize("ending", ["knock_out", "run_away", "black_out"])
def test_zapdos_not_caught_comes_back(game, ending):
	L.get_ready(game)
	L.meet(game, *ZAPDOS_SPOT)
	assert L.enemy_species(game) == L.species_index("ZAPDOS")
	getattr(L, ending)(game)

	assert game.event_flag("EVENT_FOUGHT_ZAPDOS")
	assert not game.event_flag("EVENT_CAUGHT_ZAPDOS")
	assert not zapdos_shown(game), "Zapdos should be gone until the respawn"

	L.respawn(game)
	assert zapdos_shown(game), "Zapdos should be back after the respawn"


def test_caught_zapdos_stays_gone(game):
	L.get_ready(game)
	L.meet(game, *ZAPDOS_SPOT)
	L.catch(game)
	assert game.event_flag("EVENT_CAUGHT_ZAPDOS")

	L.respawn(game)
	assert not zapdos_shown(game), "a caught Zapdos should not come back"


# Every legendary that stands on a map: the flags a knockout leaves, and a catch adds

# name: (map, map file, its objects, where to stand, flags a knockout leaves, the caught flag)
ONE_OFFS = {
	"Zapdos": ("ROUTE_10_NORTH", "Route10North", ["ROUTE10NORTH_ZAPDOS"], (4, 10),
		["EVENT_FOUGHT_ZAPDOS"], "EVENT_CAUGHT_ZAPDOS"),
	"Articuno": ("ROUTE_20", "Route20", ["ROUTE20_ARTICUNO"], (31, 9),
		["EVENT_FOUGHT_ARTICUNO"], "EVENT_CAUGHT_ARTICUNO"),
	"Moltres": ("VICTORY_ROAD", "VictoryRoad", ["VICTORYROAD_MOLTRES"], (17, 32),
		["EVENT_FOUGHT_MOLTRES"], "EVENT_CAUGHT_MOLTRES"),
	"Lugia": ("WHIRL_ISLAND_LUGIA_CHAMBER", "WhirlIslandLugiaChamber",
		["WHIRLISLANDLUGIACHAMBER_LUGIA"], (9, 13), ["EVENT_FOUGHT_LUGIA"], "EVENT_CAUGHT_LUGIA"),
	"Ho-Oh": ("TIN_TOWER_ROOF", "TinTowerRoof", ["TINTOWERROOF_HO_OH"], (9, 6),
		["EVENT_FOUGHT_HO_OH"], "EVENT_CAUGHT_HO_OH"),
	"Mewtwo": ("CERULEAN_CAVE_B1F", "CeruleanCaveB1F", ["CERULEANCAVEB1F_MEWTWO"], (27, 14),
		["EVENT_FOUGHT_MEWTWO", "EVENT_CERULEAN_CAVE_B1F_MEWTWO"], "EVENT_CAUGHT_MEWTWO"),
	"Suicune": ("TIN_TOWER_1F", "TinTower1F", ["TINTOWER1F_SUICUNE"], (9, 15),
		["EVENT_FOUGHT_SUICUNE", "EVENT_TIN_TOWER_1F_SUICUNE"], "EVENT_CAUGHT_SUICUNE"),
	"Sudowoodo": ("ROUTE_36", "Route36", ["ROUTE36_SUDOWOODO_RESPAWN"], (34, 9),
		["EVENT_FOUGHT_SUDOWOODO", "EVENT_ROUTE_36_SUDOWOODO"], "EVENT_CAUGHT_SUDOWOODO"),
	"Snorlax (Route 11)": ("ROUTE_11", "Route11", ["ROUTE11_BIG_SNORLAX"], (30, 13),
		["EVENT_FOUGHT_SNORLAX"], "EVENT_CAUGHT_SNORLAX"),
	"Snorlax (Apricorn Forest)": ("APRICORN_FOREST_CLEARING", "ApricornForestClearing",
		["APRICORNFORESTCLEARING_BIG_SNORLAX"], (8, 4),
		["EVENT_APRICORN_FOREST_CLEARING_SNORLAX"], "EVENT_CAUGHT_APRICORN_SNORLAX"),
	"Red Gyarados": ("LAKE_OF_RAGE", "LakeOfRage", ["LAKEOFRAGE_GYARADOS"], (20, 26),
		["EVENT_LAKE_OF_RAGE_RED_GYARADOS"], "EVENT_CAUGHT_RED_GYARADOS"),
	"Rocket Base Electrodes": ("TEAM_ROCKET_BASE_B2F", "TeamRocketBaseB2F",
		["TEAMROCKETBASEB2F_ELECTRODE%d" % n for n in range(1, 7)], (3, 14),
		["EVENT_CLEARED_ROCKET_HIDEOUT"] + ["EVENT_TEAM_ROCKET_BASE_B2F_ELECTRODE_%d" % n for n in (1, 2, 3)],
		"EVENT_CAUGHT_ROCKET_ELECTRODE"),
}


def shown(game, name):
	"""Which of a legendary's objects show when its map loads."""
	map_name, map_file, objects, spot, _, _ = ONE_OFFS[name]
	L.enter(game, map_name, *spot)
	return [game.object_shown(map_file, obj) for obj in objects]


def knocked_out(game, name):
	"""The flags a knockout leaves, and the map in the state it is after that battle."""
	L.get_ready(game, radio=False, wings=name in ("Lugia", "Ho-Oh"))
	for flag in ONE_OFFS[name][4]:
		game.set_event_flag(flag)
	if name == "Suicune":
		game.poke("wTinTower1FSceneID", TIN_TOWER_1F_NOOP)


@pytest.mark.parametrize("name", list(ONE_OFFS))
def test_knocked_out_comes_back(game, name):
	knocked_out(game, name)
	assert not any(shown(game, name)), "%s should be gone before the respawn" % name

	L.respawn(game)
	assert all(shown(game, name)), "%s should be back after the respawn" % name


@pytest.mark.parametrize("name", list(ONE_OFFS))
def test_caught_stays_gone(game, name):
	knocked_out(game, name)
	game.set_event_flag(ONE_OFFS[name][5])

	L.respawn(game)
	assert not any(shown(game, name)), "a caught %s should not come back" % name
