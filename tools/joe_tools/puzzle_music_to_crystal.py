#!/usr/bin/env python3
"""Convert a Pokémon Puzzle Challenge song (pret/pokepuzzle) to a Crystal song.

Usage:
    python tools/joe_tools/puzzle_music_to_crystal.py SONG.asm NAME [-o OUTPUT]

SONG.asm is a song from pokepuzzle's src/audio/music/, and NAME is the Crystal label stem
(Music_<NAME>). The output defaults to audio/music/<name in lowercase>.asm.

Puzzle Challenge's sound engine differs from Crystal's, so the song relies on these engine
additions: pitch_script, volume_script, wave_bank, Drumkit7, and the PITCH_SCRIPT_PUZZLE_*,
VOLUME_SCRIPT_PUZZLE_* and WaveSamples2 data. Only the commands and arguments in the tables below
are supported. Anything else stops the conversion with an error rather than guessing.

Timing: Puzzle Challenge ticks tempo/30 times a frame, and a note lasts its length in ticks.
Every length must be a multiple of 3 ticks, which becomes one Crystal unit of note_type 12 at
tempo 1920 / tempo.

Pitch: Puzzle Challenge octave k is played as Crystal octave k + 1. Puzzle Challenge's own
frequency table isn't in the disassembly, so this is a best guess.
"""

import argparse
import os
import re
import sys

TICKS_PER_UNIT = 3
NOTE_TYPE = 12
MAX_UNITS = 16

PITCHES = ["C_", "C#", "D_", "D#", "E_", "F_", "F#", "G_", "G#", "A_", "A#", "B_"]

# musicd4 id -> pitch_script constant
PITCH_SCRIPTS = {
    35: "PITCH_SCRIPT_PUZZLE_TRILL",
    55: "PITCH_SCRIPT_PUZZLE_VIBRATO",
    56: "PITCH_SCRIPT_PUZZLE_VIBRATO_2",
    58: "PITCH_SCRIPT_PUZZLE_SCOOP",
    60: "PITCH_SCRIPT_PUZZLE_FALL",
}

# musicd8 id -> volume_script constant
VOLUME_SCRIPTS = {
    58: "VOLUME_SCRIPT_PUZZLE_SWELL",
    101: "VOLUME_SCRIPT_PUZZLE_WAVE_ACCENT",
    161: "VOLUME_SCRIPT_PUZZLE_HOLD_10",
    164: "VOLUME_SCRIPT_PUZZLE_HOLD_7",
    165: "VOLUME_SCRIPT_PUZZLE_HOLD_6",
}

# musicd8 id -> (volume, fade) for envelopes that are one plain NRx2 step
# (221's release lasts 1 frame at volume 2, so it's dropped)
PLAIN_ENVELOPES = {
    204: (4, 1),
    205: (5, 1),
    206: (6, 1),
    207: (7, 1),
    208: (8, 1),
    209: (9, 1),
    210: (10, 1),
    221: (6, 2),
}

# wave id -> WaveSamples2 index
WAVES = {59: 0, 61: 1, 63: 2, 64: 3, 65: 4, 66: 5}

# noise id -> Drumkit7 instrument
DRUMKIT = 7
NOISE = {3: 1, 11: 2, 16: 3, 17: 4}

DUTY = {
    "duty_cycle_12_5": 0,
    "duty_cycle_25": 1,
    "duty_cycle_50": 2,
    "duty_cycle_75": 3,
}


class ConvertError(Exception):
    pass


def parse_song(path):
    """Returns (labels, items): items is a list of (label or None, command, args, line number)."""
    labels = {}
    items = []
    with open(path, encoding="utf-8") as f:
        for number, raw in enumerate(f, 1):
            line = raw.split(";")[0].rstrip()
            if not line.strip():
                continue
            m = re.match(r"^(\w+):+$", line.strip()) if not raw[0].isspace() else None
            if m:
                labels[m.group(1)] = len(items)
                items.append((m.group(1), None, [], number))
                continue
            parts = line.strip().split(None, 1)
            args = [a.strip() for a in parts[1].split(",")] if len(parts) > 1 else []
            items.append((None, parts[0], args, number))
    return labels, items


def number(text, where):
    try:
        return int(text, 0)
    except ValueError:
        raise ConvertError(f"line {where}: expected a number, got {text!r}")


def simulate(labels, items, start):
    """Follows one channel's flow and returns {item index: set of sticky lengths seen there}."""
    seen_lengths = {}
    visited = set()
    pc = labels[start] + 1
    length = None
    stack = []
    while True:
        state = (pc, length, tuple(stack))
        if state in visited:
            return seen_lengths
        visited.add(state)
        if pc >= len(items):
            raise ConvertError(f"{start}: runs off the end of the file")
        label, command, args, where = items[pc]
        seen_lengths.setdefault(pc, set()).add(length)
        if label is not None:
            pc += 1
        elif command == "note_length":
            length = number(args[0], where)
            pc += 1
        elif command == "song_call":
            stack.append(pc + 1)
            pc = labels[args[0]] + 1
        elif command == "song_ret":
            if not stack:
                raise ConvertError(f"line {where}: song_ret outside a call")
            pc = stack.pop()
        elif command == "song_jump":
            pc = labels[args[0]] + 1
        elif command == "song_end":
            return seen_lengths
        else:
            pc += 1


class ChannelWriter:
    def __init__(self, channel, labels, items, names, lengths):
        self.channel = channel
        self.labels = labels
        self.items = items
        self.names = names
        self.lengths = lengths
        self.lines = []
        self.octave = None
        self.tempo = None

    def emit(self, text):
        self.lines.append("\t" + text)

    def units(self, ticks, where):
        if ticks % TICKS_PER_UNIT:
            raise ConvertError(f"line {where}: length {ticks} isn't a multiple of {TICKS_PER_UNIT} ticks")
        units = ticks // TICKS_PER_UNIT
        if not 1 <= units <= MAX_UNITS:
            raise ConvertError(f"line {where}: length {ticks} ticks is more than {MAX_UNITS} units")
        return units

    def sticky(self, index, where):
        lengths = self.lengths.get(index)
        if lengths is None:
            raise ConvertError(f"line {where}: never reached, so its note length is unknown")
        if len(lengths) != 1 or None in lengths:
            raise ConvertError(f"line {where}: reached with note lengths {sorted(lengths, key=str)}")
        return next(iter(lengths))

    def event_ticks(self, index, where):
        """The event's length, plus every continue_note that directly follows it."""
        ticks = self.sticky(index, where)
        j = index + 1
        while j < len(self.items):
            label, command, args, w = self.items[j]
            if label is not None:
                break
            if command == "continue_note":
                ticks += self.sticky(j, w)
            elif command != "note_length":
                break
            j += 1
        return ticks

    def write(self, start):
        index = self.labels[start] + 1
        end = len(self.items)
        for name, at in self.labels.items():
            if at > self.labels[start] and name.endswith(("_Ch1", "_Ch2", "_Ch3", "_Ch4")):
                end = min(end, at)
        if self.channel == 3:
            self.emit(f"note_type {NOTE_TYPE}, 1, 0")
            self.emit("wave_bank 1")
        elif self.channel == 4:
            self.emit(f"toggle_noise {DRUMKIT}")
            self.emit(f"drum_speed {NOTE_TYPE}")
        else:
            self.emit(f"note_type {NOTE_TYPE}, 0, 0")
        while index < end:
            self.item(index)
            index += 1

    def item(self, index):
        label, command, args, where = self.items[index]
        ch = self.channel
        if label is not None:
            self.lines.append(f".{self.names[label]}:")
            self.octave = None
            return
        if command in ("note_length", "continue_note"):
            return
        if command == "volume":
            self.emit(f"volume {number(args[0], where)}, {number(args[1], where)}")
        elif command == "stereo_panning_both":
            pass
        elif command == "musicd6":
            tempo = number(args[0], where)
            if 1920 % tempo and abs(1920 / tempo - round(1920 / tempo)) > 0.25:
                print(f"warning: line {where}: tempo {tempo} rounds to {round(1920 / tempo)}", file=sys.stderr)
            self.emit(f"tempo {round(1920 / tempo)}")
        elif command == "musicd7":
            if number(args[0], where) != 0:
                raise ConvertError(f"line {where}: musicd7 (semitone transpose) other than 0")
        elif command == "musice3":
            if ch == 4:
                raise ConvertError(f"line {where}: musice3 on ch4")
            self.emit(f"pitch_offset {number(args[0], where)}")
        elif command in DUTY:
            if ch > 2:
                raise ConvertError(f"line {where}: duty cycle on ch{ch}")
            self.emit(f"duty_cycle {DUTY[command]}")
        elif command == "volume_envelope":
            if ch > 2:
                raise ConvertError(f"line {where}: volume_envelope on ch{ch}")
            self.emit(f"volume_envelope {number(args[0], where)}, {number(args[1], where)}")
        elif command == "musicd4":
            if ch == 4:
                return  # ch4 ignores it
            id_ = number(args[0], where)
            if id_ not in PITCH_SCRIPTS:
                raise ConvertError(f"line {where}: no pitch script for musicd4 {id_}")
            self.emit(f"pitch_script {PITCH_SCRIPTS[id_]}")
        elif command == "musicd5":
            if ch != 4:
                self.emit("pitch_script NO_PITCH_SCRIPT")
        elif command == "musicd8":
            id_ = number(args[0], where)
            if ch == 4:
                raise ConvertError(f"line {where}: musicd8 on ch4")
            if id_ in VOLUME_SCRIPTS:
                self.emit(f"volume_script {VOLUME_SCRIPTS[id_]}")
            elif id_ in PLAIN_ENVELOPES and ch != 3:
                volume, fade = PLAIN_ENVELOPES[id_]
                self.emit("volume_script NO_VOLUME_SCRIPT")
                self.emit(f"volume_envelope {volume}, {fade}")
            else:
                raise ConvertError(f"line {where}: no volume script for musicd8 {id_} on ch{ch}")
        elif command == "wave":
            id_ = number(args[0], where)
            if ch != 3:
                raise ConvertError(f"line {where}: wave on ch{ch}")
            if id_ not in WAVES:
                raise ConvertError(f"line {where}: no WaveSamples2 entry for wave {id_}")
            self.emit(f"volume_envelope 1, {WAVES[id_]}")
        elif command == "note_pitch":
            if ch == 4:
                raise ConvertError(f"line {where}: note_pitch on ch4")
            pitch = args[0]
            if pitch not in PITCHES:
                raise ConvertError(f"line {where}: unknown pitch {pitch}")
            octave = number(args[1], where) + 1
            if octave != self.octave:
                self.emit(f"octave {octave}")
                self.octave = octave
            self.emit(f"note {pitch}, {self.units(self.event_ticks(index, where), where)}")
        elif command == "rest":
            self.emit(f"rest {self.units(self.event_ticks(index, where), where)}")
        elif command == "noise":
            if ch != 4:
                raise ConvertError(f"line {where}: noise on ch{ch}")
            id_ = number(args[0], where)
            if id_ not in NOISE:
                raise ConvertError(f"line {where}: no Drumkit{DRUMKIT} instrument for noise {id_}")
            self.emit(f"drum_note {NOISE[id_]}, {self.units(self.event_ticks(index, where), where)}")
        elif command == "song_call":
            self.emit(f"sound_call .{self.names[args[0]]}")
            self.octave = None
        elif command == "song_ret":
            self.emit("sound_ret")
        elif command == "song_jump":
            self.emit(f"sound_loop 0, .{self.names[args[0]]}")
        else:
            raise ConvertError(f"line {where}: unsupported command {command}")


def convert(song_path, name, output):
    labels, items = parse_song(song_path)
    song_labels = [label for label in labels if not re.search(r"_(Ch\d|branch_\w+)$", label)]
    if len(song_labels) != 1:
        raise ConvertError(f"expected one song header label, found {song_labels}")
    header = labels[song_labels[0]]
    channels = []
    j = header + 1
    while j < len(items) and items[j][1] == "dw":
        channels.append(items[j][2][0])
        j += 1
    if not 1 <= len(channels) <= 4:
        raise ConvertError(f"expected 1-4 channels, found {channels}")

    names = {}
    counts = {}
    for label in labels:
        if label in channels or label == song_labels[0]:
            continue
        counts["branch"] = counts.get("branch", 0) + 1
        names[label] = f"branch{counts['branch']}"

    out = [f"; converted from Pokémon Puzzle Challenge's {song_labels[0]}"
           " by tools/joe_tools/puzzle_music_to_crystal.py", ""]
    out.append(f"Music_{name}:")
    out.append(f"\tchannel_count {len(channels)}")
    for n, _ in enumerate(channels, 1):
        out.append(f"\tchannel {n}, Music_{name}_Ch{n}")
    for n, label in enumerate(channels, 1):
        lengths = simulate(labels, items, label)
        writer = ChannelWriter(n, labels, items, names, lengths)
        out.append("")
        out.append(f"Music_{name}_Ch{n}:")
        writer.write(label)
        out.extend(writer.lines)
    with open(output, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(out) + "\n")


def main():
    parser = argparse.ArgumentParser(description="Convert Pokémon Puzzle Challenge music to a Crystal song.")
    parser.add_argument("song", help="Puzzle Challenge song .asm")
    parser.add_argument("name", help="Crystal label stem, e.g. PuzzleTotodile")
    parser.add_argument("-o", "--output", help="output .asm (default audio/music/<name>.asm)")
    args = parser.parse_args()
    output = args.output or os.path.join("audio", "music", args.name.lower() + ".asm")
    try:
        convert(args.song, args.name, output)
    except ConvertError as e:
        sys.exit(f"error: {e}")
    print(f"wrote {output}")


if __name__ == "__main__":
    main()
