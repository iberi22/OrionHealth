import { describe, expect, it } from 'vitest';
import { buildVec, buildBits, parseVec, parseBits, searchFlat, querySignBits } from './search-flat';

const DIM = 384;
function unit(seed: number): Float32Array {
  const v = new Float32Array(DIM);
  let s = seed;
  for (let i = 0; i < DIM; i++) {
    s = (s * 1664525 + 1013904223) >>> 0;
    v[i] = (s / 2 ** 32) * 2 - 1;
  }
  return v;
}

describe('search-flat', () => {
  const vecs = Array.from({ length: 50 }, (_, i) => unit(i + 1));
  const vecBuf = buildVec(vecs);
  const bitsBuf = buildBits(vecs);
  const shard = { vec: parseVec(vecBuf), bits: parseBits(bitsBuf, vecs.length) };

  it('parses header and sizes', () => {
    expect(shard.vec.n).toBe(50);
    expect(shard.vec.dim).toBe(DIM);
    expect(shard.bits.length).toBe(50 * 12);
    expect(querySignBits(vecs[0]).length).toBe(12);
  });

  it('ranks the exact vector first via Hamming + int8 rescore', () => {
    const hits = searchFlat(shard, vecs[17], { hammingK: 10, rescoreK: 5 });
    expect(hits).toHaveLength(5);
    expect(hits[0].idx).toBe(17);
    expect(hits[0].score).toBeGreaterThan(hits[1].score);
  });

  it('caps results at n and rejects bad dtype', () => {
    expect(searchFlat(shard, vecs[3], { hammingK: 1000, rescoreK: 200 })).toHaveLength(50);
    const bad = new TextEncoder().encode(JSON.stringify({ dim: 384, n: 0, dtype: 'f32' }));
    const b = new Uint8Array(4 + bad.length);
    new DataView(b.buffer).setUint32(0, bad.length, true);
    b.set(bad, 4);
    expect(() => parseVec(b)).toThrow(/dtype/);
  });
});
