"""Phone trainers' rematch parties that get weaker as you go.

A phone trainer's rematches are parties in data/trainers/parties.asm that the map script loads one
after another as you beat them. Alan's, Jack's, Erin's and Tiffany's once went out of order: a later
rematch had lower levels or fewer Pokémon than the one before it.

The order is the script's, not the constants' numbers: Hiker Anthony's first battle is ANTHONY2,
then his rematches load ANTHONY1, ANTHONY3 and so on. So each trainer's parties are taken in the
order their map file first names them, in its `trainer` event and `loadtrainer` lines.

A party whose levels scale with badges (Erin's first) is taken at 8 badges, the fewest the Elite
Four allows, since her next rematch waits for the Elite Four, or at its map's badge cap if that's
lower."""

import re
import subprocess

import pytest

from harness import data

# Steps down a ladder known to be there, as (earlier, later), until they're rebalanced.
KNOWN_WEAKER = set() # Brent's (two Pokémon at 26, then one at 33) was rebalanced

ELITE_FOUR_BADGES = 8


def rematch_ladders():
	"""[(class, base name, [trainer constants in play order], map's badge cap or None)] for every
	trainer whose numbered parties (NAME1, NAME2, ...) a map loads two or more of with
	`loadtrainer`."""
	ladders = []
	for path, battles in data.trainer_battles().items():
		loaded = {(cls, name) for cls, name in re.findall(r"loadtrainer\s+(\w+),\s*(\w+)", data.read(path))}
		seen = {}
		for cls, name in battles:
			m = re.fullmatch(r"([A-Z]+?)(\d+)", name)
			if not m:
				continue
			order = seen.setdefault((cls, m.group(1)), [])
			if name not in order:
				order.append(name)
		map_name = data.map_constants_by_file().get(path.split("/")[-1][:-4])
		cap = data.badge_scaling_caps().get(map_name)
		for (cls, base), order in seen.items():
			if sum((cls, name) in loaded for name in order) >= 2:
				ladders.append((cls, base, order, cap))
	return ladders


def strength(party, cap=None):
	levels = [data.level_at(mon["level"], ELITE_FOUR_BADGES, cap) for mon in party["mons"]]
	return max(levels), min(levels), len(levels)


def weaker_steps(rev=None):
	"""Each step down a ladder: (earlier, its strength, later, its strength)."""
	groups = data.parties(rev)
	found = []
	for cls, base, order, cap in rematch_ladders():
		previous = None
		for name in order:
			current = (name, strength(data.party(groups, cls, name), cap))
			if previous and any(now < before for now, before in zip(current[1], previous[1])):
				found.append((previous[0], previous[1], name, current[1]))
			previous = current
	return found


def describe(found):
	return "\n".join("%s (highest %d, lowest %d, %d mon) then %s (highest %d, lowest %d, %d mon)"
		% (earlier, *before, later, *now) for earlier, before, later, now in found)


def test_ladders_found():
	"""The scripts still name the rematch ladders this check walks."""
	names = {base for _, base, _, _ in rematch_ladders()}
	assert {"ALAN", "JACK", "ERIN", "TIFFANY", "ANTHONY", "JOEY"} <= names


def test_rematches_never_get_weaker():
	"""Each rematch's highest level, lowest level and party size are at least the last one's."""
	found = [step for step in weaker_steps() if (step[0], step[2]) not in KNOWN_WEAKER]
	assert not found, "rematches that get weaker:\n" + describe(found)


@pytest.mark.xfail(bool(KNOWN_WEAKER), strict=True, reason="still weaker: "
	+ "; ".join("%s then %s" % step for step in sorted(KNOWN_WEAKER)))
def test_known_weaker_rematches_are_fixed():
	"""Passes, and so fails as an unexpected pass, once a known step is fixed: then take it off the list."""
	if not KNOWN_WEAKER:
		pytest.skip("no known weaker rematches")
	found = {(step[0], step[2]) for step in weaker_steps()}
	assert not (KNOWN_WEAKER & found)


def has_revision(rev):
	return subprocess.run(["git", "cat-file", "-e", rev], cwd=data.ROOT, capture_output=True).returncode == 0


def test_check_finds_the_fixed_rematches():
	"""Run on the parties from before the rebalance, the check finds the four it fixed."""
	if not has_revision("fb7c9e485"):
		pytest.skip("fb7c9e485 isn't in this clone's history")
	later = {step[2] for step in weaker_steps("fb7c9e485^")}
	assert {"ALAN4", "JACK5", "ERIN3", "TIFFANY2"} <= later
