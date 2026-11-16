#!/usr/bin/env python3
"""
Pokemon TCG (GBC) Music to Pokemon Crystal Song Converter

Reads a song from the pret poketcg / poketcg2 disassemblies (src/audio/music/*.asm)
and writes the same song as a Crystal song .asm for this engine.

The conversion keeps the sound registers the TCG engine would write:
- Pitches: each TCG (octave, note) maps to the Crystal (octave, note) with the same
  frequency register value. TCG pulse `octave n` uses pitch-table row n-1 and the
  wave channel uses row n; Crystal `octave n` uses FrequencyTable shifted n-1 times.
  The script checks every played note and reports any that don't match exactly.
- Timing: TCG music ticks at ~60.24 Hz and a note lasts length * speed ticks.
  `tempo 254` on Crystal's 59.73 Hz frame gives the same speed, so `speed s`
  becomes `note_type s, ...` (or `drum_speed s`).
- `cutoff`/`echo` become `note_cutoff`/`release_envelope`.
- `vibrato_type`/`vibrato_delay` become `vibrato_table`, which plays TCG's own vibrato
  tables (audio/vibrato_tables.asm) with TCG's timing. --square-vibrato instead uses the
  closest Crystal `vibrato` (see VIBRATO_TYPES).
- Ch4 drum notes keep their TCG instrument numbers and play from a Crystal drumkit
  generated from the TCG noise instruments frame for frame with noise_step /
  noise_freq_step (see --instruments).

`tie` keeps TCG's order (note, tie, note): the second note changes pitch without
restarting. TCG never releases a note followed by tie, so such a note under cutoff 1-7
is wrapped in `note_cutoff 0` / `note_cutoff c`.

Anything this script doesn't know how to convert stops it with an error, rather than
guessing.

Usage:
    Convert a song:
        python tools/joe_tools/tcg_music_to_crystal.py SONG.asm SongName
            [--channels LABEL1,LABEL2,LABEL3,LABEL4] [--wave TCG=CRYSTAL ...]
            [--drumkit N] [--square-vibrato] [-o OUTPUT.asm]

        SongName is the Crystal label stem (Music_<SongName>). Channel labels default
        to the labels ending in _Ch1.._Ch4. The output defaults to
        audio/music/<songname>.asm.

    Print the wave samples and drumkit to paste into audio/wave_samples.asm and
    audio/drumkits.asm:
        python tools/joe_tools/tcg_music_to_crystal.py --instruments TCG_AUDIO_DIR
            --waves 1 [--drumkit N] [--prefix Tcg]

Example (the TCG1 overworld theme):
    python tools/joe_tools/tcg_music_to_crystal.py \\
        ../../reference_projects/poketcg/src/audio/music/overworld.asm TcgOverworld \\
        --wave 1=10 --drumkit 6
"""

import argparse
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]

CRYSTAL_TEMPO = 254
CRYSTAL_FPS = 4194304 / 70224  # ~59.73 frames per second

# TCG vibrato type -> Crystal (extent, rate), for --square-vibrato.
# TCG type 9 plays one slow 12-frame swing (+-4) and then becomes type 8, which repeats
# 2, 4, 2, 0, -2, -4, -2, 0 forever: an 8-frame cycle peaking at +-4 frequency units.
# Crystal vibrato is a square wave: it holds +ceil(extent/2) / -floor(extent/2) for
# rate + 1 frames each, so rate 3 gives the same 8-frame cycle and extent 4 (+-2)
# keeps the pitch centered with a depth close to the TCG wave's average (+-2.45 RMS).
# Type 1 is type 8 at half depth (1, 2, 1, 0, -1, -2, -1, 0), so it gets half the extent.
# Type 4 holds +1, 0, -1, 0 for 3 frames each, a 12-frame cycle: +-1 with rate 5.
VIBRATO_TYPES = {
    1: (2, 3),
    4: (2, 5),
    8: (4, 3),
    9: (4, 3),
}

NOTE_NAMES = ["C_", "C#", "D_", "D#", "E_", "F_", "F#", "G_", "G#", "A_", "A#", "B_"]

DRUM_NOTES = {"bass": 1, "snare1": 3, "snare2": 5, "snare3": 7, "snare4": 9, "snare5": 12}

# TCG command byte sizes, for the size report
TCG_SIZES = {
    "note": 1, "rest": 1, "octave": 1, "inc_octave": 1, "dec_octave": 1, "tie": 1,
    "MainLoop": 1, "EndMainLoop": 1, "EndLoop": 1, "music_ret": 1, "music_end": 1,
    "speed": 2, "stereo_panning": 2, "Loop": 2, "frequency_offset": 2, "duty": 2,
    "volume_envelope": 2, "wave": 2, "cutoff": 2, "echo": 2, "vibrato_type": 2,
    "vibrato_delay": 2, "music_call": 3,
}
TCG_SIZES.update({name: 1 for name in DRUM_NOTES})

CRYSTAL_SIZES = {
    "note": 1, "rest": 1, "drum_note": 1, "octave": 1, "sound_ret": 1, "tie": 1,
    "drum_speed": 2, "volume_envelope": 2, "duty_cycle": 2, "note_cutoff": 2,
    "release_envelope": 2, "volume": 2, "toggle_noise": 2, "stereo_panning": 2,
    "note_type": 3, "vibrato": 3, "vibrato_table": 3, "tempo": 3, "sound_call": 3, "sound_loop": 4,
}

# Commands that end a straight run of song data; pending settings are written before them
CONTROL_COMMANDS = {"music_call", "music_ret", "music_end", "Loop", "EndLoop", "MainLoop", "EndMainLoop"}
TERMINATORS = {"music_ret", "music_end", "EndMainLoop"}


class ConvertError(Exception):
    pass


def parse_number(text):
    text = text.strip()
    if text == "TRUE":
        return 1
    if text == "FALSE":
        return 0
    negative = text.startswith("-")
    if negative:
        text = text[1:].strip()
    if text.startswith("$"):
        value = int(text[1:], 16)
    elif text.startswith("%"):
        value = int(text[1:], 2)
    else:
        value = int(text)
    return -value if negative else value


def envelope_args(byte):
    """Volume envelope byte -> (volume, fade) as the volume_envelope macros write it."""
    volume, low = byte >> 4, byte & 0xf
    if low & 8 and low & 7:
        return volume, -(low & 7)
    return volume, low


def envelope_byte(volume, fade):
    if fade < 0:
        return (volume << 4) | 8 | -fade
    return (volume << 4) | fade


# ---------------------------------------------------------------------------
# Crystal pitch table

def load_crystal_frequencies():
    """The 12 FrequencyTable entries GetFrequency shifts per octave."""
    text = (REPO_ROOT / "audio" / "notes.asm").read_text()
    values = [int(v, 16) for v in re.findall(r"dw\s+\$([0-9a-fA-F]+)", text)]
    if len(values) < 12:
        raise ConvertError("couldn't read FrequencyTable from audio/notes.asm")
    return values[:12]


def crystal_register(frequencies, octave, pitch):
    """Frequency register for Crystal `octave` (1-8) and pitch (1-12), as GetFrequency."""
    value = frequencies[pitch - 1]
    if value & 0x8000:
        value -= 0x10000
    value >>= octave - 1
    return value & 0x7ff


def load_tcg_pitches(song_path):
    """Music1_Pitches from the TCG engine next to the song."""
    audio_dir = Path(song_path).resolve().parent.parent
    for name in ("music1.asm", "music2.asm"):
        path = audio_dir / name
        if not path.exists():
            continue
        text = path.read_text()
        match = re.search(r"Music\d_Pitches:\s*\n((?:\s*dw\s+\$[0-9a-fA-F]+.*\n)+)", text)
        if match:
            return [int(v, 16) for v in re.findall(r"dw\s+\$([0-9a-fA-F]+)", match.group(1))]
    raise ConvertError(f"couldn't find the TCG pitch table near {song_path}")


# ---------------------------------------------------------------------------
# TCG song parsing

def parse_song(path):
    """Returns (items, labels): items are (command, args, line_number), labels map to item indexes."""
    items = []
    labels = {}
    for line_number, raw in enumerate(Path(path).read_text().splitlines(), 1):
        line = raw.split(";", 1)[0].rstrip()
        if not line.strip():
            continue
        label = re.match(r"^([A-Za-z_][A-Za-z0-9_]*)::?\s*$", line)
        if label:
            labels[label.group(1)] = len(items)
            continue
        if not line[0].isspace():
            raise ConvertError(f"line {line_number}: can't parse {raw.strip()!r}")
        parts = line.strip().split(None, 1)
        command = parts[0]
        args = [a.strip() for a in parts[1].split(",")] if len(parts) > 1 else []
        items.append((command, args, line_number))
    return items, labels


# ---------------------------------------------------------------------------
# Simulation: run each channel the way the TCG engine would, recording the state
# every command sees, so absolute Crystal commands can be written for relative TCG ones.

STATE_FIELDS = ("octave", "speed", "envelope", "wave", "cutoff", "echo", "vibrato_type",
    "vibrato_delay")


def initial_state(channel):
    return {
        "octave": None,
        "speed": None,
        "envelope": None,
        "wave": None,
        "cutoff": 0,
        "echo": 0x40 if channel >= 3 else 0x08,
        "vibrato_type": 0,
        "vibrato_delay": 0,
    }


def freeze(state):
    return tuple(state[f] for f in STATE_FIELDS)


def thaw(frozen):
    return dict(zip(STATE_FIELDS, frozen))


class Simulation:
    def __init__(self, items, labels, channel, start):
        self.items = items
        self.labels = labels
        self.channel = channel
        self.states = {}  # item index -> set of frozen states before it
        self.called = []  # branch labels in first-call order
        self.notes_played = set()  # (tcg octave row, pitch)
        self.needs_default_release = False
        self.implicit_mainloop = False  # EndMainLoop with no MainLoop loops to the channel start
        self.run(start)

    def label_target(self, name, line):
        if name not in self.labels:
            raise ConvertError(f"line {line}: unknown label {name}")
        return self.labels[name]

    def run(self, start):
        items = self.items
        state = initial_state(self.channel)
        echo_set = False
        pc = start
        call_stack = []
        loop_stack = []
        mainloop = None
        seen_loops = set()
        for _ in range(1_000_000):
            if pc >= len(items):
                raise ConvertError(f"channel {self.channel} runs off the end of the file")
            command, args, line = items[pc]
            self.states.setdefault(pc, set()).add(freeze(state))
            next_pc = pc + 1

            if command in ("note", "rest") or command in DRUM_NOTES:
                if command == "note":
                    pitch = NOTE_NAMES.index(args[0]) + 1 if args[0] in NOTE_NAMES else None
                    if pitch is None:
                        raise ConvertError(f"line {line}: unknown note {args[0]}")
                    if self.channel != 4:
                        if state["octave"] is None:
                            raise ConvertError(f"line {line}: note before any octave")
                        self.notes_played.add((state["octave"], pitch))
                        if state["envelope"] is None:
                            raise ConvertError(f"line {line}: note before any volume_envelope")
                        if self.channel == 3 and state["wave"] is None:
                            raise ConvertError(f"line {line}: note before any wave")
                        if 0 < state["cutoff"] < 8 and not echo_set:
                            self.needs_default_release = True
                if state["speed"] is None:
                    raise ConvertError(f"line {line}: note before any speed")
                length = parse_number(args[-1])
                if not 1 <= length <= 16:
                    raise ConvertError(f"line {line}: note length {length} out of range")
                if length * state["speed"] > 255:
                    raise ConvertError(f"line {line}: note lasts over 255 ticks")
            elif command == "speed":
                state["speed"] = parse_number(args[0])
            elif command == "octave":
                n = parse_number(args[0])
                state["octave"] = n if self.channel == 3 else n - 1
            elif command == "inc_octave":
                state["octave"] = self.require(state, "octave", line) + 1
            elif command == "dec_octave":
                state["octave"] = self.require(state, "octave", line) - 1
            elif command == "volume_envelope":
                state["envelope"] = envelope_byte(parse_number(args[0]), parse_number(args[1]))
            elif command == "wave":
                state["wave"] = parse_number(args[0])
            elif command == "cutoff":
                state["cutoff"] = parse_number(args[0])
            elif command == "echo":
                state["echo"] = parse_number(args[0])
                echo_set = True
            elif command == "vibrato_type":
                state["vibrato_type"] = parse_number(args[0])
            elif command == "vibrato_delay":
                state["vibrato_delay"] = parse_number(args[0])
            elif command in ("duty", "stereo_panning", "tie"):
                pass
            elif command == "music_call":
                if call_stack:
                    raise ConvertError(f"line {line}: nested music_call (Crystal allows one level)")
                target = args[0]
                if target not in self.called:
                    self.called.append(target)
                call_stack.append(next_pc)
                next_pc = self.label_target(target, line)
            elif command == "music_ret":
                if not call_stack:
                    raise ConvertError(f"line {line}: music_ret outside a call")
                next_pc = call_stack.pop()
            elif command == "Loop":
                if loop_stack:
                    raise ConvertError(f"line {line}: nested Loop (Crystal has one loop counter)")
                count = parse_number(args[0])
                if count < 1:
                    raise ConvertError(f"line {line}: Loop {count}")
                loop_stack.append([next_pc, count])
            elif command == "EndLoop":
                if not loop_stack:
                    raise ConvertError(f"line {line}: EndLoop without Loop")
                loop_stack[-1][1] -= 1
                if loop_stack[-1][1]:
                    next_pc = loop_stack[-1][0]
                else:
                    loop_stack.pop()
            elif command == "MainLoop":
                # loop back to the command after it, so MainLoop itself only sees the first pass
                mainloop = next_pc
            elif command == "EndMainLoop":
                if mainloop is None:
                    mainloop = start
                    self.implicit_mainloop = True
                key = freeze(state)
                if key in seen_loops:
                    return
                seen_loops.add(key)
                next_pc = mainloop
            elif command == "music_end":
                return
            else:
                raise ConvertError(f"line {line}: unsupported command {command}")
            pc = next_pc
        raise ConvertError(f"channel {self.channel} never settles into its main loop")

    @staticmethod
    def require(state, field, line):
        if state[field] is None:
            raise ConvertError(f"line {line}: {field} used before it's set")
        return state[field]

    def state_at(self, index, fields):
        """The value(s) of `fields` before item `index`; they must be the same every time."""
        if index not in self.states:
            command, _, line = self.items[index]
            raise ConvertError(f"line {line}: {command} is never reached")
        values = {tuple(thaw(s)[f] for f in fields) for s in self.states[index]}
        if len(values) != 1:
            line = self.items[index][2]
            raise ConvertError(f"line {line}: {', '.join(fields)} differs between plays: {sorted(values)}")
        return dict(zip(fields, values.pop()))


# ---------------------------------------------------------------------------
# Writing the Crystal song

class ChannelWriter:
    def __init__(self, sim, channel, wave_map, drumkit, octave_shift, square_vibrato):
        self.sim = sim
        self.items = sim.items
        self.labels = sim.labels
        self.channel = channel
        self.wave_map = wave_map
        self.drumkit = drumkit
        self.octave_shift = octave_shift
        self.square_vibrato = square_vibrato
        self.lines = []
        self.size = 0
        self.ties = 0
        self.cutoff_wrappers = 0
        self.pending = set()
        self.vibrato_on = False
        self.sub_names = {}
        self.loop_count = 0

    def emit(self, command, *args):
        text = "\t" + command
        if args:
            text += " " + ", ".join(str(a) for a in args)
        self.lines.append(text)
        self.size += CRYSTAL_SIZES[command]

    def label(self, name):
        self.lines.append(f".{name}:")

    def flush(self, index):
        """Write the speed/envelope/wave/vibrato settings changed since the last note."""
        if not self.pending:
            return
        pending = self.pending
        self.pending = set()
        ch = self.channel
        fields = set()
        if "vibrato" in pending and ch != 4:
            fields |= {"vibrato_type", "vibrato_delay"}
        if "speed" in pending:
            fields.add("speed")
        if ch != 4 and pending & {"speed", "envelope", "wave"}:
            fields |= {"envelope", "wave"}
        if not fields:
            return
        state = self.sim.state_at(index, tuple(f for f in STATE_FIELDS if f in fields))
        line = self.items[index][2]
        if "vibrato" in pending and ch != 4:
            delay = state["vibrato_delay"]
            if not self.square_vibrato:
                if delay or self.vibrato_on:
                    self.emit("vibrato_table", state["vibrato_type"] if delay else 0, delay)
                    self.vibrato_on = bool(delay)
            elif delay:
                vtype = state["vibrato_type"]
                if vtype not in VIBRATO_TYPES:
                    raise ConvertError(f"line {line}: no Crystal vibrato for TCG vibrato_type {vtype}")
                extent, rate = VIBRATO_TYPES[vtype]
                self.emit("vibrato", delay - 1, extent, rate)
                self.vibrato_on = True
            elif self.vibrato_on:
                self.emit("vibrato", 0, 0, 0)
                self.vibrato_on = False
        if ch == 4:
            if "speed" in pending:
                self.emit("drum_speed", state["speed"])
            return
        if ch == 3:
            if not pending & {"speed", "envelope", "wave"}:
                return
            # an unset volume or wave is written as 0: every note comes after both are set
            volume = 0 if state["envelope"] is None else self.wave_volume(state["envelope"], line)
            wave = 0
            if state["wave"] is not None:
                if state["wave"] not in self.wave_map:
                    raise ConvertError(f"line {line}: TCG wave {state['wave']} has no Crystal wave (use --wave)")
                wave = self.wave_map[state["wave"]]
            if "speed" in pending:
                self.emit("note_type", state["speed"], volume, wave)
            else:
                self.emit("volume_envelope", volume, wave)
            return
        if not pending & {"speed", "envelope"}:
            return
        # an unset envelope is written as 0: every note comes after a volume_envelope
        volume, fade = envelope_args(state["envelope"] or 0)
        if "speed" in pending:
            self.emit("note_type", state["speed"], volume, fade)
        else:
            self.emit("volume_envelope", volume, fade)

    @staticmethod
    def wave_volume(byte, line):
        if byte & ~0x60:
            raise ConvertError(f"line {line}: wave volume ${byte:02x} isn't a plain NR32 level")
        return byte >> 5

    def octave_row(self, index):
        """TCG pitch-table row after the octave command at `index`."""
        command, args, _ = self.items[index]
        if command == "octave":
            n = parse_number(args[0])
            return n if self.channel == 3 else n - 1
        row = self.sim.state_at(index, ("octave",))["octave"]
        return row + 1 if command == "inc_octave" else row - 1

    def crystal_octave(self, index, line):
        octave = self.octave_row(index) + self.octave_shift
        if not 1 <= octave <= 8:
            raise ConvertError(f"line {line}: Crystal octave {octave} out of range")
        return octave

    def write_block(self, start):
        items = self.items
        index = start
        while True:
            command, args, line = items[index]
            ch = self.channel
            if command in CONTROL_COMMANDS:
                self.flush(index)

            if command == "note" and ch != 4 or command == "rest":
                self.flush(index)
                length = parse_number(args[-1])
                tied = index + 1 < len(items) and items[index + 1][0] == "tie"
                cutoff = self.sim.state_at(index, ("cutoff",))["cutoff"] if tied else 0
                if command == "rest":
                    self.emit("rest", length)
                elif 0 < cutoff < 8:
                    # TCG never releases a note followed by tie
                    self.emit("note_cutoff", 0)
                    self.emit("note", args[0], length)
                    self.emit("note_cutoff", cutoff)
                    self.cutoff_wrappers += 1
                else:
                    self.emit("note", args[0], length)
            elif command == "note" or command in DRUM_NOTES:
                self.flush(index)
                instrument = NOTE_NAMES.index(args[0]) + 1 if command == "note" else DRUM_NOTES[command]
                self.emit("drum_note", instrument, parse_number(args[-1]))
            elif command == "tie":
                if ch == 4:
                    raise ConvertError(f"line {line}: tie on the noise channel")
                self.emit("tie")
                self.ties += 1
            elif command in ("speed",):
                self.pending.add("speed")
            elif command == "volume_envelope":
                if ch == 4:
                    raise ConvertError(f"line {line}: volume_envelope on the noise channel")
                self.pending.add("envelope")
            elif command == "wave":
                if ch != 3:
                    raise ConvertError(f"line {line}: wave outside the wave channel")
                self.pending.add("wave")
            elif command in ("vibrato_type", "vibrato_delay"):
                self.pending.add("vibrato")
            elif command in ("octave", "inc_octave", "dec_octave"):
                if ch == 4:
                    if self.octave_row(index) != 0:
                        raise ConvertError(f"line {line}: only octave 1 has noise instruments")
                else:
                    self.emit("octave", self.crystal_octave(index, line))
            elif command == "duty":
                self.emit("duty_cycle", parse_number(args[0]))
            elif command == "stereo_panning":
                left, right = parse_number(args[0]), parse_number(args[1])
                if not (left and right):
                    self.emit("stereo_panning", "TRUE" if left else "FALSE", "TRUE" if right else "FALSE")
            elif command == "cutoff":
                if ch != 4:
                    self.emit("note_cutoff", parse_number(args[0]))
            elif command == "echo":
                value = parse_number(args[0])
                if ch == 3:
                    self.emit("release_envelope", self.wave_volume(value, line), 0)
                elif ch != 4:
                    self.emit("release_envelope", *envelope_args(value))
            elif command == "music_call":
                self.emit("sound_call", "." + self.sub_name(args[0]))
            elif command == "Loop":
                self.loop_count += 1
                self.loop_label = f"loop{self.loop_count}"
                self.loop_times = parse_number(args[0])
                self.label(self.loop_label)
            elif command == "EndLoop":
                self.emit("sound_loop", self.loop_times, "." + self.loop_label)
            elif command == "MainLoop":
                self.label("mainloop")
            elif command == "EndMainLoop":
                self.emit("sound_loop", 0, ".mainloop")
            elif command in ("music_ret", "music_end"):
                self.emit("sound_ret")
            else:
                raise ConvertError(f"line {line}: unsupported command {command}")

            if command in TERMINATORS:
                return
            index += 1
            if index in self.labels.values():
                raise ConvertError(f"line {line}: falls through into another label")

    def sub_name(self, label):
        if label not in self.sub_names:
            self.sub_names[label] = f"sub{len(self.sub_names) + 1}"
        return self.sub_names[label]

    def write(self, song_name, start_label):
        ch = self.channel
        self.lines.append(f"Music_{song_name}_Ch{ch}:")
        if ch == 1:
            self.emit("tempo", CRYSTAL_TEMPO)
            self.emit("volume", 7, 7)
        if ch == 4:
            self.emit("toggle_noise", self.drumkit)
        if self.sim.needs_default_release:
            self.emit("release_envelope", 2 if ch == 3 else 0, 0)
        if self.sim.implicit_mainloop:
            self.label("mainloop")
        self.write_block(self.labels[start_label])
        for label in self.sim.called:
            self.lines.append("")
            self.label(self.sub_name(label))
            self.write_block(self.labels[label])
        return self.lines


def find_channel_labels(labels):
    found = {}
    for name in labels:
        match = re.search(r"_Ch([1-4])$", name)
        if match:
            channel = int(match.group(1))
            if channel in found:
                raise ConvertError(f"two labels for channel {channel}: {found[channel]}, {name} (use --channels)")
            found[channel] = name
    if not found:
        raise ConvertError("no _Ch1.._Ch4 labels found (use --channels)")
    return [found.get(c) for c in range(1, 5)]


def check_pitches(sims, song_path):
    """Map TCG pitch-table rows to Crystal octaves and check every played note."""
    frequencies = load_crystal_frequencies()
    tcg = load_tcg_pitches(song_path)
    played = set()
    for sim in sims:
        if sim.channel != 4:
            played |= sim.notes_played
    shifts = {}
    mismatches = []
    for row, pitch in sorted(played):
        target = tcg[row * 12 + pitch - 1]
        exact = [o for o in range(1, 9) if crystal_register(frequencies, o, pitch) == target]
        if exact:
            shifts.setdefault(exact[0] - row, []).append((row, pitch))
            continue
        best = min(range(1, 9), key=lambda o: abs(crystal_register(frequencies, o, pitch) - target))
        diff = crystal_register(frequencies, best, pitch) - target
        shifts.setdefault(best - row, []).append((row, pitch))
        mismatches.append((row, NOTE_NAMES[pitch - 1], target, diff))
    if not shifts:
        return 1, 0, []
    if len(shifts) != 1:
        raise ConvertError(f"TCG pitch rows don't map to one Crystal octave offset: {shifts}")
    shift = next(iter(shifts))
    return shift, len(played), mismatches


def tcg_song_size(items):
    total = 0
    for command, _, line in items:
        if command not in TCG_SIZES:
            raise ConvertError(f"line {line}: unknown size for {command}")
        total += TCG_SIZES[command]
    return total


def convert(song_path, song_name, channel_labels, wave_map, drumkit, output, square_vibrato=False):
    items, labels = parse_song(song_path)
    if channel_labels is None:
        channel_labels = find_channel_labels(labels)
    sims = []
    for channel, label in enumerate(channel_labels, 1):
        if label is None:
            continue
        if label not in labels:
            raise ConvertError(f"no label {label}")
        sims.append(Simulation(items, labels, channel, labels[label]))

    shift, num_played, mismatches = check_pitches(sims, song_path)

    writers = []
    for sim in sims:
        if sim.channel == 4 and drumkit is None:
            raise ConvertError("the song has drums; pass --drumkit")
        writers.append(ChannelWriter(sim, sim.channel, wave_map, drumkit, shift, square_vibrato))

    out = [f"Music_{song_name}:", f"\tchannel_count {len(sims)}"]
    for sim in sims:
        out.append(f"\tchannel {sim.channel}, Music_{song_name}_Ch{sim.channel}")
    for writer in writers:
        out.append("")
        out.extend(writer.write(song_name, channel_labels[writer.channel - 1]))

    Path(output).write_text("\n".join(out) + "\n", newline="\n")

    crystal_size = 3 * len(sims) + sum(w.size for w in writers)
    print(f"wrote {output}")
    print(f"pitch: TCG table row r -> Crystal octave r+{shift}; {num_played} distinct notes, "
        f"{len(mismatches)} without an exact register match")
    for row, name, target, diff in mismatches:
        print(f"    row {row} {name}: TCG ${target:03x}, Crystal off by {diff:+d}")
    print(f"ties: {sum(w.ties for w in writers)}; "
        f"note_cutoff 0 wrappers on tied notes: {sum(w.cutoff_wrappers for w in writers)}")
    print(f"size: TCG {tcg_song_size(items)} bytes, Crystal {crystal_size} bytes (with header)")


# ---------------------------------------------------------------------------
# Instruments: wave samples and drumkit

def parse_instrument_file(path):
    """Returns (pointer label order, {label: [bytes]}) for a TCG instrument file."""
    order = []
    data = {}
    current = None
    for raw in Path(path).read_text().splitlines():
        line = raw.split(";", 1)[0].strip()
        if not line:
            continue
        pointer = re.match(r"dw\s+\.(\w+)", line)
        if pointer:
            order.append(pointer.group(1))
            continue
        label = re.match(r"\.(\w+):?$", line)
        if label:
            current = label.group(1)
            data[current] = []
            continue
        byte_line = re.match(r"(db|dn)\s+(.*)", line)
        if byte_line and current:
            data[current].append((byte_line.group(1), [parse_number(v) for v in byte_line.group(2).split(",")]))
            continue
        raise ConvertError(f"{path}: can't parse {raw.strip()!r}")
    return order, data


def wave_rows(audio_dir, waves):
    order, data = parse_instrument_file(Path(audio_dir) / "wave_instruments.asm")
    lines = []
    for wave in waves:
        values = [v for kind, vs in data[order[wave]] for v in vs]
        if len(values) != 32:
            raise ConvertError(f"TCG wave {wave} isn't 32 samples")
        lines.append("\tdn " + ", ".join(f"{v:2d}" for v in values))
    return lines


def drum_steps(raw):
    """TCG noise instrument bytes -> list of (restart, frames, nr42, nr43) drumkit steps.

    TCG writes NR41-NR44 on the first frame (a restart), then one NR43 per frame until $ff.
    That becomes a noise_step for frame 0 and a noise_freq_step for each later run of equal
    NR43. Once NR43 stops changing the sample ends, and the noise keeps sounding.
    NR44 bit 6 turns on the length counter, which cuts the sound after (64 - NR41) / 256 s;
    that becomes a silent restart on the cut frame.
    """
    _, nr41, nr42, nr44, *rest = raw
    seq = []
    for value in rest:
        if value == 0xff:
            break
        seq.append(value)
    silent = (True, 1, 0x08, 0)
    if nr42 & 0xf8 == 0:
        # the DAC is off: the instrument is silent
        return [silent]
    cut = None
    if nr44 & 0x40:
        cut = max(1, round((64 - (nr41 & 63)) / 256 * CRYSTAL_FPS))
        timeline = [seq[min(k, len(seq) - 1)] for k in range(cut)]
    else:
        timeline = seq
    runs = []
    for value in timeline:
        if runs and runs[-1][0] == value:
            runs[-1][1] += 1
        else:
            runs.append([value, 1])
    if not cut:
        # the last value holds until the next note, so its step only needs to write it
        runs[-1][1] = 1
    steps = []
    for i, (value, frames) in enumerate(runs):
        restart = i == 0
        while frames:
            chunk = min(16, frames)
            steps.append((restart, chunk, nr42, value))
            restart = False
            frames -= chunk
    if cut:
        steps.append(silent)
    return steps


def drumkit_lines(audio_dir, drumkit, prefix):
    """Returns (lines, size in bytes)."""
    order, data = parse_instrument_file(Path(audio_dir) / "noise_instruments.asm")
    names = {}
    for label in order:
        names.setdefault(label, prefix + label[0].upper() + label[1:])
    # entry 0 is never played: drum note 0 is a rest
    lines = [f"Drumkit{drumkit}:", f"\tdw {names.get('unused', names[order[0]])}"]
    size = 2 * (len(order) + 1)
    for label in order:
        lines.append(f"\tdw {names[label]}")
    for label in dict.fromkeys(order):
        raw = [v for kind, vs in data[label] for v in vs]
        lines.append("")
        lines.append(f"{names[label]}:")
        for restart, frames, nr42, nr43 in drum_steps(raw):
            if restart:
                lines.append(f"\tnoise_step {frames}, {', '.join(map(str, envelope_args(nr42)))}, {nr43}")
            else:
                lines.append(f"\tnoise_freq_step {frames}, {nr43}")
            size += 3
        lines.append("\tsound_ret")
        size += 1
    return lines, size


def main():
    parser = argparse.ArgumentParser(description="Convert Pokemon TCG music to a Crystal song.")
    parser.add_argument("song", nargs="?", help="TCG song .asm")
    parser.add_argument("name", nargs="?", help="Crystal label stem, e.g. TcgOverworld")
    parser.add_argument("-o", "--output", help="output .asm (default audio/music/<name>.asm)")
    parser.add_argument("--channels", help="comma-separated TCG labels for channels 1-4 (blank = unused)")
    parser.add_argument("--wave", action="append", default=[], help="TCG wave = Crystal wave, e.g. 1=10")
    parser.add_argument("--drumkit", type=int, help="Crystal drumkit id holding the TCG noise instruments")
    parser.add_argument("--square-vibrato", action="store_true",
        help="use Crystal's square vibrato instead of TCG's vibrato tables")
    parser.add_argument("--instruments", metavar="TCG_AUDIO_DIR",
        help="print wave samples and the drumkit instead of converting a song")
    parser.add_argument("--waves", default="", help="with --instruments: TCG wave ids to print, e.g. 1,3")
    parser.add_argument("--prefix", default="Tcg", help="with --instruments: drum label prefix")
    args = parser.parse_args()

    try:
        if args.instruments:
            waves = [int(w) for w in args.waves.split(",") if w.strip()]
            if waves:
                print("; audio/wave_samples.asm")
                print("\n".join(wave_rows(args.instruments, waves)))
            if args.drumkit is not None:
                print("; audio/drumkits.asm")
                lines, size = drumkit_lines(args.instruments, args.drumkit, args.prefix)
                print("\n".join(lines))
                print(f"; {size} bytes")
            return 0
        if not args.song or not args.name:
            parser.error("song and name are required")
        wave_map = {}
        for pair in args.wave:
            tcg, crystal = pair.split("=")
            wave_map[int(tcg)] = int(crystal)
            if not 0 <= int(crystal) <= 15:
                raise ConvertError(f"Crystal wave {crystal} out of range 0-15")
        channels = None
        if args.channels:
            channels = [c.strip() or None for c in args.channels.split(",")]
            channels += [None] * (4 - len(channels))
        output = args.output or REPO_ROOT / "audio" / "music" / f"{args.name.lower()}.asm"
        convert(args.song, args.name, channels, wave_map, args.drumkit, output, args.square_vibrato)
    except ConvertError as e:
        print(f"error: {e}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
