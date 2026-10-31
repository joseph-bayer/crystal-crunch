"""Trainer levels that scale with the player's badges (LEVEL_FROM_BADGES).

A party level byte up to MAX_LEVEL is the level itself. Above it, the level is the base level for the
player's badge count (BadgeBaseLevels) plus the byte minus LEVEL_FROM_BADGES, kept within MIN_LEVEL to
MAX_LEVEL. These tests call LevelFromBadges directly with the badges set by hand."""

import re

import pytest

from harness import constants
from harness.alt_shiny import call

LEVEL_FROM_BADGES = 178
MAX_LEVEL = 100
MIN_LEVEL = 2
NUM_JOHTO_BADGES = 8


def base_levels():
	text = (constants.ROOT / "data" / "trainers" / "badge_base_levels.asm").read_text(encoding="utf-8")
	return [int(n) for n in re.findall(r"^\tdb +(\d+)", text, re.M)]


def set_badges(game, count):
	johto = min(count, NUM_JOHTO_BADGES)
	game.poke("wJohtoBadges", (1 << johto) - 1)
	game.poke("wKantoBadges", (1 << (count - johto)) - 1)


def level(game, byte):
	return call(game, "LevelFromBadges", a=byte)["a"]


def test_base_table_has_a_level_per_badge_count():
	levels = base_levels()
	assert len(levels) == 17
	assert levels == sorted(levels), "more badges should never lower the base"


@pytest.mark.parametrize("badges", range(17))
def test_offset_zero_is_the_base(game, badges):
	set_badges(game, badges)
	assert level(game, LEVEL_FROM_BADGES) == base_levels()[badges]


def test_offsets_add_to_the_base(game):
	set_badges(game, 4)
	base = base_levels()[4]
	assert level(game, LEVEL_FROM_BADGES + 3) == base + 3
	assert level(game, LEVEL_FROM_BADGES - 3) == base - 3


def test_plain_levels_pass_through(game):
	set_badges(game, 16)
	for byte in (MIN_LEVEL, 40, MAX_LEVEL):
		assert level(game, byte) == byte


def test_low_levels_stop_at_the_minimum(game):
	set_badges(game, 0)
	assert level(game, LEVEL_FROM_BADGES - 4) == MIN_LEVEL # 5 - 4 = 1
	assert level(game, LEVEL_FROM_BADGES - 77) == MIN_LEVEL # below 0


def test_high_levels_stop_at_the_maximum(game):
	set_badges(game, 16)
	assert level(game, LEVEL_FROM_BADGES + 77) == MAX_LEVEL


def test_registers_are_kept(game):
	set_badges(game, 4)
	result = call(game, "LevelFromBadges", a=LEVEL_FROM_BADGES, bc=0x1234, de=0x5678, hl=0x9abc)
	assert (result["bc"], result["de"], result["hl"]) == (0x1234, 0x5678, 0x9abc)


# The party reader: a plain party's levels come through as written.

READ_TRAINERS = [("FALKNER", "FALKNER1"), ("YOUNGSTER", "JOEY1"), ("HIKER", "ANTHONY2")]


@pytest.mark.parametrize("trainer_class, trainer", READ_TRAINERS)
def test_reader_keeps_written_levels(game, trainer_class, trainer):
	from harness import data
	from harness.forms import ot_party_field

	classes = [name for name, _ in data.trainer_classes()]
	written = [mon["level"] for mon in data.party(data.parties(), trainer_class, trainer)["mons"]]
	game.poke("wOtherTrainerClass", classes.index(trainer_class))
	game.poke("wOtherTrainerID", dict(data.trainer_classes())[trainer_class][trainer])
	call(game, "ReadTrainerParty")
	assert game.peek("wOTPartyCount") == len(written)
	assert [ot_party_field(game, slot, "Level") for slot in range(len(written))] == written
	call(game, "SetTrainerBattleLevel")
	assert game.peek("wCurPartyLevel") == written[0]


# M2: a LEVEL_FROM_BADGES entry names the final species it grows toward, and is shown as the stage
# of that line its level reaches. The expected stages come from the evolution data, read here.

STAND_IN = {"EVOLVE_ITEM": 40, "EVOLVE_TRADE": 40, "EVOLVE_HAPPINESS": 35}
BABIES = {"PICHU", "CLEFFA", "IGGLYBUFF", "TOGEPI", "TYROGUE", "SMOOCHUM", "ELEKID", "MAGBY"}
GROW_LEVELS = [5, 20, 30, 36, 40, 60]


def species_index():
	"""{species: index}, from the species list at the top of pokemon_constants.asm (the form
	constants after NUM_POKEMON reuse small numbers)."""
	result = {}
	value = 1
	text = (constants.ROOT / "constants" / "pokemon_constants.asm").read_text(encoding="utf-8")
	for line in text.split("DEF NUM_POKEMON")[0].splitlines():
		m = re.match(r"\s*const\s+(\w+)", line.split(";")[0])
		if m:
			result[m.group(1)] = value
			value += 1
	return result


def evolutions():
	"""{species: [(method, level it takes here, into)]}, from data/pokemon/evos_attacks_*.asm."""
	names = {index: name for name, index in species_index().items()}
	result = {}
	labels = {}
	order = []
	for part in ("kanto", "johto"):
		text = (constants.ROOT / "data" / "pokemon" / ("evos_attacks_%s.asm" % part)).read_text(encoding="utf-8")
		order += re.findall(r"^\tdw (\w+EvosAttacks)$", text, re.M)
		label = None
		for line in text.splitlines():
			m = re.match(r"\s*(\w+EvosAttacks):", line) # one (Houndour's) is indented
			if m:
				label = m.group(1)
				labels[label] = []
				continue
			code = line.split(";")[0].strip()
			if label is None or not code:
				continue
			if code == "db 0": # the end of the evolutions; the learnset follows
				label = None
				continue
			words = [w.strip() for w in code.split(None, 1)[-1].split(",")]
			if words[0].startswith("EVOLVE_"):
				method, into = words[0], words[-1]
				level = int(words[1]) if method in ("EVOLVE_LEVEL", "EVOLVE_STAT") else STAND_IN[method]
				labels[label].append((method, level, into))
	for index, label in enumerate(order, 1):
		result[names[index]] = labels[label]
	return result


def first_stages():
	text = (constants.ROOT / "data" / "pokemon" / "first_stages.asm").read_text(encoding="utf-8")
	names = {index: name for name, index in species_index().items()}
	stages = re.findall(r"^\tdw (\w+)", text, re.M)
	return {names[index]: stage for index, stage in enumerate(stages, 1)}


def expected_stage(target, level, evos, firsts):
	def leads_to(species):
		return species == target or any(into == target for _, _, into in evos.get(species, []))

	def next_stage(species):
		return next(((into, need) for _, need, into in evos.get(species, []) if leads_to(into)), None)

	stage = firsts[target]
	if stage in BABIES:
		step = next_stage(stage)
		if step:
			stage = step[0]
	while stage != target:
		step = next_stage(stage)
		if not step or step[1] > level:
			break
		stage = step[0]
	return stage


def grow(game, target, level):
	game.poke("wCurPartyLevel", level)
	result = call(game, "GrowToLevel", de=species_index()[target])
	return result["de"]


def test_named_lines(game):
	index = species_index()
	cases = [
		("GOLEM", 10, "GEODUDE"), ("GOLEM", 25, "GRAVELER"), ("GOLEM", 37, "GRAVELER"), ("GOLEM", 38, "GOLEM"),
		("RAICHU", 5, "PIKACHU"), ("RAICHU", 39, "PIKACHU"), ("RAICHU", 40, "RAICHU"),
		("POLITOED", 40, "POLITOED"), ("POLIWRATH", 40, "POLIWRATH"),
		("CROBAT", 34, "GOLBAT"), ("CROBAT", 35, "CROBAT"),
		("HITMONTOP", 5, "HITMONTOP"), ("TAUROS", 5, "TAUROS"), ("PICHU", 50, "PICHU"),
	]
	for target, level, stage in cases:
		assert grow(game, target, level) == index[stage], "%s at %d should be %s" % (target, level, stage)


def test_every_species_matches_the_evolution_data(game):
	index = species_index()
	names = {i: n for n, i in index.items()}
	evos = evolutions()
	firsts = first_stages()
	wrong = []
	for target in sorted(firsts, key=index.get):
		for level in GROW_LEVELS:
			got = grow(game, target, level)
			want = expected_stage(target, level, evos, firsts)
			if got != index[want]:
				wrong.append((target, level, names.get(got, got), want))
	assert not wrong, "%d wrong, e.g. %s" % (len(wrong), wrong[:10])


def test_reader_grows_a_scaled_party(game):
	"""A party entry with a LEVEL_FROM_BADGES level, read through ReadTrainerPartyPieces from WRAM:
	its level comes from the badges and its species grows to match; a plain entry stays as written."""
	index = species_index()
	set_badges(game, 4) # base 25
	# level, species (dw), then the terminator: a scaled Golem (25 - 1 = 24) and a plain level 10
	# Golem (named as written)
	golem = index["GOLEM"]
	party = [LEVEL_FROM_BADGES - 1, golem & 0xff, golem >> 8, 10, golem & 0xff, golem >> 8, 0xff]
	# In the tilemap, which reading a party leaves alone (TryAddMonToParty reuses the string buffers)
	_, tilemap = game._address("wTilemap")
	start = tilemap + 0x100
	for i, byte in enumerate(party):
		game.poke("wTilemap", byte, 0x100 + i)
	from harness.forms import ot_party_field
	game.poke("wOtherTrainerType", 0) # TRAINERTYPE_NORMAL
	game.poke("wOTPartyCount", 0)
	game.poke("wOTPartySpecies", 0xff)
	game.poke("wTrainerGroupBank", 0)
	call(game, "ReadTrainerPartyPieces", de=start)
	assert game.peek("wOTPartyCount") == 2
	assert [ot_party_field(game, slot, "Level") for slot in range(2)] == [24, 10]
	from harness.followers import index_of_id
	# Geodude evolves at 25, so the level 24 scaled one is still a Geodude
	assert [index_of_id(game, game.peek("wOTPartySpecies", slot)) for slot in range(2)] == [index["GEODUDE"], golem]


# M3: the scaled parties. Route 46's first fights and Mt. Mortar's, each scaled whole.

SCALED_PARTIES = [("CAMPER", "TED"), ("PICNICKER", "ERIN1"), ("HIKER", "BAILEY"),
	("POKEMANIAC", "MILLER"), ("SUPER_NERD", "MARKUS"), ("BLACKBELT_T", "KIYO"), ("SUPER_NERD", "HUGH")]


def scaled_parties():
	"""[(class, trainer)] for every party with a LEVEL_FROM_BADGES level."""
	from harness import data
	groups = data.parties()
	labels = data.trainer_group_labels()
	found = []
	for trainer_class, members in data.trainer_classes():
		if trainer_class not in labels:
			continue
		names = {number: trainer for trainer, number in members.items()}
		for number, party in enumerate(groups[labels[trainer_class]], 1):
			if any(isinstance(mon["level"], data.ScaledLevel) for mon in party["mons"]):
				found.append((trainer_class, names.get(number, number)))
	return found


def trainer_map(trainer_class, trainer):
	"""The map constant of the map whose script fights this trainer."""
	from harness import data
	for path, battles in data.trainer_battles().items():
		if (trainer_class, trainer) in battles:
			return data.map_constants_by_file()[path.split("/")[-1][:-4]]
	raise AssertionError("no map fights %s %s" % (trainer_class, trainer))


def go_to_map(game, map_name):
	"""Set the current map, as LevelFromBadges reads it for the badge cap."""
	group, number = constants.maps()[map_name]
	game.poke("wMapGroup", group)
	game.poke("wMapNumber", number)


def test_only_the_agreed_parties_scale():
	assert sorted(scaled_parties()) == sorted(SCALED_PARTIES)


@pytest.mark.parametrize("trainer_class, trainer", SCALED_PARTIES)
def test_scaled_parties_are_scaled_whole(trainer_class, trainer):
	from harness import data
	mons = data.party(data.parties(), trainer_class, trainer)["mons"]
	assert all(isinstance(mon["level"], data.ScaledLevel) for mon in mons)


@pytest.mark.parametrize("badges", [0, 4, 7, 8, 16])
@pytest.mark.parametrize("trainer_class, trainer", SCALED_PARTIES)
def test_reader_scales_the_party(game, trainer_class, trainer, badges):
	"""Each scaled party, read on its map at a badge count: its levels come from the badges (no more
	than the map's cap), its species grow with them, and the battle intro gets the first one's
	level."""
	from harness import data
	from harness.followers import index_of_id
	from harness.forms import ot_party_field

	index = species_index()
	evos = evolutions()
	firsts = first_stages()
	mons = data.party(data.parties(), trainer_class, trainer)["mons"]
	map_name = trainer_map(trainer_class, trainer)
	cap = data.badge_scaling_caps().get(map_name)
	levels = [data.level_at(mon["level"], badges, cap) for mon in mons]
	stages = [index[expected_stage(mon["species"], level, evos, firsts)] for mon, level in zip(mons, levels)]
	set_badges(game, badges)
	go_to_map(game, map_name)
	classes = [name for name, _ in data.trainer_classes()]
	game.poke("wOtherTrainerClass", classes.index(trainer_class))
	game.poke("wOtherTrainerID", dict(data.trainer_classes())[trainer_class][trainer])
	call(game, "ReadTrainerParty")
	assert game.peek("wOTPartyCount") == len(mons)
	assert [ot_party_field(game, slot, "Level") for slot in range(len(mons))] == levels
	assert [index_of_id(game, game.peek("wOTPartySpecies", slot)) for slot in range(len(mons))] == stages
	call(game, "SetTrainerBattleLevel")
	assert game.peek("wCurPartyLevel") == levels[0]


def test_route_46_after_morty():
	"""The report's case: at 4 badges Route 46 is no longer level 38-40."""
	from harness import data
	groups = data.parties()
	for trainer_class, trainer in SCALED_PARTIES[:3]:
		for mon in data.party(groups, trainer_class, trainer)["mons"]:
			assert data.level_at(mon["level"], 4) <= 30


# M4: Mt. Mortar's wild Pokémon. A slot's level scales the same way; its species stays as written.
# 1F and B1F have their old levels at 4 badges, when they open; 2F, behind Waterfall, has its old
# levels plus 8 at 8 badges. Route 46's wild Pokémon don't scale: its grass is the early patch off
# Route 29, and stays level 2-3.

SCALED_WILD_MAPS = {"MOUNT_MORTAR_1F_OUTSIDE": 4, "MOUNT_MORTAR_1F_INSIDE": 4,
	"MOUNT_MORTAR_B1F": 4, "MOUNT_MORTAR_2F_INSIDE": 8}
MORN_F, DAY_F, NITE_F, EVE_F = range(4)
NUM_GRASSMON = 7
NUM_OW_WILDMON = 4
OW_MON_ENCOUNTER_LENGTH = 10
OW_MON_LEVEL = 3
NUM_OW_MON_SLOTS = 4


def test_only_the_agreed_wild_maps_scale():
	from harness import data
	for kind in data.WILD_TABLES:
		for map_name, rows in data.wild_tables(kind):
			scaled = [isinstance(level, data.ScaledLevel) for level, _ in rows]
			if map_name in SCALED_WILD_MAPS:
				assert all(scaled), "%s %s should be scaled whole" % (kind, map_name)
			else:
				assert not any(scaled), "%s %s shouldn't scale" % (kind, map_name)


def test_wild_levels_when_each_area_opens():
	from harness import data
	opening = {"MOUNT_MORTAR_1F_OUTSIDE": (15, 22), "MOUNT_MORTAR_1F_INSIDE": (20, 22),
		"MOUNT_MORTAR_B1F": (15, 23), "MOUNT_MORTAR_2F_INSIDE": (28, 40)}
	for kind in data.WILD_TABLES:
		for map_name, rows in data.wild_tables(kind):
			if map_name in opening:
				low, high = opening[map_name]
				levels = {data.level_at(level, SCALED_WILD_MAPS[map_name]) for level, _ in rows}
				assert low <= min(levels) and max(levels) <= high, (kind, map_name, sorted(levels))


def time_of_day(game):
	time = game.peek("wTimeOfDay")
	return NITE_F if time == EVE_F else time


def possible(kind, map_name, per_time, time, badges):
	"""{(level, species index)} the map's tables of one kind can give at a time of day."""
	from harness import data
	index = species_index()
	result = set()
	for name, rows in data.wild_tables(kind):
		if name != map_name:
			continue
		if len(rows) == 3 * per_time:
			rows = rows[time * per_time:(time + 1) * per_time]
		cap = data.badge_scaling_caps().get(map_name)
		result |= {(data.level_at(level, badges, cap), index[species]) for level, species in rows}
	return result


WILD_SPOTS = {"ROUTE_46": (7, 32), "MOUNT_MORTAR_1F_INSIDE": (11, 46), "ROUTE_29": None}


@pytest.mark.parametrize("map_name, badges", [("MOUNT_MORTAR_1F_INSIDE", 4),
	("MOUNT_MORTAR_1F_INSIDE", 8), ("MOUNT_MORTAR_1F_INSIDE", 16), ("ROUTE_46", 16), ("ROUTE_29", 16)])
def test_grass_encounters_scale(game, map_name, badges):
	"""ChooseWildEncounter on a scaled map gives a slot's species at its level for the badges; on
	Route 46 and Route 29, which don't scale, the level as written even with every badge."""
	from harness import constants
	from harness.followers import index_of_id

	set_badges(game, badges)
	group, number = constants.maps()[map_name]
	game.poke("wMapGroup", group)
	game.poke("wMapNumber", number)
	expected = possible("grass", map_name, NUM_GRASSMON, time_of_day(game), badges)
	met = set()
	for _ in range(20):
		call(game, "ChooseWildEncounter")
		met.add((game.peek("wCurPartyLevel"), index_of_id(game, game.peek("wTempWildMonSpecies"))))
	assert met <= expected, "met %s, expected some of %s" % (sorted(met), sorted(expected))


@pytest.mark.parametrize("map_name, badges", [("MOUNT_MORTAR_1F_INSIDE", 4),
	("MOUNT_MORTAR_1F_INSIDE", 16), ("ROUTE_46", 16)])
def test_wanderers_scale(game, map_name, badges):
	"""The wandering mon rolled on arriving have their roster row's level for the badges."""
	set_badges(game, badges)
	game.warp(map_name, *WILD_SPOTS[map_name])
	expected = possible("wanderers", map_name, NUM_OW_WILDMON, time_of_day(game), badges)
	met = set()
	for slot in range(NUM_OW_MON_SLOTS):
		low, high, _, level = game.peek("wOverworldMonEncounters", slot * OW_MON_ENCOUNTER_LENGTH, 4)
		if low | high << 8:
			met.add((level, low | high << 8))
	assert met, "no wanderer rolled"
	assert met <= expected, "met %s, expected some of %s" % (sorted(met), sorted(expected))


def test_scaling_stays_in_its_tables():
	"""Only the parties and the grass, water and wanderer tables use LEVEL_FROM_BADGES: fishing,
	headbutt trees, swarms, populations and the rest keep their written levels."""
	import glob
	allowed = {"data/trainers/parties.asm", "data/wild/johto_grass.asm", "data/wild/johto_water.asm",
		"data/wild/overworld_mons.asm"}
	users = set()
	for path in glob.glob(str(constants.ROOT / "data" / "**" / "*.asm"), recursive=True) \
			+ glob.glob(str(constants.ROOT / "maps" / "*.asm")):
		lines = open(path, encoding="utf-8").read().splitlines()
		if any("LEVEL_FROM_BADGES" in line.split(";")[0] for line in lines):
			users.add(path.replace("\\", "/").split(str(constants.ROOT).replace("\\", "/") + "/")[1])
	assert users == allowed


@pytest.mark.parametrize("badges", [4, 16])
def test_surfing_encounters_scale(game, badges):
	"""On Mt. Mortar's water a slot's scaled level gets Surf's random +0 to +4 on top."""
	from harness.followers import index_of_id

	set_badges(game, badges)
	group, number = constants.maps()["MOUNT_MORTAR_1F_OUTSIDE"]
	game.poke("wMapGroup", group)
	game.poke("wMapNumber", number)
	game.poke("wPlayerTileCollision", 0x29) # COLL_WATER
	slots = possible("water", "MOUNT_MORTAR_1F_OUTSIDE", 3, 0, badges)
	expected = {(level + bonus, species) for level, species in slots for bonus in range(5)}
	met = set()
	for _ in range(30):
		call(game, "ChooseWildEncounter")
		met.add((game.peek("wCurPartyLevel"), index_of_id(game, game.peek("wTempWildMonSpecies"))))
	assert met <= expected, "met %s, expected some of %s" % (sorted(met), sorted(expected))
	assert met - slots, "Surf's bonus never showed: %s" % sorted(met)


# The battle intro: the screen flashes the "stronger" way when the trainer's first Pokémon is more
# than 3 levels above your first healthy one, so it needs the scaled level, not the raw byte.

BATTLETRANSITION_NO_CAVE = 0x10
BATTLETRANSITION_NO_CAVE_STRONGER = 0x18


@pytest.mark.parametrize("badges, lead, stronger", [(4, 40, False), (4, 20, True), (8, 40, True),
	(0, 5, False)])
def test_battle_intro_uses_the_scaled_level(game, badges, lead, stronger):
	"""Camper Ted (+3): 28 at 4 badges, 48 at 8, 8 at none."""
	from harness import data
	set_badges(game, badges)
	classes = [name for name, _ in data.trainer_classes()]
	game.poke("wOtherTrainerClass", classes.index("CAMPER"))
	game.poke("wOtherTrainerID", dict(data.trainer_classes())["CAMPER"]["TED"])
	game.poke("wPartyMon1HP", 0)
	game.poke("wPartyMon1HP", 50, 1)
	game.poke("wPartyMon1Level", lead)
	game.poke("wEnvironment", data.global_constants().values["ROUTE"])
	call(game, "StartTrainerBattle_DetermineWhichAnimation")
	want = BATTLETRANSITION_NO_CAVE_STRONGER if stronger else BATTLETRANSITION_NO_CAVE
	assert game.peek("wJumptableIndex") == want


# The Open League: a seat battle replaces every level, scaled or not, with the seat's.

@pytest.mark.parametrize("seat, trainer_class, trainer", [(0, "HIKER", "BAILEY"), (4, "CHAMPION", "LANCE")])
def test_open_league_seats_set_their_own_levels(game, seat, trainer_class, trainer):
	from harness import data
	from harness.forms import ot_party_field
	values = data.global_constants().values
	if seat == values["E4_SEAT_CHAMPION"]:
		base, offsets = values["E4_CHAMPION_LEVEL"], [0, 1, 2, 1, 2, 4]
	else:
		base, offsets = values["E4_SEAT_%d_LEVEL" % (seat + 1)], [0, 1, 0, 1, 2]
	mons = data.party(data.parties(), trainer_class, trainer)["mons"]
	want = [base + offset for offset in offsets][:len(mons)]
	set_badges(game, 4)
	classes = [name for name, _ in data.trainer_classes()]
	game.poke("wOtherTrainerClass", classes.index(trainer_class))
	game.poke("wOtherTrainerID", dict(data.trainer_classes())[trainer_class][trainer])
	game.poke("wEliteFourSeatBattle", seat + 1)
	call(game, "ReadTrainerParty")
	game.poke("wEliteFourSeatBattle", 0)
	assert [ot_party_field(game, slot, "Level") for slot in range(len(want))] == want



# M5: a badge cap per map. A capped map's scaled levels stop rising at its cap; others don't.

AGREED_CAPS = {"ROUTE_46": 7, "MOUNT_MORTAR_1F_OUTSIDE": 7, "MOUNT_MORTAR_1F_INSIDE": 7,
	"MOUNT_MORTAR_B1F": 7, "MOUNT_MORTAR_2F_INSIDE": 8}


def test_the_agreed_caps():
	from harness import data
	assert data.badge_scaling_caps() == AGREED_CAPS


def test_every_scaled_map_has_a_cap():
	"""Every map with scaled trainers or wild Pokémon is capped."""
	from harness import data
	maps = {trainer_map(*party) for party in SCALED_PARTIES} | set(SCALED_WILD_MAPS)
	assert maps <= set(data.badge_scaling_caps())


@pytest.mark.parametrize("map_name", sorted(AGREED_CAPS))
@pytest.mark.parametrize("badges", [6, 7, 8, 16])
def test_capped_maps_stop_rising(game, map_name, badges):
	set_badges(game, badges)
	go_to_map(game, map_name)
	cap = AGREED_CAPS[map_name]
	assert level(game, LEVEL_FROM_BADGES) == base_levels()[min(badges, cap)]


def test_uncapped_maps_keep_rising(game):
	set_badges(game, 16)
	go_to_map(game, "ROUTE_29")
	assert level(game, LEVEL_FROM_BADGES) == base_levels()[16]
