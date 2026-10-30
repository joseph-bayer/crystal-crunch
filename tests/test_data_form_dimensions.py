"""Form sprites drawn at their base species' size.

A form with its own front sprite is drawn with its species' dimensions unless the species has a row
in CosmeticFormDimensionsPointersTable pointing at a per-form table (gfx/pokemon/cosmetic_dimensions.asm).
When Sour Crystal's Tentacruel and Graveler came in at 7x7, their RB forms stayed 6x6 and were drawn
garbled, because neither species had a row. So every form whose sprite is a different size from its
base must be listed in its species' table."""

import re

import pytest
from PIL import Image

from harness import data

POKEMON = data.ROOT / "gfx" / "pokemon"
POINTERS = data.ROOT / "gfx" / "pokemon" / "cosmetic_form_dimensions_pointers.asm"
TABLES = data.ROOT / "gfx" / "pokemon" / "cosmetic_dimensions.asm"


def size(folder):
	return Image.open(POKEMON / folder / "front.png").size[0]


def species_tables():
	"""{species folder: [the form folders its dimensions table lists]} for species that have one."""
	rows = dict((name.lower(), label) for label, name in
		re.findall(r"dw (\w+)\s*;\s*(\w+)", POINTERS.read_text(encoding="utf-8")))
	tables, current = {}, None
	for line in TABLES.read_text(encoding="utf-8").splitlines():
		label = re.match(r"(\w+):", line)
		if label:
			current = tables.setdefault(label.group(1), [])
		path = re.search(r'INCBIN "gfx/pokemon/(\w+)/front\.dimensions"', line)
		if path and current is not None:
			current.append(path.group(1))
	return {species: tables.get(label, []) for species, label in rows.items() if label != "0"}


def form_sprites():
	"""(form folder, base species folder) for every form with its own front sprite."""
	species = sorted((p.name for p in POKEMON.iterdir() if (p / "front.png").exists() and "_" not in p.name),
		key=len, reverse=True)
	for folder in sorted(POKEMON.iterdir()):
		if not (folder / "front.png").exists() or folder.name.startswith("unown_"):
			continue
		base = next((s for s in species if folder.name.startswith(s + "_")), None)
		if base:
			yield folder.name, base


@pytest.mark.parametrize("form, base", list(form_sprites()))
def test_form_sized_like_its_sprite(form, base):
	if size(form) == size(base):
		return
	listed = species_tables().get(base)
	assert listed is not None, "%s is %d pixels wide but %s is %d, and %s has no dimensions table" % (
		form, size(form), base, size(base), base.upper())
	assert form in listed, "%s's dimensions table doesn't list %s" % (base, form)
