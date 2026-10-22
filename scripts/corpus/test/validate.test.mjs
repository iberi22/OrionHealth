import { test } from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync, execFileSync } from 'node:child_process';
import { mkdtempSync, mkdirSync, writeFileSync, readFileSync, readdirSync, copyFileSync, rmSync, truncateSync, existsSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { materialize, writeEntries, writeManifest, base, cochrane } from './fixtures/validate/fixtures.mjs';

const here = dirname(fileURLToPath(import.meta.url));
const repo = join(here, '..', '..', '..');
const validator = join(here, '..', 'validate-corpus.mjs');
const builder = join(here, '..', 'build-manifest.mjs');

function setup(name) {
  const root = mkdtempSync(join(tmpdir(), 'corpus-'));
  mkdirSync(join(root, 'corpus', 'sources'), { recursive: true });
  for (const f of ['FUNDERS.json', 'SCHEMA.json']) copyFileSync(join(repo, 'corpus', f), join(root, 'corpus', f));
  copyFileSync(join(repo, 'corpus/sources/registry.json'), join(root, 'corpus/sources/registry.json'));
  if (name) materialize(name, root);
  return root;
}
function run(root, ...args) {
  const r = spawnSync('node', [validator, '--root', root, ...args], { encoding: 'utf8' });
  return { code: r.status, out: r.stdout + r.stderr };
}
function expectFail(name, rule, re = '.+') {
  const root = setup(name);
  const r = run(root);
  assert.equal(r.code, 1, `${name}: expected exit 1\n${r.out}`);
  assert.match(r.out, new RegExp(`^[^\\n]+: ${rule}: ${re}`, 'm'), `${name}: expected ${rule}\n${r.out}`);
  rmSync(root, { recursive: true, force: true });
}
const firstEntry = (root) => {
  const d = join(root, 'corpus/entries/us-uspstf/2022');
  return join(d, readdirSync(d)[0]);
};
// Rewrites the us-uspstf entry through `mut`, re-hashes and regenerates the manifest.
function edit(root, mut) {
  const e = JSON.parse(readFileSync(firstEntry(root), 'utf8'));
  mut(e);
  writeEntries(root, [e]);
  writeManifest(root);
}

test('valid fixture passes', () => {
  const r = run(setup('valid'));
  assert.equal(r.code, 0, r.out);
});

test('R1 shape', () => expectFail('r1-missing-field', 'R1'));
test('R2 host', () => expectFail('r2-bad-host', 'R2'));
test('R2 unknown source', () => expectFail('r2-unknown-source', 'R2', '.*registry'));
test('R2 blocked source', () => {
  const root = setup('valid');
  const p = join(root, 'corpus/sources/registry.json');
  const reg = JSON.parse(readFileSync(p, 'utf8'));
  reg.sources.find((s) => s.id === 'us-uspstf').status = 'blocked';
  writeFileSync(p, JSON.stringify(reg));
  const r = run(root);
  assert.equal(r.code, 1);
  assert.match(r.out, /R2: .*blocked/);
});
test('R3 licence ceiling', () => expectFail('r3-bad-licence', 'R3'));
test('R3 text policy looser than source', () => expectFail('r3-loose-policy', 'R3'));
test('R3 NC gate / unverified licence', () => expectFail('r3-nc-gate', 'R3'));
test('R3 NC gate opens when noncommercial_distribution and verified', () => {
  const root = setup('r3-nc-gate');
  const p = join(root, 'corpus/sources/registry.json');
  const reg = JSON.parse(readFileSync(p, 'utf8'));
  reg.policy.noncommercial_distribution = true;
  const s = reg.sources.find((x) => x.id === 'int-who-iris');
  s.licence.verified = true; s.licence.verified_at = '2026-01-01'; s.licence.evidence = 'x';
  writeFileSync(p, JSON.stringify(reg));
  const r = run(root);
  assert.equal(r.code, 0, r.out);
});
test('R4 industry label', () => expectFail('r4-industry', 'R4'));
test('R4 all-industry funders labelled public', () => expectFail('r4-industry-public', 'R4', '.*industry'));
test('R4 industry plus others labelled public (only mixed)', () => expectFail('r4-industry-mixed-public', 'R4', '.*mixed'));
test('R4 industry plus others labelled mixed is accepted', () => {
  const root = setup('valid');
  edit(root, (e) => { e.funding_class = 'mixed'; e.funders = [{ name: 'Pfizer', class: 'industry', ror: null }, { name: 'NIH', class: 'public', ror: null }]; });
  const r = run(root);
  assert.equal(r.code, 0, r.out);
});
test('R4 unknown funder cannot be declared nonprofit', () => expectFail('r4-unknown-funder', 'R4', '.*unknown'));
test('R4 unknown funder accepted only as unknown', () => {
  const root = setup('r4-unknown-funder');
  edit(root, (e) => { e.funding_class = 'unknown'; });
  const r = run(root);
  assert.equal(r.code, 0, r.out);
});
test('R4 funder class vs FUNDERS.json', () => expectFail('r4-funder-class', 'R4'));
test('R5 hash', () => expectFail('r5-bad-hash', 'R5'));
test('R5 path', () => expectFail('r5-bad-path', 'R5'));
test('R5 duplicate id', () => {
  const root = setup('valid');
  const f = firstEntry(root);
  copyFileSync(f, join(dirname(f), 'copy.json'));
  const r = run(root);
  assert.equal(r.code, 1);
  assert.match(r.out, /R5: .*duplicate/i);
});
test('R6 future', () => expectFail('r6-future', 'R6'));
test('R6 published after retrieved', () => expectFail('r6-published-after', 'R6'));
test('R7 retracted', () => expectFail('r7-retracted', 'R7'));
test('R8 screenshot field must be null', () => expectFail('r8-screenshot-field', 'R8'));
test('R8 no corpus/screenshots/**', () => expectFail('r8-screenshots-dir', 'R8'));
test('R9 manifest mismatch', () => expectFail('r9-stale-manifest', 'R9'));
test('R9 build-manifest fixes it and is deterministic', () => {
  const root = setup('r9-stale-manifest');
  execFileSync('node', [builder, '--root', root]);
  const a = readFileSync(join(root, 'corpus/MANIFEST.json'), 'utf8');
  execFileSync('node', [builder, '--root', root]);
  assert.equal(readFileSync(join(root, 'corpus/MANIFEST.json'), 'utf8'), a);
  const m = JSON.parse(a);
  assert.deepEqual(m.entries.map((e) => e.id), ['int-cochrane:CD000001', 'us-uspstf:statin-use']);
  assert.deepEqual(m.counts.by_source, { 'int-cochrane': 1, 'us-uspstf': 1 });
  assert.equal(m.counts.by_text_policy.fulltext, 1);
  assert.equal(m.counts.by_text_policy.metadata_only, 1);
  assert.deepEqual(m.entries[0].storage, { kind: 'git', repo: null, revision: null });
  assert.equal(run(root).code, 0, run(root).out);
});
test('R10 entry over 16 KB', () => {
  const root = setup('valid');
  const f = firstEntry(root);
  const e = JSON.parse(readFileSync(f, 'utf8'));
  e.title = 'a'.repeat(17 * 1024);
  writeFileSync(f, JSON.stringify(e));
  const r = run(root);
  assert.equal(r.code, 1);
  assert.match(r.out, /R10: .*16384/);
});
test('R12 corpus/ over 100 MB fails, 80 MB warns', () => {
  const root = setup('valid');
  const big = join(root, 'corpus', 'big.bin');
  writeFileSync(big, '');
  truncateSync(big, 85 * 1024 * 1024);
  const warn = run(root);
  assert.equal(warn.code, 0, warn.out);
  assert.match(warn.out, /R12: .*warn/i);
  truncateSync(big, 101 * 1024 * 1024);
  const r = run(root);
  assert.equal(r.code, 1);
  assert.match(r.out, /R12: .*100 MB/);
});
test('R13 sections must be [] in git', () => expectFail('r13-sections', 'R13'));
test('R13 extract at most 50 words', () => expectFail('r13-long-extract', 'R13', '.*50'));
test('R14 source must be curated', () => expectFail('r14-bulk-source', 'R14'));

function gitRepo() {
  const root = setup('valid');
  const g = (...a) => execFileSync('git', a, { cwd: root, stdio: 'pipe' });
  g('init', '-q', '-b', 'main');
  g('config', 'user.email', 't@t'); g('config', 'user.name', 't');
  writeFileSync(join(root, 'README.md'), 'x');
  g('add', '-A'); g('commit', '-q', '-m', 'base');
  return { root, g };
}
test('R11 data-path guard rejects mixed change', () => {
  const { root } = gitRepo();
  writeFileSync(join(root, 'README.md'), 'changed');
  writeFileSync(firstEntry(root), readFileSync(firstEntry(root), 'utf8') + ' ');
  const r = run(root, '--changed-from', 'HEAD');
  assert.equal(r.code, 1);
  assert.match(r.out, /README\.md: R11: /);
});
test('R11 passes when only non-data paths change', () => {
  const { root } = gitRepo();
  writeFileSync(join(root, 'README.md'), 'changed');
  assert.equal(run(root, '--changed-from', 'HEAD').code, 0);
});
test('R10 more than 400 new entries in a PR; last output line survives piping (exit-code truncation)', () => {
  const { root, g } = gitRepo();
  g('rm', '-rq', '--cached', 'corpus/entries', 'corpus/MANIFEST.json');
  g('commit', '-q', '-m', 'drop');
  const f = firstEntry(root);
  const e = JSON.parse(readFileSync(f, 'utf8'));
  for (let i = 0; i < 401; i++) {
    const c = { ...e, id: `us-uspstf:n${i}`, content_sha256: '' };
    writeFileSync(join(dirname(f), `n${i}.json`), JSON.stringify(c)); // invalid on purpose: floods the output
  }
  g('add', 'corpus/entries');
  const r = run(root, '--changed-from', 'HEAD');
  assert.equal(r.code, 1);
  const lines = r.out.trimEnd().split('\n');
  assert.match(lines.at(-1), /R10: PR adds (40[1-9]|4[1-9]\d) entries/, 'R10 line must be the last line, not truncated');
});

test('exit code is set, not forced: no process.exit() in corpus scripts', () => {
  for (const f of ['validate-corpus.mjs', 'validate-registry.mjs', 'build-manifest.mjs']) {
    assert.ok(!/process\.exit\(/.test(readFileSync(join(here, '..', f), 'utf8')), `${f} calls process.exit()`);
  }
});

test('real repo corpus passes', () => {
  const r = spawnSync('node', [validator], { cwd: repo, encoding: 'utf8' });
  assert.equal(r.status, 0, r.stdout + r.stderr);
});
