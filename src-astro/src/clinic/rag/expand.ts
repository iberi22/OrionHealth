import { tokenize } from './tokenize';

/** Curated es<->en clinical seed dictionary. Keys/values are free text; matched after tokenize(). */
const PAIRS: Array<[string, string]> = [
  ['hipertension', 'hypertension'], ['hipertension arterial', 'hypertension blood pressure'], ['hta', 'hypertension'], ['hypertension', 'hta'],
  ['insuficiencia cardiaca', 'heart failure'], ['ic', 'heart failure'], ['diabetes', 'diabetes'],
  ['diabetes mellitus', 'diabetes mellitus'], ['dm2', 'type 2 diabetes'], ['epoc', 'chronic obstructive pulmonary disease'], ['epoc', 'copd'], ['copd', 'chronic obstructive pulmonary disease'],
  ['enfermedad pulmonar obstructiva cronica', 'copd'], ['erc', 'chronic kidney disease'], ['erc', 'ckd'], ['ckd', 'chronic kidney disease'],
  ['enfermedad renal cronica', 'chronic kidney disease'], ['enfermedad renal cronica', 'ckd'], ['infarto', 'myocardial infarction'],
  ['infarto agudo de miocardio', 'myocardial infarction'], ['iam', 'myocardial infarction'],
  ['accidente cerebrovascular', 'stroke'], ['acv', 'stroke'], ['ictus', 'stroke'], ['fibrilacion auricular', 'atrial fibrillation'],
  ['asma', 'asthma'], ['neumonia', 'pneumonia'], ['cancer', 'cancer neoplasm'], ['tumor', 'neoplasm'],
  ['cancer de mama', 'breast cancer'], ['cancer de pulmon', 'lung cancer'], ['depresion', 'depression'],
  ['ansiedad', 'anxiety'], ['obesidad', 'obesity'], ['sobrepeso', 'overweight'], ['colesterol', 'cholesterol'],
  ['dislipidemia', 'dyslipidemia'], ['anemia', 'anemia'], ['embarazo', 'pregnancy'], ['tratamiento', 'treatment therapy'],
  ['diagnostico', 'diagnosis'], ['prevencion', 'prevention'], ['dolor', 'pain'], ['fiebre', 'fever'], ['tos', 'cough'],
  ['infeccion', 'infection'], ['antibiotico', 'antibiotic'], ['vacuna', 'vaccine'], ['riñon', 'kidney'], ['rinon', 'kidney'],
  ['higado', 'liver'], ['corazon', 'heart'], ['pulmon', 'lung'], ['sangre', 'blood'], ['presion arterial', 'blood pressure'],
  ['ensayo clinico', 'clinical trial'], ['guia de practica clinica', 'clinical practice guideline'], ['gpc', 'guideline'],
  ['tuberculosis', 'tuberculosis'], ['vih', 'hiv'], ['sida', 'aids'], ['epilepsia', 'epilepsy'], ['demencia', 'dementia'],
  ['artritis', 'arthritis'], ['osteoporosis', 'osteoporosis'], ['hipotiroidismo', 'hypothyroidism'], ['insuficiencia renal', 'renal failure'],
];

type Table = Map<string, string[]>;
function build(): { table: Table; maxLen: number } {
  const table: Table = new Map();
  let maxLen = 1;
  const add = (k: string, v: string[]) => {
    if (!k || !v.length) return;
    const cur = table.get(k) ?? [];
    for (const x of v) if (!cur.includes(x)) cur.push(x);
    table.set(k, cur);
  };
  for (const [a, b] of PAIRS) {
    const ka = tokenize(a), kb = tokenize(b);
    maxLen = Math.max(maxLen, ka.length, kb.length);
    add(ka.join(' '), kb);
    add(kb.join(' '), ka);
  }
  return { table, maxLen };
}
const { table: TABLE, maxLen: MAX_LEN } = build();

/** Extra normalized terms for a token sequence (phrases up to MAX_LEN, then single tokens). */
export function expandTokens(tokens: string[]): string[] {
  const extra: string[] = [];
  const seen = new Set(tokens);
  const push = (xs: string[] | undefined) => {
    for (const x of xs ?? []) if (!seen.has(x)) { seen.add(x); extra.push(x); }
  };
  for (let i = 0; i < tokens.length; i++) {
    for (let n = Math.min(MAX_LEN, tokens.length - i); n >= 1; n--) push(TABLE.get(tokens.slice(i, i + n).join(' ')));
  }
  return extra;
}

/** ExpandHook-compatible: per raw term, with the full term list as context. */
export function builtinExpand(term: string, all: string[] = [term]): string[] {
  const toks = all.flatMap((t) => tokenize(t));
  const mine = new Set(tokenize(term));
  const out: string[] = [];
  for (const e of expandTokens(toks)) if (!mine.has(e) && !out.includes(e)) out.push(e);
  // only emit once (on the first term) so expansion is not repeated per term
  return all[0] === term ? out : [];
}
