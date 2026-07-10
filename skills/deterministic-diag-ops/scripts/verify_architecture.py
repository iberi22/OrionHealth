import os
import re
import json

def check_layer_violations():
    violations = []
    lib_path = "lib"
    
    # Layer definitions
    layers = {
        "core": ["core"],
        "features": ["features", "presentation", "domain", "data"],
        "app": ["app", "main.dart"]
    }
    
    # Rules: core should NOT import features
    for root, dirs, files in os.walk(lib_path):
        for file in files:
            if file.endswith(".dart"):
                file_path = os.path.join(root, file)
                rel_path = os.path.relpath(file_path, lib_path)
                
                is_core = any(rel_path.startswith(p) for p in layers["core"])
                
                if is_core:
                    with open(file_path, "r", encoding="utf-8") as f:
                        content = f.read()
                        # Check for imports of features
                        feature_imports = re.findall(r"import\s+['\"]package:orionhealth_health/features/.*?['\"]", content)
                        if feature_imports:
                            violations.append({
                                "file": rel_path,
                                "type": "CORE_IMPORTING_FEATURE",
                                "imports": feature_imports
                            })
                            
    return violations

def audit():
    violations = check_layer_violations()
    return {
        "status": "PASS" if not violations else "FAIL",
        "violations": violations,
        "summary": f"Found {len(violations)} architectural violations."
    }

if __name__ == "__main__":
    print(json.dumps(audit(), indent=2))
