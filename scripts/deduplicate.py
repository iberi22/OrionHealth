import json
import os

def deduplicate(file_path):
    if not os.path.exists(file_path):
        return

    with open(file_path, 'r', encoding='utf-8') as f:
        content = json.load(f)
    
    data_list = content.get("data", [])
    
    unique_data = {}
    for item in data_list:
        code = item["code"]
        if code not in unique_data:
            unique_data[code] = item
        else:
            # Keep the one with more information (more keys)
            if len(item) > len(unique_data[code]):
                unique_data[code] = item
    
    content["data"] = list(unique_data.values())
    content["metadata"]["totalCount"] = len(content["data"])
    
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(content, f, indent=2, ensure_ascii=False)
    
    print(f"Deduplicated {file_path}. New count: {len(content['data'])}")

if __name__ == "__main__":
    deduplicate("medical-standards/icd10.json")
    deduplicate("medical-standards/rxnorm.json")
    deduplicate("medical-standards/loinc.json")
    deduplicate("medical-standards/snomed.json")
