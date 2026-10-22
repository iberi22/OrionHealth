// Canonical JSON + hashing helpers for the evidence corpus. Zero dependencies.
import { createHash } from 'node:crypto';

export function canonicalize(value) {
  if (value === null || typeof value !== 'object') return JSON.stringify(value);
  if (Array.isArray(value)) return `[${value.map(canonicalize).join(',')}]`;
  const keys = Object.keys(value).sort();
  return `{${keys.map((k) => `${JSON.stringify(k)}:${canonicalize(value[k])}`).join(',')}}`;
}

export function sha256Hex(data) {
  return createHash('sha256').update(data).digest('hex');
}

const EXCLUDED = ['content_sha256', 'retrieved_at', 'screenshot'];

export function computeContentHash(entry) {
  const rest = {};
  for (const k of Object.keys(entry)) if (!EXCLUDED.includes(k)) rest[k] = entry[k];
  return sha256Hex(Buffer.from(canonicalize(rest), 'utf8'));
}

export function safeId(id) {
  return id.replace(/:/g, '_').toLowerCase();
}

export function entryRelPath(entry) {
  const year = (entry.published ?? entry.retrieved_at ?? '').slice(0, 4);
  return `corpus/entries/${entry.source}/${year}/${safeId(entry.id)}.json`;
}
