VolumeScripts:
; volume envelopes played from the start of each note, then from a rest right after it, for volume_script
; each step restarts the note: volume_step volume, fade, frames
; on ch3 only the volume counts, as in note_type (1: 100%, 2: 50%, 3: 25%)
; volume_script_end leaves the last envelope playing
	table_width 2 * 2
	dw .puzzle_swell,       .puzzle_swell_release
	dw .puzzle_wave_accent, NoVolumeRelease
	dw .puzzle_hold_10,     .puzzle_hold_10_release
	dw .puzzle_hold_7,      .puzzle_hold_7_release
	dw .puzzle_hold_6,      .puzzle_hold_6_release
	assert_table_length NUM_VOLUME_SCRIPTS

; from the Pokémon Puzzle Challenge sound engine

.puzzle_swell
	volume_step 12,  7,  8
	volume_step  8,  0,  6
	volume_step  6,  0,  6
	volume_step  3,  5, 30
	volume_step  7, -6, 40
	volume_step  8,  5, 50
	volume_script_end

.puzzle_swell_release
	volume_step  2,  1,  1
	volume_script_end

.puzzle_wave_accent
	volume_step  1,  0,  5
	volume_step  3,  0,  2
	volume_step  2,  0,  5
	volume_step  3,  0,  5
	volume_script_end

.puzzle_hold_10
	volume_step 10,  0,  1
	volume_script_end

.puzzle_hold_10_release
	volume_step 10,  1,  1
	volume_script_end

.puzzle_hold_7
	volume_step  7,  0,  1
	volume_script_end

.puzzle_hold_7_release
	volume_step  7,  1,  1
	volume_script_end

.puzzle_hold_6
	volume_step  6,  0,  1
	volume_script_end

.puzzle_hold_6_release
	volume_step  6,  1,  1
	; fallthrough

NoVolumeRelease:
	volume_script_end
