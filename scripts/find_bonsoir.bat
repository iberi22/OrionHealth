@echo off
cd /d E:\scripts-python\orionhealth
python -c "import sys,json; d=json.load(sys.stdin); [print(p['rootUri']) for p in d['packages'] if 'bonsoir' in p['name'] and '_platform' not in p['name'] and '_android' not in p['name'] and '_darwin' not in p['name'] and '_linux' not in p['name'] and '_windows' not in p['name']]" < .dart_tool\package_config.json
