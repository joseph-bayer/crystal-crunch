"""Pokémon pic animations that name frames their sprite doesn't have.

A front sprite's PNG stacks its animation frames, one square under the other, and its anim.asm and
anim_idle.asm show them by number (frame 0 is the plain pic). The scripts and sprites came from
different places over time (vanilla, Crystal Legacy, Sour Crystal); a script that names a frame past
the bottom of its sheet draws garbage tiles. dorepeat jumps to a command by its index, so that
index has to be a command of the same script."""

import re

import pytest
from PIL import Image

from harness import data

POKEMON = data.ROOT / "gfx" / "pokemon"


def commands(path):
	"""[(op, [numbers])] for each command in an animation script."""
	out = []
	for line in path.read_text(encoding="utf-8").splitlines():
		line = line.split(";")[0].strip()
		if not line:
			continue
		op, _, args = line.partition(" ")
		out.append((op, [int(a.strip().lstrip("$"), 16 if a.strip().startswith("$") else 10)
			for a in args.split(",") if a.strip()]))
	return out


def frame_count(folder):
	width, height = Image.open(folder / "front.png").size
	return height // width


def scripts():
	for folder in sorted(POKEMON.iterdir()):
		if not (folder / "front.png").exists():
			continue
		for name in ("anim.asm", "anim_idle.asm"):
			if (folder / name).exists():
				yield folder, name


@pytest.mark.parametrize("folder, name", [pytest.param(f, n, id="%s/%s" % (f.name, n)) for f, n in scripts()])
def test_script_fits_its_sprite(folder, name):
	cmds = commands(folder / name)
	frames = frame_count(folder)
	for index, (op, args) in enumerate(cmds):
		assert op in ("frame", "setrepeat", "dorepeat", "endanim"), "%s line %d: unknown %s" % (name, index, op)
		if op == "frame":
			assert args[0] < frames, "%s command %d shows frame %d, but the sprite has %d" % (
				name, index, args[0], frames)
		if op == "dorepeat":
			# Vanilla's Cloyster and Krabby idles repeat from themselves or ahead; with no setrepeat
			# before them the count is 0 and the game moves on, so only the index's range matters.
			assert args[0] < len(cmds), "%s command %d repeats from %d, past the script's end" % (
				name, index, args[0])
	assert cmds and cmds[-1][0] == "endanim", "%s doesn't end with endanim" % name
