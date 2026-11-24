; Blackjack: a shoe of two decks, reshuffled at a cut card three quarters in, A hits and B stands, the dealer stands on every 17,
; blackjack pays 3:2, a win pays 1:1 and a push returns the bet. The bottom bar says what A and B
; do at each stop; the player can leave between hands.

DEF BLACKJACK_FACE_DOWN EQU $ff

DEF BJ_CARD_WIDTH   EQU 4
DEF BJ_CARD_HEIGHT  EQU 6

; Tiles in vTiles2: the card parts every deck shares (card_parts.png), then the deck's own suits,
; pictures and back, then the felt, the A and B buttons, and "+" in a spot of its own.
DEF BJTILE_RANKS          EQU $00 ; + rank - 1: A 2 3 4 5 6 7 8 9 10 J Q K
DEF BJTILE_RANK_MARK      EQU BJTILE_RANKS + BLACKJACK_NUM_RANKS
DEF BJTILE_BLANK          EQU BJTILE_RANK_MARK + 1
DEF BJTILE_TOP            EQU BJTILE_BLANK + 1 ; then the top right corner
DEF BJTILE_RIGHT_EDGE     EQU BJTILE_TOP + 2
DEF BJTILE_BOTTOM_LEFT    EQU BJTILE_RIGHT_EDGE + 1 ; then the bottom edge and the bottom right corner
DEF BJ_NUM_CARD_PART_TILES EQU BJTILE_BOTTOM_LEFT + 3 - BJTILE_RANKS
; A deck's own tiles (BlackjackDecks)
DEF BJTILE_SUITS          EQU BJTILE_RANKS + BJ_NUM_CARD_PART_TILES ; + suit
DEF BJ_PICTURE_TILES      EQU BJ_CARD_WIDTH * 3 ; a 4x3 picture
DEF BJTILE_PICTURES       EQU BJTILE_SUITS + BLACKJACK_NUM_SUITS ; + suit * BJ_PICTURE_TILES
DEF BJ_BACK_TILES         EQU BJ_CARD_WIDTH * BJ_CARD_HEIGHT ; the whole card
DEF BJTILE_BACK           EQU BJTILE_PICTURES + BLACKJACK_NUM_SUITS * BJ_PICTURE_TILES
DEF BJ_NUM_CARD_TILES     EQU BJTILE_BACK + BJ_BACK_TILES - BJTILE_RANKS
; felt.png: a 2x2 pattern, then a blank 2x2 (its first tile used), so the tile below any tile is
; BJ_FELT_PNG_WIDTH on; then the same tiles again for the dealer's side, made with the felt's two
; greens swapped
DEF BJTILE_FELT           EQU BJTILE_BACK + BJ_BACK_TILES
DEF BJ_FELT_PNG_WIDTH     EQU 4
DEF BJ_FELT_PNG_TILES     EQU BJ_FELT_PNG_WIDTH * 2
DEF BJTILE_FELT_BLANK     EQU BJTILE_FELT + 2
DEF BJ_FELT_DEALER        EQU BJ_FELT_PNG_TILES ; from a felt tile to its dealer's side copy
DEF BJ_NUM_FELT_TILES     EQU BJ_FELT_PNG_TILES * 2
DEF BJTILE_BUTTON_A       EQU BJTILE_FELT + BJ_NUM_FELT_TILES
DEF BJTILE_BUTTON_B       EQU BJTILE_BUTTON_A + 1
DEF BJ_NUM_BUTTON_TILES   EQU 2
; A card's left corners where it covers the card behind, made from the deck's tiles with the outline
; of the card behind carried on outside them: the suits' top left corners (+ suit), the back's, then
; the bottom left corners, a face card's and the back's
DEF BJTILE_OVERLAP        EQU BJTILE_BUTTON_A + BJ_NUM_BUTTON_TILES
DEF BJTILE_OVERLAP_BACK   EQU BJTILE_OVERLAP + BLACKJACK_NUM_SUITS
DEF BJTILE_OVERLAP_BOTTOM_LEFT      EQU BJTILE_OVERLAP_BACK + 1
DEF BJTILE_OVERLAP_BACK_BOTTOM_LEFT EQU BJTILE_OVERLAP_BOTTOM_LEFT + 1
DEF BJ_NUM_OVERLAP_TILES  EQU BJTILE_OVERLAP_BACK_BOTTOM_LEFT + 1 - BJTILE_OVERLAP
DEF BJTILE_PLUS           EQU "<BJ_PLUS>" ; the font has no "+"
assert BJTILE_OVERLAP + BJ_NUM_OVERLAP_TILES <= BJTILE_PLUS && BJTILE_PLUS < " ", \
	"the blackjack tiles end before \"+\", which comes before the text box's space tile"
; Each card corner's pixels outside its rounded edge, as the card art draws them: two on the
; card's edge row and one on the row in from it
DEF BJ_CORNER_LEFT_EDGE  EQU %11000000
DEF BJ_CORNER_LEFT_NEXT  EQU %10000000
DEF BJ_CORNER_RIGHT_EDGE EQU %00000011
DEF BJ_CORNER_RIGHT_NEXT EQU %00000001
; Sprites: the sliding card's, then two for the top left corner of each hand's first card, whose
; suit tile can't show the felt's green: the dealer's, then yours. Their tiles follow the sliding
; card copies in vTiles0.
DEF BJ_CORNER_OAM     EQU BJ_CARD_WIDTH * BJ_CARD_HEIGHT
DEF BJ_CORNER_SPRITES EQU BJ_NUM_CARD_TILES ; the dealer's side's, then yours

; BG palettes: 0-3 the suits' (palette = suit), then these; the suits' and the back's come from
; the deck. A sliding card's sprite palettes use the same numbers.
DEF BJPAL_FELT EQU 4
DEF BJPAL_BACK EQU 5
DEF BJPAL_SIDEBAR EQU 6
DEF NUM_BJ_PALETTES EQU 4 ; blackjack.pal, from BJPAL_FELT

; The sidebar's tiles are in VRAM bank 1, where nothing else here is, and drawn over sprites, so a
; card sliding out from behind it stays hidden until it clears its edge.
DEF BJ_SIDEBAR_ATTR EQU BJPAL_SIDEBAR | BG_BANK1 | BG_PRIO
; sidebar.png is the sidebar above Meowth, the owner's art; the totals' numbers and the bet menu
; are drawn over copies of its tiles at run time
DEF BJTILE1_COINS    EQU $00 ; the coin count, across the row under the COINS banner: 5 tiles
DEF BJTILE1_TOTALS   EQU $05 ; YOU's, then THEM's (the dealer's) total, 2 tiles each
DEF BJTILE1_MENU     EQU $09 ; the bet menu's three rows, 3 tiles each, then "BET?" above them
DEF BJTILE1_FELT_CORNERS EQU $14 ; card corners on your side of the felt: bottom left, top right, bottom right
DEF BJ_DEALER_CORNERS  EQU 3     ; then the same on the dealer's side
; then the back's top right and bottom right on the dealer's felt (the face-down card is only ever
; the dealer's), in the back's palette, whose colour 2 is the dealer's green
DEF BJTILE1_BACK_CORNERS EQU BJTILE1_FELT_CORNERS + BJ_DEALER_CORNERS * 2
DEF BJTILE1_SHEET    EQU $20 ; sidebar.png's tiles, each different one once (sidebar.tilemap)
; meowth.png: frames of 5x5 tiles, the window's border drawn in them, so Meowth can reach past it.
; Each different tile is kept once, all of them in VRAM together, and meowth.tilemap says where
; they go in each frame, so a frame change is only the window's tilemap.
DEF BJ_MEOWTH_SIZE   EQU 5
DEF BJ_MEOWTH_TILES  EQU BJ_MEOWTH_SIZE * BJ_MEOWTH_SIZE
DEF BJ_MEOWTH_FRAMES EQU 2 + 2 + 2 + 1 ; idle, cheer, big cheer, slump
DEF BJTILE1_MEOWTH   EQU $80
; Each animation is a list of steps, a frame and how long it stays up (BlackjackMeowthAnimations)
DEF BJ_MEOWTH_STEP      EQU 16 ; idle and slump: calm
DEF BJ_MEOWTH_CHEER_STEP EQU 6 ; cheer: a quick hop
DEF BJ_MEOWTH_BIG_CHEER_STEP EQU 5 ; big cheer: the same hop, quicker

; small_font.png: 4x8 characters, two to a tile, in this order
DEF BJ_SMALL_SPACE EQU 0
DEF BJ_SMALL_0     EQU 1 ; to 9
DEF BJ_SMALL_A     EQU 11 ; to Z
DEF BJ_SMALL_CURSOR EQU BJ_SMALL_A + 26
DEF BJ_SMALL_QUESTION EQU BJ_SMALL_CURSOR + 1
; The sidebar's text tiles are drawn in WRAM bank 6's scratch, as DecompressRequest2bpp does
DEF wBlackjackSidebarTiles EQUS "wDecompressScratch"
DEF BJ_FIELD_INK EQUS "(wDecompressScratch + $180)" ; a field's ink, tile by tile, before it's drawn
DEF BJ_MAX_FIELD_TILES EQU 5

; BlackjackDecks: suits, pictures and back gfx, palettes, and how many back colours follow the
; suits' palettes
DEF BJ_DECK_ENTRY_SIZE EQU 4 * 2 + 1

; The screen: the table on the left, with the dealer's hand, a gap and your hand on the felt; the
; sidebar on the right, with the totals in small text at the top and Meowth's window at the bottom;
; and a white bar along the bottom saying what A and B do. Messages show in a text box the dialogue
; box's height, centred over the gap.
DEF BJ_SIDEBAR_X     EQU 15
DEF BJ_SIDEBAR_WIDTH EQU SCREEN_WIDTH - BJ_SIDEBAR_X
DEF BJ_TABLE_WIDTH   EQU BJ_SIDEBAR_X
DEF BJ_FELT_TOP     EQU 0
DEF BJ_FELT_HEIGHT  EQU SCREEN_HEIGHT - 1
DEF BJ_HAND_X       EQU 1
DEF BJ_DEALER_ROW   EQU 1
DEF BJ_PLAYER_ROW   EQU 10
DEF BJ_MAX_SHOWN    EQU 6 ; later cards go in the last one's spot
	assert BJ_HAND_X + (BJ_MAX_SHOWN - 1) * 2 + BJ_CARD_WIDTH <= BJ_TABLE_WIDTH, \
		"a full hand fits the table"
; The sidebar: the owner's picture above Meowth, with the totals' numbers and the bet menu drawn
; over it in the small font
DEF BJ_SHEET_ROWS     EQU 12 ; rows 0-11
DEF BJ_NUM_SHEET_TILES EQU BJ_SHEET_ROWS * BJ_SIDEBAR_WIDTH ; its cells on screen
DEF BJ_COINS_Y        EQU 1 ; the coin count, centred in white in the panel under COINS
DEF BJ_TOTALS_Y       EQU 4 ; YOU's and THEM's totals, centred in white in the panels under them
DEF BJ_TOTAL_TILES    EQU 2
DEF BJ_YOU_X          EQU BJ_SIDEBAR_X
DEF BJ_THEM_X         EQU BJ_SIDEBAR_X + 3
DEF BJ_SIDEBAR_DIGITS EQU 4 ; a number's places before it's centred
; nudges, in pixels, to sit each total in its panel: right (or left if negative), and down
DEF BJ_YOU_NUDGE_X    EQU 2
DEF BJ_YOU_NUDGE_Y    EQU 1
DEF BJ_THEM_NUDGE_X   EQU -1
DEF BJ_THEM_NUDGE_Y   EQU 1
	assert BJ_THEM_X + BJ_TOTAL_TILES == SCREEN_WIDTH, "THEM's total ends at the screen's edge"
	assert BJTILE1_COINS + BJ_SIDEBAR_WIDTH == BJTILE1_TOTALS && \
		BJTILE1_TOTALS + 2 * BJ_TOTAL_TILES <= BJTILE1_MENU, \
		"the coins' and totals' tiles in a row, before the menu's"
DEF BJ_MENU_X         EQU BJ_SIDEBAR_X + 1 ; the bet menu: the cursor, then the amount
DEF BJ_MENU_PROMPT_Y  EQU 6 ; "BET?", from the sidebar's left edge, a pixel in
DEF BJ_MENU_PROMPT_NUDGE_X EQU 1
	assert BJ_MENU_PROMPT_Y > BJ_TOTALS_Y + 1, "the menu is below the totals' panels"
DEF BJ_MENU_PROMPT_TILES EQU 2
DEF BJ_MENU_Y         EQU BJ_MENU_PROMPT_Y + 1 ; the first bet's row; the others under it
DEF BJ_MENU_TILES     EQU 3
DEF BJTILE1_PROMPT    EQU BJTILE1_MENU + 3 * BJ_MENU_TILES
	assert BJTILE1_PROMPT + BJ_MENU_PROMPT_TILES <= BJTILE1_FELT_CORNERS && \
		BJTILE1_BACK_CORNERS + 2 <= BJTILE1_SHEET, \
		"the menu's tiles, then the felt's card corners, end before the sheet's"
DEF BJ_MEOWTH_X       EQU BJ_SIDEBAR_X
DEF BJ_MEOWTH_Y       EQU BJ_FELT_TOP + BJ_FELT_HEIGHT - BJ_MEOWTH_SIZE ; below the message box
	assert BJ_MEOWTH_Y >= BJ_BOX_TOP + BJ_BOX_HEIGHT, "results don't cover Meowth"
	assert BJ_MEOWTH_X + BJ_MEOWTH_SIZE == SCREEN_WIDTH && \
		BJ_MEOWTH_Y + BJ_MEOWTH_SIZE == BJ_FELT_TOP + BJ_FELT_HEIGHT, \
		"Meowth fills the sidebar's bottom right corner"
	assert BJ_PLAYER_ROW + BJ_CARD_HEIGHT < SCREEN_HEIGHT - 1, "your hand clears the bottom bar"
DEF BJ_BOX_HEIGHT   EQU TEXTBOX_HEIGHT
DEF BJ_BOX_TOP      EQU (SCREEN_HEIGHT - BJ_BOX_HEIGHT) / 2
DEF BJ_MESSAGE_X    EQU 1
DEF BJ_MESSAGE_ROW  EQU BJ_BOX_TOP + 2 ; the box's first line
	assert BJ_DEALER_ROW + BJ_CARD_HEIGHT <= BJ_MESSAGE_ROW && BJ_MESSAGE_ROW < BJ_PLAYER_ROW, \
		"the message line is in the gap between the hands"
; A dealt card slides out from behind the sidebar at the top of the table over BJ_SLIDE_FRAMES, then
; the next one waits BJ_DEAL_FRAMES.
DEF BJ_SLIDE_FRAMES EQU 12
DEF BJ_DEAL_FRAMES  EQU 8
DEF BJ_SLIDE_START_X EQU BJ_SIDEBAR_X * TILE_WIDTH
DEF BJ_SLIDE_START_Y EQU BJ_DEALER_ROW * TILE_HEIGHT
	assert BJ_SLIDE_START_X - BJ_HAND_X * TILE_WIDTH + BJ_SLIDE_FRAMES < 256 && \
		BJ_PLAYER_ROW * TILE_HEIGHT - BJ_SLIDE_START_Y + BJ_SLIDE_FRAMES < 256, \
		"a slide's distances fit Blackjack_SlideCard's bytes"
	assert BJ_CARD_WIDTH <= BJ_SIDEBAR_WIDTH, "a card starts out hidden behind the sidebar"
; The felt: blank, in bands two rows tall from the top, with the 2x2 pattern every BJ_FELT_SPACING
; columns, staggered by half that from one band to the next, lined up with the table's right
; edge. The dealer's side, its top BJ_DEALER_FELT_HEIGHT rows, has the two greens swapped.
DEF BJ_FELT_SPACING   EQU 6
DEF BJ_FELT_FIRST_X   EQU 1 ; in the first band
DEF BJ_FELT_SECOND_X  EQU BJ_FELT_FIRST_X + BJ_FELT_SPACING / 2 ; in the next
DEF BJ_FELT_BANDS_TOP EQU BJ_FELT_TOP
DEF BJ_FELT_BANDS     EQU BJ_FELT_HEIGHT / 2 ; an odd row left over at the bottom is plain
	assert (BJ_TABLE_WIDTH - 2 - BJ_FELT_FIRST_X) % BJ_FELT_SPACING == 0, 		"the first band's last pattern ends at the table's right edge"
DEF BJ_DEALER_FELT_HEIGHT EQU 8
	assert BJ_DEALER_FELT_HEIGHT % 2 == 0, "the dealer's side ends between two bands"
	assert BJ_DEALER_ROW + BJ_CARD_HEIGHT <= BJ_FELT_TOP + BJ_DEALER_FELT_HEIGHT && \
		BJ_FELT_TOP + BJ_DEALER_FELT_HEIGHT <= BJ_PLAYER_ROW, \
		"the dealer's side holds the dealer's hand and none of yours"
; The title screen: the felt's pattern over the whole screen, moving a pixel left and a pixel down
; every BJ_TITLE_STEP_FRAMES; the logo; and white text drawn over the felt. The pattern repeats every
; 6x4 tiles, so the felt is those tiles over and over. They are made from a 48x32 copy of the
; pattern in WRAM, turned a pixel at each step, with the text's tiles made over them, and sent to
; whichever of two copies isn't on screen (vTiles2 or vTiles0, both tile $00 on with LCDC's tile
; blocks bit), which is then shown from the start of a VBlank, so the screen never tears.
DEF BJ_TITLE_TEXTURE_WIDTH  EQU BJ_FELT_SPACING ; tiles
DEF BJ_TITLE_TEXTURE_HEIGHT EQU 4 ; tiles: two bands
	assert BJ_TITLE_TEXTURE_WIDTH == 6, "Blackjack_TitleTilemap multiplies by 6"
DEF BJ_TITLE_TEXTURE_ROW    EQU BJ_TITLE_TEXTURE_WIDTH * 2 ; a pixel row's bytes, the planes interleaved
DEF BJ_TITLE_TEXTURE_PIXEL_ROWS EQU BJ_TITLE_TEXTURE_HEIGHT * TILE_HEIGHT
	assert BJ_TITLE_TEXTURE_PIXEL_ROWS & (BJ_TITLE_TEXTURE_PIXEL_ROWS - 1) == 0, \
		"the felt's rows wrap with a mask"
DEF BJ_TITLE_FELT_TILES     EQU BJ_TITLE_TEXTURE_WIDTH * BJ_TITLE_TEXTURE_HEIGHT
DEF BJ_TITLE_STEP_FRAMES    EQU 2
; the text: START, the deck control's label, and the control: "◀ " and " ▶" around the deck's name
; while more than one deck is unlocked. Each line is the sidebar's small font in white, with a black
; shadow a pixel down and right, centred on the screen to the pixel, in cells of its own.
DEF BJ_TITLE_NAME_LENGTH  EQU 10 ; the longest deck name
DEF BJ_SMALL_WIDTH        EQU 4 ; a small character's pixels across, its gap included
DEF BJ_TITLE_START_LENGTH EQU 10 ; "PUSH START"
DEF BJ_TITLE_LABEL_LENGTH EQU 4 ; "DECK"
DEF BJ_TITLE_DECK_LENGTH  EQU BJ_TITLE_NAME_LENGTH + 4 ; "◀ " name " ▶"
DEF BJ_TITLE_START_CELLS  EQU 6
DEF BJ_TITLE_LABEL_CELLS  EQU 3
DEF BJ_TITLE_DECK_CELLS   EQU 8
DEF BJ_TITLE_START_Y      EQU 10
DEF BJ_TITLE_LABEL_Y      EQU 12
DEF BJ_TITLE_DECK_Y       EQU 13
DEF BJ_TITLE_START_X      EQU (SCREEN_WIDTH - BJ_TITLE_START_CELLS) / 2
DEF BJ_TITLE_LABEL_X      EQU (SCREEN_WIDTH - BJ_TITLE_LABEL_CELLS) / 2
DEF BJ_TITLE_DECK_X       EQU (SCREEN_WIDTH - BJ_TITLE_DECK_CELLS) / 2
; A line of n characters starts SCREEN_WIDTH_PX / 2 - 2n pixels in (its last gap left out), so its
; cells must reach that far left and, with the shadow, as far right; a shorter line fits too.
MACRO bj_title_line_fits
; length, x, cells
	assert SCREEN_WIDTH_PX / 2 - (\1) * BJ_SMALL_WIDTH / 2 >= (\2) * TILE_WIDTH && \
		SCREEN_WIDTH_PX / 2 + (\1) * BJ_SMALL_WIDTH / 2 <= ((\2) + (\3)) * TILE_WIDTH, \
		"a title line fits its cells"
ENDM
	bj_title_line_fits BJ_TITLE_START_LENGTH, BJ_TITLE_START_X, BJ_TITLE_START_CELLS
	bj_title_line_fits BJ_TITLE_LABEL_LENGTH, BJ_TITLE_LABEL_X, BJ_TITLE_LABEL_CELLS
	bj_title_line_fits BJ_TITLE_DECK_LENGTH, BJ_TITLE_DECK_X, BJ_TITLE_DECK_CELLS
	assert BJ_TITLE_START_CELLS <= BJ_TITLE_DECK_CELLS && BJ_TITLE_LABEL_CELLS <= BJ_TITLE_DECK_CELLS, \
		"the deck line is the widest"
DEF BJ_TITLE_START_CELL   EQU 0
DEF BJ_TITLE_LABEL_CELL   EQU BJ_TITLE_START_CELL + BJ_TITLE_START_CELLS
DEF BJ_TITLE_DECK_CELL    EQU BJ_TITLE_LABEL_CELL + BJ_TITLE_LABEL_CELLS
DEF BJ_TITLE_TEXT_CELLS   EQU BJ_TITLE_DECK_CELL + BJ_TITLE_DECK_CELLS
; tiles: the felt's, then the text's, in both copies; the logo's from $80, which both share
DEF BJTILE_TITLE_FELT     EQU $00
DEF BJTILE_TITLE_TEXT     EQU BJTILE_TITLE_FELT + BJ_TITLE_FELT_TILES
DEF BJ_TITLE_TILES        EQU BJTILE_TITLE_TEXT + BJ_TITLE_TEXT_CELLS - BJTILE_TITLE_FELT
	assert BJTILE_TITLE_FELT + BJ_TITLE_TILES <= $80, "the moving tiles are below $80, in both copies"
; logo.png, the owner's, in solid tiles: Meowth's two frames side by side, centred over the sign.
; On screen one frame at a time sits centred on top of the sign, the two taking turns every
; BJ_TITLE_MEOWTH_FRAMES. Each different tile is kept once, and logo.tilemap says where each goes.
; The PNG's top left tile is the plain background beside the frames, which no cell shows, so it is
; tile 0 and left out.
DEF BJ_TITLE_MEOWTH_WIDTH  EQU 4
DEF BJ_TITLE_MEOWTH_HEIGHT EQU 3
DEF BJ_TITLE_MEOWTH_TILES  EQU BJ_TITLE_MEOWTH_WIDTH * BJ_TITLE_MEOWTH_HEIGHT
DEF BJ_TITLE_SIGN_WIDTH    EQU 10
DEF BJ_TITLE_SIGN_HEIGHT   EQU 2
DEF BJ_TITLE_LOGO_PNG_WIDTH EQU BJ_TITLE_SIGN_WIDTH
DEF BJ_TITLE_MEOWTH_PNG_X  EQU (BJ_TITLE_LOGO_PNG_WIDTH - 2 * BJ_TITLE_MEOWTH_WIDTH) / 2
	assert BJ_TITLE_MEOWTH_PNG_X > 0, "logo.png's top left tile is beside the frames"
DEF BJ_TITLE_SIGN_PNG_Y    EQU BJ_TITLE_MEOWTH_HEIGHT
DEF BJ_TITLE_SIGN_X        EQU (SCREEN_WIDTH - BJ_TITLE_SIGN_WIDTH) / 2
DEF BJ_TITLE_MEOWTH_X      EQU BJ_TITLE_SIGN_X + (BJ_TITLE_SIGN_WIDTH - BJ_TITLE_MEOWTH_WIDTH) / 2
DEF BJ_TITLE_MEOWTH_Y      EQU 3
DEF BJ_TITLE_SIGN_Y        EQU BJ_TITLE_MEOWTH_Y + BJ_TITLE_MEOWTH_HEIGHT
	assert BJ_TITLE_MEOWTH_Y + BJ_TITLE_MEOWTH_HEIGHT <= SCREEN_HEIGHT / 3, \
		"Meowth is in the tilemap's top third, which goes over when its frame changes"
	assert (SCREEN_WIDTH - BJ_TITLE_SIGN_WIDTH) % 2 == 0 && \
		(BJ_TITLE_SIGN_WIDTH - BJ_TITLE_MEOWTH_WIDTH) % 2 == 0, "the logo centred to the tile"
	assert BJ_TITLE_SIGN_Y + BJ_TITLE_SIGN_HEIGHT <= BJ_TITLE_START_Y, "the logo is above the text"
DEF BJ_TITLE_MEOWTH_FRAMES EQU 45
DEF BJTILE_TITLE_LOGO      EQU $80 - 1 ; logo.2bpp's tile 1 at $80
; Meowth's box has a card's top corners; two sprites cover them in the felt's plain green, the
; right one the left one flipped. Their tile follows the felt's copy in vTiles0.
DEF BJTILE_TITLE_CORNER    EQU BJTILE_TITLE_FELT + BJ_TITLE_TILES
	assert BJTILE_TITLE_CORNER < $80, "the corner sprites' tile is below the logo's"
	assert BJ_TITLE_START_Y < BJ_TITLE_LABEL_Y && BJ_TITLE_LABEL_Y < BJ_TITLE_DECK_Y && \
		BJ_TITLE_DECK_Y < SCREEN_HEIGHT, "the text's lines in order, on the screen"
DEF BJ_TITLE_PAL_FELT     EQU 0
DEF BJ_TITLE_PAL_LOGO     EQU 1 ; the sidebar's
; in WRAM bank 6's scratch: the tiles to send (on a 16-byte boundary, for GDMA), the felt's
; pattern, each text cell's pixels row by row (the letters', then the shadow's), and a line's
; letters being drawn, row by row, a spare byte on each row's end
DEF BJ_TITLE_TILE_BUFFER EQUS "wDecompressScratch"
DEF BJ_TITLE_TEXTURE     EQUS "(wDecompressScratch + $300)"
DEF BJ_TITLE_MASKS       EQUS "(wDecompressScratch + $480)"
DEF BJ_TITLE_LINE_INK    EQUS "(wDecompressScratch + $600)"
DEF BJ_TITLE_LINE_STRIDE EQU BJ_TITLE_DECK_CELLS + 1
	assert BJ_TITLE_TILES tiles <= $300 && \
		BJ_TITLE_TEXTURE_PIXEL_ROWS * BJ_TITLE_TEXTURE_ROW <= $180 && \
		BJ_TITLE_TEXT_CELLS * TILE_HEIGHT * 2 <= $180 && \
		TILE_HEIGHT * BJ_TITLE_LINE_STRIDE <= $100, "the title's scratch doesn't overlap"
	assert BJ_TITLE_DECK_LENGTH + 1 <= wBlackjackTitleLineEnd - wBlackjackTitleLine, \
		"the deck's line fits wBlackjackTitleLine"
	assert NUM_BJ_DECKS <= 4, "the deck last picked fits two event flags"
	assert BJ_DECK_FRENCH == 0, "the title falls back on deck 0, the one always unlocked"

; The bottom bar: (A) and its word at the left, (B) and its word from the middle
DEF BJ_A_LABEL_X EQU 1
DEF BJ_B_LABEL_X EQU SCREEN_WIDTH / 2 + 1
; Betting: the prompt, centred above the bet menu, both centred on the empty table
; Reshuffling the shoe: a riffle of deal sounds under the message, then a pause
DEF BJ_RIFFLE_SOUNDS  EQU 6
DEF BJ_RIFFLE_FRAMES  EQU 4
DEF BJ_SHUFFLE_PAUSE  EQU 30

; Blackjack_AskHitOrStand
	const_def
	const BJ_HIT
	const BJ_STAND

; What the bottom bar shows (wBlackjackBar): nothing, or (A) and (B) labels (BlackjackBarLabels)
	const_def
	const BJBAR_NONE     ; nothing to press
	const BJBAR_DEAL     ; the bet window
	const BJBAR_HIT      ; your turn
	const BJBAR_BET      ; after a result, or "Not enough coins."
	const BJBAR_YES_NO   ; "Leave the table?"
DEF NUM_BJBARS EQU const_value

; What Meowth does (wBlackjackMeowth; BlackjackMeowthStates)
	const_def
	const MEOWTH_STILL     ; while cards are dealt, the dealer's turn, and after a push
	const MEOWTH_IDLE      ; while the player decides: the bet window, and hit or stand
	const MEOWTH_CHEER     ; a win
	const MEOWTH_BIG_CHEER ; blackjack
	const MEOWTH_SLUMP     ; a loss
DEF NUM_MEOWTH_STATES EQU const_value

_Blackjack:
	ld hl, wOptions
	set NO_TEXT_SCROLL, [hl]
	call Blackjack_Title
	jmp c, .leave
	call ClearTilemap
	call ClearSprites
	call DelayFrame
	call DisableLCD
	call LoadStandardFont
	call LoadFontsExtra

	ld hl, BlackjackCardPartsGFX
	ld de, vTiles2 tile BJTILE_RANKS
	ld bc, BJ_NUM_CARD_PART_TILES tiles
	rst CopyBytes
	ld hl, BlackjackFeltGFX
	ld de, vTiles2 tile BJTILE_FELT
	ld bc, BJ_FELT_PNG_TILES tiles
	rst CopyBytes
; the dealer's side: the same tiles with colours 0 and 1 swapped, by flipping the low plane wherever
; the high plane is clear
	ld hl, BlackjackFeltGFX
	ld de, vTiles2 tile (BJTILE_FELT + BJ_FELT_DEALER)
	ld b, BJ_FELT_PNG_TILES * TILE_HEIGHT
.dealer_felt
	ld a, [hli]
	ld c, a
	ld a, [hl]
	cpl
	xor c
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .dealer_felt
	ld hl, BlackjackButtonsGFX
	ld de, vTiles2 tile BJTILE_BUTTON_A
	ld bc, BJ_NUM_BUTTON_TILES tiles
	rst CopyBytes
	ld hl, BlackjackPlusGFX
	ld de, vTiles2 tile BJTILE_PLUS
	ld bc, 1 tiles
	rst CopyBytes

	call Blackjack_LoadPalettes
	ld a, [wBlackjackTitleDeck]
	call Blackjack_LoadDeck
	call Blackjack_MakeSlidingCards
	ld hl, BlackjackCornerJobs
	ld c, NUM_BJ_CORNER_JOBS
	call Blackjack_CornerJobs
	ld hl, BlackjackCornerSpritesGFX
	ld de, vTiles0 tile BJ_CORNER_SPRITES
	ld bc, 2 tiles
	rst CopyBytes
; the sidebar's own tiles, in VRAM bank 1, and the card corners on the felt
	ld a, 1
	ldh [rVBK], a
	ld hl, BlackjackSidebarGFX
	ld de, vTiles2 tile BJTILE1_SHEET
	ld bc, BlackjackSidebarGFXEnd - BlackjackSidebarGFX
	rst CopyBytes
	ld hl, BlackjackMeowthGFX
	ld de, vTiles1 tile (BJTILE1_MEOWTH - $80)
	ld bc, BlackjackMeowthGFXEnd - BlackjackMeowthGFX
	rst CopyBytes
	ld hl, BlackjackFeltCornerJobs
	ld c, NUM_BJ_FELT_CORNER_JOBS
	call Blackjack_CornerJobs
	call Blackjack_BackCorners
	xor a
	ldh [rVBK], a
	dec a
	ld [wBlackjackMeowthFrame], a ; none yet
	ld [wBlackjackMeowthLastState], a ; so the first state starts its animation from the top

	call Blackjack_ShuffleShoe
	ld a, 1
	ld [wBlackjackBetChoice], a
	assert MEOWTH_STILL == 0
	xor a
	ld [wBlackjackMeowth], a
	ld [wBlackjackSidebarWhite], a
	ld [wBlackjackSidebarNudgeX], a
	ld [wBlackjackSidebarNudgeY], a
	call Blackjack_NewHand
	call Blackjack_DrawTable
	call Blackjack_SaveRegion
	call EnableLCD
	call WaitBGMap2
	ld a, %11100100
	call DmgToCgbBGPals
	lb de, %11100100, %11100100
	call DmgToCgbObjPals
	call DelayFrame

.loop
	call Blackjack_PlayHand
	jr nc, .loop

.leave
	call ClearSprites ; the corners'
	call WaitSFX
	ld de, SFX_QUIT_SLOTS
	call PlaySFX
	call WaitSFX
	call ClearBGPalettes
	call RestartMapMusic
	ld hl, wOptions
	res NO_TEXT_SCROLL, [hl]
	ret

Blackjack_Title:
; The title screen, with Ronald's theme, which carries on at the table. Left and Right change the
; deck, A or START plays it (wBlackjackTitleDeck), and B returns carry to leave.
	call ClearBGPalettes
	call ClearTilemap
	call ClearSprites
	ld de, MUSIC_NONE
	call PlayMusic
	call DelayFrame
	call DisableLCD
	call Blackjack_TitleSavedDeck
	ld hl, BlackjackTitleLogoGFX
	ld de, vTiles1 tile (BJTILE_TITLE_LOGO + 1 - $80)
	ld bc, BlackjackTitleLogoGFXEnd - BlackjackTitleLogoGFX
	rst CopyBytes
	ld hl, BlackjackCornerSpritesGFX + 1 tiles ; your side's: the corner's pixels in colour 2
	ld de, vTiles0 tile BJTILE_TITLE_CORNER
	ld bc, 1 tiles
	rst CopyBytes
	ld hl, BlackjackTitleCornerOAM
	ld de, wShadowOAM
	ld bc, BlackjackTitleCornerOAMEnd - BlackjackTitleCornerOAM
	rst CopyBytes
	xor a
	ld [wBlackjackTitleShift], a
	ld [wBlackjackTitleSet], a
	ld [wBlackjackTitleMeowth], a
	ld a, BJ_TITLE_STEP_FRAMES
	ld [wBlackjackTitleClock], a
	ld a, BJ_TITLE_MEOWTH_FRAMES
	ld [wBlackjackTitleMeowthClock], a
	ld hl, BlackjackTitleStartText
	lb bc, BJ_TITLE_START_CELLS, BJ_TITLE_START_CELL
	ld d, BJ_TITLE_START_X
	call Blackjack_TitleLine
	ld hl, BlackjackTitleLabelText
	lb bc, BJ_TITLE_LABEL_CELLS, BJ_TITLE_LABEL_CELL
	ld d, BJ_TITLE_LABEL_X
	call Blackjack_TitleLine
	call Blackjack_TitleDeckLine
	ldh a, [rWBK]
	push af
	ld a, BANK(wDecompressScratch)
	ldh [rWBK], a
	call Blackjack_TitleTexture
	call Blackjack_TitleBuild
; both copies the same to start with
	ld hl, BJ_TITLE_TILE_BUFFER
	ld de, vTiles2 tile BJTILE_TITLE_FELT
	ld bc, BJ_TITLE_TILES tiles
	rst CopyBytes
	ld hl, BJ_TITLE_TILE_BUFFER
	ld de, vTiles0 tile BJTILE_TITLE_FELT
	ld bc, BJ_TITLE_TILES tiles
	rst CopyBytes
	pop af
	ldh [rWBK], a
	call Blackjack_TitleTilemap
	call Blackjack_TitlePalettes
	call EnableLCD
	call WaitBGMap2
	xor a
	ldh [hBGMapMode], a
	ld a, %11100100
	call DmgToCgbBGPals
	lb de, %11100100, %11100100
	call DmgToCgbObjPals
	call DelayFrame
	ld de, MUSIC_TCG_RONALD
	call PlayMusic

.loop
	xor a
	ldh [hBGMapMode], a ; Meowth's cells, if they changed, went over in the last VBlank
	call JoyTextDelay
	ldh a, [hJoyLast]
	and PAD_A | PAD_START
	jr nz, .play
	ldh a, [hJoyLast]
	bit B_PAD_B, a
	jr nz, .leave
	ld c, 1
	bit B_PAD_RIGHT, a
	jr nz, .change
	ld c, -1
	bit B_PAD_LEFT, a
	jr z, .wait
.change
	call Blackjack_TitleChangeDeck
.wait
	call Blackjack_TitleMeowthTick
	ld hl, wBlackjackTitleClock
	dec [hl]
	jr z, .step
	call DelayFrame
	jr .loop

.step
	ld [hl], BJ_TITLE_STEP_FRAMES
	call Blackjack_TitleStep
	jr .loop

.play
	call Blackjack_TitleSaveDeck
	call .Close
	and a
	ret

.leave
	call .Close
	scf
	ret

.Close:
; The tiles in vTiles2 again, as everything else expects, once the screen is white
	call ClearBGPalettes
	ldh a, [rLCDC]
	res B_LCDC_BLOCKS, a
	ldh [rLCDC], a
	ret

Blackjack_TitleStep:
; Move the felt a pixel left and a pixel down, with the text over it, into the copy of the tiles
; not on screen, then show that copy from the start of the next VBlank.
	ldh a, [rWBK]
	push af
	ld a, BANK(wDecompressScratch)
	ldh [rWBK], a
	call Blackjack_TitleTurn
	call Blackjack_TitleBuild
	ld a, [wBlackjackTitleSet]
	and a
	ld hl, vTiles0 tile BJTILE_TITLE_FELT
	jr z, .got_copy
	ld hl, vTiles2 tile BJTILE_TITLE_FELT
.got_copy
	ld de, BJ_TITLE_TILE_BUFFER
	lb bc, BANK(@), BJ_TITLE_TILES
	call Get2bpp
	pop af
	ldh [rWBK], a
	di
.wait
	ldh a, [rLY]
	cp SCREEN_HEIGHT_PX
	jr nz, .wait
	ldh a, [rLCDC]
	xor LCDC_BLOCKS
	ldh [rLCDC], a
	ei
	ld hl, wBlackjackTitleSet
	ld a, [hl]
	xor 1
	ld [hl], a
	ret

Blackjack_TitleMeowthTick:
; Once a frame: every BJ_TITLE_MEOWTH_FRAMES, Meowth's other frame into the tilemap, to go over
; whole in the next VBlank with the tilemap's top third, which holds Meowth.
	ld hl, wBlackjackTitleMeowthClock
	dec [hl]
	ret nz
	ld [hl], BJ_TITLE_MEOWTH_FRAMES
	ld hl, wBlackjackTitleMeowth
	ld a, [hl]
	xor 1
	ld [hl], a
	call Blackjack_TitlePlaceMeowth
	xor a
	ldh [hBGMapThird], a
	inc a
	ldh [hBGMapMode], a
	ret

Blackjack_TitlePlaceMeowth:
; Meowth's frame wBlackjackTitleMeowth, on top of the sign, from logo.tilemap
	ld a, [wBlackjackTitleMeowth]
	ld hl, BlackjackTitleMeowthTilemaps
	ld bc, BJ_TITLE_MEOWTH_TILES
	rst AddNTimes
	ld d, h
	ld e, l
	hlcoord BJ_TITLE_MEOWTH_X, BJ_TITLE_MEOWTH_Y
	lb bc, BJ_TITLE_MEOWTH_HEIGHT, BJ_TITLE_MEOWTH_WIDTH
	ld a, BJTILE_TITLE_LOGO
	jmp Blackjack_PlaceTilemap

Blackjack_TitleTexture:
; The felt's pattern into BJ_TITLE_TEXTURE, from felt.png's tiles, with WRAM bank 6 in.
	ld hl, BlackjackTitlePatternTiles
	ld de, BJ_TITLE_TEXTURE
	ld b, BJ_TITLE_TEXTURE_HEIGHT
.tile_row
	ld c, BJ_TITLE_TEXTURE_WIDTH
.tile
	push bc
	push hl
	push de
	ld a, [hl]
	ld hl, BlackjackFeltGFX
	ld bc, 1 tiles
	rst AddNTimes
	ld b, TILE_HEIGHT
.pixel_row
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ld a, e
	add BJ_TITLE_TEXTURE_ROW - 1
	ld e, a
	adc d
	sub e
	ld d, a
	dec b
	jr nz, .pixel_row
	pop de
	inc de
	inc de
	pop hl
	inc hl
	pop bc
	dec c
	jr nz, .tile
; on to the next row of tiles, from the end of this one's first pixel row
	ld a, e
	add LOW((TILE_HEIGHT - 1) * BJ_TITLE_TEXTURE_ROW)
	ld e, a
	adc d
	sub e
	ld d, a
	dec b
	jr nz, .tile_row
	ret

Blackjack_TitleTurn:
; Turn the felt's pattern a pixel left, round to the right edge, and count it a pixel further down.
	ld hl, BJ_TITLE_TEXTURE
	ld b, BJ_TITLE_TEXTURE_PIXEL_ROWS
.row
	call .Plane
	inc hl
	call .Plane
	ld de, BJ_TITLE_TEXTURE_ROW - 1
	add hl, de
	dec b
	jr nz, .row
	ld hl, wBlackjackTitleShift
	ld a, [hl]
	inc a
	and BJ_TITLE_TEXTURE_PIXEL_ROWS - 1
	ld [hl], a
	ret

.Plane:
; The plane of the row starting at hl: its first byte's top bit goes round to its last byte's bottom
	push hl
	ld a, [hl]
	ld de, BJ_TITLE_TEXTURE_ROW - 2
	add hl, de
	add a
	ld c, BJ_TITLE_TEXTURE_WIDTH
.byte
	rl [hl]
	dec hl
	dec hl
	dec c
	jr nz, .byte
	pop hl
	ret

Blackjack_TitleBuild:
; The felt's tiles from its pattern, moved wBlackjackTitleShift pixels down, then the text's tiles
; over them, into BJ_TITLE_TILE_BUFFER, with WRAM bank 6 in.
	ld de, BJ_TITLE_TILE_BUFFER
	ld a, [wBlackjackTitleShift]
	cpl
	inc a
	and BJ_TITLE_TEXTURE_PIXEL_ROWS - 1 ; the pattern's row at the top of the screen
	ld b, BJ_TITLE_TEXTURE_HEIGHT
.tile_row
	push bc
	ld c, 0 ; the column's first byte in a pixel row
.tile
	push af
	push bc
	call .Tile
	pop bc
	pop af
	inc c
	inc c
	ld h, a
	ld a, c
	cp BJ_TITLE_TEXTURE_ROW
	ld a, h
	jr c, .tile
	add TILE_HEIGHT
	and BJ_TITLE_TEXTURE_PIXEL_ROWS - 1
	pop bc
	dec b
	jr nz, .tile_row

; each cell of text: the felt tile under it, the letters' pixels in colour 2 (white) and the
; shadow's in colour 3 (black)
	ld a, BJ_TITLE_TEXT_CELLS
	ld [wBlackjackTitleCount], a
	ld bc, BJ_TITLE_MASKS
	ld hl, BlackjackTitleCellFelt
.cell
	ld a, [hli]
	push hl
	swap a ; a tile's 16 bytes
	ld l, a
	and $f
	ld h, a
	xor l
	ld l, a
	push de
	ld de, BJ_TITLE_TILE_BUFFER
	add hl, de
	pop de
.cell_row
	ld a, [bc] ; the letters' pixels
	cpl
	and [hl] ; the felt's low plane without them
	inc bc
	push hl
	ld h, b
	ld l, c
	or [hl] ; with the shadow's
	ld [de], a
	inc de
	dec hl
	ld a, [hli]
	or [hl] ; letters or shadow: the high plane set
	inc hl
	ld b, h
	ld c, l ; the next row's
	pop hl
	inc hl
	or [hl]
	inc hl
	ld [de], a
	inc de
	ld a, e
	and (1 tiles) - 1
	jr nz, .cell_row
	ld hl, wBlackjackTitleCount
	dec [hl]
	pop hl
	jr nz, .cell
	ret

.Tile:
; A tile from column c of the pattern, starting at row a, to de
	push af
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	ld b, l
	add hl, hl
	ld a, l
	add b
	ld l, a
	adc h
	sub l
	ld h, a ; row * BJ_TITLE_TEXTURE_ROW
	ld a, l
	add c
	ld l, a
	adc h
	sub l
	ld h, a
	ld bc, BJ_TITLE_TEXTURE
	add hl, bc
	pop af
	ld c, a ; the row
	ld b, TILE_HEIGHT
.pixel_row
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hld]
	ld [de], a
	inc de
; the pattern's next row, round from its bottom to its top
	inc c
	ld a, c
	cp BJ_TITLE_TEXTURE_PIXEL_ROWS
	push bc
	ld bc, BJ_TITLE_TEXTURE_ROW
	jr c, .next_row
	ld bc, BJ_TITLE_TEXTURE_ROW - BJ_TITLE_TEXTURE_PIXEL_ROWS * BJ_TITLE_TEXTURE_ROW
.next_row
	add hl, bc
	pop bc
	and BJ_TITLE_TEXTURE_PIXEL_ROWS - 1
	ld c, a
	dec b
	jr nz, .pixel_row
	ret

Blackjack_TitleDeckLine:
; The deck's name between "◀ " and " ▶". It's on screen only while more than one deck is unlocked.
	ld de, wBlackjackTitleLine
	ld a, "◀"
	ld [de], a
	inc de
	ld a, " "
	ld [de], a
	inc de
	ld a, [wBlackjackTitleDeck]
	ld hl, BlackjackDeckNames
	ld c, a
	ld b, 0
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
.copy
	ld a, [hli]
	cp "@"
	jr z, .copied
	ld [de], a
	inc de
	jr .copy

.copied
	ld a, " "
	ld [de], a
	inc de
	ld a, "▶"
	ld [de], a
	inc de
	ld a, "@"
	ld [de], a
	ld hl, wBlackjackTitleLine
	lb bc, BJ_TITLE_DECK_CELLS, BJ_TITLE_DECK_CELL
	ld d, BJ_TITLE_DECK_X
; fallthrough
Blackjack_TitleLine:
; The text at hl, centred on the screen to the pixel, into b cells from cell c, which start at
; column d: each cell's pixels into BJ_TITLE_MASKS, row by row, the letters' then the shadow's.
	ldh a, [rWBK]
	push af
	ld a, BANK(wDecompressScratch)
	ldh [rWBK], a
	push bc
	push hl
	push de
	ld hl, BJ_TITLE_LINE_INK
	ld bc, TILE_HEIGHT * BJ_TITLE_LINE_STRIDE
	xor a
	rst ByteFill
	pop de
	pop hl
	push hl
	ld e, 0
.count
	ld a, [hli]
	cp "@"
	jr z, .counted
	inc e
	jr .count

.counted
	pop hl
; the first character's pixel in the cells: half the screen, less half the line, less the cells'
; own start
	ld a, d
	add a
	add a
	add a
	ld d, a
	ld a, e
	add a ; BJ_SMALL_WIDTH / 2 a character
	add d
	cpl
	inc a
	add SCREEN_WIDTH_PX / 2
	ld [wBlackjackTitleCount], a
.char
	ld a, [hli]
	cp "@"
	jr z, .cells
	push hl
	call Blackjack_TitleGlyph
	ld hl, wBlackjackTitleCount
	ld a, [hl]
	add BJ_SMALL_WIDTH
	ld [hl], a
	pop hl
	jr .char

.cells
	pop bc
	ld l, c
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, BJ_TITLE_MASKS
	add hl, de
	ld d, h
	ld e, l
	ld c, 0 ; the cell's column of bytes
.cell
	push bc
	ld b, 0 ; the row
.row
	call .Ink
	ld [de], a
	inc de
	call .Shadow
	ld [de], a
	inc de
	inc b
	ld a, b
	cp TILE_HEIGHT
	jr nz, .row
	pop bc
	inc c
	ld a, c
	cp b
	jr nz, .cell
	pop af
	ldh [rWBK], a
	ret

.Shadow:
; Row b, column c's shadow: the letters a pixel up and left of each pixel, where there are no
; letters. Keeps bc and de.
	ld a, b
	and a
	ret z
	push de
	dec b
	call .Ink
	srl a
	ld d, a
	ld a, c
	and a
	jr z, .first_column
	dec hl
	ld a, [hl] ; the column before's last pixel
	rrca
	and %10000000
	or d
	ld d, a
.first_column
	inc b
	call .Ink
	cpl
	and d
	pop de
	ret

.Ink:
; a = the letters in row b, column c, at hl
	ld a, b
	add a
	add a
	add a
	add b ; times BJ_TITLE_LINE_STRIDE
	add c
	add LOW(BJ_TITLE_LINE_INK)
	ld l, a
	adc HIGH(BJ_TITLE_LINE_INK)
	sub l
	ld h, a
	ld a, [hl]
	ret

	assert BJ_TITLE_LINE_STRIDE == 9, "Blackjack_TitleLine.Ink multiplies by 9"

Blackjack_TitleGlyph:
; Character a in the small font, drawn into BJ_TITLE_LINE_INK from pixel wBlackjackTitleCount. "◀" is
; its "▶" mirrored.
	ld d, 0
	cp "◀"
	jr nz, .got_char
	inc d ; mirrored
	ld a, "▶"
.got_char
	push de
	call Blackjack_SidebarText.Glyph
	pop de
	ld e, a ; the character: even on a tile's left half, odd on its right
	srl a
	add a
	add a
	add a
	ld c, a
	ld b, 0
	ld hl, BlackjackSmallFontGFX
	add hl, bc
	ld a, [wBlackjackTitleCount]
	ld c, a ; the pixel
	ld b, 0 ; the row
.row
	push hl
	push bc
	push de
	ld a, [hl]
	bit 0, e
	jr z, .left_half
	swap a
.left_half
	and $f0
	bit 0, d
	call nz, .Mirror
; across two bytes from the pixel
	ld d, a
	ld e, 0
	ld a, c
	and TILE_WIDTH - 1
	jr z, .placed
.shift
	srl d
	rr e
	dec a
	jr nz, .shift
.placed
	ld a, c
	rrca
	rrca
	rrca
	and %00011111 ; the byte
	ld l, a
	ld a, b
	add a
	add a
	add a
	add b ; times BJ_TITLE_LINE_STRIDE
	add l
	add LOW(BJ_TITLE_LINE_INK)
	ld l, a
	adc HIGH(BJ_TITLE_LINE_INK)
	sub l
	ld h, a
	ld a, [hl]
	or d
	ld [hli], a
	ld a, [hl]
	or e
	ld [hl], a
	pop de
	pop bc
	pop hl
	inc hl
	inc b
	ld a, b
	cp TILE_HEIGHT
	jr nz, .row
	ret

.Mirror:
; The character's three columns the other way round: its first and third swap
	ld d, a
	and %01000000
	bit 7, d
	jr z, .no_first
	or %00100000
.no_first
	bit 5, d
	ret z
	or %10000000
	ret

Blackjack_TitleTilemap:
; The felt's tiles in their 6x4 pattern over the whole screen, then the text's cells and the logo.
	hlcoord 0, 0
	ld b, 0
.row
	ld a, b
	and BJ_TITLE_TEXTURE_HEIGHT - 1
	ld c, a
	add a
	add c
	add a ; times BJ_TITLE_TEXTURE_WIDTH
	add BJTILE_TITLE_FELT
	ld e, a
	ld d, 0 ; the column in the pattern
	ld c, SCREEN_WIDTH
.column
	ld a, e
	add d
	ld [hli], a
	inc d
	ld a, d
	cp BJ_TITLE_TEXTURE_WIDTH
	jr c, .next
	ld d, 0
.next
	dec c
	jr nz, .column
	inc b
	ld a, b
	cp SCREEN_HEIGHT
	jr c, .row

	hlcoord BJ_TITLE_START_X, BJ_TITLE_START_Y
	lb bc, 1, BJ_TITLE_START_CELLS
	ld a, BJTILE_TITLE_TEXT + BJ_TITLE_START_CELL
	call .Box
; the deck's label and name only while there's another deck to pick: with one, just the felt
	call Blackjack_MoreThanOneDeck
	jr z, .logo
	hlcoord BJ_TITLE_LABEL_X, BJ_TITLE_LABEL_Y
	lb bc, 1, BJ_TITLE_LABEL_CELLS
	ld a, BJTILE_TITLE_TEXT + BJ_TITLE_LABEL_CELL
	call .Box
	hlcoord BJ_TITLE_DECK_X, BJ_TITLE_DECK_Y
	lb bc, 1, BJ_TITLE_DECK_CELLS
	ld a, BJTILE_TITLE_TEXT + BJ_TITLE_DECK_CELL
	call .Box
.logo
	ld de, BlackjackTitleSignTilemap
	hlcoord BJ_TITLE_SIGN_X, BJ_TITLE_SIGN_Y
	lb bc, BJ_TITLE_SIGN_HEIGHT, BJ_TITLE_SIGN_WIDTH
	ld a, BJTILE_TITLE_LOGO
	call Blackjack_PlaceTilemap
	call Blackjack_TitlePlaceMeowth

	hlcoord 0, 0, wAttrmap
	ld bc, SCREEN_WIDTH * SCREEN_HEIGHT
	ld a, BJ_TITLE_PAL_FELT
	rst ByteFill
	hlcoord BJ_TITLE_SIGN_X, BJ_TITLE_SIGN_Y, wAttrmap
	lb bc, BJ_TITLE_SIGN_HEIGHT, BJ_TITLE_SIGN_WIDTH
	ld a, BJ_TITLE_PAL_LOGO
	call FillBoxWithByte
	hlcoord BJ_TITLE_MEOWTH_X, BJ_TITLE_MEOWTH_Y, wAttrmap
	lb bc, BJ_TITLE_MEOWTH_HEIGHT, BJ_TITLE_MEOWTH_WIDTH
	ld a, BJ_TITLE_PAL_LOGO
	jmp FillBoxWithByte

.Box:
; b rows of c tiles at hl, numbered on from a, row by row
	ld de, SCREEN_WIDTH
.box_row
	push bc
	push hl
.box_tile
	ld [hli], a
	inc a
	dec c
	jr nz, .box_tile
	pop hl
	add hl, de
	pop bc
	dec b
	jr nz, .box_row
	ret

Blackjack_TitlePalettes:
; The felt in your side's greens, white for the text, and the sidebar's for the logo.
	ldh a, [rWBK]
	push af
	ld a, BANK(wBGPals1)
	ldh [rWBK], a
	ld hl, BlackjackPalettes ; the felt's, first
	ld de, wBGPals1 palette BJ_TITLE_PAL_FELT
	ld bc, 2 * 2
	rst CopyBytes
	ld hl, BlackjackTitleTextColours
	ld bc, 2 * 2
	rst CopyBytes
	assert BJ_TITLE_PAL_LOGO == BJ_TITLE_PAL_FELT + 1
	ld hl, BlackjackPalettes + (BJPAL_SIDEBAR - BJPAL_FELT) palettes
	ld bc, 1 palettes
	rst CopyBytes
; the corner sprites' colours 1 and 2 are the felt's two greens, as at the table; the title's
; felt is your side's, so its plain green is colour 2
	ld hl, BlackjackPalettes
	ld de, wOBPals1 palette BJPAL_FELT + 1 * 2
	ld bc, 2 * 2
	rst CopyBytes
	pop af
	ldh [rWBK], a
	ret

Blackjack_TitleChangeDeck:
; The next unlocked deck the way c points (1 right, -1 left), round past either end.
	ld a, [wBlackjackTitleDeck]
	ld b, a
.next
	add c
	cp NUM_BJ_DECKS
	jr c, .in_range
	xor a ; past the last deck: the first
	bit 7, c
	jr z, .in_range
	ld a, NUM_BJ_DECKS - 1
.in_range
	cp b
	ret z ; round to where it started: no other deck is unlocked
	push af
	push bc
	call Blackjack_IsDeckUnlocked
	pop bc
	jr nz, .found
	pop af
	jr .next

.found
	pop af
	ld [wBlackjackTitleDeck], a
	jmp Blackjack_TitleDeckLine

Blackjack_MoreThanOneDeck:
; Return nz if more than one deck is unlocked. Keeps de.
	push de
	ld c, 0
	xor a
.deck
	push af
	push bc
	call Blackjack_IsDeckUnlocked
	pop bc
	jr z, .locked
	inc c
.locked
	pop af
	inc a
	cp NUM_BJ_DECKS
	jr c, .deck
	pop de
	ld a, c
	cp 2
	ccf
	sbc a
	ret

Blackjack_IsDeckUnlocked:
; Return nz if deck a is unlocked.
	ld hl, BlackjackDeckUnlocks
	ld e, a
	ld d, 0
	add hl, de
	add hl, de
	ld a, [hli]
	ld e, a
	ld d, [hl]
	and d
	inc a
	jr z, .always
	ld b, CHECK_FLAG
	call EventFlagAction
	and a
	ret

.always
	inc a
	ret

Blackjack_TitleSavedDeck:
; The deck last picked, from its two event flags, or deck 0 if it isn't unlocked.
	ld de, EVENT_BLACKJACK_DECK_BIT_1
	ld b, CHECK_FLAG
	call EventFlagAction
	jr z, .no_two
	ld a, 2
.no_two
	push af
	ld de, EVENT_BLACKJACK_DECK_BIT_0
	ld b, CHECK_FLAG
	call EventFlagAction
	pop bc
	ld a, b
	jr z, .no_one
	inc a
.no_one
	ld [wBlackjackTitleDeck], a
	cp NUM_BJ_DECKS
	jr nc, .first
	call Blackjack_IsDeckUnlocked
	ret nz
.first
	xor a
	ld [wBlackjackTitleDeck], a
	ret

Blackjack_TitleSaveDeck:
; The deck picked into its two event flags.
	assert RESET_FLAG == 0 && SET_FLAG == 1
	ld a, [wBlackjackTitleDeck]
	push af
	and 1
	ld b, a
	ld de, EVENT_BLACKJACK_DECK_BIT_0
	call EventFlagAction
	pop af
	srl a
	and 1
	ld b, a
	ld de, EVENT_BLACKJACK_DECK_BIT_1
	jmp EventFlagAction

Blackjack_LoadPalettes:
; The felt's and the text's; the deck's go in around them.
	ldh a, [rWBK]
	push af
	ld a, BANK(wBGPals1)
	ldh [rWBK], a
	ld hl, BlackjackPalettes
	ld de, wBGPals1 palette BJPAL_FELT
	ld bc, NUM_BJ_PALETTES palettes
	rst CopyBytes
; the corner sprites' colours 1 and 2 are the felt's two greens
	ld hl, BlackjackPalettes
	ld de, wOBPals1 palette BJPAL_FELT + 1 * 2
	ld bc, 2 * 2
	rst CopyBytes
	pop af
	ldh [rWBK], a
	ret

Blackjack_LoadDeck:
; Deck a: its suits, pictures and back into vTiles2, with the LCD off, and its palettes into
; wBGPals1.
	ld hl, BlackjackDecks
	ld bc, BJ_DECK_ENTRY_SIZE
	rst AddNTimes
	ld de, vTiles2 tile BJTILE_SUITS
	ld bc, BLACKJACK_NUM_SUITS tiles
	call .Copy
	ld de, vTiles2 tile BJTILE_PICTURES
	ld bc, BLACKJACK_NUM_SUITS * BJ_PICTURE_TILES tiles
	call .Copy
	ld de, vTiles2 tile BJTILE_BACK
	ld bc, BJ_BACK_TILES tiles
	call .Copy
	ldh a, [rWBK]
	push af
	ld a, BANK(wBGPals1)
	ldh [rWBK], a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
	ld de, wBGPals1
	ld bc, BLACKJACK_NUM_SUITS palettes
	rst CopyBytes
; the felt's colours 2 and 3 are the cards' white and black, for the card corners on the felt
	ld a, [wBGPals1 + 0 * 2]
	ld [wBGPals1 palette BJPAL_FELT + 2 * 2], a
	ld a, [wBGPals1 + 0 * 2 + 1]
	ld [wBGPals1 palette BJPAL_FELT + 2 * 2 + 1], a
	ld a, [wBGPals1 + 3 * 2]
	ld [wBGPals1 palette BJPAL_FELT + 3 * 2], a
	ld a, [wBGPals1 + 3 * 2 + 1]
	ld [wBGPals1 palette BJPAL_FELT + 3 * 2 + 1], a
	ld de, wBGPals1 palette BJPAL_BACK
	ld bc, 1 palettes ; the first back colour, until one can be picked
	rst CopyBytes
; a back leaves its colour 2 to the dealer's green, for its corners on the felt
	ld a, [BlackjackPalettes + 0 * 2]
	ld [wBGPals1 palette BJPAL_BACK + 2 * 2], a
	ld a, [BlackjackPalettes + 0 * 2 + 1]
	ld [wBGPals1 palette BJPAL_BACK + 2 * 2 + 1], a
	pop hl
	ld de, wOBPals1
	ld c, BLACKJACK_NUM_SUITS
	call Blackjack_SlidingPalettes
	ld de, wOBPals1 palette BJPAL_BACK
	ld c, 1
	call Blackjack_SlidingPalettes
	pop af
	ldh [rWBK], a
	ret

.Copy:
; Copy bc bytes to de from where the pointer at hl points, and move hl on to the next pointer.
	ld a, [hli]
	push hl
	ld h, [hl]
	ld l, a
	rst CopyBytes
	pop hl
	inc hl
	ret

Blackjack_SlidingPalettes:
; Copy c card palettes from hl to de as sprite palettes for sliding cards, where colour 0 is
; see-through: 1 is the card's white, 2 its colour, 3 its black, and its grey shows as white.
	push bc
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	call .Put ; colour 0, unseen
	call .Put ; white
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	call .Put ; the card's colour
	inc hl
	inc hl ; grey
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	call .Put ; black
	pop bc
	dec c
	jr nz, Blackjack_SlidingPalettes
	ret

.Put:
	ld a, c
	ld [de], a
	inc de
	ld a, b
	ld [de], a
	inc de
	ret

Blackjack_MakeSlidingCards:
; With the LCD off, copy the card tiles from vTiles2 to the same tile numbers in vTiles0 for the
; sliding cards' sprites, with their colours moved to match Blackjack_SlidingPalettes: white (0)
; to 1, the card's colour (1) to 2, grey (2) to 1, black stays 3. Each row of pixels: the new low
; plane is the old low plane's inverse or'd with the high plane, and the new high plane is the old
; low plane.
	ld hl, vTiles2 tile BJTILE_RANKS
	ld de, vTiles0 tile BJTILE_RANKS
	ld bc, BJ_NUM_CARD_TILES * TILE_HEIGHT
.loop
	push bc
	ld a, [hli]
	ld b, a
	cpl
	or [hl]
	inc hl
	ld [de], a
	inc de
	ld a, b
	ld [de], a
	inc de
	pop bc
	dec bc
	ld a, b
	or c
	jr nz, .loop
	ret

Blackjack_CornerJobs:
; Do the c jobs at hl (BlackjackCornerJobs): copy a tile, then change its corner pixels in place.
; With the LCD off, so VRAM can be read and written at any time.
.loop
	push bc
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a ; from
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a ; to
	push hl
	push de
	ld h, b
	ld l, c
	ld bc, 1 tiles
	rst CopyBytes
	pop de
	pop hl
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a ; the corner's pixels, row by row
	ld a, [hli]
	push hl
	ld h, [hl]
	ld l, a
	call _hl_
	pop hl
	inc hl
	pop bc
	dec c
	jr nz, .loop
	ret

; How a corner job changes the tile at de: bc points to the corner's pixels for each row.

Blackjack_BlackCorner:
; Those pixels black (colour 3), the outline of the card behind.
	ld h, d
	ld l, e
	ld e, TILE_HEIGHT
.row
	ld a, [bc]
	inc bc
	ld d, a
	or [hl]
	ld [hli], a
	ld a, d
	or [hl]
	ld [hli], a
	dec e
	jr nz, .row
	ret

Blackjack_BackCorners:
; The deck's back's top right and bottom right on the dealer's felt, in VRAM bank 1: its own tiles,
; the pixels outside the card in colour 2. With the LCD off.
	ld a, [wBlackjackTitleDeck]
	ld hl, BlackjackDecks + 2 * 2 ; the back's graphics
	ld bc, BJ_DECK_ENTRY_SIZE
	rst AddNTimes
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
	ld bc, (BJ_CARD_WIDTH - 1) tiles
	add hl, bc
	ld de, vTiles2 tile BJTILE1_BACK_CORNERS
	ld bc, BlackjackCornerPixels.TopRight
	call .Corner
	pop hl
	ld bc, (BJ_BACK_TILES - 1) tiles
	add hl, bc
	ld de, vTiles2 tile (BJTILE1_BACK_CORNERS + 1)
	ld bc, BlackjackCornerPixels.BottomRight
.Corner:
	push bc
	push de
	ld bc, 1 tiles
	rst CopyBytes
	pop de
	pop bc
; fallthrough
Blackjack_Colour2Corner:
; Those pixels colour 2: the felt's green, in the back's palette.
	ld h, d
	ld l, e
	ld e, TILE_HEIGHT
.row
	ld a, [bc]
	inc bc
	ld d, a
	cpl
	and [hl]
	ld [hli], a
	ld a, [hl]
	or d
	ld [hli], a
	dec e
	jr nz, .row
	ret

Blackjack_ClearCorner:
; Those pixels see-through (colour 0), for a sliding card's sprites.
	ld h, d
	ld l, e
	ld e, TILE_HEIGHT
.row
	ld a, [bc]
	inc bc
	cpl
	ld d, a
	and [hl]
	ld [hli], a
	ld a, d
	and [hl]
	ld [hli], a
	dec e
	jr nz, .row
	ret

Blackjack_DealerFeltCorner:
; In the felt's palette: the card's white (0) to colour 2, its grey (2) and black (3) to 3, and those pixels to
; the dealer's side's green (0).
	ld h, d
	ld l, e
	ld e, TILE_HEIGHT
.row
	ld a, [bc]
	inc bc
	cpl
	ld d, a
	inc hl
	ld a, [hld]
	and d
	ld [hli], a
	ld a, d
	ld [hli], a
	dec e
	jr nz, .row
	ret

Blackjack_YourFeltCorner:
; The same, with those pixels your side's green (1).
	ld h, d
	ld l, e
	ld e, TILE_HEIGHT
.row
	ld a, [bc]
	inc bc
	ld d, a
	inc hl
	ld a, [hld]
	or d
	ld [hli], a
	ld a, d
	cpl
	ld [hli], a
	dec e
	jr nz, .row
	ret

BlackjackCornerJobs:
; from, to, the corner's pixels, how; in VRAM bank 0, once the deck and the sliding cards are in
; the overlap copies
for bj_suit, BLACKJACK_NUM_SUITS
	dw vTiles2 tile (BJTILE_SUITS + bj_suit), vTiles2 tile (BJTILE_OVERLAP + bj_suit), BlackjackCornerPixels.TopLeftEdge, Blackjack_BlackCorner
endr
	dw vTiles2 tile BJTILE_BACK, vTiles2 tile BJTILE_OVERLAP_BACK, BlackjackCornerPixels.TopLeftEdge, Blackjack_BlackCorner
	dw vTiles2 tile BJTILE_BOTTOM_LEFT, vTiles2 tile BJTILE_OVERLAP_BOTTOM_LEFT, BlackjackCornerPixels.BottomLeftEdge, Blackjack_BlackCorner
	dw vTiles2 tile (BJTILE_BACK + BJ_CARD_WIDTH * (BJ_CARD_HEIGHT - 1)), vTiles2 tile BJTILE_OVERLAP_BACK_BOTTOM_LEFT, BlackjackCornerPixels.BottomLeftEdge, Blackjack_BlackCorner
; a sliding card's corners, see-through
for bj_suit, BLACKJACK_NUM_SUITS
	dw vTiles0 tile (BJTILE_SUITS + bj_suit), vTiles0 tile (BJTILE_SUITS + bj_suit), BlackjackCornerPixels.TopLeft, Blackjack_ClearCorner
endr
	dw vTiles0 tile (BJTILE_TOP + 1), vTiles0 tile (BJTILE_TOP + 1), BlackjackCornerPixels.TopRight, Blackjack_ClearCorner
	dw vTiles0 tile BJTILE_BOTTOM_LEFT, vTiles0 tile BJTILE_BOTTOM_LEFT, BlackjackCornerPixels.BottomLeft, Blackjack_ClearCorner
	dw vTiles0 tile (BJTILE_BOTTOM_LEFT + 2), vTiles0 tile (BJTILE_BOTTOM_LEFT + 2), BlackjackCornerPixels.BottomRight, Blackjack_ClearCorner
	dw vTiles0 tile BJTILE_BACK, vTiles0 tile BJTILE_BACK, BlackjackCornerPixels.TopLeft, Blackjack_ClearCorner
	dw vTiles0 tile (BJTILE_BACK + BJ_CARD_WIDTH - 1), vTiles0 tile (BJTILE_BACK + BJ_CARD_WIDTH - 1), BlackjackCornerPixels.TopRight, Blackjack_ClearCorner
	dw vTiles0 tile (BJTILE_BACK + BJ_CARD_WIDTH * (BJ_CARD_HEIGHT - 1)), vTiles0 tile (BJTILE_BACK + BJ_CARD_WIDTH * (BJ_CARD_HEIGHT - 1)), BlackjackCornerPixels.BottomLeft, Blackjack_ClearCorner
	dw vTiles0 tile (BJTILE_BACK + BJ_BACK_TILES - 1), vTiles0 tile (BJTILE_BACK + BJ_BACK_TILES - 1), BlackjackCornerPixels.BottomRight, Blackjack_ClearCorner
DEF NUM_BJ_CORNER_JOBS EQU (@ - BlackjackCornerJobs) / 8

BlackjackFeltCornerJobs:
; in VRAM bank 1: the card corners on the felt, from card_parts.png (the back's corners are the same)
	dw BlackjackCardPartsGFX + (BJTILE_BOTTOM_LEFT - BJTILE_RANKS) tiles, vTiles2 tile BJTILE1_FELT_CORNERS, BlackjackCornerPixels.BottomLeft, Blackjack_YourFeltCorner
	dw BlackjackCardPartsGFX + (BJTILE_TOP + 1 - BJTILE_RANKS) tiles, vTiles2 tile (BJTILE1_FELT_CORNERS + 1), BlackjackCornerPixels.TopRight, Blackjack_YourFeltCorner
	dw BlackjackCardPartsGFX + (BJTILE_BOTTOM_LEFT + 2 - BJTILE_RANKS) tiles, vTiles2 tile (BJTILE1_FELT_CORNERS + 2), BlackjackCornerPixels.BottomRight, Blackjack_YourFeltCorner
	dw BlackjackCardPartsGFX + (BJTILE_BOTTOM_LEFT - BJTILE_RANKS) tiles, vTiles2 tile (BJTILE1_FELT_CORNERS + BJ_DEALER_CORNERS), BlackjackCornerPixels.BottomLeft, Blackjack_DealerFeltCorner
	dw BlackjackCardPartsGFX + (BJTILE_TOP + 1 - BJTILE_RANKS) tiles, vTiles2 tile (BJTILE1_FELT_CORNERS + BJ_DEALER_CORNERS + 1), BlackjackCornerPixels.TopRight, Blackjack_DealerFeltCorner
	dw BlackjackCardPartsGFX + (BJTILE_BOTTOM_LEFT + 2 - BJTILE_RANKS) tiles, vTiles2 tile (BJTILE1_FELT_CORNERS + BJ_DEALER_CORNERS + 2), BlackjackCornerPixels.BottomRight, Blackjack_DealerFeltCorner
DEF NUM_BJ_FELT_CORNER_JOBS EQU (@ - BlackjackFeltCornerJobs) / 8
	assert NUM_BJ_FELT_CORNER_JOBS == BJ_DEALER_CORNERS * 2

BlackjackCornerPixels:
; each corner's pixels outside the card, row by row
.TopLeft:     db BJ_CORNER_LEFT_EDGE, BJ_CORNER_LEFT_NEXT, 0, 0, 0, 0, 0, 0
.TopRight:    db BJ_CORNER_RIGHT_EDGE, BJ_CORNER_RIGHT_NEXT, 0, 0, 0, 0, 0, 0
.BottomLeft:  db 0, 0, 0, 0, 0, 0, BJ_CORNER_LEFT_NEXT, BJ_CORNER_LEFT_EDGE
.BottomRight: db 0, 0, 0, 0, 0, 0, BJ_CORNER_RIGHT_NEXT, BJ_CORNER_RIGHT_EDGE
; only those on the edge row, where the card behind has its outline
.TopLeftEdge:    db BJ_CORNER_LEFT_EDGE, 0, 0, 0, 0, 0, 0, 0
.BottomLeftEdge: db 0, 0, 0, 0, 0, 0, 0, BJ_CORNER_LEFT_EDGE

BlackjackCornerSpritesGFX:
; the top left corner's pixels outside the card: the dealer's side's in colour 1, yours in colour 2
	db BJ_CORNER_LEFT_EDGE, 0, BJ_CORNER_LEFT_NEXT, 0
	ds (TILE_HEIGHT - 2) * 2, 0
	db 0, BJ_CORNER_LEFT_EDGE, 0, BJ_CORNER_LEFT_NEXT
	ds (TILE_HEIGHT - 2) * 2, 0

Blackjack_PlaceCorners:
; The corner sprites, on the top left corner of each hand's first card, or hidden with no cards.
	ld a, TRUE
	ldh [hOAMUpdate], a
	ld hl, wShadowOAM + BJ_CORNER_OAM * OBJ_SIZE
	ld a, [wBlackjackDealerCount]
	lb bc, BJ_DEALER_ROW, BJ_CORNER_SPRITES
	call .Place
	ld a, [wBlackjackPlayerCount]
	lb bc, BJ_PLAYER_ROW, BJ_CORNER_SPRITES + 1
	call .Place
	xor a
	ldh [hOAMUpdate], a
	ret

.Place:
; a cards, on row b; c: the sprite's tile
	and a
	jr z, .hide
	ld a, b
	add a
	add a
	add a
	add OAM_Y_OFS
	ld [hli], a
	ld a, BJ_HAND_X * TILE_WIDTH + OAM_X_OFS
	ld [hli], a
	ld a, c
	ld [hli], a
	ld a, BJPAL_FELT
	ld [hli], a
	ret

.hide
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ret

Blackjack_HideYourCorner:
; The message box covers your hand's top row, and with it your corner sprite.
	assert BJ_DEALER_ROW < BJ_BOX_TOP && \
		BJ_BOX_TOP <= BJ_PLAYER_ROW && BJ_PLAYER_ROW < BJ_BOX_TOP + BJ_BOX_HEIGHT, \
		"the message box covers your first card's top left corner, not the dealer's"
	xor a
	ld [wShadowOAM + (BJ_CORNER_OAM + 1) * OBJ_SIZE + OAMA_Y], a
	ret

Blackjack_HideSlidingCard:
	ld a, TRUE
	ldh [hOAMUpdate], a
	ld hl, wShadowOAM
	ld bc, BJ_CORNER_OAM * OBJ_SIZE
	xor a
	rst ByteFill
	xor a
	ldh [hOAMUpdate], a
	ret

Blackjack_NewHand:
	xor a
	ld [wBlackjackPlayerCount], a
	ld [wBlackjackDealerCount], a
	ld [wBlackjackBet], a
	assert BJBAR_NONE == 0
	ld [wBlackjackBar], a
	ld a, TRUE
	ld [wBlackjackHoleHidden], a
	ret

Blackjack_PlayHand:
; Play one hand. Return carry if the player leaves the table.
	call Blackjack_NewHand
	ld a, [wBlackjackDeckPos]
	cp BLACKJACK_SHOE_CUT
	call nc, Blackjack_ReshuffleShoe
.ask_bet
	call Blackjack_AskBet
	ret c
	ld b, a
	ld a, [wCoins]
	and a
	jr nz, .enough_coins
	ld a, [wCoins + 1]
	cp b
	jr nc, .enough_coins
	ld de, SFX_WRONG
	call PlaySFX
	ld a, BJBAR_BET
	ld [wBlackjackBar], a
	ld hl, BlackjackNotEnoughCoinsText
	call Blackjack_PrintText
	call WaitSFX
	ld hl, BlackjackNotEnoughCoinsText
	call Blackjack_AskNextHand
	ret c
	jr .ask_bet

.enough_coins
	ld a, b
	ld [wBlackjackBet], a
	assert BJBAR_NONE == 0
	xor a
	ld [wBlackjackBar], a
	assert MEOWTH_STILL == 0
	ld [wBlackjackMeowth], a
	call Blackjack_Refresh
	call Blackjack_TakeBet
	call WaitSFX

	call Blackjack_DealPlayer
	call Blackjack_DealDealer
	call Blackjack_DealPlayer
	call Blackjack_DealDealer

; Naturals: the dealer looks at the hole card at once.
	call Blackjack_PlayerTotal
	cp BLACKJACK_BLACKJACK
	jr nz, .no_player_blackjack
	call Blackjack_RevealHole
	call Blackjack_DealerTotal
	cp BLACKJACK_BLACKJACK
	jr z, .push
	jr .blackjack

.no_player_blackjack
	call Blackjack_DealerTotal
	cp BLACKJACK_BLACKJACK
	jr nz, .player_turn
	call Blackjack_RevealHole
	ld hl, BlackjackDealerBlackjackText
	jr .lose

.player_turn
	call Blackjack_PlayerTotal
	cp BLACKJACK_BLACKJACK
	jr nc, .stand
	call Blackjack_AskHitOrStand
	assert BJ_HIT == 0
	and a
	jr nz, .stand

; hit
	call Blackjack_DealPlayer
	call Blackjack_PlayerTotal
	cp BLACKJACK_BLACKJACK + 1
	jr c, .player_turn
	call Blackjack_RevealHole
	ld hl, BlackjackPlayerBustText
	jr .lose

.stand
	call Blackjack_RevealHole
.dealer_turn
	call Blackjack_DealerTotal
	cp BLACKJACK_DEALER_STANDS
	jr nc, .dealer_stands
	call Blackjack_DealDealer
	jr .dealer_turn

.dealer_stands
	cp BLACKJACK_BLACKJACK + 1
	jr nc, .dealer_bust
	ld d, a ; Blackjack_PlayerTotal keeps d
	call Blackjack_PlayerTotal
	cp d
	jr z, .push
	jr c, .lose_on_totals
	ld hl, BlackjackWinText
	jr .win

.dealer_bust
	ld hl, BlackjackDealerBustText
.win
	ld a, MEOWTH_CHEER
	ld [wBlackjackMeowth], a
	ld a, [wBlackjackBet]
	ld [wBlackjackWinnings], a
	add a
	jr .pay

.blackjack
	ld a, MEOWTH_BIG_CHEER
	ld [wBlackjackMeowth], a
; 3:2; bets are even
	ld a, [wBlackjackBet]
	ld b, a
	srl a
	add b
	ld [wBlackjackWinnings], a
	add b
	ld hl, BlackjackBlackjackText
	jr .pay

.push
	assert MEOWTH_STILL == 0
	xor a
	ld [wBlackjackMeowth], a
	ld a, [wBlackjackBet]
	ld hl, BlackjackPushText
	jr .pay

.lose_on_totals
	ld hl, BlackjackLoseText
.lose
	ld a, MEOWTH_SLUMP
	ld [wBlackjackMeowth], a
	xor a
.pay
	ld [wBlackjackPayout], a
	push hl
	call Blackjack_PrintText
	call Blackjack_PayOut
	pop hl
; fallthrough
Blackjack_AskNextHand:
; The text at hl is up. (A) BET returns nc; (B) LEAVE asks "Leave the table?": return carry on YES,
; else put the text at hl back and keep waiting.
	push hl
	ld a, BJBAR_BET
	call Blackjack_ShowBar
	pop hl
.loop
	push hl
	call Blackjack_AnimateMeowth
	call JoyTextDelay
	pop hl
	ldh a, [hJoyLast]
	bit B_PAD_A, a
	jr nz, .bet
	bit B_PAD_B, a
	jr z, .loop
	push hl
	call Blackjack_AskLeave
	pop hl
	ret c
	ld a, BJBAR_BET
	ld [wBlackjackBar], a
	push hl
	call Blackjack_PrintText
	pop hl
	jr .loop

.bet
	and a
	ret

Blackjack_TakeBet:
; Take the bet: one sound, then COIN counts down a coin at a time, silently.
	ld de, SFX_TRANSACTION
	call PlaySFX
	ld a, 1
	ldh [hBGMapMode], a
	ld a, [wBlackjackBet]
	ld c, a
.loop
	push bc
	ld hl, wCoins + 1
	ld a, [hl]
	dec [hl]
	and a
	jr nz, .took
	dec hl
	dec [hl]
.took
	call Blackjack_UpdateCoins
	call DelayFrame
	pop bc
	dec c
	jr nz, .loop
	ret

Blackjack_PayOut:
; Hand back wBlackjackPayout coins one at a time, stopping at MAX_COINS.
	ld a, [wBlackjackPayout]
	and a
	ret z
	ld c, a
.loop
	push bc
	call Blackjack_IsCoinCaseFull
	jr c, .full
	ld hl, wCoins + 1
	inc [hl]
	jr nz, .added
	dec hl
	inc [hl]
.added
	ld de, SFX_PAY_DAY
	call PlaySFX
.full
	call Blackjack_UpdateCoins
; Meowth's next frame is looked for around each wait, so its quick steps keep their length while
; coins count
	call Blackjack_AnimateMeowth
	call DelayFrame
	call Blackjack_AnimateMeowth
	pop bc
	dec c
	jr nz, .loop
	ret

Blackjack_IsCoinCaseFull:
; Return carry if the player has MAX_COINS.
	ld a, [wCoins]
	cp HIGH(MAX_COINS)
	jr c, .not_full
	jr nz, .full
	ld a, [wCoins + 1]
	cp LOW(MAX_COINS)
	jr c, .not_full
.full
	scf
	ret

.not_full
	and a
	ret

Blackjack_AskBet:
; The bet menu in the sidebar, with Meowth idling: A picks the bet under the cursor, which starts
; on the bet last picked; B asks "Leave the table?". Return the bet in a, or carry if the player
; leaves.
	ld a, BJBAR_DEAL
	ld [wBlackjackBar], a
	ld a, MEOWTH_IDLE
	ld [wBlackjackMeowth], a
	ld a, [wBlackjackBetChoice]
	ld [wMenuCursorY], a
	call Blackjack_DrawBetMenu
	call Blackjack_Refresh
.loop
	call Blackjack_AnimateMeowth
	call JoyTextDelay
	ldh a, [hJoyLast]
	bit B_PAD_A, a
	jr nz, .bet
	bit B_PAD_B, a
	jr nz, .leave
	ld hl, wMenuCursorY
	bit B_PAD_UP, a
	jr nz, .up
	bit B_PAD_DOWN, a
	jr z, .loop
	ld a, [hl]
	cp NUM_BLACKJACK_BETS
	jr nc, .loop
	inc [hl]
	jr .moved

.up
	ld a, [hl]
	dec a
	jr z, .loop
	ld [hl], a
.moved
	call Blackjack_DrawBetMenu
	jr .loop

.bet
	call PlayClickSFX
	ld a, [wMenuCursorY]
	ld [wBlackjackBetChoice], a
	add LOW(BlackjackBets - 1)
	ld l, a
	adc HIGH(BlackjackBets - 1)
	sub l
	ld h, a
	ld a, [hl]
	and a
	ret

.leave
	call PlayClickSFX
	call Blackjack_AskLeave
	jr nc, Blackjack_AskBet
	ret

Blackjack_DrawBetMenu:
; The bet menu's rows over the sidebar's art: the cursor beside the bet in wMenuCursorY, then the
; amount, right-aligned.
	ld hl, wBlackjackSidebarTiles
	call Blackjack_SetSidebarDest
	ld de, BlackjackBets
	ld c, 1
.item
	push bc
	push de
; PrintNum leaves the places before a number as they are, so blank the whole row first
	ld hl, wBlackjackSidebarLine
	ld a, " "
rept BJ_MENU_TILES * 2
	ld [hli], a
endr
	ld a, [wMenuCursorY]
	cp c
	jr nz, .no_cursor
	ld a, "▶"
	ld [wBlackjackSidebarLine], a
.no_cursor
; PrintNum reads from another ROM bank, so the amount goes through WRAM
	ld a, [de]
	ld [wBlackjackSidebarValue], a
	ld de, wBlackjackSidebarValue
	ld hl, wBlackjackSidebarLine + 2
	lb bc, 1, BJ_SIDEBAR_DIGITS
	call PrintNum
; the art behind: this row's tiles from the cursor's column
	pop de
	pop bc
	push bc
	push de
	ld a, c
	dec a
	add BJ_MENU_Y
	ld hl, BlackjackSidebarTilemap + BJ_MENU_X - BJ_SIDEBAR_X
	ld bc, BJ_SIDEBAR_WIDTH
	rst AddNTimes
	ld b, BJ_MENU_TILES
	xor a
	ld [wBlackjackSidebarWhite], a
	call Blackjack_SidebarText
	pop de
	inc de
	pop bc
	inc c
	ld a, c
	cp NUM_BLACKJACK_BETS + 1
	jr nz, .item
; "BET?" above them
	ld hl, .Prompt
	ld de, wBlackjackSidebarLine
	ld bc, BJ_MENU_PROMPT_TILES * 2
	rst CopyBytes
	ld hl, BlackjackSidebarTilemap + BJ_MENU_PROMPT_Y * BJ_SIDEBAR_WIDTH
	ld b, BJ_MENU_PROMPT_TILES
	ld a, BJ_MENU_PROMPT_NUDGE_X
	ld [wBlackjackSidebarNudgeX], a
	call Blackjack_SidebarText
	ld hl, vTiles2 tile BJTILE1_MENU
	ld c, NUM_BLACKJACK_BETS * BJ_MENU_TILES + BJ_MENU_PROMPT_TILES
	jmp Blackjack_SendSidebarTiles

.Prompt:
	db "BET?"
	assert @ - .Prompt == BJ_MENU_PROMPT_TILES * 2

BlackjackBets:
	db 10, 50, 100
DEF NUM_BLACKJACK_BETS EQU @ - BlackjackBets

Blackjack_AskHitOrStand:
; A hits, B stands, with Meowth idling meanwhile. Return BJ_HIT or BJ_STAND in a; the bar goes
; blank and Meowth sits still.
	ld a, MEOWTH_IDLE
	ld [wBlackjackMeowth], a
	ld a, BJBAR_HIT
	call Blackjack_ShowBar
.loop
	call Blackjack_AnimateMeowth
	call JoyTextDelay
	ldh a, [hJoyLast]
	ld b, BJ_HIT
	bit B_PAD_A, a
	jr nz, .chose
	assert BJ_STAND == BJ_HIT + 1
	inc b
	bit B_PAD_B, a
	jr z, .loop
.chose
	push bc
	assert BJBAR_NONE == 0 && MEOWTH_STILL == 0
	xor a
	ld [wBlackjackMeowth], a
	call Blackjack_ShowBar
	call Blackjack_AnimateMeowth
	pop bc
	ld a, b
	ret

Blackjack_AskLeave:
; "Leave the table?" in the message box, with (A) YES (B) NO on the bar. Return carry on YES; after
; NO the caller puts its own bar and message back.
	ld a, BJBAR_YES_NO
	ld [wBlackjackBar], a
	ld hl, BlackjackLeaveText
	call Blackjack_PrintText
.loop
	call JoyTextDelay
	ldh a, [hJoyLast]
	bit B_PAD_A, a
	jr nz, .yes
	bit B_PAD_B, a
	jr z, .loop
	and a
	ret

.yes
	scf
	ret

Blackjack_ShowBar:
; Show bar a (BJBAR_*) on the bottom row, leaving the rest of the screen as it is.
	ld [wBlackjackBar], a
	hlcoord 0, SCREEN_HEIGHT - 1
	ld bc, SCREEN_WIDTH
	ld a, " "
	rst ByteFill
	ld a, [wBlackjackBar]
	call Blackjack_DrawBarLabels
	jmp WaitBGMap

Blackjack_DrawBarLabels:
; Bar a's (A) and (B) labels on the bottom row, if it has any.
	assert BJBAR_NONE == 0
	and a
	ret z
	dec a
	ld hl, BlackjackBarLabels
	ld bc, 2 * 2
	rst AddNTimes
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	push hl
	hlcoord BJ_A_LABEL_X, SCREEN_HEIGHT - 1
	ld a, BJTILE_BUTTON_A
	ld [hli], a
	rst PlaceString
	pop hl
	ld a, [hli]
	ld d, [hl]
	ld e, a
	hlcoord BJ_B_LABEL_X, SCREEN_HEIGHT - 1
	ld a, BJTILE_BUTTON_B
	ld [hli], a
	rst PlaceString
	ret

BlackjackBarLabels:
; (A)'s word and (B)'s, for each bar from BJBAR_DEAL
	table_width 2 * 2
	dw .Deal, .Leave ; BJBAR_DEAL
	dw .Hit, .Stand  ; BJBAR_HIT
	dw .Bet, .Leave  ; BJBAR_BET
	dw .Yes, .No     ; BJBAR_YES_NO
	assert_table_length NUM_BJBARS - 1

.Deal:  db " DEAL@"
.Hit:   db " HIT@"
.Bet:   db " BET@"
.Yes:   db " YES@"
.Leave: db " LEAVE@"
.Stand: db " STAND@"
.No:    db " NO@"
	assert BJ_A_LABEL_X + 1 + STRLEN(" DEAL") <= BJ_B_LABEL_X, "(A)'s words end before (B)"
	assert BJ_B_LABEL_X + 1 + STRLEN(" LEAVE") <= SCREEN_WIDTH - 1 && \
		BJ_B_LABEL_X + 1 + STRLEN(" STAND") <= SCREEN_WIDTH - 1, "(B)'s words fit on the bar"

Blackjack_PrintText:
; Redraw the table with the message box over the gap, then print the text at hl on the box's
; first line.
	push hl
	call Blackjack_DrawTable
	hlcoord 0, BJ_BOX_TOP
	lb bc, BJ_BOX_HEIGHT - 2, SCREEN_WIDTH - 2
	call Textbox
	call Blackjack_HideYourCorner
	call Blackjack_ShowScreen
	ld a, 1
	ldh [hBGMapMode], a
	pop hl
	bccoord BJ_MESSAGE_X, BJ_MESSAGE_ROW
	call PrintTextboxTextAt
; the message's letters over the sidebar are what's on screen there now
	jmp Blackjack_SaveRegion

Blackjack_ReshuffleShoe:
; Past the cut card: "Shuffling the shoe." with a riffle of deal sounds, then a fresh shoe.
	call Blackjack_ShuffleShoe
	assert BJBAR_NONE == 0
	xor a
	ld [wBlackjackBar], a
	ld hl, BlackjackShufflingText
	call Blackjack_PrintText
	ld b, BJ_RIFFLE_SOUNDS
.riffle
	push bc
	ld de, SFX_DEAL_CARD
	call PlaySFX
	ld c, BJ_RIFFLE_FRAMES
	call DelayFrames
	pop bc
	dec b
	jr nz, .riffle
	ld c, BJ_SHUFFLE_PAUSE
	jmp DelayFrames

Blackjack_ShuffleShoe:
; Fresh decks in the shoe, then a Fisher-Yates shuffle.
	ld hl, wBlackjackDeck
	ld d, BLACKJACK_SHOE_DECKS
.deck
	ld b, 0
.suit
	ld c, 1
.rank
	ld a, b
	or c
	ld [hli], a
	inc c
	ld a, c
	cp BLACKJACK_NUM_RANKS + 1
	jr nz, .rank
	ld a, b
	add 1 << 4
	ld b, a
	cp BLACKJACK_NUM_SUITS << 4
	jr nz, .suit
	dec d
	jr nz, .deck

	ld c, BLACKJACK_SHOE_SIZE - 1
.shuffle
; swap card c with a random card from 0 to c
	ld a, c
	inc a
	call RandomRange
	add LOW(wBlackjackDeck)
	ld l, a
	adc HIGH(wBlackjackDeck)
	sub l
	ld h, a
	ld a, c
	add LOW(wBlackjackDeck)
	ld e, a
	adc HIGH(wBlackjackDeck)
	sub e
	ld d, a
	ld a, [de]
	ld b, [hl]
	ld [hl], a
	ld a, b
	ld [de], a
	dec c
	jr nz, .shuffle
	xor a
	ld [wBlackjackDeckPos], a
	ret

Blackjack_DealPlayer:
	ld hl, wBlackjackPlayerCount
	ld de, wBlackjackPlayerHand
	ld b, BJ_PLAYER_ROW
	jr Blackjack_Deal

Blackjack_DealDealer:
	ld hl, wBlackjackDealerCount
	ld de, wBlackjackDealerHand
	ld b, BJ_DEALER_ROW
; fallthrough
Blackjack_Deal:
; Put the next card of the deck at the end of the hand at de, whose count is at hl, sliding it in
; to its spot in the hand on row b.
	ld a, [hl]
	inc [hl]
	ld c, a ; its place in the hand
	add e
	ld e, a
	adc d
	sub e
	ld d, a
	ld hl, wBlackjackDeckPos
	ld a, [hl]
	inc [hl]
	add LOW(wBlackjackDeck)
	ld l, a
	adc HIGH(wBlackjackDeck)
	sub l
	ld h, a
	ld a, [hl]
	ld [de], a
	ld e, a
; the dealer's second card is face down while the hole is hidden
	ld a, b
	cp BJ_DEALER_ROW
	jr nz, .face_up
	ld a, c
	dec a
	jr nz, .face_up
	ld a, [wBlackjackHoleHidden]
	and a
	jr z, .face_up
	ld e, BLACKJACK_FACE_DOWN
.face_up
; its column, as Blackjack_DrawHand places it
	ld a, c
	cp BJ_MAX_SHOWN
	jr c, .shown
	ld a, BJ_MAX_SHOWN - 1
.shown
	add a
	add BJ_HAND_X
	ld c, a
	push de
	push bc
	ld de, SFX_DEAL_CARD
	call PlaySFX
	pop bc
	pop de
	ld a, e
	call Blackjack_SlideCard
	call Blackjack_Refresh
	call Blackjack_HideSlidingCard
	ld c, BJ_DEAL_FRAMES
	jmp DelayFrames

Blackjack_SlideCard:
; Slide card a in as sprites from behind the sidebar to tile column c, row b, over
; BJ_SLIDE_FRAMES frames, stepping each way by whole pixels along a straight line. The sprites are
; the copies Blackjack_MakeSlidingCards made, so a card's tile numbers serve for them too.
	push bc
	call Blackjack_GetCardTiles
	ld [wBlackjackSlidePalette], a
	pop bc
	ld a, c
	add a
	add a
	add a
	cpl
	inc a
	add BJ_SLIDE_START_X
	ld [wBlackjackSlideDistX], a
	ld a, b
	add a
	add a
	add a
	sub BJ_SLIDE_START_Y
	ld [wBlackjackSlideDistY], a
	xor a
	ld [wBlackjackSlideAccX], a
	ld [wBlackjackSlideAccY], a
	ld a, BJ_SLIDE_START_X
	ld [wBlackjackSlideX], a
	ld a, LOW(BJ_SLIDE_START_Y)
	ld [wBlackjackSlideY], a
	ld c, BJ_SLIDE_FRAMES
.frame
	push bc
	ld hl, wBlackjackSlideAccX
	ld a, [wBlackjackSlideDistX]
	call .Step
	ld a, [wBlackjackSlideX]
	sub b
	ld [wBlackjackSlideX], a
	ld hl, wBlackjackSlideAccY
	ld a, [wBlackjackSlideDistY]
	call .Step
	ld a, [wBlackjackSlideY]
	add b
	ld [wBlackjackSlideY], a
	call Blackjack_PlaceSlidingCard
	call DelayFrame
	pop bc
	dec c
	jr nz, .frame
	ret

.Step:
; Add a to the fraction at hl; return in b the whole pixels that makes, each one BJ_SLIDE_FRAMES.
	add [hl]
	ld b, 0
.step
	cp BJ_SLIDE_FRAMES
	jr c, .stepped
	sub BJ_SLIDE_FRAMES
	inc b
	jr .step

.stepped
	ld [hl], a
	ret

Blackjack_PlaceSlidingCard:
; The sliding card's 24 sprites at wBlackjackSlideX, wBlackjackSlideY.
	ld a, TRUE
	ldh [hOAMUpdate], a
	ld hl, wShadowOAM
	ld de, wBlackjackCardTiles
	ld a, [wBlackjackSlideY]
	add OAM_Y_OFS
	ld c, a ; y
	ld a, BJ_CARD_HEIGHT
.row
	push af
	ld a, [wBlackjackSlideX]
	add OAM_X_OFS
	ld b, a ; x
	ld a, BJ_CARD_WIDTH
.col
	push af
	ld a, c
	ld [hli], a
	ld a, b
	ld [hli], a
	add TILE_WIDTH
	ld b, a
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [wBlackjackSlidePalette]
	ld [hli], a
	pop af
	dec a
	jr nz, .col
	ld a, c
	add TILE_HEIGHT
	ld c, a
	pop af
	dec a
	jr nz, .row
	xor a
	ldh [hOAMUpdate], a
	ret

Blackjack_RevealHole:
	ld hl, wBlackjackHoleHidden
	ld a, [hl]
	and a
	ret z
	ld [hl], FALSE
	call Blackjack_Refresh
	ld c, BJ_DEAL_FRAMES
	jmp DelayFrames

Blackjack_PlayerTotal:
	ld hl, wBlackjackPlayerHand
	ld a, [wBlackjackPlayerCount]
	ld c, a
	jr Blackjack_HandTotal

Blackjack_DealerTotal:
; The hole card counts, face down or not.
	ld hl, wBlackjackDealerHand
	ld a, [wBlackjackDealerCount]
	ld c, a
; fallthrough
Blackjack_HandTotal:
; Return in a the total of the c cards at hl. An ace counts 11 unless that busts the hand.
; Keeps d.
	ld a, c
	and a
	ret z
	ld b, 0
	ld e, b
.loop
	ld a, [hli]
	and $f
	cp 10
	jr c, .not_ten
	ld a, 10
.not_ten
	dec a
	jr nz, .not_ace
	ld e, TRUE
.not_ace
	inc a
	add b
	ld b, a
	dec c
	jr nz, .loop
	ld a, e
	and a
	ld a, b
	ret z
	cp BLACKJACK_BLACKJACK - 10 + 1
	ret nc
	add 10
	ret

Blackjack_Refresh:
	call Blackjack_DrawTable
; fallthrough
Blackjack_ShowScreen:
; Send the tilemap and its attributes to the screen. CopyTilemapAtOnce sends the attributes, then
; the tiles, across a frame; where the message box meets the sidebar, a cell caught between the two
; would show the box's tiles from VRAM bank 1 or the sidebar's from bank 0. So those cells stay as
; they are on screen for that copy, and then go over together in VBlank.
	ldh a, [hBGMapMode]
	push af
	xor a
	ldh [hBGMapMode], a
	call Blackjack_SwapRegion
	call CopyTilemapAtOnce
	call Blackjack_SwapRegion
	call Blackjack_SendRegion
	call Blackjack_SaveRegion
	pop af
	ldh [hBGMapMode], a
	ret

Blackjack_SaveRegion:
; Keep the cells where the message box meets the sidebar, as they are about to be on screen.
	ld de, wBlackjackRegion
	ld b, FALSE
	jr Blackjack_RegionCells

Blackjack_SwapRegion:
; Exchange those cells with the ones kept.
	ld de, wBlackjackRegion
	ld b, TRUE
; fallthrough
Blackjack_RegionCells:
; Copy the region's tiles, then its attributes, to de, or with b TRUE exchange them with de.
	hlcoord BJ_SIDEBAR_X, BJ_BOX_TOP
	call .Map
	hlcoord BJ_SIDEBAR_X, BJ_BOX_TOP, wAttrmap
.Map:
	ld c, BJ_BOX_HEIGHT
.row
	push hl
	push bc
	ld c, BJ_SIDEBAR_WIDTH
.cell
	ld a, [de]
	push af
	ld a, [hl]
	ld [de], a
	pop af
	inc de
	bit 0, b
	jr z, .kept
	ld [hl], a
.kept
	inc hl
	dec c
	jr nz, .cell
	pop bc
	pop hl
	push de
	ld de, SCREEN_WIDTH
	add hl, de
	pop de
	dec c
	jr nz, .row
	ret

Blackjack_SendRegion:
; Write those cells' attributes and tiles straight to the BG map, all in one VBlank.
	di
.wait
	ldh a, [rLY]
	cp SCREEN_HEIGHT_PX
	jr nz, .wait
	ld a, 1
	ldh [rVBK], a
	hlcoord BJ_SIDEBAR_X, BJ_BOX_TOP, wAttrmap
	call .Copy
	xor a
	ldh [rVBK], a
	hlcoord BJ_SIDEBAR_X, BJ_BOX_TOP
	call .Copy
	reti

.Copy:
	ldh a, [hBGMapAddress + 1]
	ld d, a
	ld e, 0
	push hl
	ld hl, BJ_BOX_TOP * TILEMAP_WIDTH + BJ_SIDEBAR_X
	add hl, de
	ld d, h
	ld e, l
	pop hl
	ld b, BJ_BOX_HEIGHT
.row
	ld c, BJ_SIDEBAR_WIDTH
.cell
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .cell
	push bc
	ld bc, SCREEN_WIDTH - BJ_SIDEBAR_WIDTH
	add hl, bc
	ld a, e
	add TILEMAP_WIDTH - BJ_SIDEBAR_WIDTH
	ld e, a
	adc d
	sub e
	ld d, a
	pop bc
	dec b
	jr nz, .row
	ret

Blackjack_DrawTable:
; The whole screen: the felt, both hands, the sidebar and the bar along the bottom.
	xor a
	ldh [hBGMapMode], a

	hlcoord 0, BJ_FELT_TOP
	lb bc, BJ_FELT_HEIGHT, BJ_TABLE_WIDTH
	ld a, BJTILE_FELT_BLANK
	call FillBoxWithByte
; the patterns, band by band
	hlcoord 0, BJ_FELT_BANDS_TOP
	ld b, BJ_FELT_BANDS
	ld d, BJ_FELT_FIRST_X
.felt_band
	push hl
	push de
	ld a, d
	add l
	ld l, a
	adc h
	sub l
	ld h, a
	ld e, d ; the column
.felt_pattern
	ld a, BJTILE_FELT
	ld [hli], a
	inc a
	ld [hld], a
	ld a, l
	add SCREEN_WIDTH
	ld l, a
	adc h
	sub l
	ld h, a
	ld a, BJTILE_FELT + BJ_FELT_PNG_WIDTH
	ld [hli], a
	inc a
	ld [hl], a
; back up to the band's top row, at the next pattern's column
	ld a, l
	add LOW(BJ_FELT_SPACING - 1 - SCREEN_WIDTH)
	ld l, a
	ld a, h
	adc HIGH(BJ_FELT_SPACING - 1 - SCREEN_WIDTH)
	ld h, a
	ld a, e
	add BJ_FELT_SPACING
	ld e, a
	cp BJ_TABLE_WIDTH - 1 ; a pattern is two columns wide
	jr c, .felt_pattern
	pop de
	pop hl
; the next band: two rows down, from the other column
	ld a, l
	add SCREEN_WIDTH * 2
	ld l, a
	adc h
	sub l
	ld h, a
	ld a, BJ_FELT_FIRST_X + BJ_FELT_SECOND_X
	sub d
	ld d, a
	dec b
	jr nz, .felt_band
; the dealer's side in its own tiles
	hlcoord 0, BJ_FELT_TOP
	ld de, SCREEN_WIDTH - BJ_TABLE_WIDTH
	ld b, BJ_DEALER_FELT_HEIGHT
.dealer_row
	ld c, BJ_TABLE_WIDTH
.dealer_cell
	ld a, [hl]
	add BJ_FELT_DEALER
	ld [hli], a
	dec c
	jr nz, .dealer_cell
	add hl, de
	dec b
	jr nz, .dealer_row
	hlcoord 0, BJ_FELT_TOP, wAttrmap
	lb bc, BJ_FELT_HEIGHT, BJ_TABLE_WIDTH
	ld a, BJPAL_FELT
	call FillBoxWithByte

	call Blackjack_DrawSidebar
	hlcoord 0, SCREEN_HEIGHT - 1
	call .Bar
	ld a, [wBlackjackBar]
	call Blackjack_DrawBarLabels

	ld hl, wBlackjackDealerHand
	ld a, [wBlackjackDealerCount]
	ld c, a
	ld a, [wBlackjackHoleHidden]
	ld b, a
	decoord BJ_HAND_X, BJ_DEALER_ROW
	call Blackjack_DrawHand
	ld hl, wBlackjackPlayerHand
	ld a, [wBlackjackPlayerCount]
	ld c, a
	ld b, FALSE
	decoord BJ_HAND_X, BJ_PLAYER_ROW
	call Blackjack_DrawHand
	jmp Blackjack_PlaceCorners

.Bar:
; A blank white row at hl
	push hl
	ld bc, SCREEN_WIDTH
	ld a, " "
	rst ByteFill
	pop hl
	ld de, wAttrmap - wTilemap
	add hl, de
	ld bc, SCREEN_WIDTH
	ld a, PAL_BG_TEXT
	jmp ByteFill

Blackjack_DrawSidebar:
; The sidebar's tilemap: the owner's picture, with the totals' numbers over it and, while the bet
; menu is up, the menu; then Meowth, and the numbers drawn.
	hlcoord BJ_SIDEBAR_X, BJ_FELT_TOP, wAttrmap
	lb bc, BJ_FELT_HEIGHT, BJ_SIDEBAR_WIDTH
	ld a, BJ_SIDEBAR_ATTR
	call FillBoxWithByte
	hlcoord BJ_SIDEBAR_X, BJ_FELT_TOP
	ld de, BlackjackSidebarTilemap
	lb bc, BJ_SHEET_ROWS, BJ_SIDEBAR_WIDTH
	ld a, BJTILE1_SHEET
	call Blackjack_PlaceTilemap
	hlcoord BJ_SIDEBAR_X, BJ_COINS_Y
	ld a, BJTILE1_COINS
	lb bc, 1, BJ_SIDEBAR_WIDTH
	call .Block
	hlcoord BJ_YOU_X, BJ_TOTALS_Y
	ld a, BJTILE1_TOTALS
	lb bc, 1, BJ_TOTAL_TILES
	call .Block
	hlcoord BJ_THEM_X, BJ_TOTALS_Y
	ld a, BJTILE1_TOTALS + BJ_TOTAL_TILES
	lb bc, 1, BJ_TOTAL_TILES
	call .Block
	ld a, [wBlackjackBar]
	cp BJBAR_DEAL
	jr nz, .no_menu
	hlcoord BJ_MENU_X, BJ_MENU_Y
	ld a, BJTILE1_MENU
	lb bc, NUM_BLACKJACK_BETS, BJ_MENU_TILES
	call .Block
	hlcoord BJ_SIDEBAR_X, BJ_MENU_PROMPT_Y
	ld a, BJTILE1_PROMPT
	lb bc, 1, BJ_MENU_PROMPT_TILES
	call .Block
.no_menu
	call Blackjack_AnimateMeowth
	call Blackjack_PlaceMeowth
	jmp Blackjack_UpdateSidebar

.Block:
; b rows of c tiles at hl, numbered on from a
.row
	push bc
	push hl
.col
	ld [hli], a
	inc a
	dec c
	jr nz, .col
	pop hl
	ld de, SCREEN_WIDTH
	add hl, de
	pop bc
	dec b
	jr nz, .row
	ret

Blackjack_AnimateMeowth:
; Show Meowth's frame for now, from its state's animation: the time since the state began, in
; frames, runs through the animation's steps and round again. A new frame goes into the slot that
; isn't on screen, and then the tilemap moves over to it.
; the frames since the last call
	ldh a, [hVBlankCounter]
	ld hl, wBlackjackMeowthClock
	ld b, a
	sub [hl]
	ld [hl], b
	ld c, a
; a new state starts its animation from the top
	ld a, [wBlackjackMeowth]
	ld hl, wBlackjackMeowthLastState
	cp [hl]
	jr z, .same_state
	ld [hl], a
	xor a
	ld [wBlackjackMeowthTime], a
	ld c, a
.same_state
	ld a, [wBlackjackMeowth]
	add a
	add LOW(BlackjackMeowthAnimations)
	ld l, a
	adc HIGH(BlackjackMeowthAnimations)
	sub l
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wBlackjackMeowthTime]
	add c
	ld [wBlackjackMeowthTime], a
.restart
	push hl
.step
	ld b, a ; the time left
	ld a, [hli]
	cp -1
	jr z, .round_again
	ld d, a ; the step's frame
	ld a, [hli]
	ld e, a ; how long it stays up
	ld a, b
	sub e
	jr nc, .step
	pop hl
	ld b, d
	jr .got_frame

.round_again
; past the last step: take the animation's length off and start over
	pop hl
	ld a, b
	ld [wBlackjackMeowthTime], a
	jr .restart

.got_frame
	ld hl, wBlackjackMeowthFrame
	ld a, b
	cp [hl]
	ret z
	ld [hl], a
; fallthrough
Blackjack_PlaceMeowth:
; The frame on screen, from meowth.tilemap
	ld a, [wBlackjackMeowthFrame]
	ld hl, BlackjackMeowthTilemap
	ld bc, BJ_MEOWTH_TILES
	rst AddNTimes
	ld d, h
	ld e, l
	hlcoord BJ_MEOWTH_X, BJ_MEOWTH_Y
	lb bc, BJ_MEOWTH_SIZE, BJ_MEOWTH_SIZE
	ld a, BJTILE1_MEOWTH
; fallthrough
Blackjack_PlaceTilemap:
; b rows of c tiles at hl from the tilemap at de, each plus a
	push bc
	push hl
.tile
	push af
	ld a, [de]
	inc de
	ld b, a
	pop af
	push af
	add b
	ld [hli], a
	pop af
	dec c
	jr nz, .tile
	pop hl
	ld bc, SCREEN_WIDTH
	add hl, bc
	pop bc
	dec b
	jr nz, Blackjack_PlaceTilemap
	ret

BlackjackMeowthAnimations:
; Each state's animation in meowth.png's frames (idle 0-1, cheer 2-3, big cheer 4-5, slump 6):
; steps of a frame and how many frames it stays up, ending with -1, then round again
	table_width 2
	dw .Still     ; MEOWTH_STILL
	dw .Idle      ; MEOWTH_IDLE
	dw .Cheer     ; MEOWTH_CHEER
	dw .BigCheer  ; MEOWTH_BIG_CHEER
	dw .Slump     ; MEOWTH_SLUMP
	assert_table_length NUM_MEOWTH_STATES

.Still:
	db 0, 1
	db -1

.Idle:
; 1 1 2
	db 0, BJ_MEOWTH_STEP * 2
	db 1, BJ_MEOWTH_STEP
	db -1

.Cheer:
; a hop with idle's frames for the wind-up: idle 1 1, idle 2 2, happy 1, happy 2, happy 1
	db 0, BJ_MEOWTH_CHEER_STEP * 2 ; idle's first frame
	db 1, BJ_MEOWTH_CHEER_STEP * 2 ; idle's second: the wind-up
	db 2, BJ_MEOWTH_CHEER_STEP     ; up
	db 3, BJ_MEOWTH_CHEER_STEP     ; the top
	db 2, BJ_MEOWTH_CHEER_STEP     ; down
	db -1

.BigCheer:
; the cheer's hop with the very happy frames, quicker: idle 1 1, idle 2 2, very happy 1, 2, 1
	db 0, BJ_MEOWTH_BIG_CHEER_STEP * 2 ; idle's first frame
	db 1, BJ_MEOWTH_BIG_CHEER_STEP * 2 ; idle's second: the wind-up
	db 4, BJ_MEOWTH_BIG_CHEER_STEP     ; up
	db 5, BJ_MEOWTH_BIG_CHEER_STEP     ; the top
	db 4, BJ_MEOWTH_BIG_CHEER_STEP     ; down
	db -1

.Slump:
; one frame
	db 6, 1
	db -1

Blackjack_UpdateSidebar:
; Draw the numbers over the sidebar's art and send them to VRAM: the coin count, then YOU's total
; and THEM's (the face-up card while the hole is down), each blank until there are cards.
	ld hl, wBlackjackSidebarTiles
	call Blackjack_SetSidebarDest
	call Blackjack_SidebarCoins
	call Blackjack_PlayerTotal
	lb de, BJ_YOU_NUDGE_X, BJ_YOU_NUDGE_Y
	ld hl, BlackjackSidebarTilemap + BJ_TOTALS_Y * BJ_SIDEBAR_WIDTH + BJ_YOU_X - BJ_SIDEBAR_X
	call .Total
	call Blackjack_DealerShownTotal
	lb de, LOW(BJ_THEM_NUDGE_X), BJ_THEM_NUDGE_Y
	ld hl, BlackjackSidebarTilemap + BJ_TOTALS_Y * BJ_SIDEBAR_WIDTH + BJ_THEM_X - BJ_SIDEBAR_X
	call .Total
	ld hl, vTiles2 tile BJTILE1_COINS
	ld c, BJ_SIDEBAR_WIDTH + 2 * BJ_TOTAL_TILES
	jr Blackjack_SendSidebarTiles

.Total:
; the total a, blank if 0, centred over the art at hl, nudged d pixels right and e down
	ld b, a
	ld a, d
	ld [wBlackjackSidebarNudgeX], a
	ld a, e
	ld [wBlackjackSidebarNudgeY], a
	ld a, b
	ld [wBlackjackSidebarValue], a
	ld de, wBlackjackSidebarValue
	ld c, BJ_TOTAL_TILES * 2
	and a
	ld b, a
	jr z, Blackjack_SidebarCentred
	ld b, 1
	jr Blackjack_SidebarCentred

Blackjack_UpdateCoins:
; Just the coin count, while coins count.
	ld hl, wBlackjackSidebarTiles
	call Blackjack_SetSidebarDest
	call Blackjack_SidebarCoins
	ld hl, vTiles2 tile BJTILE1_COINS
	ld c, BJ_SIDEBAR_WIDTH
; fallthrough
Blackjack_SendSidebarTiles:
; Send the first c tiles drawn in wBlackjackSidebarTiles to VRAM bank 1 at hl.
	ldh a, [rWBK]
	push af
	ld a, BANK(wBlackjackSidebarTiles)
	ldh [rWBK], a
	ld de, wBlackjackSidebarTiles
	ld b, BANK(@)
	call Blackjack_Get2bppBank1
	pop af
	ldh [rWBK], a
	ret

Blackjack_Get2bppBank1:
; Get2bpp into VRAM bank 1. The BG map waits meanwhile: sent with bank 1 selected, it would land
; on the attributes.
	ldh a, [hBGMapMode]
	push af
	xor a
	ldh [hBGMapMode], a
	inc a
	ldh [rVBK], a
	call Get2bpp
	xor a
	ldh [rVBK], a
	pop af
	ldh [hBGMapMode], a
	ret

Blackjack_SetSidebarDest:
	ld a, l
	ld [wBlackjackSidebarDest], a
	ld a, h
	ld [wBlackjackSidebarDest + 1], a
	ret

Blackjack_SidebarCoins:
; The coin count, centred in white across the row under the COINS banner.
	ld de, wCoins
	lb bc, 2, BJ_SIDEBAR_WIDTH * 2
	ld hl, BlackjackSidebarTilemap + BJ_COINS_Y * BJ_SIDEBAR_WIDTH
; fallthrough
Blackjack_SidebarCentred:
; The b-byte number at de (b = 0: none), centred in white across a field of c characters whose
; art starts at hl, as the next tiles from wBlackjackSidebarDest. With an odd number of digits it
; sits half a character left.
	push hl
	ld a, c
	ld [wBlackjackFieldCells], a
	push bc
	push de
	ld hl, wBlackjackSidebarLine
	ld b, 0
	ld a, " "
	rst ByteFill
	pop de
	pop bc
	ld a, b
	and a
	jr z, .art
; four places, right-aligned, at the end of the field; PrintNum leaves the places before as spaces
	ld a, [wBlackjackFieldCells]
	sub BJ_SIDEBAR_DIGITS
	add LOW(wBlackjackSidebarLine)
	ld l, a
	adc HIGH(wBlackjackSidebarLine)
	sub l
	ld h, a
	push hl
	ld c, BJ_SIDEBAR_DIGITS
	call PrintNum
	pop hl
; c = how many digits, hl = the first
	ld c, BJ_SIDEBAR_DIGITS
.count
	ld a, [hl]
	cp " "
	jr nz, .counted
	inc hl
	dec c
	jr nz, .count
.counted
; move them to start at (the field's width - c) / 2, then blank the rest of the field
	ld a, [wBlackjackFieldCells]
	sub c
	srl a
	add LOW(wBlackjackSidebarLine)
	ld e, a
	adc HIGH(wBlackjackSidebarLine)
	sub e
	ld d, a
	ld b, c
.move
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .move
	ld a, [wBlackjackFieldCells]
	add LOW(wBlackjackSidebarLine)
	ld b, a
.blank
	ld a, e
	cp b
	jr z, .art
	ld a, " "
	ld [de], a
	inc de
	jr .blank

.art
	ld a, TRUE
	ld [wBlackjackSidebarWhite], a
	ld a, [wBlackjackFieldCells]
	srl a
	ld b, a
	pop hl
; fallthrough
Blackjack_SidebarText:
; Draw the characters at wBlackjackSidebarLine (the normal font's), two to a tile, over b of the
; sidebar's art tiles from the cell of sidebar.tilemap at hl, as the next tiles from wBlackjackSidebarDest: in black (colour 3),
; or in white (colour 0) if wBlackjackSidebarWhite is set, nudged wBlackjackSidebarNudgeX pixels
; right (-1 for left) and wBlackjackSidebarNudgeY down. The ink is worked out for the whole field
; first, since a nudge carries pixels across tiles; then it goes over the art. The white and
; nudge settings are cleared afterwards.
	ldh a, [rWBK]
	push af
	ld a, BANK(wBlackjackSidebarTiles)
	ldh [rWBK], a
	ld a, l
	ld [wBlackjackArtCell], a
	ld a, h
	ld [wBlackjackArtCell + 1], a
	ld a, b
	ld [wBlackjackFieldTiles], a
; 1. the ink, tile by tile, row by row
	ld hl, wBlackjackSidebarLine
	ld de, BJ_FIELD_INK
.ink_tile
	ld a, [hli]
	call .Glyph
	ld [wBlackjackGlyphLeft], a
	ld a, [hli]
	call .Glyph
	ld [wBlackjackGlyphRight], a
	ld c, 0
.ink_row
; this row shows the characters' row c - the nudge down, if there is one
	ld a, [wBlackjackSidebarNudgeY]
	cpl
	inc a
	add c
	cp TILE_HEIGHT
	jr nc, .no_ink
	push bc
	ld c, a
	ld a, [wBlackjackGlyphRight]
	call .GlyphRow
	swap a
	ld b, a
	ld a, [wBlackjackGlyphLeft]
	call .GlyphRow
	or b
	pop bc
	jr .got_ink

.no_ink
	xor a
.got_ink
	ld [de], a
	inc de
	inc c
	ld a, c
	cp TILE_HEIGHT
	jr nz, .ink_row
	dec b
	jr nz, .ink_tile
; 2. the nudge across, a pixel at a time, each a row at a time through every tile
	ld a, [wBlackjackSidebarNudgeX]
	and a
	jr z, .draw
	bit 7, a
	jr z, .nudge_pixel
	cpl
	inc a
.nudge_pixel
	push af
	ld c, 0
.nudge_row
	ld a, [wBlackjackSidebarNudgeX]
	bit 7, a
	ld a, [wBlackjackFieldTiles]
	ld b, a
	ld e, 0 ; the pixel carried over
	jr nz, .nudge_left
; right: from the first tile on, each one's last pixel into the next one's first
	ld hl, BJ_FIELD_INK
	call .RowInTile
.right
	ld a, [hl]
	ld d, a
	srl a
	or e
	ld [hl], a
	ld a, d
	and 1
	rrca
	ld e, a
	ld a, l
	add TILE_HEIGHT
	ld l, a
	adc h
	sub l
	ld h, a
	dec b
	jr nz, .right
	jr .nudged_row

.nudge_left
; left: from the last tile back, each one's first pixel into the one before's last
	ld hl, BJ_FIELD_INK - TILE_HEIGHT
	push bc
	ld a, b
	ld bc, TILE_HEIGHT
	rst AddNTimes
	pop bc
	call .RowInTile
.left_tile
	ld a, [hl]
	ld d, a
	add a
	or e
	ld [hl], a
	ld a, d
	rlca
	and 1
	ld e, a
	ld a, l
	sub TILE_HEIGHT
	ld l, a
	jr nc, .left_next
	dec h
.left_next
	dec b
	jr nz, .left_tile
.nudged_row
	inc c
	ld a, c
	cp TILE_HEIGHT
	jr nz, .nudge_row
	pop af
	dec a
	jr nz, .nudge_pixel
; 3. over the art: black sets both planes where there's ink, white clears them
.draw
	ld hl, wBlackjackSidebarDest
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ld a, [wBlackjackFieldTiles]
	add a
	add a
	add a
	ld c, a ; rows of ink in all
	ld hl, BJ_FIELD_INK
.draw_row
	push hl
	ld b, [hl] ; the ink
	ld a, c
	and TILE_HEIGHT - 1
	call z, .NextArtTile
	ld hl, wBlackjackArtPointer
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wBlackjackSidebarWhite]
	and a
	jr nz, .white
	ld a, b
	or [hl]
	inc hl
	ld [de], a
	inc de
	ld a, b
	or [hl]
	jr .drawn

.white
	ld a, b
	cpl
	ld b, a
	and [hl]
	inc hl
	ld [de], a
	inc de
	ld a, b
	and [hl]
.drawn
	inc hl
	ld [de], a
	inc de
	ld a, l
	ld [wBlackjackArtPointer], a
	ld a, h
	ld [wBlackjackArtPointer + 1], a
	pop hl
	inc hl
	dec c
	jr nz, .draw_row
	ld hl, wBlackjackSidebarDest
	ld a, e
	ld [hli], a
	ld [hl], d
	xor a
	ld [wBlackjackSidebarWhite], a
	ld [wBlackjackSidebarNudgeX], a
	ld [wBlackjackSidebarNudgeY], a
	pop af
	ldh [rWBK], a
	ret

.NextArtTile:
; The art pointer to the tile in the next cell of sidebar.tilemap. Keeps bc.
	ld hl, wBlackjackArtCell
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [hli]
	push af
	ld a, l
	ld [wBlackjackArtCell], a
	ld a, h
	ld [wBlackjackArtCell + 1], a
	pop af
	push de
	swap a ; a tile's 16 bytes
	ld l, a
	and $f
	ld h, a
	xor l
	ld l, a
	ld de, BlackjackSidebarGFX
	add hl, de
	ld a, l
	ld [wBlackjackArtPointer], a
	ld a, h
	ld [wBlackjackArtPointer + 1], a
	pop de
	ret

.RowInTile:
; hl += c, the row
	ld a, l
	add c
	ld l, a
	ret nc
	inc h
	ret

.Glyph:
; The small font's character for the normal font's character a: a space, a digit, a capital or
; the cursor
	cp " "
	jr z, .space
	cp "▶"
	jr z, .cursor
	cp "?"
	jr z, .question
	cp "0"
	jr nc, .digit
	sub "A" - BJ_SMALL_A
	ret

.cursor
	ld a, BJ_SMALL_CURSOR
	ret

.question
	ld a, BJ_SMALL_QUESTION
	ret

.digit
	sub "0" - BJ_SMALL_0
	ret

.space
	assert BJ_SMALL_SPACE == 0
	xor a
	ret

.GlyphRow:
; Row c of the small font's character a, in the high nibble. Keeps bc, de and hl.
	push hl
	push af
	srl a ; two to a tile
	add a
	add a
	add a
	add c
	add LOW(BlackjackSmallFontGFX)
	ld l, a
	adc HIGH(BlackjackSmallFontGFX)
	sub l
	ld h, a
	pop af
	bit 0, a
	ld a, [hl]
	jr z, .left
	swap a
.left
	and $f0
	pop hl
	ret

Blackjack_DealerShownTotal:
; The dealer's total as the player sees it: the face-up card alone while the hole is down.
	ld a, [wBlackjackHoleHidden]
	and a
	jmp z, Blackjack_DealerTotal
	ld hl, wBlackjackDealerHand
	ld a, [wBlackjackDealerCount]
	and a
	ret z
	ld c, 1
	jmp Blackjack_HandTotal

Blackjack_DrawHand:
; Draw the c cards at hl fanned out from tilemap address de, each one 2 tiles right of the last.
; b: TRUE if the second card is face down.
	ld a, c
	and a
	ret z
	xor a
	ld [wBlackjackCardIndex], a
.loop
	push bc
	push de
	push hl
	ld c, [hl]
	ld a, [wBlackjackCardIndex]
	dec a
	jr nz, .face_up
	ld a, b
	and a
	jr z, .face_up
	ld c, BLACKJACK_FACE_DOWN
.face_up
	ld a, [wBlackjackCardIndex]
	cp BJ_MAX_SHOWN
	jr c, .shown
	ld a, BJ_MAX_SHOWN - 1
.shown
	add a
	add e
	ld l, a
	adc d
	sub l
	ld h, a
	ld a, c
	call Blackjack_DrawCard
	ld hl, wBlackjackCardIndex
	inc [hl]
	pop hl
	pop de
	pop bc
	inc hl
	dec c
	jr nz, .loop
	ret

Blackjack_DrawCard:
; Draw card a at tilemap address hl, with its palette. Its corners: the right ones, and a hand's
; first card's bottom left, sit on the felt, so they're tiles in the felt's palette with that side's
; green outside the card; a later card's left corners sit on the card before, so they're its overlap
; copies. A first card's top left gets its green from a corner sprite (Blackjack_PlaceCorners).
	push hl
	call Blackjack_GetCardTiles
	pop hl
	push af
	push hl
; c: the first of this side's felt corner tiles
	ld c, BJTILE1_FELT_CORNERS
	ld a, l
	sub LOW(wTilemap + (BJ_FELT_TOP + BJ_DEALER_FELT_HEIGHT) * SCREEN_WIDTH)
	ld a, h
	sbc HIGH(wTilemap + (BJ_FELT_TOP + BJ_DEALER_FELT_HEIGHT) * SCREEN_WIDTH)
	jr nc, .your_side
	ld c, BJTILE1_FELT_CORNERS + BJ_DEALER_CORNERS
.your_side
	ld a, [wBlackjackCardTiles]
	cp BJTILE_BACK
	ld a, BJTILE1_BACK_CORNERS - 1 ; the back's own, in its palette
	jr z, .right_corners
	ld a, c
.right_corners
	inc a
	ld [wBlackjackCardTiles + BJ_CARD_WIDTH - 1], a ; top right
	inc a
	ld [wBlackjackCardTiles + BJ_CARD_WIDTH * BJ_CARD_HEIGHT - 1], a ; bottom right
	ld hl, wBlackjackCardTiles + BJ_CARD_WIDTH * (BJ_CARD_HEIGHT - 1) ; bottom left
	ld a, [wBlackjackCardIndex]
	and a
	jr nz, .overlap
	ld [hl], c
	jr .tiles

.overlap
	ld a, [wBlackjackCardTiles]
	cp BJTILE_BACK
	jr z, .overlap_back
	add BJTILE_OVERLAP - BJTILE_SUITS
	ld [wBlackjackCardTiles], a
	ld [hl], BJTILE_OVERLAP_BOTTOM_LEFT
	jr .tiles

.overlap_back
	ld a, BJTILE_OVERLAP_BACK
	ld [wBlackjackCardTiles], a
	ld [hl], BJTILE_OVERLAP_BACK_BOTTOM_LEFT
.tiles
	ld de, wBlackjackCardTiles
	pop hl
	push hl
	lb bc, BJ_CARD_HEIGHT, BJ_CARD_WIDTH
.row
	push bc
	push hl
.col
	ld a, [de]
	inc de
	ld [hli], a
	dec c
	jr nz, .col
	pop hl
	ld bc, SCREEN_WIDTH
	add hl, bc
	pop bc
	dec b
	jr nz, .row
	pop hl
	ld de, wAttrmap - wTilemap
	add hl, de
	pop af
	push hl
	lb bc, BJ_CARD_HEIGHT, BJ_CARD_WIDTH
	call FillBoxWithByte
	pop hl
; the corners on the felt: the felt's palette (the back's for its own), their tiles in VRAM bank 1
	ld bc, BJ_CARD_WIDTH - 1
	add hl, bc
	ld a, [wBlackjackCardTiles + BJ_CARD_WIDTH - 1]
	cp BJTILE1_BACK_CORNERS
	ld a, BJPAL_BACK | BG_BANK1
	jr z, .right_attributes
	ld a, BJPAL_FELT | BG_BANK1
.right_attributes
	ld [hl], a ; top right
	ld bc, (BJ_CARD_HEIGHT - 1) * SCREEN_WIDTH
	add hl, bc
	ld [hl], a ; bottom right
	ld a, [wBlackjackCardIndex]
	and a
	ret nz
	ld bc, -(BJ_CARD_WIDTH - 1)
	add hl, bc
	ld [hl], BJPAL_FELT | BG_BANK1 ; bottom left
	ret

Blackjack_GetCardTiles:
; Fill wBlackjackCardTiles with card a's tiles, row by row, and return its palette in a.
	cp BLACKJACK_FACE_DOWN
	jr nz, .face_up
; the deck's back, the whole card
	ld hl, wBlackjackCardTiles
	ld a, BJTILE_BACK
	ld c, BJ_BACK_TILES
.back
	ld [hli], a
	inc a
	dec c
	jr nz, .back
	ld a, BJPAL_BACK
	ret

.face_up
	ld c, a
	swap a
	and $f
	ld b, a ; suit
	ld hl, wBlackjackCardTiles
; top edge, with the suit in the corner
	add BJTILE_SUITS
	ld [hli], a
	ld a, BJTILE_TOP
	ld [hli], a
	ld [hli], a
	inc a
	ld [hli], a
; rank
	ld a, BJTILE_RANK_MARK
	ld [hli], a
	ld a, c
	and $f
	add BJTILE_RANKS - 1
	ld [hli], a
	ld a, BJTILE_BLANK
	ld [hli], a
	ld a, BJTILE_RIGHT_EDGE
	ld [hli], a
; the suit's picture
	assert BJ_PICTURE_TILES == 12
	ld a, b
	add a
	add b
	add a
	add a
	add BJTILE_PICTURES
	ld c, BJ_PICTURE_TILES
.art
	ld [hli], a
	inc a
	dec c
	jr nz, .art
; bottom edge
	ld a, BJTILE_BOTTOM_LEFT
	ld [hli], a
	inc a
	ld [hli], a
	ld [hli], a
	inc a
	ld [hl], a
	ld a, b ; the suit's palette
	ret

; Each message is one line of at most 18 characters, on the message box's first line.

BlackjackShufflingText:
	text "Shuffling the"
	next "shoe."
	done

BlackjackNotEnoughCoinsText:
	text "Not enough coins."
	done

BlackjackLeaveText:
	text "Leave the table?"
	done

BlackjackBlackjackText:
	text "Blackjack! <BJ_PLUS>@"
	text_decimal wBlackjackWinnings, 1, 3
	text_end

BlackjackWinText:
	text "You win! <BJ_PLUS>@"
	text_decimal wBlackjackWinnings, 1, 3
	text_end

BlackjackDealerBustText:
	text "Dealer busts! <BJ_PLUS>@"
	text_decimal wBlackjackWinnings, 1, 3
	text_end

BlackjackPushText:
	text "Push. Bet back."
	done

BlackjackLoseText:
	text "You lose."
	done

BlackjackPlayerBustText:
	text "Bust! You lose."
	done

BlackjackDealerBlackjackText:
	text "Dealer blackjack!"
	done

BlackjackTitleLogoGFX:
; from tile 1: tile 0 is the background beside Meowth's frames
INCBIN "gfx/blackjack/logo.2bpp", 1 tiles
BlackjackTitleLogoGFXEnd:
	assert BJTILE_TITLE_LOGO + 1 + (BlackjackTitleLogoGFXEnd - BlackjackTitleLogoGFX) / TILE_SIZE <= $100, \
		"the logo fits vTiles1"

BlackjackTitleMeowthTilemaps:
; each of Meowth's frames, row by row, from logo.tilemap
	for _bj_frame, 2
		for _bj_y, BJ_TITLE_MEOWTH_HEIGHT
			INCBIN "gfx/blackjack/logo.tilemap", \
				_bj_y * BJ_TITLE_LOGO_PNG_WIDTH + BJ_TITLE_MEOWTH_PNG_X + _bj_frame * BJ_TITLE_MEOWTH_WIDTH, \
				BJ_TITLE_MEOWTH_WIDTH
		endr
	endr
	assert @ - BlackjackTitleMeowthTilemaps == 2 * BJ_TITLE_MEOWTH_TILES

BlackjackTitleSignTilemap:
; the sign, row by row, to the end of logo.tilemap
INCBIN "gfx/blackjack/logo.tilemap", BJ_TITLE_SIGN_PNG_Y * BJ_TITLE_LOGO_PNG_WIDTH
	assert @ - BlackjackTitleSignTilemap == BJ_TITLE_SIGN_WIDTH * BJ_TITLE_SIGN_HEIGHT, \
		"logo.png is Meowth's frames over the sign"

BlackjackTitleCornerOAM:
; Meowth's top left and top right tiles
	db BJ_TITLE_MEOWTH_Y * TILE_HEIGHT + OAM_Y_OFS, BJ_TITLE_MEOWTH_X * TILE_WIDTH + OAM_X_OFS
	db BJTILE_TITLE_CORNER, BJPAL_FELT
	db BJ_TITLE_MEOWTH_Y * TILE_HEIGHT + OAM_Y_OFS
	db (BJ_TITLE_MEOWTH_X + BJ_TITLE_MEOWTH_WIDTH - 1) * TILE_WIDTH + OAM_X_OFS
	db BJTILE_TITLE_CORNER, BJPAL_FELT | OAM_XFLIP
BlackjackTitleCornerOAMEnd:

BlackjackTitleTextColours:
; the felt palette's colours 2 and 3 on the title screen
	RGB 31, 31, 31 ; the text
	RGB 00, 00, 00

BlackjackTitlePatternTiles:
; Each of the felt pattern's 6x4 tiles, row by row, as a tile of felt.png: the table's bands, the
; first with the paw at BJ_FELT_FIRST_X, the next at BJ_FELT_SECOND_X, blank elsewhere
	for _bj_y, BJ_TITLE_TEXTURE_HEIGHT
		DEF _bj_paw = BJ_FELT_FIRST_X + (_bj_y / 2) * (BJ_FELT_SECOND_X - BJ_FELT_FIRST_X)
		DEF _bj_paw = _bj_paw % BJ_TITLE_TEXTURE_WIDTH
		assert _bj_paw + 1 < BJ_TITLE_TEXTURE_WIDTH, "a paw doesn't wrap round the pattern"
		for _bj_x, BJ_TITLE_TEXTURE_WIDTH
			if _bj_x == _bj_paw || _bj_x == _bj_paw + 1
				db (_bj_y % 2) * BJ_FELT_PNG_WIDTH + _bj_x - _bj_paw
			else
				db BJTILE_FELT_BLANK - BJTILE_FELT
			endc
		endr
	endr
	assert @ - BlackjackTitlePatternTiles == BJ_TITLE_FELT_TILES

MACRO bj_title_cells
; x, y, cells: the felt tile under each cell of a line of text
	for _bj_x, \1, \1 + \3
		db (\2 % BJ_TITLE_TEXTURE_HEIGHT) * BJ_TITLE_TEXTURE_WIDTH + _bj_x % BJ_TITLE_TEXTURE_WIDTH
	endr
ENDM

BlackjackTitleCellFelt:
	bj_title_cells BJ_TITLE_START_X, BJ_TITLE_START_Y, BJ_TITLE_START_CELLS
	bj_title_cells BJ_TITLE_LABEL_X, BJ_TITLE_LABEL_Y, BJ_TITLE_LABEL_CELLS
	bj_title_cells BJ_TITLE_DECK_X, BJ_TITLE_DECK_Y, BJ_TITLE_DECK_CELLS
	assert @ - BlackjackTitleCellFelt == BJ_TITLE_TEXT_CELLS

BlackjackTitleStartText:
	db "PUSH START@"
	assert @ - BlackjackTitleStartText - 1 == BJ_TITLE_START_LENGTH

BlackjackTitleLabelText:
	db "DECK@"
	assert @ - BlackjackTitleLabelText - 1 == BJ_TITLE_LABEL_LENGTH

BlackjackDeckNames:
; as the title screen shows them
	table_width 2
	dw .French     ; BJ_DECK_FRENCH
	dw .Spaceworld ; BJ_DECK_SPACEWORLD
	assert_table_length NUM_BJ_DECKS
.French:
	db "DEFAULT@"
	assert @ - .French - 1 <= BJ_TITLE_NAME_LENGTH
.Spaceworld:
	db "SPACEWORLD@"
	assert @ - .Spaceworld - 1 <= BJ_TITLE_NAME_LENGTH

BlackjackDeckUnlocks:
; the event flag that unlocks each deck, or -1 for one always there
	table_width 2
	dw -1                              ; BJ_DECK_FRENCH
	dw EVENT_BLACKJACK_SPACEWORLD_DECK ; BJ_DECK_SPACEWORLD
	assert_table_length NUM_BJ_DECKS

BlackjackPalettes:
; From BJPAL_FELT: the felt, the deck's back (replaced by the deck's own), the sidebar, and the text
INCLUDE "gfx/blackjack/blackjack.pal"
	assert @ - BlackjackPalettes == NUM_BJ_PALETTES palettes
	assert BJPAL_FELT + NUM_BJ_PALETTES == PAL_BG_TEXT + 1, "blackjack.pal ends with the text's"

BlackjackDecks:
; Each deck: its suits, its pictures, its back, its palettes (the four suits', then one or more for
; the back: the same back in different colours), and how many back colours it has
	table_width BJ_DECK_ENTRY_SIZE
	; BJ_DECK_FRENCH
	dw BlackjackFrenchSuitsGFX, BlackjackFrenchPicturesGFX
	dw BlackjackFrenchBackGFX, BlackjackFrenchPalettes
	db (BlackjackFrenchPalettesEnd - BlackjackFrenchPalettes) / PALETTE_SIZE - BLACKJACK_NUM_SUITS
	; BJ_DECK_SPACEWORLD
	dw BlackjackSpaceworldSuitsGFX, BlackjackSpaceworldPicturesGFX
	dw BlackjackSpaceworldBackGFX, BlackjackSpaceworldPalettes
	db (BlackjackSpaceworldPalettesEnd - BlackjackSpaceworldPalettes) / PALETTE_SIZE - BLACKJACK_NUM_SUITS
	assert_table_length NUM_BJ_DECKS

; A deck's files, each the size BlackjackDecks expects. They are written out per deck, not made by
; a macro, so that make can find the graphics to build.

BlackjackFrenchSuitsGFX:
INCBIN "gfx/blackjack/decks/french/suits.2bpp"
	assert @ - BlackjackFrenchSuitsGFX == BLACKJACK_NUM_SUITS tiles
BlackjackFrenchPicturesGFX:
INCBIN "gfx/blackjack/decks/french/pictures.2bpp"
	assert @ - BlackjackFrenchPicturesGFX == BLACKJACK_NUM_SUITS * BJ_PICTURE_TILES tiles
BlackjackFrenchBackGFX:
INCBIN "gfx/blackjack/decks/french/back.2bpp"
	assert @ - BlackjackFrenchBackGFX == BJ_BACK_TILES tiles
BlackjackFrenchPalettes:
INCLUDE "gfx/blackjack/decks/french/deck.pal"
BlackjackFrenchPalettesEnd:
	assert @ - BlackjackFrenchPalettes >= (BLACKJACK_NUM_SUITS + 1) palettes && 		(@ - BlackjackFrenchPalettes) % PALETTE_SIZE == 0, "the suits' palettes and at least one back colour"

BlackjackSpaceworldSuitsGFX:
INCBIN "gfx/blackjack/decks/spaceworld/suits.2bpp"
	assert @ - BlackjackSpaceworldSuitsGFX == BLACKJACK_NUM_SUITS tiles
BlackjackSpaceworldPicturesGFX:
INCBIN "gfx/blackjack/decks/spaceworld/pictures.2bpp"
	assert @ - BlackjackSpaceworldPicturesGFX == BLACKJACK_NUM_SUITS * BJ_PICTURE_TILES tiles
BlackjackSpaceworldBackGFX:
INCBIN "gfx/blackjack/decks/spaceworld/back.2bpp"
	assert @ - BlackjackSpaceworldBackGFX == BJ_BACK_TILES tiles
BlackjackSpaceworldPalettes:
INCLUDE "gfx/blackjack/decks/spaceworld/deck.pal"
BlackjackSpaceworldPalettesEnd:
	assert @ - BlackjackSpaceworldPalettes >= (BLACKJACK_NUM_SUITS + 1) palettes && 		(@ - BlackjackSpaceworldPalettes) % PALETTE_SIZE == 0, "the suits' palettes and at least one back colour"

BlackjackCardPartsGFX:
INCBIN "gfx/blackjack/card_parts.2bpp"
	assert @ - BlackjackCardPartsGFX == BJ_NUM_CARD_PART_TILES tiles

BlackjackFeltGFX:
INCBIN "gfx/blackjack/felt.2bpp"
	assert @ - BlackjackFeltGFX == BJ_FELT_PNG_TILES tiles

BlackjackButtonsGFX:
INCBIN "gfx/blackjack/buttons.2bpp"

BlackjackPlusGFX:
INCBIN "gfx/blackjack/plus.2bpp"

BlackjackSidebarGFX:
; the sidebar above Meowth, 5x12 tiles: each different tile once
INCBIN "gfx/blackjack/sidebar.2bpp"
BlackjackSidebarGFXEnd:
	assert BJTILE1_SHEET + (BlackjackSidebarGFXEnd - BlackjackSidebarGFX) / (1 tiles) <= BJTILE1_MEOWTH, \
		"the sheet's tiles end before Meowth's"

BlackjackSidebarTilemap:
; where each of them goes, row by row
INCBIN "gfx/blackjack/sidebar.tilemap"
	assert @ - BlackjackSidebarTilemap == BJ_NUM_SHEET_TILES

BlackjackMeowthGFX:
; every frame's tiles, each different one once
INCBIN "gfx/blackjack/meowth.2bpp"
BlackjackMeowthGFXEnd:
	assert BJTILE1_MEOWTH + (BlackjackMeowthGFXEnd - BlackjackMeowthGFX) / (1 tiles) <= $100, \
		"Meowth's tiles fit VRAM bank 1"

BlackjackMeowthTilemap:
; where they go in each frame, frame after frame, row by row
INCBIN "gfx/blackjack/meowth.tilemap"
	assert @ - BlackjackMeowthTilemap == BJ_MEOWTH_FRAMES * BJ_MEOWTH_TILES

BlackjackSmallFontGFX:
; 4x8 characters, two to a tile: a space, 0-9, A-Z, the cursor, "?"
INCBIN "gfx/blackjack/small_font.1bpp"
	assert @ - BlackjackSmallFontGFX == (BJ_SMALL_QUESTION + 2) / 2 * TILE_HEIGHT
