import { describe, it, expect } from 'vitest';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

function parseRedirects(filePath: string) {
  const content = fs.readFileSync(filePath, 'utf-8');
  return content.split('\n')
    .map(line => line.trim())
    .filter(line => line.length > 0 && !line.startsWith('#'))
    .map(line => {
      const parts = line.split(/\s+/);
      return {
        from: parts[0],
        to: parts[1],
        status: parts[2]
      };
    });
}

describe('Redirect rules', () => {
  it('all docs redirects target orionhealth.swal.network', () => {
    const redirectsPath = path.resolve(__dirname, '../../../docs/public/_redirects');
    const rules = parseRedirects(redirectsPath);
    expect(rules.length).toBeGreaterThan(0);
    for (const rule of rules) {
      expect(rule.to.startsWith('https://orionhealth.swal.network')).toBe(true);
    }
  });

  it('all web redirects target orionhealth.swal.network', () => {
    const redirectsPath = path.resolve(__dirname, '../../../web/_redirects');
    const rules = parseRedirects(redirectsPath);
    expect(rules.length).toBeGreaterThan(0);
    for (const rule of rules) {
      expect(rule.to.startsWith('https://orionhealth.swal.network')).toBe(true);
    }
  });
});
