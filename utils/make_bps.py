#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Make a BPS patch that turns a base ROM into the built ROM, then check it by applying it.

Usage: make_bps.py baserom.gbc pokecrystal.gbc out.bps [--sha1 <expected base sha1>]

Any run of bytes that can be found in the base ROM is copied from it, so the patch holds only
bytes the base ROM doesn't have. A patch that stored the moved data itself would carry the
original game's data along with it.
"""

from argparse import ArgumentParser
from hashlib import sha1
from sys import exit, stderr
from zlib import crc32

# Shortest run worth copying from the base ROM; shorter runs are stored as they are
MIN_MATCH = 6
# How many base ROM offsets to remember per MIN_MATCH-byte key
MAX_CANDIDATES = 32

SOURCE_READ, TARGET_READ, SOURCE_COPY, TARGET_COPY = range(4)

def encode_number(n):
	out = bytearray()
	while True:
		x = n & 0x7f
		n >>= 7
		if n == 0:
			out.append(0x80 | x)
			return out
		out.append(x)
		n -= 1

def decode_number(data, pos):
	n, shift = 0, 1
	while True:
		x = data[pos]
		pos += 1
		n += (x & 0x7f) * shift
		if x & 0x80:
			return n, pos
		shift <<= 7
		n += shift

def index_source(source):
	index = {}
	for i in range(len(source) - MIN_MATCH + 1):
		candidates = index.setdefault(source[i:i + MIN_MATCH], [])
		if len(candidates) < MAX_CANDIDATES:
			candidates.append(i)
	return index

def match_length(a, a_pos, b, b_pos):
	n = 0
	limit = min(len(a) - a_pos, len(b) - b_pos)
	while n < limit and a[a_pos + n] == b[b_pos + n]:
		n += 1
	return n

def make_patch(source, target):
	index = index_source(source)
	actions = bytearray()
	literal = bytearray()
	source_relative = 0
	stored = 0

	def flush_literal():
		nonlocal stored
		if literal:
			actions.extend(encode_number(((len(literal) - 1) << 2) | TARGET_READ))
			actions.extend(literal)
			stored += len(literal)
			literal.clear()

	pos = 0
	while pos < len(target):
		# Same offset in the base ROM: the cheapest action
		best_len = match_length(source, pos, target, pos) if pos < len(source) else 0
		best_mode, best_from = SOURCE_READ, pos
		if best_len < MIN_MATCH:
			for candidate in index.get(target[pos:pos + MIN_MATCH], ()):
				length = match_length(source, candidate, target, pos)
				if length > best_len:
					best_len, best_mode, best_from = length, SOURCE_COPY, candidate
		if best_len < MIN_MATCH:
			literal.append(target[pos])
			pos += 1
			continue
		flush_literal()
		actions.extend(encode_number(((best_len - 1) << 2) | best_mode))
		if best_mode == SOURCE_COPY:
			delta = best_from - source_relative
			actions.extend(encode_number((abs(delta) << 1) | (delta < 0)))
			source_relative = best_from + best_len
		pos += best_len
	flush_literal()

	patch = bytearray(b'BPS1')
	patch += encode_number(len(source))
	patch += encode_number(len(target))
	patch += encode_number(0) # no metadata
	patch += actions
	patch += crc32(source).to_bytes(4, 'little')
	patch += crc32(target).to_bytes(4, 'little')
	patch += crc32(patch).to_bytes(4, 'little')
	return bytes(patch), stored

def apply_patch(source, patch):
	if patch[:4] != b'BPS1':
		raise ValueError('not a BPS patch')
	if crc32(patch[:-4]) != int.from_bytes(patch[-4:], 'little'):
		raise ValueError('patch checksum mismatch')
	pos = 4
	source_size, pos = decode_number(patch, pos)
	target_size, pos = decode_number(patch, pos)
	metadata_size, pos = decode_number(patch, pos)
	pos += metadata_size
	if source_size != len(source) or crc32(source) != int.from_bytes(patch[-12:-8], 'little'):
		raise ValueError('wrong base ROM')
	target = bytearray()
	source_relative = target_relative = 0
	end = len(patch) - 12
	while pos < end:
		data, pos = decode_number(patch, pos)
		mode, length = data & 3, (data >> 2) + 1
		if mode == SOURCE_READ:
			target += source[len(target):len(target) + length]
		elif mode == TARGET_READ:
			target += patch[pos:pos + length]
			pos += length
		else:
			data, pos = decode_number(patch, pos)
			delta = -(data >> 1) if data & 1 else data >> 1
			if mode == SOURCE_COPY:
				source_relative += delta
				target += source[source_relative:source_relative + length]
				source_relative += length
			else:
				target_relative += delta
				for _ in range(length):
					target.append(target[target_relative])
					target_relative += 1
	if len(target) != target_size or crc32(target) != int.from_bytes(patch[-8:-4], 'little'):
		raise ValueError('patched ROM checksum mismatch')
	return bytes(target)

def main():
	parser = ArgumentParser(description='Make a BPS patch from a base ROM to the built ROM.')
	parser.add_argument('base')
	parser.add_argument('built')
	parser.add_argument('out')
	parser.add_argument('--sha1', help='expected SHA1 of the base ROM')
	args = parser.parse_args()

	try:
		with open(args.base, 'rb') as f:
			source = f.read()
	except FileNotFoundError:
		print(f'{args.base} not found. Put an unmodified Pokémon Crystal (USA, Europe) (Rev 1) ROM '
			f'there to make the patch.', file=stderr)
		exit(1)
	if args.sha1 and sha1(source).hexdigest() != args.sha1.lower():
		print(f'{args.base} has SHA1 {sha1(source).hexdigest()}, not {args.sha1}. It must be an '
			f'unmodified Pokémon Crystal (USA, Europe) (Rev 1) ROM.', file=stderr)
		exit(1)
	with open(args.built, 'rb') as f:
		target = f.read()

	patch, stored = make_patch(source, target)
	if apply_patch(source, patch) != target:
		print('The patch does not rebuild the ROM; not writing it.', file=stderr)
		exit(1)
	with open(args.out, 'wb') as f:
		f.write(patch)
	print(f'{args.out}: {len(patch):,} bytes; {stored:,} of the ROM\'s {len(target):,} bytes '
		f'are stored in the patch, the rest are copied from the base ROM. Checked by applying it.')

if __name__ == '__main__':
	main()
