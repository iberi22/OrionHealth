import fs from 'fs';
import path from 'path';

const INPUT_DIR = path.resolve('../assets/medical-standards');
const OUTPUT_DIR = path.resolve('public/kb');

const systemMap = {
  'icd10.json': 'icd10',
  'loinc.json': 'loinc',
  'rxnorm.json': 'rxnorm',
  'snomed.json': 'snomed',
  'clinical_guidelines.json': 'guideline',
  'drug_interactions.json': 'interaction',
  'symptom_checker.json': 'symptom',
};

function processFile(filename) {
  const system = systemMap[filename];
  if (!system) return null;

  const inputPath = path.join(INPUT_DIR, filename);
  if (!fs.existsSync(inputPath)) {
    console.warn(`File ${filename} not found`);
    return null;
  }

  const raw = fs.readFileSync(inputPath, 'utf8');
  let data;
  try {
    data = JSON.parse(raw);
  } catch (e) {
    console.error(`Invalid JSON in ${filename}`);
    return null;
  }

  const items = data.data;
  if (!Array.isArray(items)) {
    console.error(`No data array in ${filename}`);
    return null;
  }

  let skipped = 0;
  const entries = [];

  for (const item of items) {
    try {
      let code, title, body, related;

      if (['icd10', 'loinc', 'rxnorm', 'snomed', 'guideline'].includes(system)) {
        if (!item.code || !item.displayName) {
          skipped++;
          continue;
        }
        code = item.code;
        title = item.displayName;
        related = item.searchTerms || [];

        const bodyObj = { ...item };
        delete bodyObj.code;
        delete bodyObj.displayName;
        delete bodyObj.searchTerms;
        body = Object.entries(bodyObj)
          .filter(([_, v]) => v !== undefined && v !== null && v !== '')
          .map(([k, v]) => `${k}: ${typeof v === 'object' ? JSON.stringify(v) : v}`)
          .join('\n');
      } else if (system === 'interaction') {
        if (!item.drugA?.code || !item.drugB?.code || !item.drugA?.name || !item.drugB?.name) {
          skipped++;
          continue;
        }
        code = `${item.drugA.code}_${item.drugB.code}`;
        title = `${item.drugA.name} - ${item.drugB.name}`;
        body = `Severity: ${item.severity}\nDescription: ${item.description}\nMechanism: ${item.mechanism}`;
        related = [item.drugA.name, item.drugB.name];
      } else if (system === 'symptom') {
        if (!item.symptom) {
          skipped++;
          continue;
        }
        code = item.symptom;
        title = item.symptom;
        related = item.searchTerms || [];
        body = `Category: ${item.category}\nMatches: ${JSON.stringify(item.matches)}\nRed Flags: ${JSON.stringify(item.redFlags)}`;
      }

      if (!code || !title) {
        skipped++;
        continue;
      }

      entries.push({
        id: `${system}:${code}`,
        system,
        code,
        title,
        body,
        ...(related && related.length > 0 ? { related } : {})
      });
    } catch (e) {
      skipped++;
    }
  }

  if (skipped > 0) {
    console.log(`Skipped ${skipped} invalid items in ${filename}`);
  }

  return { system, entries, metadata: data.metadata };
}

function build() {
  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  }

  const files = fs.readdirSync(INPUT_DIR).filter(f => f.endsWith('.json'));
  const manifest = {
    updatedAt: new Date().toISOString(),
    systems: {}
  };

  for (const file of files) {
    const result = processFile(file);
    if (result) {
      const outputPath = path.join(OUTPUT_DIR, `${result.system}.json`);
      fs.writeFileSync(outputPath, JSON.stringify(result.entries, null, 2), 'utf8');
      console.log(`Wrote ${result.entries.length} entries to ${result.system}.json`);
      manifest.systems[result.system] = {
        count: result.entries.length,
        metadata: result.metadata
      };
    }
  }

  const manifestPath = path.join(OUTPUT_DIR, 'manifest.json');
  fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2), 'utf8');
  console.log('Wrote manifest.json');
}

build();
