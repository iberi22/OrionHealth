import { describe, expect, it } from 'vitest';
import { PERSONAL_CATEGORIES, type Alert, type VitalReading } from '../../contracts/types';
import type { HealthCircleService, RecordsService } from '../../contracts/services';
import { randomBytes } from '../../crypto/index';
import { FakeKernel, FakeNetwork } from './kernel.fake';
import { createGrantsService } from './grants';

async function peers(n: number) {
  const net = new FakeNetwork();
  const ck = randomBytes(32);
  const ks: FakeKernel[] = [];
  for (let i = 0; i < n; i++) ks.push(await FakeKernel.create({ network: net }));
  FakeKernel.introduce(...ks);
  for (const k of ks) {
    k.addCircleKey(0, ck);
    await k.setCircle('circle-1', { memberId: ks[0]!.memberId(), signPub: ks[0]!.bundle().signPub });
  }
  return ks.map((kernel) => ({ kernel, svc: createGrantsService(kernel) }));
}

const sealVitals = async (k: FakeKernel, v: unknown) => {
  const env = await k.seal({ category: 'vitals', plaintext: v });
  await k.publish(env);
  return env;
};

describe('GrantsService', () => {
  it('guardian preset grants every personal category with write', async () => {
    const [ana, rosa] = await peers(2);
    await ana!.svc.grant(rosa!.kernel.memberId(), 'guardian');
    const given = await ana!.svc.grantsGiven();
    expect(given.map((g) => g.category).sort()).toEqual([...PERSONAL_CATEGORIES].sort());
    expect(given.every((g) => g.access === 'write' && g.to === rosa!.kernel.memberId())).toBe(true);
    expect(await rosa!.svc.grantsReceived()).toHaveLength(PERSONAL_CATEGORIES.length);
    expect(await rosa!.svc.grantsGiven()).toHaveLength(0);
  });

  it('grantee opens the owner vitals only after syncReceivedKeys; others get NO_KEY', async () => {
    const [ana, rosa, leo] = await peers(3);
    const env = await sealVitals(ana!.kernel, { v: 1 });
    await ana!.svc.grant(rosa!.kernel.memberId(), 'caregiver');
    await rosa!.svc.syncReceivedKeys();
    expect(await rosa!.kernel.open(env)).toEqual({ v: 1 });
    await leo!.svc.syncReceivedKeys();
    await expect(leo!.kernel.open(env)).rejects.toMatchObject({ code: 'NO_KEY' });
  });

  it('syncReceivedKeys returns the number of keys added, once', async () => {
    const [ana, rosa] = await peers(2);
    await ana!.svc.grant(rosa!.kernel.memberId(), 'emergency-only');
    await new Promise((r) => setTimeout(r, 20)); // auto-sync from onEnvelope may already have run
    const first = await rosa!.svc.syncReceivedKeys();
    expect(first).toBeLessThanOrEqual(1);
    expect(await rosa!.svc.syncReceivedKeys()).toBe(0);
  });

  it('an expired grant is inactive and a forged grant is ignored', async () => {
    const [ana, rosa] = await peers(2);
    await ana!.svc.grant(rosa!.kernel.memberId(), 'emergency-only', undefined, Date.now() + 60_000);
    expect(await rosa!.svc.grantsReceived()).toHaveLength(1);
    await ana!.svc.grant(rosa!.kernel.memberId(), 'custom', { categories: ['allergies'], access: 'read' }, Date.now() - 1);
    expect(await rosa!.svc.grantsReceived()).toHaveLength(1);
    expect(await rosa!.svc.syncReceivedKeys()).toBeLessThanOrEqual(1);

    const [g] = await ana!.svc.grantsGiven();
    const forged = await rosa!.kernel.seal({ category: 'grant', plaintext: { ...g!, to: rosa!.kernel.memberId(), category: 'conditions', id: 'x' } });
    await rosa!.kernel.publish(forged);
    expect((await rosa!.svc.grantsReceived()).some((x) => x.id === 'x')).toBe(false);
  });

  it('spec §12: revoked member cannot open epoch+1; remaining grantee can', async () => {
    const [ana, rosa, leo] = await peers(3);
    await ana!.svc.grant(rosa!.kernel.memberId(), 'caregiver');
    await ana!.svc.grant(leo!.kernel.memberId(), 'caregiver');
    await rosa!.svc.syncReceivedKeys();
    await leo!.svc.syncReceivedKeys();
    const old = await sealVitals(ana!.kernel, { n: 1 });
    expect(await rosa!.kernel.open(old)).toEqual({ n: 1 });

    const rosaVitals = (await ana!.svc.grantsGiven()).find((g) => g.to === rosa!.kernel.memberId() && g.category === 'vitals')!;
    await ana!.svc.revoke(rosaVitals.id);

    const fresh = await sealVitals(ana!.kernel, { n: 2 });
    expect(fresh.epoch).toBe(old.epoch + 1);
    await rosa!.svc.syncReceivedKeys();
    await leo!.svc.syncReceivedKeys();
    await expect(rosa!.kernel.open(fresh)).rejects.toMatchObject({ code: 'NO_KEY' });
    expect(await leo!.kernel.open(fresh)).toEqual({ n: 2 });
    // history seen before stays readable, other categories of rosa are untouched
    expect(await rosa!.kernel.open(old)).toEqual({ n: 1 });
    expect((await rosa!.svc.grantsReceived()).some((g) => g.category === 'vitals')).toBe(false);
    expect((await rosa!.svc.grantsReceived()).some((g) => g.category === 'medications')).toBe(true);
  });

  it('only the owner can revoke; a stranger revoke marker is ignored', async () => {
    const [ana, rosa] = await peers(2);
    await ana!.svc.grant(rosa!.kernel.memberId(), 'emergency-only');
    const [g] = await rosa!.svc.grantsReceived();
    await expect(rosa!.svc.revoke(g!.id)).rejects.toThrow();
    await rosa!.kernel.publish(await rosa!.kernel.seal({ category: 'grant', plaintext: { kind: 'revoke', grantId: g!.id } }));
    expect(await rosa!.svc.grantsReceived()).toHaveLength(1);
    expect(await ana!.svc.grantsGiven()).toHaveLength(1);
  });

  it('guardedSummaries shows granted categories, latest vitals and open alerts', async () => {
    const [ana, rosa] = await peers(2);
    const vital: VitalReading = { kind: 'vital', recordId: 'v1', owner: ana!.kernel.memberId(), type: 'bp', value: 120, unit: 'mmHg', updatedAt: 1, at: 1 };
    const alerts: Alert[] = [
      { alertId: 'a1', ruleId: 'r', subject: ana!.kernel.memberId(), at: 1, message: 'm', severity: 'warning' },
      { alertId: 'a2', ruleId: 'r', subject: ana!.kernel.memberId(), at: 1, message: 'm', severity: 'info', acknowledgedBy: 'x' },
      { alertId: 'a3', ruleId: 'r', subject: 'other', at: 1, message: 'm', severity: 'info' },
    ];
    const records = { list: async () => [vital] } as unknown as RecordsService;
    const health = { alerts: async () => alerts } as unknown as HealthCircleService;
    const svc = createGrantsService(rosa!.kernel, { records, health });
    expect(await svc.guardedSummaries()).toEqual([]);
    await ana!.svc.grant(rosa!.kernel.memberId(), 'caregiver');
    const [s] = await svc.guardedSummaries();
    expect(s!.member.memberId).toBe(ana!.kernel.memberId());
    expect(s!.latestVitals).toEqual([vital]);
    expect(s!.openAlerts.map((a) => a.alertId)).toEqual(['a1']);
    expect([...s!.grantedCategories].sort()).toEqual(['allergies', 'appointments', 'emergency', 'medications', 'vitals']);
  });
});
