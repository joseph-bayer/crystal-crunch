"""Kanto's trainers use Red/Blue forms.

Every trainer fought in Kanto proper (not the Indigo Plateau, Routes 26 and 27, Tohjo Falls or
Victory Road) whose party holds a species with a Red/Blue or beta form uses that form for it; the
rest of the party stays plain. The Route 24 Rocket Grunt keeps his Rocket forms.

So do the Open League's Kanto and Gen 1 seats, and their room partners take the form too. The
Johto leaders' Open League parties stay plain, and so does the first-round Elite Four, whose
parties the Open League reuses, but for Lance: a surprise, his Gyarados and first Dragonite are
alternate shinies, and his Aerodactyl and his ace Dragonite are Red/Blue.

A badge-scaled party names one species and grows or shrinks it to the stage its level reaches. Each
Red/Blue line numbers its forms the same at every stage, so the form byte still fits the stage the
battle sends out."""

import pytest

from harness import constants, data
from harness.alt_shiny import call
from harness.followers import index_of_id
from harness.forms import form_constant, ot_party_field
from test_level_scaling import evolutions, expected_stage, first_stages, go_to_map, set_badges, species_index, \
	trainer_map
from test_rb_forms import ot_party_stat

FORM_MASK = 0x1f

# The parties with a Red/Blue-capable species, by the map that fights them
KANTO_RB_TRAINERS = {
	"PewterGym": [("BROCK", "BROCK1")],
	"CeruleanGym": [("MISTY", "MISTY1"), ("SWIMMERF", "DIANA"), ("SWIMMERM", "PARKER")],
	"VermilionGym": [("GENTLEMAN", "GREGORY"), ("LT_SURGE", "LT_SURGE1")],
	"CeladonGym": [("BEAUTY", "JULIA"), ("ERIKA", "ERIKA1"), ("PICNICKER", "TANYA")],
	"FuchsiaGym": [("CAMPER", "BARRY"), ("JANINE", "JANINE1"), ("PICNICKER", "CINDY")],
	"SaffronGym": [("PSYCHIC_T", "JARED")],
	"ViridianGym": [("BLUE", "BLUE1")],
	"MountMoon": [("RIVAL2", "RIVAL2_1_CHIKORITA"), ("RIVAL2", "RIVAL2_1_CYNDAQUIL"),
		("RIVAL2", "RIVAL2_1_TOTODILE")],
	"ViridianForest": [("BUG_CATCHER", "ABNER")],
	"Route1": [("COOLTRAINERF", "QUINN")],
	"Route3": [("BLACKBELT_T", "ANDER"), ("FIREBREATHER", "BURT"), ("FIREBREATHER", "OTIS"),
		("HIKER", "BRUCE"), ("YOUNGSTER", "REGIS")],
	"Route8": [("BIKER", "DWAYNE"), ("BIKER", "ZEKE")],
	"Route9": [("CAMPER", "DEAN"), ("HIKER", "TIM"), ("PICNICKER", "EDNA"), ("PICNICKER", "HEIDI")],
	"Route10South": [("HIKER", "JIM"), ("POKEFANM", "ROBERT")],
	"Route11": [("PSYCHIC_T", "HERMAN"), ("YOUNGSTER", "JASON")],
	"Route12": [("FISHER", "BARNEY"), ("FISHER", "KYLER"), ("FISHER", "STEPHEN")],
	"Route13": [("BIRD_KEEPER", "PERRY"), ("HIKER", "KENNY"), ("POKEFANM", "ALEX"), ("POKEFANM", "JOSHUA")],
	"Route14": [("SCHOOLBOY", "TORIN")],
	"Route15": [("TEACHER", "HILLARY")],
	"Route17": [("BIKER", "CHARLES"), ("BIKER", "GLENN"), ("BIKER", "RILEY")],
	"Route19": [("SWIMMERM", "HAROLD"), ("SWIMMERM", "JEROME"), ("SWIMMERM", "TUCKER")],
	"Route20": [("SWIMMERF", "LORI"), ("SWIMMERF", "NICOLE")],
	"Route21": [("BIRD_KEEPER", "KINSLEY"), ("SWIMMERF", "NIKKI"), ("SWIMMERM", "SETH")],
	"Route25": [("CAMPER", "LLOYD"), ("COOLTRAINERM", "KEVIN"), ("LASS", "ELLEN")],
}
KANTO_RB_PARTIES = [trainer for trainers in KANTO_RB_TRAINERS.values() for trainer in trainers]

# The Open League seats with a Red/Blue-capable species: (class, party, E4_ROSTER_*, the room
# partner's form or None when the partner has no Red/Blue form)
OPEN_LEAGUE_RB_SEATS = [
	("BROCK", "BROCK_ELITE_FOUR", "E4_ROSTER_BROCK", None),
	("MISTY", "MISTY_ELITE_FOUR", "E4_ROSTER_MISTY", "STARMIE_RB_FORM"),
	("LT_SURGE", "LT_SURGE_ELITE_FOUR", "E4_ROSTER_LT_SURGE", "RAICHU_RB_FORM"),
	("ERIKA", "ERIKA_ELITE_FOUR", "E4_ROSTER_ERIKA", None),
	("JANINE", "JANINE_ELITE_FOUR", "E4_ROSTER_JANINE", "VENOMOTH_RB_FORM"),
	("BLUE", "BLUE_ELITE_FOUR", "E4_ROSTER_BLUE", None),
	("LORELEI", "LORELEI_ELITE_FOUR", "E4_ROSTER_LORELEI", "LAPRAS_RB_FORM"),
	("AGATHA", "AGATHA_ELITE_FOUR", "E4_ROSTER_AGATHA", "GENGAR_RB_FORM"),
	("GIOVANNI", "GIOVANNI_ELITE_FOUR", "E4_ROSTER_GIOVANNI", None),
	("TORU", "TORU_ELITE_FOUR", "E4_ROSTER_TORU", "KANGASKHAN_RB_FORM"),
]
OPEN_LEAGUE_RB_PARTIES = [(trainer_class, trainer) for trainer_class, trainer, _, _ in OPEN_LEAGUE_RB_SEATS]
# Partners with a Red/Blue form whose seat stays plain
PLAIN_PARTNERS = ["E4_ROSTER_KOGA", "E4_ROSTER_MORTY", "E4_ROSTER_CLAIR"]


def rb_forms():
	"""{species: its Red/Blue or beta form constant}, from RBFormTable."""
	import re
	text = data.read("data/pokemon/rb_forms.asm")
	return dict(re.findall(r"^\trb_form (\w+),\s*(\w+),", text, re.M))


def all_parties():
	"""[(class, trainer constant or party number, party)] for every trainer party."""
	groups = data.parties()
	labels = data.trainer_group_labels()
	found = []
	for trainer_class, members in data.trainer_classes():
		if trainer_class not in labels:
			continue
		names = {number: trainer for trainer, number in members.items()}
		for number, party in enumerate(groups[labels[trainer_class]], 1):
			found.append((trainer_class, names.get(number, number), party))
	return found


def test_the_lists_are_57_and_10_parties():
	assert len(KANTO_RB_PARTIES) == len(set(KANTO_RB_PARTIES)) == 57
	assert len(OPEN_LEAGUE_RB_PARTIES) == len(set(OPEN_LEAGUE_RB_PARTIES)) == 10


@pytest.mark.parametrize("trainer_class, trainer", KANTO_RB_PARTIES + OPEN_LEAGUE_RB_PARTIES)
def test_listed_parties_use_rb_forms(trainer_class, trainer):
	"""Each Red/Blue-capable species has its form; everything else in the party is plain."""
	forms = rb_forms()
	party = data.party(data.parties(), trainer_class, trainer)
	assert "TRAINERTYPE_FORM" in party["type"]
	got = [(mon["species"], mon["form"]) for mon in party["mons"]]
	want = [(mon["species"], forms.get(mon["species"], "PLAIN_FORM")) for mon in party["mons"]]
	assert got == want
	assert any(form != "PLAIN_FORM" for _, form in got)


def test_no_other_party_uses_rb_forms():
	"""Johto, the Indigo Plateau, the Open League's Johto leaders and the league path keep their plain
	Pokémon."""
	forms = set(rb_forms().values())
	listed = set(KANTO_RB_PARTIES + OPEN_LEAGUE_RB_PARTIES + [("CHAMPION", "LANCE")])
	stray = [(trainer_class, trainer, mon["species"], mon["form"])
		for trainer_class, trainer, party in all_parties() if (trainer_class, trainer) not in listed
		for mon in party["mons"] if mon["form"] in forms]
	assert not stray


def test_the_route_24_grunt_keeps_his_rocket_forms():
	party = data.party(data.parties(), "GRUNTM", "GRUNTM_31")
	assert [mon["form"] for mon in party["mons"] if mon["form"] != "PLAIN_FORM"] == \
		["CROBAT_ROCKET_FORM", "WEEZING_ROCKET_FORM"]


def test_each_listed_party_is_fought_on_its_map():
	for map_name, trainers in KANTO_RB_TRAINERS.items():
		for trainer_class, trainer in trainers:
			assert trainer_map(trainer_class, trainer) == data.map_constants_by_file()[map_name]


@pytest.mark.parametrize("badges", [0, 16])
@pytest.mark.parametrize("trainer_class, trainer", KANTO_RB_PARTIES)
def test_reader_keeps_the_form_at_every_stage(game, trainer_class, trainer, badges):
	"""Read on its map with no badges and with all of them: each mon is the stage its level reaches,
	in its party's form, and a Red/Blue one has one Special."""
	forms = rb_forms()
	index = species_index()
	evos = evolutions()
	firsts = first_stages()
	mons = data.party(data.parties(), trainer_class, trainer)["mons"]
	map_name = trainer_map(trainer_class, trainer)
	cap = data.badge_scaling_caps().get(map_name)
	levels = [data.level_at(mon["level"], badges, cap) for mon in mons]
	stages = [index[expected_stage(mon["species"], level, evos, firsts)] for mon, level in zip(mons, levels)]
	set_badges(game, badges)
	go_to_map(game, map_name)
	classes = [name for name, _ in data.trainer_classes()]
	game.poke("wOtherTrainerClass", classes.index(trainer_class))
	game.poke("wOtherTrainerID", dict(data.trainer_classes())[trainer_class][trainer])
	call(game, "ReadTrainerParty")
	assert game.peek("wOTPartyCount") == len(mons)
	assert [index_of_id(game, game.peek("wOTPartySpecies", slot)) for slot in range(len(mons))] == stages
	want = [form_constant(forms[mon["species"]]) if mon["species"] in forms else 0 for mon in mons]
	assert [ot_party_field(game, slot, "Form") & FORM_MASK for slot in range(len(mons))] == want
	for slot, mon in enumerate(mons):
		if mon["species"] in forms:
			assert ot_party_stat(game, slot, "SpclAtk") == ot_party_stat(game, slot, "SpclDef"), mon


@pytest.mark.parametrize("trainer_class, trainer", OPEN_LEAGUE_RB_PARTIES)
def test_reader_gives_open_league_parties_their_forms(game, trainer_class, trainer):
	"""An Open League party, read outside a seat battle: each mon as written, in its form."""
	forms = rb_forms()
	mons = data.party(data.parties(), trainer_class, trainer)["mons"]
	classes = [name for name, _ in data.trainer_classes()]
	game.poke("wOtherTrainerClass", classes.index(trainer_class))
	game.poke("wOtherTrainerID", dict(data.trainer_classes())[trainer_class][trainer])
	call(game, "ReadTrainerParty")
	assert game.peek("wOTPartyCount") == len(mons)
	want = [form_constant(forms[mon["species"]]) if mon["species"] in forms else 0 for mon in mons]
	assert [ot_party_field(game, slot, "Form") & FORM_MASK for slot in range(len(mons))] == want
	for slot, mon in enumerate(mons):
		if mon["species"] in forms:
			assert ot_party_stat(game, slot, "SpclAtk") == ot_party_stat(game, slot, "SpclDef"), mon


def roster():
	return constants._consts(constants.ROOT / "constants" / "elite_four_constants.asm")


def room_partner(game, entry):
	"""(species index, form) of the partner in Will's room with `entry` in its seat, during the Open
	League."""
	game.set_event_flag("EVENT_OPEN_LEAGUE_STARTED")
	others = [roster()[name] for name in ("E4_ROSTER_FALKNER", "E4_ROSTER_BUGSY", "E4_ROSTER_WHITNEY",
		"E4_ROSTER_CHUCK")]
	for seat, value in enumerate([roster()[entry]] + others):
		game.poke("wEliteFourLineup", value, seat)
	go_to_map(game, "WILLS_ROOM")
	result = call(game, "EliteFourRoomPartner", de=0)
	return result["hl"], result["a"]


@pytest.mark.parametrize("trainer_class, trainer, entry, partner_form", [s for s in OPEN_LEAGUE_RB_SEATS if s[3]])
def test_room_partner_takes_the_rb_form(game, trainer_class, trainer, entry, partner_form):
	_, form = room_partner(game, entry)
	assert form == form_constant(partner_form)


@pytest.mark.parametrize("entry", PLAIN_PARTNERS)
def test_other_room_partners_stay_plain(game, entry):
	_, form = room_partner(game, entry)
	assert form == 0


# The Gen 1 TM moves swapped in by hand, as (class, party, slot from 1, species): its moves
PICKED_MOVESETS = {
	("BLACKBELT_T", "ANDER", 2, "GRAVELER"): ("ROLLOUT", "SUBMISSION", "EARTHQUAKE", "EXPLOSION"),
	("BLACKBELT_T", "ANDER", 3, "MACHOKE"): ("SUBMISSION", "ROCK_SLIDE", "CROSS_CHOP", "SCARY_FACE"),
	("BUG_CATCHER", "ABNER", 3, "PIKACHU"): ("THUNDERBOLT", "AGILITY", "THUNDER_WAVE", "SUBMISSION"),
	("HIKER", "BRUCE", 1, "GRAVELER"): ("SUBMISSION", "ROCK_SLIDE", "EARTHQUAKE", "EXPLOSION"),
	("GIOVANNI", "GIOVANNI_ELITE_FOUR", 1, "KANGASKHAN"): ("ROCK_SLIDE", "EARTHQUAKE", "SHADOW_BALL", "CURSE"),
}


@pytest.mark.parametrize("trainer_class, trainer, slot, species", list(PICKED_MOVESETS))
def test_picked_gen1_tm_moves(trainer_class, trainer, slot, species):
	mon = data.party(data.parties(), trainer_class, trainer)["mons"][slot - 1]
	assert mon["species"] == species
	assert mon["moves"] == PICKED_MOVESETS[(trainer_class, trainer, slot, species)]


# Lance's party, in order: the form bytes
LANCE_FORMS = [
	("GYARADOS", "SHINY_MASK | ALT_SHINY_MASK"),
	("DRAGONITE", "SHINY_MASK | ALT_SHINY_MASK"),
	("CHARIZARD", "PLAIN_FORM"),
	("DRAGONITE", "PLAIN_FORM"),
	("DRAGONITE", "DRAGONITE_RB_FORM"),
	("AERODACTYL", "AERODACTYL_RB_FORM"),
]


def test_lances_surprises():
	party = data.party(data.parties(), "CHAMPION", "LANCE")
	assert "TRAINERTYPE_FORM" in party["type"]
	assert [(mon["species"], mon["form"]) for mon in party["mons"]] == LANCE_FORMS


def test_reader_gives_lance_his_surprises(game):
	"""Read as the champion battle reads it: the alternate shinies keep both bits, and the Red/Blue
	Aerodactyl and Dragonite have one Special."""
	from harness import alt_shiny as A
	classes = [name for name, _ in data.trainer_classes()]
	game.poke("wOtherTrainerClass", classes.index("CHAMPION"))
	game.poke("wOtherTrainerID", dict(data.trainer_classes())["CHAMPION"]["LANCE"])
	call(game, "ReadTrainerParty")
	alt = A.SHINY_MASK | A.ALT_SHINY_MASK
	assert [ot_party_field(game, slot, "Form") for slot in range(6)] == 		[alt, alt, 0, 0, form_constant("DRAGONITE_RB_FORM"), form_constant("AERODACTYL_RB_FORM")]
	for slot in (4, 5):
		assert ot_party_stat(game, slot, "SpclAtk") == ot_party_stat(game, slot, "SpclDef")
