"""
Banglish to Bengali Mapping Dictionary
This file is generated from a large JSON dataset to avoid memory overhead of raw JSON parsing repeatedly.
"""

import json
import os

def load_banglish_dictionary():
    try:
        # Load the large dictionary file
        # In a real 20k word scenario, you might want to use a database (SQLite) or a Trie structure
        # for memory efficiency. For now, a Python dict is extremely fast for lookups up to 100k-500k items.
        
        dict_path = os.path.join(os.path.dirname(__file__), 'banglish_dictionary.json')
        
        with open(dict_path, 'r', encoding='utf-8') as f:
            return json.load(f)
            
    except Exception as e:
        print(f"Warning: Could not load Banglish dictionary: {e}")
        return {}

# Load on module import
BANGLISH_TO_BN = load_banglish_dictionary()

# Create a set of keys for O(1) existence checks in Language Detection
BANGLISH_MARKERS_SET = set(BANGLISH_TO_BN.keys())
