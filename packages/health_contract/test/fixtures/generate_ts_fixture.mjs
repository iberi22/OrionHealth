// Run: node test/fixtures/generate_ts_fixture.mjs /path/to/GOS/packages/health-contract/dist/index.js
import { readFile, writeFile } from 'node:fs/promises';
import { pathToFileURL } from 'node:url';
const { encodeDeepLink } = await import(pathToFileURL(process.argv[2]));
const record = JSON.parse(await readFile(new URL('./valid/workout-session-01.json', import.meta.url), 'utf8'));
const link = await encodeDeepLink([record], 'https://orionhealth.example/import#source=training');
await writeFile(new URL('./ts-deep-link.json', import.meta.url), JSON.stringify({ sourceCommit: '34b15de0', recordFixture: 'valid/workout-session-01.json', link }, null, 2) + '\n');
const { validateRecord } = await import(pathToFileURL(process.argv[2]));
const { readdir } = await import('node:fs/promises');
const validation = {};
for (const group of ['valid', 'invalid']) {
  for (const name of (await readdir(new URL(`./${group}/`, import.meta.url))).sort()) {
    validation[`${group}/${name}`] = validateRecord(JSON.parse(await readFile(new URL(`./${group}/${name}`, import.meta.url), 'utf8'))).errors;
  }
}
await writeFile(new URL('./ts-validation.json', import.meta.url), JSON.stringify(validation, null, 2) + '\n');
