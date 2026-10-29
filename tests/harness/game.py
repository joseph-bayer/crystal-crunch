"""A thin wrapper around PyBoy for the test ROM: buttons, waits, memory by symbol, event flags by
name, warps by map constant and the screen's text read back from wTilemap.

Everything is read from memory rather than pixels: PyBoy draws this hack's backgrounds wrong, but
the game's own copy of the screen (wTilemap) and its variables are exact."""

import io
import os
import re
from pathlib import Path

from pyboy import PyBoy

from . import constants

SCREEN_WIDTH = 20
SCREEN_HEIGHT = 18

MAPSETUP_WARP = 0xf1
MAPSTATUS_ENTER = 1
SPAWN_N_A = 0xff

CURSOR = "▶"

# Frames to hold a button, and to wait after letting go. Enough for menus and one overworld step.
PRESS_FRAMES = 3
SETTLE_FRAMES = 25
STEP_FRAMES = 16


class HarnessTimeout(AssertionError):
	pass


def rom_path():
	return Path(os.environ.get("TEST_ROM", constants.ROOT / "pokecrystal_test.gbc"))


class Game:
	def __init__(self, rom=None):
		rom = Path(rom or rom_path())
		self.rom = rom
		self.pyboy = PyBoy(
			str(rom),
			window="null",
			sound_emulated=False,
			cgb=True,
			symbols=str(rom.with_suffix(".sym")),
			log_level="ERROR",
		)
		self.pyboy.set_emulation_speed(0)
		# The clock is the one input from outside the emulator; frozen, every run sees the same time.
		self.pyboy.rtc_lock_experimental(True)

	def close(self):
		self.pyboy.stop(save=False)

	# Time and buttons

	def wait(self, frames):
		self.pyboy.tick(frames, False)

	def press(self, button, hold=PRESS_FRAMES, after=SETTLE_FRAMES):
		self.pyboy.button(button, hold)
		self.pyboy.tick(hold + after, False)

	def step(self, direction, steps=1):
		"""Walk in the overworld, holding the direction for one step each time."""
		for _ in range(steps):
			self.pyboy.button_press(direction)
			self.pyboy.tick(STEP_FRAMES, False)
			self.pyboy.button_release(direction)
			self.pyboy.tick(2, False)

	# States

	def save_state(self):
		buffer = io.BytesIO()
		self.pyboy.save_state(buffer)
		return buffer.getvalue()

	def load_state(self, data):
		self.pyboy.load_state(io.BytesIO(data))
		self.pyboy.rtc_lock_experimental(True)

	def screenshot(self, path):
		self.pyboy.tick(1, True)
		self.pyboy.screen.image.save(path)

	# Memory by symbol

	def _address(self, symbol):
		bank, address = self.pyboy.symbol_lookup(symbol)
		return bank, address

	def peek(self, symbol, offset=0, count=None):
		bank, address = self._address(symbol)
		values = [self._read(bank, address + offset + i) for i in range(count or 1)]
		return values if count else values[0]

	def poke(self, symbol, value, offset=0):
		bank, address = self._address(symbol)
		self._write(bank, address + offset, value)

	def _read(self, bank, address):
		if 0xd000 <= address < 0xe000:
			return self.pyboy.memory[bank, address]
		return self.pyboy.memory[address]

	def _write(self, bank, address, value):
		if 0xd000 <= address < 0xe000:
			self.pyboy.memory[bank, address] = value
		else:
			self.pyboy.memory[address] = value

	def seed_random(self, seed):
		"""Restart the test ROM's random sequence from a 16-bit seed (not 0), so a test can choose
		the next roll: the same seed always gives the same numbers in the same order."""
		assert 0 < seed <= 0xffff, "the sequence needs a non-zero 16-bit seed"
		self.poke("hRandomAdd", seed & 0xff)
		self.poke("hRandomSub", seed >> 8)

	# Event flags by name

	def event_flag(self, name):
		number = constants.event_flags()[name]
		return bool(self.peek("wEventFlags", number // 8) & (1 << (number % 8)))

	def set_event_flag(self, name, value=True):
		number = constants.event_flags()[name]
		byte = self.peek("wEventFlags", number // 8)
		bit = 1 << (number % 8)
		self.poke("wEventFlags", (byte | bit) if value else (byte & ~bit), number // 8)

	# The map

	def current_map(self):
		return self.peek("wMapGroup"), self.peek("wMapNumber")

	def position(self):
		return self.peek("wXCoord"), self.peek("wYCoord")

	def in_map(self, map_name):
		return self.current_map() == constants.maps()[map_name]

	def warp(self, map_name, x, y, settle=200):
		"""Warp the way the warp script command does, then let the map load."""
		group, number = constants.maps()[map_name]
		self.poke("wMapGroup", group)
		self.poke("wMapNumber", number)
		self.poke("wXCoord", x)
		self.poke("wYCoord", y)
		self.poke("wDefaultSpawnpoint", SPAWN_N_A)
		self.poke("hMapEntryMethod", MAPSETUP_WARP)
		self.poke("wMapStatus", MAPSTATUS_ENTER)
		self.wait(settle)
		assert self.current_map() == (group, number), "the warp to %s didn't happen" % map_name
		assert self.position() == (x, y), "the warp to %s landed at %s" % (map_name, self.position())

	def object_shown(self, map_file, object_const):
		"""Whether a map object is unmasked on the current map, by its object_const_def name."""
		index = constants.map_objects(map_file)[object_const]
		return self.peek("wObjectMasks", index) == 0

	# The screen's text

	def screen_lines(self):
		chars = constants.charmap()
		tiles = self.peek("wTilemap", 0, SCREEN_WIDTH * SCREEN_HEIGHT)
		lines = []
		for row in range(SCREEN_HEIGHT):
			line = tiles[row * SCREEN_WIDTH:(row + 1) * SCREEN_WIDTH]
			lines.append("".join(chars.get(t, " ") if len(chars.get(t, " ")) == 1 else " " for t in line))
		return lines

	def screen_text(self):
		return "\n".join(self.screen_lines())

	def wait_for_text(self, text, timeout=600, step=10):
		for _ in range(0, timeout, step):
			if text in self.screen_text():
				return
			self.wait(step)
		raise HarnessTimeout("%r never appeared on screen. The screen:\n%s" % (text, self.screen_text()))

	def choose(self, item, tries=20):
		"""Move a menu's cursor to the row showing `item`, then press A. `item` must stand on its own,
		not inside a longer word: "NO" is not the NO in "SNORLAX"."""
		alone = re.compile(r"(?<![A-Za-z])%s(?![A-Za-z])" % re.escape(item))
		for _ in range(tries):
			lines = self.screen_lines()
			target = next((row for row, line in enumerate(lines) if alone.search(line)), None)
			cursor = next((row for row, line in enumerate(lines) if CURSOR in line), None)
			if target is None or cursor is None:
				self.wait(10)
				continue
			if cursor == target:
				self.press("a")
				return
			# Held a little longer than a plain press: in the bag, after switching pockets, a 3-frame
			# press every 28 frames was missed every time (cause not pinned down); 6 and 30 work.
			self.press("down" if cursor < target else "up", hold=6, after=30)
		raise HarnessTimeout("couldn't choose %r. The screen:\n%s" % (item, self.screen_text()))
