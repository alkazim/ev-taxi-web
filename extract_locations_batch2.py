import re
import json
import os

def parse_places_data(file_path):
    if not os.path.exists(file_path):
        return []
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    matches = re.finditer(r'"([^"]+)"\s*:\s*\[\s*(-?\d+\.\d+)\s*,\s*(-?\d+\.\d+)\s*\]', content)
    
    locations = []
    for match in matches:
        name = match.group(1)
        lat = float(match.group(2))
        lng = float(match.group(3))
        if name:
            locations.append({"name": name, "lat": lat, "lng": lng})
    
    return locations

if __name__ == "__main__":
    file_path = r"lib\data\places_data.dart"
    all_locations = parse_places_data(file_path)
    
    # Save Batch 2 (100-200)
    batch_2 = all_locations[100:200]
    with open("batch_2.json", "w") as f:
        json.dump(batch_2, f, indent=2)
    print(f"Batch 2 saved to batch_2.json. Total extracted: {len(batch_2)}")
