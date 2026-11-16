Music_TcgClub2:
	channel_count 3
	channel 1, Music_TcgClub2_Ch1
	channel 2, Music_TcgClub2_Ch2
	channel 3, Music_TcgClub2_Ch3

Music_TcgClub2_Ch1:
	tempo 254
	volume 7, 7
	duty_cycle 2
	note_cutoff 8
	note_type 6, 0, 0
.mainloop:
	octave 4
.loop1:
	volume_envelope 7, 5
	note G_, 4
	note E_, 4
	note C_, 4
	volume_envelope 7, 7
	note F#, 4
	tie
	note F#, 16
	volume_envelope 7, 5
	note G_, 4
	note A_, 4
	note B_, 4
	volume_envelope 7, 7
	note F#, 4
	tie
	note F#, 16
	sound_loop 8, .loop1
	volume_envelope 7, 5
	note G_, 4
	note D_, 4
	octave 3
	note B_, 4
	octave 4
	volume_envelope 7, 7
	note B_, 4
	tie
	note B_, 16
	volume_envelope 7, 5
	note G_, 4
	note D_, 4
	note C_, 4
	volume_envelope 7, 7
	note B_, 4
	tie
	note B_, 16
	octave 3
	volume_envelope 7, 5
	note F#, 4
	octave 2
	note D_, 4
	note F#, 4
	note A_, 4
	octave 3
	note D_, 4
	note F#, 4
	note A_, 4
	octave 4
	note D_, 4
	octave 3
	note C_, 4
	octave 2
	note C_, 4
	note E_, 4
	note G_, 4
	octave 3
	note C_, 4
	note E_, 4
	note G_, 4
	octave 4
	note C_, 4
	octave 3
	note D_, 4
	octave 2
	note D_, 4
	note F#, 4
	note A_, 4
	octave 3
	note D_, 4
	note F#, 4
	note A_, 4
	note A_, 3
	tie
	note_type 1, 7, 5
	note A_, 3
	octave 4
	volume_envelope 7, 7
	rest 4
	note D_, 5
	tie
	note_type 6, 7, 7
	note D_, 15
	tie
	note D_, 16
	sound_loop 0, .mainloop

Music_TcgClub2_Ch2:
	duty_cycle 2
	note_cutoff 8
	note_type 6, 0, 0
.mainloop:
	octave 2
.loop1:
	volume_envelope 7, 5
	note C_, 4
	note G_, 4
	octave 3
	note G_, 4
	octave 4
	volume_envelope 7, 7
	note D_, 4
	tie
	note D_, 16
	octave 3
	octave 2
	volume_envelope 7, 5
	note C_, 4
	note G_, 4
	octave 3
	octave 4
	note C_, 4
	volume_envelope 7, 7
	note D_, 4
	tie
	note D_, 16
	octave 3
	octave 2
	sound_loop 8, .loop1
	octave 1
	volume_envelope 7, 5
	note B_, 4
	octave 2
	note G_, 4
	octave 3
	note G_, 4
	octave 4
	volume_envelope 7, 7
	note G_, 4
	tie
	note G_, 16
	octave 3
	octave 2
	octave 1
	volume_envelope 7, 5
	note A_, 4
	octave 2
	note A_, 4
	octave 3
	note A_, 4
	octave 4
	volume_envelope 7, 7
	note C_, 4
	tie
	note C_, 16
	octave 3
	octave 2
	volume_envelope 7, 5
	note D_, 4
	octave 2
	note F#, 4
	note A_, 4
	octave 3
	note D_, 4
	note F#, 4
	note A_, 4
	octave 4
	note D_, 4
	note F#, 4
	note G_, 4
	octave 3
	octave 2
	note E_, 4
	note G_, 4
	octave 3
	note C_, 4
	note E_, 4
	note G_, 4
	octave 4
	note C_, 4
	note E_, 4
	note F#, 4
	octave 3
	octave 2
	note F#, 4
	note A_, 4
	octave 3
	note D_, 4
	note F#, 4
	note A_, 4
	octave 4
	note D_, 4
	note E_, 3
	tie
	note_type 1, 7, 5
	note E_, 3
	octave 3
	volume_envelope 7, 4
	note A_, 8
	octave 4
	volume_envelope 7, 7
	note F#, 7
	tie
	note_type 6, 7, 7
	note F#, 14
	tie
	note F#, 16
	sound_loop 0, .mainloop

Music_TcgClub2_Ch3:
	note_cutoff 6
	release_envelope 2, 0
	vibrato_table 4, 35
	note_type 6, 1, 11
.mainloop:
	note_cutoff 8
	volume_envelope 3, 11
	rest 2
	octave 5
	note G_, 4
	note E_, 4
	note C_, 4
	note F#, 2
	rest 2
	rest 16
	note G_, 4
	note A_, 4
	note B_, 4
	note F#, 2
	rest 2
	rest 14
	release_envelope 3, 0
	volume_envelope 2, 11
	sound_call .sub1
	octave 5
	note_cutoff 8
	note G_, 8
	sound_call .sub1
	release_envelope 2, 0
	octave 4
	note_cutoff 8
	volume_envelope 1, 11
	note G_, 8
	sound_call .sub2
	octave 4
	note_cutoff 0
	note G_, 16
	note_cutoff 6
	tie
	note G_, 12
	rest 16
	rest 8
	note_cutoff 8
	note E_, 8
	sound_call .sub2
	octave 4
	note_cutoff 0
	note G_, 16
	note_cutoff 6
	tie
	note_cutoff 0
	note G_, 12
	note_cutoff 6
	tie
	note_cutoff 0
	note G_, 16
	note_cutoff 6
	tie
	note G_, 8
	rest 4
	note_cutoff 8
	note A_, 2
	note G_, 2
	note_cutoff 6
	note_cutoff 0
	note F#, 16
	note_cutoff 6
	tie
	note F#, 12
	rest 4
	note_cutoff 0
	note F#, 1
	note_cutoff 6
	tie
	note_cutoff 0
	note G_, 15
	note_cutoff 6
	tie
	note G_, 12
	rest 4
	note_cutoff 0
	note G#, 1
	note_cutoff 6
	tie
	note_cutoff 0
	note A_, 15
	note_cutoff 6
	tie
	note A_, 16
	rest 16
	rest 16
	release_envelope 3, 0
	sound_loop 0, .mainloop

.sub1:
	note_cutoff 6
	octave 6
	note_cutoff 0
	note C#, 1
	note_cutoff 6
	tie
	note_cutoff 0
	note D_, 15
	note_cutoff 6
	tie
	note D_, 12
	note_cutoff 8
	note C_, 2
	octave 5
	note B_, 2
	note_cutoff 6
	note_cutoff 0
	note G_, 16
	note_cutoff 6
	tie
	note G_, 8
	rest 4
	note_cutoff 8
	note E_, 4
	note B_, 4
	octave 6
	note C_, 4
	octave 5
	note B_, 4
	note_cutoff 6
	note_cutoff 0
	note A_, 16
	note_cutoff 6
	tie
	note_cutoff 0
	note A_, 8
	note_cutoff 6
	tie
	note A_, 16
	rest 4
	sound_ret

.sub2:
	octave 5
	note C#, 1
	tie
	note D_, 15
	tie
	note D_, 4
	note E_, 4
	octave 4
	note B_, 4
	octave 5
	note C_, 4
	note_cutoff 6
	note_cutoff 0
	note D_, 16
	note_cutoff 6
	tie
	note D_, 8
	rest 4
	note_cutoff 8
	note C_, 2
	octave 4
	note B_, 2
	octave 5
	note C_, 2
	octave 4
	note B_, 2
	note_cutoff 6
	sound_ret
