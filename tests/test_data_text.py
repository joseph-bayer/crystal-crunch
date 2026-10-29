"""Text box lines that are too wide for the box.

A text box line holds 18 tiles. Two lines once didn't fit: a Goldenrod Rocket's "stronger than
ever!" and the lab aide's follower tip. Nothing in the build catches it, and the extra letters
run into the box's border.

Widths are counted the way rgbds encodes the string: "'s", "'t" and the other ligatures are one
tile, "#" prints POKé (four), names count at their longest, and {d:NAME} becomes its digits."""

import subprocess

import pytest

from harness import data

# Text that lives in the source tree and prints in a text box.
SOURCES = ["maps/*.asm", "data/**/*.asm", "engine/**/*.asm", "home/**/*.asm", "mobile/**/*.asm"]

# Lines known to be too wide, by file and text, until they're rewritten.
KNOWN_TOO_WIDE = {
	("maps/PlayersHouse2F.asm", "on their own again."),
}


def too_wide(paths, rev=None):
	found = []
	for path in paths:
		for line, command, strings, width in data.text_lines(path, rev):
			if width > data.TEXTBOX_WIDTH:
				found.append((path, line, command, "".join(strings), width))
	return found


def all_sources():
	paths = []
	for pattern in SOURCES:
		paths.extend(data.asm_files(pattern))
	return paths


def describe(found):
	return "\n".join('%s:%d %s "%s" is %d tiles' % entry for entry in found)


def test_text_box_lines_fit():
	found = [entry for entry in too_wide(all_sources()) if (entry[0], entry[3]) not in KNOWN_TOO_WIDE]
	assert not found, "text box lines wider than %d tiles:\n%s" % (data.TEXTBOX_WIDTH, describe(found))


@pytest.mark.xfail(strict=True, reason="still too wide: "
	+ "; ".join('%s "%s"' % entry for entry in sorted(KNOWN_TOO_WIDE)))
def test_known_wide_lines_are_fixed():
	"""Passes, and so fails as an unexpected pass, once a known line fits: then take it off the list."""
	found = {(entry[0], entry[3]) for entry in too_wide(sorted({path for path, _ in KNOWN_TOO_WIDE}))}
	assert not (KNOWN_TOO_WIDE & found)


def has_revision(rev):
	return subprocess.run(["git", "cat-file", "-e", rev], cwd=data.ROOT, capture_output=True).returncode == 0


@pytest.mark.parametrize("fix, path, text", [
	("c02b95cf7", "maps/GoldenrodCity.asm", "stronger than ever!"),
	("032b9c432", "maps/ElmsLab.asm", "Open your party and"),
])
def test_check_finds_the_fixed_lines(fix, path, text):
	"""The check, run on the files from before each fix, finds the line that was fixed."""
	if not has_revision(fix):
		pytest.skip("%s isn't in this clone's history" % fix)
	found = [entry[3] for entry in too_wide([path], fix + "^")]
	assert text in found
