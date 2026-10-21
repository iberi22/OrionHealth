/** Runtime capability probing. Feature probes only (try + catch), never UA sniffing. */

export type PromptApiState = 'available' | 'downloadable' | 'downloading' | 'unavailable';

export interface Caps {
  /** false => tier U */
  supported: boolean;
  /** names of missing hard requirements */
  missing: string[];
  simd: boolean;
  /** GB, null when the browser does not expose it */
  deviceMemory: number | null;
  saveData: boolean;
  quotaBytes: number | null;
  usageBytes: number | null;
  /** quota - usage, null when unknown */
  freeBytes: number | null;
  persisted: boolean;
  opfs: boolean;
  promptApi: PromptApiState;
  gpu: { available: boolean; maxBufferSize: number };
}

/** All globals are injectable for tests. Everything is optional. */
export interface CapsEnv {
  Worker?: new (url: string, opts?: { type?: string }) => { terminate(): void };
  indexedDB?: unknown;
  DecompressionStream?: new (format: string) => unknown;
  crypto?: { subtle?: { digest?: (alg: string, data: Uint8Array) => Promise<ArrayBuffer> } };
  WebAssembly?: { validate(bytes: Uint8Array): boolean };
  LanguageModel?: { availability?: () => Promise<string> };
  navigator?: {
    deviceMemory?: number;
    connection?: { saveData?: boolean };
    gpu?: { requestAdapter?: () => Promise<{ limits?: { maxBufferSize?: number } } | null> };
    storage?: {
      estimate?: () => Promise<{ quota?: number; usage?: number }>;
      persist?: () => Promise<boolean>;
      persisted?: () => Promise<boolean>;
      getDirectory?: () => Promise<unknown>;
    };
  };
}

/** Minimal module with a v128 const + i8x16.popcnt-style SIMD op. */
const SIMD_PROBE = new Uint8Array([
  0, 97, 115, 109, 1, 0, 0, 0, 1, 5, 1, 96, 0, 1, 123, 3, 2, 1, 0, 10, 10, 1, 8, 0, 65, 0, 253, 15,
  253, 98, 11,
]);

async function attempt<T>(fn: () => T | Promise<T>, fallback: T): Promise<T> {
  try {
    return await fn();
  } catch {
    return fallback;
  }
}

function probeModuleWorker(env: CapsEnv): boolean {
  if (typeof env.Worker !== 'function') return false;
  // The `type` getter is what proves module-worker support. Under a CSP that
  // blocks data: (e.g. /clinic/* worker-src 'self' blob:) the constructor throws
  // AFTER reading `type`, so the flag must be returned regardless of the throw.
  let read = false;
  const opts = {
    get type() {
      read = true;
      return 'module';
    },
  };
  try {
    const w = new env.Worker('data:text/javascript,', opts as { type?: string });
    try {
      w.terminate();
    } catch {
      /* ignore */
    }
  } catch {
    /* blocked or unsupported: judged by `read` below */
  }
  return read;
}

export async function detectCaps(env: CapsEnv = globalThis as unknown as CapsEnv): Promise<Caps> {
  const nav = env.navigator ?? {};
  const missing: string[] = [];

  if (!probeModuleWorker(env)) missing.push('moduleWorker');
  if (!env.indexedDB) missing.push('indexedDB');
  const ds = await attempt(() => {
    if (typeof env.DecompressionStream !== 'function') return false;
    new env.DecompressionStream('gzip');
    return true;
  }, false);
  if (!ds) missing.push('decompressionStream');
  const digest = await attempt(async () => {
    const f = env.crypto?.subtle?.digest;
    if (typeof f !== 'function') return false;
    await f.call(env.crypto!.subtle, 'SHA-256', new Uint8Array(1));
    return true;
  }, false);
  if (!digest) missing.push('cryptoDigest');

  const simd = await attempt(() => env.WebAssembly?.validate(SIMD_PROBE) === true, false);

  const est = await attempt(async () => (await nav.storage?.estimate?.()) ?? null, null);
  const quotaBytes = typeof est?.quota === 'number' ? est.quota : null;
  const usageBytes = typeof est?.usage === 'number' ? est.usage : null;
  const freeBytes =
    quotaBytes !== null ? Math.max(0, quotaBytes - (usageBytes ?? 0)) : null;
  const persisted = await attempt(
    // Never fall back to persist(): it may show a permission prompt. Detection is read-only.
    async () => (await nav.storage?.persisted?.()) === true,
    false,
  );
  const opfs = await attempt(async () => {
    if (typeof nav.storage?.getDirectory !== 'function') return false;
    await nav.storage.getDirectory();
    return true;
  }, false);

  const promptApi = await attempt<PromptApiState>(async () => {
    const s = await env.LanguageModel?.availability?.();
    return s === 'available' || s === 'downloadable' || s === 'downloading' ? s : 'unavailable';
  }, 'unavailable');

  const gpu = await attempt(async () => {
    if (!nav.gpu?.requestAdapter) return { available: false, maxBufferSize: 0 };
    const a = await nav.gpu.requestAdapter();
    if (!a) return { available: false, maxBufferSize: 0 };
    return { available: true, maxBufferSize: a.limits?.maxBufferSize ?? 0 };
  }, { available: false, maxBufferSize: 0 });

  return {
    supported: missing.length === 0,
    missing,
    simd,
    deviceMemory: typeof nav.deviceMemory === 'number' ? nav.deviceMemory : null,
    saveData: nav.connection?.saveData === true,
    quotaBytes,
    usageBytes,
    freeBytes,
    persisted,
    opfs,
    promptApi,
    gpu,
  };
}
