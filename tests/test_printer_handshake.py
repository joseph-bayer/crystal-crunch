"""While the Game Boy Printer is in use, VBlank sends it a handshake every 6 frames.

Vanilla's serial VBlank (VBlank4) calls AskSerial, which, while a printer connection is open and
the printer code is idle, sends the $88 handshake and sets the printer opcode to $0c. CSE's VBlank
rewrite dropped the call, so nothing sent it and printing had no keep-alive.

No printer is attached: the test only checks that VBlank, in its serial mode, starts the handshake.
The serial interrupt moves the opcode on from $0c within the same frame, so any opcode at all shows
the handshake started; without the call it stays 0."""

VBLANK_SERIAL = 4 # constants/ram_constants.asm
PRINTER_CONNECTION_OPEN = 1 << 0 # constants/printer_constants.asm, bit 0 of wPrinterConnectionOpen
HANDSHAKE_EVERY = 6 # frames


def test_serial_vblank_starts_the_handshake(game):
	game.poke("wPrinterConnectionOpen", PRINTER_CONNECTION_OPEN)
	game.poke("wPrinterOpcode", 0)
	game.poke("wHandshakeFrameDelay", 0)
	game.poke("hVBlank", VBLANK_SERIAL)
	opcodes = []
	for _ in range(HANDSHAKE_EVERY * 2):
		game.wait(1)
		opcodes.append(game.peek("wPrinterOpcode"))
	assert game.peek("hVBlank") == VBLANK_SERIAL, "something else changed the VBlank mode"
	assert any(opcodes), "no handshake was started: %s" % opcodes


def test_no_handshake_without_a_connection(game):
	game.poke("wPrinterConnectionOpen", 0)
	game.poke("wPrinterOpcode", 0)
	game.poke("hVBlank", VBLANK_SERIAL)
	game.wait(HANDSHAKE_EVERY * 2)
	assert game.peek("wPrinterOpcode") == 0
