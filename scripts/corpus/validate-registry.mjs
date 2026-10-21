#!/usr/bin/env node
// Validates corpus/sources/registry.json against registry.schema.json plus the licence rules. Zero dependencies.
import { readFileSync } from 'node:fs';
import { join, resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { checkSchema } from './lib/schema.mjs';

const HOST_RE = /^(?=.{1,253}$)([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z]{2,}$/;

export function validateRegistry(root) {
  const failures = [];
  const fail = (path, msg) => failures.push(`${path}: registry: ${msg}`);
  const rel = 'corpus/sources/registry.json';
  const schema = JSON.parse(readFileSync(join(root, 'corpus/sources/registry.schema.json'), 'utf8'));
  let reg;
  try { reg = JSON.parse(readFileSync(join(root, rel), 'utf8')); } catch (x) { return [`${rel}: registry: invalid JSON: ${x.message}`]; }
  for (const m of checkSchema(reg, schema)) failures.push(`${rel}: registry: ${m}`);
  if (!Array.isArray(reg.sources)) return failures;

  const seen = new Set();
  for (const [i, s] of reg.sources.entries()) {
    if (!s || typeof s !== 'object') continue;
    const at = `${rel}#${s.id ?? i}`;
    if (typeof s.id === 'string') {
      if (seen.has(s.id)) fail(at, `duplicate id "${s.id}"`);
      seen.add(s.id);
      const prefix = s.id.split('-')[0];
      if (typeof s.country === 'string' && (prefix === 'uk' ? 'GB' : prefix.toUpperCase()) !== s.country) fail(at, `id prefix "${prefix}" does not match country "${s.country}"`);
    }
    for (const h of Array.isArray(s.hosts) ? s.hosts : []) {
      if (typeof h !== 'string' || !HOST_RE.test(h)) fail(at, `host "${h}" must be a bare lowercase hostname (no scheme, path or port)`);
    }
    const l = s.licence;
    if (!l || typeof l !== 'object') continue;
    if ((l.family === 'copyright' || l.family === 'unknown') && s.storage_max !== 'metadata_only') fail(at, `licence family "${l.family}" requires storage_max metadata_only (got "${s.storage_max}")`);
    if (l.verified === true && (!l.verified_at || !l.evidence)) fail(at, 'verified licence needs verified_at and evidence');
    if (l.verified === false && l.verified_at) fail(at, 'unverified licence must have verified_at null');
    if (s.status === 'active' && l.verified !== true) fail(at, 'status active requires a verified licence');
  }
  return failures;
}

function main() {
  const args = process.argv.slice(2);
  const i = args.indexOf('--root');
  const root = resolve(i >= 0 ? args[i + 1] : join(dirname(fileURLToPath(import.meta.url)), '..', '..'));
  let failures;
  try { failures = validateRegistry(root); }
  catch (x) { console.error(`registry: ERROR: ${x.message}`); process.exitCode = 1; return; }
  for (const f of failures) console.log(f);
  process.exitCode = failures.length ? 1 : 0;
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) main();
