import re
import json
import os

def parse_places_data(file_path):
    if not os.path.exists(file_path):
        return []
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Simple regex to find "Location Name": [lat, lng]
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
    print(f"Total locations found: {len(all_locations)}")
    
    # Output the first 100 for batch 1
    batch_1 = all_locations[:100]
    out_path = "batch_1.json"
    with open(out_path, "w") as f:
        json.dump(batch_1, f, indent=2)
    print(f"Batch 1 saved to {out_path}")
