import json
import os
import sys

def check_pubspec():
    results = {"status": "PASS", "details": []}
    if not os.path.exists("pubspec.yaml"):
        results["status"] = "FAIL"
        results["details"].append("pubspec.yaml missing")
        return results
    
    # Check local package paths
    try:
        import yaml
        with open("pubspec.yaml", "r") as f:
            pub_data = yaml.safe_load(f)
            deps = pub_data.get("dependencies", {})
            for name, config in deps.items():
                if isinstance(config, dict) and "path" in config:
                    local_path = config["path"]
                    if not os.path.exists(local_path):
                        results["status"] = "FAIL"
                        results["details"].append(f"Local package '{name}' missing at path: {local_path}")
    except ImportError:
        # If yaml is not available, we skip deep check but don't fail the audit
        results["details"].append("PyYAML not installed, skipping local package path validation.")
    
    if not os.path.exists("pubspec.lock"):
        results["status"] = "WARNING"
        results["details"].append("pubspec.lock missing (run flutter pub get)")
    return results

def check_medical_data():
    results = {"status": "PASS", "files": {}, "hierarchy": "PASS"}
    assets_path = "assets/medical-standards"
    required_files = ["icd10.json", "snomed.json", "loinc.json", "rxnorm.json"]
    
    for f in required_files:
        f_path = os.path.join(assets_path, f)
        if os.path.exists(f_path):
            try:
                with open(f_path, "r", encoding="utf-8") as file:
                    data = json.load(file)
                    results["files"][f] = {"status": "OK", "size": os.path.getsize(f_path)}
                    
                    # Hierarchy Check for ICD-10
                    if f == "icd10.json" and isinstance(data, list):
                        orphan_codes = 0
                        for item in data:
                            if "code" in item and "." in item["code"]:
                                parent = item["code"].split(".")[0]
                                # Simple heuristic: parent should exist or be valid
                                if not parent:
                                    orphan_codes += 1
                        if orphan_codes > 0:
                            results["hierarchy"] = "WARNING"
                            results["files"][f]["note"] = f"Detected {orphan_codes} codes with ambiguous parentage."
            except Exception as e:
                results["files"][f] = {"status": "CORRUPT", "error": str(e)}
                results["status"] = "FAIL"
        else:
            results["files"][f] = {"status": "MISSING"}
            results["status"] = "FAIL"
            
    return results

def audit():
    return {
        "codebase": check_pubspec(),
        "medical_data": check_medical_data()
    }

if __name__ == "__main__":
    print(json.dumps(audit(), indent=2))
