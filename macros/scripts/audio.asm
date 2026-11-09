MACRO channel_count
	assert 0 < (\1) && (\1) <= NUM_MUSIC_CHANS, \
		"channel_count must be 1-{d:NUM_MUSIC_CHANS}"
	DEF _num_channels = \1 - 1
ENDM

MACRO channel
	assert 0 < (\1) && (\1) <= NUM_CHANNELS, \
		"channel id must be 1-{d:NUM_CHANNELS}"
	dn (_num_channels << 2), \1 - 1 ; channel id
	dw \2 ; address
	DEF _num_channels = 0
ENDM

MACRO note
	dn (\1), (\2) - 1 ; pitch, length
ENDM

MACRO drum_note
	note \1, \2 ; drum instrument, length
ENDM

MACRO rest
	note 0, \1 ; length
ENDM

MACRO square_note
	db \1 ; length
	if \3 < 0
		dn \2, %1000 | (\3 * -1) ; volume envelope
	else
		dn \2, \3 ; volume envelope
	endc
	dw \4 ; frequency
ENDM

MACRO noise_note
	db \1 ; length
	if \3 < 0
		dn \2, %1000 | (\3 * -1) ; volume envelope
	else
		dn \2, \3 ; volume envelope
	endc
	db \4 ; frequency
ENDM

; drumkit sample steps lasting exactly \1 frames (noise_note steps last 2 frames more than their low nybble)
MACRO noise_step
	assert 1 <= (\1) && (\1) <= 16, "noise step must last 1-16 frames"
	db (1 << NOISE_STEP_EXACT_F) | ((\1) - 1) ; length
	if \3 < 0
		dn \2, %1000 | (\3 * -1) ; volume envelope
	else
		dn \2, \3 ; volume envelope
	endc
	db \4 ; frequency
ENDM

; changes the noise frequency without restarting the sound
MACRO noise_freq_step
	assert 1 <= (\1) && (\1) <= 16, "noise step must last 1-16 frames"
	db (1 << NOISE_STEP_EXACT_F) | (1 << NOISE_STEP_CONTINUE_F) | ((\1) - 1) ; length
	db 0 ; volume envelope (unused)
	db \2 ; frequency
ENDM

; pitch_script steps (see audio/pitch_scripts.asm)
MACRO pitch_step
	assert -8 * NUM_NOTES <= (\1) && (\1) < 8 * NUM_NOTES, "pitch offset out of range"
	assert 0 <= (\2) && (\2) < $100, "pitch step must last 0-255 frames"
	db LOW(\1) ; offset in eighths of a semitone
	db \2 ; frames (0: hold for good)
ENDM

MACRO pitch_loop
	db PITCH_SCRIPT_LOOP
	db (\2) - (\1) ; step to go on from: \1 is the script, \2 the step
ENDM

; volume_script steps (see audio/volume_scripts.asm)
MACRO volume_step
	assert 1 <= (\3) && (\3) < $100, "volume step must last 1-255 frames"
	if \2 < 0
		dn \1, %1000 | (\2 * -1) ; volume envelope
	else
		dn \1, \2 ; volume envelope
	endc
	db \3 ; frames
ENDM

MACRO volume_script_end
	db 0
ENDM

; MusicCommands indexes (see audio/engine.asm)
	const_def $d0
DEF FIRST_MUSIC_CMD EQU const_value

	const octave_cmd ; $d0
MACRO octave
	assert 1 <= (\1) && (\1) <= 8, "octave must be 1-8"
	db octave_cmd + 8 - (\1) ; octave
ENDM

	const_skip 7 ; all octave values

	const note_type_cmd ; $d8
MACRO note_type
	db note_type_cmd
	db \1 ; note length
	if _NARG >= 2
		if \3 < 0
			dn \2, %1000 | (\3 * -1) ; volume envelope
		else
			dn \2, \3 ; volume envelope
		endc
	endc
ENDM

; only valid on the noise channel
MACRO drum_speed
	note_type \1 ; note length
ENDM

	const transpose_cmd ; $d9
MACRO transpose
	db transpose_cmd
	dn \1, \2 ; num octaves, num pitches
ENDM

	const tempo_cmd ; $da
MACRO tempo
	db tempo_cmd
	bigdw \1 ; tempo
ENDM

	const duty_cycle_cmd ; $db
MACRO duty_cycle
	db duty_cycle_cmd
	db \1 ; duty cycle
ENDM

	const volume_envelope_cmd ; $dc
MACRO volume_envelope
	db volume_envelope_cmd
	if \2 < 0
		dn \1, %1000 | (\2 * -1) ; volume envelope
	else
		dn \1, \2 ; volume envelope
	endc
ENDM

	const pitch_sweep_cmd ; $dd
MACRO pitch_sweep
	db pitch_sweep_cmd
	if \2 < 0
		dn \1, %1000 | (\2 * -1) ; pitch sweep
	else
		dn \1, \2 ; pitch sweep
	endc
ENDM

	const duty_cycle_pattern_cmd ; $de
MACRO duty_cycle_pattern
	db duty_cycle_pattern_cmd
	db (\1 << 6) | (\2 << 4) | (\3 << 2) | (\4 << 0) ; duty cycle pattern
ENDM

	const toggle_sfx_cmd ; $df
MACRO toggle_sfx
	db toggle_sfx_cmd
ENDM

	const pitch_slide_cmd ; $e0
MACRO pitch_slide
	db pitch_slide_cmd
	db \1 - 1 ; duration
	dn 8 - \2, \3 % 12 ; octave, pitch
ENDM

	const vibrato_cmd ; $e1
MACRO vibrato
	db vibrato_cmd
	db \1 ; delay
	if _NARG > 2
		dn \2, \3 ; extent, rate
	else
		db \2 ; LEGACY: Support for 1-arg extent
	endc
ENDM

	const vibrato_table_cmd ; $e2
MACRO vibrato_table
	assert 0 <= (\1) && (\1) < NUM_VIBRATO_TABLES, "no such vibrato table"
	db vibrato_table_cmd
	db \1 ; table
	db \2 ; frames into each note before the vibrato starts, plus 1 (0: off)
ENDM

	const toggle_noise_cmd ; $e3
MACRO toggle_noise
	db toggle_noise_cmd
	if _NARG > 0
		db \1 ; drum kit
	endc
ENDM

	const force_stereo_panning_cmd ; $e4
MACRO force_stereo_panning
	db force_stereo_panning_cmd
	dn %1111 * (1 && \1), %1111 * (1 && \2) ; left enable, right enable
ENDM

	const volume_cmd ; $e5
MACRO volume
	db volume_cmd
	if _NARG > 1
		dn \1, \2 ; left volume, right volume
	else
		db \1 ; LEGACY: Support for 1-arg volume
	endc
ENDM

	const pitch_offset_cmd ; $e6
MACRO pitch_offset
	db pitch_offset_cmd
	bigdw \1 ; pitch offset
ENDM

	const note_cutoff_cmd ; $e7
MACRO note_cutoff
	assert 0 <= (\1) && (\1) <= 8, "note cutoff must be 0-8"
	db note_cutoff_cmd
	db \1 ; eighths of each note played before its release (0 or 8: no release)
ENDM

	const release_envelope_cmd ; $e8
MACRO release_envelope
	db release_envelope_cmd
	if \2 < 0
		dn \1, %1000 | (\2 * -1) ; volume envelope
	else
		dn \1, \2 ; volume envelope
	endc
ENDM

	const tempo_relative_cmd ; $e9
MACRO tempo_relative
	db tempo_relative_cmd
	db \1 ; tempo adjustment
ENDM

	const restart_channel_cmd ; $ea
MACRO restart_channel
	db restart_channel_cmd
	dw \1 ; address
ENDM

	const new_song_cmd ; $eb
MACRO new_song
	db new_song_cmd
	dw \1 ; id
ENDM

	const sfx_priority_on_cmd ; $ec
MACRO sfx_priority_on
	db sfx_priority_on_cmd
ENDM

	const sfx_priority_off_cmd ; $ed
MACRO sfx_priority_off
	db sfx_priority_off_cmd
ENDM

	const unknownmusic0xee_cmd ; $ee
MACRO unknownmusic0xee
	db unknownmusic0xee_cmd
	dw \1 ; address
ENDM

	const stereo_panning_cmd ; $ef
MACRO stereo_panning
	db stereo_panning_cmd
	dn %1111 * (1 && \1), %1111 * (1 && \2) ; left enable, right enable
ENDM

	const sfx_toggle_noise_cmd ; $f0
MACRO sfx_toggle_noise
	db sfx_toggle_noise_cmd
	if _NARG > 0
		db \1 ; drum kit
	endc
ENDM

	const pitch_script_cmd ; $f1
MACRO pitch_script
	assert (\1) == NO_PITCH_SCRIPT || (0 <= (\1) && (\1) < NUM_PITCH_SCRIPTS), "no such pitch script"
	db pitch_script_cmd
	db \1 ; script played from each new note (see audio/pitch_scripts.asm), or NO_PITCH_SCRIPT
ENDM

	const volume_script_cmd ; $f2
MACRO volume_script
	assert (\1) == NO_VOLUME_SCRIPT || (0 <= (\1) && (\1) < NUM_VOLUME_SCRIPTS), "no such volume script"
	db volume_script_cmd
	db \1 ; script played from each new note (see audio/volume_scripts.asm), or NO_VOLUME_SCRIPT
ENDM

	const wave_bank_cmd ; $f3
MACRO wave_bank
	assert (\1) == 0 || (\1) == 1, "wave bank must be 0 or 1"
	db wave_bank_cmd
	db \1 ; 0: WaveSamples, 1: WaveSamples2
ENDM

	const music0xf4_cmd ; $f4
MACRO music0xf4
	db music0xf4_cmd
ENDM

	const music0xf5_cmd ; $f5
MACRO music0xf5
	db music0xf5_cmd
ENDM

	const music0xf6_cmd ; $f6
MACRO music0xf6
	db music0xf6_cmd
ENDM

	const music0xf7_cmd ; $f7
MACRO music0xf7
	db music0xf7_cmd
ENDM

	const music0xf8_cmd ; $f8
MACRO music0xf8
	db music0xf8_cmd
ENDM

	const tie_cmd ; $f9
MACRO tie
	db tie_cmd ; the next note continues this one without restarting
ENDM

	const set_condition_cmd ; $fa
MACRO set_condition
	db set_condition_cmd
	db \1 ; condition
ENDM

	const sound_jump_if_cmd ; $fb
MACRO sound_jump_if
	db sound_jump_if_cmd
	db \1 ; condition
	dw \2 ; address
ENDM

	const sound_jump_cmd ; $fc
MACRO sound_jump
	db sound_jump_cmd
	dw \1 ; address
ENDM

	const sound_loop_cmd ; $fd
MACRO sound_loop
	db sound_loop_cmd
	db \1 ; count
	dw \2 ; address
ENDM

	const sound_call_cmd ; $fe
MACRO sound_call
	db sound_call_cmd
	dw \1 ; address
ENDM

	const sound_ret_cmd ; $ff
MACRO sound_ret
	db sound_ret_cmd
ENDM
