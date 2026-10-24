import { describe, it, expect, beforeAll } from 'vitest';
import { sealEnvelope, verifyEnvelope, openEnvelope } from './envelope.js';
import { generateSigningPair, aesKey, randomBytes } from '../crypto/index.js';

describe('envelope', () => {
  let authorSignPair: Awaited<ReturnType<typeof generateSigningPair>>;
  let categoryKey: CryptoKey;
  let wrongCategoryKey: CryptoKey;

  beforeAll(async () => {
    authorSignPair = await generateSigningPair();
    categoryKey = await aesKey(randomBytes(32));
    wrongCategoryKey = await aesKey(randomBytes(32));
  });

  const getArgs = () => ({
    id: 'test-id',
    circle: 'test-circle',
    owner: 'test-owner',
    author: 'test-author',
    device: 'test-device',
    category: 'emergency' as const,
    epoch: 1,
    hlc: '1696200000000-0000-devA',
    plaintext: { recordId: 'test-record', kind: 'medical-id', data: 'hello' },
    categoryKey,
    authorSignPkcs8: authorSignPair.privatePkcs8,
  });

  it('seals, verifies, and opens correctly', async () => {
    const args = getArgs();
    const env = await sealEnvelope(args);

    expect(env.v).toBe(1);
    expect(env.id).toBe(args.id);
    expect(env.sig).toBeTruthy();

    const isVerified = await verifyEnvelope(env, authorSignPair.publicSpki);
    expect(isVerified).toBe(true);

    const opened = await openEnvelope(env, categoryKey);
    expect(opened).toEqual(args.plaintext);
  });

  it('fails verify and open on tampering', async () => {
    const args = getArgs();
    const env = await sealEnvelope(args);

    // Tamper with circle
    const tamperedEnv = { ...env, circle: 'tampered-circle' };

    const isVerified = await verifyEnvelope(tamperedEnv, authorSignPair.publicSpki);
    expect(isVerified).toBe(false);

    await expect(openEnvelope(tamperedEnv, categoryKey)).rejects.toThrow();
  });

  it('fails open on wrong category key', async () => {
    const args = getArgs();
    const env = await sealEnvelope(args);

    await expect(openEnvelope(env, wrongCategoryKey)).rejects.toThrow();
  });
});
