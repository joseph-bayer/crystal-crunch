Music_TcgDuelTheme1:
	channel_count 4
	channel 1, Music_TcgDuelTheme1_Ch1
	channel 2, Music_TcgDuelTheme1_Ch2
	channel 3, Music_TcgDuelTheme1_Ch3
	channel 4, Music_TcgDuelTheme1_Ch4

Music_TcgDuelTheme1_Ch1:
	tempo 254
	volume 7, 7
	note_cutoff 8
	duty_cycle 2
	vibrato_table 8, 20
	note_type 7, 0, 0
.mainloop:
	octave 2
.loop1:
	rest 16
	sound_loop 7, .loop1
	rest 9
.loop2:
	rest 3
	sound_call .sub1
	note_type 1, 10, 0
	note F_, 4
	note F#, 3
	tie
	note_type 7, 10, 0
	note F#, 1
	volume_envelope 3, 7
	note F#, 1
	octave 2
	volume_envelope 10, 0
	note A_, 1
	rest 2
	octave 3
	volume_envelope 10, 0
	note D_, 10
	volume_envelope 3, 7
	note D_, 12
	sound_call .sub1
	volume_envelope 10, 0
	note F#, 2
	volume_envelope 3, 7
	note F#, 1
	volume_envelope 10, 0
	note A_, 13
	volume_envelope 3, 7
	note A_, 10
	volume_envelope 10, 0
	note F#, 1
	volume_envelope 3, 7
	note F#, 1
	volume_envelope 10, 0
	note F#, 1
	note G_, 1
	note A_, 1
	volume_envelope 3, 7
	note A_, 1
	note_type 1, 10, 0
	note A#, 4
	note B_, 3
	tie
	note_type 7, 10, 0
	note B_, 15
	volume_envelope 3, 7
	note B_, 4
	note_type 1, 10, 0
	note A#, 4
	note B_, 3
	tie
	note_type 7, 10, 0
	note B_, 3
	note A_, 3
	volume_envelope 3, 7
	note A_, 1
	volume_envelope 10, 0
	note G_, 2
	volume_envelope 3, 7
	note G_, 2
	note_type 1, 10, 0
	note G#, 4
	note A_, 3
	tie
	note_type 7, 10, 0
	note A_, 15
	volume_envelope 3, 7
	note A_, 4
	note_type 1, 10, 0
	note G#, 4
	note A_, 3
	tie
	note_type 7, 10, 0
	note A_, 3
	note G_, 4
	note F#, 2
	volume_envelope 3, 7
	note F#, 2
	note_type 1, 10, 0
	note F#, 4
	note G_, 3
	tie
	note_type 7, 10, 0
	note G_, 15
	volume_envelope 3, 7
	note G_, 4
	note_type 1, 10, 0
	note F#, 4
	note G_, 3
	tie
	note_type 7, 10, 0
	note G_, 3
	note F#, 4
	note E_, 3
	volume_envelope 3, 7
	note E_, 1
	note_type 1, 10, 0
	note D#, 4
	note E_, 3
	tie
	note_type 7, 10, 0
	note E_, 1
	volume_envelope 3, 7
	note E_, 1
	volume_envelope 10, 0
	note D_, 13
	volume_envelope 3, 7
	note D_, 9
	octave 2
	sound_loop 2, .loop2
	octave 3
	duty_cycle 1
	note_type 1, 10, 0
	note C#, 4
	note D_, 3
	tie
	note_type 7, 10, 0
	note D_, 1
	rest 1
	note D_, 1
	rest 1
	note C#, 1
	rest 1
	sound_call .sub2
	note_type 1, 10, 0
	note G#, 4
	note A_, 3
	tie
	note_type 7, 10, 0
	note A_, 1
	volume_envelope 3, 7
	note A_, 1
	volume_envelope 10, 0
	note F#, 5
	volume_envelope 3, 7
	note F#, 1
	octave 2
	volume_envelope 10, 0
	note A_, 1
	octave 3
	note_type 1, 10, 0
	note D_, 4
	volume_envelope 3, 7
	note D_, 3
	volume_envelope 10, 0
	note F#, 4
	volume_envelope 3, 7
	note F#, 3
	volume_envelope 10, 0
	note A_, 4
	volume_envelope 3, 7
	note A_, 3
	note_type 7, 3, 7
	rest 3
	octave 2
	duty_cycle 1
	note_cutoff 8
	volume_envelope 10, 0
.loop3:
	note A_, 1
	rest 2
	sound_loop 3, .loop3
	octave 3
	note_type 1, 10, 0
	note C#, 4
	note D_, 3
	tie
	note_type 7, 10, 0
	note D_, 1
	rest 1
	note D_, 1
	rest 1
	note C#, 1
	rest 1
	sound_call .sub2
	note_type 1, 10, 0
	note G#, 4
	note A_, 3
	tie
	note_type 7, 10, 0
	note A_, 5
	tie
	note A_, 10
	tie
	note A_, 6
	volume_envelope 3, 7
	note A_, 2
	octave 4
	note_type 1, 10, 0
	note C#, 4
	note D_, 3
	tie
	note_type 7, 10, 0
	note D_, 2
	note C#, 1
	volume_envelope 3, 7
	note C#, 2
	octave 3
	volume_envelope 10, 0
	note B_, 1
	volume_envelope 3, 7
	note B_, 1
	note_type 1, 10, 0
	note A#, 4
	note B_, 3
	tie
	note_type 7, 10, 0
	note B_, 1
	volume_envelope 3, 7
	note B_, 1
	volume_envelope 10, 0
	note A_, 13
	tie
	note A_, 6
	volume_envelope 3, 7
	note A_, 2
	octave 2
	note_type 1, 7, -1
	note A_, 5
	octave 3
	note C#, 5
	note E_, 4
	note A_, 5
	octave 4
	note C#, 5
	note E_, 4
	octave 3
	note C#, 5
	note E_, 5
	note A_, 4
	octave 4
	note C#, 5
	note E_, 5
	note A_, 4
	octave 3
	sound_call .sub3
	volume_envelope 10, 0
	note A_, 2
	tie
	note A_, 8
	tie
	note A_, 8
	tie
	note A_, 6
	duty_cycle 1
	octave 2
	note_type 1, 10, 0
	note B_, 4
	octave 3
	note C_, 3
	note_type 7, 10, 0
	note C#, 1
	rest 1
	note C#, 1
	note D_, 2
	note E_, 2
	note G_, 2
	duty_cycle 2
	sound_call .sub3
	note_type 1, 10, 0
	note G#, 4
	note A_, 3
	tie
	note_type 7, 10, 0
	note A_, 5
	note G_, 2
	note F#, 2
	volume_envelope 3, 7
	note F#, 2
	volume_envelope 10, 0
	note E_, 2
	volume_envelope 3, 7
	note E_, 2
	note_type 1, 10, 0
	note F#, 4
	note G_, 3
	tie
	note_type 7, 10, 0
	note G_, 5
	note F#, 2
	note E_, 2
	volume_envelope 3, 7
	note E_, 2
	volume_envelope 10, 0
	note D_, 2
	volume_envelope 3, 7
	note D_, 2
	volume_envelope 10, 0
	note D_, 8
	tie
	note D_, 8
	note D_, 8
	tie
	note D_, 8
	volume_envelope 3, 7
	note D_, 2
	volume_envelope 10, 0
	note D_, 12
	volume_envelope 3, 7
	note D_, 2
	volume_envelope 10, 0
	note D_, 6
	tie
	note D_, 8
	rest 4
	sound_loop 0, .mainloop

.sub1:
	octave 2
	volume_envelope 10, 0
	note A_, 1
	note B_, 1
	octave 3
	note D_, 1
	volume_envelope 3, 7
	note D_, 1
	note_type 1, 10, 0
	note F_, 4
	note F#, 3
	tie
	note_type 7, 10, 0
	note F#, 10
	volume_envelope 3, 7
	note F#, 1
	volume_envelope 10, 0
	note D_, 3
	volume_envelope 3, 7
	note D_, 1
	note_type 1, 10, 0
	note D#, 4
	note E_, 3
	tie
	note_type 7, 10, 0
	note E_, 5
	volume_envelope 3, 7
	note E_, 2
	note_type 1, 10, 0
	note F#, 4
	note G_, 3
	tie
	note_type 7, 10, 0
	note G_, 2
	note F#, 1
	volume_envelope 3, 7
	note F#, 2
	volume_envelope 10, 0
	note E_, 1
	volume_envelope 3, 7
	note E_, 1
	sound_ret

.sub2:
	note C_, 1
	rest 2
	octave 2
	note G_, 1
	rest 2
	note G_, 1
	rest 2
	duty_cycle 2
	volume_envelope 10, 0
	note G_, 1
	octave 3
	note_type 1, 10, 0
	note C_, 4
	volume_envelope 3, 7
	note C_, 3
	volume_envelope 10, 0
	note E_, 4
	volume_envelope 3, 7
	note E_, 3
	volume_envelope 10, 0
	note G_, 4
	volume_envelope 3, 7
	note G_, 3
	note_type 7, 3, 7
	rest 3
	duty_cycle 1
	note_cutoff 8
	octave 2
	volume_envelope 10, 0
.loop4:
	note G_, 1
	rest 2
	sound_loop 3, .loop4
	octave 3
	duty_cycle 2
	note_type 1, 10, 0
	note A#, 4
	note B_, 3
	tie
	note_type 7, 10, 0
	note B_, 2
	note A_, 1
	volume_envelope 3, 7
	note A_, 1
	volume_envelope 10, 0
	note G_, 1
	volume_envelope 3, 7
	note G_, 1
	volume_envelope 10, 0
	sound_ret

.sub3:
	note_type 1, 10, 0
	note F_, 4
	note F#, 3
	tie
	note_type 7, 10, 0
	note F#, 9
	volume_envelope 3, 7
	note F#, 2
	volume_envelope 10, 0
	note G_, 1
	volume_envelope 3, 7
	note G_, 1
	volume_envelope 10, 0
	note A_, 1
	volume_envelope 3, 7
	note A_, 1
	volume_envelope 10, 0
	note B_, 2
	volume_envelope 3, 7
	note B_, 2
	octave 4
	note_type 1, 10, 0
	note F_, 4
	note F#, 3
	tie
	note_type 7, 10, 0
	note F#, 7
	note E_, 1
	volume_envelope 3, 7
	note E_, 1
	volume_envelope 10, 0
	note D_, 1
	volume_envelope 3, 7
	note D_, 1
	volume_envelope 10, 0
	note C#, 2
	volume_envelope 3, 7
	note C#, 1
	octave 3
	volume_envelope 10, 0
	note A_, 9
	note F#, 1
	volume_envelope 3, 7
	note F#, 1
	note_type 1, 10, 0
	note A#, 4
	note B_, 3
	tie
	note_type 7, 10, 0
	note B_, 8
	volume_envelope 3, 7
	note B_, 1
	volume_envelope 10, 0
	note A_, 4
	note G_, 4
	note F#, 10
	note G_, 1
	volume_envelope 3, 7
	note G_, 1
	volume_envelope 10, 0
	note A_, 1
	volume_envelope 3, 7
	note A_, 1
	volume_envelope 10, 0
	note D_, 10
	note E_, 2
	note F#, 2
	volume_envelope 3, 7
	note F#, 2
	sound_ret

Music_TcgDuelTheme1_Ch2:
	release_envelope 0, 0
	note_cutoff 8
	vibrato_table 8, 20
	note_type 7, 0, 0
.mainloop:
	duty_cycle 1
	octave 2
	volume_envelope 9, 0
.loop1:
	note D_, 1
	rest 2
	note D_, 1
	rest 2
	note D_, 1
	rest 2
	rest 1
	octave 1
	note A_, 1
	rest 1
	note A_, 1
	note B_, 1
	rest 2
	octave 2
	sound_loop 4, .loop1
.loop2:
	octave 2
	note D_, 1
	rest 2
	note D_, 1
	duty_cycle 2
	note_cutoff 6
	volume_envelope 10, 2
	note A_, 2
	sound_call .sub1
	sound_loop 4, .loop2
	octave 2
	note D_, 1
	rest 2
	note D_, 1
	duty_cycle 2
	octave 3
	note_cutoff 6
	volume_envelope 10, 2
	note D_, 2
	sound_call .sub1
	octave 2
	note D_, 1
	rest 2
	note D_, 1
	duty_cycle 2
	octave 3
	note_cutoff 6
	volume_envelope 10, 2
	note C_, 2
	octave 2
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note D_, 1
	rest 3
	octave 1
	note A_, 1
	rest 1
	octave 2
	duty_cycle 2
	note_cutoff 6
	volume_envelope 10, 2
	note G_, 1
	octave 1
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note B_, 1
	rest 2
	octave 2
.loop3:
	octave 2
	note D_, 1
	rest 2
	note D_, 1
	duty_cycle 2
	octave 3
	note_cutoff 6
	volume_envelope 10, 2
	note D_, 2
	sound_call .sub1
	sound_loop 3, .loop3
	octave 2
	note D_, 1
	rest 2
	note D_, 1
	duty_cycle 2
	octave 3
	note_cutoff 6
	volume_envelope 10, 2
	note C_, 2
	octave 2
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note D_, 1
	rest 3
	octave 1
	note A_, 1
	rest 1
	octave 2
	duty_cycle 2
	note_cutoff 6
	volume_envelope 10, 2
	note G_, 1
	octave 1
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note B_, 1
	rest 2
	octave 2
	note D_, 1
	rest 2
	note D_, 1
	duty_cycle 2
	octave 3
	note_cutoff 6
	volume_envelope 10, 2
	note D_, 2
	sound_call .sub1
	octave 2
	note D_, 1
	rest 2
	note D_, 1
	duty_cycle 2
	octave 3
	note_cutoff 6
	volume_envelope 10, 2
	note D_, 2
	octave 2
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note D_, 1
	rest 3
	note D_, 1
	rest 1
	duty_cycle 2
	note_cutoff 6
	volume_envelope 10, 2
	note A_, 2
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note F#, 1
	rest 1
.loop4:
	note G_, 1
	rest 2
	note G_, 1
	duty_cycle 2
	note_cutoff 6
	volume_envelope 10, 2
	note G_, 2
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note G_, 1
	rest 3
	note D_, 1
	rest 1
	duty_cycle 2
	note_cutoff 6
	volume_envelope 10, 2
	note G_, 1
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note E_, 1
	rest 2
	sound_loop 2, .loop4
	note F#, 1
	rest 2
	note F#, 1
	duty_cycle 2
	note_cutoff 6
	octave 3
	volume_envelope 10, 2
	note C#, 2
	sound_call .sub2
	octave 2
	note F#, 1
	rest 2
	note F#, 1
	octave 3
	duty_cycle 2
	note_cutoff 6
	volume_envelope 10, 2
	note E_, 2
	sound_call .sub2
	note E_, 1
	rest 2
	note E_, 1
	duty_cycle 2
	note_cutoff 6
	volume_envelope 10, 2
	note G_, 2
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note E_, 1
	rest 3
	note E_, 1
	rest 1
	duty_cycle 2
	note_cutoff 6
	volume_envelope 10, 2
	note B_, 1
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note G_, 1
	rest 2
	note A_, 1
	rest 2
	note A_, 1
	duty_cycle 2
	note_cutoff 6
	volume_envelope 10, 2
	note G_, 2
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note A_, 1
	rest 3
	note E_, 1
	rest 1
	duty_cycle 2
	note_cutoff 6
	volume_envelope 10, 2
	note A_, 1
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note A_, 1
	rest 2
	note D_, 1
	rest 2
	note D_, 1
	duty_cycle 2
	note_cutoff 6
	volume_envelope 10, 2
	note A_, 2
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note D_, 1
	rest 3
	octave 1
	note A_, 1
	rest 1
	octave 2
	duty_cycle 2
	note_cutoff 6
	volume_envelope 10, 2
	note A_, 1
	octave 1
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note B_, 1
	rest 2
	octave 2
	note D_, 1
	rest 2
	note D_, 1
	duty_cycle 2
	note_cutoff 6
	volume_envelope 10, 2
	note A_, 2
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note D_, 1
	rest 3
	octave 1
	note A_, 1
	rest 1
	octave 2
	duty_cycle 2
	volume_envelope 7, 0
	note E_, 1
	note F#, 1
	note A_, 1
	rest 1
	volume_envelope 7, 0
	sound_call .sub3
	octave 3
	note_type 1, 7, 0
	note C#, 4
	note D_, 3
	tie
	note_type 7, 7, 0
	note D_, 1
	rest 1
	octave 2
	note F#, 1
	note_cutoff 6
	volume_envelope 10, 2
	note F#, 2
	note_cutoff 8
	volume_envelope 7, 0
	note A_, 10
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note D_, 1
	rest 2
	note D_, 1
	duty_cycle 2
	note_cutoff 6
	octave 3
	volume_envelope 10, 2
	note D_, 2
	octave 2
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note D_, 1
	rest 3
	octave 1
	note A_, 1
	rest 1
	octave 2
	duty_cycle 2
	volume_envelope 7, 0
	note E_, 1
	note F#, 1
	note A_, 1
	rest 1
	sound_call .sub3
	octave 3
	volume_envelope 7, 0
	note D_, 2
	rest 1
	note F#, 13
	octave 2
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note D_, 1
	rest 2
	note D_, 1
	duty_cycle 2
	octave 3
	note_cutoff 6
	volume_envelope 10, 2
	note D_, 2
	octave 2
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note D_, 1
	rest 3
	octave 3
	duty_cycle 2
	volume_envelope 7, 0
	note D_, 1
	rest 1
	note D_, 1
	note E_, 1
	note F#, 1
	rest 1
	note_type 1, 7, 0
	note F#, 4
	note G_, 3
	tie
	note_type 7, 7, 0
	note G_, 15
	octave 2
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note G_, 1
	rest 2
	note G_, 1
	octave 3
	duty_cycle 2
	note_type 1, 7, 0
	note F#, 4
	note G_, 3
	tie
	note_type 7, 7, 0
	note G_, 2
	rest 1
	note F#, 3
	rest 1
	octave 2
	note_cutoff 6
	volume_envelope 10, 2
	note G_, 1
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note E_, 1
	rest 2
	octave 3
	duty_cycle 2
	note_type 1, 7, 0
	note E_, 4
	note F#, 3
	tie
	note_type 7, 7, 0
	note F#, 15
	octave 2
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note F#, 1
	rest 2
	note F#, 1
	octave 3
	duty_cycle 2
	note_type 1, 7, 0
	note E_, 4
	note F#, 3
	tie
	note_type 7, 7, 0
	note F#, 2
	rest 1
	note E_, 3
	rest 1
	octave 2
	note_cutoff 6
	volume_envelope 10, 2
	note A_, 1
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note E_, 1
	rest 2
	octave 3
	duty_cycle 2
	note_type 1, 7, 0
	note D#, 4
	note E_, 3
	tie
	note_type 7, 7, 0
	note E_, 15
	octave 2
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note A_, 1
	rest 2
	note A_, 1
	duty_cycle 2
	note_type 1, 7, 0
	note A#, 4
	note B_, 3
	tie
	note_type 7, 7, 0
	note B_, 2
	rest 1
	note A_, 3
	rest 1
	note G_, 3
	rest 1
	note_type 1, 7, 0
	note F#, 4
	note G_, 3
	tie
	note_type 7, 7, 0
	note G_, 1
	rest 1
	note F#, 13
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note D_, 1
	rest 2
	note D_, 1
	octave 3
	duty_cycle 2
	note_cutoff 6
	volume_envelope 10, 2
	note D_, 2
	octave 2
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note D_, 1
	rest 2
	sound_call .sub4
	octave 3
	note_type 1, 7, 0
	note F_, 4
	note F#, 3
	tie
	note_type 7, 7, 0
	note F#, 1
	rest 1
	note D_, 5
	rest 1
	octave 2
	note F#, 1
	note_type 1, 7, 0
	note A_, 4
	rest 3
	octave 3
	note D_, 4
	rest 3
	note F#, 4
	rest 3
	note_type 7, 7, 0
	rest 3
	octave 2
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
.loop5:
	note D_, 1
	rest 2
	sound_loop 3, .loop5
	sound_call .sub4
	octave 3
	volume_envelope 8, 0
	note D_, 16
	tie
	note D_, 6
	rest 2
	note_type 1, 8, 0
	note G#, 4
	note A_, 3
	tie
	note_type 7, 8, 0
	note A_, 2
	note A_, 1
	rest 2
	note A_, 1
	rest 1
	note D_, 2
	rest 1
	note D_, 13
	note C#, 6
	rest 2
	octave 2
	note_type 1, 7, -1
	note E_, 5
	note A_, 5
	octave 3
	note C#, 4
	note E_, 5
	note A_, 5
	octave 4
	note C#, 4
	octave 3
	octave 2
	note A_, 5
	octave 3
	note C#, 5
	note E_, 4
	note A_, 5
	octave 4
	note C#, 5
	note E_, 4
	octave 3
	note_type 7, 7, -1
	sound_call .sub5
	note D_, 8
	tie
	note D_, 8
	note C#, 6
	octave 2
	duty_cycle 1
	note_type 1, 7, 0
	note G_, 4
	note G#, 3
	note_type 7, 7, 0
	note A_, 1
	rest 1
	note A_, 1
	note B_, 2
	octave 3
	note C#, 2
	note E_, 2
	duty_cycle 2
	sound_call .sub5
	note D_, 4
	note E_, 2
	note D_, 2
	rest 2
	note C#, 2
	rest 2
	note E_, 6
	note D_, 2
	note C#, 2
	rest 2
	octave 2
	note A_, 2
	rest 2
	note G_, 8
	tie
	note G_, 8
	note F#, 8
	tie
	note F#, 8
	rest 2
	note G_, 12
	rest 2
	note G_, 14
	rest 4
	sound_loop 0, .mainloop

.sub1:
	octave 2
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note D_, 1
	rest 3
	octave 1
	note A_, 1
	rest 1
	octave 2
	duty_cycle 2
	note_cutoff 6
	volume_envelope 10, 2
	note A_, 1
	octave 1
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note B_, 1
	rest 2
	sound_ret

.sub2:
	octave 2
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note F#, 1
	rest 3
	note C#, 1
	rest 1
	duty_cycle 2
	note_cutoff 6
	volume_envelope 10, 2
	note A_, 1
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note E_, 1
	rest 2
	sound_ret

.sub3:
	octave 3
	note_type 1, 7, 0
	note C#, 4
	note D_, 3
	tie
	note_type 7, 7, 0
	note D_, 9
	octave 2
	duty_cycle 1
	octave 1
	volume_envelope 9, 0
	note A_, 1
	rest 1
	octave 2
	duty_cycle 2
	volume_envelope 7, 0
	note A_, 3
	rest 1
	octave 3
	note C_, 6
	octave 2
	duty_cycle 1
	note_cutoff 8
	volume_envelope 9, 0
	note D_, 1
	rest 1
	octave 3
	duty_cycle 2
	note_type 1, 7, 0
	note D#, 4
	note E_, 3
	tie
	note_type 7, 7, 0
	note E_, 2
	note D_, 1
	octave 2
	note_cutoff 6
	volume_envelope 10, 2
	note G_, 2
	octave 3
	note_cutoff 8
	volume_envelope 7, 0
	note C_, 1
	rest 1
	sound_ret

.sub4:
	octave 2
	note_type 1, 8, 0
	note G#, 4
	note A_, 3
	tie
	note_type 7, 8, 0
	note A_, 1
	rest 1
	note A_, 1
	rest 1
	note G#, 1
	rest 1
	note G_, 1
	rest 2
	note C_, 1
	rest 2
	note C_, 1
	rest 2
	duty_cycle 2
	volume_envelope 7, 0
	note E_, 1
	note_type 1, 7, 0
	note G_, 4
	rest 3
	octave 3
	note C_, 4
	rest 3
	note E_, 4
	rest 3
	note_type 7, 7, 0
	rest 3
	note_cutoff 8
	octave 2
	duty_cycle 1
	volume_envelope 8, 0
.loop6:
	note C_, 1
	rest 2
	sound_loop 3, .loop6
	octave 3
	duty_cycle 2
	note_type 1, 7, 0
	note F#, 4
	note G_, 3
	tie
	note_type 7, 7, 0
	note G_, 2
	note F#, 1
	rest 1
	note E_, 1
	rest 1
	sound_ret

.sub5:
	volume_envelope 8, 0
	note D_, 10
	rest 2
	note E_, 1
	rest 1
	note F#, 1
	rest 1
	note G_, 2
	rest 2
	octave 4
	note D_, 8
	note C#, 1
	rest 1
	octave 3
	note B_, 1
	rest 1
	note A_, 2
	rest 1
	note F#, 9
	note D_, 1
	rest 1
	note G_, 9
	rest 1
	note F#, 4
	note E_, 4
	note D_, 10
	note E_, 1
	rest 1
	note F#, 1
	rest 1
	octave 2
	note B_, 10
	octave 3
	note C#, 2
	note D_, 2
	rest 2
	note D_, 2
	tie
	sound_ret

Music_TcgDuelTheme1_Ch3:
	release_envelope 3, 0
	note_cutoff 8
	octave 2
	note_type 7, 1, 12
.mainloop:
.loop1:
	note D_, 1
	rest 2
	note D_, 1
	rest 2
	note D_, 1
	rest 2
	rest 1
	sound_call .sub1
	sound_loop 4, .loop1
.loop2:
	note D_, 1
	rest 2
	note D_, 1
	octave 3
	octave 4
	note_cutoff 3
	note D_, 2
	octave 3
	octave 2
	note_cutoff 8
	note D_, 1
	rest 3
	sound_call .sub1
	sound_loop 4, .loop2
	sound_call .sub2
	note D_, 1
	rest 2
	note D_, 1
	octave 3
	note_cutoff 3
	note F#, 2
	octave 2
	note_cutoff 8
	note D_, 1
	rest 3
	sound_call .sub1
	note D_, 1
	rest 2
	note D_, 1
	octave 3
	octave 4
	note_cutoff 3
	note D_, 2
	octave 3
	octave 2
	note_cutoff 8
	note D_, 1
	rest 3
	sound_call .sub1
	sound_call .sub2
	note D_, 1
	rest 2
	note D_, 1
	octave 3
	note_cutoff 3
	note A_, 2
	octave 2
	note_cutoff 8
	note D_, 1
	rest 3
	sound_call .sub1
	note D_, 1
	rest 2
	note D_, 1
	octave 3
	note_cutoff 3
	note A_, 2
	octave 2
	note_cutoff 8
	note D_, 1
	rest 2
	note D_, 2
	rest 1
	note D_, 1
	rest 1
	note C#, 1
	rest 1
	sound_call .sub3
	octave 3
	note C_, 3
	octave 2
	note G_, 1
	rest 1
	octave 3
	note C_, 1
	rest 1
	octave 2
.loop3:
	note D_, 1
	rest 2
	sound_loop 3, .loop3
	octave 3
	note D_, 1
	note_type 1, 1, 12
	note F#, 4
	rest 3
	note A_, 4
	rest 3
	octave 4
	note D_, 4
	rest 3
	note_type 7, 1, 12
	rest 3
	octave 3
	octave 2
.loop4:
	note D_, 1
	rest 2
	sound_loop 3, .loop4
	note D_, 2
	rest 1
	note D_, 1
	rest 1
	note C#, 1
	rest 1
	sound_call .sub3
	octave 2
	note C_, 3
	note D_, 1
	rest 1
	note D#, 1
	rest 1
	sound_call .sub4
	octave 2
	note_cutoff 8
	note E_, 1
	rest 1
	note E_, 2
	note_cutoff 6
	note B_, 2
	sound_call .sub4
	octave 2
	note_cutoff 8
	note F#, 2
	note G_, 2
	note_cutoff 6
	note G#, 2
	sound_call .sub5
	octave 2
	note_cutoff 8
	note A_, 1
	rest 1
	note A_, 2
	note_cutoff 6
	note E_, 2
	sound_call .sub5
	octave 2
	note_cutoff 8
	note B_, 2
	octave 3
	note C_, 2
	note C#, 2
	octave 2
.loop5:
	sound_call .sub6
	note E_, 1
	rest 1
	note E_, 1
	rest 1
	note E_, 2
	rest 1
	note E_, 1
	rest 1
	note E_, 1
	rest 1
	note_cutoff 7
	note E_, 1
	note_cutoff 8
	note E_, 1
	rest 1
	note E_, 2
	note F#, 1
	rest 1
	note F#, 1
	rest 1
	note F#, 2
	rest 1
	note F#, 1
	rest 1
	note F#, 1
	rest 1
	note_cutoff 7
	note F#, 1
	note_cutoff 8
	note F#, 1
	rest 1
	note F#, 2
	note G_, 1
	rest 1
	note G_, 1
	rest 1
	note G_, 2
	rest 1
	note G_, 1
	rest 1
	note G_, 1
	rest 1
	note_cutoff 7
	note G_, 1
	note_cutoff 8
	note F#, 1
	rest 1
	note E_, 2
	sound_call .sub6
	note B_, 1
	rest 1
	note B_, 1
	rest 1
	note B_, 2
	rest 1
	note B_, 1
	rest 1
	note B_, 1
	rest 1
	note_cutoff 7
	note B_, 1
	note_cutoff 8
	note F#, 1
	rest 1
	note F_, 2
	note E_, 1
	rest 1
	note E_, 1
	rest 1
	note E_, 2
	rest 1
	note E_, 1
	rest 1
	note E_, 1
	note F#, 2
	note G_, 2
	note G#, 2
	note A_, 1
	rest 1
	note A_, 1
	rest 1
	note A_, 2
	rest 1
	note B_, 1
	rest 1
	note B_, 1
	note A_, 2
	note E_, 2
	note C#, 2
	sound_loop 2, .loop5
.loop6:
	sound_call .sub6
	sound_loop 2, .loop6
	note D_, 1
	rest 1
	note D_, 1
	rest 1
	note D_, 2
	rest 1
	note D_, 1
	rest 1
	note D_, 1
	rest 1
	note_cutoff 7
	note D_, 1
	note_cutoff 8
	note D_, 1
	rest 1
	note A_, 14
	rest 4
	sound_loop 0, .mainloop

.sub1:
	note A_, 1
	rest 1
	note A_, 1
	note B_, 1
	rest 2
	sound_ret

.sub2:
	note D_, 1
	rest 2
	note D_, 1
	octave 3
	note_cutoff 3
	note A_, 2
	octave 2
	note_cutoff 8
	note D_, 1
	rest 3
	note A_, 1
	rest 1
	note A_, 1
	note B_, 1
	rest 2
	note D_, 1
	rest 2
	note D_, 1
	octave 3
	note_cutoff 3
	note G_, 2
	octave 2
	note_cutoff 8
	note D_, 1
	rest 3
	note A_, 1
	rest 1
	note A_, 1
	note B_, 1
	rest 2
.loop7:
	note D_, 1
	rest 2
	note D_, 1
	octave 3
	note_cutoff 3
	note A_, 2
	octave 2
	note_cutoff 8
	note D_, 1
	rest 3
	note A_, 1
	rest 1
	note A_, 1
	note B_, 1
	rest 2
	sound_loop 3, .loop7
	note D_, 1
	rest 2
	note D_, 1
	octave 3
	note_cutoff 3
	note G_, 2
	octave 2
	note_cutoff 8
	note D_, 1
	rest 3
	note A_, 1
	rest 1
	note A_, 1
	note B_, 1
	rest 2
	note D_, 1
	rest 2
	note D_, 1
	octave 3
	note_cutoff 3
	note A_, 2
	octave 2
	note_cutoff 8
	note D_, 1
	rest 3
	note A_, 1
	rest 1
	note A_, 1
	note B_, 1
	rest 2
	note D_, 1
	rest 2
	note D_, 1
	octave 3
	note_cutoff 3
	note A_, 2
	octave 2
	note_cutoff 8
	note D_, 1
	rest 3
	note D_, 1
	rest 1
	note E_, 2
	note F#, 1
	rest 1
.loop8:
	note G_, 1
	rest 2
	note G_, 1
	octave 3
	note_cutoff 3
	note B_, 2
	octave 2
	note_cutoff 8
	note G_, 1
	rest 3
	note D_, 1
	rest 1
	note D_, 1
	note E_, 1
	rest 2
	sound_loop 2, .loop8
	note F#, 1
	rest 2
	note F#, 1
	octave 3
	note_cutoff 3
	note A_, 2
	octave 2
	note_cutoff 8
	note F#, 1
	rest 3
	note C#, 1
	rest 1
	note C#, 1
	note E_, 1
	rest 2
	note F#, 1
	rest 2
	note F#, 1
	octave 3
	octave 4
	note_cutoff 3
	note C#, 2
	octave 3
	octave 2
	note_cutoff 8
	note F#, 1
	rest 3
	note C#, 1
	rest 1
	note C#, 1
	note E_, 1
	rest 2
	note E_, 1
	rest 2
	note E_, 1
	octave 3
	note_cutoff 3
	note B_, 2
	octave 2
	note_cutoff 8
	note E_, 1
	rest 3
	note E_, 1
	rest 1
	note F#, 1
	note G_, 1
	rest 2
	note A_, 1
	rest 2
	note A_, 1
	octave 3
	note_cutoff 3
	note B_, 2
	octave 2
	note_cutoff 8
	note A_, 1
	rest 3
	note E_, 1
	rest 1
	note F#, 1
	note A_, 1
	rest 2
	sound_ret

.sub3:
	octave 2
.loop9:
	note C_, 1
	rest 2
	sound_loop 3, .loop9
	octave 3
	note C_, 1
	note_type 1, 1, 12
	note E_, 4
	rest 3
	note G_, 4
	rest 3
	octave 4
	note C_, 4
	rest 3
	note_type 7, 1, 12
	rest 3
	octave 3
	octave 2
.loop10:
	note C_, 1
	rest 2
	sound_loop 3, .loop10
	sound_ret

.sub4:
	octave 2
	note_cutoff 8
	note E_, 1
	rest 1
	note E_, 1
	rest 1
	note E_, 2
	rest 1
	note E_, 1
	rest 1
	note_cutoff 6
	note E_, 1
	sound_ret

.sub5:
	octave 2
	note_cutoff 8
	note A_, 1
	rest 1
	note A_, 1
	rest 1
	note A_, 2
	rest 1
	note A_, 1
	rest 1
	note_cutoff 6
	note A_, 1
	sound_ret

.sub6:
	note D_, 1
	rest 1
	note D_, 1
	rest 1
	note D_, 2
	rest 1
	note D_, 1
	rest 1
	note D_, 1
	rest 1
	note_cutoff 7
	note D_, 1
	note_cutoff 8
	note D_, 1
	rest 1
	note D_, 2
	sound_ret

Music_TcgDuelTheme1_Ch4:
	toggle_noise 6
	drum_speed 7
.mainloop:
.loop1:
	drum_note 1, 2
	drum_note 7, 1
	drum_note 9, 1
	drum_note 7, 1
	drum_note 1, 1
	drum_note 5, 2
	drum_note 7, 1
	drum_note 1, 1
	drum_note 9, 2
	drum_note 3, 1
	drum_note 9, 1
	rest 1
	drum_note 7, 1
	sound_loop 3, .loop1
	drum_note 1, 2
	drum_note 7, 1
	drum_note 9, 1
	drum_note 7, 1
	drum_note 1, 1
	drum_note 5, 2
	drum_note 7, 1
	drum_note 3, 1
	drum_note 9, 1
	drum_speed 1
	drum_note 5, 4
	drum_note 5, 3
	drum_speed 7
	drum_note 3, 1
	drum_note 3, 1
	drum_note 3, 2
.loop2:
	sound_call .sub1
	sound_loop 3, .loop2
	sound_call .sub2
.loop3:
	sound_call .sub1
	sound_loop 15, .loop3
	sound_call .sub2
.loop4:
	sound_call .sub1
	sound_loop 15, .loop4
	drum_note 1, 2
	drum_note 7, 1
	drum_note 9, 1
	drum_note 3, 2
	drum_note 9, 2
	drum_note 7, 1
	drum_note 3, 1
	drum_note 9, 1
	drum_speed 1
	drum_note 5, 4
	drum_note 5, 3
	drum_speed 7
.loop5:
	drum_note 3, 1
	sound_loop 4, .loop5
.loop6:
	drum_note 1, 1
	drum_note 7, 1
	drum_note 9, 1
	drum_note 3, 1
	drum_note 7, 1
	drum_note 1, 1
	drum_note 9, 2
	drum_note 7, 1
	drum_note 1, 1
	drum_note 7, 2
	drum_note 3, 2
	drum_note 9, 2
	sound_loop 5, .loop6
	drum_note 1, 2
	drum_note 7, 1
	drum_note 3, 1
	drum_note 7, 1
	drum_note 1, 1
	drum_note 9, 2
	drum_note 7, 1
	drum_note 1, 1
	drum_note 9, 1
	drum_speed 1
	drum_note 5, 4
	drum_note 5, 3
	drum_speed 7
.loop7:
	drum_note 3, 1
	sound_loop 4, .loop7
.loop8:
	sound_call .sub1
	sound_loop 3, .loop8
	sound_call .sub3
.loop9:
	sound_call .sub1
	sound_loop 7, .loop9
	sound_call .sub2
.loop10:
	sound_call .sub1
	sound_loop 7, .loop10
	sound_call .sub3
.loop11:
	sound_call .sub1
	sound_loop 2, .loop11
	drum_note 1, 2
	drum_note 7, 1
	drum_note 9, 1
	drum_note 3, 2
	drum_note 9, 2
	drum_note 1, 1
	drum_note 7, 1
	drum_note 9, 2
	drum_note 3, 2
	drum_note 12, 14
	drum_note 3, 4
	sound_loop 0, .mainloop

.sub1:
	drum_note 1, 2
	drum_note 7, 1
	drum_note 9, 1
	drum_note 3, 2
	drum_note 9, 2
	drum_note 1, 1
	drum_note 7, 1
	drum_note 9, 2
	drum_note 3, 1
	drum_note 9, 1
	rest 1
	drum_note 7, 1
	sound_ret

.sub2:
	drum_note 1, 2
	drum_note 7, 1
	drum_note 9, 1
	drum_note 3, 2
	drum_note 9, 2
	drum_note 7, 1
	drum_note 3, 1
	drum_note 9, 1
	drum_speed 1
	drum_note 5, 4
	drum_note 5, 3
	drum_speed 7
	drum_note 3, 1
	drum_note 3, 1
	drum_note 3, 2
	sound_ret

.sub3:
	drum_note 1, 2
	drum_note 7, 1
	drum_note 9, 1
	drum_note 3, 2
	drum_note 9, 1
	drum_speed 1
	drum_note 5, 4
	drum_note 5, 3
	drum_speed 7
.loop12:
	drum_note 3, 1
	sound_loop 8, .loop12
	sound_ret
