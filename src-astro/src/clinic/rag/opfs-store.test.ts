import { describe, expect, it } from 'vitest';
import { CorpusStore, MemoryFileStore } from './opfs-store';
import { sha256Hex } from './hash';

const enc = (s: string) => new TextEncoder().encode(s);

describe('CorpusStore', () => {
  it('switches active.json only after every file verifies', async () => {
    const store = new CorpusStore(new MemoryFileStore());
    await store.writeFile('v1', 'a.bin', enc('aaa'));
    await store.activate('v1', { 'a.bin': await sha256Hex(enc('aaa')) });
    expect(await store.activeVersion()).toBe('v1');

    await store.writeFile('v2', 'a.bin', enc('bbb'));
    await expect(store.activate('v2', { 'a.bin': await sha256Hex(enc('aaa')) })).rejects.toThrow(/sha256/);
    await expect(store.activate('v2', { 'a.bin': 'x', 'missing.bin': 'y' })).rejects.toThrow();
    expect(await store.activeVersion()).toBe('v1');

    await store.activate('v2', { 'a.bin': await sha256Hex(enc('bbb')) });
    expect(await store.activeVersion()).toBe('v2');
    await store.removeVersion('v1');
    expect(await store.readFile('v1', 'a.bin')).toBeNull();
  });
});
