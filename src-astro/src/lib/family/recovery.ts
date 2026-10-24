import { split, combine } from 'shamir-secret-sharing';
import { wrapTo, unwrapFrom, utf8 } from '../crypto/index.js';
import type { TrusteePolicy } from '../contracts/types.js';

export interface WrappedRecoveryShare {
  trusteeId: string;
  ephPub: string;
  wrapped: string;
}

export class RecoveryError extends Error {
  constructor(public code: string, message: string) {
    super(message);
    this.name = 'RecoveryError';
  }
}

export function validatePolicy(policy: TrusteePolicy, allowSingle = false): string | undefined {
  const k = policy.threshold;
  const n = policy.trustees.length;

  if (k > n) {
    throw new RecoveryError('orion/recovery/invalid-policy', 'threshold cannot be greater than number of trustees');
  }

  if (k < 2) {
    if (k === 1 && n === 1 && allowSingle) {
      return 'Warning: 1-of-1 recovery relies entirely on a single guardian. If they lose access, you lose your data.';
    }
    throw new RecoveryError('orion/recovery/invalid-policy', 'threshold must be at least 2 unless explicitly allowing 1-of-1');
  }

  return undefined;
}

export async function splitToTrustees(
  mrs: Uint8Array,
  policy: TrusteePolicy,
  trusteeBoxPubs: Record<string, string>,
  memberId: string
): Promise<WrappedRecoveryShare[]> {
  validatePolicy(policy, false);

  const k = policy.threshold;
  const n = policy.trustees.length;

  const shares = await split(mrs, n, k);
  const result: WrappedRecoveryShare[] = [];

  for (let i = 0; i < n; i++) {
    const trusteeId = policy.trustees[i];
    const trusteeBoxPub = trusteeBoxPubs[trusteeId];
    if (!trusteeBoxPub) {
      throw new RecoveryError('orion/recovery/missing-key', `missing box pub for trustee ${trusteeId}`);
    }

    const share = shares[i];
    const aad = utf8(`orion/v1/recovery|${memberId}|${trusteeId}`);
    const wrapped = await wrapTo(trusteeBoxPub, share, 'orion/v1/recovery-share', aad);

    result.push({
      trusteeId,
      ephPub: wrapped.ephPub,
      wrapped: wrapped.wrapped,
    });
  }

  return result;
}

export async function openShare(
  wrappedShare: WrappedRecoveryShare,
  myBoxPkcs8: string,
  memberId: string
): Promise<Uint8Array<ArrayBuffer>> {
  const aad = utf8(`orion/v1/recovery|${memberId}|${wrappedShare.trusteeId}`);
  return unwrapFrom(myBoxPkcs8, wrappedShare.ephPub, wrappedShare.wrapped, 'orion/v1/recovery-share', aad);
}

export async function rewrapForRequest(
  share: Uint8Array,
  tempBoxPub: string,
  memberId: string
): Promise<{ ephPub: string; wrapped: string }> {
  const aad = utf8(`orion/v1/recovery|${memberId}|temp`);
  return wrapTo(tempBoxPub, share, 'orion/v1/recovery-share', aad);
}

export async function combineShares(shares: Uint8Array[]): Promise<Uint8Array> {
  return combine(shares);
}
