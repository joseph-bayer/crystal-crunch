"""Text that goes back to characters after a text command without saying so.

After a command such as text_ram, the text engine reads the next byte as another command. `line`,
`cont`, `para`, `done` and the rest are characters, only meant inside a string, so one placed
straight after a command is looked up in the command table and jumps somewhere it never should:
a `line` byte ran code in WRAM, a `done` byte jumped into the warp code. The debug E4 lineup and
picker printed the texts after theirs in ROM, over the edge of the box, and fifteen follower
lines ("…blew out a fireball…") could do anything. Text has to go back to characters with
text_start (or end with text_end)."""

import re

from harness import data

MACROS = "macros/scripts/text.asm"
DEFINITION = re.compile(r"^MACRO (\w+)\n\s*db ([^\n,;]+)", re.MULTILINE)


def macros():
	"""(text commands, macros that are characters inside a string)."""
	commands, characters = set(), set()
	for name, first in DEFINITION.findall(data.read(MACROS)):
		first = first.strip()
		if first.startswith('"'):
			characters.add(name)
		elif first.startswith("TX_") and first not in ("TX_START", "TX_START_ASM", "TX_END"):
			commands.add(name)
	return commands, characters


def strays():
	commands, characters = macros()
	for path in data.asm_files("**/*.asm"):
		if path.startswith(".claude/"):
			continue
		previous = None
		for number, line in enumerate(data.read(path).splitlines(), 1):
			line = data.code(line)
			if not line:
				continue
			word = line.split()[0]
			if previous in commands and word in characters:
				yield "%s:%d: %s right after %s" % (path, number, word, previous)
			previous = word


def test_the_macro_lists_are_read():
	commands, characters = macros()
	assert {"text_ram", "text_decimal", "text_far"} <= commands
	assert {"line", "cont", "para", "done", "prompt"} <= characters


def test_no_characters_straight_after_a_text_command():
	found = list(strays())
	assert not found, "add text_start (or end with text_end):\n" + "\n".join(found)
