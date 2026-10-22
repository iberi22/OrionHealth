// Licence / text-policy / funding rules shared by the corpus scripts. Zero dependencies.
export const POLICY_RANK = { metadata_only: 0, abstract: 1, fulltext: 2 };
const minPolicy = (a, b) => (POLICY_RANK[a] <= POLICY_RANK[b] ? a : b);

// Licence ceiling: what a licence family allows, before the NC gate.
export function licenceCeiling(family, verified = true) {
  if (!verified) return 'metadata_only';
  if (family === 'copyright' || family === 'unknown') return 'metadata_only';
  return 'fulltext';
}
export const isNc = (family) => /-nc(-|$)/.test(family);

// effective policy = min(registry storage_max, licence ceiling, NC gate)
export function effectivePolicy(source, policy, entryFamily = null) {
  let eff = source.storage_max;
  eff = minPolicy(eff, licenceCeiling(source.licence.family, source.licence.verified));
  const fams = [source.licence.family, ...(entryFamily ? [entryFamily] : [])];
  if (entryFamily) eff = minPolicy(eff, licenceCeiling(entryFamily, true));
  if (fams.some(isNc) && !policy.noncommercial_distribution) eff = 'metadata_only';
  return eff;
}

export function buildFunderIndex(funders) {
  const m = new Map();
  for (const f of funders.funders) for (const n of [f.name, ...(f.aliases ?? [])]) m.set(n.toLowerCase(), f.class);
  return m;
}

// Derives the funding_class an entry must carry from funders[].
// Returns { expected: string[] (accepted labels), errors: string[] }.
export function deriveFunding(entry, funderIndex, source) {
  const errors = [];
  const classes = [];
  let unknown = false;
  for (const f of entry.funders) {
    const known = funderIndex.get(f.name.toLowerCase());
    if (known === undefined) {
      if (f.class === 'industry') classes.push('industry');
      else { unknown = true; if (entry.funding_class !== 'unknown') errors.push(`funder "${f.name}" is not in FUNDERS.json and cannot be declared ${f.class}; only funding_class "unknown" is accepted`); }
    } else {
      if (known !== f.class) errors.push(`funder "${f.name}" class "${f.class}" does not match FUNDERS.json ("${known}")`);
      classes.push(known);
    }
  }
  const industry = classes.filter((c) => c === 'industry').length;
  let expected;
  if (!entry.funders.length) expected = ['unknown', source.default_funding_class].filter((c) => c !== 'industry');
  else if (industry && industry === entry.funders.length) expected = ['industry'];
  else if (industry) expected = ['mixed'];
  else if (unknown) expected = ['unknown'];
  else expected = [new Set(classes).size === 1 ? classes[0] : 'mixed'];
  return { expected, errors };
}
