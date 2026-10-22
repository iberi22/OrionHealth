// Fixture catalogue for validate.test.mjs (schema v2 ids). Fixtures are materialised at test
// time because scripts/.gitignore excludes *.json, so JSON fixture files would never be committed.
import { mkdirSync, writeFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { computeContentHash, entryRelPath } from '../../../lib/canonical.mjs';
import { buildManifest } from '../../../build-manifest.mjs';

export const base = () => ({
  id: 'us-uspstf:statin-use', source: 'us-uspstf', country: 'US', issuer: 'US Preventive Services Task Force',
  url: 'https://www.uspreventiveservicestaskforce.org/uspstf/recommendation/statin-use', title: 'Statin Use for Primary Prevention',
  lang: 'en', doc_type: 'recommendation', published: '2022-08-23', updated: null, retrieved_at: '2025-01-15T10:00:00Z',
  licence: 'Public domain (US government work)', licence_family: 'public-domain', text_policy: 'fulltext',
  extract: { text: 'The USPSTF recommends prescribing a statin for adults aged 40 to 75 years.', source_url: 'https://www.uspreventiveservicestaskforce.org/uspstf/recommendation/statin-use' },
  acquisition: 'html', funding_class: 'public',
  funders: [{ name: 'National Institutes of Health', class: 'public', ror: null }],
  coi: { status: 'none_declared', text: null }, evidence_level: { scale: 'OCEBM-2011', level: 1, grade: 'B', basis: 'publication_type' },
  icd10: ['E78.5'], mesh: ['Hydroxymethylglutaryl-CoA Reductase Inhibitors'], retracted: false, supersedes: null, sections: [], content_sha256: '', screenshot: null,
});
export const cochrane = () => ({
  ...base(), id: 'int-cochrane:CD000001', source: 'int-cochrane', country: 'INT', issuer: 'Cochrane',
  url: 'https://www.cochranelibrary.com/cdsr/doi/10.1002/14651858.CD000001/full', title: 'Example systematic review',
  doc_type: 'systematic_review', published: '2024-03-01', licence: 'Copyright Cochrane', licence_family: 'copyright',
  text_policy: 'metadata_only', extract: null, funding_class: 'nonprofit',
  funders: [{ name: 'Cochrane', class: 'nonprofit', ror: null }], icd10: [], mesh: [],
});
const f = (name, class_) => ({ name, class: class_, ror: null });

// Writes entries (hash recomputed unless raw) and returns nothing.
export function writeEntries(root, entries, { raw = false } = {}) {
  for (const e of entries) {
    if (!(raw && e.content_sha256)) e.content_sha256 = computeContentHash(e);
    const p = join(root, entryRelPath(e));
    mkdirSync(dirname(p), { recursive: true });
    writeFileSync(p, JSON.stringify(e, null, 2) + '\n');
  }
}
export function writeManifest(root) {
  mkdirSync(join(root, 'corpus'), { recursive: true });
  writeFileSync(join(root, 'corpus', 'MANIFEST.json'), JSON.stringify(buildManifest(root), null, 2) + '\n');
}

const mutated = (mut) => { const e = base(); mut(e); return [e, cochrane()]; };
const CATALOGUE = {
  'valid': () => [base(), cochrane()],
  'r1-missing-field': () => mutated((e) => { delete e.issuer; }),
  'r2-bad-host': () => mutated((e) => { e.url = 'https://evil.example.com/x'; }),
  'r2-unknown-source': () => mutated((e) => { e.id = 'zz-nope:a'; e.source = 'zz-nope'; }),
  'r3-bad-licence': () => mutated((e) => { e.licence_family = 'copyright'; }),
  'r3-loose-policy': () => { const c = cochrane(); c.text_policy = 'abstract'; return [base(), c]; },
  'r3-nc-gate': () => [{
    ...base(), id: 'int-who-iris:10665-1', source: 'int-who-iris', country: 'INT', issuer: 'World Health Organization',
    url: 'https://iris.who.int/handle/10665/1', licence: 'CC BY-NC-SA 3.0 IGO', licence_family: 'cc-by-nc-sa',
    funders: [f('World Health Organization', 'public')],
  }, cochrane()],
  'r4-industry': () => mutated((e) => { e.funding_class = 'industry'; e.funders = [f('Pfizer', 'industry')]; }),
  'r4-industry-public': () => mutated((e) => { e.funding_class = 'public'; e.funders = [f('Pfizer', 'industry')]; }),
  'r4-industry-mixed-public': () => mutated((e) => { e.funding_class = 'public'; e.funders = [f('Pfizer', 'industry'), f('NIH', 'public')]; }),
  'r4-unknown-funder': () => mutated((e) => { e.funding_class = 'nonprofit'; e.funders = [f('Acme Health Foundation', 'nonprofit')]; }),
  'r4-funder-class': () => mutated((e) => { e.funders = [f('National Institutes of Health', 'nonprofit')]; }),
  'r5-bad-hash': () => { const e = base(); e.content_sha256 = computeContentHash(e); e.title = 'Changed after hashing'; return [e, cochrane()]; },
  'r6-future': () => mutated((e) => { e.retrieved_at = '2999-01-01T00:00:00Z'; }),
  'r6-published-after': () => mutated((e) => { e.published = '2025-02-01'; }),
  'r7-retracted': () => mutated((e) => { e.retracted = true; }),
  'r8-screenshot-field': () => mutated((e) => { e.screenshot = 'corpus/screenshots/us-uspstf/a.png'; }),
  'r13-sections': () => mutated((e) => { e.sections = [{ heading: 'Summary', text: 'Body text.' }]; }),
  'r13-long-extract': () => mutated((e) => { e.extract.text = Array.from({ length: 51 }, (_, i) => `w${i}`).join(' '); }),
  'r14-bulk-source': () => [{
    ...base(), id: 'us-ctgov:NCT01234567', source: 'us-ctgov', issuer: 'ClinicalTrials.gov',
    url: 'https://clinicaltrials.gov/study/NCT01234567', doc_type: 'trial_record', licence: 'Public domain',
    funders: [f('National Cancer Institute', 'public')],
  }, cochrane()],
};

export const NAMES = [...Object.keys(CATALOGUE), 'r5-bad-path', 'r8-screenshots-dir', 'r9-stale-manifest'];

export function materialize(name, root) {
  if (name === 'r5-bad-path') {
    const e = base(); e.content_sha256 = computeContentHash(e);
    const p = join(root, 'corpus/entries/us-uspstf/2022/wrong-name.json');
    mkdirSync(dirname(p), { recursive: true });
    writeFileSync(p, JSON.stringify(e, null, 2) + '\n');
    writeEntries(root, [cochrane()]);
    return writeManifest(root);
  }
  if (name === 'r8-screenshots-dir') {
    writeEntries(root, [base(), cochrane()]);
    const p = join(root, 'corpus/screenshots/us-uspstf/us-uspstf_statin-use.png');
    mkdirSync(dirname(p), { recursive: true });
    writeFileSync(p, 'png');
    return writeManifest(root);
  }
  if (name === 'r9-stale-manifest') {
    writeEntries(root, [base(), cochrane()]);
    mkdirSync(join(root, 'corpus'), { recursive: true });
    const m = buildManifest(root);
    m.entries[0].sha256 = '0'.repeat(64);
    return writeFileSync(join(root, 'corpus', 'MANIFEST.json'), JSON.stringify(m, null, 2) + '\n');
  }
  if (!CATALOGUE[name]) throw new Error(`unknown fixture ${name}`);
  writeEntries(root, CATALOGUE[name](), { raw: name === 'r5-bad-hash' });
  writeManifest(root);
}
