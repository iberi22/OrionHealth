import json
import subprocess
import time
import os
import sys
import urllib.parse

# Ensure stdout uses UTF-8
if sys.stdout.encoding != 'utf-8':
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

def fetch_nlm_data(table, query, fields="code,name", max_list=500):
    encoded_query = urllib.parse.quote(query)
    api_url = f"https://clinicaltables.nlm.nih.gov/api/{table}/v3/search?terms={encoded_query}&maxList={max_list}&df={fields}"
    
    try:
        result = subprocess.run(
            ["curl.exe", "-s", "-H", "User-Agent: OrionHealthBot/1.0", api_url],
            capture_output=True,
            text=True,
            encoding='utf-8'
        )
        if result.returncode == 0 and result.stdout:
            data = json.loads(result.stdout)
            return data[3] if len(data) > 3 else []
    except Exception as e:
        print(f"Error fetching {table} for {query}: {e}")
    return []

def update_json_file(file_path, new_entries, standard_name):
    if not os.path.exists(file_path):
        return

    with open(file_path, 'r', encoding='utf-8') as f:
        content = json.load(f)
    
    data_list = content.get("data", [])
    existing_codes = {str(item["code"]) for item in data_list}
    
    added = 0
    for entry in new_entries:
        if not entry or len(entry) < 2:
            continue
            
        code_str = str(entry[0])
        name = str(entry[1])
        
        if not code_str or not name:
            continue

        if code_str not in existing_codes:
            entry_obj = {
                "code": code_str,
                "displayName": name,
                "category": "",
                "searchTerms": [name]
            }
            data_list.append(entry_obj)
            existing_codes.add(code_str)
            added += 1
    
    content["data"] = data_list
    content["metadata"]["totalCount"] = len(data_list)
    content["metadata"]["lastUpdated"] = time.strftime("%Y-%m-%d")
    
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(content, f, indent=2, ensure_ascii=False)
    
    if added > 0:
        print(f"Added {added} new entries to {file_path}. Total: {len(data_list)}")

def fetch_rxnorm():
    print("Fetching RxTerms (RxNorm) codes...")
    # Use SXDG_RXCUI and DISPLAY_NAME as discovered
    for char in "ABCDEFGHIJKLMNOPQRSTUVWXYZ":
        entries = fetch_nlm_data("rxterms", char, fields="SXDG_RXCUI,DISPLAY_NAME", max_list=200)
        if entries:
            update_json_file("medical-standards/rxnorm.json", entries, "RxNorm")
            time.sleep(1.0)

def fetch_loinc():
    print("Fetching LOINC items...")
    # Use LOINC_NUM and LONG_COMMON_NAME as discovered
    search_terms = ["CBC", "BMP", "Lipid", "Glucose", "TSH", "Hgb", "Sodium", "Potassium", "Creatinine", "Urine"]
    for term in search_terms:
        entries = fetch_nlm_data("loinc_items", term, fields="LOINC_NUM,LONG_COMMON_NAME", max_list=100)
        if entries:
            update_json_file("medical-standards/loinc.json", entries, "LOINC")
            time.sleep(1.0)

if __name__ == "__main__":
    fetch_rxnorm()
    fetch_loinc()
