import os
import json

def count_debt():
    debt_markers = ["TODO", "FIXME", "XXX", "HACK"]
    results = {marker: 0 for marker in debt_markers}
    file_details = []
    
    for root, dirs, files in os.walk("lib"):
        for file in files:
            if file.endswith(".dart"):
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, "r", encoding="utf-8") as f:
                        lines = f.readlines()
                        file_debt = {marker: 0 for marker in debt_markers}
                        for i, line in enumerate(lines):
                            for marker in debt_markers:
                                if marker in line:
                                    results[marker] += 1
                                    file_debt[marker] += 1
                        
                        if sum(file_debt.values()) > 0:
                            file_details.append({
                                "file": os.path.relpath(file_path, "lib"),
                                "debt": file_debt
                            })
                except:
                    pass
                    
    return {
        "summary": results,
        "total": sum(results.values()),
        "top_files": sorted(file_details, key=lambda x: sum(x["debt"].values()), reverse=True)[:5]
    }

if __name__ == "__main__":
    print(json.dumps(count_debt(), indent=2))
