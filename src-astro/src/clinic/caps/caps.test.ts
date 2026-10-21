import { describe, expect, it, vi } from 'vitest';
import { detectCaps, type CapsEnv } from './detect';
import { resolveBudget, type Budget } from './budgets';
import { resolveTier } from './tiers';
import type { Caps } from './detect';

const GB = 1024 ** 3;
const MB = 1024 ** 2;

class OkWorker {
  constructor(_url: string, opts?: { type?: string }) {
    void opts?.type;
  }
  terminate() {}
}
class NoModuleWorker {
  constructor(_url: string, _opts?: { type?: string }) {}
  terminate() {}
}

function fullEnv(over: Partial<CapsEnv> = {}): CapsEnv {
  return {
    Worker: OkWorker as unknown as CapsEnv['Worker'],
    indexedDB: {},
    DecompressionStream: class {
      constructor(f: string) {
        if (f !== 'gzip') throw new TypeError('bad');
      }
    } as unknown as CapsEnv['DecompressionStream'],
    crypto: { subtle: { digest: async () => new ArrayBuffer(32) } },
    WebAssembly: { validate: () => true },
    navigator: {
      deviceMemory: 4,
      storage: {
        estimate: async () => ({ quota: 10 * GB, usage: 1 * GB }),
        persisted: async () => true,
        persist: async () => true,
        getDirectory: async () => ({}),
      },
    },
    ...over,
  };
}

function caps(over: Partial<Caps> = {}): Caps {
  return {
    supported: true,
    missing: [],
    simd: true,
    deviceMemory: 4,
    saveData: false,
    quotaBytes: 10 * GB,
    usageBytes: 0,
    freeBytes: 10 * GB,
    persisted: true,
    opfs: true,
    promptApi: 'unavailable',
    gpu: { available: false, maxBufferSize: 0 },
    ...over,
  };
}

describe('detectCaps', () => {
  it('detects a full environment', async () => {
    const c = await detectCaps(fullEnv());
    expect(c.supported).toBe(true);
    expect(c.simd).toBe(true);
    expect(c.opfs).toBe(true);
    expect(c.freeBytes).toBe(9 * GB);
    expect(c.persisted).toBe(true);
    expect(c.deviceMemory).toBe(4);
  });
  it.each([
    ['moduleWorker', { Worker: undefined }],
    ['indexedDB', { indexedDB: undefined }],
    ['decompressionStream', { DecompressionStream: undefined }],
    ['cryptoDigest', { crypto: undefined }],
  ] as const)('unsupported without %s', async (name, over) => {
    const c = await detectCaps(fullEnv(over as Partial<CapsEnv>));
    expect(c.supported).toBe(false);
    expect(c.missing).toContain(name);
  });
  it('flags Worker that ignores type:module', async () => {
    const c = await detectCaps(fullEnv({ Worker: NoModuleWorker as unknown as CapsEnv['Worker'] }));
    expect(c.missing).toContain('moduleWorker');
  });
  it('keeps moduleWorker when the CSP blocks the data: probe after type was read', async () => {
    class CspBlockedWorker {
      constructor(_url: string, opts?: { type?: string }) {
        void opts?.type;
        throw new Error('SecurityError: blocked by worker-src');
      }
      terminate() {}
    }
    const c = await detectCaps(
      fullEnv({ Worker: CspBlockedWorker as unknown as CapsEnv['Worker'] }),
    );
    expect(c.missing).not.toContain('moduleWorker');
  });
  it('flags moduleWorker when the Worker throws without reading type', async () => {
    class ThrowingWorker {
      constructor(_url: string, _opts?: { type?: string }) {
        throw new Error('nope');
      }
      terminate() {}
    }
    const c = await detectCaps(fullEnv({ Worker: ThrowingWorker as unknown as CapsEnv['Worker'] }));
    expect(c.missing).toContain('moduleWorker');
  });
  it('flags decompressionStream when gzip is rejected', async () => {
    const c = await detectCaps(
      fullEnv({
        DecompressionStream: class {
          constructor(_f: string) {
            throw new TypeError('gzip unsupported');
          }
        } as unknown as CapsEnv['DecompressionStream'],
      }),
    );
    expect(c.missing).toContain('decompressionStream');
  });
  it('never calls storage.persist() while probing persisted state', async () => {
    const persist = vi.fn(async () => true);
    const c = await detectCaps(
      fullEnv({
        navigator: {
          storage: {
            estimate: async () => ({ quota: 10 * GB, usage: 0 }),
            persist,
            getDirectory: async () => ({}),
          },
        },
      }),
    );
    expect(persist).not.toHaveBeenCalled();
    expect(c.persisted).toBe(false);
  });
  it('catches throwing probes', async () => {
    const c = await detectCaps(
      fullEnv({
        crypto: { subtle: { digest: async () => { throw new Error('x'); } } },
        WebAssembly: { validate: () => { throw new Error('x'); } },
        navigator: { storage: { estimate: async () => { throw new Error('x'); }, getDirectory: async () => { throw new Error('x'); } } },
      }),
    );
    expect(c.missing).toContain('cryptoDigest');
    expect(c.simd).toBe(false);
    expect(c.opfs).toBe(false);
    expect(c.quotaBytes).toBeNull();
    expect(c.deviceMemory).toBeNull();
  });
  it('reads prompt api, gpu and saveData', async () => {
    const c = await detectCaps(
      fullEnv({
        LanguageModel: { availability: async () => 'available' },
        navigator: {
          deviceMemory: 8,
          connection: { saveData: true },
          gpu: { requestAdapter: async () => ({ limits: { maxBufferSize: 2 * GB } }) },
        },
      }),
    );
    expect(c.promptApi).toBe('available');
    expect(c.gpu).toEqual({ available: true, maxBufferSize: 2 * GB });
    expect(c.saveData).toBe(true);
  });
});

describe('resolveBudget', () => {
  const cases: Array<[string, Partial<Caps>, Budget['profile'], number, number]> = [
    ['deviceMemory 2', { deviceMemory: 2 }, 'low', 80 * MB, 1],
    ['deviceMemory 1', { deviceMemory: 1 }, 'low', 80 * MB, 1],
    ['saveData', { saveData: true }, 'low', 80 * MB, 1],
    ['small quota', { quotaBytes: 500 * MB }, 'low', 80 * MB, 1],
    ['standard 4GB ram', { deviceMemory: 4 }, 'standard', 400 * MB, 4],
    ['large', { deviceMemory: 8, quotaBytes: 4 * GB }, 'large', 2 * GB, Infinity],
    ['8GB ram, 3GB quota', { deviceMemory: 8, quotaBytes: 3 * GB }, 'standard', 400 * MB, 4],
    ['unknown memory', { deviceMemory: null }, 'standard', 400 * MB, 4],
    ['unknown memory, small quota', { deviceMemory: null, quotaBytes: 100 * MB }, 'low', 80 * MB, 1],
    ['unknown quota', { quotaBytes: null }, 'standard', 400 * MB, 4],
  ];
  it.each(cases)('%s', (_n, over, profile, maxPack, lru) => {
    const b = resolveBudget(caps(over));
    expect(b.profile).toBe(profile);
    expect(b.maxPackBytes).toBe(maxPack);
    expect(b.lexicalPartsInRam).toBe(lru);
    expect(b.semanticVisible).toBe(profile !== 'low');
    expect(b.generativeVisible).toBe(profile !== 'low');
  });
});

describe('resolveTier', () => {
  const on = { semantic: true, generative: true };
  const off = { semantic: false, generative: false };
  it('U when unsupported', () => {
    const c = caps({ supported: false, missing: ['indexedDB'] });
    expect(resolveTier(c, resolveBudget(c), on).tier).toBe('U');
  });
  it('L0 by default even on strong device', () => {
    const c = caps({ promptApi: 'available' });
    const r = resolveTier(c, resolveBudget(c), off);
    expect(r.tier).toBe('L0');
    expect(r.l1Eligible).toBe(true);
    expect(r.l2Eligible).toBe(true);
  });
  it('L1 with opt-in', () => {
    const c = caps();
    expect(resolveTier(c, resolveBudget(c), { semantic: true, generative: false }).tier).toBe('L1');
  });
  it.each([
    ['no simd', { simd: false }],
    ['low profile', { deviceMemory: 2 }],
    ['< 400MB free', { freeBytes: 399 * MB, quotaBytes: 2 * GB }],
  ])('L1 blocked: %s', (_n, over) => {
    const c = caps(over);
    const r = resolveTier(c, resolveBudget(c), { semantic: true, generative: false });
    expect(r.l1Eligible).toBe(false);
    expect(r.tier).toBe('L0');
  });
  it('L2 via Prompt API with opt-in', () => {
    const c = caps({ promptApi: 'available' });
    expect(resolveTier(c, resolveBudget(c), { semantic: false, generative: true }).tier).toBe('L2');
  });
  it('L2 via gpu path', () => {
    const c = caps({ gpu: { available: true, maxBufferSize: GB } });
    expect(resolveTier(c, resolveBudget(c), { semantic: false, generative: true }).tier).toBe('L2');
  });
  it.each([
    ['prompt downloadable', { promptApi: 'downloadable' as const }],
    ['gpu small buffer', { gpu: { available: true, maxBufferSize: GB - 1 } }],
    ['gpu low memory', { deviceMemory: 2, gpu: { available: true, maxBufferSize: 2 * GB } }],
    ['gpu unknown memory', { deviceMemory: null, gpu: { available: true, maxBufferSize: 2 * GB } }],
  ])('L2 blocked: %s', (_n, over) => {
    const c = caps(over);
    const r = resolveTier(c, resolveBudget(c), { semantic: false, generative: true });
    expect(r.l2Eligible).toBe(false);
    expect(r.tier).toBe('L0');
  });
  it('no L2 on low profile even when Prompt API is available', () => {
    const c = caps({ promptApi: 'available', deviceMemory: 2 });
    const r = resolveTier(c, resolveBudget(c), { semantic: false, generative: true });
    expect(r.l2Eligible).toBe(false);
    expect(r.tier).toBe('L0');
  });
  it('L2 wins over L1 when both enabled', () => {
    const c = caps({ promptApi: 'available' });
    expect(resolveTier(c, resolveBudget(c), on).tier).toBe('L2');
  });
});
