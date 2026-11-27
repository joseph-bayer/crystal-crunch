"""Red/Blue forms (and the beta forms that count as them) have one Special stat and no gender.

Their Sp.Atk and Sp.Def both use one Special base (the species' Red/Blue Special, or the beta
form's own), one DV and one EV pool, so the two stored stats are always equal; the stats
screen shows one SPECIAL. Most of these call the ROM's own routines directly
(see harness.alt_shiny.call)."""

import re

import pytest

from harness import alt_shiny as A
from harness import constants
from harness.forms import (form_constant, ot_party_field, party_field, party_struct_length,
	set_party_field, shorten_party, take_radio_items)

CARRY = 0x10
GENGAR_SPECIAL = 130 # Red/Blue; the plain form's Sp.Atk/Sp.Def are 130/75
LEVEL = 50
MAX_EV = 252


def rb_rows():
	"""[(species, form const, special)] from data/pokemon/rb_forms.asm; special 0 means the
	species' Red/Blue Special."""
	text = (constants.ROOT / "data" / "pokemon" / "rb_forms.asm").read_text(encoding="utf-8")
	return [(m.group(1), m.group(2), int(m.group(3)))
		for m in re.finditer(r"^\trb_form (\w+),\s*(\w+),\s*(\d+)", text, re.M)]


def kanto_specials():
	text = (constants.ROOT / "data" / "pokemon" / "gen1_base_special.asm").read_text(encoding="utf-8")
	return [int(v) for v in re.findall(r"^\tdb\s+(\d+)", text, re.M)]


def word(game, symbol, offset=0):
	return game.peek(symbol, offset) << 8 | game.peek(symbol, offset + 1)


def party_stat(game, slot, stat):
	length = game._address("wPartyMon2")[1] - game._address("wPartyMon1")[1]
	return word(game, "wPartyMon1" + stat, slot * length)


def ot_party_stat(game, slot, stat):
	length = game._address("wOTPartyMon2")[1] - game._address("wOTPartyMon1")[1]
	return word(game, "wOTPartyMon1" + stat, slot * length)


def special_rb_stat(base, dvs_low, ev, level):
	"""Gen 2's stat formula for Sp.Atk/Sp.Def, with the Special DV (low nibble of the second DV byte)."""
	return ((base + (dvs_low & 0xf)) * 2 + ev // 4) * level // 100 + 5


NAMES = 0x200 # in wTilemap: the nickname and OT pointers, then the names


def give_poke(game, species, form, level=LEVEL):
	"""GivePoke, as the givepoke command calls it with a nickname and OT (so it asks nothing).
	The pointers and names sit in WRAM, which reads the same whatever wScriptBank is."""
	_, tilemap = game._address("wTilemap")
	base = tilemap + NAMES
	name = base + 4
	text = [0x80, 0x50, 0] # "A@", then the byte the OT loop reads past its "@"
	data = [name & 0xff, name >> 8, name & 0xff, name >> 8] + text
	for i, byte in enumerate(data):
		game.poke("wTilemap", byte, NAMES + i)
	game.poke("wScriptBank", 1)
	game.poke("wCurPartySpecies", A.species_id(game, species))
	game.poke("wCurPartyLevel", level)
	game.poke("wCurItem", 0)
	game.poke("wForm", form)
	A.call(game, "GivePoke", bc=0x0100, de=base)
	return game.peek("wPartyCount") - 1


@pytest.mark.parametrize("species, form, special", rb_rows())
def test_rb_special_lookup(game, species, form, special):
	specials = kanto_specials()
	want = special or specials[A.pokemon_index(species) - 1]
	result = A.call(game, "GetRBFormSpecial", a=A.species_id(game, species), bc=form_constant(form))
	assert result["f"] & CARRY, "%s %s should be an RB form" % (species, form)
	assert result["a"] == want
	plain = A.call(game, "GetRBFormSpecial", a=A.species_id(game, species), bc=0)
	assert not plain["f"] & CARRY, "plain %s isn't an RB form" % species


def test_rb_table_covers_every_rb_and_beta_form():
	text = (constants.ROOT / "constants" / "pokemon_constants.asm").read_text(encoding="utf-8")
	forms = set(re.findall(r"const (\w+_(?:RB|BETA)_FORM)\b", text))
	assert {form for _, form, _ in rb_rows()} == forms


def test_givepoke_rb_form_has_one_special(game):
	slot = give_poke(game, "GENGAR", form_constant("GENGAR_RB_FORM"))
	assert party_field(game, slot, "Form") == form_constant("GENGAR_RB_FORM")
	spatk = party_stat(game, slot, "SpclAtk")
	assert spatk == party_stat(game, slot, "SpclDef")
	length = game._address("wPartyMon2")[1] - game._address("wPartyMon1")[1]
	dvs_low = game.peek("wPartyMon1DVs", 1 + slot * length)
	assert spatk == special_rb_stat(GENGAR_SPECIAL, dvs_low, 0, LEVEL)


def test_givepoke_plain_form_is_unchanged(game):
	slot = give_poke(game, "GENGAR", 0)
	assert party_stat(game, slot, "SpclAtk") != party_stat(game, slot, "SpclDef")


def read_party(game, trainer_type, party, stale_form=0):
	"""Read a party written in WRAM through ReadTrainerPartyPieces."""
	start = 0x100
	_, tilemap = game._address("wTilemap")
	for i, byte in enumerate(party + [0xff]):
		game.poke("wTilemap", byte, start + i)
	game.poke("wOtherTrainerType", trainer_type)
	game.poke("wOTPartyCount", 0)
	game.poke("wOTPartySpecies", 0xff)
	game.poke("wTrainerGroupBank", 0)
	game.poke("wEnemyMonForm", stale_form)
	A.call(game, "ReadTrainerPartyPieces", de=tilemap + start)


def test_trainer_rb_form_has_one_special(game):
	gengar = A.pokemon_index("GENGAR")
	rb = form_constant("GENGAR_RB_FORM")
	trainer_form = 1 << 2 # TRAINERTYPE_FORM
	read_party(game, trainer_form, [LEVEL, gengar & 0xff, gengar >> 8, rb, LEVEL, gengar & 0xff, gengar >> 8, 0])
	assert game.peek("wOTPartyCount") == 2
	assert ot_party_field(game, 0, "Form") == rb
	assert ot_party_stat(game, 0, "SpclAtk") == ot_party_stat(game, 0, "SpclDef")
	assert ot_party_field(game, 1, "Form") == 0
	assert ot_party_stat(game, 1, "SpclAtk") != ot_party_stat(game, 1, "SpclDef")


def test_plain_trainer_mon_after_an_rb_battle(game):
	"""wEnemyMonForm still holds the last battle's form; a party without forms is plain."""
	gengar = A.pokemon_index("GENGAR")
	read_party(game, 0, [LEVEL, gengar & 0xff, gengar >> 8], stale_form=form_constant("GENGAR_RB_FORM"))
	assert ot_party_field(game, 0, "Form") == 0
	assert ot_party_stat(game, 0, "SpclAtk") != ot_party_stat(game, 0, "SpclDef")


def wild_stats(game, form):
	species = A.species_id(game, "GENGAR")
	game.poke("wCurSpecies", species)
	A.call(game, "GetBaseData")
	game.poke("wEnemyMonForm", form)
	game.poke("wEnemyMonDVs", 0xff)
	game.poke("wEnemyMonDVs", 0xff, 1)
	game.poke("wCurPartyLevel", LEVEL)
	_, dvs = game._address("wEnemyMonDVs")
	_, maxhp = game._address("wEnemyMonMaxHP")
	stand_in = dvs - (game._address("wPartyMon1DVs")[1] - game._address("wPartyMon1EVs")[1] + 1)
	A.call(game, "CalcMonStats", bc=0, de=maxhp, hl=stand_in)
	return word(game, "wEnemyMonSpclAtk"), word(game, "wEnemyMonSpclDef")


def test_wild_rb_form_has_one_special(game):
	spatk, spdef = wild_stats(game, form_constant("GENGAR_RB_FORM"))
	assert spatk == spdef == special_rb_stat(GENGAR_SPECIAL, 0xff, 0, LEVEL)
	spatk, spdef = wild_stats(game, 0)
	assert spatk != spdef


def recalc_party_stats(game, slot):
	game.poke("wCurPartyMon", slot)
	game.poke("wCurSpecies", party_field(game, slot, "Species"))
	A.call(game, "GetBaseData")
	game.poke("wCurPartyLevel", party_field(game, slot, "Level"))
	A.call(game, "UpdateStatsAfterItem")


def test_split_special_evs_merge_to_the_higher(game):
	"""An RB mon from an old save may hold two Special EVs: stats recalculation makes them one."""
	slot = give_poke(game, "GENGAR", form_constant("GENGAR_RB_FORM"))
	set_party_field(game, slot, "SpclAtkEV", 40)
	set_party_field(game, slot, "SpclDefEV", 100)
	recalc_party_stats(game, slot)
	assert party_field(game, slot, "SpclAtkEV") == party_field(game, slot, "SpclDefEV") == 100
	assert party_stat(game, slot, "SpclAtk") == party_stat(game, slot, "SpclDef")


def test_plain_special_evs_stay_split(game):
	slot = give_poke(game, "GENGAR", 0)
	set_party_field(game, slot, "SpclAtkEV", 40)
	set_party_field(game, slot, "SpclDefEV", 100)
	recalc_party_stats(game, slot)
	assert (party_field(game, slot, "SpclAtkEV"), party_field(game, slot, "SpclDefEV")) == (40, 100)


def pool_battle_evs(game, slot, sat, sdf, yields, pokerus=False):
	"""The EVs after PoolRBFormBattleEVs, given the EVs the gain loop left and the defeated
	species' Sp.Atk/Sp.Def yields (%ttff0000)."""
	set_party_field(game, slot, "SpclAtkEV", sat)
	set_party_field(game, slot, "SpclDefEV", sdf)
	game.poke("wBaseSpAtkSpDefEVs", yields)
	length = game._address("wPartyMon2")[1] - game._address("wPartyMon1")[1]
	_, past_evs = game._address("wPartyMon1HPLevel")
	A.call(game, "PoolRBFormBattleEVs", de=int(pokerus), hl=past_evs + slot * length)
	return party_field(game, slot, "SpclAtkEV"), party_field(game, slot, "SpclDefEV")


def test_battle_evs_feed_one_pool(game):
	slot = give_poke(game, "GENGAR", form_constant("GENGAR_RB_FORM"))
	# Sp.Atk yield 1, Sp.Def yield 2: a pool of 10 became 11 and 12 in the gain loop
	assert pool_battle_evs(game, slot, 11, 12, 0b01100000) == (13, 13)
	# Pokérus doubles the Sp.Def yield too
	assert pool_battle_evs(game, slot, 12, 14, 0b01100000, pokerus=True) == (16, 16)
	assert pool_battle_evs(game, slot, MAX_EV, MAX_EV, 0b11110000) == (MAX_EV, MAX_EV)
	assert pool_battle_evs(game, slot, 250, 251, 0b01100000) == (MAX_EV, MAX_EV)


def test_battle_evs_of_a_plain_mon_stay_split(game):
	slot = give_poke(game, "GENGAR", 0)
	assert pool_battle_evs(game, slot, 11, 12, 0b01100000) == (11, 12)


def gender(game, mon_type):
	game.poke("wMonType", mon_type)
	return A.call(game, "GetGender")


def test_rb_forms_have_no_gender(game):
	slot = give_poke(game, "NIDORAN_M", form_constant("NIDORAN_M_RB_FORM"))
	game.poke("wCurPartyMon", slot)
	game.poke("wCurPartySpecies", party_field(game, slot, "Species"))
	assert gender(game, 0)["f"] & CARRY, "a party RB form is genderless"
	set_party_field(game, slot, "Form", 0)
	assert not gender(game, 0)["f"] & CARRY, "a plain Nidoran♂ is male"

	# wTempMon (TEMPMON = 3) and a wild mon (WILDMON = 4)
	game.poke("wTempMonForm", form_constant("NIDORAN_M_RB_FORM"))
	assert gender(game, 3)["f"] & CARRY
	game.poke("wTempMonForm", 0)
	assert not gender(game, 3)["f"] & CARRY
	game.poke("wEnemyMonForm", form_constant("NIDORAN_M_RB_FORM"))
	assert gender(game, 4)["f"] & CARRY
	game.poke("wEnemyMonForm", 0)
	assert not gender(game, 4)["f"] & CARRY


@pytest.mark.parametrize("form, rows", [(0, ["SPCL.ATK", "SPCL.DEF"]), ("GENGAR_RB_FORM", ["SPECIAL"])])
def test_stats_print_one_special(game, form, rows):
	slot = give_poke(game, "GENGAR", form_constant(form) if form else 0)
	game.poke("wTempMonSpecies", party_field(game, slot, "Species"))
	game.poke("wTempMonForm", party_field(game, slot, "Form"))
	_, tilemap = game._address("wTilemap")
	for i in range(18 * 20):
		game.poke("wTilemap", 0x7f, i) # " "
	A.call(game, "PrintTempMonStats", bc=8, hl=tilemap)
	text = game.screen_text()
	for row in rows:
		assert row in text
	if form:
		assert "SPCL" not in text


def set_up_party_mon(game, slot, species, form, level, moves):
	"""Turn party mon `slot` into this one, keeping its nickname, without calling the ROM: a routine
	that prints text has to start from the main loop, which a plain A.call leaves parked."""
	shorten_party(game, max(slot + 1, 1))
	species_id = A.species_id(game, species)
	game.poke("wPartySpecies", species_id, slot)
	set_party_field(game, slot, "Species", species_id)
	set_party_field(game, slot, "Form", form)
	set_party_field(game, slot, "Level", level)
	for field in ("HPEV", "AtkEV", "DefEV", "SpdEV", "SpclAtkEV", "SpclDefEV"):
		set_party_field(game, slot, field, 0)
	set_party_moves(game, slot, moves)


def string_at(game, symbol):
	chars = constants.charmap()
	out = ""
	for i in range(20):
		byte = game.peek(symbol, i)
		if byte == 0x50: # "@"
			return out
		out += chars.get(byte, "?")
	raise AssertionError("no @ in %s" % symbol)


@pytest.mark.parametrize("form, item, stat", [(0, "CALCIUM", "SPCL.ATK"), (0, "ZINC", "SPCL.DEF"),
	("GENGAR_RB_FORM", "CALCIUM", "SPECIAL"), ("GENGAR_RB_FORM", "ZINC", "SPECIAL")])
def test_vitamin_names_the_stat_it_raised(game, form, item, stat):
	slot = 0 # where the party menu's cursor starts
	set_up_party_mon(game, slot, "GENGAR", form_constant(form) if form else 0, LEVEL, ["LICK"])
	game.poke("wCurItem", A.item_id(game, item))
	# The party menu, then "<MON>'s <STAT> rose.", each taken with A
	A.call(game, "VitaminEffect", press_a_every=30, must_return=False, frames=900, from_main_loop=True)
	assert string_at(game, "wStringBuffer2") == stat
	sat = party_field(game, slot, "SpclAtkEV")
	sdf = party_field(game, slot, "SpclDefEV")
	if form:
		assert sat == sdf == 10, "an RB form's vitamin raises its one Special pool"
	else:
		assert (sat, sdf) == ((10, 0) if item == "CALCIUM" else (0, 10))


LEVEL_UP_MOVES = [("SNORLAX", "HARDEN", 41), ("SNORLAX", "DOUBLE_EDGE", 48), ("KABUTO", "SLASH", 39),
	("MOLTRES", "PECK", 1), ("TENTACOOL", "WATER_GUN", 22), ("SANDSHREW", "POISON_STING", 24)]


@pytest.mark.parametrize("species, move, level", LEVEL_UP_MOVES)
def test_missing_rby_level_up_moves(species, move, level):
	text = (constants.ROOT / "data" / "pokemon" / "evos_attacks_kanto.asm").read_text(encoding="utf-8")
	label = species.capitalize() + "EvosAttacks:"
	block = text.split(label, 1)[1].split("EvosAttacks:", 1)[0]
	assert re.search(r"\tdbw %d, %s\b" % (level, move), block), "%s should learn %s at %d" % (species, move, level)



@pytest.mark.parametrize("species, move", [("KABUTO", "LEER"), ("KABUTOPS", "ABSORB"), ("JYNX", "LOVELY_KISS")])
def test_duplicate_level_up_move_removed(species, move):
	# Each learned the same move twice (at 1 and again later); the later copy is gone
	text = (constants.ROOT / "data" / "pokemon" / "evos_attacks_kanto.asm").read_text(encoding="utf-8")
	block = text.split(species.capitalize() + "EvosAttacks:", 1)[1].split("no more level-up moves", 1)[0]
	assert re.findall(r"\tdbw (\d+), %s\b" % move, block) == ["1"]


def level_up_moves(species):
	"""[(level, move)] from the species' learnset in evos_attacks_kanto.asm."""
	text = (constants.ROOT / "data" / "pokemon" / "evos_attacks_kanto.asm").read_text(encoding="utf-8")
	block = text.split(species.capitalize() + "EvosAttacks:", 1)[1].split("no more level-up moves", 1)[0]
	return [(int(level), move) for level, move in re.findall(r"^\tdbw (\d+), (\w+)", block, re.M)]


def party_moves(game, slot):
	length = party_struct_length(game)
	return [game.peek("wPartyMon1Moves", slot * length + i) for i in range(4)]


def set_party_moves(game, slot, moves):
	length = party_struct_length(game)
	ids = [move_id(game, move) for move in moves]
	for i in range(4):
		game.poke("wPartyMon1Moves", ids[i] if i < len(ids) else 0, slot * length + i)


# A mon generated at its evolution level gets the last four moves it learned, and these two now
# have five level-1 moves, so the first drops out; Snorlax at 41 has the new Harden.
GENERATED_MOVES = [
	("CHARIZARD", 36, ["FIRE_SPIN", "SCARY_FACE", "FLAMETHROWER", "WING_ATTACK"]),
	("OMASTAR", 40, ["SPIKE_CANNON", "ANCIENTPOWER", "HORN_ATTACK", "PROTECT"]),
	("SNORLAX", 41, ["HEADBUTT", "SNORE", "REST", "HARDEN"]),
]


@pytest.mark.parametrize("species, level, moves", GENERATED_MOVES)
def test_generated_mon_gets_its_last_four_moves(game, species, level, moves):
	shorten_party(game, 1)
	slot = give_poke(game, species, 0, level)
	assert party_moves(game, slot) == [move_id(game, move) for move in moves]


# (species, level, a move it must not learn there): the new moves come at their levels, and the
# three later copies that were removed don't come back
LEVEL_UPS = [(species, level, None) for species, move, level in LEVEL_UP_MOVES if level > 1] + [
	("KABUTO", 25, "LEER"), ("KABUTOPS", 19, "ABSORB"), ("JYNX", 34, "LOVELY_KISS")]


@pytest.mark.parametrize("species, level, not_learned", LEVEL_UPS)
def test_level_up_learns_the_moves_listed_at_that_level(game, species, level, not_learned):
	slot = 0
	set_up_party_mon(game, slot, species, 0, level, ["SPLASH"]) # room for what comes: no forgetting
	game.poke("wTempSpecies", A.species_id(game, species))
	game.poke("wCurPartyLevel", level)
	game.poke("wCurPartyMon", slot)
	# Each move learned prints "<MON> learned <MOVE>!", taken with A. With interrupts on, a frame
	# can end inside VBlank, so the return may not be seen: give it time and read the party.
	A.call(game, "LearnLevelMoves", press_a_every=30, must_return=False, frames=900, from_main_loop=True)
	new = [move for at, move in level_up_moves(species) if at == level]
	assert party_moves(game, slot) == [move_id(game, move) for move in ["SPLASH"] + new] + [0] * (3 - len(new))
	if not_learned:
		assert move_id(game, not_learned) not in party_moves(game, slot)

# Breeding: a Red/Blue form breeds as whichever gender its partner lacks, and a Gen 1 tutor move
# passes to any egg whose line learned it by TM in Red/Blue.

MALE_DVS = (0xff, 0xff)
FEMALE_DVS = (0x00, 0x00)
SAME_SPECIES = 254
DIFFERENT_SPECIES = 128


def move_id(game, name):
	index = constants._consts(constants.ROOT / "constants" / "move_constants.asm")[name]
	return A._table_id(game, "wMoveIndexTable", index)


def set_breedmon(game, slot, species, form=None, dvs=MALE_DVS, moves=()):
	prefix = "wBreedMon%d" % slot
	game.poke(prefix + "Species", A.species_id(game, species))
	game.poke(prefix + "Form", form_constant(form) if form else 0)
	game.poke(prefix + "DVs", dvs[0])
	game.poke(prefix + "DVs", dvs[1], 1)
	ids = [move_id(game, move) for move in moves]
	for i in range(4):
		game.poke(prefix + "Moves", ids[i] if i < len(ids) else 0, i)


def compatibility(game):
	A.call(game, "CheckBreedmonCompatibility")
	return game.peek("wBreedingCompatibility")


def make_egg(game, seed=1):
	"""The egg the Day-Care would make from the two breed mons: its species and move ids, and
	which breed mon (1 or 2) was the mother."""
	game.seed_random(seed)
	A.call(game, "DayCare_InitBreeding.UselessJump")
	mother = 2 if game.peek("wBreedMotherOrNonDitto") else 1
	return game.peek("wEggMonSpecies"), [game.peek("wEggMonMoves", i) for i in range(4)], mother


@pytest.mark.parametrize("partner, form, dvs, expected", [
	("PIKACHU", None, MALE_DVS, SAME_SPECIES),
	("PIKACHU", None, FEMALE_DVS, SAME_SPECIES),
	("PIKACHU", "PIKACHU_RB_FORM", MALE_DVS, SAME_SPECIES),
	("DITTO", None, MALE_DVS, DIFFERENT_SPECIES),
	("CLEFAIRY", None, FEMALE_DVS, DIFFERENT_SPECIES),
])
def test_rb_form_breeds_with_any_gender(game, partner, form, dvs, expected):
	for first in (1, 2):
		set_breedmon(game, first, "PIKACHU", "PIKACHU_RB_FORM")
		set_breedmon(game, 3 - first, partner, form, dvs)
		assert compatibility(game) == expected, "with the RB mon in slot %d" % first


def test_rb_form_and_a_genderless_species_are_not_compatible(game):
	set_breedmon(game, 1, "TENTACOOL", "TENTACOOL_RB_FORM")
	set_breedmon(game, 2, "STARYU")
	assert compatibility(game) == 0


def test_two_plain_males_still_are_not_compatible(game):
	set_breedmon(game, 1, "PIKACHU", dvs=MALE_DVS)
	set_breedmon(game, 2, "PIKACHU", dvs=MALE_DVS)
	assert compatibility(game) == 0


@pytest.mark.parametrize("partner_dvs, rb_is_mother", [(MALE_DVS, True), (FEMALE_DVS, False)])
def test_rb_form_is_the_mother_unless_its_partner_is_female(game, partner_dvs, rb_is_mother):
	for rb_slot in (1, 2):
		set_breedmon(game, rb_slot, "PIKACHU", "PIKACHU_RB_FORM")
		set_breedmon(game, 3 - rb_slot, "PIKACHU", dvs=partner_dvs)
		_, _, mother = make_egg(game)
		assert (mother == rb_slot) == rb_is_mother, "with the RB mon in slot %d" % rb_slot


def test_two_rb_forms_flip_a_coin_for_the_mother(game):
	mothers = set()
	for seed in range(1, 41):
		set_breedmon(game, 1, "PIKACHU", "PIKACHU_RB_FORM")
		set_breedmon(game, 2, "PIKACHU", "PIKACHU_RB_FORM")
		mothers.add(make_egg(game, seed)[2])
	assert mothers == {1, 2}


def test_rb_mother_lays_her_own_species(game):
	# An RB mother with a male of another species in her egg group: the egg is her line's
	set_breedmon(game, 1, "CLEFAIRY", dvs=MALE_DVS)
	set_breedmon(game, 2, "PIKACHU", "PIKACHU_RB_FORM")
	species, _, mother = make_egg(game)
	assert mother == 2
	assert species == A.species_id(game, "PICHU")


def test_rb_tentacool_breeds_with_ditto(game):
	set_breedmon(game, 1, "TENTACOOL", "TENTACOOL_RB_FORM")
	set_breedmon(game, 2, "DITTO")
	assert compatibility(game) == DIFFERENT_SPECIES


FORM_MASK = 0x1f


def egg_form(game, seed=1):
	make_egg(game, seed)
	return game.peek("wEggMonForm") & FORM_MASK # without the shiny bits


# (parent 1, its form, parent 1's DVs, parent 2, its form, the egg's species, the egg's form).
# The egg takes the form of the parent of its own line; MultiFormEggTable names the one form per
# line that passes, so anything else hatches plain.
EGG_FORMS = [
	("PIKACHU", "PIKACHU_RB_FORM", MALE_DVS, "DITTO", None, "PICHU", "PICHU_BETA_FORM"),
	("RAICHU", "RAICHU_RB_FORM", MALE_DVS, "DITTO", None, "PICHU", "PICHU_BETA_FORM"),
	("PIKACHU", None, MALE_DVS, "DITTO", None, "PICHU", None),
	("PIKACHU", "PIKACHU_SURF_FORM", MALE_DVS, "DITTO", None, "PICHU", None),
	("PIKACHU", "PIKACHU_RB_FORM", MALE_DVS, "PIKACHU", "PIKACHU_RB_FORM", "PICHU", "PICHU_BETA_FORM"),
	# An RB mother with a male of another line: her line's egg, in her form
	("CLEFAIRY", None, MALE_DVS, "PIKACHU", "PIKACHU_RB_FORM", "PICHU", "PICHU_BETA_FORM"),
	# A female of another line is the mother: her line's egg, plain
	("CLEFAIRY", None, FEMALE_DVS, "PIKACHU", "PIKACHU_RB_FORM", "CLEFFA", None),
	("TENTACOOL", "TENTACOOL_RB_FORM", MALE_DVS, "DITTO", None, "TENTACOOL", "TENTACOOL_RB_FORM"),
	("CROBAT", "CROBAT_BETA_FORM", MALE_DVS, "DITTO", None, "ZUBAT", "ZUBAT_RB_FORM"),
	("CROBAT", "CROBAT_ROCKET_FORM", MALE_DVS, "DITTO", None, "ZUBAT", None),
	("KINGDRA", "KINGDRA_BETA_FORM", MALE_DVS, "DITTO", None, "HORSEA", "HORSEA_RB_FORM"),
	("SEADRA", "SEADRA_RB_FORM", MALE_DVS, "DITTO", None, "HORSEA", "HORSEA_RB_FORM"),
	("RHYDON", "RHYDON_RB_FORM", MALE_DVS, "DITTO", None, "RHYHORN", "RHYHORN_RB_FORM"),
	("KANGASKHAN", "KANGASKHAN_RB_FORM", MALE_DVS, "DITTO", None, "KANGASKHAN", "KANGASKHAN_RB_FORM"),
	("VENOMOTH", "VENOMOTH_RB_FORM", MALE_DVS, "DITTO", None, "VENONAT", "VENONAT_RB_FORM"),
	("LAPRAS", "LAPRAS_RB_FORM", MALE_DVS, "DITTO", None, "LAPRAS", "LAPRAS_RB_FORM"),
	("FARFETCH_D", "FARFETCH_D_RB_FORM", MALE_DVS, "DITTO", None, "FARFETCH_D", "FARFETCH_D_RB_FORM"),
	("MAROWAK", "MAROWAK_RB_FORM", MALE_DVS, "DITTO", None, "CUBONE", "CUBONE_RB_FORM"),
	("EXEGGUTOR", "EXEGGUTOR_RB_FORM", MALE_DVS, "DITTO", None, "EXEGGCUTE", "EXEGGCUTE_RB_FORM"),
	("DRAGONITE", "DRAGONITE_RB_FORM", MALE_DVS, "DITTO", None, "DRATINI", "DRATINI_RB_FORM"),
]


@pytest.mark.parametrize("parent1, form1, dvs1, parent2, form2, species, form", EGG_FORMS)
def test_egg_form(game, parent1, form1, dvs1, parent2, form2, species, form):
	for seed in (1, 2, 3):
		set_breedmon(game, 1, parent1, form1, dvs1)
		set_breedmon(game, 2, parent2, form2)
		assert egg_form(game, seed) == (form_constant(form) if form else 0), "seed %d" % seed
		assert game.peek("wEggMonSpecies") == A.species_id(game, species)


EVOLUTION_FRAMES = 3000


# (species, its RB form, level, item used or None, what it becomes, that one's RB form)
RB_EVOLUTIONS = [
	("EXEGGCUTE", "EXEGGCUTE_RB_FORM", 30, "LEAF_STONE", "EXEGGUTOR", "EXEGGUTOR_RB_FORM"),
	("VENONAT", "VENONAT_RB_FORM", 31, None, "VENOMOTH", "VENOMOTH_RB_FORM"),
	("DRATINI", "DRATINI_RB_FORM", 30, None, "DRAGONAIR", "DRAGONAIR_RB_FORM"),
	("DRAGONAIR", "DRAGONAIR_RB_FORM", 55, None, "DRAGONITE", "DRAGONITE_RB_FORM"),
]


@pytest.mark.parametrize("species, form, level, item, evolved, evolved_form", RB_EVOLUTIONS)
def test_rb_form_keeps_its_form_when_it_evolves(game, species, form, level, item, evolved, evolved_form):
	take_radio_items(game) # a party, set up without parking the CPU as give_poke's call would
	slot = 0
	species_id = A.species_id(game, species)
	game.poke("wPartySpecies", species_id)
	set_party_field(game, slot, "Species", species_id)
	set_party_field(game, slot, "Form", form_constant(form))
	set_party_field(game, slot, "Level", level)
	game.poke("wCurItem", A.item_id(game, item) if item else 0)
	game.poke("wForceEvolution", 1 if item else 0)
	game.poke("wCurPartyMon", slot)
	A.call(game, "EvolvePokemon", press_a_every=30, must_return=False, frames=EVOLUTION_FRAMES,
		from_main_loop=True)
	assert party_field(game, slot, "Species") == A.species_id(game, evolved)
	assert party_field(game, slot, "Form") & FORM_MASK == form_constant(evolved_form)


def test_rb_and_plain_of_one_line_pick_either_form(game):
	forms = set()
	for seed in range(1, 41):
		set_breedmon(game, 1, "PIKACHU", "PIKACHU_RB_FORM")
		set_breedmon(game, 2, "PIKACHU", dvs=FEMALE_DVS)
		forms.add(egg_form(game, seed))
	assert forms == {0, form_constant("PICHU_BETA_FORM")}


def test_gen1_tutor_moves_pass_down_a_line_that_learned_them(game):
	# RB Pikachu father, female Clefairy mother: a plain Cleffa egg. Clefairy learned Body Slam
	# and Submission by TM in Red/Blue (Cleffa itself is Johto's), but never Pay Day.
	set_breedmon(game, 1, "CLEFAIRY", dvs=FEMALE_DVS)
	set_breedmon(game, 2, "PIKACHU", "PIKACHU_RB_FORM", moves=("BODY_SLAM", "SUBMISSION", "PAY_DAY"))
	species, moves, mother = make_egg(game)
	assert mother == 1
	assert species == A.species_id(game, "CLEFFA")
	assert move_id(game, "BODY_SLAM") in moves
	assert move_id(game, "SUBMISSION") in moves
	assert move_id(game, "PAY_DAY") not in moves


def gen1_tutor_learnsets():
	"""{species: set of moves} from data/pokemon/rb_tutor_moves.asm."""
	text = (constants.ROOT / "data" / "pokemon" / "rb_tutor_moves.asm").read_text(encoding="utf-8")
	rows = {}
	for m in re.finditer(r"^\tgen1_tutor_learnset (\w+)(.*)$", text, re.M):
		rows[m.group(1)] = set(re.findall(r"\w+", m.group(2)))
	return rows


@pytest.mark.parametrize("species", ["PIKACHU", "GOLBAT", "MEW", "MAGIKARP", "CHANSEY", "MR__MIME"])
def test_gen1_tutor_learnset_bits_match_the_data(game, species):
	moves = re.findall(r"^\tgen1_tutor_move (\w+)", (constants.ROOT / "data" / "pokemon" /
		"rb_tutor_moves.asm").read_text(encoding="utf-8"), re.M)
	assert len(moves) == 35
	learnset = gen1_tutor_learnsets()[species]
	index = A.pokemon_index(species)
	for number, move in enumerate(moves):
		result = A.call(game, "CanLearnGen1TutorMove", bc=index, de=number)
		assert bool(result["f"] & CARRY) == (move in learnset), "%s and %s" % (species, move)
