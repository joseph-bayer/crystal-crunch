#!/usr/bin/env python3
"""
Pokemon Data Extractor for Pokemon Crystal
Generates a CSV file with Pokemon locations and evolution data
"""

import csv
import re
import os
from pathlib import Path
from typing import Set, Dict, List
from typing import Dict, List, Set, Tuple, Optional

class PokemonDataExtractor:
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.pokemon_list = []
        self.kanto_morning_encounters = {}
        self.kanto_day_encounters = {}
        self.kanto_night_encounters = {}
        self.johto_morning_encounters = {}
        self.johto_day_encounters = {}
        self.johto_night_encounters = {}
        self.kanto_water_encounters = {}
        self.johto_water_encounters = {}
        self.gift_pokemon = {}
        self.evolutions = {}
        self.npc_trades = {}
        self.headbutt_encounters = {}
        self.rock_smash_encounters = {}
        self.bug_contest_pokemon = set()
        self.static_pokemon = {}
        self.old_rod_fish_groups = {}
        self.good_rod_fish_groups = {}
        self.super_rod_fish_groups = {}
        self.fish_group_locations = {}  # Maps fish groups to their locations
        self.overrides = {}  # For future context overrides
        self.first_stage_pokemon = set()  # Pokemon that can be hatched from eggs
        self.egg_hatchable = {}  # Maps Pokemon to whether they can be hatched
        
    def extract_pokemon_constants(self):
        """Extract all Pokemon names from pokemon_constants.asm"""
        constants_file = self.base_path / "constants" / "pokemon_constants.asm"
        
        with open(constants_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Find all const POKEMON_NAME lines
        pokemon_pattern = r'^\s*const\s+([A-Z_]+)\s*;'
        matches = re.findall(pokemon_pattern, content, re.MULTILINE)
        
        # Filter out non-Pokemon constants (like UNOWN forms)
        pokemon_names = []
        for match in matches:
            # Skip UNOWN forms and other non-main Pokemon
            if not match.startswith('UNOWN_') and match not in ['EGG']:
                pokemon_names.append(match)
        
        self.pokemon_list = pokemon_names
        print(f"Found {len(pokemon_names)} Pokemon")
        
    def extract_wild_encounters(self):
        """Extract wild encounters from grass and water files"""
        # Process Kanto encounters (grass and water)
        kanto_grass_file = self.base_path / "data" / "wild" / "kanto_grass.asm"
        kanto_water_file = self.base_path / "data" / "wild" / "kanto_water.asm"
        self._parse_wild_file(kanto_grass_file, "Kanto")
        self._parse_wild_file(kanto_water_file, "Kanto")
        
        # Process Johto encounters (grass and water)
        johto_grass_file = self.base_path / "data" / "wild" / "johto_grass.asm"
        johto_water_file = self.base_path / "data" / "wild" / "johto_water.asm"
        self._parse_wild_file(johto_grass_file, "Johto")
        self._parse_wild_file(johto_water_file, "Johto")
        
    def _parse_wild_file(self, file_path: Path, region: str):
        """Parse a wild encounters file with time-of-day awareness"""
        if not file_path.exists():
            return
            
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        lines = content.split('\n')
        current_location = None
        current_time_period = None
        is_water_encounter = False
        
        for line in lines:
            line = line.strip()
            
            # Check for location definition
            location_match = re.search(r'def_(?:grass|water)_wildmons\s+([A-Z_0-9]+)', line)
            if location_match:
                current_location = location_match.group(1)
                current_time_period = None
                is_water_encounter = 'water' in line
                continue
            
            # Check for time period markers (only for grass encounters)
            if current_location and not is_water_encounter:
                if line == '; morn':
                    current_time_period = 'morning'
                    continue
                elif line == '; day':
                    current_time_period = 'day'
                    continue
                elif line == '; nite':
                    current_time_period = 'night'
                    continue
            
            # Check for Pokemon encounter
            if current_location:
                pokemon_match = re.search(r'dbw\s+[^,]+,\s+([A-Z_]+)', line)  # a level may be LEVEL_FROM_BADGES +/- n
                if pokemon_match:
                    pokemon = pokemon_match.group(1)
                    if pokemon in self.pokemon_list:
                        # Format location name better
                        formatted_location = self._format_location_name(current_location)
                        
                        # For water encounters, add to water encounter dictionaries
                        if is_water_encounter:
                            if region == "Kanto":
                                if pokemon not in self.kanto_water_encounters:
                                    self.kanto_water_encounters[pokemon] = set()
                                self.kanto_water_encounters[pokemon].add(formatted_location)
                            else:  # Johto
                                if pokemon not in self.johto_water_encounters:
                                    self.johto_water_encounters[pokemon] = set()
                                self.johto_water_encounters[pokemon].add(formatted_location)
                        # For grass encounters, store in appropriate time-specific dictionary
                        elif current_time_period:
                            if region == "Kanto":
                                if current_time_period == 'morning':
                                    if pokemon not in self.kanto_morning_encounters:
                                        self.kanto_morning_encounters[pokemon] = set()
                                    self.kanto_morning_encounters[pokemon].add(formatted_location)
                                elif current_time_period == 'day':
                                    if pokemon not in self.kanto_day_encounters:
                                        self.kanto_day_encounters[pokemon] = set()
                                    self.kanto_day_encounters[pokemon].add(formatted_location)
                                elif current_time_period == 'night':
                                    if pokemon not in self.kanto_night_encounters:
                                        self.kanto_night_encounters[pokemon] = set()
                                    self.kanto_night_encounters[pokemon].add(formatted_location)
                            else:  # Johto
                                if current_time_period == 'morning':
                                    if pokemon not in self.johto_morning_encounters:
                                        self.johto_morning_encounters[pokemon] = set()
                                    self.johto_morning_encounters[pokemon].add(formatted_location)
                                elif current_time_period == 'day':
                                    if pokemon not in self.johto_day_encounters:
                                        self.johto_day_encounters[pokemon] = set()
                                    self.johto_day_encounters[pokemon].add(formatted_location)
                                elif current_time_period == 'night':
                                    if pokemon not in self.johto_night_encounters:
                                        self.johto_night_encounters[pokemon] = set()
                                    self.johto_night_encounters[pokemon].add(formatted_location)
            
            # Reset location on end marker
            if 'end_grass_wildmons' in line or 'end_water_wildmons' in line:
                current_location = None
                current_time_period = None
                is_water_encounter = False
                
    def extract_gift_pokemon(self):
        """Extract gift Pokemon from map files"""
        # First extract Odd Egg Pokemon
        self._extract_odd_egg_pokemon()
        
        maps_dir = self.base_path / "maps"
        
        for map_file in maps_dir.glob("*.asm"):
            # Skip PlayerHouse2F.asm and unused folder
            if map_file.name == "PlayersHouse2F.asm":
                continue
                
            self._parse_map_file(map_file)
    
    def _extract_odd_egg_pokemon(self):
        """Extract Pokemon that can be obtained from the Odd Egg"""
        odd_eggs_file = self.base_path / "data" / "events" / "odd_eggs.asm"
        
        if odd_eggs_file.exists():
            try:
                with open(odd_eggs_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Look for the OddEggSpecies section
                lines = content.split('\n')
                in_odd_egg_species = False
                
                for line in lines:
                    line = line.strip()
                    
                    if 'OddEggSpecies:' in line:
                        in_odd_egg_species = True
                        continue
                    
                    if in_odd_egg_species:
                        # Stop when we hit the next section
                        if line.startswith('assert_table_length') or line == '':
                            break
                        
                        # Look for Pokemon names: dw POKEMON_NAME
                        if line.startswith('dw '):
                            pokemon_match = re.search(r'dw\s+([A-Z_]+)', line)
                            if pokemon_match:
                                pokemon = pokemon_match.group(1)
                                if pokemon in self.pokemon_list:
                                    if pokemon not in self.gift_pokemon:
                                        self.gift_pokemon[pokemon] = set()
                                    self.gift_pokemon[pokemon].add("Odd Egg")
                                    
            except Exception as e:
                print(f"Error parsing odd_eggs.asm: {e}")
            
    def _parse_map_file(self, file_path: Path):
        """Parse a single map file for gift Pokemon"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Find givepoke and giveegg commands
            givepoke_pattern = r'givepoke\s+([A-Z_]+)(?:,\s*\d+)?(?:,\s*[A-Z_]+)?'
            giveegg_pattern = r'giveegg\s+([A-Z_]+)(?:,\s*\d+)?'
            
            givepoke_matches = re.findall(givepoke_pattern, content)
            giveegg_matches = re.findall(giveegg_pattern, content)
            
            # Combine both types of matches
            all_matches = givepoke_matches + giveegg_matches
            
            for pokemon in all_matches:
                if pokemon in self.pokemon_list:
                    if pokemon not in self.gift_pokemon:
                        self.gift_pokemon[pokemon] = set()
                    # Remove file extension and format location name
                    location = file_path.stem
                    formatted_location = self._format_location_name(location)
                    self.gift_pokemon[pokemon].add(formatted_location)
                    
        except Exception as e:
            print(f"Error parsing {file_path}: {e}")
            
    def _format_location_name(self, location: str) -> str:
        """Format a location name for better readability"""
        # If the location is in camelCase format (like from map file names), 
        # apply regex transformations first
        # Improved camelCase detection: look for lowercase followed by uppercase OR number
        if '_' not in location and any(
            (c.islower() and i+1 < len(location) and (location[i+1].isupper() or location[i+1].isdigit())) or
            (c.isdigit() and i+1 < len(location) and location[i+1].isupper())
            for i, c in enumerate(location)
        ):
            # This appears to be camelCase, apply transformations
            # Step 1: Add space before capitals (handles most camelCase)
            location = re.sub(r'([a-z])([A-Z])', r'\1 \2', location)
            # Step 2: Handle floor patterns specifically - add space before standalone floor numbers (1F, 2F, etc.)
            # but NOT before B1F, B2F patterns. Use negative lookbehind to avoid splitting B1F
            location = re.sub(r'([a-zA-Z])(?<!B)([0-9]+F)$', r'\1 \2', location)
            # Step 3: Add space before isolated numbers (like Route35 -> Route 35) but not floor patterns
            location = re.sub(r'([a-zA-Z])([0-9]+)(?![0-9]*F)', r'\1 \2', location)
            # Step 4: Add space between numbers and capitals 
            location = re.sub(r'([0-9])([A-Z])', r'\1 \2', location)
            # Step 5: Fix broken floor patterns by removing space before F in floor designations
            location = re.sub(r'([B]?[0-9]+)\s+F', r'\1F', location)
            # Convert to underscore format for consistent processing below
            location = location.upper().replace(' ', '_')

        # General formatting for all locations (routes are handled by regex above)
        formatted = location.replace('_', ' ').title()
        
        return formatted
            
    def extract_evolutions(self):
        """Extract evolution data from evos_attacks files"""
        # Process Kanto evolutions
        kanto_file = self.base_path / "data" / "pokemon" / "evos_attacks_kanto.asm"
        self._parse_evolution_file(kanto_file)
        
        # Process Johto evolutions
        johto_file = self.base_path / "data" / "pokemon" / "evos_attacks_johto.asm"
        self._parse_evolution_file(johto_file)
        
    def _parse_evolution_file(self, file_path: Path):
        """Parse an evolution file"""
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        lines = content.split('\n')
        current_pokemon = None
        
        for line in lines:
            line = line.strip()
            
            # Check for Pokemon name
            if line.endswith('EvosAttacks:'):
                pokemon_name = line.replace('EvosAttacks:', '')
                # Convert from PokemonNameEvosAttacks format to POKEMON_NAME format
                # e.g., BulbasaurEvosAttacks -> BULBASAUR
                pokemon_constant = pokemon_name.upper()
                if pokemon_constant in self.pokemon_list:
                    current_pokemon = pokemon_constant
                continue
            
            # Check for evolution line - handle different evolution types
            if current_pokemon and ('EVOLVE_' in line):
                # Remove any comments first
                line = line.split(';')[0].strip()
                parts = [p.strip() for p in line.split(',')]
                
                evolved_form = None
                if line.startswith('dbbw') and len(parts) >= 3:
                    # dbbw EVOLVE_LEVEL, 16, IVYSAUR
                    # dbbw EVOLVE_HAPPINESS, TR_ANYTIME, PIKACHU
                    evolved_form = parts[2]
                elif line.startswith('dbww') and len(parts) >= 3:
                    # dbww EVOLVE_ITEM, LEAF_STONE, VILEPLUME
                    evolved_form = parts[2]
                elif line.startswith('dbbbw') and len(parts) >= 4:
                    # dbbbw EVOLVE_STAT, 20, ATK_LT_DEF, HITMONCHAN
                    evolved_form = parts[3]
                
                if evolved_form and evolved_form in self.pokemon_list:
                    if evolved_form not in self.evolutions:
                        self.evolutions[evolved_form] = set()
                    self.evolutions[evolved_form].add(current_pokemon)
            
            # Reset current_pokemon when we hit the end of evolutions or start of attacks
            if current_pokemon and (line == 'db 0 ; no more evolutions' or 
                                  (line.startswith('dbw') and not 'EVOLVE_' in line)):
                current_pokemon = None
                    
    def extract_npc_trades(self):
        """Extract NPC trade Pokemon from npc_trades.asm and map files"""
        npc_trades_file = self.base_path / "data" / "events" / "npc_trades.asm"
        
        # First, get the trade constants mapping from npc_trade_constants.asm
        trade_constants = self._get_trade_constants()
        
        # Find locations for each trade constant by searching map files
        trade_locations = self._find_trade_locations(trade_constants)
        
        with open(npc_trades_file, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Parse npctrade lines - format: npctrade TRADE_DIALOGSET_*, REQUESTED_MON, OFFERED_MON, nickname, ...
        trade_pattern = r'npctrade\s+[A-Z_]+,\s*([A-Z_]+),\s*([A-Z_]+),\s*"[^"]+",.*?"([A-Z@]+)"'
        matches = re.findall(trade_pattern, content)
        
        for i, (requested_mon, offered_mon, trader_name) in enumerate(matches):
            # Clean up trader name (remove @s)
            trader_name = trader_name.replace('@', '').strip()
            
            # Get the trade constant name for this index
            trade_constant = f"NPC_TRADE_{trader_name}"
            
            if offered_mon in self.pokemon_list and trade_constant in trade_locations:
                if offered_mon not in self.npc_trades:
                    self.npc_trades[offered_mon] = set()
                location = trade_locations[trade_constant]
                # Format as "Trade for REQUESTED_MON at LOCATION"
                trade_description = f"Trade for {requested_mon} at {location}"
                self.npc_trades[offered_mon].add(trade_description)

    def _get_trade_constants(self) -> List[str]:
        """Get the list of NPC trade constants from npc_trade_constants.asm"""
        constants_file = self.base_path / "constants" / "npc_trade_constants.asm"
        
        with open(constants_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Find all NPC_TRADE_* constants
        trade_pattern = r'const\s+(NPC_TRADE_[A-Z_]+)'
        matches = re.findall(trade_pattern, content)
        
        return matches
    
    def _find_trade_locations(self, trade_constants: List[str]) -> Dict[str, str]:
        """Find locations for trade constants by searching map files"""
        trade_locations = {}
        maps_dir = self.base_path / "maps"
        
        for trade_constant in trade_constants:
            for map_file in maps_dir.glob("*.asm"):
                try:
                    with open(map_file, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    # Look for "trade TRADE_CONSTANT" in the file
                    if f"trade {trade_constant}" in content:
                        # Remove file extension and format location name
                        location = map_file.stem
                        location = re.sub(r'([a-z])([A-Z])', r'\1 \2', location)
                        trade_locations[trade_constant] = location
                        break
                except Exception as e:
                    continue
        
        return trade_locations

    def extract_treemon_encounters(self):
        """Extract headbutt tree and rock smash encounters"""
        treemons_file = self.base_path / "data" / "wild" / "treemons.asm"
        treemon_maps_file = self.base_path / "data" / "wild" / "treemon_maps.asm"
        
        # First, parse the treemon sets to get Pokemon for each set
        treemon_sets = self._parse_treemon_sets(treemons_file)
        
        # Then, parse the map assignments to associate locations with treemon sets
        self._parse_treemon_maps(treemon_maps_file, treemon_sets)
    
    def _parse_treemon_sets(self, file_path: Path) -> Dict[str, Set[str]]:
        """Parse treemons.asm to get Pokemon for each treemon set"""
        treemon_sets = {}
        
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Find treemon set definitions
        current_set = None
        for line in content.split('\n'):
            line = line.strip()
            
            # Check for treemon set definition (e.g., "TreeMonSet_Canyon:")
            if line.startswith('TreeMonSet_') and line.endswith(':'):
                current_set = line.replace(':', '').replace('TreeMonSet_', 'TREEMON_SET_').upper()
                treemon_sets[current_set] = set()
                continue
            
            # Check for Pokemon encounter line (e.g., "dbbw 50, 10, SPEAROW")
            if current_set and line.startswith('dbbw'):
                # Extract Pokemon name from the line
                parts = line.split(',')
                if len(parts) >= 3:
                    pokemon = parts[2].strip()
                    if pokemon in self.pokemon_list:
                        treemon_sets[current_set].add(pokemon)
            
            # Reset current set on end marker or empty line after set
            if line == 'db -1' or (current_set and line == ''):
                current_set = None
        
        return treemon_sets
    
    def _parse_treemon_maps(self, file_path: Path, treemon_sets: Dict[str, Set[str]]):
        """Parse treemon_maps.asm to associate locations with treemon sets"""
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        lines = content.split('\n')
        in_treemon_maps = False
        in_rockmon_maps = False
        
        for line in lines:
            line = line.strip()
            
            # Track which section we're in
            if line == 'TreeMonMaps:':
                in_treemon_maps = True
                in_rockmon_maps = False
                continue
            elif line == 'RockMonMaps:':
                in_treemon_maps = False
                in_rockmon_maps = True
                continue
            elif line == 'db -1':
                in_treemon_maps = False
                in_rockmon_maps = False
                continue
            
            # Parse treemon_map lines
            if (in_treemon_maps or in_rockmon_maps) and line.startswith('treemon_map'):
                # Extract location and treemon set (e.g., "treemon_map ROUTE_26, TREEMON_SET_KANTO")
                parts = line.replace('treemon_map', '').strip().split(',')
                if len(parts) >= 2:
                    location = parts[0].strip()
                    treemon_set = parts[1].strip()
                    
                    # Format location name
                    formatted_location = self._format_location_name(location)
                    
                    # Get Pokemon from this treemon set
                    if treemon_set in treemon_sets:
                        for pokemon in treemon_sets[treemon_set]:
                            if in_treemon_maps:
                                # Headbutt encounters
                                if pokemon not in self.headbutt_encounters:
                                    self.headbutt_encounters[pokemon] = set()
                                self.headbutt_encounters[pokemon].add(formatted_location)
                            elif in_rockmon_maps:
                                # Rock smash encounters
                                if pokemon not in self.rock_smash_encounters:
                                    self.rock_smash_encounters[pokemon] = set()
                                self.rock_smash_encounters[pokemon].add(formatted_location)

    def extract_bug_contest_pokemon(self):
        """Extract Pokemon available in the Bug Catching Contest"""
        bug_contest_file = self.base_path / "data" / "wild" / "bug_contest_mons.asm"
        
        with open(bug_contest_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Parse lines with format: dbwbb %, SPECIES, min, max
        # Only include Pokemon with positive percentages (negative means they don't appear)
        contest_pattern = r'dbwbb\s+(\d+),\s+([A-Z_]+),'
        matches = re.findall(contest_pattern, content)
        
        for percentage, pokemon in matches:
            if pokemon in self.pokemon_list and int(percentage) > 0:
                self.bug_contest_pokemon.add(pokemon)

    def extract_static_pokemon(self):
        """Extract static Pokemon from map files using loadwildmon command"""
        maps_dir = self.base_path / "maps"
        
        for map_file in maps_dir.glob("*.asm"):
            self._parse_static_pokemon_from_map(map_file)
    
    def _parse_static_pokemon_from_map(self, file_path: Path):
        """Parse a single map file for static Pokemon encounters"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Look for loadwildmon commands: loadwildmon POKEMON, level
            # But exclude tutorial encounters (those followed by catchtutorial)
            lines = content.split('\n')
            
            for i, line in enumerate(lines):
                line = line.strip()
                if 'loadwildmon' in line:
                    # Check if this is followed by catchtutorial (tutorial encounter)
                    is_tutorial = False
                    # Look ahead a few lines to see if catchtutorial appears
                    for j in range(i + 1, min(i + 5, len(lines))):
                        if 'catchtutorial' in lines[j]:
                            is_tutorial = True
                            break
                    
                    # Only process non-tutorial encounters
                    if not is_tutorial:
                        loadwildmon_pattern = r'loadwildmon\s+([A-Z_]+)(?:,\s*\d+)?'
                        matches = re.findall(loadwildmon_pattern, line)
                        
                        for pokemon in matches:
                            if pokemon in self.pokemon_list:
                                if pokemon not in self.static_pokemon:
                                    self.static_pokemon[pokemon] = set()
                                # Remove file extension and format location name
                                location = file_path.stem
                                formatted_location = self._format_location_name(location)
                                self.static_pokemon[pokemon].add(formatted_location)
                    
        except Exception as e:
            print(f"Error parsing {file_path}: {e}")

    def extract_fishing_encounters(self):
        """Extract fishing encounters from fish.asm and maps data"""
        fish_file = self.base_path / "data" / "wild" / "fish.asm"
        maps_file = self.base_path / "data" / "maps" / "maps.asm"
        
        # First, parse the fishing encounter data
        fish_groups = self._parse_fish_file(fish_file)
        
        # Then, parse the maps to see which locations use which fish groups
        self._parse_fishing_maps(maps_file, fish_groups)
        
    def _parse_fish_file(self, file_path: Path) -> Dict[str, Dict[str, List[Tuple[str, int, str]]]]:
        """Parse fish.asm to extract fishing encounter data"""
        fish_groups = {}
        
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        lines = content.split('\n')
        current_group = None
        current_rod = None
        time_fish_groups = {}
        
        # First pass: extract TimeFishGroups data
        in_time_fish_groups = False
        time_group_index = 0
        
        for line in lines:
            line = line.strip()
            
            if line == 'TimeFishGroups:':
                in_time_fish_groups = True
                continue
            
            if in_time_fish_groups and line.startswith('dbwbw'):
                # Parse: dbwbw 20, CORSOLA, 20, STARYU ; 0
                match = re.search(r'dbwbw\s+(\d+),\s+([A-Z_]+),\s*(\d+),\s+([A-Z_]+)', line)
                if match:
                    day_level, day_pokemon, night_level, night_pokemon = match.groups()
                    time_fish_groups[time_group_index] = {
                        'day': (day_pokemon, int(day_level)),
                        'night': (night_pokemon, int(night_level))
                    }
                    time_group_index += 1
        
        # Second pass: extract fish group encounter tables
        for line in lines:
            line = line.strip()
            
            # Check for fish group start (e.g., ".Shore_Old:")
            if line.startswith('.') and line.endswith('_Old:'):
                group_name = line[1:-5]  # Remove '.' and '_Old:'
                current_group = group_name
                current_rod = 'Old'
                if current_group not in fish_groups:
                    fish_groups[current_group] = {'Old': [], 'Good': [], 'Super': []}
                continue
            elif line.startswith('.') and line.endswith('_Good:'):
                group_name = line[1:-6]  # Remove '.' and '_Good:'
                current_group = group_name
                current_rod = 'Good'
                if current_group not in fish_groups:
                    fish_groups[current_group] = {'Old': [], 'Good': [], 'Super': []}
                continue
            elif line.startswith('.') and line.endswith('_Super:'):
                group_name = line[1:-7]  # Remove '.' and '_Super:'
                current_group = group_name
                current_rod = 'Super'
                if current_group not in fish_groups:
                    fish_groups[current_group] = {'Old': [], 'Good': [], 'Super': []}
                continue
            
            # Parse encounter lines (e.g., "dbbw 70 percent + 1, 10, MAGIKARP")
            if current_group and current_rod and line.startswith('dbbw'):
                match = re.search(r'dbbw\s+\d+[^,]*,\s*(\d+),\s+([A-Z_]+)', line)
                if match:
                    level, pokemon = match.groups()
                    level = int(level)
                    
                    if pokemon == 'TIME_GROUP':
                        # Handle time group encounters
                        if level in time_fish_groups:
                            day_pokemon, day_level = time_fish_groups[level]['day']
                            night_pokemon, night_level = time_fish_groups[level]['night']
                            
                            if day_pokemon in self.pokemon_list:
                                fish_groups[current_group][current_rod].append((day_pokemon, day_level, 'day'))
                            if night_pokemon in self.pokemon_list and night_pokemon != day_pokemon:
                                fish_groups[current_group][current_rod].append((night_pokemon, night_level, 'night'))
                    elif pokemon in self.pokemon_list:
                        fish_groups[current_group][current_rod].append((pokemon, level, ''))
        
        return fish_groups
    
    def _parse_fishing_maps(self, file_path: Path, fish_groups: Dict[str, Dict[str, List[Tuple[str, int, str]]]]):
        """Parse maps.asm to associate locations with fish groups and store Pokemon by fish group"""
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Map fishgroup constants to names
        fishgroup_names = {
            'FISHGROUP_SHORE': 'Shore',
            'FISHGROUP_OCEAN': 'Ocean', 
            'FISHGROUP_LAKE': 'Lake',
            'FISHGROUP_POND': 'Pond',
            'FISHGROUP_DRATINI': 'Dratini',
            'FISHGROUP_QWILFISH_SWARM': 'Qwilfish Swarm',
            'FISHGROUP_GYARADOS': 'Gyarados',
            'FISHGROUP_DRATINI_2': 'Dratini 2',
            'FISHGROUP_WHIRL_ISLANDS': 'Whirl Islands',
            'FISHGROUP_QWILFISH': 'Qwilfish',
        }
        
        # First pass: collect all locations for each fish group
        lines = content.split('\n')
        for line in lines:
            line = line.strip()
            
            # Look for map entries that include fishgroup info
            if line.startswith('map ') and any(fg in line for fg in fishgroup_names.keys()):
                # Extract map name and fishgroup
                parts = line.split(',')
                if len(parts) >= 8:  # Ensure we have enough parts
                    map_name = parts[0].replace('map ', '').strip()
                    fishgroup_constant = parts[7].strip()
                    
                    if fishgroup_constant in fishgroup_names:
                        fishgroup_name = fishgroup_names[fishgroup_constant]
                        formatted_location = self._format_location_name(map_name)
                        
                        # Store location for this fish group
                        if fishgroup_name not in self.fish_group_locations:
                            self.fish_group_locations[fishgroup_name] = set()
                        self.fish_group_locations[fishgroup_name].add(formatted_location)
        
        # Second pass: associate Pokemon with fish groups
        # Create a mapping from parsed fish group names to formatted names
        parsed_to_formatted = {
            'Shore': 'Shore',
            'Ocean': 'Ocean',
            'Lake': 'Lake', 
            'Pond': 'Pond',
            'Dratini': 'Dratini',
            'Qwilfish_Swarm': 'Qwilfish Swarm',
            'Gyarados': 'Gyarados',
            'Dratini_2': 'Dratini 2',
            'WhirlIslands': 'Whirl Islands',
            'Qwilfish': 'Qwilfish',
        }
        
        for fishgroup_name, rod_data in fish_groups.items():
            for rod_type, encounters in rod_data.items():
                for pokemon, level, time_suffix in encounters:
                    # Use the formatted name if available, otherwise use original
                    formatted_fishgroup_name = parsed_to_formatted.get(fishgroup_name, fishgroup_name)
                    
                    fishgroup_display = formatted_fishgroup_name
                    if time_suffix:
                        fishgroup_display += f" ({time_suffix})"
                    
                    # Store Pokemon in appropriate rod dictionary by fish group
                    if rod_type == 'Old':
                        if pokemon not in self.old_rod_fish_groups:
                            self.old_rod_fish_groups[pokemon] = set()
                        self.old_rod_fish_groups[pokemon].add(fishgroup_display)
                    elif rod_type == 'Good':
                        if pokemon not in self.good_rod_fish_groups:
                            self.good_rod_fish_groups[pokemon] = set()
                        self.good_rod_fish_groups[pokemon].add(fishgroup_display)
                    elif rod_type == 'Super':
                        if pokemon not in self.super_rod_fish_groups:
                            self.super_rod_fish_groups[pokemon] = set()
                        self.super_rod_fish_groups[pokemon].add(fishgroup_display)

    def extract_first_stages(self):
        """Extract Pokemon that are listed in first_stages.asm"""
        first_stages_file = self.base_path / "data" / "pokemon" / "first_stages.asm"
        
        with open(first_stages_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Find all "dw POKEMON_NAME" lines
        pokemon_pattern = r'dw\s+([A-Z_]+)'
        matches = re.findall(pokemon_pattern, content)
        
        for pokemon in matches:
            if pokemon in self.pokemon_list:
                self.first_stage_pokemon.add(pokemon)
        
        print(f"Found {len(self.first_stage_pokemon)} Pokemon that are first stages")

    def can_breed(self, pokemon: str) -> bool:
        """Check if a Pokemon can breed by examining its egg groups"""
        # Convert Pokemon name to lowercase for filename
        pokemon_filename = pokemon.lower()
        base_stats_file = self.base_path / "data" / "pokemon" / "base_stats" / f"{pokemon_filename}.asm"
        
        if not base_stats_file.exists():
            return False
        
        try:
            with open(base_stats_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Look for the egg groups line (format: dn EGG_GROUP1, EGG_GROUP2)
            egg_groups_pattern = r'.*dn\s+([A-Z_0-9]+),\s*([A-Z_0-9]+).*egg groups'
            match = re.search(egg_groups_pattern, content)
            
            if match:
                egg_group1, egg_group2 = match.groups()
                # Pokemon can breed if at least one egg group is not EGG_DITTO or EGG_NONE
                return egg_group1 not in ['EGG_DITTO', 'EGG_NONE'] or egg_group2 not in ['EGG_DITTO', 'EGG_NONE']
            
        except Exception as e:
            print(f"Error reading base stats for {pokemon}: {e}")
        
        return False

    def get_evolution_chain(self, pokemon: str) -> Set[str]:
        """Get all Pokemon in the evolution chain starting from the given Pokemon"""
        evolution_chain = {pokemon}
        
        # Find all Pokemon that evolve from this one
        for evolved_pokemon, pre_evolutions in self.evolutions.items():
            if pokemon in pre_evolutions:
                # Recursively get the evolution chain for the evolved form
                evolved_chain = self.get_evolution_chain(evolved_pokemon)
                evolution_chain.update(evolved_chain)
        
        return evolution_chain

    def determine_egg_hatchability(self):
        """Determine which Pokemon can be hatched from eggs"""
        for pokemon in self.pokemon_list:
            can_hatch = False
            
            # Only Pokemon in first_stages.asm can potentially be hatched
            if pokemon in self.first_stage_pokemon:
                # Get the full evolution chain starting from this first stage
                evolution_chain = self.get_evolution_chain(pokemon)
                
                # Check if any Pokemon in the evolution chain can breed
                for chain_pokemon in evolution_chain:
                    if self.can_breed(chain_pokemon):
                        can_hatch = True
                        break
            
            self.egg_hatchable[pokemon] = can_hatch
        
        hatchable_count = sum(1 for can_hatch in self.egg_hatchable.values() if can_hatch)
        print(f"Found {hatchable_count} Pokemon that can be hatched from eggs")

    def add_override(self, pokemon: str, category: str, location: str):
        """Add a manual override for Pokemon location data"""
        if pokemon not in self.overrides:
            self.overrides[pokemon] = {}
        if category not in self.overrides[pokemon]:
            self.overrides[pokemon][category] = set()
        self.overrides[pokemon][category].add(location)
        
    def generate_csv(self, output_file: str = "pokemon_data.csv"):
        """Generate the CSV file with all Pokemon data"""
        with open(output_file, 'w', newline='', encoding='utf-8') as csvfile:
            fieldnames = ['Pokemon Name', 'Johto Morning Wild', 'Johto Day Wild', 'Johto Night Wild', 'Kanto Morning Wild', 'Kanto Day Wild', 'Kanto Night Wild', 'Johto Water', 'Kanto Water', 'Old Rod Fish Groups', 'Good Rod Fish Groups', 'Super Rod Fish Groups', 'Gift Locations', 'NPC Trade Locations', 'Headbutt Tree Locations', 'Rock Smash Locations', 'Static Locations', 'Evolves From', 'Can be Hatched from an Egg']
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            
            writer.writeheader()
            
            for pokemon in self.pokemon_list:  # Keep original order from pokemon_constants.asm
                # Get data for this Pokemon
                johto_morning_locations = self._get_locations(pokemon, 'johto_morning')
                johto_day_locations = self._get_locations(pokemon, 'johto_day')
                johto_night_locations = self._get_locations(pokemon, 'johto_night')
                kanto_morning_locations = self._get_locations(pokemon, 'kanto_morning')
                kanto_day_locations = self._get_locations(pokemon, 'kanto_day')
                kanto_night_locations = self._get_locations(pokemon, 'kanto_night')
                johto_water_locations = self._get_locations(pokemon, 'johto_water')
                kanto_water_locations = self._get_locations(pokemon, 'kanto_water')
                old_rod_fish_groups = self._get_locations(pokemon, 'old_rod')
                good_rod_fish_groups = self._get_locations(pokemon, 'good_rod')
                super_rod_fish_groups = self._get_locations(pokemon, 'super_rod')
                gift_locations = self._get_locations(pokemon, 'gift')
                npc_trade_locations = self._get_locations(pokemon, 'npc_trade')
                headbutt_locations = self._get_locations(pokemon, 'headbutt')
                rock_smash_locations = self._get_locations(pokemon, 'rock_smash')
                static_locations = self._get_locations(pokemon, 'static')
                evolves_from = self._get_locations(pokemon, 'evolution')
                
                writer.writerow({
                    'Pokemon Name': pokemon,
                    'Johto Morning Wild': ', '.join(sorted(johto_morning_locations)) if johto_morning_locations else '',
                    'Johto Day Wild': ', '.join(sorted(johto_day_locations)) if johto_day_locations else '',
                    'Johto Night Wild': ', '.join(sorted(johto_night_locations)) if johto_night_locations else '',
                    'Kanto Morning Wild': ', '.join(sorted(kanto_morning_locations)) if kanto_morning_locations else '',
                    'Kanto Day Wild': ', '.join(sorted(kanto_day_locations)) if kanto_day_locations else '',
                    'Kanto Night Wild': ', '.join(sorted(kanto_night_locations)) if kanto_night_locations else '',
                    'Johto Water': ', '.join(sorted(johto_water_locations)) if johto_water_locations else '',
                    'Kanto Water': ', '.join(sorted(kanto_water_locations)) if kanto_water_locations else '',
                    'Old Rod Fish Groups': ', '.join(sorted(old_rod_fish_groups)) if old_rod_fish_groups else '',
                    'Good Rod Fish Groups': ', '.join(sorted(good_rod_fish_groups)) if good_rod_fish_groups else '',
                    'Super Rod Fish Groups': ', '.join(sorted(super_rod_fish_groups)) if super_rod_fish_groups else '',
                    'Gift Locations': ', '.join(sorted(gift_locations)) if gift_locations else '',
                    'NPC Trade Locations': ', '.join(sorted(npc_trade_locations)) if npc_trade_locations else '',
                    'Headbutt Tree Locations': ', '.join(sorted(headbutt_locations)) if headbutt_locations else '',
                    'Rock Smash Locations': ', '.join(sorted(rock_smash_locations)) if rock_smash_locations else '',
                    'Static Locations': ', '.join(sorted(static_locations)) if static_locations else '',
                    'Evolves From': ', '.join(sorted(evolves_from)) if evolves_from else '',
                    'Can be Hatched from an Egg': 'Yes' if self.egg_hatchable.get(pokemon, False) else 'No'
                })
                
        print(f"CSV file generated: {output_file}")
        
        # Generate fish group locations reference file
        self.generate_fish_groups_csv()
        
    def generate_fish_groups_csv(self, output_file: str = "fish_groups.csv"):
        """Generate a separate CSV file showing which locations belong to each fish group"""
        with open(output_file, 'w', newline='', encoding='utf-8') as csvfile:
            fieldnames = ['Fish Group', 'Locations']
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            
            writer.writeheader()
            
            for fish_group, locations in sorted(self.fish_group_locations.items()):
                writer.writerow({
                    'Fish Group': fish_group,
                    'Locations': ', '.join(sorted(locations))
                })
                
        print(f"Fish groups reference file generated: {output_file}")
        
    def _get_locations(self, pokemon: str, category: str) -> Set[str]:
        """Get locations for a Pokemon, including overrides"""
        locations = set()
        
        # Get base data
        if category == 'johto_morning':
            locations.update(self.johto_morning_encounters.get(pokemon, set()))
            # Add Bug Catching Contest for applicable Pokemon
            if pokemon in self.bug_contest_pokemon:
                locations.add("Bug Catching Contest")
        elif category == 'johto_day':
            locations.update(self.johto_day_encounters.get(pokemon, set()))
            # Add Bug Catching Contest for applicable Pokemon
            if pokemon in self.bug_contest_pokemon:
                locations.add("Bug Catching Contest")
        elif category == 'johto_night':
            locations.update(self.johto_night_encounters.get(pokemon, set()))
            # Add Bug Catching Contest for applicable Pokemon
            if pokemon in self.bug_contest_pokemon:
                locations.add("Bug Catching Contest")
        elif category == 'kanto_morning':
            locations.update(self.kanto_morning_encounters.get(pokemon, set()))
        elif category == 'kanto_day':
            locations.update(self.kanto_day_encounters.get(pokemon, set()))
        elif category == 'kanto_night':
            locations.update(self.kanto_night_encounters.get(pokemon, set()))
        elif category == 'johto_water':
            locations.update(self.johto_water_encounters.get(pokemon, set()))
        elif category == 'kanto_water':
            locations.update(self.kanto_water_encounters.get(pokemon, set()))
        elif category == 'old_rod':
            locations.update(self.old_rod_fish_groups.get(pokemon, set()))
        elif category == 'good_rod':
            locations.update(self.good_rod_fish_groups.get(pokemon, set()))
        elif category == 'super_rod':
            locations.update(self.super_rod_fish_groups.get(pokemon, set()))
        elif category == 'gift':
            locations.update(self.gift_pokemon.get(pokemon, set()))
        elif category == 'npc_trade':
            locations.update(self.npc_trades.get(pokemon, set()))
        elif category == 'headbutt':
            locations.update(self.headbutt_encounters.get(pokemon, set()))
        elif category == 'rock_smash':
            locations.update(self.rock_smash_encounters.get(pokemon, set()))
        elif category == 'static':
            locations.update(self.static_pokemon.get(pokemon, set()))
        elif category == 'evolution':
            locations.update(self.evolutions.get(pokemon, set()))
            
        # Apply overrides
        if pokemon in self.overrides and category in self.overrides[pokemon]:
            locations.update(self.overrides[pokemon][category])
            
        # Deduplicate fishing groups to remove redundancy
        if category in ['old_rod', 'good_rod', 'super_rod']:
            locations = self._deduplicate_fish_groups(locations)
            
        return locations
    
    def _deduplicate_fish_groups(self, fish_groups: Set[str]) -> Set[str]:
        """Remove redundant time-specific fish group entries when base group exists"""
        deduplicated = set()
        base_groups = set()
        time_specific_groups = set()
        
        # Separate base groups from time-specific ones
        for group in fish_groups:
            if ' (day)' in group or ' (night)' in group:
                base_group = group.split(' (')[0]
                time_specific_groups.add(group)
                base_groups.add(base_group)
            else:
                base_groups.add(group)
                deduplicated.add(group)
        
        # Add time-specific groups only if their base group doesn't exist
        for group in time_specific_groups:
            base_group = group.split(' (')[0]
            if base_group not in deduplicated:
                deduplicated.add(group)
        
        return deduplicated
        
    def run_extraction(self):
        """Run the complete extraction process"""
        print("Starting Pokemon data extraction...")
        
        print("1. Extracting Pokemon constants...")
        self.extract_pokemon_constants()
        
        print("2. Extracting wild encounters...")
        self.extract_wild_encounters()
        
        print("3. Extracting gift Pokemon...")
        self.extract_gift_pokemon()
        
        print("4. Extracting evolution data...")
        self.extract_evolutions()
        
        print("5. Extracting NPC trades...")
        self.extract_npc_trades()
        
        print("6. Extracting headbutt and rock smash encounters...")
        self.extract_treemon_encounters()
        
        print("7. Extracting Bug Catching Contest Pokemon...")
        self.extract_bug_contest_pokemon()
        
        print("8. Extracting static Pokemon...")
        self.extract_static_pokemon()
        
        print("9. Extracting fishing encounters...")
        self.extract_fishing_encounters()
        
        print("10. Extracting first stage Pokemon...")
        self.extract_first_stages()
        
        print("11. Determining egg hatchability...")
        self.determine_egg_hatchability()
        
        print("12. Generating CSV...")
        self.generate_csv()
        
        print("Extraction complete!")
        
        # Print some statistics
        print(f"\nStatistics:")
        print(f"Total Pokemon: {len(self.pokemon_list)}")
        print(f"Pokemon found in Johto morning wild: {len(self.johto_morning_encounters)}")
        print(f"Pokemon found in Johto day wild: {len(self.johto_day_encounters)}")
        print(f"Pokemon found in Johto night wild: {len(self.johto_night_encounters)}")
        print(f"Pokemon found in Kanto morning wild: {len(self.kanto_morning_encounters)}")
        print(f"Pokemon found in Kanto day wild: {len(self.kanto_day_encounters)}")
        print(f"Pokemon found in Kanto night wild: {len(self.kanto_night_encounters)}")
        print(f"Pokemon found in Johto water: {len(self.johto_water_encounters)}")
        print(f"Pokemon found in Kanto water: {len(self.kanto_water_encounters)}")
        print(f"Pokemon found via Old Rod: {len(self.old_rod_fish_groups)}")
        print(f"Pokemon found via Good Rod: {len(self.good_rod_fish_groups)}")
        print(f"Pokemon found via Super Rod: {len(self.super_rod_fish_groups)}")
        print(f"Total fish groups: {len(self.fish_group_locations)}")
        print(f"Pokemon given as gifts: {len(self.gift_pokemon)}")
        print(f"Pokemon available via NPC trades: {len(self.npc_trades)}")
        print(f"Pokemon found via headbutt trees: {len(self.headbutt_encounters)}")
        print(f"Pokemon found via rock smash: {len(self.rock_smash_encounters)}")
        print(f"Pokemon in Bug Catching Contest: {len(self.bug_contest_pokemon)}")
        print(f"Pokemon found as static encounters: {len(self.static_pokemon)}")
        print(f"Pokemon with evolution data: {len(self.evolutions)}")
        print(f"Pokemon that can be hatched from eggs: {sum(1 for can_hatch in self.egg_hatchable.values() if can_hatch)}")


def main():
    """Main function to run the extractor"""
    # Set the base path to the project root directory (3 levels up from this script)
    script_dir = os.path.dirname(os.path.abspath(__file__))
    base_path = os.path.join(script_dir, "..", "..", "..")
    
    extractor = PokemonDataExtractor(base_path)
    
    # Example of adding overrides (as mentioned in the requirements)
    # Special pointer overrides - these are harder to detect automatically
    extractor.add_override("SHUCKLE", "gift", "Mania's House (Olivine City)")
    
    # You can add more overrides here in the future:
    # extractor.add_override("TOGEPI", "gift", "Professor Elm's assistant (after completing Pokedex)")
    # extractor.add_override("LAPRAS", "gift", "Union Cave (Fridays)")
    
    extractor.run_extraction()


if __name__ == "__main__":
    main()
