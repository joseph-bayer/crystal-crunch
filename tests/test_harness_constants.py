"""The harness's reading of the source's constants, which every test's names go through."""

import re

from harness import constants


def test_const_align_starts_the_next_constant_on_its_boundary():
	"""The key items, balls and TMs each start a new $100 (const_align 8): without it, the ball the
	starter was caught in, or any key item, was read as some other item."""
	path = constants.ROOT / "constants" / "item_constants.asm"
	values = constants._consts(path)
	lines = path.read_text(encoding="utf-8").splitlines()
	aligned = 0
	for i, line in enumerate(lines):
		m = re.match(r"\s*const_align\s+(\d+)", line)
		if not m:
			continue
		first = next(re.match(r"\s*const\s+(\w+)", l).group(1) for l in lines[i + 1:] if re.match(r"\s*const\s+\w", l))
		assert values[first] % (1 << int(m.group(1))) == 0, first
		aligned += 1
	assert aligned == 3
	assert (values["MASTER_BALL"], values["POKE_BALL"], values["PARK_BALL"]) == (0x200, 0x203, 0x20b)
