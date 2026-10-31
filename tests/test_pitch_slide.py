"""Upward pitch slides go at vanilla's speed.

An optimization rewrote the high byte of an upward slide's distance in LoadNote (audio/engine.asm)
as `sbc d / add e`, which gives 2e - d - carry instead of d - carry. Each upward slide then got the
wrong per-frame amount: the evolution music's opening sweeps ran at 230 and 202 a frame instead of
59 and 117, and never reached vanilla's frequencies. Downward slides take another path and were
fine (the heal jingle's matched vanilla).

The expected amounts were measured from vanilla pokecrystal playing the same music."""

from harness.alt_shiny import call

MUSIC_EVOLUTION = 0x22
# Channel 1's opening: two slides up to A, alternating, each set when its note starts
VANILLA_AMOUNTS = [59, 117, 59, 117]
FRAMES = 30


def test_evolution_music_slides(game):
	call(game, "PlayMusic", de=MUSIC_EVOLUTION)
	amounts = []
	previous = None
	for _ in range(FRAMES):
		game.wait(1)
		amount = game.peek("wChannel1PitchSlideAmount")
		if amount != previous and amount:
			amounts.append(amount)
		previous = amount
	assert amounts[:len(VANILLA_AMOUNTS)] == VANILLA_AMOUNTS
