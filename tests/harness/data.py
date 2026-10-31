"""Read data out of the source files, for the checks that need no ROM: text widths, trainer parties
and the scripts that load them.

Every reader takes an optional git revision, so a check can be pointed at the files as they were
before a fix and shown to fail on them."""

import glob
import re
import subprocess
from functools import lru_cache

from .constants import ROOT

TEXTBOX_WIDTH = 18


def read(path, rev=None):
	"""A source file's text, from the working tree or from a git revision."""
	if rev is None:
		return (ROOT / path).read_text(encoding="utf-8")
	result = subprocess.run(["git", "show", "%s:%s" % (rev, path)], cwd=ROOT, capture_output=True,
		check=True)
	return result.stdout.decode("utf-8")


def asm_files(pattern):
	"""Paths under the repo, relative and with forward slashes, matching a glob."""
	return sorted(path.replace("\\", "/") for path in glob.glob(pattern, root_dir=ROOT, recursive=True))


def code(line):
	"""A line without its comment and surrounding space."""
	return line.split(";", 1)[0].strip()


# Numbers and constants

def number(text):
	text = text.strip()
	if text.startswith("$"):
		return int(text[1:], 16)
	if text.startswith("%"):
		return int(text[1:], 2)
	return int(text)


class Constants:
	"""The numeric constants a set of files defines, evaluated in order: `DEF NAME EQU/=/+= expr`,
	the const_def/const/const_skip/const_next counter, and the TM/HM macros' running count. Enough
	for the {d:NAME} interpolations in text, which name simple constants."""

	TMHM_MACROS = ("add_tm", "add_hm", "add_tmnum")

	def __init__(self):
		self.values = {}
		self.const_value = 0

	def eval(self, expr):
		expr = expr.strip()
		expr = re.sub(r"\$([0-9A-Fa-f]+)", lambda m: str(int(m.group(1), 16)), expr)
		expr = re.sub(r"%([01]+)", lambda m: str(int(m.group(1), 2)), expr)
		def name(m):
			key = m.group(0)
			if key == "const_value":
				return str(self.const_value)
			if key not in self.values:
				raise KeyError(key)
			return str(self.values[key])
		expr = re.sub(r"[A-Za-z_][A-Za-z0-9_]*", name, expr)
		if not re.fullmatch(r"[0-9+\-*/()<> ]+", expr):
			raise ValueError(expr)
		return int(eval(expr.replace("/", "//")))

	def feed(self, text):
		in_macro = False
		for line in text.splitlines():
			c = code(line)
			if c.startswith("MACRO"):
				in_macro = True
				continue
			if c.startswith("ENDM"):
				in_macro = False
				continue
			if in_macro:
				continue
			m = re.match(r"(object_)?const_def\b\s*(\S*)", c)
			if m:
				if m.group(1):
					self.const_value = 2 # the player and the follower come first
				else:
					try:
						self.const_value = self.eval(m.group(2)) if m.group(2) else 0
					except (KeyError, ValueError):
						self.const_value = 0
				continue
			m = re.match(r"const_next\s+(.+)", c)
			if m:
				try:
					self.const_value = self.eval(m.group(1))
				except (KeyError, ValueError):
					pass
				continue
			if re.match(r"const_skip\b", c):
				self.const_value += 1
				continue
			m = re.match(r"const\s+(\w+)", c)
			if m:
				self.values[m.group(1)] = self.const_value
				self.const_value += 1
				continue
			if c.split(" ", 1)[0] in self.TMHM_MACROS:
				self.values["__tmhm_value__"] = self.values.get("__tmhm_value__", 0) + 1
				continue
			m = re.match(r"DEF\s+(\w+)\s+(EQU|=|\+=)\s+(.+)", c)
			if m:
				key, op, expr = m.groups()
				try:
					value = self.eval(expr)
				except (KeyError, ValueError, SyntaxError):
					continue
				self.values[key] = self.values.get(key, 0) + value if op == "+=" else value


@lru_cache(maxsize=None)
def global_constants():
	"""The constants every file sees: the constants/ files, in the order includes.asm includes them."""
	constants = Constants()
	for path in re.findall(r'INCLUDE\s+"([^"]+)"', read("includes.asm")):
		if path.startswith("constants/"):
			constants.feed(read(path))
	return constants


# Text

TEXT_LINE_COMMANDS = ("text", "line", "cont", "para")

# Commands that print something of their own on the current line and keep it going: a `text`
# after one of them continues that line instead of starting a new box.
INLINE_COMMANDS = ("text_ram", "text_decimal", "text_bcd", "text_low")

# What the control characters print. Names count at their longest; "<USER>", "<TARGET>" and
# "<ENEMY>" vary with the battle, so they count as one tile, a lower bound.
EXPANSIONS = {
	"<PLAYER>": 7, "<PLAY_G>": 7, "<RIVAL>": 7, "<RED>": 7, "<GREEN>": 7, "<MOM>": 7,
	"#": 4, "<PKMN>": 2, "<POKE>": 2, "<……>": 2, "<PC>": 2, "<TM>": 2, "<TRAINER>": 7,
	"<ROCKET>": 6, "<USER>": 1, "<TARGET>": 1, "<ENEMY>": 1,
}


@lru_cache(maxsize=None)
def charmap_strings():
	"""{first character: every charmap string starting with it, longest first}. rgbds matches the
	longest one, so "'s" is one tile wherever it appears."""
	strings = set()
	for line in read("constants/charmap.asm").splitlines():
		m = re.match(r'\s*charmap\s+"([^"]*)"\s*,', line)
		if m and m.group(1):
			strings.add(m.group(1))
	by_first = {}
	for string in sorted(strings, key=len, reverse=True):
		by_first.setdefault(string[0], []).append(string)
	return by_first


def text_width(string, constants):
	"""How many tiles a string prints. {d:NAME} becomes the constant's digits; "@" ends it."""
	def interpolate(m):
		fmt, name = m.group(1), m.group(2)
		value = constants.values.get(name)
		if value is None:
			raise KeyError("can't work out {%s:%s}" % (fmt, name))
		return str(value)
	string = re.sub(r"\{(d):(\w+)\}", interpolate, string)
	if "{" in string:
		raise KeyError("can't work out the interpolation in %r" % string)
	string = string.split("@", 1)[0]
	strings = charmap_strings()
	width = 0
	i = 0
	while i < len(string):
		for token in strings.get(string[i], ()):
			if string.startswith(token, i):
				width += EXPANSIONS.get(token, 1)
				i += len(token)
				break
		else:
			width += 1
			i += 1
	return width


def text_lines(path, rev=None):
	"""Each text box line a file prints with text/line/cont/para, as (line number, command, the
	strings on that screen line, width). A `text` right after an inline command such as text_ram
	continues that line; the inline part counts as nothing, so the width is a lower bound."""
	source = read(path, rev)
	if not re.search(r'^\s*(?:text|line|cont|para)\s+"', source, re.M):
		return []
	constants = Constants()
	constants.values = dict(global_constants().values)
	constants.feed(source)
	result = []
	current = None
	previous = None
	for number_, line in enumerate(source.splitlines(), 1):
		c = code(line)
		if not c:
			continue
		m = re.match(r'(\w+)\s+"([^"]*)"\s*$', c)
		command = c.split(None, 1)[0]
		if m and m.group(1) in TEXT_LINE_COMMANDS:
			width = text_width(m.group(2), constants)
			if m.group(1) == "text" and previous in INLINE_COMMANDS and current is not None:
				current[2].append(m.group(2))
				current[3] += width
			else:
				current = [number_, m.group(1), [m.group(2)], width]
				result.append(current)
		elif command not in INLINE_COMMANDS:
			current = None
		previous = command
	return [tuple(entry) for entry in result]


# Trainers

@lru_cache(maxsize=None)
def trainer_classes():
	"""[(class, {trainer constant: index in its group, from 1})], in class order."""
	result = []
	for line in read("constants/trainer_constants.asm").splitlines():
		c = code(line)
		m = re.match(r"trainerclass\s+(\w+)", c)
		if m:
			result.append((m.group(1), {}))
			continue
		m = re.match(r"const\s+(\w+)", c)
		if m and result:
			members = result[-1][1]
			members[m.group(1)] = len(members) + 1
	return result


@lru_cache(maxsize=None)
def trainer_group_labels():
	"""{class: its parties' label}, from TrainerGroups (one entry per class, from class 1)."""
	labels = re.findall(r"dba\s+(\w+)", read("data/trainers/party_pointers.asm"))
	classes = [name for name, _ in trainer_classes()][1:]
	return dict(zip(classes, labels))


LEVEL_FROM_BADGES = 178
MIN_LEVEL = 2
MAX_LEVEL = 100


@lru_cache(maxsize=None)
def badge_base_levels():
	"""BadgeBaseLevels: the base level for each badge count, 0 to 16."""
	return [int(n) for n in re.findall(r"^\tdb +(\d+)", read("data/trainers/badge_base_levels.asm"), re.M)]


class ScaledLevel:
	"""A party level written LEVEL_FROM_BADGES + offset: the base level for the player's badge count
	plus the offset, kept within MIN_LEVEL to MAX_LEVEL. It has no level of its own, so it doesn't
	compare with a plain one; ask for it at a badge count."""

	def __init__(self, offset):
		self.offset = offset

	def at(self, badges, cap=None):
		"""The level with this many badges, counting no more than `cap` (a map's, see
		badge_scaling_caps)."""
		if cap is not None:
			badges = min(badges, cap)
		return max(MIN_LEVEL, min(MAX_LEVEL, badge_base_levels()[badges] + self.offset))

	def __eq__(self, other):
		return isinstance(other, ScaledLevel) and other.offset == self.offset

	def __hash__(self):
		return hash(("ScaledLevel", self.offset))

	def __repr__(self):
		return "LEVEL_FROM_BADGES %+d" % self.offset


def party_level(text):
	"""A party level byte as written: an int, or a ScaledLevel."""
	m = re.fullmatch(r"LEVEL_FROM_BADGES\s*(?:([+-])\s*(\d+))?", text.strip())
	if m:
		offset = int(m.group(2) or 0)
		return ScaledLevel(-offset if m.group(1) == "-" else offset)
	return int(text)


def level_at(level, badges, cap=None):
	"""A party level at a badge count, on a map with this badge cap: a plain level is itself."""
	return level.at(badges, cap) if isinstance(level, ScaledLevel) else level


@lru_cache(maxsize=None)
def badge_scaling_caps():
	"""{MAP_CONST: the most badges its scaled levels count}, from BadgeScalingCaps."""
	text = read("data/trainers/badge_scaling_caps.asm")
	return {m: int(cap) for m, cap in re.findall(r"map_id (\w+)\s*\n\s*db (\d+)", text)}


@lru_cache(maxsize=None)
def map_constants_by_file():
	"""{map file name (Route46): its constant (ROUTE_46)}, from data/maps/attributes.asm."""
	return dict(re.findall(r"map_attributes (\w+), (\w+),", read("data/maps/attributes.asm")))


WILD_TABLES = {
	"grass": ("data/wild/johto_grass.asm", "def_grass_wildmons", r"dbw\s+(.+?),\s*(\w+)$"),
	"water": ("data/wild/johto_water.asm", "def_water_wildmons", r"dbw\s+(.+?),\s*(\w+)$"),
	# the wandering mon's rosters: grass first, then water, a map in either or both
	"wanderers": ("data/wild/overworld_mons.asm", "def_ow_wildmons",
		r"ow_wildmon\s+\w+,\s*(\w+),\s*(.+?),"),
}


def wild_tables(kind, rev=None):
	"""[(map, [(level, species)])] for one kind of wild table, in file order (a map can appear twice
	among the wanderers: once for grass, once for water). A level is an int or a ScaledLevel."""
	path, opener, row = WILD_TABLES[kind]
	result = []
	for line in read(path, rev).splitlines():
		c = code(line)
		m = re.match(opener + r"\s+(\w+)", c)
		if m:
			result.append((m.group(1), []))
			continue
		m = re.match(row, c)
		if m and result:
			level, species = m.groups() if kind != "wanderers" else m.groups()[::-1]
			result[-1][1].append((party_level(level), species))
	return result


def parse_parties(text):
	"""{group label: [party]}. A party is {"name", "type", "mons"}; a mon is {"level", "species",
	"form", "item", "moves"}, with the fields its trainer type has. A level is an int, or a
	ScaledLevel for a LEVEL_FROM_BADGES one."""
	groups = {}
	group = None
	party = None
	words = []

	def flush():
		# The words after the name line: level, species, then the type's optional fields.
		mons = party["mons"]
		has_form = "FORM" in party["type"]
		has_item = "ITEM" in party["type"]
		has_moves = "MOVES" in party["type"]
		i = 0
		while i < len(words):
			mon = {"level": party_level(words[i]), "species": words[i + 1], "form": None, "item": None,
				"moves": None}
			i += 2
			if has_form:
				mon["form"] = words[i]
				i += 1
			if has_item:
				mon["item"] = words[i]
				i += 1
			if has_moves:
				mon["moves"] = tuple(words[i:i + 4])
				i += 4
			mons.append(mon)

	for line in text.splitlines():
		c = code(line)
		m = re.match(r"(\w+Group):", c)
		if m:
			group = groups.setdefault(m.group(1), [])
			party = None
			continue
		if c.startswith("next_list_item"):
			party = None
			continue
		m = re.match(r'db\s+"([^"]*)"\s*,\s*(.+)', c)
		if m and group is not None:
			party = {"name": m.group(1).rstrip("@"), "type": m.group(2), "mons": []}
			group.append(party)
			words = []
			continue
		if party is None:
			continue
		m = re.match(r"(db|dw)\s+(.+)", c)
		if not m:
			continue
		values = [v.strip() for v in m.group(2).split(",")]
		if values == ["-1"]:
			flush()
			party = None
			continue
		words.extend(values)
	return groups


def parties(rev=None):
	return parse_parties(read("data/trainers/parties.asm", rev))


def party(groups, trainer_class, trainer):
	"""The party a trainer constant names."""
	members = dict(trainer_classes())[trainer_class]
	return groups[trainer_group_labels()[trainer_class]][members[trainer] - 1]


@lru_cache(maxsize=None)
def trainer_battles():
	"""{map file: [(class, trainer constant)]}, each `trainer` event and `loadtrainer` in the order
	the file has them."""
	result = {}
	for path in asm_files("maps/*.asm"):
		battles = re.findall(r"^\s*(?:loadtrainer|trainer)\s+(\w+),\s*(\w+)", read(path), re.M)
		if battles:
			result[path] = battles
	return result
