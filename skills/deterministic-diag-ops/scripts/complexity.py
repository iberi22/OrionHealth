import os
import re
import json

def calculate_complexity(file_path):
    # Heuristic keywords for control flow
    keywords = [r"\sif\s*\(", r"\selse\s+", r"\selse\s*if", r"\swhile\s*\(", r"\sfor\s*\(", r"\scase\s+", r"\scatch\s*\(", r"&&", r"\|\|", r"\?\:"]
    complexity = 1 # Base complexity
    
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()
            for kw in keywords:
                complexity += len(re.findall(kw, content))
    except:
        return 0
        
    return complexity

def analyze_complexity():
    results = []
    for root, dirs, files in os.walk("lib"):
        for file in files:
            if file.endswith(".dart"):
                file_path = os.path.join(root, file)
                complexity = calculate_complexity(file_path)
                results.append({
                    "file": os.path.relpath(file_path, "lib"),
                    "complexity": complexity
                })
                
    # Sort by complexity
    return sorted(results, key=lambda x: x["complexity"], reverse=True)[:10]

if __name__ == "__main__":
    print(json.dumps(analyze_complexity(), indent=2))
