roms := \
	pokecrystal.gbc\
	pokecrystal_debug.gbc
patches := pokecrystal.patch

rom_obj := \
	audio.o \
	home.o \
	main.o \
	ram.o \
	data/text/common.o \
	data/maps/map_data.o \
	data/pokemon/dex_entries.o \
	data/pokemon/egg_moves.o \
	data/pokemon/evos_attacks.o \
	engine/movie/credits.o \
	engine/overworld/events.o \
	gfx/icons.o \
	gfx/misc.o \
	gfx/pics.o \
	gfx/sprites.o \
	gfx/tilesets.o \
	lib/mobile/main.o

pokecrystal_obj       := $(rom_obj:.o=.o)
pokecrystal_debug_obj := $(rom_obj:.o=_debug.o)
pokecrystal_vc_obj    := $(rom_obj:.o=_vc.o)
pokecrystal_test_obj  := $(rom_obj:.o=_test.o)


### Build tools

ifeq (,$(shell command -v sha1sum 2>/dev/null))
SHA1 := shasum
else
SHA1 := sha1sum
endif

RGBDS ?=
RGBASM  ?= $(RGBDS)rgbasm
RGBFIX  ?= $(RGBDS)rgbfix
RGBGFX  ?= $(RGBDS)rgbgfx
RGBLINK ?= $(RGBDS)rgblink

PYTHON ?= python

# `make release` patches this unmodified Pokémon Crystal (USA, Europe) (Rev 1) ROM
BASEROM ?= baserom.gbc
BASEROM_SHA1 := f2f52230b536214ef7c9924f483392993e226cfb
VERSION ?= $(shell git describe --tags --always --dirty)


### Build targets

.SUFFIXES:
.PHONY: all crystal clean tidy tools check_trainer_art release test
.SECONDEXPANSION:
.PRECIOUS:
.SECONDARY:

all: crystal crystal_debug crystal_vc
crystal:       pokecrystal.gbc
crystal_debug: pokecrystal_debug.gbc
crystal_vc:    pokecrystal.patch
crystal_test:  pokecrystal_test.gbc

# The regression tests in tests/, run against the test ROM: a debug ROM with a fixed random sequence
test: crystal_test
	$(PYTHON) -m pytest tests

# The files to upload to a GitHub release: a BPS patch for the game and the 3DS Virtual Console patch
release: pokecrystal.gbc pokecrystal.patch
	mkdir -p release
	$(PYTHON) utils/make_bps.py $(BASEROM) pokecrystal.gbc release/crystal-crunch-$(VERSION).bps --sha1 $(BASEROM_SHA1)
	cp pokecrystal.patch release/crystal-crunch-$(VERSION).patch

clean: tidy
	find gfx \
	     \( -name "*.[12]bpp" \
	        -o -name "*.2bpp.vtiles[245]" \
	        -o -name "*.lz" \
	        -o -name "*.gbcpal" \
	        -o -name "*.allpals" \
	        -o -name "*.palx" \
	        -o -name "*.rgbgfxmap" \
	        -o -name "*.sgb.tilemap" \) \
	     -delete
	find gfx/pokemon -mindepth 1 \
	     ! -path "gfx/pokemon/unown/*" \
	     \( -name "bitmask.asm" \
	        -o -name "frames.asm" \
	        -o -name "front.animated.tilemap" \
	        -o -name "front.dimensions" \) \
	     -delete

tidy:
	$(RM) $(roms) \
	      $(roms:.gbc=.sym) \
	      $(roms:.gbc=.map) \
	      $(patches) \
	      $(patches:.patch=_vc.gbc) \
	      $(patches:.patch=_vc.sym) \
	      $(patches:.patch=_vc.map) \
	      $(patches:%.patch=vc/%.constants.sym) \
	      pokecrystal_test.gbc \
	      pokecrystal_test.sym \
	      pokecrystal_test.map \
	      $(pokecrystal_obj) \
	      $(pokecrystal_debug_obj) \
	      $(pokecrystal_vc_obj) \
	      $(pokecrystal_test_obj) \
	      rgbdscheck.o
	$(MAKE) clean -C tools/

tools:
	$(MAKE) -C tools/


RGBASMFLAGS = -Q8 -P includes.asm -Weverything -Wtruncation=1

$(pokecrystal_obj):       RGBASMFLAGS +=
$(pokecrystal_debug_obj): RGBASMFLAGS += -D _DEBUG
$(pokecrystal_vc_obj):    RGBASMFLAGS += -D _CRYSTAL_VC
$(pokecrystal_test_obj):  RGBASMFLAGS += -D _DEBUG -D _TEST

%.patch: %_vc.gbc %.gbc vc/%.patch.template
	tools/make_patch $*_vc.sym $^ $@

rgbdscheck.o: rgbdscheck.asm
	$(RGBASM) -o $@ $<

# Build tools when building the rom.
# This has to happen before the rules are processed, since that's when scan_includes is run.
ifeq (,$(filter clean tidy tools check_trainer_art,$(MAKECMDGOALS)))

$(info $(shell $(MAKE) -C tools))

# The dep rules have to be explicit or else missing files won't be reported.
# As a side effect, they're evaluated immediately instead of when the rule is invoked.
# It doesn't look like $(shell) can be deferred so there might not be a better way.
preinclude_deps := includes.asm $(shell tools/scan_includes includes.asm)
define DEP
$1: $2 $$(shell tools/scan_includes $2) $(preinclude_deps) | rgbdscheck.o
	$$(RGBASM) $$(RGBASMFLAGS) -o $$@ $$<
endef

# Dependencies for shared objects objects
$(foreach obj, $(pokecrystal_obj), $(eval $(call DEP,$(obj),$(obj:.o=.asm))))
$(foreach obj, $(pokecrystal_debug_obj), $(eval $(call DEP,$(obj),$(obj:_debug.o=.asm))))
$(foreach obj, $(pokecrystal_vc_obj), $(eval $(call DEP,$(obj),$(obj:_vc.o=.asm))))
$(foreach obj, $(pokecrystal_test_obj), $(eval $(call DEP,$(obj),$(obj:_test.o=.asm))))

endif


pokecrystal_opt         = -Cjv -t PM_CRYSTAL -i BYTE -n 0 -k 01 -l 0x33 -m MBC3+TIMER+RAM+BATTERY -r 3 -p 0
pokecrystal_debug_opt   = -Cjv -t PM_CRYSTAL -i BYTE -n 0 -k 01 -l 0x33 -m MBC3+TIMER+RAM+BATTERY -r 3 -p 0
pokecrystal_test_opt    = -Cjv -t PM_CRYSTAL -i BYTE -n 0 -k 01 -l 0x33 -m MBC3+TIMER+RAM+BATTERY -r 3 -p 0
pokecrystal_vc_opt      = -Cjv -t PM_CRYSTAL -i BYTE -n 0 -k 01 -l 0x33 -m MBC3+TIMER+RAM+BATTERY -r 3 -p 0

.gbc: tools/bankends
%.gbc: $$(%_obj) layout.link
	$(RGBLINK) -n $*.sym -m $*.map -M -l layout.link -o $@ $(filter %.o,$^)
	$(RGBFIX) $($*_opt) $@
	tools/stadium $@
	tools/bankends -q $(basename $@).map


### LZ compression rules

%.lz: %
	tools/lzcomp -- $< $@


### Pokemon pic animation rules

gfx/pokemon/%/front.animated.2bpp: gfx/pokemon/%/front.2bpp gfx/pokemon/%/front.dimensions
	tools/pokemon_animation_graphics -o $@ $^
gfx/pokemon/%/front.animated.tilemap: gfx/pokemon/%/front.2bpp gfx/pokemon/%/front.dimensions
	tools/pokemon_animation_graphics -t $@ $^
gfx/pokemon/%/bitmask.asm: gfx/pokemon/%/front.animated.tilemap gfx/pokemon/%/front.dimensions
	tools/pokemon_animation -b $^ > $@
gfx/pokemon/%/frames.asm: gfx/pokemon/%/front.animated.tilemap gfx/pokemon/%/front.dimensions
	tools/pokemon_animation -f $^ > $@


### Pokemon and trainer sprite rules

gfx/pokemon/%/back.2bpp: rgbgfx += --columns
gfx/pokemon/%/back.2bpp: gfx/pokemon/%/back.png gfx/pokemon/%/normal.gbcpal
	$(RGBGFX) $(rgbgfx) --colors gbc:$(word 2,$^) -o $@ $<
gfx/pokemon/%/front.2bpp: gfx/pokemon/%/front.png gfx/pokemon/%/normal.gbcpal
	$(RGBGFX) $(rgbgfx) --colors gbc:$(word 2,$^) -o $@ $<
gfx/pokemon/%/normal.gbcpal: gfx/pokemon/%/front.gbcpal gfx/pokemon/%/back.gbcpal
	tools/gbcpal $(tools/gbcpal) $@ $^

# Trainer pics can use up to 3 palettes, which may share colors. tools/trainer_palettes picks them:
# .gbcpal is palette A (TrainerPalettes) and .allpals is every palette, for rgbgfx. rgbgfx gives
# each tile a palette (-q); from that map, --palx writes .palx (TrainerExtraPalettes): palettes B
# and C plus the map, after checking that every tile's colors are in its palette.
# Per-pic options go in trainer_palettes_<name> (see "Pokemon and trainer sprite rules").
gfx/trainers/%.gbcpal gfx/trainers/%.allpals: gfx/trainers/%.png
	tools/trainer_palettes $(trainer_palettes_$*) $< gfx/trainers/$*.gbcpal gfx/trainers/$*.allpals

gfx/trainers/%.2bpp: rgbgfx += --columns
gfx/trainers/%.2bpp: gfx/trainers/%.png gfx/trainers/%.allpals
	$(RGBGFX) $(rgbgfx) --colors gbc:$(word 2,$^) -q gfx/trainers/$*.rgbgfxmap -o $@ $<

# This is a special case for kris since we don't INCBIN her palette.
gfx/trainers/kris.2bpp: gfx/trainers/kris.png gfx/trainers/kris.allpals
	$(RGBGFX) $(rgbgfx) --colors gbc:$(word 2,$^) -q gfx/trainers/kris.rgbgfxmap -o $@ $<

gfx/trainers/%.palx: gfx/trainers/%.png gfx/trainers/%.2bpp
	tools/trainer_palettes --palx $(trainer_palettes_$*) $< gfx/trainers/$*.rgbgfxmap $@

check_trainer_art:
	$(MAKE) -C tools trainer_palettes
	tools/trainer_palettes --verbose $(trainer_palettes_$(TRAINER)) gfx/trainers/$(TRAINER).png

# Egg does not have a back sprite, so it only uses front.gbcpal
gfx/pokemon/egg/front.2bpp: gfx/pokemon/egg/front.png gfx/pokemon/egg/front.gbcpal
gfx/pokemon/egg/front.2bpp: rgbgfx += --colors gbc:$(word 2,$^)

# Neither does the Elekid egg pattern
gfx/pokemon/egg_elekid/front.2bpp: gfx/pokemon/egg_elekid/front.png gfx/pokemon/egg_elekid/front.gbcpal
gfx/pokemon/egg_elekid/front.2bpp: rgbgfx += --colors gbc:$(word 2,$^)

# Apricorn Snorlax has its own colours but no back sprite, so its palette comes from the front alone
gfx/pokemon/snorlax_apricorn/normal.gbcpal: gfx/pokemon/snorlax_apricorn/front.gbcpal
	tools/gbcpal $(tools/gbcpal) $@ $^

# Rocket Charmeleon likewise has its own colours but no back sprite
gfx/pokemon/charmeleon_rocket/normal.gbcpal: gfx/pokemon/charmeleon_rocket/front.gbcpal
	tools/gbcpal $(tools/gbcpal) $@ $^

# Rocket Charizard, same again
gfx/pokemon/charizard_rocket/normal.gbcpal: gfx/pokemon/charizard_rocket/front.gbcpal
	tools/gbcpal $(tools/gbcpal) $@ $^

# Rocket Weezing has no back sprite and is drawn in Weezing's own colours,
# so it takes the species' palette instead of building one of its own
gfx/pokemon/weezing_rocket/front.2bpp: gfx/pokemon/weezing_rocket/front.png gfx/pokemon/weezing/normal.gbcpal
gfx/pokemon/weezing_rocket/front.2bpp: rgbgfx += --colors gbc:$(word 2,$^)

# Rocket Golbat, same again: no back sprite, drawn in Golbat's own colours
gfx/pokemon/golbat_rocket/front.2bpp: gfx/pokemon/golbat_rocket/front.png gfx/pokemon/golbat/normal.gbcpal
gfx/pokemon/golbat_rocket/front.2bpp: rgbgfx += --colors gbc:$(word 2,$^)

# Rocket Arbok has no back sprite but keeps its own colours, so its palette
# comes from the front alone
gfx/pokemon/arbok_rocket/normal.gbcpal: gfx/pokemon/arbok_rocket/front.gbcpal
	tools/gbcpal $(tools/gbcpal) $@ $^

# Rocket Crobat, same again
gfx/pokemon/crobat_rocket/normal.gbcpal: gfx/pokemon/crobat_rocket/front.gbcpal
	tools/gbcpal $(tools/gbcpal) $@ $^

# Rocket Electrode, same again
gfx/pokemon/electrode_rocket/normal.gbcpal: gfx/pokemon/electrode_rocket/front.gbcpal
	tools/gbcpal $(tools/gbcpal) $@ $^

# Unown letters share one normal.gbcpal
unown_pngs := $(wildcard gfx/pokemon/unown_*/front.png) $(wildcard gfx/pokemon/unown_*/back.png)
$(foreach png, $(unown_pngs),\
	$(eval $(png:.png=.2bpp): $(png) gfx/pokemon/unown/normal.gbcpal))
gfx/pokemon/unown_%/back.2bpp: rgbgfx += --colors gbc:$(word 2,$^)
gfx/pokemon/unown_%/front.2bpp: rgbgfx += --colors gbc:$(word 2,$^)
gfx/pokemon/unown/normal.gbcpal: $(subst .png,.gbcpal,$(unown_pngs))
	tools/gbcpal $(tools/gbcpal) $@ $^


### Misc file-specific graphics rules
gfx/pokemon/egg/unused_front.2bpp: rgbgfx += --columns

gfx/pokemon/spearow/normal.gbcpal: tools/gbcpal += --reverse
gfx/pokemon/fearow/normal.gbcpal: tools/gbcpal += --reverse
gfx/pokemon/farfetch_d/normal.gbcpal: tools/gbcpal += --reverse
gfx/pokemon/hitmonlee/normal.gbcpal: tools/gbcpal += --reverse
gfx/pokemon/scyther/normal.gbcpal: tools/gbcpal += --reverse
gfx/pokemon/jynx/normal.gbcpal: tools/gbcpal += --reverse
gfx/pokemon/porygon/normal.gbcpal: tools/gbcpal += --reverse
gfx/pokemon/porygon2/normal.gbcpal: tools/gbcpal += --reverse

trainer_palettes_swimmer_m := --reverse

gfx/new_game/shrink1.2bpp: rgbgfx += --columns
gfx/new_game/shrink2.2bpp: rgbgfx += --columns

gfx/mail/dragonite.1bpp: tools/gfx += --remove-whitespace
gfx/mail/large_note.1bpp: tools/gfx += --remove-whitespace
gfx/mail/surf_mail_border.1bpp: tools/gfx += --remove-whitespace
gfx/mail/flower_mail_border.1bpp: tools/gfx += --remove-whitespace
gfx/mail/litebluemail_border.1bpp: tools/gfx += --remove-whitespace

gfx/pokedex/pokedex.2bpp: tools/gfx += --trim-whitespace
gfx/pokedex/pokedex_sgb.2bpp: tools/gfx += --trim-whitespace
gfx/pokedex/question_mark.2bpp: rgbgfx += --columns
gfx/pokedex/slowpoke.2bpp: tools/gfx += --trim-whitespace

gfx/pokegear/pokegear_sprites.2bpp: tools/gfx += --trim-whitespace

gfx/mystery_gift/mystery_gift.2bpp: tools/gfx += --trim-whitespace

gfx/title/crystal.2bpp: tools/gfx += --interleave --png=$<
gfx/title/old_fg.2bpp: tools/gfx += --interleave --png=$<
gfx/title/logo.2bpp: rgbgfx += --trim-end 4

gfx/trade/ball.2bpp: tools/gfx += --remove-whitespace
gfx/trade/game_boy.2bpp: tools/gfx += --remove-duplicates --preserve=0x23,0x27
gfx/trade/game_boy_cable.2bpp: gfx/trade/game_boy.2bpp gfx/trade/link_cable.2bpp ; cat $^ > $@

gfx/pc/obj.2bpp: gfx/pc/modes.2bpp gfx/pc/packs.2bpp ; cat $^ > $@

gfx/slots/slots_1.2bpp: tools/gfx += --trim-whitespace
gfx/slots/slots_2.2bpp: tools/gfx += --interleave --png=$<
gfx/slots/slots_3.2bpp: tools/gfx += --interleave --png=$< --remove-duplicates --keep-whitespace --remove-xflip

gfx/card_flip/card_flip_1.2bpp: tools/gfx += --trim-whitespace
gfx/card_flip/card_flip_2.2bpp: tools/gfx += --remove-whitespace

gfx/battle_anims/angels.2bpp: tools/gfx += --trim-whitespace
gfx/battle_anims/beam.2bpp: tools/gfx += --remove-xflip --remove-yflip --remove-whitespace
gfx/battle_anims/bubble.2bpp: tools/gfx += --trim-whitespace
gfx/battle_anims/charge.2bpp: tools/gfx += --trim-whitespace
gfx/battle_anims/egg.2bpp: tools/gfx += --remove-whitespace
gfx/battle_anims/explosion.2bpp: tools/gfx += --remove-whitespace
gfx/battle_anims/hit.2bpp: tools/gfx += --remove-whitespace
gfx/battle_anims/horn.2bpp: tools/gfx += --remove-whitespace
gfx/battle_anims/lightning.2bpp: tools/gfx += --remove-whitespace
gfx/battle_anims/misc.2bpp: tools/gfx += --remove-duplicates --remove-xflip
gfx/battle_anims/noise.2bpp: tools/gfx += --remove-whitespace
gfx/battle_anims/objects.2bpp: tools/gfx += --remove-whitespace --remove-xflip
gfx/battle_anims/pokeball.2bpp: tools/gfx += --remove-xflip --keep-whitespace
gfx/battle_anims/reflect.2bpp: tools/gfx += --remove-whitespace
gfx/battle_anims/rocks.2bpp: tools/gfx += --remove-whitespace
gfx/battle_anims/skyattack.2bpp: tools/gfx += --remove-whitespace
gfx/battle_anims/status.2bpp: tools/gfx += --remove-whitespace

gfx/player/chris.2bpp: rgbgfx += --columns
gfx/player/chris_back.2bpp: rgbgfx += --columns
gfx/player/kris.2bpp: rgbgfx += --columns
gfx/player/kris_back.2bpp: rgbgfx += --columns

gfx/trainer_card/chris_card.2bpp: rgbgfx += --columns
gfx/trainer_card/kris_card.2bpp: rgbgfx += --columns
gfx/trainer_card/leaders.2bpp: tools/gfx += --trim-whitespace

gfx/overworld/chris_fish.2bpp: tools/gfx += --trim-whitespace
gfx/overworld/kris_fish.2bpp: tools/gfx += --trim-whitespace

gfx/sprites/big_onix.2bpp: tools/gfx += --remove-whitespace --remove-xflip

gfx/battle/dude.2bpp: rgbgfx += --columns

gfx/font/unused_bold_font.1bpp: tools/gfx += --trim-whitespace

gfx/sgb/sgb_border.2bpp: tools/gfx += --trim-whitespace
gfx/sgb/sgb_border.sgb.tilemap: gfx/sgb/sgb_border.bin ; tr < $< -d '\000' > $@

gfx/mobile/ascii_font.2bpp: tools/gfx += --trim-whitespace
gfx/mobile/dialpad.2bpp: tools/gfx += --trim-whitespace
gfx/mobile/dialpad_cursor.2bpp: tools/gfx += --trim-whitespace
gfx/mobile/electro_ball.2bpp: tools/gfx += --remove-duplicates --remove-xflip --preserve=0x39
gfx/mobile/mobile_splash.2bpp: tools/gfx += --remove-duplicates --remove-xflip
gfx/mobile/card.2bpp: tools/gfx += --trim-whitespace
gfx/mobile/card_2.2bpp: tools/gfx += --trim-whitespace
gfx/mobile/card_folder.2bpp: tools/gfx += --trim-whitespace
gfx/mobile/phone_tiles.2bpp: tools/gfx += --remove-whitespace
gfx/mobile/pichu_animated.2bpp: tools/gfx += --trim-whitespace
gfx/mobile/stadium2_n64.2bpp: tools/gfx += --trim-whitespace

### Catch-all graphics rules

%.2bpp: %.png
	$(RGBGFX) --colors dmg=e4 $(rgbgfx) -o $@ $<
	$(if $(tools/gfx),\
		tools/gfx $(tools/gfx) -o $@ $@ || $$($(RM) $@ && false))

%.1bpp: %.png
	$(RGBGFX) --colors dmg=e4 $(rgbgfx) --depth 1 -o $@ $<
	$(if $(tools/gfx),\
		tools/gfx $(tools/gfx) --depth 1 -o $@ $@ || $$($(RM) $@ && false))

%.2bpp.vtiles2: %.2bpp
	$Qtools/sub_2bpp.sh $< 128 > $@

%.2bpp.vtiles4: %.2bpp
	$Qtools/sub_2bpp.sh $< 256 128 > $@

%.2bpp.vtiles5: %.2bpp
	$Qtools/sub_2bpp.sh $< 128 128 > $@

%.gbcpal: %.png
	$(RGBGFX) -p $@ $<
	tools/gbcpal $(tools/gbcpal) $@ $@ || $$($(RM) $@ && false)

%.dimensions: %.png
	tools/png_dimensions $< $@
