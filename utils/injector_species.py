"""What the starter injector's page shows of the game's own species: base stats, the moves each learns
(by level, by TM/HM/tutor and as egg moves) for its move marks, its icon colors, and its art for the
previews, copied beside the data. Used by utils/export_injector_data.py.

Art per form: a form with its own folder (gfx/pokemon/<species>_<form>/) uses its pics if it has them,
and its normal.pal / shiny.pal if it has them; otherwise its species' art and colors.
"""

import re
import shutil

from export_injector_data import ROOT, read

STATS = 6


def rgb_pairs(path):
	"""The colors of a .pal file of RGB lines (0-31 a channel)."""
	if not path.exists():
		return None
	return [[int(r), int(g), int(b)] for r, g, b in re.findall(r"RGB\s+(\d+),\s*(\d+),\s*(\d+)", path.read_text(encoding="utf-8"))]


def table_rows(text, label, pattern):
	"""The rows after `label:` matching pattern (one per species, from index 1), until one doesn't."""
	rows = []
	for line in text.split(label + ":", 1)[1].splitlines():
		m = re.match(pattern, line)
		if m:
			rows.append(m.groups())
		elif rows and line.strip() and not line.strip().startswith(";") and "table_width" not in line:
			break
	return rows


def blocks(text, suffix):
	"""Each `<Name><suffix>:` block's lines, by name."""
	out = {}
	for m in re.finditer(r"^[ \t]*(\w+%s):\n(.*?)(?=^[ \t]*\w+:|\Z)" % suffix, text, re.M | re.S):
		out[m.group(1)] = m.group(2)
	return out


def icon_names():
	"""Each species' icon file (gfx/icons/<name>.png), by species index: its row of the game's icon
	table, or, where that row is 0 (Pikachu, Unown), the first icon in its forms' icon table."""
	files = {}
	for path in ("gfx/icons.asm", "gfx/cosmetic_icons.asm"):
		# Most labels end in Icon, not all (Piloswine::)
		files.update(re.findall(r'^(\w+)::\s+INCBIN "gfx/icons/(\w+)\.2bpp"', read(path), re.M))
	rows = re.findall(r"^\tdw (\w+)", read("data/pokemon/icon_pointers.asm").split("IconPointers:", 1)[1], re.M)
	forms_text = read("data/pokemon/cosmetic_form_icon_pointers.asm")
	# The forms' master table starts at index 1
	form_rows = re.findall(r"^\tdw (\w+)", forms_text.split("CosmeticFormIconPointersTable:", 1)[1], re.M)
	names = {}
	for index, label in enumerate(rows):
		if label == "0" and 0 < index <= len(form_rows) and form_rows[index - 1] != "0":
			table = form_rows[index - 1]
			label = re.search(r"^%s:\n(?:\t.*\n)*?\tdw (\w+)" % table, forms_text, re.M).group(1)
		if label in files:
			names[index] = files[label]
	return names


def gbc_colors(data):
	"""RGB (0-31 a channel) of little-endian 15-bit colors."""
	words = [data[i] | data[i + 1] << 8 for i in range(0, len(data), 2)]
	return [[w & 31, w >> 5 & 31, w >> 10 & 31] for w in words]


def form_palettes():
	"""Each species with a forms' palette table (data/pokemon/cosmetic_palettes.asm): its forms'
	(normal, shiny) colors, by form number. A form's normal colors are a .gbcpal's middle two (which
	may be another species' or form's, as Surf and Fly Pikachu take Pikachu's) or a .pal's."""
	pointers = read("data/pokemon/cosmetic_form_palette_pointers.asm").split("CosmeticFormPalettePointersTable:", 1)[1]
	rows = re.findall(r"^\tdw (\w+)\s*;\s*(\w+)", pointers, re.M)
	text = read("data/pokemon/cosmetic_palettes.asm")
	out = {}
	for table, species in rows:
		if table == "0":
			continue
		block = text.split(table + ":", 1)[1].split("assert_table_length", 1)[0]
		colors = []
		for kind, path, rest in re.findall(r'^\s*(INCBIN|INCLUDE)\s+"([^"]+)"([^\n]*)', block, re.M):
			if kind == "INCBIN":
				assert "middle_colors" in rest, (table, path)
				colors.append(gbc_colors((ROOT / path).read_bytes()[2:6]))
			else:
				colors.append(rgb_pairs(ROOT / path))
		out[species] = [tuple(colors[i:i + 2]) for i in range(0, len(colors), 2)]
	return out


def details(species, forms, form_values, base_files, evos_labels, new_slots, out):
	"""{species: its details}; copies each species' and form's art to out/art/<folder>/."""
	evos = blocks(read("data/pokemon/evos_attacks_kanto.asm") + read("data/pokemon/evos_attacks_johto.asm"), "EvosAttacks")
	egg_text = read("data/pokemon/egg_moves_kanto.asm") + read("data/pokemon/egg_moves_johto.asm")
	egg_labels = re.findall(r"^\tdw (\w+EggMoves\d?)\s*(?:;.*)?$", egg_text, re.M)
	egg_blocks = blocks(egg_text, r"EggMoves\d?")
	orders = [g[0] for g in table_rows(read("data/pokemon/icon_palette_order.asm"), "IconPaletteOrders", r"^\tdb ([\w |]+?)\s*(?:;.*)?$")]
	alt = {m.group(1): m.group(2) for m in re.finditer(r'^\tdw (\w+)[^\n]*\nINCLUDE "([^"]+)"', read("data/pokemon/alt_shiny_palettes.asm"), re.M)}
	# Written afresh, so art an earlier export copied (a form no longer offered) doesn't linger
	art_out = out / "art"
	shutil.rmtree(art_out, ignore_errors=True)
	icons = icon_names()
	palettes = form_palettes()

	def copy_art(folder, icon_name):
		"""Copy a folder's pics and an icon; which of them were there."""
		src = ROOT / "gfx/pokemon" / folder
		have = {}
		for name in ("front.png", "back.png"):
			if (src / name).exists():
				(art_out / folder).mkdir(parents=True, exist_ok=True)
				shutil.copyfile(src / name, art_out / folder / name)
				have[name.removesuffix(".png")] = True
		icon = ROOT / "gfx/icons" / (icon_name + ".png")
		if icon.exists():
			(art_out / folder).mkdir(parents=True, exist_ok=True)
			shutil.copyfile(icon, art_out / folder / "icon.png")
			have["icon"] = True
		return have

	result = {}
	index = 0
	for n, base_file, evos_label in zip(species, base_files, evos_labels):
		index += 1
		if n in new_slots:
			continue
		base_text = (ROOT / base_file).read_text(encoding="utf-8")
		stats = re.search(r"^\tdb\s+(\d+),\s*(\d+),\s*(\d+),\s*(\d+),\s*(\d+),\s*(\d+)\s*$", base_text, re.M).groups()
		tmhm = re.search(r"^\ttmhm(.*)$", base_text, re.M).group(1)
		hatch = int(re.search(r"^\tdb (\d+) ; step cycles to hatch", base_text, re.M).group(1))
		evo_block = evos[evos_label]
		learnset = [[int(l), m] for l, m in re.findall(r"^\tdbw (\d+),\s*(\w+)", evo_block.split("no more evolutions", 1)[1], re.M)]
		egg = re.findall(r"^\tdw (\w+)", egg_blocks.get(egg_labels[index - 1], ""), re.M)
		folder = n.lower()
		have = copy_art(folder, icons.get(index, folder))
		entry = {
			"base": [int(x) for x in stats],
			"learnset": learnset,
			"eggMoves": [m for m in egg if m != "-1"],
			"tmhm": [m.strip() for m in tmhm.split(",") if m.strip()],
			"hatchCycles": hatch,
			"iconPaletteOrder": [f.strip() for f in orders[index - 1].split("|") if f.strip() != "ICON_PAL_NORMAL"],
			"art": {"folder": folder, **have, "shiny": rgb_pairs(ROOT / "gfx/pokemon" / folder / "shiny.pal")},
		}
		if n in alt:
			entry["art"]["altShiny"] = rgb_pairs(ROOT / alt[n])
		form_art = {}
		for f in forms.get(n, []):
			name = f.lower()
			suffix = name.removeprefix(folder + "_").removesuffix("_form")
			fd = name if n == "UNOWN" else folder + "_" + suffix
			if not (ROOT / "gfx/pokemon" / fd).is_dir():
				continue
			art = {"folder": fd, **copy_art(fd, fd)}
			if n in palettes:
				# The game's own table says which colors each form takes
				normal, shiny = palettes[n][form_values[f]]
				art["normal"], art["shiny"] = normal, shiny
			else:
				for key, pal in (("normal", "normal.pal"), ("shiny", "shiny.pal")):
					colors = rgb_pairs(ROOT / "gfx/pokemon" / fd / pal)
					if colors:
						art[key] = colors
			form_art[f] = art
		if form_art:
			entry["formArt"] = form_art
		result[n] = entry
	return result
