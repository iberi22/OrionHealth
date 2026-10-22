#!/usr/bin/env node
// Evidence corpus validator (rules 1-11). Node 22+, zero dependencies.
// Usage: node scripts/corpus/validate-corpus.mjs [--root <dir>] [--changed-from <git-ref>]
// Prints one `path: RULE: message` line per failure and exits 1 if any.
import { readFileSync, existsSync, statSync, readdirSync } from 'node:fs';
import { join, resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';
import { computeContentHash, entryRelPath } from './lib/canonical.mjs';
import { buildManifest, listEntryFiles } from './build-manifest.mjs';
import { checkSchema } from './lib/schema.mjs';
import { effectivePolicy, POLICY_RANK, buildFunderIndex, deriveFunding } from './lib/policy.mjs';

export { checkSchema };

const MAX_ENTRY_BYTES = 16 * 1024;
const MAX_CORPUS_BYTES = 100 * 1024 * 1024;
const WARN_CORPUS_BYTES = 80 * 1024 * 1024;
const MAX_NEW_ENTRIES = 400;
const MB = 1024 * 1024;

function dirBytes(dir) {
  let total = 0;
  for (const d of readdirSync(dir, { withFileTypes: true })) {
    const p = join(dir, d.name);
    total += d.isDirectory() ? dirBytes(p) : statSync(p).size;
  }
  return total;
}
function listFiles(dir) {
  if (!existsSync(dir)) return [];
  return readdirSync(dir, { withFileTypes: true }).flatMap((d) => (d.isDirectory() ? listFiles(join(dir, d.name)) : [join(dir, d.name)]));
}

function git(root, args) {
  const r = spawnSync('git', args, { cwd: root, encoding: 'utf8' });
  if (r.status !== 0) throw new Error(`git ${args.join(' ')} failed: ${r.stderr.trim()}`);
  return r.stdout.split('\n').filter(Boolean);
}

export function validate(root, { changedFrom = null, warnings = [] } = {}) {
  const failures = [];
  const fail = (path, rule, msg) => failures.push(`${path}: ${rule}: ${msg}`);
  const readJson = (rel) => JSON.parse(readFileSync(join(root, rel), 'utf8'));
  const schemaDoc = readJson('corpus/SCHEMA.json');
  const registry = readJson('corpus/sources/registry.json');
  const funderIndex = buildFunderIndex(readJson('corpus/FUNDERS.json'));
  const sources = new Map(registry.sources.map((s) => [s.id, s]));
  const maxWords = registry.policy?.extract_max_words ?? 50;
  const now = Date.now();
  const seen = new Map();

  for (const file of listEntryFiles(root)) {
    const rel = file.slice(root.length + 1).split('\\').join('/');
    const bytes = statSync(file).size;
    if (bytes > MAX_ENTRY_BYTES) fail(rel, 'R10', `entry is ${bytes} bytes, limit ${MAX_ENTRY_BYTES}`);
    let e;
    try { e = JSON.parse(readFileSync(file, 'utf8')); } catch (x) { fail(rel, 'R1', `invalid JSON: ${x.message}`); continue; }

    if (e && e.retracted === true) fail(rel, 'R7', 'entry is retracted');
    if (e && typeof e === 'object') {
      // R8 / R13 run before the shape gate so they are reported even with other shape errors
      if (e.screenshot !== null && e.screenshot !== undefined) fail(rel, 'R8', 'screenshot must be null in git (screenshots live on HF)');
      if (Array.isArray(e.sections) && e.sections.length) fail(rel, 'R13', 'sections must be [] in git (text lives on HF)');
      const words = typeof e.extract?.text === 'string' ? e.extract.text.trim().split(/\s+/).filter(Boolean).length : 0;
      if (words > maxWords) fail(rel, 'R13', `extract is ${words} words, limit ${maxWords}`);
    }
    const shape = checkSchema(e, schemaDoc.$defs.entry);
    for (const m of shape) fail(rel, 'R1', m);
    if (shape.length) continue;

    // R2 / R3 / R14
    const src = sources.get(e.source);
    if (!src) fail(rel, 'R2', `source "${e.source}" is not in corpus/sources/registry.json`);
    else {
      if (src.status === 'blocked') fail(rel, 'R2', `source "${e.source}" is blocked`);
      let host = '';
      try { host = new URL(e.url).hostname; } catch { /* R1 covers */ }
      if (!src.hosts.includes(host)) fail(rel, 'R2', `host "${host}" does not belong to source "${e.source}"`);
      if (e.id.split(':')[0] !== e.source) fail(rel, 'R2', `id "${e.id}" does not start with source "${e.source}"`);
      const eff = effectivePolicy(src, registry.policy, e.licence_family);
      if (POLICY_RANK[e.text_policy] > POLICY_RANK[eff]) fail(rel, 'R3', `text_policy "${e.text_policy}" is looser than the effective policy "${eff}" for "${e.source}" (storage_max ${src.storage_max}, licence ${src.licence.family}${src.licence.verified ? '' : ' unverified'}, entry licence ${e.licence_family})`);
      if (src.ingest !== 'curated') fail(rel, 'R14', `source "${e.source}" has ingest "${src.ingest}"; only curated sources may have entries in git`);
    }
    // R4: funding_class is derived from funders[]
    if (e.funding_class === 'industry') fail(rel, 'R4', 'funding_class industry is rejected');
    else {
      const d = deriveFunding(e, funderIndex, src ?? { default_funding_class: 'unknown' });
      for (const m of d.errors) fail(rel, 'R4', m);
      if (!d.expected.includes(e.funding_class) && !(d.errors.length && d.expected[0] === 'unknown')) {
        if (d.expected[0] === 'industry') fail(rel, 'R4', `all funders are industry: entry is industry-funded and rejected (labelled "${e.funding_class}")`);
        else fail(rel, 'R4', `funding_class "${e.funding_class}" does not match funders[]; derived ${d.expected.map((x) => `"${x}"`).join(' or ')}${d.expected[0] === 'mixed' ? ' (industry plus other funders is only accepted as mixed)' : ''}`);
      }
    }
    // R5
    const h = computeContentHash(e);
    if (h !== e.content_sha256) fail(rel, 'R5', `content_sha256 mismatch (expected ${h})`);
    if (seen.has(e.id)) fail(rel, 'R5', `duplicate id "${e.id}" (also in ${seen.get(e.id)})`);
    else seen.set(e.id, rel);
    const want = entryRelPath(e);
    if (rel !== want) fail(rel, 'R5', `path does not match id; expected ${want}`);
    // R6
    const t = Date.parse(e.retrieved_at);
    if (t > now) fail(rel, 'R6', 'retrieved_at is in the future');
    if (e.published && Date.parse(`${e.published}T00:00:00Z`) > t) fail(rel, 'R6', 'published is after retrieved_at');
  }

  // R8: no screenshots tree
  for (const f of listFiles(join(root, 'corpus', 'screenshots'))) fail(f.slice(root.length + 1).split('\\').join('/'), 'R8', 'corpus/screenshots/** is not allowed in git');

  // R12
  if (existsSync(join(root, 'corpus'))) {
    const total = dirBytes(join(root, 'corpus'));
    if (total > MAX_CORPUS_BYTES) fail('corpus', 'R12', `corpus/ is ${(total / MB).toFixed(1)} MB, limit 100 MB; move entries to HF JSONL`);
    else if (total > WARN_CORPUS_BYTES) warnings.push(`corpus: R12: warn: corpus/ is ${(total / MB).toFixed(1)} MB (limit 100 MB, warns at 80 MB)`);
  }

  // R9
  const mrel = 'corpus/MANIFEST.json';
  if (!existsSync(join(root, mrel))) fail(mrel, 'R9', 'MANIFEST.json is missing');
  else {
    let m = null;
    try { m = readJson(mrel); } catch (x) { fail(mrel, 'R1', `invalid JSON: ${x.message}`); }
    if (m) {
      const shape = checkSchema(m, schemaDoc.$defs.manifest);
      for (const s of shape) fail(mrel, 'R1', s);
      if (!shape.length) {
        const exp = buildManifest(root, m);
        const strip = (x) => JSON.stringify({ c: x.counts, e: x.entries });
        if (strip(exp) !== strip(m)) {
          const have = new Map(m.entries.map((e) => [e.path, e.sha256]));
          for (const e of exp.entries) {
            if (!have.has(e.path)) fail(mrel, 'R9', `missing entry ${e.path}`);
            else if (have.get(e.path) !== e.sha256) fail(mrel, 'R9', `sha256 mismatch for ${e.path}`);
          }
          for (const p of have.keys()) if (!exp.entries.some((e) => e.path === p)) fail(mrel, 'R9', `lists nonexistent file ${p}`);
          if (JSON.stringify(exp.counts) !== JSON.stringify(m.counts)) fail(mrel, 'R9', 'counts do not match the files');
          if (!failures.some((f) => f.startsWith(`${mrel}: R9`))) fail(mrel, 'R9', 'entries are not sorted by id or do not match the files');
        }
      }
    }
  }

  // R10 (count) and R11
  if (changedFrom) {
    const changed = git(root, ['diff', '--name-only', changedFrom]);
    const isData = (f) => f.startsWith('corpus/entries/') || f === mrel;
    if (changed.some(isData)) for (const f of changed) if (!isData(f)) fail(f, 'R11', 'file changed together with corpus data paths; data PRs may only touch corpus/entries and MANIFEST.json');
    const added = git(root, ['diff', '--name-only', '--diff-filter=A', changedFrom, '--', 'corpus/entries']);
    if (added.length > MAX_NEW_ENTRIES) fail('corpus/entries', 'R10', `PR adds ${added.length} entries, limit ${MAX_NEW_ENTRIES}`);
  }
  return failures;
}

function main() {
  const args = process.argv.slice(2);
  const opt = (n) => { const i = args.indexOf(n); return i >= 0 ? args[i + 1] : null; };
  const root = resolve(opt('--root') ?? join(dirname(fileURLToPath(import.meta.url)), '..', '..'));
  const warnings = [];
  let failures;
  try { failures = validate(root, { changedFrom: opt('--changed-from'), warnings }); }
  catch (x) { console.error(`corpus: ERROR: ${x.message}`); process.exitCode = 1; return; }
  for (const w of warnings) console.log(w);
  for (const f of failures) console.log(f);
  process.exitCode = failures.length ? 1 : 0;
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) main();
