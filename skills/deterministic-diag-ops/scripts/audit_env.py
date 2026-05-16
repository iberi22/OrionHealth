import subprocess
import platform
import os
import json
import sys

def get_command_output(cmd):
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, shell=True)
        stdout = result.stdout or ""
        stderr = result.stderr or ""
        return (stdout + stderr).strip()
    except Exception as e:
        return f"Error: {str(e)}"

def audit():
    audit_data = {
        "os": {
            "system": platform.system(),
            "release": platform.release(),
            "version": platform.version(),
            "machine": platform.machine()
        },
        "toolchain": {
            "flutter": get_command_output("flutter --version"),
            "dart": get_command_output("dart --version"),
            "python": sys.version
        },
        "binaries": {
            "isar_dll": os.path.exists("isar.dll"),
            "flutter_exe": get_command_output("where flutter"),
            "dart_exe": get_command_output("where dart")
        },
        "environment_vars": {
            "FLUTTER_ROOT": os.environ.get("FLUTTER_ROOT", "Not Set"),
            "PATH_HEALTHY": "flutter" in os.environ.get("PATH", "").lower()
        }
    }
    return audit_data

if __name__ == "__main__":
    print(json.dumps(audit(), indent=2))
