import subprocess
import json
import os
import datetime
import sys

# Ensure scripts can be imported or run
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

def run_script(name):
    try:
        result = subprocess.run([sys.executable, os.path.join(SCRIPT_DIR, name)], capture_output=True, text=True)
        if result.returncode == 0:
            return json.loads(result.stdout)
        else:
            return {"status": "ERROR", "error": result.stderr}
    except Exception as e:
        return {"status": "ERROR", "error": str(e)}

def run_command(cmd, is_json=True):
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, shell=True)
        if is_json:
            return json.loads(result.stdout)
        return result.stdout
    except Exception as e:
        return {"status": "ERROR", "error": str(e)}

def calculate_confidence(audit_results):
    # Heuristic for confidence based on successful tool execution
    score = 100
    errors = 0
    if audit_results["env"].get("status") == "ERROR": score -= 30; errors += 1
    if audit_results["integrity"].get("status") == "ERROR": score -= 30; errors += 1
    if audit_results["arch"].get("status") == "ERROR": score -= 30; errors += 1
    
    return max(0, score)

def generate_report(data):
    template_path = os.path.join(SCRIPT_DIR, "report_template.md")
    if os.path.exists(template_path):
        with open(template_path, "r", encoding="utf-8") as f:
            template = f.read()
    else:
        template = "# DIAGNOSTIC REPORT\n\n{json_data}"

    # Simple placeholder replacement
    report = template.replace("{timestamp}", str(datetime.datetime.now()))
    report = report.replace("{confidence}", str(data["confidence"]))
    
    # Env table
    env = data["env"]
    env_str = f"| OS | {env.get('os', {}).get('system')} |\n| Flutter | {env.get('toolchain', {}).get('flutter', 'N/A').split('\\n')[0]} |"
    report = report.replace("{env_table}", env_str)
    
    # Tech Debt & Complexity
    debt = data["tech_debt"]
    complexity = data["complexity"]
    metrics_str = f"| Metric | Value |\n| :--- | :--- |\n| Total Tech Debt (TODOs) | {debt.get('total', 0)} |\n| Max Complexity | {complexity[0]['complexity'] if complexity else 'N/A'} ({complexity[0]['file'] if complexity else ''}) |"
    report = report.replace("{metrics_table}", metrics_str)
    
    # Integrity
    integrity = data["integrity"]
    integ_status = "✅ PASS" if integrity.get("codebase", {}).get("status") == "PASS" else "❌ FAIL"
    report = report.replace("{integrity_status}", integ_status)
    
    # Architecture
    arch = data["arch"]
    arch_status = "✅ PASS" if arch.get("status") == "PASS" else "❌ FAIL"
    report = report.replace("{arch_status}", arch_status)
    
    # Actionable Tasks
    tasks = []
    if arch.get("status") == "FAIL":
        tasks.append("- [ ] Fix architectural violations in `lib/` (see `diag.json`)")
    if integrity.get("codebase", {}).get("status") != "PASS":
        tasks.append("- [ ] Run `flutter pub get` to sync dependencies")
        
    report = report.replace("{actionable_tasks}", "\n".join(tasks) if tasks else "No critical issues detected.")

    with open("DIAGNOSTIC_REPORT.md", "w", encoding="utf-8") as f:
        f.write(report)
    
    with open("diag.json", "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)

def main():
    print("Starting Deterministic Project Diagnosis...")
    
    data = {
        "timestamp": str(datetime.datetime.now()),
        "env": run_script("audit_env.py"),
        "integrity": run_script("verify_integrity.py"),
        "arch": run_script("verify_architecture.py"),
        "tech_debt": run_script("tech_debt.py"),
        "complexity": run_script("complexity.py"),
        "coverage": run_script("verify_coverage.py"),
        "outdated": run_command("flutter pub outdated --json"),
    }
    
    data["confidence"] = calculate_confidence(data)
    
    generate_report(data)
    print("Diagnosis complete. Report generated: DIAGNOSTIC_REPORT.md")

if __name__ == "__main__":
    main()
