#!/usr/bin/env python3
"""
expand_symptom_mappings.py
==========================
Generates an expanded symptoms_mapping.json from the ICD-10 dataset.

For each ICD-10 code that has meaningful search terms, this script:
  1. Creates a symptom entry using the code's display name and search terms
  2. Assigns confidence weights based on code specificity (chapter/block/code level)
  3. Validates that all referenced codes exist in icd10.json
  4. Outputs a deduplicated, sorted symptoms_mapping.json

Usage:
    python scripts/expand_symptom_mappings.py

Output:
    medical-standards/symptoms_mapping.json
"""

import json
import re
from pathlib import Path
from collections import defaultdict

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

REPO_ROOT = Path(__file__).parent.parent
ICD10_FILE = REPO_ROOT / "medical-standards" / "icd10.json"
OUTPUT_FILE = REPO_ROOT / "medical-standards" / "symptoms_mapping.json"

# Mental health chapters in ICD-10 (F00-F99)
MENTAL_HEALTH_CHAPTERS = {"F"}

# Minimum search terms required to generate a mapping entry
MIN_SEARCH_TERMS = 1

# Maximum matches per symptom entry (keeps JSON compact)
MAX_MATCHES_PER_SYMPTOM = 3

# Score tiers based on code specificity
SCORE_SPECIFIC = 0.92   # 4+ char code (specific diagnosis)
SCORE_BLOCK = 0.78      # 3-char code (block/category)
SCORE_CHAPTER = 0.65    # 1-2 char code (chapter level)


def get_score(code: str) -> float:
    """Return confidence score based on code specificity."""
    clean = re.sub(r'[^A-Z0-9]', '', code.upper())
    if len(clean) >= 4:
        return SCORE_SPECIFIC
    elif len(clean) == 3:
        return SCORE_BLOCK
    return SCORE_CHAPTER


def normalize(text: str) -> str:
    return text.lower().strip()


def load_icd10() -> list[dict]:
    with open(ICD10_FILE, encoding="utf-8") as f:
        data = json.load(f)
    return data.get("data", [])


def build_symptom_entries(codes: list[dict]) -> list[dict]:
    """Build symptom mapping entries from ICD-10 codes."""
    # symptom_text -> list of match entries
    symptom_map: dict[str, list[dict]] = defaultdict(list)

    for entry in codes:
        code = entry.get("code", "")
        display = entry.get("displayName", "")
        search_terms: list[str] = entry.get("searchTerms", [])
        category = entry.get("category", "")

        if not code or not display or not search_terms:
            continue

        score = get_score(code)

        # Primary symptom = first search term (most specific)
        primary_symptom = normalize(search_terms[0])
        if not primary_symptom:
            continue

        match_entry = {
            "code": code,
            "score": score,
            "reason": f"Asociado con {display} ({code})"
        }

        symptom_map[primary_symptom].append({
            "symptom": primary_symptom,
            "searchTerms": [normalize(t) for t in search_terms[1:4]],  # up to 3 aliases
            "category": category,
            "match": match_entry,
            "display": display,
        })

    # Collapse: one entry per unique symptom, top MAX_MATCHES_PER_SYMPTOM matches
    result = []
    seen_symptoms: set[str] = set()

    for symptom, entries in symptom_map.items():
        if symptom in seen_symptoms:
            continue
        seen_symptoms.add(symptom)

        # Collect all search terms across duplicate symptoms
        all_terms: set[str] = set()
        matches: list[dict] = []
        categories: set[str] = set()

        for e in entries:
            all_terms.update(e["searchTerms"])
            matches.append(e["match"])
            if e["category"]:
                categories.add(e["category"])

        # Sort by score descending and limit
        matches.sort(key=lambda m: m["score"], reverse=True)
        matches = matches[:MAX_MATCHES_PER_SYMPTOM]

        result.append({
            "symptom": symptom,
            "searchTerms": sorted(all_terms - {symptom}),
            "categories": sorted(categories),
            "matches": matches,
        })

    return sorted(result, key=lambda r: r["symptom"])


def validate(entries: list[dict], all_codes: set[str]) -> tuple[int, int]:
    """Return (valid_count, invalid_count) — validates all match codes exist."""
    valid, invalid = 0, 0
    for entry in entries:
        for match in entry.get("matches", []):
            code = match.get("code", "")
            if code in all_codes:
                valid += 1
            else:
                invalid += 1
                print(f"  [WARN] Code not found in ICD-10: {code}")
    return valid, invalid


def main():
    print(f"Loading {ICD10_FILE}...")
    codes = load_icd10()
    all_codes = {c["code"] for c in codes if c.get("code")}
    print(f"  Loaded {len(codes)} ICD-10 codes ({len(all_codes)} unique code values)")

    print("Building symptom mapping entries...")
    entries = build_symptom_entries(codes)
    print(f"  Generated {len(entries)} symptom entries")

    print("Validating code references...")
    valid, invalid = validate(entries, all_codes)
    print(f"  Valid: {valid} | Invalid: {invalid}")

    output = {
        "generated_by": "expand_symptom_mappings.py",
        "source": "ICD-10",
        "total_entries": len(entries),
        "data": entries,
    }

    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(output, f, ensure_ascii=False, indent=2)

    print(f"\n[OK] Done! Written to {OUTPUT_FILE}")
    print(f"   Entries: {len(entries)} | Invalid codes: {invalid}")


if __name__ == "__main__":
    main()
