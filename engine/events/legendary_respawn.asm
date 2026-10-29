RespawnLegendariesScript::
; Run on every Elite Four win, before the Hall of Fame saves. A one-off Pokemon that was fought but
; not caught (knocked out, fled from, or blacked out to) comes back; a caught one never does.
; Story flags its first battle set stay set: only the battle comes back.

; The birds, Lugia and Ho-Oh: their callbacks show them again once the fought flag is clear.
	checkevent EVENT_CAUGHT_ZAPDOS
	iftrue .Articuno
	clearevent EVENT_FOUGHT_ZAPDOS
.Articuno:
	checkevent EVENT_CAUGHT_ARTICUNO
	iftrue .Moltres
	clearevent EVENT_FOUGHT_ARTICUNO
.Moltres:
	checkevent EVENT_CAUGHT_MOLTRES
	iftrue .Lugia
	clearevent EVENT_FOUGHT_MOLTRES
.Lugia:
	checkevent EVENT_CAUGHT_LUGIA
	iftrue .HoOh
	clearevent EVENT_FOUGHT_LUGIA
.HoOh:
	checkevent EVENT_CAUGHT_HO_OH
	iftrue .Mewtwo
	clearevent EVENT_FOUGHT_HO_OH ; Tin Tower 1F goes back to how it was before Ho-Oh
	setevent EVENT_TIN_TOWER_1F_EUSINE ; its callback shows him only while Ho-Oh is fought
.Mewtwo:
; Mewtwo has no callback, so its object flag is cleared too
	checkevent EVENT_CAUGHT_MEWTWO
	iftrue .Mew
	clearevent EVENT_FOUGHT_MEWTWO
	clearevent EVENT_CERULEAN_CAVE_B1F_MEWTWO
.Mew:
	checkevent EVENT_CAUGHT_MEW
	iftrue .Suicune
	clearevent EVENT_FOUGHT_MEW
.Suicune:
; It stands in Tin Tower 1F where the scene left it, for a rematch
	checkevent EVENT_CAUGHT_SUICUNE
	iftrue .Celebi
	checkevent EVENT_FOUGHT_SUICUNE
	iffalse .Celebi
	clearevent EVENT_TIN_TOWER_1F_SUICUNE
.Celebi:
; The Ilex shrine offers a rematch, without the GS Ball or the restless forest
	checkevent EVENT_CAUGHT_CELEBI
	iftrue .Sudowoodo
	checkevent EVENT_FOUGHT_CELEBI
	iffalse .Sudowoodo
	setevent EVENT_CELEBI_RETURNS
.Sudowoodo:
; A second Sudowoodo on Route 36: the first one's weird tree sprite is shared with Route 37's twins
	checkevent EVENT_CAUGHT_SUDOWOODO
	iftrue .VermilionSnorlax
	checkevent EVENT_FOUGHT_SUDOWOODO
	iffalse .VermilionSnorlax
	clearevent EVENT_ROUTE_36_SUDOWOODO_RESPAWN
.VermilionSnorlax:
; It comes back on Route 11, so Diglett's Cave stays open
	checkevent EVENT_CAUGHT_SNORLAX
	iftrue .ApricornSnorlax
	checkevent EVENT_FOUGHT_SNORLAX
	iffalse .ApricornSnorlax
	clearevent EVENT_VERMILION_SNORLAX_RESPAWN
.ApricornSnorlax:
	checkevent EVENT_CAUGHT_APRICORN_SNORLAX
	iftrue .RedGyarados
	clearevent EVENT_APRICORN_FOREST_CLEARING_SNORLAX
.RedGyarados:
	checkevent EVENT_CAUGHT_RED_GYARADOS
	iftrue .Electrodes
	clearevent EVENT_LAKE_OF_RAGE_RED_GYARADOS
.Electrodes:
; All three come back, with their look-alikes, until any one of them is caught. The generator
; puzzle stays solved.
	checkevent EVENT_CLEARED_ROCKET_HIDEOUT
	iffalse .Beasts
	checkevent EVENT_CAUGHT_ROCKET_ELECTRODE
	iftrue .Beasts
	clearevent EVENT_TEAM_ROCKET_BASE_B2F_ELECTRODE_1
	clearevent EVENT_TEAM_ROCKET_BASE_B2F_ELECTRODE_2
	clearevent EVENT_TEAM_ROCKET_BASE_B2F_ELECTRODE_3
.Beasts:
	callasm RespawnRoamingBeasts
	end

RespawnRoamingBeasts:
; A released beast that was knocked out, and not caught, roams again from its release route as a
; new beast: L50, a fresh shiny roll, and HP 0 so its first battle rolls new DVs and stats. One that
; was only fled from is still roaming, and is left as it is.
	ld de, EVENT_RELEASED_THE_BEASTS
	ld b, CHECK_FLAG
	call EventFlagAction
	ld a, c
	and a
	ret z

	ld de, EVENT_CAUGHT_RAIKOU
	ld hl, wRoamMon1Species
	call .IsGone
	jr nc, .Entei
	ld a, 50
	farcall InitRoamRaikou
	ld hl, wRoamMon1Form
	call .NewForm

.Entei:
	ld de, EVENT_CAUGHT_ENTEI
	ld hl, wRoamMon2Species
	call .IsGone
	ret nc
	ld a, 50
	farcall InitRoamEntei
	ld hl, wRoamMon2Form
.NewForm:
	ld [hl], PLAIN_FORM
	farjp RollLegendaryShiny

.IsGone:
; in: de = the beast's caught flag, hl = its species byte
; out: carry if it was knocked out: no species left, and not caught
	ld a, [hl]
	and a
	ret nz ; still roaming
	ld b, CHECK_FLAG
	call EventFlagAction
	ld a, c
	and a
	ret nz ; caught
	scf
	ret
