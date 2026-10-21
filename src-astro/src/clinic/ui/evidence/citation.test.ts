import { describe, it, expect } from 'vitest';
import { vancouver } from './citation';

describe('vancouver', () => {
  it('formats a full journal citation', () => {
    expect(vancouver({
      authors: ['Smith J', 'Lee K'], title: 'Statins in CKD.', journal: 'Lancet', year: 2020,
      volume: '395', issue: '2', pages: '100-8', pmid: '123',
    })).toBe('Smith J, Lee K. Statins in CKD. Lancet. 2020;395(2):100-8. PMID: 123.');
  });
  it('truncates beyond six authors with et al.', () => {
    const a = ['A A', 'B B', 'C C', 'D D', 'E E', 'F F', 'G G'];
    expect(vancouver({ authors: a, title: 'T', year: 2019 })).toBe('A A, B B, C C, D D, E E, F F, et al. T. 2019.');
  });
  it('handles missing fields and adds doi/nct', () => {
    expect(vancouver({ title: 'Only title', doi: '10.1/x', nct: 'NCT01' })).toBe('Only title. doi:10.1/x. NCT01.');
  });
});
