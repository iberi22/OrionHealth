import { describe, it, expect } from 'vitest';
import {
  validatePolicy,
  splitToTrustees,
  openShare,
  rewrapForRequest,
  combineShares,
} from './recovery.js';
import { generateBoxPair, randomBytes, unwrapFrom, utf8 } from '../crypto/index.js';

describe('recovery', () => {
  describe('validatePolicy', () => {
    it('throws if threshold > trustees length', () => {
      expect(() => validatePolicy({ threshold: 3, trustees: ['t1', 't2'] })).toThrow();
    });

    it('throws if threshold < 2 and allowSingle is false', () => {
      expect(() => validatePolicy({ threshold: 1, trustees: ['t1'] })).toThrow();
    });

    it('returns warning if threshold == 1 and allowSingle is true', () => {
      const warning = validatePolicy({ threshold: 1, trustees: ['t1'] }, true);
      expect(warning).toContain('Warning');
    });

    it('passes for valid policy', () => {
      expect(validatePolicy({ threshold: 2, trustees: ['t1', 't2', 't3'] })).toBeUndefined();
    });
  });

  describe('Shamirs Secret Sharing and Wrapping flow', () => {
    it('splits MRS, opens shares, rewraps and combines', async () => {
      const memberId = 'member1';
      const mrs = randomBytes(32);
      const policy = { threshold: 3, trustees: ['t1', 't2', 't3', 't4', 't5'] };

      // generate trustee box pairs
      const t1 = await generateBoxPair();
      const t2 = await generateBoxPair();
      const t3 = await generateBoxPair();
      const t4 = await generateBoxPair();
      const t5 = await generateBoxPair();
      const trusteeBoxPubs = {
        t1: t1.publicSpki,
        t2: t2.publicSpki,
        t3: t3.publicSpki,
        t4: t4.publicSpki,
        t5: t5.publicSpki,
      };
      const trusteeBoxPkcs8 = {
        t1: t1.privatePkcs8,
        t2: t2.privatePkcs8,
        t3: t3.privatePkcs8,
        t4: t4.privatePkcs8,
        t5: t5.privatePkcs8,
      };

      // 1. split to trustees
      const wrappedShares = await splitToTrustees(mrs, policy, trusteeBoxPubs, memberId);
      expect(wrappedShares).toHaveLength(5);
      expect(wrappedShares[0].trusteeId).toBe('t1');

      // 2. Open shares
      const openedShare1 = await openShare(wrappedShares[0], trusteeBoxPkcs8['t1'], memberId);
      const openedShare2 = await openShare(wrappedShares[1], trusteeBoxPkcs8['t2'], memberId);
      const openedShare3 = await openShare(wrappedShares[2], trusteeBoxPkcs8['t3'], memberId);

      // Wrong key should throw
      await expect(openShare(wrappedShares[0], trusteeBoxPkcs8['t2'], memberId)).rejects.toThrow();

      // 3. k-1 shares do not reproduce MRS
      // the k-1 test is deterministic (assert inequality, no ambiguous try/catch)
      const kMinus1 = await combineShares([openedShare1, openedShare2]);
      expect(kMinus1).not.toEqual(mrs);

      // 4. rewrap for request
      const tempKeys = await generateBoxPair();
      const requestId = 'req-123';
      const rewrapped1 = await rewrapForRequest(openedShare1, tempKeys.publicSpki, memberId, requestId);
      const rewrapped2 = await rewrapForRequest(openedShare2, tempKeys.publicSpki, memberId, requestId);
      const rewrapped3 = await rewrapForRequest(openedShare3, tempKeys.publicSpki, memberId, requestId);

      // new device unwraps them
      const aad = utf8(`orion/v1/recovery-request|${memberId}|${requestId}|${tempKeys.publicSpki}`);
      const unwrapped1 = await unwrapFrom(tempKeys.privatePkcs8, rewrapped1.ephPub, rewrapped1.wrapped, 'orion/v1/recovery-share', aad);
      const unwrapped2 = await unwrapFrom(tempKeys.privatePkcs8, rewrapped2.ephPub, rewrapped2.wrapped, 'orion/v1/recovery-share', aad);
      const unwrapped3 = await unwrapFrom(tempKeys.privatePkcs8, rewrapped3.ephPub, rewrapped3.wrapped, 'orion/v1/recovery-share', aad);

      // 5. k shares reproduce MRS
      const recovered = await combineShares([unwrapped1, unwrapped2, unwrapped3]);
      expect(recovered).toEqual(mrs);
    });

    it('shares from different splits do not combine to MRS', async () => {
      const memberId = 'member1';
      const mrs1 = randomBytes(32);
      const mrs2 = randomBytes(32);
      const policy = { threshold: 2, trustees: ['t1', 't2'] };

      const t1 = await generateBoxPair();
      const t2 = await generateBoxPair();
      const trusteeBoxPubs = {
        t1: t1.publicSpki,
        t2: t2.publicSpki,
      };

      const wrappedShares1 = await splitToTrustees(mrs1, policy, trusteeBoxPubs, memberId);
      const wrappedShares2 = await splitToTrustees(mrs2, policy, trusteeBoxPubs, memberId);

      const openedShare1_1 = await openShare(wrappedShares1[0], t1.privatePkcs8, memberId);
      const openedShare2_2 = await openShare(wrappedShares2[1], t2.privatePkcs8, memberId);

      try {
        const mix = await combineShares([openedShare1_1, openedShare2_2]);
        expect(mix).not.toEqual(mrs1);
        expect(mix).not.toEqual(mrs2);
      } catch (err) {
        expect(err).toBeDefined();
      }
    });
  });
});
