import { test } from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtempSync, mkdirSync, writeFileSync, readFileSync, copyFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const repo = join(here, '..', '..', '..');
const script = join(here, '..', 'validate-registry.mjs');
const real = JSON.parse(readFileSync(join(repo, 'corpus/sources/registry.json'), 'utf8'));

function runWith(mut) {
  const root = mkdtempSync(join(tmpdir(), 'registry-'));
  mkdirSync(join(root, 'corpus/sources'), { recursive: true });
  copyFileSync(join(repo, 'corpus/sources/registry.schema.json'), join(root, 'corpus/sources/registry.schema.json'));
  const reg = structuredClone(real);
  mut(reg);
  writeFileSync(join(root, 'corpus/sources/registry.json'), JSON.stringify(reg));
  const r = spawnSync('node', [script, '--root', root], { encoding: 'utf8' });
  return { code: r.status, out: r.stdout + r.stderr };
}
const bad = (mut, re) => { const r = runWith(mut); assert.equal(r.code, 1, r.out); assert.match(r.out, re, r.out); };

test('real registry passes', () => {
  const r = spawnSync('node', [script], { cwd: repo, encoding: 'utf8' });
  assert.equal(r.status, 0, r.stdout + r.stderr);
});
test('unmodified copy passes', () => assert.equal(runWith(() => {}).code, 0));
test('duplicate ids', () => bad((r) => { r.sources[1].id = r.sources[0].id; }, /duplicate id/));
test('id pattern', () => bad((r) => { r.sources[0].id = 'Bad_ID'; }, /id/));
test('enum violation', () => bad((r) => { r.sources[0].status = 'maybe'; }, /enum/));
test('mandatory key missing', () => bad((r) => { delete r.sources[0].hosts; }, /missing required "hosts"/));
test('host must be a bare hostname', () => bad((r) => { r.sources[0].hosts = ['https://x.org/path']; }, /host/));
test('empty hosts', () => bad((r) => { r.sources[0].hosts = []; }, /hosts/));
test('copyright licence cannot allow fulltext', () => bad((r) => {
  const s = r.sources.find((x) => x.licence.family === 'copyright'); s.storage_max = 'fulltext';
}, /metadata_only/));
test('unknown licence cannot allow abstract', () => bad((r) => {
  const s = r.sources.find((x) => x.licence.family === 'unknown'); s.storage_max = 'abstract';
}, /metadata_only/));
test('verified licence needs verified_at', () => bad((r) => {
  const s = r.sources.find((x) => x.licence.verified); s.licence.verified_at = null;
}, /verified_at/));
test('active source needs verified licence', () => bad((r) => {
  const s = r.sources.find((x) => x.status === 'active'); s.licence.verified = false; s.licence.verified_at = null;
}, /active/));
test('id country prefix must match country', () => bad((r) => { r.sources[0].country = 'US'; }, /country/));
