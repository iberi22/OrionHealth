import json
import os

def add_icd10_hierarchy(file_path):
    if not os.path.exists(file_path):
        return

    with open(file_path, 'r', encoding='utf-8') as f:
        content = json.load(f)
    
    data_list = content.get("data", [])
    
    # First, build a map of all codes to their index in the list
    code_to_index = {item["code"]: i for i, item in enumerate(data_list)}
    
    updated_children = 0
    updated_parents = 0
    
    for i in range(len(data_list)):
        code = data_list[i]["code"]
        if "." in code:
            parent_code = code.split(".")[0]
            if parent_code in code_to_index:
                # Update child
                data_list[i]["parentCode"] = parent_code
                updated_children += 1
                
                # Update parent
                parent_idx = code_to_index[parent_code]
                if "childCodes" not in data_list[parent_idx]:
                    data_list[parent_idx]["childCodes"] = []
                
                if code not in data_list[parent_idx]["childCodes"]:
                    data_list[parent_idx]["childCodes"].append(code)
                    updated_parents += 1
    
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(content, f, indent=2, ensure_ascii=False)
    
    print(f"Updated {updated_children} children and {updated_parents} parents.")

if __name__ == "__main__":
    add_icd10_hierarchy("medical-standards/icd10.json")
