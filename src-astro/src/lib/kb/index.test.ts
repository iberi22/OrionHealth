import { describe, it, expect, vi } from 'vitest';
import { createKb } from './index';
import type { KbEntry, KbSystem } from '../contracts/types';

describe('KbService', () => {
  const mockIcd10: KbEntry[] = [
    {
      id: 'icd10:A00.0',
      system: 'icd10',
      code: 'A00.0',
      title: 'Cholera due to Vibrio cholerae 01, biovar cholerae',
      body: 'Cholera due to Vibrio cholerae 01, biovar cholerae is an infectious condition caused by pathogenic microorganisms.',
      related: ['Cólera due to Vibrio cólerae 01, biovar cólerae']
    },
    {
      id: 'icd10:I10',
      system: 'icd10',
      code: 'I10',
      title: 'Essential (primary) hypertension',
      body: 'High blood pressure that does not have a known secondary cause.',
      related: ['Hipertensión arterial']
    }
  ];

  const mockSymptom: KbEntry[] = [
    {
      id: 'symptom:Chest Pain',
      system: 'symptom',
      code: 'Chest Pain',
      title: 'Chest Pain',
      body: 'Category: cardiovascular\nMatches: []\nRed Flags: "Crushing pain"',
      related: ['dolor de pecho']
    }
  ];

  const fetcher = async (url: string): Promise<Response> => {
    let data: any[] = [];
    if (url === '/kb/icd10.json') {
      data = mockIcd10;
    } else if (url === '/kb/symptom.json') {
      data = mockSymptom;
    } else {
      return new Response(null, { status: 404, statusText: 'Not Found' });
    }

    return new Response(JSON.stringify(data), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });
  };

  it('loads systems and searches them', async () => {
    const kb = createKb(fetcher);
    await kb.load(['icd10', 'symptom']);

    const hits = await kb.search('hypertension');
    expect(hits.length).toBeGreaterThan(0);
    expect(hits[0].entry.id).toBe('icd10:I10');
  });

  it('ranks exact code matches first', async () => {
    const kb = createKb(fetcher);
    await kb.load(['icd10']);

    // A search that might match words but should match the exact code highly
    const hits = await kb.search('A00.0');
    expect(hits.length).toBeGreaterThan(0);
    expect(hits[0].entry.code).toBe('A00.0');
    expect(hits[0].score).toBeGreaterThan(100); // Because of the exact match boost
  });

  it('can get an entry by id', async () => {
    const kb = createKb(fetcher);
    // Explicitly do not load first, let `get` lazy load
    const entry = await kb.get('symptom:Chest Pain');
    expect(entry).not.toBeNull();
    expect(entry?.title).toBe('Chest Pain');
  });

  it('returns null for unknown id', async () => {
    const kb = createKb(fetcher);
    const entry = await kb.get('icd10:Z99.9');
    expect(entry).toBeNull();
  });

  it('filters search by systems', async () => {
    const kb = createKb(fetcher);
    await kb.load(['icd10', 'symptom']);

    const hits = await kb.search('Cholera', { systems: ['symptom'] });
    expect(hits.length).toBe(0);

    const hits2 = await kb.search('Cholera', { systems: ['icd10'] });
    expect(hits2.length).toBeGreaterThan(0);
    expect(hits2[0].entry.id).toBe('icd10:A00.0');
  });

  it('handles fetch errors gracefully', async () => {
    const kb = createKb(fetcher);
    // 'rxnorm' mock doesn't exist, fetcher will 404
    await kb.load(['rxnorm']);
    const hits = await kb.search('Lisinopril', { systems: ['rxnorm'] });
    expect(hits.length).toBe(0);
  });
});
