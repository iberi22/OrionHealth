export interface CitationInput {
  authors?: string[];
  title: string;
  journal?: string;
  year?: number | string;
  volume?: string;
  issue?: string;
  pages?: string;
  pmid?: string;
  doi?: string;
  nct?: string;
}

const dot = (s: string) => (/[.?!]$/.test(s) ? s : `${s}.`);

/** Vancouver-style citation (pure). Lists up to 6 authors, then "et al.". */
export function vancouver(c: CitationInput): string {
  const parts: string[] = [];
  const au = (c.authors ?? []).filter(Boolean);
  if (au.length) parts.push(dot(au.length > 6 ? `${au.slice(0, 6).join(', ')}, et al` : au.join(', ')));
  parts.push(dot(c.title.trim()));
  if (c.journal) parts.push(dot(c.journal));
  if (c.year !== undefined && c.year !== '') {
    let y = String(c.year);
    if (c.volume) y += `;${c.volume}${c.issue ? `(${c.issue})` : ''}`;
    if (c.pages) y += `:${c.pages}`;
    parts.push(dot(y));
  }
  if (c.pmid) parts.push(`PMID: ${c.pmid}.`);
  if (c.doi) parts.push(`doi:${c.doi}.`);
  if (c.nct) parts.push(`${c.nct}.`);
  return parts.join(' ');
}
