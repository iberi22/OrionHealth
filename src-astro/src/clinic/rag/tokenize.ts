const STOP_ES = 'de la que el en y a los del se las por un para con no una su al lo como mas pero sus le ya o este si porque esta entre cuando muy sin sobre tambien me hasta hay donde quien desde todo nos durante todos uno les ni contra otros ese eso ante ellos e esto mi antes algunos que unos yo otro otras otra el tanto esa estos mucho quienes nada muchos cual poco ella estar estas algunas algo nosotros es son fue ha han ser'.split(' ');
const STOP_EN = 'the of and to in a is that for it as was with be by on not he this are or his from at which but have an had they you were their one all we can her has there been if more when will would so no'.split(' ');
const STOP_PT = 'o os as um uma uns umas de do da dos das em no na nos nas por para com sem sobre entre e ou mas que se ao aos foi ser sao tem ha mais muito como seu sua seus suas isso este esta esse essa'.split(' ');
export const STOPWORDS: ReadonlySet<string> = new Set([...STOP_ES, ...STOP_EN, ...STOP_PT]);

/** NFKD, strip combining marks, lowercase. */
export function normalize(s: string): string {
  return s.normalize('NFKD').replace(/\p{M}+/gu, '').toLowerCase();
}

/** Tokenizer used for BOTH index and query. */
export function tokenize(text: string): string[] {
  const out: string[] = [];
  for (const t of normalize(text).split(/[^\p{L}\p{N}]+/u)) {
    if (!t) continue;
    if (t.length < 2 && !/^\p{N}$/u.test(t)) continue;
    if (STOPWORDS.has(t)) continue;
    out.push(t);
  }
  return out;
}
