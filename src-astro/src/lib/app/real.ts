// Composition of the real services (spec: docs/architecture/web-vault-family-health.md). Everything
// persists encrypted: vault session (passkey PRF) + envelope store + kernel. Used by loadServices().
//
// PENDING: recovery on a brand-new device. RecoveryService.startRecovery needs the member id of the
// account being recovered before the vault exists, but the contract gives no way to obtain it (the
// session is empty, kernel.memberId() throws LOCKED). No protocol is invented here; the UI/ spec must
// define how the new device learns the member id (e.g. carried by the recovery invite).
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
  const recovery = createRecoveryService(kernel, session);
  const grants = createGrantsService(kernel, { records, health });
  const circle = createFamilyCircleService(kernel, {
    transport: opts.transport ?? createWebrtcInviteTransport(),
    displayName: () => session.displayName() ?? '',
  });

  const family: FamilyService = {
    ...circle,
    grantsGiven: grants.grantsGiven,
    grantsReceived: grants.grantsReceived,
    grant: grants.grant,
    guardedSummaries: grants.guardedSummaries,
    async revoke(grantId) {
      await grants.revoke(grantId);
      await kernel.revokeGrant(grantId);
    },
  };

  // Keys received through grants become usable once unlocked (grants.ts re-syncs on each grant envelope).
  session.onState((s) => {
    if (s === 'unlocked') void grants.syncReceivedKeys().catch(() => undefined);
  });

  return { vault: session, records, family, health, recovery, kb, rag, demo: false };
}
