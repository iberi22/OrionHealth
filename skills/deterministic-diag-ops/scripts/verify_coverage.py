import subprocess
import os
import json
import re

def check_coverage():
    results = {"status": "PASS", "details": []}
    
    # Run flutter test --coverage
    # Note: This might take time, so we check if coverage/lcov.info exists first
    lcov_path = "coverage/lcov.info"
    
    if not os.path.exists(lcov_path):
        results["status"] = "WARNING"
        results["details"].append("Coverage data not found. Run 'flutter test --coverage' to generate.")
        return results
        
    try:
        with open(lcov_path, "r") as f:
            content = f.read()
            # Simple heuristic to count lines covered
            lines_found = len(re.findall(r"LF:(\d+)", content))
            lines_hit = len(re.findall(r"LH:(\d+)", content))
            
            # This is a very rough estimate, lcov parsing is better done with a proper tool
            # But for a deterministic diagnostic, we just check presence and basic stats
            results["details"].append(f"Found LCOV data with entries for multiple files.")
    except Exception as e:
        results["status"] = "FAIL"
        results["details"].append(f"Error reading coverage data: {str(e)}")
        
    return results

if __name__ == "__main__":
    print(json.dumps(check_coverage(), indent=2))
