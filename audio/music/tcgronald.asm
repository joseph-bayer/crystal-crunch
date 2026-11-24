Music_TcgRonald:
	channel_count 4
	channel 1, Music_TcgRonald_Ch1
	channel 2, Music_TcgRonald_Ch2
	channel 3, Music_TcgRonald_Ch3
	channel 4, Music_TcgRonald_Ch4

Music_TcgRonald_Ch1:
	tempo 254
	volume 7, 7
	release_envelope 0, 0
	note_cutoff 8
	duty_cycle 0
	vibrato_table 8, 12
.mainloop:
	octave 3
	note_type 13, 9, 2
.loop1:
	note_cutoff 3
	volume_envelope 9, 2
	note D_, 1
	note D_, 1
	note_cutoff 4
	note F_, 1
	rest 2
	note D_, 1
	rest 1
	note C_, 1
	rest 1
	note D_, 1
	rest 1
	note F_, 1
	rest 1
	note_cutoff 8
	volume_envelope 9, 0
	note E_, 2
	rest 1
	octave 2
	note_cutoff 3
	volume_envelope 9, 2
	note G_, 1
	octave 3
	note D_, 1
	note_cutoff 4
	note F_, 1
	rest 2
	note F_, 1
	rest 1
	note C_, 1
	rest 1
	note F_, 1
	rest 1
	note A_, 1
	rest 1
	note_cutoff 8
	volume_envelope 9, 0
	note G_, 2
	rest 1
	sound_loop 2, .loop1
.loop2:
	vibrato_table 8, 20
	sound_call .sub1
	octave 4
	note_type 1, 10, 0
	note C#, 3
	note D_, 10
	tie
	note_type 13, 10, 0
	note D_, 2
	vibrato_table 8, 12
	sound_call .sub2
	sound_loop 2, .loop2
.loop3:
	vibrato_table 8, 20
	sound_call .sub3
	octave 4
	note_type 1, 10, 0
	note C#, 3
	note D_, 10
	tie
	note_type 13, 10, 0
	note D_, 2
	vibrato_table 8, 12
	sound_call .sub2
	sound_loop 2, .loop3
	sound_call .sub1
	octave 4
	vibrato_table 8, 20
	note_type 1, 10, 0
	note C#, 3
	note D_, 3
	rest 7
	duty_cycle 2
	volume_envelope 9, 0
	rest 6
	octave 3
	note_cutoff 4
	note G_, 7
	octave 4
	note F_, 6
	octave 3
	note G_, 7
	octave 4
	note E_, 6
	octave 3
	note G_, 7
	octave 4
	note D_, 6
	octave 3
	note G_, 7
	octave 4
	note_cutoff 8
	note C_, 4
	note C#, 4
	note C_, 5
	octave 3
	note_cutoff 4
	note A#, 6
	octave 4
	note C_, 7
	octave 3
	note A#, 6
	note G_, 7
	note F_, 6
	note F#, 7
	note_cutoff 8
	note G_, 6
	note_cutoff 4
	note C#, 7
	note C_, 6
	octave 2
	note A#, 7
	octave 3
	note_cutoff 8
	note C_, 4
	note C#, 4
	note C_, 5
	octave 2
	note A#, 6
	octave 3
	note_cutoff 4
	note C_, 7
	octave 2
	note A#, 6
	note G_, 7
	note F_, 6
	note F#, 7
	note G_, 6
	note_cutoff 8
	note A#, 7
	octave 3
	note C_, 6
	note D_, 7
	note_type 13, 9, 0
	sound_call .sub1
	octave 4
	note_type 1, 10, 0
	note C#, 3
	note D_, 3
	rest 7
	duty_cycle 2
	volume_envelope 9, 0
	rest 6
	octave 3
	note_cutoff 4
	note G_, 7
	octave 4
	note F_, 6
	octave 3
	note G_, 7
	octave 4
	note E_, 6
	octave 3
	note G_, 7
	octave 4
	note D_, 6
	octave 3
	note G_, 7
	octave 4
	note_cutoff 8
	note C_, 4
	note C#, 4
	note C_, 5
	octave 3
	note_cutoff 4
	note A#, 6
	octave 4
	note C_, 7
	octave 3
	note A#, 6
	note G_, 7
	note F_, 6
	note F#, 7
	note G_, 6
	note_cutoff 8
	note A#, 7
	octave 4
	note_cutoff 4
	note C_, 6
	octave 3
	note A#, 7
	octave 4
	note_cutoff 8
	note C#, 4
	note C_, 4
	octave 3
	note A#, 5
	note_cutoff 4
	note G_, 6
	note F_, 7
	note G_, 6
	note C#, 7
	note C_, 6
	octave 2
	note A#, 7
	octave 3
	note_cutoff 8
	note C_, 4
	note C#, 4
	note C_, 5
	octave 2
	note_cutoff 4
	note A#, 6
	note G_, 7
	note_cutoff 8
	sound_call .sub3
	octave 4
	note_type 1, 10, 0
	note C#, 3
	note D_, 3
	rest 7
	duty_cycle 2
	volume_envelope 9, 0
	rest 13
	note_cutoff 4
	note F_, 6
	rest 7
	note_cutoff 8
	note E_, 4
	note F_, 4
	note E_, 5
	note_cutoff 4
	note D_, 6
	rest 7
	note_cutoff 8
	note E_, 6
	note_cutoff 4
	note C_, 7
	octave 3
	note G_, 6
	octave 4
	note C_, 7
	note C#, 6
	note D_, 7
	octave 3
	note_cutoff 8
	note A#, 6
	note_cutoff 4
	note G_, 7
	rest 6
	note F_, 7
	note_cutoff 8
	note F#, 6
	note_cutoff 4
	note G_, 7
	note_cutoff 8
	note A#, 6
	note_cutoff 4
	note G_, 7
	note A#, 6
	octave 4
	note C_, 7
	note_cutoff 8
	note C#, 6
	note_cutoff 4
	note D_, 7
	note F_, 6
	note D_, 7
	note_cutoff 8
	note F_, 6
	octave 3
	note_cutoff 4
	note G_, 7
	octave 2
	note G_, 6
	octave 3
	note D_, 7
	duty_cycle 1
	note_cutoff 8
	volume_envelope 10, 0
	sound_call .sub3
	octave 4
	note_type 1, 10, 0
	note C#, 3
	note D_, 3
	rest 7
	rest 13
	octave 3
	note G_, 3
	note G#, 10
	note G_, 3
	rest 10
	note_type 13, 10, 0
	note F_, 4
	vibrato_table 8, 12
	note_type 1, 9, 3
	note C_, 6
	rest 7
	rest 13
	note F_, 6
	rest 7
	rest 13
	note A_, 6
	rest 7
	rest 13
	note_type 13, 9, 0
	note G_, 2
	rest 1
	vibrato_table 8, 20
	note_type 1, 10, 0
	note F#, 3
	note G_, 10
	note A#, 3
	rest 10
	note G_, 3
	rest 10
	octave 4
	note D_, 13
	rest 13
	octave 3
	note A#, 6
	rest 7
	rest 13
	note A#, 3
	octave 4
	note C_, 10
	rest 13
	octave 3
	note A#, 3
	rest 10
	octave 4
	note C_, 13
	octave 3
	note A#, 3
	rest 10
	octave 4
	note C#, 4
	note C_, 4
	octave 3
	note A#, 5
	note G_, 3
	rest 10
	note B_, 3
	octave 4
	note C_, 10
	octave 3
	note A#, 3
	rest 10
	rest 13
	octave 4
	note G_, 3
	rest 10
	note C_, 4
	note C#, 4
	note C_, 5
	octave 3
	note A#, 3
	rest 10
	octave 4
	note C_, 13
	octave 3
	note A#, 3
	rest 10
	note G_, 3
	rest 10
	octave 4
	note E_, 3
	note F_, 10
	rest 13
	note D#, 13
	rest 13
	note D_, 6
	rest 7
	rest 13
	note C_, 6
	rest 7
	rest 13
	note C#, 3
	rest 10
	note C#, 3
	note D_, 10
	octave 3
	note A#, 3
	rest 10
	note G_, 3
	rest 10
	note_type 13, 10, 0
	note A#, 3
	rest 4
	note_type 1, 10, 0
	note B_, 3
	octave 4
	note C_, 16
	rest 7
	note E_, 3
	note F_, 10
	rest 6
	note D_, 7
	rest 13
	note C_, 6
	rest 7
	note C#, 3
	note D_, 10
	tie
	note_type 13, 10, 0
	note D_, 5
	rest 1
	octave 3
	note D_, 8
	rest 1
	duty_cycle 0
	vibrato_table 8, 12
	sound_loop 0, .mainloop

.sub1:
	octave 4
	duty_cycle 1
	volume_envelope 10, 0
	rest 2
	note_type 1, 10, 0
	note G#, 3
	note A_, 3
	rest 7
	rest 13
	note F_, 13
	note D_, 3
	rest 10
	rest 13
	note E_, 6
	rest 7
	note_type 13, 10, 0
	rest 1
	note F_, 1
	note_type 1, 10, 0
	note G_, 3
	rest 10
	note E_, 6
	rest 7
	rest 13
	note C_, 6
	rest 7
	rest 13
	sound_ret

.sub2:
	octave 3
	duty_cycle 0
	note_type 1, 9, 2
	note F_, 6
	rest 7
	note_type 13, 9, 2
	rest 2
	note_type 1, 9, 2
	note F_, 6
	rest 7
	note_type 13, 9, 2
	rest 3
	note_type 1, 9, 2
	note F_, 6
	rest 7
	rest 13
	note A_, 6
	rest 7
	rest 13
	note_type 13, 9, 0
	note G_, 2
	rest 1
	sound_ret

.sub3:
	octave 4
	duty_cycle 1
	note_type 1, 10, 0
	note D#, 3
	note E_, 10
	note F_, 3
	rest 10
	note G_, 3
	rest 10
	note E_, 6
	rest 7
	rest 13
	note C_, 6
	rest 7
	rest 13
	note D_, 6
	rest 7
	rest 13
	note D#, 3
	note E_, 10
	note F_, 3
	rest 10
	note G_, 3
	rest 10
	note E_, 13
	note C_, 6
	rest 7
	rest 13
	sound_ret

Music_TcgRonald_Ch2:
	release_envelope 0, 0
	note_cutoff 8
	duty_cycle 0
	vibrato_table 8, 12
.mainloop:
	octave 2
.loop1:
	note_type 1, 9, 2
	note G_, 3
	rest 3
	note G_, 3
	rest 4
	note A#, 3
	rest 10
	octave 3
	note D_, 6
	octave 2
	note G_, 3
	rest 4
	note A#, 3
	rest 3
	rest 13
	note G_, 3
	note D_, 4
	note A#, 6
	rest 7
	note D_, 3
	rest 3
	note G_, 3
	rest 4
	note G_, 6
	rest 7
	rest 13
	note A#, 6
	rest 13
	note G_, 3
	note A#, 4
	octave 3
	note D_, 6
	rest 7
	rest 13
	note_type 13, 9, 0
	note C_, 2
	rest 1
	octave 2
	note_type 1, 9, 2
	note D_, 3
	rest 3
	note G_, 3
	rest 4
	note A#, 3
	rest 10
	octave 3
	note D_, 6
	octave 2
	note G_, 3
	rest 4
	note A#, 3
	rest 3
	rest 13
	note G_, 3
	note A#, 4
	octave 3
	note D_, 6
	rest 7
	octave 2
	note D_, 3
	rest 3
	note G_, 3
	rest 4
	note G_, 6
	rest 7
	rest 13
	octave 3
	note D_, 6
	rest 13
	octave 2
	note A#, 3
	octave 3
	note D_, 4
	note F_, 6
	rest 7
	rest 13
	note_type 13, 9, 0
	note E_, 2
	rest 1
	octave 2
	sound_loop 2, .loop1
.loop2:
	sound_call .sub1
	note_cutoff 8
	volume_envelope 8, 0
	note C_, 2
	rest 1
	sound_call .sub1
	note_cutoff 8
	volume_envelope 8, 0
	note E_, 2
	rest 1
	sound_loop 4, .loop2
.loop3:
	duty_cycle 1
	octave 4
	vibrato_table 8, 20
	note_type 13, 8, 0
	rest 2
	note_cutoff 4
	note F_, 1
	rest 1
	note_cutoff 8
	note D_, 1
	octave 3
	octave 2
	note_cutoff 4
	duty_cycle 0
	volume_envelope 9, 2
	note A#, 1
	rest 1
	octave 3
	octave 4
	duty_cycle 1
	volume_envelope 8, 0
	note C_, 1
	rest 1
	note_cutoff 8
	note D_, 1
	note_cutoff 3
	note E_, 1
	note_cutoff 4
	note C_, 1
	rest 1
	octave 3
	note A_, 1
	rest 1
	note A#, 1
	rest 2
	duty_cycle 0
	vibrato_table 8, 12
	volume_envelope 9, 2
	note F_, 1
	rest 2
	note F_, 1
	rest 1
	octave 2
	note G_, 1
	rest 1
	octave 3
	note F_, 1
	rest 1
	note A_, 1
	rest 1
	note_cutoff 8
	volume_envelope 9, 0
	note G_, 2
	rest 1
	sound_loop 2, .loop3
	vibrato_table 8, 20
	sound_call .sub2
	octave 3
	rest 2
	duty_cycle 0
	note_cutoff 4
	vibrato_table 8, 12
	volume_envelope 9, 2
	note F_, 1
	rest 2
	note F_, 1
	rest 1
	octave 2
	note G_, 1
	rest 1
	octave 3
	note F_, 1
	rest 1
	note A_, 1
	rest 1
	note_cutoff 8
	volume_envelope 9, 0
	note G_, 2
	rest 1
	vibrato_table 8, 20
	sound_call .sub2
	octave 3
	rest 1
	note_cutoff 8
	note_type 1, 8, 0
	note E_, 3
	note F_, 10
	note E_, 3
	rest 10
	note_type 13, 8, 0
	note D_, 4
	octave 2
	duty_cycle 0
	note_cutoff 4
	vibrato_table 8, 12
	volume_envelope 9, 2
	note G_, 1
	rest 1
	octave 3
	note D_, 1
	rest 1
	note D_, 1
	rest 1
	note_cutoff 8
	volume_envelope 9, 0
	note E_, 2
	rest 1
	sound_call .sub3
	rest 1
	note_cutoff 4
	octave 2
	note A#, 1
	rest 1
	note A#, 1
	rest 1
	octave 3
	note_cutoff 8
	volume_envelope 9, 0
	note C_, 2
	rest 1
	volume_envelope 9, 2
	rest 2
	note_cutoff 4
	note F_, 1
	rest 2
	note F_, 1
	rest 1
	note C_, 1
	rest 1
	note F_, 1
	rest 1
	note A_, 1
	rest 1
	note_cutoff 8
	volume_envelope 9, 0
	note F_, 2
	rest 1
	sound_call .sub3
	rest 1
	octave 2
	note_cutoff 4
	note G_, 1
	rest 1
	note G_, 1
	rest 1
	octave 3
	note_cutoff 8
	volume_envelope 9, 0
	note C_, 2
	rest 1
	rest 2
	octave 2
	note_cutoff 4
	volume_envelope 9, 2
	note G_, 1
	rest 2
	note G_, 1
	rest 1
	note_cutoff 8
	duty_cycle 1
	vibrato_table 8, 20
	volume_envelope 7, 0
	note F#, 8
	rest 1
	duty_cycle 0
	vibrato_table 8, 12
	sound_loop 0, .mainloop

.sub1:
	octave 2
	note_type 13, 9, 2
	rest 2
	note_cutoff 4
	note A#, 1
	rest 2
	note A#, 1
	rest 1
	note G_, 1
	rest 1
	note A#, 1
	rest 1
	octave 3
	note D_, 1
	rest 1
	sound_ret

.sub2:
	octave 4
	duty_cycle 1
	note_type 13, 8, 0
	note C_, 1
	note_cutoff 3
	note D_, 1
	note E_, 1
	note_cutoff 4
	note C_, 1
	rest 1
	octave 3
	note A_, 1
	rest 1
	note A#, 1
	rest 1
	octave 4
	note_cutoff 8
	note C_, 1
	note_cutoff 3
	note D_, 1
	note E_, 1
	note_cutoff 8
	note C_, 1
	octave 3
	note_cutoff 4
	note A_, 1
	rest 1
	note A#, 1
	sound_ret

.sub3:
	octave 2
	note_type 13, 9, 2
	rest 2
	note_cutoff 4
	note A#, 1
	rest 2
	note A#, 1
	rest 1
	octave 3
	note C_, 1
	sound_ret

Music_TcgRonald_Ch3:
	release_envelope 0, 0
	note_cutoff 8
	note_type 1, 1, 10
.mainloop:
	octave 2
.loop1:
	note G_, 13
	note G_, 2
	rest 4
	note G_, 5
	rest 2
	octave 3
	note A#, 6
	octave 2
	note F_, 2
	rest 5
	note F_, 6
	note F#, 3
	rest 4
	note G_, 2
	rest 4
	note G_, 3
	rest 10
	note F_, 7
	note G_, 6
	rest 7
	octave 3
	note C_, 13
	rest 6
	octave 4
	note C_, 2
	rest 11
	octave 3
	note C_, 2
	rest 5
	octave 2
	note E_, 13
	rest 6
	note F_, 7
	rest 6
	note F_, 7
	note F#, 13
	note G_, 13
	octave 3
	note C_, 6
	rest 7
	octave 2
	sound_loop 4, .loop1
.loop2:
	sound_call .sub1
	octave 3
	note A#, 6
	sound_call .sub2
	sound_call .sub1
	octave 4
	note F_, 6
	sound_call .sub2
	sound_loop 8, .loop2
	sound_call .sub3
	octave 2
	note D_, 13
	rest 6
	octave 3
	note D_, 2
	rest 5
	octave 4
	note D_, 6
	octave 2
	note D_, 2
	rest 5
	note D_, 13
	octave 4
	note D_, 6
	octave 2
	note A_, 7
	rest 6
	octave 3
	note C_, 7
	note C_, 13
	note C#, 13
	note D_, 6
	rest 7
	octave 2
	note C_, 13
	note C_, 2
	rest 4
	note C_, 5
	rest 2
	octave 4
	note D_, 6
	octave 2
	note G_, 2
	rest 5
	note G_, 6
	octave 3
	note C_, 3
	rest 4
	octave 2
	note C_, 2
	rest 4
	note C_, 3
	rest 4
	octave 4
	note D_, 6
	octave 2
	note G_, 7
	note C_, 6
	rest 7
	note D_, 13
	rest 6
	octave 3
	note D_, 2
	rest 5
	octave 4
	note D_, 6
	octave 2
	note D_, 2
	rest 5
	note D_, 13
	octave 4
	note F_, 6
	octave 2
	note A_, 7
	rest 6
	octave 3
	note D_, 7
	note D_, 13
	octave 2
	note A_, 13
	note D_, 6
	rest 7
	sound_call .sub3
	octave 2
	note G#, 13
	rest 6
	octave 3
	note G#, 2
	rest 5
	octave 4
	note D_, 6
	octave 2
	note G#, 2
	rest 5
	note G#, 13
	octave 4
	note D_, 6
	octave 3
	note D#, 7
	rest 6
	note G#, 7
	note G#, 13
	octave 2
	note G#, 13
	octave 3
	note D#, 6
	rest 7
	octave 2
	note A_, 13
	note A_, 2
	rest 4
	note A_, 5
	rest 2
	octave 4
	note D_, 6
	octave 3
	note E_, 2
	rest 5
	note E_, 6
	note E_, 3
	rest 4
	octave 2
	note A_, 2
	rest 4
	note A_, 3
	rest 4
	octave 4
	note D_, 6
	octave 3
	note E_, 7
	octave 2
	note A_, 6
	rest 7
	note_type 13, 1, 10
	note G#, 8
	rest 1
	note_type 1, 1, 10
	sound_loop 0, .mainloop

.sub1:
	octave 2
	note G_, 13
	note G_, 2
	rest 4
	note G_, 5
	rest 2
	octave 4
	note D_, 6
	octave 3
	note D_, 2
	rest 5
	note D_, 6
	note G_, 3
	rest 4
	octave 2
	note G_, 2
	rest 4
	note G_, 3
	rest 4
	octave 4
	note D_, 6
	octave 2
	note F_, 7
	note G_, 6
	rest 7
	octave 3
	note C_, 13
	rest 6
	octave 4
	note C_, 2
	rest 5
	note D_, 6
	octave 3
	note C_, 2
	rest 5
	octave 2
	note E_, 13
	octave 3
	sound_ret

.sub2:
	octave 2
	note F_, 7
	rest 6
	note F_, 7
	note F#, 13
	note G_, 13
	octave 3
	note C_, 6
	rest 7
	sound_ret

.sub3:
	octave 2
	note D#, 13
	note D#, 2
	rest 4
	note D#, 5
	rest 2
	octave 4
	note D_, 6
	octave 2
	note A#, 2
	rest 5
	note A#, 6
	octave 3
	note D#, 3
	rest 4
	octave 2
	note D#, 2
	rest 4
	note D#, 3
	rest 4
	octave 4
	note D_, 6
	octave 2
	note A#, 7
	note D#, 6
	rest 7
	sound_ret

Music_TcgRonald_Ch4:
	toggle_noise 6
	drum_speed 1
.mainloop:
.loop1:
	sound_call .sub1
	drum_note 7, 13
	sound_call .sub2
	drum_note 5, 7
	drum_note 1, 6
	drum_note 5, 7
	drum_note 9, 6
	drum_note 1, 7
	drum_note 3, 13
	drum_note 7, 6
	drum_note 5, 7
	sound_loop 3, .loop1
	sound_call .sub1
	drum_note 7, 13
	sound_call .sub2
	drum_note 5, 7
	drum_note 1, 13
	drum_note 9, 6
	drum_note 5, 3
	drum_note 5, 4
.loop2:
	drum_note 3, 6
	drum_note 3, 7
	sound_loop 2, .loop2
.loop3:
	sound_call .sub1
	drum_note 7, 13
	sound_call .sub2
	drum_note 5, 7
	drum_note 1, 6
	drum_note 5, 7
	drum_note 9, 6
	drum_note 1, 7
	drum_note 3, 13
	drum_note 7, 6
	drum_note 5, 7
	sound_loop 7, .loop3
	sound_call .sub1
	drum_note 7, 13
	sound_call .sub2
	drum_note 5, 3
	drum_note 5, 4
.loop4:
	drum_note 3, 6
	drum_note 3, 7
	sound_loop 4, .loop4
.loop5:
	sound_call .sub1
	drum_note 7, 13
	sound_call .sub2
	drum_note 5, 7
	drum_note 1, 6
	drum_note 5, 7
	drum_note 9, 6
	drum_note 1, 7
	drum_note 3, 13
	drum_note 7, 6
	drum_note 5, 7
	sound_loop 7, .loop5
	sound_call .sub1
	drum_note 7, 13
	sound_call .sub2
	drum_note 5, 3
	drum_note 5, 4
.loop6:
	drum_note 3, 6
	drum_note 3, 7
	sound_loop 4, .loop6
.loop7:
	sound_call .sub1
	drum_note 7, 13
	sound_loop 6, .loop7
	sound_call .sub1
	drum_speed 13
	drum_note 12, 4
	drum_speed 1
	rest 6
	drum_note 5, 3
	drum_note 5, 4
	drum_note 3, 6
	drum_note 3, 7
.loop8:
	drum_note 5, 6
	drum_note 3, 7
	sound_loop 2, .loop8
	drum_note 3, 6
	drum_note 5, 7
	sound_loop 0, .mainloop

.sub1:
	drum_note 1, 13
	drum_note 9, 6
	drum_note 1, 7
	drum_note 3, 13
	drum_note 1, 6
	drum_note 5, 7
	drum_note 1, 13
	drum_note 9, 6
	drum_note 1, 7
	drum_note 3, 13
	sound_ret

.sub2:
	drum_note 1, 13
	drum_note 9, 6
	drum_note 1, 7
	drum_note 3, 13
	drum_note 1, 6
	sound_ret
