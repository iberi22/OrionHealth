export interface Segment { text: string; hit: boolean }

/** Split a snippet into plain/highlighted segments (rendered as text, never HTML). */
export function highlightSegments(snippet: string, terms: string[] = []): Segment[] {
  const ts = terms.map((x) => x.trim()).filter(Boolean);
  if (!ts.length) return [{ text: snippet, hit: false }];
  const re = new RegExp(`(${ts.map((x) => x.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')).join('|')})`, 'gi');
  return snippet.split(re).filter((s) => s !== '').map((text, i) => ({ text, hit: i % 2 === 1 }));
}
