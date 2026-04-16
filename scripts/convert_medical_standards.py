import os
import json
import yaml
import re

def parse_markdown_table(md_content):
    lines = md_content.strip().split('\n')

    # Find the start of the table
    start_index = -1
    for i, line in enumerate(lines):
        if '|' in line and i + 1 < len(lines) and '---|' in lines[i+1]:
            start_index = i
            break

    if start_index == -1 or len(lines) < start_index + 3:
        return []

    headers = [h.strip() for h in lines[start_index].strip('|').split('|')]
    data = []

    for line in lines[start_index + 2:]:
        if not line.strip() or not line.strip().startswith('|'):
            continue
        values = [v.strip() for v in line.strip('|').split('|')]
        if len(values) != len(headers):
            continue

        item = dict(zip(headers, values))

        # Transform keys to match expected JSON format
        transformed_item = {
            "code": item.get("Code", ""),
            "displayName": item.get("Display Name", ""),
            "category": item.get("Category", ""),
            "wikipediaUrl": item.get("Wikipedia URL", ""),
            "searchTerms": [s.strip() for s in item.get("Search Terms", "").split(",") if s.strip()]
        }
        data.append(transformed_item)

    return data

def convert_md_to_json(md_filepath, json_filepath):
    with open(md_filepath, 'r') as f:
        content = f.read()

    # Extract YAML frontmatter
    match = re.match(r'^---\s*\n(.*?)\n---\s*\n(.*)', content, re.DOTALL)
    if not match:
        raise ValueError(f"Invalid Markdown format in {md_filepath}: Missing frontmatter")

    frontmatter_raw = match.group(1)
    body = match.group(2)

    metadata = yaml.safe_load(frontmatter_raw)

    # Extract table data
    data = parse_markdown_table(body)

    output = {
        "metadata": {
            "standard": metadata.get("standard", ""),
            "version": metadata.get("version", ""),
            "lastUpdated": metadata.get("lastUpdated", ""),
            "source": metadata.get("source", ""),
            "sourceUrl": metadata.get("sourceUrl", ""),
            "license": metadata.get("license", ""),
            "wikipediaBase": metadata.get("wikipediaBase", ""),
            "totalCount": len(data)
        },
        "data": data
    }

    os.makedirs(os.path.dirname(json_filepath), exist_ok=True)
    with open(json_filepath, 'w') as f:
        json.dump(output, f, indent=2)

    print(f"Converted {md_filepath} -> {json_filepath} ({len(data)} items)")

def main():
    source_dir = 'docs/medical-standards'
    target_dir = 'medical-standards'

    files = [
        ('icd10.md', 'icd10.json'),
        ('loinc.md', 'loinc.json'),
        ('rxnorm.md', 'rxnorm.json'),
        ('snomed.md', 'snomed.json')
    ]

    for md_file, json_file in files:
        md_path = os.path.join(source_dir, md_file)
        json_path = os.path.join(target_dir, json_file)
        if os.path.exists(md_path):
            convert_md_to_json(md_path, json_path)
        else:
            print(f"Warning: {md_path} not found")

if __name__ == "__main__":
    main()
