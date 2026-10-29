"""Trainer Pokémon missing their first move.

The trainer parties came from Crystal Legacy through the importer in
tools/joe_tools/crystal_legacy_parties_to_16_bit/. For parties with moves but no items, it once took
the first move for an item and dropped it, so hundreds of trainer Pokémon lost a move: the rival's
Larvitar had ROCK_THROW, SCREECH and nothing else instead of BITE first.

The importer's fixed output, trainer_parties_16bit.asm, is kept beside it. Wherever a party slot
still holds the same Pokémon at the same level as that output, its moves must match it, unless the
change is a deliberate later edit listed below."""

import subprocess

import pytest

from harness import data

IMPORTED = "tools/joe_tools/crystal_legacy_parties_to_16_bit/trainer_parties_16bit.asm"

# Movesets changed on purpose after the import, as (group, party number, slot, species).
DELIBERATE_EDITS = {
	("BlueGroup", 2, 2, "ALAKAZAM"), # the Open League: THUNDERPUNCH for THUNDERBOLT
}


def moveset_differences(rev=None):
	"""[(group, party number, name, slot, species, moves, imported moves)] for every slot holding
	the imported Pokémon at the imported level with other moves."""
	imported = data.parse_parties(data.read(IMPORTED))
	current = data.parties(rev)
	found = []
	compared = 0
	for label, imported_parties in imported.items():
		parties = current.get(label, [])
		for number, (imported_party, party) in enumerate(zip(imported_parties, parties), 1):
			for slot, (imported_mon, mon) in enumerate(zip(imported_party["mons"], party["mons"]), 1):
				if imported_mon["moves"] is None or mon["moves"] is None:
					continue
				if (imported_mon["level"], imported_mon["species"]) != (mon["level"], mon["species"]):
					continue
				compared += 1
				if imported_mon["moves"] != mon["moves"]:
					found.append((label, number, party["name"], slot, mon["species"], mon["moves"],
						imported_mon["moves"]))
	return compared, found


def describe(found):
	return "\n".join("%s party %d (%s) slot %d %s: %s, imported as %s"
		% (label, number, name, slot, species, ", ".join(moves), ", ".join(imported))
		for label, number, name, slot, species, moves, imported in found)


def test_trainer_movesets_match_the_import():
	compared, found = moveset_differences()
	assert compared > 400, "only %d movesets lined up with the import; has the file moved?" % compared
	found = [entry for entry in found if (entry[0], entry[1], entry[3], entry[4]) not in DELIBERATE_EDITS]
	assert not found, "trainer movesets that differ from the import:\n" + describe(found)


def has_revision(rev):
	return subprocess.run(["git", "cat-file", "-e", rev], cwd=data.ROOT, capture_output=True).returncode == 0


def test_check_finds_the_dropped_moves():
	"""Run on the parties from before the fix, the check finds the dropped moves, the rival's
	Larvitar among them."""
	if not has_revision("d4f7c5080"):
		pytest.skip("d4f7c5080 isn't in this clone's history")
	_, found = moveset_differences("d4f7c5080^")
	assert len(found) > 100
	assert any(entry[0] == "Rival1Group" and entry[4] == "LARVITAR" and entry[6][0] == "BITE"
		for entry in found)
