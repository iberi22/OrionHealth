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

def get_wiki_summary(title):
    if not title:
        return None
    
    # Clean up title for URL
    title = title.replace(" ", "_")
    title = urllib.parse.quote(title)
    
    api_url = f"https://en.wikipedia.org/api/rest_v1/page/summary/{title}"
    
    try:
        result = subprocess.run(
            ["curl.exe", "-s", "-L", "-H", "User-Agent: OrionHealthBot/1.0", api_url],
            capture_output=True,
            text=True,
            encoding='utf-8'
        )
        if result.returncode == 0 and result.stdout:
            try:
                data = json.loads(result.stdout)
                if "extract" in data:
                    return {
                        "definition": data.get("extract"),
                        "url": data.get("content_urls", {}).get("desktop", {}).get("page")
                    }
            except:
                pass
    except Exception as e:
        print(f"Error fetching {title}: {e}")
    return None

def process_file(file_path, limit=50):
    if not os.path.exists(file_path):
        return

    with open(file_path, 'r', encoding='utf-8') as f:
        content = json.load(f)
    
    data_list = content.get("data", [])
    
    print(f"Enriching {file_path} (Limit: {limit})...")
    
    updated = 0
    processed = 0

    # Sort entries: Prioritize parents or those with short codes (more general)
    data_list.sort(key=lambda x: (len(x['code']), not bool(x.get('childCodes'))))

    for i, entry in enumerate(data_list):
        if updated >= limit:
            break

        # If it already has a definition, skip
        if "definition" in entry and entry["definition"]:
            continue
            
        title = entry.get("displayName")
        if title:
            processed += 1
            print(f"[{updated+1}/{limit}] Fetching: {entry['code']} - {title}...")
            result = get_wiki_summary(title)
            
            if result:
                entry["definition"] = result["definition"]
                if not entry.get("wikipediaUrl"):
                    entry["wikipediaUrl"] = result["url"]
                updated += 1
                time.sleep(1.2)
            else:
                # If direct title failed, try without parenthetical info
                if "(" in title:
                    clean_title = title.split("(")[0].strip()
                    print(f"  Trying clean title: {clean_title}...")
                    result = get_wiki_summary(clean_title)
                    if result:
                        entry["definition"] = result["definition"]
                        entry["wikipediaUrl"] = result["url"]
                        updated += 1
                        time.sleep(1.2)
                else:
                    print(f"  Not found.")
    
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(content, f, indent=2, ensure_ascii=False)
    
    print(f"Finished {file_path}. Updated {updated} entries.")

if __name__ == "__main__":
    process_file("medical-standards/icd10.json", limit=60)
    process_file("medical-standards/rxnorm.json", limit=40)
    process_file("medical-standards/loinc.json", limit=20)
