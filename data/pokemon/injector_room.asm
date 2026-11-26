; The starter injector's room for the new species slots' pics, Pokédex entries and custom cries:
; one of each per slot, empty in the plain build (see constants/injector_constants.asm). Their
; tables carry their own banks (dba), so this room can sit anywhere.

SECTION "Injector Frontpics", ROMX

InjectorFrontpicRoom::
	ds INJECTOR_FRONT_ROOM * NUM_NEW_MONS


SECTION "Injector Room", ROMX

InjectorBackpicRoom::
	ds INJECTOR_BACK_ROOM * NUM_NEW_MONS
InjectorDexEntryRoom::
	ds INJECTOR_DEX_ENTRY_ROOM * NUM_NEW_MONS
InjectorCryRoom::
	ds INJECTOR_CRY_ROOM * NUM_NEW_MONS
