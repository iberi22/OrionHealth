import { describe, expect, it } from 'vitest';
import { createMockServices } from './mock';
import { getServices, setServices } from './services';

describe('mock services (demo family, no PHI)', () => {
  it('starts locked and unlocks through the vault', async () => {
    const s = createMockServices(0);
    expect(s.vault.state()).toBe('locked');
    expect(s.vault.memberId()).toBeNull();
    await s.vault.unlock();
    expect(s.vault.memberId()).toBe('m-ana');
  });

  it('exposes a guardian view of the elder member with an open alert', async () => {
    const s = createMockServices(0);
    const [rosa] = await s.family.guardedSummaries();
    expect(rosa?.member.displayName).toContain('Rosa');
    expect(rosa?.openAlerts).toHaveLength(1);
    await s.health.acknowledge('a-1');
    expect((await s.family.guardedSummaries())[0]?.openAlerts).toHaveLength(0);
  });

  it('getServices throws until set', () => {
    expect(() => getServices()).toThrow();
    setServices(createMockServices(0));
    expect(getServices().vault.state()).toBe('locked');
  });
});
