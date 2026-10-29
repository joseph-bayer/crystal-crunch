"""Alternate shinies: a shiny is an alternate shiny (ALT_SHINY_MASK, bit 6 of the form byte) 1 time
in 5, or 4 in 5 in an alternate-shiny swarm, and a species with an alternate (Scyther in red, Scizor
in gold) draws in those colors and shows the hollow shiny icon.

Most of these call the ROM's own routines directly (see harness.alt_shiny.call), so the rolls can
be checked against the test ROM's random sequence seed by seed."""

import re

import pytest

from harness import alt_shiny as A
from harness.forms import (form_constant, party_field, party_species, set_party_field,
	super_nerd_menu, take_radio_items, wait_for_battle_menu, wait_until)

SEEDS = range(1, 1001)

PALETTE_BANK_ROUTINE = "GetMonNormalOrShinyPalettePointer"

SCYTHER_ALT = "gfx/pokemon/scyther/alt_shiny.pal"
SCYTHER_SHINY = "gfx/pokemon/scyther/shiny.pal"
SCIZOR_ALT = "gfx/pokemon/scizor/alt_shiny.pal"
MEW_SHINY = "gfx/pokemon/mew/shiny.pal"

SCREEN_WIDTH = 20

NUM_BOXES = 18

# Long enough for the evolution scene, its text and the return to the map
EVOLUTION_FRAMES = 3000
BOX_FULL = 3


def roll_counts(game, routine, numerator, **registers):
	"""Run a roll once per seed on a shiny form byte; check every seed against the sequence and
	return how many came out alternates."""
	alternates = 0
	for seed in SEEDS:
		game.seed_random(seed)
		result = A.call(game, routine, a=A.SHINY_MASK, **registers)["a"]
		assert result & A.SHINY_MASK, "the roll should keep the shiny bit"
		expected = A.expected_alt(seed, A.threshold(numerator))
		assert bool(result & A.ALT_SHINY_MASK) == expected, "seed %d" % seed
		alternates += bool(result & A.ALT_SHINY_MASK)
	return alternates


def test_alt_roll_is_one_in_five(game):
	alternates = roll_counts(game, "RollAltShiny", 1)
	assert 150 <= alternates <= 250, "about 1 in 5 of 1000 shinies should be alternates"


def test_alt_roll_leaves_a_plain_mon_alone(game):
	for form in (0, 1, 2):
		for seed in (1, 2, 3, 4, 5):
			game.seed_random(seed)
			assert A.call(game, "RollAltShiny", a=form)["a"] == form


def test_swarm_alt_roll_is_four_in_five(game):
	alternates = roll_counts(game, "RollSwarmAltShiny", 4)
	assert 750 <= alternates <= 850, "about 4 in 5 of 1000 shinies should be alternates"


@pytest.mark.parametrize("from_swarm, swarm_alt, numerator", [
	(1, A.SWARM_ALT_SHINY, 4), # an alternate-shiny swarm's wanderer
	(1, 0, 1),                 # an ordinary swarm's
	(0, A.SWARM_ALT_SHINY, 1), # the route's own mon on a map where that swarm runs
])
def test_wanderer_alt_odds(game, from_swarm, swarm_alt, numerator):
	game.poke("wOverworldMonRollFromSwarm", from_swarm)
	game.poke("wOverworldMonSwarmAltShiny", swarm_alt)
	roll_counts(game, "RollOverworldMonAltShiny", numerator)


def swarm_shiny_seeds(count):
	"""Seeds whose first swarm roll is shiny: a 0 from the 1/256 gate, then under 128."""
	seeds = []
	for seed in range(1, 0x10000):
		rng = A.TestRandom(seed)
		if rng.next() == 0 and rng.next() < 128:
			seeds.append((seed, rng.x))
			if len(seeds) == count:
				break
	return seeds


@pytest.mark.parametrize("terrain, numerator", [
	(A.SWARM_GRASS, 1),
	(A.SWARM_GRASS | A.SWARM_ALT_SHINY, 4),
])
def test_swarm_battle_roll_uses_the_rows_odds(game, terrain, numerator):
	for seed, after_shiny in swarm_shiny_seeds(40):
		game.seed_random(seed)
		result = A.call(game, "RollSwarmShiny", a=0, bc=terrain)["a"]
		assert result & A.SHINY_MASK, "seed %d should roll shiny" % seed
		assert bool(result & A.ALT_SHINY_MASK) == A.expected_alt(after_shiny, A.threshold(numerator)), \
			"seed %d" % seed


def test_force_shiny_makes_every_swarm_mon_shiny(game):
	"""The debug ROM's BEASTS -> FORCE SHINY reaches swarms too, so the alternate-shiny swarm can be
	seen without a thousand battles."""
	game.set_event_flag("EVENT_DEBUG_FORCE_SHINY_BEASTS")
	alternates = 0
	for seed in range(1, 101):
		game.seed_random(seed)
		result = A.call(game, "RollSwarmShiny", a=0, bc=A.SWARM_GRASS | A.SWARM_ALT_SHINY)["a"]
		assert result & A.SHINY_MASK, "seed %d should be forced shiny" % seed
		alternates += bool(result & A.ALT_SHINY_MASK)
	assert 60 <= alternates <= 95, "about 4 in 5 should still be alternates"

	game.poke("wOverworldMonRollFromSwarm", 1)
	assert A.call(game, "DebugForceSwarmMonShiny")["a"], "a swarm's wanderer is forced too"
	game.poke("wOverworldMonRollFromSwarm", 0)
	assert not A.call(game, "DebugForceSwarmMonShiny")["a"], "the route's own mon are left alone"


CARRY = 0x10


def swarm_ids():
	text = (A.constants.ROOT / "constants" / "swarm_constants.asm").read_text(encoding="utf-8")
	return {name: int(n) for name, n in re.findall(r"const (SWARM_\w+)\s*; (\d+)", text)}


def test_radio_reports_only_the_alt_shiny_swarm_as_oddly_colored(game):
	"""The swarm report picks its "Oddly colored" lines from IsDailySwarmAltShiny, and Team Rocket's
	from IsDailySwarmRocket: each must say yes for its own rows only."""
	ids = swarm_ids()
	for name in ("SWARM_SCYTHER_ALT_SHINY", "SWARM_DRATINI_ALT_SHINY", "SWARM_MAGIKARP_ALT_SHINY", "SWARM_MARILL_ALT_SHINY",
			"SWARM_GOLBAT_ROCKET", "SWARM_DUNSPARCE"):
		game.poke("wDailySwarm", ids[name])
		alt = bool(A.call(game, "IsDailySwarmAltShiny")["f"] & CARRY)
		rocket = bool(A.call(game, "IsDailySwarmRocket")["f"] & CARRY)
		assert alt == name.endswith("_ALT_SHINY"), name
		assert rocket == (name == "SWARM_GOLBAT_ROCKET"), name
	game.poke("wDailySwarm", 0)
	assert not A.call(game, "IsDailySwarmAltShiny")["f"] & CARRY, "no swarm today"


def palette_and_icon(game, species, form):
	"""The two colors a mon with this form byte draws in, and the shiny icon it shows."""
	address = A.scratch_address(game, 0)
	game.pyboy.memory[address] = form
	species = A.species_id(game, species)
	hl = A.call(game, PALETTE_BANK_ROUTINE, a=species, bc=address)["hl"]
	bank, _ = game.pyboy.symbol_lookup(PALETTE_BANK_ROUTINE)
	data = [game.pyboy.memory[bank, hl + i] for i in range(4)]
	colors = [data[0] | data[1] << 8, data[2] | data[3] << 8]
	icon = A.call(game, "GetShinyIcon", a=species, bc=address)["a"]
	return colors, icon


@pytest.mark.parametrize("form", [0, 1, 2]) # every form shares the alternate, as they share the shiny
def test_alternate_scyther_is_red(game, form):
	colors, icon = palette_and_icon(game, "SCYTHER", form | A.SHINY_MASK | A.ALT_SHINY_MASK)
	assert colors == A.pal_colors(SCYTHER_ALT)
	assert icon == A.ALT_SHINY_ICON


def test_alternate_scizor_is_gold(game):
	colors, icon = palette_and_icon(game, "SCIZOR", A.SHINY_MASK | A.ALT_SHINY_MASK)
	assert colors == A.pal_colors(SCIZOR_ALT)
	assert icon == A.ALT_SHINY_ICON


@pytest.mark.parametrize("species, forms", [
	("DRATINI", 1), ("DRAGONAIR", 1), ("DRAGONITE", 1),
	("MAGIKARP", 4), ("GYARADOS", 4), ("MARILL", 1), ("AZUMARILL", 1), # plain, XS, XL and RB: every form shares the alternate
])
def test_dragon_line_and_magikarp_line_alternates(game, species, forms):
	alt = A.pal_colors("gfx/pokemon/%s/alt_shiny.pal" % species.lower())
	for form in range(forms):
		colors, icon = palette_and_icon(game, species, form | A.SHINY_MASK | A.ALT_SHINY_MASK)
		assert colors == alt, "%s form %d" % (species, form)
		assert icon == A.ALT_SHINY_ICON
		colors, icon = palette_and_icon(game, species, form | A.SHINY_MASK)
		# an ordinary shiny keeps its own colors (the RB forms have shiny colors of their own)
		assert colors != alt, "%s form %d's ordinary shiny" % (species, form)
		assert icon == A.SHINY_ICON


def test_ordinary_shiny_scyther_is_unchanged(game):
	colors, icon = palette_and_icon(game, "SCYTHER", A.SHINY_MASK)
	assert colors == A.pal_colors(SCYTHER_SHINY)
	assert icon == A.SHINY_ICON


def test_alternate_bit_without_shiny_draws_normal(game):
	colors, _ = palette_and_icon(game, "SCYTHER", A.ALT_SHINY_MASK)
	assert colors not in (A.pal_colors(SCYTHER_ALT), A.pal_colors(SCYTHER_SHINY))


def test_species_without_an_alternate_looks_ordinary(game):
	colors, icon = palette_and_icon(game, "MEW", A.SHINY_MASK | A.ALT_SHINY_MASK)
	assert colors == A.pal_colors(MEW_SHINY)
	assert icon == A.SHINY_ICON


def test_stats_screen_icon(game):
	game.poke("wTempMonSpecies", A.species_id(game, "SCYTHER"))
	game.poke("wTempMonForm", A.SHINY_MASK | A.ALT_SHINY_MASK)
	A.call(game, "StatsScreen_PlaceShinyIcon")
	assert game.peek("wTilemap", 19) == A.ALT_SHINY_ICON

	game.poke("wTempMonForm", A.SHINY_MASK)
	A.call(game, "StatsScreen_PlaceShinyIcon")
	assert game.peek("wTilemap", 19) == A.SHINY_ICON


def bg_palette_pairs(game):
	"""Colors 1 and 2 of each of the eight background palettes, as last applied."""
	data = game.peek("wBGPals2", 0, 64)
	return [[data[p * 8 + 2] | data[p * 8 + 3] << 8, data[p * 8 + 4] | data[p * 8 + 5] << 8]
		for p in range(8)]


def test_wild_alternate_scyther_in_battle(game):
	take_radio_items(game)
	scyther = A.species_id(game, "SCYTHER")
	form = A.SHINY_MASK | A.ALT_SHINY_MASK

	# WILD MEW, turned into a wild alternate shiny Scyther before the enemy loads
	super_nerd_menu(game, "HP BATTLES", "WILD MEW")
	assert game.peek("wBattleMode") == 0, "the battle shouldn't have loaded its enemy yet"
	for symbol in ("wTempWildMonSpecies", "wTempEnemyMonSpecies", "wCurPartySpecies"):
		game.poke(symbol, scyther)
	game.poke("wTempWildMonForm", form)
	wait_until(game, lambda: game.peek("wBattleMode") == 1, "the wild battle")
	wait_for_battle_menu(game)

	assert game.peek("wEnemyMonSpecies") == scyther
	assert game.peek("wEnemyMonForm") == form
	assert game.peek("wTilemap", 1 * SCREEN_WIDTH + 3) == A.ALT_SHINY_ICON, "the HUD's shiny icon"
	assert A.pal_colors(SCYTHER_ALT) in bg_palette_pairs(game), "its pic should be in the red colors"


@pytest.mark.parametrize("routine, start_form", [
	("MoveDeletion.revert_pikachu_to_plain_form", "PIKACHU_SURF_FORM"),
	("LearnMove.reset_pikachu_to_plain_form", "PIKACHU_SURF_FORM"),
])
def test_pikachu_form_reset_keeps_the_alternate(game, routine, start_form):
	shiny = A.SHINY_MASK | A.ALT_SHINY_MASK
	game.poke("wCurPartyMon", 0)
	game.poke("wPartyMon1Form", form_constant(start_form) | shiny)
	A.call(game, routine)
	assert game.peek("wPartyMon1Form") == shiny


def test_shuckie_form_change_keeps_the_alternate(game):
	shiny = A.SHINY_MASK | A.ALT_SHINY_MASK
	game.poke("wPartyCount", 1)
	game.poke("wPartySpecies", A.species_id(game, "SHUCKLE"))
	game.poke("wPartyMon1Species", A.species_id(game, "SHUCKLE"))
	game.poke("wPartyMon1Happiness", 200)
	game.poke("wPartyMon1Form", form_constant("SHUCKLE_SHUCKIE_NEUTRAL_FORM") | shiny)
	game.poke("wCurPartyMon", 0)
	A.call(game, "ChangeHappiness.update_shuckle_form")
	assert game.peek("wPartyMon1Form") == form_constant("SHUCKLE_SHUCKIE_HAPPY_FORM") | shiny


def test_alternate_survives_the_pc(game):
	take_radio_items(game)
	form = A.SHINY_MASK | A.ALT_SHINY_MASK | 1
	set_party_field(game, 1, "Form", form)
	species = party_species(game)[1]

	# Party slot 2 into the first box with room (the debug game fills some), anywhere; then back
	# into the party, anywhere
	for box in range(1, NUM_BOXES + 1):
		out = A.call(game, "SwapStorageBoxSlots", bc=box << 8, de=0 << 8 | 2)
		if out["a"] != BOX_FULL:
			break
	assert out["a"] == 0, "the deposit failed with %d" % out["a"]
	box_slot = out["bc"]
	out = A.call(game, "SwapStorageBoxSlots", bc=0, de=box_slot)
	assert out["a"] == 0, "the withdrawal failed with %d" % out["a"]

	last = game.peek("wPartyCount") - 1
	assert party_species(game)[last] == species
	assert party_field(game, last, "Form") == form


def test_alternate_survives_evolution(game):
	take_radio_items(game)
	scyther = A.species_id(game, "SCYTHER")
	form = A.SHINY_MASK | A.ALT_SHINY_MASK
	game.poke("wPartySpecies", scyther)
	set_party_field(game, 0, "Species", scyther)
	set_party_field(game, 0, "Form", form)
	game.poke("wCurItem", A.item_id(game, "METAL_COAT"))
	game.poke("wForceEvolution", 1)
	game.poke("wCurPartyMon", 0)
	# It ends by going back to the map rather than returning, so give it time and look at the party
	A.call(game, "EvolvePokemon", press_a_every=30, must_return=False, frames=EVOLUTION_FRAMES)

	assert party_species(game)[0] == A.species_id(game, "SCIZOR"), "Scyther should have evolved"
	assert party_field(game, 0, "Form") == form, "the evolved Scizor should still be an alternate"
