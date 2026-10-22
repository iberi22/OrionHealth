#!/usr/bin/env node
// Regenerates corpus/MANIFEST.json deterministically. Zero dependencies.
import { readFileSync, writeFileSync, readdirSync, existsSync, statSync } from 'node:fs';
import { join, resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { sha256Hex } from './lib/canonical.mjs';

const FUNDING = ['public', 'nonprofit', 'mixed', 'industry', 'unknown'];
const POLICIES = ['fulltext', 'abstract', 'metadata_only'];

export function listEntryFiles(root) {
  const out = [];
  const walk = (dir) => {
    for (const name of readdirSync(dir).sort()) {
      const p = join(dir, name);
      if (statSync(p).isDirectory()) walk(p);
      else if (name.endsWith('.json')) out.push(p);
    }
  };
  const base = join(root, 'corpus', 'entries');
  if (existsSync(base)) walk(base);
  return out;
}

const zero = (keys) => Object.fromEntries(keys.map((k) => [k, 0]));

// Returns the manifest derived from files; unreadable files are skipped (the validator reports them).
export function buildManifest(root, previous = {}) {
  const entries = [];
  const counts = { by_source: {}, by_funding_class: zero(FUNDING), by_text_policy: zero(POLICIES) };
  let latest = '1970-01-01T00:00:00Z';
  for (const file of listEntryFiles(root)) {
    const bytes = readFileSync(file);
    let e;
    try { e = JSON.parse(bytes.toString('utf8')); } catch { continue; }
    if (!e || typeof e.id !== 'string') continue;
    entries.push({
      id: e.id,
      path: file.slice(root.length + 1).split('\\').join('/'),
      sha256: sha256Hex(bytes),
      storage: { kind: 'git', repo: null, revision: null },
    });
    if (typeof e.source === 'string') counts.by_source[e.source] = (counts.by_source[e.source] ?? 0) + 1;
    if (e.funding_class in counts.by_funding_class) counts.by_funding_class[e.funding_class]++;
    if (e.text_policy in counts.by_text_policy) counts.by_text_policy[e.text_policy]++;
    if (typeof e.retrieved_at === 'string' && e.retrieved_at > latest) latest = e.retrieved_at;
  }
  counts.by_source = Object.fromEntries(Object.entries(counts.by_source).sort(([a], [b]) => (a < b ? -1 : 1)));
  entries.sort((a, b) => (a.id < b.id ? -1 : a.id > b.id ? 1 : a.path < b.path ? -1 : 1));
  return {
    schema_version: 2,
    corpus_version: previous.corpus_version ?? '2026.43.0',
    generated_at: latest,
    last_refresh: previous.last_refresh ?? { week: null, marker: null },
    counts,
    entries,
  };
}

function main() {
  const args = process.argv.slice(2);
  const i = args.indexOf('--root');
  const root = resolve(i >= 0 ? args[i + 1] : join(dirname(fileURLToPath(import.meta.url)), '..', '..'));
  const file = join(root, 'corpus', 'MANIFEST.json');
  let previous = {};
  if (existsSync(file)) { try { previous = JSON.parse(readFileSync(file, 'utf8')); } catch { /* regenerate */ } }
  writeFileSync(file, JSON.stringify(buildManifest(root, previous), null, 2) + '\n');
  console.log(`wrote ${file}`);
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) main();
