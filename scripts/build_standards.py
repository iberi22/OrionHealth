#!/usr/bin/env python3
"""
Generate all 4 medical standards JSON files for OrionHealth.
All codes are real and sourced from WHO ICD-10, LOINC, RxNorm, and SNOMED CT.
"""
import json, os, re

OUT_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "medical-standards")
os.makedirs(OUT_DIR, exist_ok=True)

def wslug(name):
    s = name.replace("/", " ").replace(",", "").replace("[", "").replace("]", "").replace("(", "").replace(")", "")
    s = re.sub(r'\s+', '_', s.strip().lower())
    return s

# ============================
# HEADER BUILDER FUNCTION
# ============================
def build(meta_key, entries):
    """Build a complete standard JSON from entries list of tuples."""
    keys = {
        "icd10": {"standard": "ICD-10", "version": "2024-1", "lastUpdated": "2026-05-02", "source": "WHO", "sourceUrl": "https://icd.who.int/browse10/2019/en", "license": "WHO ICD-10 License", "wikipediaBase": "https://en.wikipedia.org/wiki/List_of_ICD-10_codes"},
        "loinc": {"standard": "LOINC", "version": "2.74", "lastUpdated": "2026-03-01", "source": "Regenstrief Institute", "sourceUrl": "https://loinc.org/", "license": "LOINC License", "wikipediaBase": "https://en.wikipedia.org/wiki/LOINC"},
        "rxnorm": {"standard": "RxNorm", "version": "2024-03-04", "lastUpdated": "2026-05-02", "source": "NLM RxNorm", "sourceUrl": "https://www.nlm.nih.gov/research/umls/rxnorm/", "license": "UMLS License", "wikipediaBase": ""},
        "snomed": {"standard": "SNOMED CT", "version": "2024-07-31", "lastUpdated": "2026-05-02", "source": "SNOMED International", "sourceUrl": "https://www.snomed.org/", "license": "SNOMED CT License Required", "wikipediaBase": ""},
    }
    meta = keys[meta_key]
    data = []
    for entry in entries:
        code, name, cat, terms = entry[0], entry[1], entry[2], entry[3]
        obj = {"code": code, "displayName": name, "category": cat, "searchTerms": terms}
        if isinstance(terms, str):
            obj["searchTerms"] = [t.strip() for t in terms.split(",")]
        data.append(obj)
    meta["totalCount"] = len(data)
    return {"metadata": meta, "data": data}

def save(key, result):
    path = os.path.join(OUT_DIR, f"{key}.json")
    with open(path, "w", encoding="utf-8") as f:
        json.dump(result, f, indent=2, ensure_ascii=False)
    size = os.path.getsize(path)
    print(f"✅ Written {key}.json: {result['metadata']['totalCount']} entries, {size:,} bytes")
    return size
