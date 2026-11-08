Music_TcgOverworld:
	channel_count 4
	channel 1, Music_TcgOverworld_Ch1
	channel 2, Music_TcgOverworld_Ch2
	channel 3, Music_TcgOverworld_Ch3
	channel 4, Music_TcgOverworld_Ch4

Music_TcgOverworld_Ch1:
	tempo 254
	volume 7, 7
	release_envelope 0, 0
	duty_cycle 0
	note_cutoff 7
	octave 3
	vibrato_table 9, 25
	note_type 7, 10, 2
	rest 3
	sound_call .sub1
	rest 3
.mainloop:
	sound_call .sub1
	duty_cycle 1
	note_cutoff 8
	octave 3
	volume_envelope 10, 0
	note A_, 5
	volume_envelope 3, 7
	note A_, 1
	octave 4
	volume_envelope 10, 0
	note C_, 5
	volume_envelope 3, 7
	note C_, 1
	volume_envelope 10, 0
	note F_, 3
	note_type 1, 10, 0
	note E_, 11
	volume_envelope 3, 7
	note E_, 10
	note_type 7, 10, 0
	note G_, 3
	note_type 1, 10, 0
	note F_, 11
	volume_envelope 3, 7
	note F_, 10
	note_type 7, 10, 0
	note C_, 12
	volume_envelope 3, 7
	note C_, 2
	duty_cycle 0
	note_cutoff 7
	octave 3
	volume_envelope 9, 2
	note E_, 4
	note E_, 3
	note E_, 3
	duty_cycle 1
	note_cutoff 8
	volume_envelope 10, 0
	sound_call .sub2
	note C_, 6
	volume_envelope 3, 7
	note C_, 6
	volume_envelope 10, 0
	note C_, 3
	note D_, 3
	note E_, 3
	note G_, 6
	volume_envelope 3, 7
	note G_, 3
	volume_envelope 10, 0
	note F_, 4
	volume_envelope 3, 7
	note F_, 2
	volume_envelope 10, 0
	note C_, 3
	octave 3
	note A_, 6
	note A#, 9
	volume_envelope 3, 7
	note A#, 6
	volume_envelope 10, 0
	note A#, 3
	octave 4
	note D_, 3
	note F_, 3
	note A_, 3
	volume_envelope 3, 7
	note A_, 6
	volume_envelope 10, 0
	note G_, 3
	volume_envelope 3, 7
	note G_, 3
	volume_envelope 10, 0
	note E_, 3
	note D_, 3
	volume_envelope 3, 7
	note D_, 3
	volume_envelope 10, 0
	note E_, 2
	volume_envelope 3, 7
	note E_, 1
	note_cutoff 8
	volume_envelope 10, 0
	note C_, 9
	volume_envelope 3, 7
	note C_, 3
	octave 3
	volume_envelope 10, 0
	note A_, 3
	octave 4
	note_type 1, 10, 0
	note C_, 11
	volume_envelope 4, 0
	note C_, 10
	note_type 7, 10, 0
	note G_, 3
	note_type 1, 10, 0
	note F_, 11
	volume_envelope 4, 0
	note F_, 10
	note_type 7, 10, 0
	note C_, 12
	volume_envelope 3, 7
	note C_, 6
	duty_cycle 2
	note_cutoff 8
	octave 4
	volume_envelope 5, -7
	note G_, 1
	tie
	note E_, 1
	tie
	note C_, 1
	tie
	octave 3
	note G_, 1
	tie
	note E_, 1
	tie
	note C_, 1
	duty_cycle 1
	note_cutoff 8
	volume_envelope 10, 0
	sound_call .sub2
	note C_, 6
	volume_envelope 3, 7
	note C_, 6
	volume_envelope 10, 0
	note C_, 3
	note D_, 3
	note E_, 3
	note F_, 9
	volume_envelope 3, 7
	note F_, 12
	volume_envelope 10, 0
	note F_, 2
	note G_, 1
	note A_, 1
	volume_envelope 3, 7
	note A_, 2
	volume_envelope 10, 0
	note A_, 12
	volume_envelope 3, 7
	note A_, 3
	volume_envelope 10, 0
	note D_, 3
	note A_, 3
	note A#, 9
	volume_envelope 3, 7
	note A#, 6
	volume_envelope 10, 0
	note A_, 5
	volume_envelope 3, 7
	note A_, 1
	volume_envelope 10, 0
	note G_, 5
	volume_envelope 3, 7
	note G_, 1
	volume_envelope 9, 0
	note F_, 8
	tie
	note F_, 8
	tie
	note F_, 8
	tie
	note F_, 8
	tie
	note F_, 8
	tie
	note F_, 8
	volume_envelope 3, 7
	note F_, 3
	duty_cycle 0
	note_cutoff 7
	volume_envelope 10, 2
	sound_loop 0, .mainloop

.sub1:
	octave 3
	note F_, 3
	note F_, 2
	note A_, 1
	octave 4
	note_cutoff 4
	volume_envelope 10, 0
	note C_, 1
	rest 1
	octave 3
	note_cutoff 7
	volume_envelope 9, 2
	note A#, 3
	note A#, 1
	octave 4
	note_cutoff 4
	volume_envelope 10, 0
	note D_, 1
	rest 2
	octave 3
	note_cutoff 7
	volume_envelope 9, 2
	note G_, 3
	note A#, 3
	rest 3
	note A_, 3
	note A_, 2
	octave 4
	note C_, 1
	note_cutoff 4
	volume_envelope 10, 0
	note C_, 1
	rest 1
	octave 3
	note_cutoff 7
	volume_envelope 9, 2
	note A#, 3
	note A#, 1
	octave 4
	note_cutoff 4
	volume_envelope 10, 0
	note D_, 1
	rest 2
	note_cutoff 7
	volume_envelope 9, 2
	note C_, 3
	octave 3
	note A#, 3
	sound_ret

.sub2:
	octave 4
	volume_envelope 10, 0
	note D_, 5
	volume_envelope 3, 7
	note D_, 1
	volume_envelope 10, 0
	note F_, 5
	volume_envelope 3, 7
	note F_, 1
	volume_envelope 10, 0
	note A_, 3
	note_type 1, 10, 0
	note G_, 11
	volume_envelope 3, 7
	note G_, 10
	octave 5
	note_type 7, 10, 0
	note C_, 3
	octave 4
	note_type 1, 10, 0
	note A#, 11
	volume_envelope 3, 7
	note A#, 10
	note_type 7, 10, 0
	note C#, 12
	volume_envelope 3, 7
	note C#, 6
	volume_envelope 10, 0
	note D#, 3
	note_type 1, 10, 0
	note C#, 11
	volume_envelope 3, 7
	note C#, 10
	note_type 7, 10, 0
	sound_ret

Music_TcgOverworld_Ch2:
	release_envelope 0, 0
	duty_cycle 0
	note_cutoff 7
	octave 3
	vibrato_table 9, 30
	note_type 7, 0, 0
	sound_call .sub1
.mainloop:
	sound_call .sub1
	note_cutoff 7
	volume_envelope 9, 2
	rest 3
	note C_, 5
	note C_, 3
	note_cutoff 4
	octave 4
	volume_envelope 9, 0
	note F_, 1
	rest 2
	octave 3
	note_cutoff 7
	volume_envelope 9, 2
	note C_, 4
	note C_, 3
	note C_, 3
	rest 3
	note C_, 5
	note C_, 3
	note_cutoff 4
	octave 4
	volume_envelope 9, 0
	note G_, 1
	rest 2
	octave 3
	note_cutoff 7
	volume_envelope 9, 2
	note D_, 4
	note D_, 3
	note C_, 3
	rest 3
	octave 2
	note A#, 5
	octave 3
	note D_, 3
	note_cutoff 4
	octave 4
	volume_envelope 9, 0
	note F_, 1
	rest 2
	octave 3
	note_cutoff 7
	volume_envelope 9, 2
	note C_, 4
	note C_, 3
	octave 2
	note A#, 3
	rest 3
	note A#, 5
	octave 3
	note C#, 3
	note_cutoff 4
	octave 4
	volume_envelope 9, 0
	note F_, 1
	rest 2
	octave 3
	note_cutoff 7
	volume_envelope 9, 2
	note C#, 4
	octave 2
	note F_, 3
	note A#, 3
	rest 3
	octave 3
	note C_, 3
	note E_, 2
	note C_, 3
	note_cutoff 4
	octave 4
	volume_envelope 9, 0
	note G_, 1
	note_cutoff 7
	note_cutoff 8
	octave 3
	volume_envelope 6, 0
	note E_, 3
	note F_, 3
	note G_, 3
	note_cutoff 7
	note A#, 6
	note_cutoff 7
	octave 3
	volume_envelope 9, 2
	note D_, 3
	note_cutoff 8
	octave 3
	volume_envelope 6, 0
	note A_, 3
	note_cutoff 7
	octave 2
	volume_envelope 9, 2
	note A_, 2
	octave 3
	octave 4
	note_cutoff 4
	volume_envelope 9, 0
	note F_, 1
	octave 3
	rest 2
	note_cutoff 7
	volume_envelope 9, 2
	note D_, 4
	note D_, 3
	octave 2
	note A_, 3
	rest 3
	note A#, 3
	octave 3
	note D_, 2
	octave 2
	note A#, 3
	note_cutoff 4
	octave 3
	octave 4
	volume_envelope 9, 0
	note F_, 1
	rest 2
	octave 3
	octave 2
	note_cutoff 7
	volume_envelope 9, 2
	note A#, 4
	note A#, 3
	note A#, 3
	rest 3
	note A#, 3
	octave 3
	note D_, 2
	octave 2
	note A#, 3
	note_cutoff 4
	octave 3
	volume_envelope 9, 0
	note A_, 1
	rest 2
	octave 2
	note_cutoff 7
	volume_envelope 9, 2
	note A#, 6
	octave 3
	note D_, 1
	octave 2
	note A#, 3
	rest 3
	octave 3
	note C_, 5
	note C_, 3
	note_cutoff 4
	octave 4
	volume_envelope 9, 0
	note F_, 1
	rest 2
	note_cutoff 7
	octave 3
	volume_envelope 9, 2
	note C_, 4
	note C_, 3
	note C_, 3
	rest 3
	note C_, 5
	note C_, 3
	note_cutoff 4
	octave 4
	volume_envelope 9, 0
	note G_, 1
	rest 2
	octave 3
	note_cutoff 7
	volume_envelope 9, 2
	note D_, 4
	duty_cycle 2
	note_cutoff 8
	octave 4
	volume_envelope 5, -7
	note C_, 1
	tie
	octave 3
	note G_, 1
	tie
	note E_, 1
	tie
	note C_, 1
	tie
	octave 2
	note G_, 1
	tie
	note E_, 1
	duty_cycle 0
	note_cutoff 7
	octave 2
	volume_envelope 9, 2
	rest 3
	note A#, 5
	octave 3
	note D_, 3
	note_cutoff 4
	octave 4
	volume_envelope 9, 0
	note F_, 1
	rest 2
	octave 3
	note_cutoff 7
	volume_envelope 9, 2
	note C_, 4
	note C_, 3
	octave 2
	note A#, 3
	rest 3
	note A#, 5
	octave 3
	note C#, 3
	note_cutoff 4
	octave 4
	volume_envelope 9, 0
	note F_, 1
	rest 2
	octave 3
	note_cutoff 7
	volume_envelope 9, 2
	note C#, 4
	note C#, 3
	note C#, 3
	rest 3
	note C_, 3
	octave 2
	note A_, 2
	octave 3
	note C_, 3
	note_cutoff 4
	octave 4
	volume_envelope 9, 0
	note G_, 1
	rest 2
	octave 3
	note_cutoff 7
	volume_envelope 9, 2
	note C_, 4
	note E_, 3
	note C_, 3
	rest 3
	note D_, 6
	octave 2
	note B_, 2
	octave 3
	octave 4
	note_cutoff 4
	volume_envelope 9, 0
	note F_, 1
	rest 2
	octave 3
	note_cutoff 7
	volume_envelope 9, 2
	note D_, 4
	note_cutoff 8
	octave 4
	volume_envelope 6, 0
	note D_, 2
	note E_, 1
	note F_, 1
	volume_envelope 2, 7
	note F_, 2
	volume_envelope 6, 0
	note F_, 11
	note_cutoff 7
	octave 4
	note_cutoff 4
	volume_envelope 9, 0
	note F_, 1
	rest 2
	octave 3
	octave 2
	note_cutoff 7
	volume_envelope 9, 2
	note A#, 1
	note_cutoff 8
	octave 3
	volume_envelope 6, 0
	note A#, 3
	octave 4
	note F_, 3
	note G_, 9
	note_cutoff 7
	octave 3
	volume_envelope 9, 2
	note D_, 2
	octave 2
	note A#, 3
	octave 3
	octave 4
	note_cutoff 4
	volume_envelope 9, 0
	note F_, 1
	note_cutoff 8
	octave 4
	volume_envelope 6, 0
	note C_, 5
	volume_envelope 2, 7
	note C_, 1
	octave 3
	volume_envelope 9, 0
	note A#, 5
	volume_envelope 2, 7
	note A#, 1
	note_cutoff 7
	octave 3
	volume_envelope 9, 2
	rest 3
	note F_, 3
	note C_, 2
	note F_, 1
	note_cutoff 4
	octave 4
	volume_envelope 9, 0
	note F_, 1
	rest 1
	octave 3
	note_cutoff 7
	volume_envelope 9, 2
	note G_, 3
	note G_, 3
	note_cutoff 8
	octave 4
	note_type 1, 9, 0
	note F_, 4
	note C_, 3
	octave 3
	note_cutoff 7
	note_type 7, 9, 2
	note E_, 3
	note G_, 2
	octave 4
	note_cutoff 4
	volume_envelope 9, 0
	note F_, 1
	note_cutoff 7
	octave 3
	volume_envelope 9, 2
	rest 3
	note A_, 3
	note F_, 2
	note A_, 1
	octave 4
	note_cutoff 4
	volume_envelope 9, 0
	note F_, 1
	rest 1
	octave 3
	note_cutoff 7
	volume_envelope 9, 2
	note G_, 3
	note G_, 3
	note_cutoff 8
	octave 4
	note_type 1, 9, 0
	note F_, 4
	note C_, 3
	octave 3
	note_cutoff 7
	note_type 7, 9, 2
	note A_, 3
	note G_, 2
	octave 4
	note_cutoff 4
	volume_envelope 9, 0
	note F_, 1
	sound_loop 0, .mainloop

.sub1:
	octave 3
	note_cutoff 7
	volume_envelope 9, 2
	rest 3
	note C_, 3
	note C_, 2
	note F_, 1
	note_cutoff 4
	octave 4
	volume_envelope 9, 0
	note F_, 1
	rest 1
	octave 3
	note_cutoff 7
	volume_envelope 9, 2
	note G_, 3
	note G_, 1
	note_cutoff 4
	octave 4
	volume_envelope 9, 0
	note F_, 1
	rest 1
	octave 3
	note_cutoff 8
	octave 4
	note_type 1, 9, 0
	note F_, 4
	note C_, 3
	note_cutoff 7
	octave 3
	note_type 7, 9, 2
	note E_, 3
	note G_, 2
	note_cutoff 4
	octave 4
	volume_envelope 9, 0
	note F_, 1
	octave 3
	rest 3
	note_cutoff 8
	volume_envelope 9, 2
	note F_, 3
	note F_, 2
	note A_, 1
	note_cutoff 4
	octave 4
	volume_envelope 9, 0
	note F_, 1
	rest 1
	octave 3
	note_cutoff 7
	volume_envelope 9, 2
	note G_, 3
	note G_, 1
	note_cutoff 4
	octave 4
	volume_envelope 9, 0
	note F_, 1
	rest 1
	octave 3
	note_cutoff 8
	octave 4
	note_type 1, 9, 0
	note F_, 4
	note C_, 3
	note_cutoff 7
	octave 3
	note_type 7, 9, 2
	note A_, 3
	note G_, 2
	note_cutoff 4
	octave 4
	volume_envelope 9, 0
	note F_, 1
	octave 3
	sound_ret

Music_TcgOverworld_Ch3:
	release_envelope 2, 0
	note_cutoff 7
	octave 2
	note_type 7, 1, 10
	sound_call .sub1
	note F_, 2
	octave 3
	note C_, 1
.mainloop:
	sound_call .sub1
	note F_, 3
	sound_call .sub2
	octave 2
	note_cutoff 8
	note F_, 1
	note A#, 2
	rest 1
	octave 4
	note_cutoff 3
	note C#, 2
	octave 3
	note_cutoff 8
	note F_, 1
	note A#, 1
	rest 1
	octave 4
	note_cutoff 3
	note F_, 2
	rest 1
	octave 5
	note C#, 1
	octave 2
	note_cutoff 8
	note A#, 1
	rest 1
	octave 4
	note_cutoff 7
	note G_, 1
	octave 2
	note_cutoff 8
	note A#, 1
	rest 1
	note F_, 1
	octave 3
	note_cutoff 3
	note A#, 2
	octave 2
	note_cutoff 8
	note A#, 1
	octave 4
	note_cutoff 3
	note C#, 2
	octave 2
	note_cutoff 8
	note F_, 1
	note A_, 2
	rest 1
	octave 4
	note_cutoff 3
	note E_, 2
	octave 2
	note_cutoff 8
	note A_, 1
	octave 4
	note_cutoff 3
	note G_, 2
	note_cutoff 7
	note E_, 1
	note_cutoff 8
	octave 3
	note E_, 1
	rest 1
	octave 4
	octave 5
	note_cutoff 3
	note E_, 1
	octave 2
	note_cutoff 8
	note A_, 1
	rest 1
	octave 3
	note A_, 1
	rest 2
	octave 2
	note A_, 1
	octave 3
	note A_, 1
	note E_, 1
	note C_, 1
	octave 2
	note A_, 1
	rest 1
	octave 3
	note A_, 1
	octave 2
	note D_, 2
	rest 1
	octave 4
	note_cutoff 3
	note F_, 2
	octave 2
	note_cutoff 8
	note A_, 1
	octave 3
	note D_, 2
	octave 2
	note A_, 1
	octave 4
	note_cutoff 3
	note D_, 2
	octave 5
	note C_, 1
	octave 2
	note_cutoff 8
	note D_, 2
	octave 4
	note_cutoff 3
	note F_, 2
	rest 1
	octave 2
	note_cutoff 8
	note A_, 1
	octave 4
	note_cutoff 3
	note F_, 2
	octave 2
	note_cutoff 8
	note D_, 1
	octave 4
	note_cutoff 3
	note D_, 2
	note_cutoff 8
	octave 2
	note A_, 1
	note G_, 2
	rest 1
	octave 4
	note_cutoff 3
	note D_, 2
	octave 2
	note_cutoff 8
	note G_, 1
	octave 4
	note_cutoff 3
	note F_, 2
	note_cutoff 7
	note D_, 1
	octave 3
	note_cutoff 8
	note D_, 1
	rest 1
	note_cutoff 3
	octave 4
	note A#, 1
	octave 2
	note_cutoff 8
	note G_, 1
	rest 1
	octave 4
	note_cutoff 3
	note D_, 2
	rest 1
	octave 3
	note_cutoff 8
	note D_, 1
	octave 4
	note_cutoff 3
	note F_, 2
	octave 2
	note_cutoff 8
	note G_, 1
	octave 4
	note_cutoff 3
	note D_, 2
	note_cutoff 8
	octave 3
	note D_, 1
	note C_, 2
	rest 1
	octave 4
	note_cutoff 3
	note D_, 2
	octave 2
	note_cutoff 8
	note G_, 1
	octave 4
	note_cutoff 3
	note F_, 2
	note_cutoff 7
	note D_, 1
	octave 2
	note_cutoff 8
	note C_, 1
	rest 1
	octave 4
	note_cutoff 3
	note F_, 1
	octave 3
	note_cutoff 8
	note C_, 1
	rest 1
	octave 4
	note_cutoff 3
	note D_, 2
	rest 1
	octave 2
	note_cutoff 8
	note E_, 1
	octave 3
	note C_, 1
	rest 1
	octave 4
	note_cutoff 7
	note F_, 1
	note_cutoff 3
	note E_, 2
	note_cutoff 8
	octave 2
	note E_, 1
	sound_call .sub2
	note_cutoff 8
	octave 3
	note C_, 1
	note C#, 2
	rest 1
	octave 4
	note_cutoff 3
	note C#, 2
	octave 2
	note_cutoff 8
	note G#, 1
	octave 3
	note C#, 1
	rest 1
	octave 4
	note_cutoff 3
	note F_, 2
	rest 1
	octave 5
	note C#, 1
	octave 3
	note_cutoff 8
	note C#, 1
	rest 1
	octave 4
	note G_, 1
	octave 3
	note_cutoff 8
	note C#, 1
	rest 1
	octave 2
	note G#, 1
	octave 4
	note_cutoff 3
	note G_, 2
	octave 3
	note_cutoff 8
	note C#, 1
	octave 4
	note_cutoff 3
	note F_, 2
	octave 2
	note_cutoff 8
	note G#, 1
	octave 3
	note C_, 2
	rest 1
	octave 4
	note_cutoff 3
	note E_, 2
	octave 3
	note_cutoff 8
	note G_, 1
	octave 4
	note_cutoff 3
	note C_, 2
	note_cutoff 7
	note E_, 1
	octave 3
	note_cutoff 8
	note E_, 1
	rest 1
	octave 5
	note_cutoff 3
	note E_, 1
	octave 3
	note_cutoff 8
	note C_, 1
	rest 1
	octave 4
	note_cutoff 3
	note E_, 2
	rest 1
	octave 2
	note_cutoff 8
	note G_, 1
	octave 4
	note_cutoff 3
	note G_, 2
	octave 3
	note_cutoff 8
	note C_, 1
	octave 4
	note_cutoff 3
	note E_, 2
	octave 2
	note_cutoff 8
	note G_, 1
	note B_, 2
	rest 1
	octave 4
	note_cutoff 3
	note F_, 2
	octave 3
	note_cutoff 8
	note F_, 1
	note B_, 2
	note F_, 1
	octave 4
	note_cutoff 3
	note D_, 2
	octave 5
	note D_, 1
	octave 2
	note_cutoff 8
	note B_, 2
	octave 4
	note_cutoff 3
	note F_, 2
	rest 1
	octave 3
	note_cutoff 8
	note F_, 1
	note B_, 2
	note F_, 1
	octave 2
	note B_, 2
	rest 1
	note A#, 2
	rest 1
	octave 4
	note_cutoff 3
	note D_, 2
	octave 3
	note_cutoff 8
	note F_, 1
	note A#, 2
	note F_, 1
	octave 4
	note_cutoff 3
	note F_, 2
	octave 5
	note D_, 1
	octave 2
	note_cutoff 8
	note A#, 1
	rest 1
	octave 4
	note_cutoff 7
	note D_, 1
	octave 2
	note_cutoff 8
	note A#, 1
	rest 2
	note A#, 2
	octave 3
	note F_, 1
	note A#, 1
	rest 2
	note C_, 2
	rest 1
	octave 4
	note_cutoff 3
	note D_, 2
	octave 2
	note_cutoff 8
	note G_, 1
	octave 4
	note_cutoff 3
	note F_, 2
	note_cutoff 7
	note D_, 1
	octave 2
	note_cutoff 8
	note C_, 1
	rest 1
	octave 5
	note_cutoff 3
	note D_, 1
	octave 3
	note_cutoff 8
	note C_, 1
	rest 1
	octave 4
	note_cutoff 3
	note D_, 2
	rest 1
	octave 2
	note_cutoff 8
	note E_, 1
	octave 3
	note C_, 1
	octave 2
	note G_, 1
	note E_, 1
	note C_, 1
	rest 1
	note E_, 1
	note F_, 3
	octave 4
	note_cutoff 3
	note A_, 2
	octave 3
	note_cutoff 8
	note C_, 1
	octave 4
	note_cutoff 5
	note F_, 2
	note A_, 1
	octave 5
	note C_, 1
	octave 4
	rest 1
	note A#, 2
	rest 1
	note A#, 1
	octave 5
	note D_, 1
	octave 4
	rest 2
	note G_, 2
	octave 3
	note_cutoff 8
	note C_, 1
	octave 4
	note_cutoff 5
	note A#, 2
	octave 5
	note C_, 1
	octave 2
	note_cutoff 8
	note F_, 3
	octave 5
	note_cutoff 3
	note C_, 2
	octave 3
	note_cutoff 8
	note C_, 1
	octave 4
	note_cutoff 5
	note A_, 2
	octave 5
	note C_, 1
	note C_, 1
	rest 1
	octave 4
	note A#, 2
	rest 1
	note A#, 1
	octave 5
	note D_, 1
	rest 2
	note C_, 2
	octave 3
	note_cutoff 8
	note C_, 1
	octave 4
	note_cutoff 5
	note A#, 2
	octave 3
	note_cutoff 8
	note C_, 1
	sound_loop 0, .mainloop

.sub1:
	octave 2
	note F_, 3
	octave 4
	note_cutoff 3
	note A_, 2
	octave 3
	note_cutoff 8
	note C_, 1
	note F_, 2
	note C_, 1
	rest 2
	note F_, 1
	rest 2
	note F_, 1
	rest 2
	note C_, 1
	note F_, 2
	note C_, 1
	octave 2
	note F_, 2
	octave 3
	note C_, 1
	octave 2
	note F_, 3
	octave 5
	note_cutoff 3
	note C_, 2
	octave 3
	note_cutoff 8
	note C_, 1
	note F_, 2
	note C_, 1
	rest 2
	note F_, 1
	rest 2
	note F_, 1
	rest 2
	note C_, 1
	note F_, 2
	note C_, 1
	octave 2
	sound_ret

.sub2:
	octave 2
	note F_, 2
	rest 1
	octave 4
	note_cutoff 3
	note F_, 2
	octave 3
	note_cutoff 8
	note C_, 1
	note F_, 1
	rest 1
	octave 4
	note_cutoff 3
	note F_, 2
	rest 1
	octave 5
	note C_, 1
	octave 2
	note_cutoff 8
	note F_, 1
	rest 1
	octave 4
	note_cutoff 7
	note G_, 1
	octave 2
	note_cutoff 8
	note F_, 1
	rest 1
	note C_, 1
	octave 4
	note_cutoff 3
	note G_, 2
	octave 2
	note_cutoff 8
	note F_, 1
	octave 4
	note_cutoff 7
	note F_, 2
	octave 2
	note_cutoff 8
	note G_, 1
	note A_, 2
	rest 1
	octave 4
	note_cutoff 3
	note E_, 2
	octave 3
	note_cutoff 8
	note E_, 1
	note A_, 1
	rest 1
	octave 4
	note_cutoff 3
	note E_, 2
	rest 1
	octave 5
	note C_, 1
	octave 2
	note_cutoff 8
	note A_, 1
	rest 1
	octave 4
	note_cutoff 7
	note E_, 1
	octave 2
	note_cutoff 8
.loop1:
	note A_, 1
	rest 1
	note E_, 1
	sound_loop 2, .loop1
	note A_, 2
	rest 1
	note A#, 2
	rest 1
	octave 4
	note_cutoff 3
	note D_, 2
	octave 3
	note_cutoff 8
	note F_, 1
	note A#, 1
	rest 1
	octave 4
	note_cutoff 3
	note F_, 2
	rest 1
	octave 5
	note D_, 1
	octave 2
	note_cutoff 8
	note A#, 1
	rest 1
	octave 4
	note_cutoff 7
	note D_, 1
	octave 2
	note_cutoff 8
	note A#, 1
	rest 1
	note F_, 1
	octave 4
	note_cutoff 3
	note D_, 2
	octave 2
	note_cutoff 8
	note A#, 1
	octave 4
	note_cutoff 3
	note D_, 2
	sound_ret

Music_TcgOverworld_Ch4:
	toggle_noise 6
	drum_speed 7
	sound_call .sub1
	sound_call .sub2
.mainloop:
	sound_call .sub1
	drum_note 1, 3
	drum_note 7, 2
	drum_note 1, 1
	drum_note 3, 3
	drum_note 7, 2
	drum_note 9, 1
	drum_note 1, 2
	drum_note 7, 1
	drum_note 7, 3
	drum_note 3, 1
	drum_note 7, 1
	drum_note 7, 1
	drum_note 3, 3
.loop1:
	sound_call .sub1
	sound_call .sub2
	sound_loop 3, .loop1
	sound_call .sub1
	sound_call .sub3
.loop2:
	sound_call .sub1
	sound_call .sub2
	sound_loop 3, .loop2
	sound_call .sub1
	sound_call .sub3
	sound_call .sub1
	sound_call .sub2
	sound_loop 0, .mainloop

.sub1:
	drum_note 1, 3
	drum_note 7, 2
	drum_note 1, 1
	drum_note 3, 3
	drum_note 7, 2
	drum_note 9, 1
	drum_note 1, 2
	drum_note 7, 1
	drum_note 7, 3
	drum_note 3, 3
	drum_note 7, 2
	drum_note 9, 1
	sound_ret

.sub2:
	drum_note 1, 3
	drum_note 7, 2
	drum_note 1, 1
	drum_note 3, 3
	drum_note 7, 2
	drum_note 9, 1
	drum_note 1, 2
	drum_note 7, 1
	drum_note 7, 3
	drum_note 3, 1
	drum_note 7, 1
	drum_note 7, 1
	drum_note 7, 2
	drum_note 9, 1
	sound_ret

.sub3:
	drum_note 1, 3
	drum_note 7, 2
	drum_note 1, 1
	drum_note 3, 3
	drum_note 7, 2
	drum_note 9, 1
	drum_note 1, 2
	drum_note 7, 1
	drum_note 7, 3
	drum_note 3, 1
	drum_note 7, 1
	drum_note 7, 1
	drum_note 3, 2
	drum_note 3, 1
	sound_ret
