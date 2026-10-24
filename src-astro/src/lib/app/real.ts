// Composition of the real services (spec: docs/architecture/web-vault-family-health.md). Everything
// persists encrypted: vault session (passkey PRF) + envelope store + kernel. Used by loadServices().
// Recovery on a brand-new device (spec §9.3): the recovery invitation carries the member id, and the kernel
// runs in guest mode until the recovered MRS unlocks the session.
import type { PasskeyPrfProvider } from '@swal/vault/web';
import type { FamilyService, Services } from '../contracts/services';
import type { InviteTransport } from '../family/inviteChannel';
import { createVaultSession } from '../vault/session';
import { openEnvelopeStore } from '../vault/store';
import { createKernel } from './real/kernel.impl';
import { createRecordsService } from './real/records';
import { createHealthService } from './real/health';
import { createAssist } from './real/assist';
import { createRecoveryService } from './real/recovery';
import { createGrantsService } from './real/grants';
import { createFamilyCircleService } from './real/family';
import { createWebrtcInviteTransport } from './real/inviteTransport';

export interface RealServicesOptions {
  transport?: InviteTransport;
  passkey?: PasskeyPrfProvider;
  /** Prefix for the IndexedDB database names (default "orion"). */
  dbPrefix?: string;
  /** Open the WebRTC replica when a circle exists (default true). */
  connect?: boolean;
}

const DEVICE_KEY = 'device-id';

export async function createRealServices(opts: RealServicesOptions = {}): Promise<Services & { demo: false }> {
  const prefix = opts.dbPrefix ?? 'orion';
  const session = createVaultSession({ passkey: opts.passkey, dbName: `${prefix}-meta` });
  await session.ready();
  const store = await openEnvelopeStore(`${prefix}-vault`);

  // Meta is plain IndexedDB (no unlock needed), so the device id is stable across sessions. The kernel
  // itself stays locked (methods throw LOCKED) until the session reports 'unlocked'.
  let deviceId = await session.getMeta(DEVICE_KEY);
  if (!deviceId) {
    deviceId = crypto.randomUUID();
    await session.putMeta(DEVICE_KEY, deviceId);
  }

  const kernel = await createKernel({ session, store, deviceId, connect: opts.connect });
  const records = createRecordsService(kernel);
  const health = createHealthService(kernel, records);
  const { kb, rag } = createAssist(records);
  const transport = opts.transport ?? createWebrtcInviteTransport();
  const origin = typeof location !== 'undefined' ? location.origin : undefined;
  const recovery = createRecoveryService(kernel, session, { transport, origin });
  const grants = createGrantsService(kernel, { records, health });
  const circle = createFamilyCircleService(kernel, {
    transport,
    // Invite links point at the origin serving the app (preview, staging, production)
    origin,
    displayName: () => session.displayName() ?? '',
  });

  // The circle service only notifies on membership changes; grants and revocations (local or arriving
  // from the replica) must refresh the permission and guardian views as well.
  const grantSubs = new Set<() => void>();
  const notifyGrants = () => grantSubs.forEach((cb) => cb());
  kernel.onEnvelope((env) => {
    // Spec §9.1: the code blob goes to the replica as soon as this member belongs to a circle.
    if (env.category === 'membership') void recovery.ensureCodeBlobPublished();
    if (env.category !== 'grant') return;
    // Received keys first, so a view refreshed by this notification can already read the data.
    void grants.syncReceivedKeys().catch(() => 0).then(notifyGrants);
  });

  const family: FamilyService = {
    ...circle,
    onChange(cb) {
      const off = circle.onChange(cb);
      grantSubs.add(cb);
      return () => {
        off();
        grantSubs.delete(cb);
      };
    },
    grantsGiven: grants.grantsGiven,
    grantsReceived: grants.grantsReceived,
    async grant(to, preset, custom, expiresAt) {
      await grants.grant(to, preset, custom, expiresAt);
      notifyGrants();
    },
    guardedSummaries: grants.guardedSummaries,
    async revoke(grantId) {
      await grants.revoke(grantId);
      await kernel.revokeGrant(grantId);
      notifyGrants();
    },
  };

  // Keys received through grants become usable once unlocked (grants.ts re-syncs on each grant envelope).
  session.onState((s) => {
    if (s === 'unlocked') {
      void grants.syncReceivedKeys().catch(() => undefined);
      void recovery.ensureCodeBlobPublished();
    }
  });

  return { vault: session, records, family, health, recovery, kb, rag, demo: false };
}
