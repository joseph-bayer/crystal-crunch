"""What each map's Pokémon NPCs stand for (OverworldMonObjects).

Will's room's row was added after the table's end marker, so the lookup never reached it and his
Xatu drew as whatever graphics were left in its slot. Every row has to come before the end
marker, and every map that places a Pokémon NPC in a SPRITE_OW_MON_* slot needs a row that fills
that slot."""

import re

import pytest

from harness import data

TABLE = "data/maps/overworld_mons.asm"
NPC = re.compile(r"object_event\s+.*?SPRITE_OW_MON_(\d+),(?!.*OBJECTTYPE_WILDMON)")


def table_rows():
	"""({map constant: slots declared}, [maps whose row comes after the end marker])."""
	rows, late, current, ended = {}, [], None, False
	for line in data.read(TABLE).splitlines():
		line = data.code(line)
		if line == "db -1":
			ended = True
		elif line.startswith("ow_mon_map"):
			current = line.split()[1]
			rows[current] = 0
			if ended:
				late.append(current)
		elif line.startswith("ow_mon ") and current:
			rows[current] += 1
	return rows, late


def npc_slots():
	"""(map file, map constant, highest SPRITE_OW_MON_n its non-wanderer objects use)."""
	constants = data.map_constants_by_file()
	for path in data.asm_files("maps/*.asm"):
		slots = [int(n) for n in NPC.findall(data.read(path))]
		if slots:
			name = path.split("/")[-1][:-4]
			yield pytest.param(constants[name], max(slots), id=name)


def test_every_row_comes_before_the_end_marker():
	_, late = table_rows()
	assert not late, "rows after the end marker are never read: %s" % ", ".join(late)


@pytest.mark.parametrize("map_const, slot", list(npc_slots()))
def test_every_pokemon_npc_has_a_row(map_const, slot):
	rows, late = table_rows()
	assert map_const in rows and map_const not in late, "%s has no reachable row" % map_const
	assert rows[map_const] >= slot, "%s uses SPRITE_OW_MON_%d but its row declares %d" % (
		map_const, slot, rows[map_const])
