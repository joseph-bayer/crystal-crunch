PitchScripts:
; pitch offsets played from the start of each note, for pitch_script
; each step: pitch_step offset, frames
;	offset: from the note's pitch, in eighths of a semitone (at least -8 * NUM_NOTES)
;	frames: how long to hold it (0: for good)
; pitch_loop goes on from an earlier step
	table_width 2
	dw .puzzle_trill
	dw .puzzle_vibrato
	dw .puzzle_vibrato_2
	dw .puzzle_scoop
	dw .puzzle_fall
	assert_table_length NUM_PITCH_SCRIPTS

; The Pokémon Puzzle Challenge scripts step every tick, which is 2.14 frames at its tempo 14;
; here each step's ticks are rounded to frames.

.puzzle_trill
	pitch_step  0, 26
.puzzle_trill_loop
	pitch_step -1, 2
	pitch_step  0, 2
	pitch_loop .puzzle_trill, .puzzle_trill_loop

.puzzle_vibrato
	pitch_step  0, 13
.puzzle_vibrato_loop
	pitch_step  1, 2
	pitch_step  2, 2
	pitch_step  1, 2
	pitch_step  0, 7
	pitch_loop .puzzle_vibrato, .puzzle_vibrato_loop

.puzzle_vibrato_2
	pitch_step  0, 9
.puzzle_vibrato_2_loop
	pitch_step  1, 2
	pitch_step  2, 2
	pitch_step  3, 2
	pitch_step  2, 2
	pitch_step  1, 2
	pitch_step  0, 7
	pitch_loop .puzzle_vibrato_2, .puzzle_vibrato_2_loop

.puzzle_scoop
	pitch_step -16, 2
	pitch_step  -8, 2
	pitch_step   0, 5
.puzzle_scoop_loop
	pitch_step   1, 4
	pitch_step   2, 4
	pitch_step   1, 4
	pitch_step   0, 5
	pitch_loop .puzzle_scoop, .puzzle_scoop_loop

.puzzle_fall
	pitch_step  -2, 2
	pitch_step  -4, 2
	pitch_step  -6, 2
	pitch_step  -8, 3
	pitch_step -10, 2
	pitch_step -12, 2
	pitch_step -14, 2
	pitch_step -16, 0
