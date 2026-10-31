"""Read names out of the source tree, so tests can say EVENT_FOUGHT_MEWTWO or CERULEAN_CAVE_B1F
instead of numbers that move whenever a constant is added."""

import re
from functools import lru_cache
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def _number(text):
	text = text.strip()
	if text.startswith("$"):
		return int(text[1:], 16)
	if text.startswith("%"):
		return int(text[1:], 2)
	return int(text, 0)


def _consts(path):
	"""The value of every `const NAME` in an rgbds file that uses const_def, const, const_skip and
	const_next, in order."""
	values = {}
	value = 0
	step = 1
	for line in Path(path).read_text(encoding="utf-8").splitlines():
		code = line.split(";", 1)[0].strip()
		if re.match(r"object_const_def\b", code):
			value = 2 # the macro's const_def 2: the player and the follower come first
			continue
		m = re.match(r"const_def\b\s*([^,]*)(?:,\s*(.+))?", code)
		if m:
			value = _number(m.group(1)) if m.group(1).strip() else 0
			step = _number(m.group(2)) if m.group(2) else 1
			continue
		m = re.match(r"const_next\s+(\S+)", code)
		if m:
			value = _number(m.group(1))
			continue
		if re.match(r"const_skip\b", code):
			value += step
			continue
		m = re.match(r"const\s+(\w+)", code)
		if m:
			values[m.group(1)] = value
			value += step
	return values


@lru_cache(maxsize=None)
def event_flags():
	return _consts(ROOT / "constants" / "event_flags.asm")


@lru_cache(maxsize=None)
def maps():
	"""{MAP_NAME: (group, number)} from constants/map_constants.asm."""
	result = {}
	group = 0
	number = 0
	for line in (ROOT / "constants" / "map_constants.asm").read_text(encoding="utf-8").splitlines():
		code = line.split(";", 1)[0].strip()
		if code.startswith("MACRO") or code.startswith("ENDM"):
			continue
		if re.match(r"newgroup\b", code):
			group += 1
			number = 0
			continue
		m = re.match(r"map_const\s+(\w+)", code)
		if m:
			number += 1
			result[m.group(1)] = (group, number)
	return result


@lru_cache(maxsize=None)
def map_objects(map_file):
	"""{CONST: index into wObjectMasks} for the object_const_def list in maps/<map_file>.asm.
	object_const_def starts at 2: index 0 is the player and 1 the follower."""
	return _consts(ROOT / "maps" / (map_file + ".asm"))


@lru_cache(maxsize=None)
def charmap():
	"""{byte: text} for decoding the tilemap. Where several strings share a byte, the first one wins,
	so a letter is preferred over a later alias."""
	result = {}
	for path in (ROOT / "constants" / "charmap.asm",):
		for line in path.read_text(encoding="utf-8").splitlines():
			m = re.match(r'\s*charmap\s+"((?:[^"\\]|\\.)*)"\s*,\s*(\$[0-9a-fA-F]+|\d+)', line)
			if m:
				byte = _number(m.group(2))
				result.setdefault(byte, m.group(1))
	return result
