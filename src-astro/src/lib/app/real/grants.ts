// Real grants service (spec §6). Grants and revocations travel as circle-keyed envelopes of category
// 'grant'. The plaintext is either a signed Grant, or a revocation marker { kind: 'revoke', grantId }
// whose envelope author must be the owner of the revoked grant. The wrapped CEK never leaves the kernel:
// the Grant is assembled here from kernel.wrapKeyFor and signed with the owner's sign key.

import type { Access, AccessPreset, Alert, Grant, GuardedSummary, Member, PersonalCategory, VitalReading } from '../../contracts/types';
import { PERSONAL_CATEGORIES } from '../../contracts/types';
import type { FamilyService, HealthCircleService, RecordsService } from '../../contracts/services';
import { b64u, canonical, randomBytes, sign, utf8 } from '../../crypto/index';
import { activeGrants, expandPreset, verifyGrant } from '../../family/grants';
import type { Kernel } from './kernel';

export interface RevokeMarker {
  kind: 'revoke';
  grantId: string;
}

const GRANT_INFO = 'orion/v1/grant';
const LATEST_VITALS = 10;

const isPersonal = (c: string): c is PersonalCategory => (PERSONAL_CATEGORIES as readonly string[]).includes(c);

const grantAad = (g: Pick<Grant, 'circle' | 'from' | 'to' | 'category' | 'epoch' | 'access'>) =>
  utf8([GRANT_INFO, g.circle, g.from, g.to, g.category, g.epoch, g.access].join('|'));

export function createGrantsService(
  kernel: Kernel,
  deps: { records?: RecordsService; health?: HealthCircleService } = {},
): Pick<FamilyService, 'grantsGiven' | 'grantsReceived' | 'grant' | 'revoke' | 'guardedSummaries'> & {
  syncReceivedKeys(): Promise<number>;
  dropRemovedMembers(): Promise<number>;
} {
  const synced = new Set<string>();

  /** Valid (author + signature checked), non-revoked grants from the 'grant' envelopes; expiry is not applied. */
  const readGrants = async (): Promise<Grant[]> => {
    const envs = await kernel.envelopes({ category: 'grant' });
    const grants: Grant[] = [];
    const revokes: { grantId: string; author: string }[] = [];
    for (const env of envs) {
      let pt: unknown;
      try {
        pt = await kernel.open(env);
      } catch {
        continue;
      }
      if (!pt || typeof pt !== 'object') continue;
      const o = pt as Partial<Grant> & Partial<RevokeMarker>;
      if (o.kind === 'revoke' && typeof o.grantId === 'string') {
        revokes.push({ grantId: o.grantId, author: env.author });
      } else if (o.v === 1 && typeof o.id === 'string' && typeof o.from === 'string' && env.author === o.from) {
        const pub = await kernel.signPubOf(o.from);
        if (pub && (await verifyGrant(o as Grant, pub).catch(() => false))) grants.push(o as Grant);
      }
    }
    const byId = new Map(grants.map((g) => [g.id, g]));
    const revoked = new Set<string>();
    for (const r of revokes) if (byId.get(r.grantId)?.from === r.author) revoked.add(r.grantId);
    return activeGrants(grants, 0, revoked).filter((g, i, a) => a.findIndex((x) => x.id === g.id) === i);
  };

  const live = async (): Promise<Grant[]> => activeGrants(await readGrants(), Date.now());

  const grantsGiven = async () => {
    const me = kernel.memberId();
    return (await live()).filter((g) => g.from === me);
  };
  const grantsReceived = async () => {
    const me = kernel.memberId();
    return (await live()).filter((g) => g.to === me);
  };

  const publishGrant = async (to: string, category: PersonalCategory, access: Access, expiresAt?: number) => {
    const boxPub = await kernel.boxPubOf(to);
    if (!boxPub) throw new Error(`unknown box key for member ${to}`);
    const circle = (await kernel.circle())?.circleId ?? 'local';
    const from = kernel.memberId();
    const { epoch } = await kernel.categoryKey(category);
    const base = { circle, from, to, category, epoch, access };
    const w = await kernel.wrapKeyFor({ category, epoch }, boxPub, GRANT_INFO, grantAad(base));
    const unsigned: Omit<Grant, 'sig'> = {
      v: 1,
      id: b64u(randomBytes(16)),
      ...base,
      ...(expiresAt !== undefined ? { expiresAt } : {}),
      ephPub: w.ephPub,
      wrapped: w.wrapped,
    };
    const g: Grant = { ...unsigned, sig: await sign(kernel.bundle().signPkcs8, canonical(unsigned, ['sig'])) };
    await kernel.publish(await kernel.seal({ category: 'grant', plaintext: g }));
  };

  const grant: FamilyService['grant'] = async (to, preset: AccessPreset, custom, expiresAt) => {
    const { categories, access } = expandPreset(preset, custom);
    for (const category of categories) await publishGrant(to, category, access, expiresAt);
  };

  const syncReceivedKeys = async (): Promise<number> => {
    let added = 0;
    for (const g of await grantsReceived()) {
      if (synced.has(g.id) || !isPersonal(g.category)) continue;
      try {
        const raw = await kernel.unwrapForMe(g.ephPub, g.wrapped, GRANT_INFO, grantAad(g));
        kernel.addForeignKey(g.from, g.category, g.epoch, raw);
        synced.add(g.id);
        added++;
      } catch {
        /* not unwrappable by me */
      }
    }
    return added;
  };

  // Rotations (revoke, removal) run one at a time: each reads the grants the previous one left.
  let rotations: Promise<unknown> = Promise.resolve();
  const serial = <T>(fn: () => Promise<T>): Promise<T> => {
    const run = rotations.then(fn);
    rotations = run.catch(() => undefined);
    return run;
  };

  /**
   * Spec §6: one revoke marker per dropped grant of mine for `category`, epoch+1 for the category, and the new
   * epoch re-granted to every other live grantee that is still a circle member.
   */
  const rotateWithout = async (category: PersonalCategory, drop: (g: Grant) => boolean) => {
    const me = kernel.memberId();
    const mine = (await readGrants()).filter((g) => g.from === me && g.category === category);
    const dropped = mine.filter(drop);
    if (!dropped.length) return false;
    const members = (await kernel.circle())?.members ?? {};
    const remaining = new Map<string, Grant>();
    for (const g of activeGrants(mine, Date.now())) {
      if (drop(g) || members[g.to]?.removed) continue;
      const prev = remaining.get(g.to);
      if (!prev || g.epoch > prev.epoch) remaining.set(g.to, g);
    }
    for (const g of dropped) {
      const marker: RevokeMarker = { kind: 'revoke', grantId: g.id };
      await kernel.publish(await kernel.seal({ category: 'grant', plaintext: marker }));
    }
    await kernel.rotateCategory(category);
    for (const g of remaining.values()) await publishGrant(g.to, category, g.access, g.expiresAt);
    return true;
  };

  /**
   * Spec §7: once a `remove` is in the membership log, every personal category I granted to a removed member
   * (expired grants included: the CEK was unwrapped while they were valid) is rotated and re-granted to the
   * remaining grantees. Idempotent: the revoke markers make a second run find nothing. Returns the number of
   * categories rotated.
   */
  const dropRemovedMembers = () =>
    serial(async () => {
      const circle = await kernel.circle();
      const me = kernel.memberId();
      if (!circle || !circle.members[me] || circle.members[me]!.removed) return 0;
      const removed = new Set(Object.values(circle.members).filter((m) => m.removed).map((m) => m.memberId));
      if (!removed.size) return 0;
      const categories = new Set<PersonalCategory>();
      for (const g of await readGrants()) if (g.from === me && removed.has(g.to) && isPersonal(g.category)) categories.add(g.category);
      let rotated = 0;
      for (const category of categories) if (await rotateWithout(category, (g) => removed.has(g.to))) rotated++;
      return rotated;
    });

  kernel.onEnvelope((env) => {
    if (env.category === 'grant') void syncReceivedKeys().catch(() => undefined);
    // Returned to the kernel, which awaits it: removeMember() resolves only after my categories rotated.
    if (env.category === 'membership') return dropRemovedMembers().then(() => undefined, () => undefined);
  });

  const revoke: FamilyService['revoke'] = async (grantId) => {
    const target = (await grantsGiven()).find((g) => g.id === grantId);
    if (!target || !isPersonal(target.category)) throw new Error(`grant ${grantId} not found or not mine`);
    // Every grant of that grantee for the category goes away (older epochs included).
    await serial(() => rotateWithout(target.category as PersonalCategory, (g) => g.to === target.to));
  };

  const guardedSummaries = async (): Promise<GuardedSummary[]> => {
    const received = await grantsReceived();
    const circle = await kernel.circle();
    const owners = [...new Set(received.map((g) => g.from))];
    const alerts: Alert[] = (await deps.health?.alerts().catch(() => [])) ?? [];
    const out: GuardedSummary[] = [];
    for (const owner of owners) {
      const grantedCategories = [...new Set(received.filter((g) => g.from === owner).map((g) => g.category))].filter(isPersonal);
      const member: Member = circle?.members[owner] ?? {
        memberId: owner,
        displayName: owner,
        role: 'member',
        signPub: (await kernel.signPubOf(owner)) ?? '',
        boxPub: (await kernel.boxPubOf(owner)) ?? '',
        devices: [],
        guardianOf: [],
        dependent: false,
        removed: false,
      };
      let vitals: VitalReading[] = [];
      if (grantedCategories.includes('vitals')) {
        vitals = (await deps.records?.list('vital', owner).catch(() => [] as VitalReading[])) ?? [];
      }
      out.push({
        member,
        latestVitals: [...vitals].sort((a, b) => b.at - a.at).slice(0, LATEST_VITALS),
        openAlerts: alerts.filter((a) => a.subject === owner && !a.acknowledgedBy),
        grantedCategories,
      });
    }
    return out;
  };

  return { grantsGiven, grantsReceived, grant, revoke, guardedSummaries, syncReceivedKeys, dropRemovedMembers };
}
