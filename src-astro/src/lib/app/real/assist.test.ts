import { describe, expect, it, vi } from 'vitest';
import { createAssist } from './assist';
import type { RecordsService } from '../../contracts/services';
import type { HealthRecord } from '../../contracts/types';

describe('createAssist', () => {
  it('returns rag and kb that fetches only /kb/*.json without PHI egress', async () => {
    // Mock RecordsService to return a piece of PHI
    const mockRecords: Partial<RecordsService> = {
      list: async <K extends HealthRecord['kind']>(kind: K) => {
        if (kind === 'vital') {
          return [
            {
              kind: 'vital',
              recordId: 'v-1',
              owner: 'me',
              updatedAt: 1000,
              type: 'bp',
              value: 120,
              unit: 'mmHg',
              at: 1000,
            }
          ] as unknown as Extract<HealthRecord, { kind: K }>[];
        }
        return [];
      }
    };

    // Spied fetcher that returns a new Response on each call so body is not read multiple times
    const fetcher = vi.fn().mockImplementation(async () => {
      return new Response(JSON.stringify([]), {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      });
    });

    const { rag } = createAssist(mockRecords as RecordsService, fetcher);

    const result = await rag.ask('What is normal blood pressure?', { includePersonal: true });

    // Ensure we actually used personal data
    expect(result.usedPersonalData).toBe(true);

    // Verify fetch calls
    const calls = fetcher.mock.calls;
    expect(calls.length).toBeGreaterThan(0);

    for (const call of calls) {
      const url = call[0];
      // Assert it only fetches local knowledge base files
      expect(url).toMatch(/^\/kb\/[a-z0-9]+\.json$/);
      // Assert no PHI (like "120") leaked into the URL
      expect(url).not.toContain('120');
      expect(url).not.toContain('vital');
      expect(url).not.toContain('bp');
    }
  });
});
