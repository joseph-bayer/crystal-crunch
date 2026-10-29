#!/usr/bin/env python3
"""
Usage: python utils/ow_mon_check.py

Checks each map's wandering Pokemon against its objects. A map is reported when:

- the highest SPRITE_OW_MON_n among its objects isn't its slot count: static entries plus grass
  and water roster counts (or plus its population's count), capped at NUM_OW_MON_SLOTS;
- a rolled slot doesn't have exactly one OBJECTTYPE_WILDMON object;
- it has more objects than NUM_OBJECTS - 2 (the player and the follower take two);
- its slots plus its distinct other Pokemon-colored sprites (palette 0) need more than
  NUM_OW_MON_PALS color pairs, past which a mon is drawn in palette 0, flat red;
- its object_const_def names wanderers (<MAP>_WILD_MON_n) that don't match its wandering
  SPRITE_OW_MON objects: one constant per wanderer, at the same index.

Prints nothing and exits 0 when every map passes.
"""

import glob
import os
import re
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')

def path(*parts):
	return os.path.join(ROOT, *parts)

def read_lines(*parts):
	with open(path(*parts), encoding='utf-8') as f:
		return [line.split(';', 1)[0].rstrip() for line in f]

def number(text):
	text = text.strip()
	if text.startswith('$'):
		return int(text[1:], 16)
	if text.startswith('%'):
		return int(text[1:], 2)
	return int(text)

def find_const(lines, name):
	for line in lines:
		m = re.match(r'\s*DEF\s+' + name + r'\s+EQU\s+(\S+)$', line)
		if m:
			return number(m.group(1))
	sys.exit(f'ow_mon_check: {name} not found')

def read_sprite_constants():
	"""Sprite ids by name, following const_def / const / const_next / const_skip."""
	values = {}
	value = 0
	for line in read_lines('constants', 'sprite_constants.asm'):
		words = line.replace(',', ' ').split()
		if not words:
			continue
		if words[0] == 'const_def':
			value = number(words[1]) if len(words) > 1 else 0
		elif words[0] == 'const_next':
			value = number(words[1])
		elif words[0] == 'const_skip':
			value += number(words[1]) if len(words) > 1 else 1
		elif words[0] == 'const':
			values[words[1]] = value
			value += 1
		elif words[0] == 'DEF' and len(words) >= 4 and words[2] == 'EQU' and words[3] == 'const_value':
			values[words[1]] = value
	return values

def read_maps():
	"""{map constant: (map name, width, height)}"""
	sizes = {}
	for line in read_lines('constants', 'map_constants.asm'):
		m = re.match(r'\s*map_const\s+(\w+)\s*,\s*(\d+)\s*,\s*(\d+)', line)
		if m:
			sizes[m.group(1)] = (int(m.group(2)), int(m.group(3)))
	maps = {}
	for line in read_lines('data', 'maps', 'attributes.asm'):
		m = re.match(r'\s*map_attributes\s+(\w+)\s*,\s*(\w+)', line)
		if m:
			maps[m.group(2)] = (m.group(1),) + sizes[m.group(2)]
	return maps

def read_map_files():
	"""{map name: file} from each map's <Name>_MapScripts label."""
	files = {}
	for filename in glob.glob(path('maps', '*.asm')):
		with open(filename, encoding='utf-8') as f:
			for line in f:
				m = re.match(r'(\w+)_MapScripts:', line)
				if m:
					files[m.group(1)] = filename
	return files

def read_statics():
	"""{map constant: number of static entries}"""
	statics = {}
	current = None
	for line in read_lines('data', 'maps', 'overworld_mons.asm'):
		words = line.replace(',', ' ').split()
		if not words:
			continue
		if words[0] == 'ow_mon_map':
			current = words[1]
			statics[current] = 0
		elif words[0] == 'ow_mon':
			statics[current] += 1
	return statics

def read_rosters():
	"""({map constant: grass count}, {map constant: water count})"""
	grass, water = {}, {}
	table = None
	current = None
	for line in read_lines('data', 'wild', 'overworld_mons.asm'):
		if line.startswith('OverworldWildMonsGrass:'):
			table = grass
		elif line.startswith('OverworldWildMonsWater:'):
			table = water
		words = line.replace(',', ' ').split()
		if not words:
			continue
		if words[0] == 'def_ow_wildmons':
			current = words[1]
		elif words[0] == 'db' and current is not None:
			if current in table:
				sys.exit(f'ow_mon_check: {current} has two rosters in one table')
			table[current] = number(words[1])
			current = None
	return grass, water

def read_populations():
	"""{map constant: member count}"""
	populations = {}
	for line in read_lines('data', 'wild', 'mon_populations.asm'):
		m = re.match(r'\s*def_population\s+(\w+)\s*,\s*\w+\s*,\s*(\S+)', line)
		if m:
			populations[m.group(1)] = number(m.group(2))
	return populations

def read_map_file(filename):
	"""(object constants as [(name, value)], objects as [argument lists])"""
	consts = []
	objects = []
	in_consts = False
	value = 0
	with open(filename, encoding='utf-8') as f:
		for line in f:
			line = line.split(';', 1)[0].strip()
			words = line.replace(',', ' ').split()
			if words[:1] == ['object_const_def']:
				in_consts = True
				value = 2 # the player is object 0 and the follower 1
				continue
			if in_consts:
				if words[:1] == ['const']:
					consts.append((words[1], value))
					value += 1
					continue
				if words[:1] == ['const_skip']:
					value += number(words[1]) if len(words) > 1 else 1
					continue
				in_consts = False
			if words[:1] == ['object_event']:
				args = [arg.strip() for arg in line[len('object_event'):].split(',')]
				objects.append(args)
	return consts, objects

def palette_is_default(arg):
	return arg in ('0', 'PAL_NPC_DEFAULT')

def main():
	sprites = read_sprite_constants()
	object_lines = read_lines('constants', 'map_object_constants.asm')
	max_objects = find_const(object_lines, 'NUM_OBJECTS') - 2
	num_pals = find_const(read_lines('constants', 'sprite_data_constants.asm'), 'NUM_OW_MON_PALS')
	ow_mon = sprites['SPRITE_OW_MON']
	# DEF NUM_OW_MON_SLOTS EQU const_value - SPRITE_OW_MON, read above as const_value alone
	num_slots = sprites['NUM_OW_MON_SLOTS'] - ow_mon
	sprite_pokemon = sprites['SPRITE_POKEMON']
	other_mon_sprites = {sprites[name] for name in (
		'SPRITE_DAY_CARE_MON_1', 'SPRITE_DAY_CARE_MON_2',
		'SPRITE_SUICUNE', 'SPRITE_ENTEI', 'SPRITE_RAIKOU')}

	maps = read_maps()
	files = read_map_files()
	statics = read_statics()
	grass, water = read_rosters()
	populations = read_populations()

	problems = []
	for const, (name, width, height) in sorted(maps.items()):
		filename = files.get(name)
		if filename is None:
			continue
		consts, objects = read_map_file(filename)
		where = f'{const} ({os.path.relpath(filename, ROOT)})'

		if len(objects) > max_objects:
			problems.append(f'{where}: {len(objects)} objects, more than {max_objects}')

		static = statics.get(const, 0)
		if const in populations:
			rolled = populations[const]
			if const in grass or const in water:
				problems.append(f'{where}: has a population and a grass or water roster')
		else:
			rolled = grass.get(const, 0) + water.get(const, 0)
		slots = min(num_slots, static + rolled)

		def slot_of(obj):
			sprite = sprites.get(obj[2])
			if sprite is not None and ow_mon <= sprite < ow_mon + num_slots:
				return sprite - ow_mon + 1
			return None

		used = [slot_of(obj) for obj in objects]
		highest = max((slot for slot in used if slot), default=0)
		if highest != slots:
			problems.append(f'{where}: highest SPRITE_OW_MON is {highest}, but static {static} + '
				f'rolled {rolled} gives {slots}')

		for slot in range(static + 1, slots + 1):
			count = sum(1 for obj, s in zip(objects, used) if s == slot and obj[9] == 'OBJECTTYPE_WILDMON')
			if count != 1:
				problems.append(f'{where}: rolled slot {slot} has {count} OBJECTTYPE_WILDMON objects, not 1')

		slot_ids = {s for s in used if s}
		others = set()
		for obj in objects:
			sprite = sprites.get(obj[2])
			if sprite is None or not palette_is_default(obj[8]):
				continue
			if (sprite_pokemon <= sprite < ow_mon) or sprite in other_mon_sprites:
				others.add(obj[2])
		colors = max(slots, len(slot_ids)) + len(others)
		if colors > num_pals:
			extra = ', '.join(sorted(others))
			problems.append(f'{where}: {max(slots, len(slot_ids))} slots + {len(others)} other Pokemon '
				f'sprites ({extra}) need {colors} color pairs, more than {num_pals}')

		named = [(cname, value) for cname, value in consts if re.search(r'_WILD_MON_\d+$', cname)]
		if named:
			wanderers = [i + 2 for i, (obj, s) in enumerate(zip(objects, used))
				if s and obj[9] == 'OBJECTTYPE_WILDMON']
			for k, (cname, value) in enumerate(named, 1):
				if not cname.endswith(f'_WILD_MON_{k}'):
					problems.append(f'{where}: {cname} is wild mon constant {k}')
			if len(named) != len(wanderers):
				problems.append(f'{where}: {len(named)} _WILD_MON_ constants for {len(wanderers)} wanderers')
			for (cname, value), index in zip(named, wanderers):
				if value != index:
					problems.append(f'{where}: {cname} is {value}, but its wanderer is object {index}')

	for problem in problems:
		print(problem)
	return 1 if problems else 0

if __name__ == '__main__':
	sys.exit(main())
