import { describe, expect, it, vi } from 'vitest';
import worker, { Env } from './index';

describe('Signaling Worker HTTP endpoints', () => {
  const mockEnv = (overrides: Partial<Env> = {}): Env => ({
    SIGNALING_ROOM: {
      idFromName: vi.fn(),
      get: vi.fn().mockReturnValue({ fetch: vi.fn() }),
    } as any,
    ...overrides,
  });

  it('403 without allowlist in production', async () => {
    const env = mockEnv({ ENVIRONMENT: 'production' });
    const req = new Request('https://test.local', { headers: { Origin: 'https://test.local' } });
    const res = await worker.fetch(req, env);
    expect(res.status).toBe(403);
  });

  it('403 with a foreign Origin', async () => {
    const env = mockEnv({ ORIGIN_ALLOWLIST: 'https://orionhealth.swal.network' });
    const req = new Request('https://test.local', { headers: { Origin: 'https://evil.local' } });
    const res = await worker.fetch(req, env);
    expect(res.status).toBe(403);
  });

  it('426 for a non-WebSocket request', async () => {
    const env = mockEnv({ ORIGIN_ALLOWLIST: 'https://orionhealth.swal.network' });
    const req = new Request('https://test.local', { headers: { Origin: 'https://orionhealth.swal.network' } });
    const res = await worker.fetch(req, env);
    expect(res.status).toBe(426);
  });
});
