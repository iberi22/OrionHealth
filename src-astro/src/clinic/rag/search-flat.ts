export interface VecShard { dim: number; n: number; vecs: Int8Array; scales: Float32Array }
export interface FlatShard { vec: VecShard; bits: Uint32Array }
export interface FlatHit { idx: number; score: number }

const WORD = 32;

export function parseVec(buf: Uint8Array): VecShard {
  const dv = new DataView(buf.buffer, buf.byteOffset, buf.byteLength);
  const hl = dv.getUint32(0, true);
  const head = JSON.parse(new TextDecoder().decode(buf.subarray(4, 4 + hl))) as { dim: number; n: number; dtype: string };
  if (head.dtype !== 'int8') throw new Error(`unsupported dtype ${head.dtype}`);
  const { dim, n } = head;
  const start = 4 + hl;
  const need = start + n * dim + n * 4;
  if (buf.byteLength < need) throw new Error('truncated .vec shard');
  const vecs = new Int8Array(n * dim);
  vecs.set(new Int8Array(buf.buffer, buf.byteOffset + start, n * dim));
  const scales = new Float32Array(n);
  for (let i = 0; i < n; i++) scales[i] = dv.getFloat32(start + n * dim + i * 4, true);
  return { dim, n, vecs, scales };
}

export function parseBits(buf: Uint8Array, n: number): Uint32Array {
  const words = (n * 12);
  if (buf.byteLength < words * 4) throw new Error('truncated .bits shard');
  const dv = new DataView(buf.buffer, buf.byteOffset, buf.byteLength);
  const out = new Uint32Array(words);
  for (let i = 0; i < words; i++) out[i] = dv.getUint32(i * 4, true);
  return out;
}

export function querySignBits(q: ArrayLike<number>): Uint32Array {
  const out = new Uint32Array(Math.ceil(q.length / WORD));
  for (let j = 0; j < q.length; j++) if (q[j] > 0) out[j >>> 5] |= 1 << (j & 31);
  return out;
}

function popcount(x: number): number {
  x -= (x >>> 1) & 0x55555555;
  x = (x & 0x33333333) + ((x >>> 2) & 0x33333333);
  x = (x + (x >>> 4)) & 0x0f0f0f0f;
  return Math.imul(x, 0x01010101) >>> 24;
}

/** Hamming top-`hammingK`, then int8 dot-product rescore, top-`rescoreK`. */
export function searchFlat(shard: FlatShard, q: Float32Array, opts: { hammingK?: number; rescoreK?: number } = {}): FlatHit[] {
  const { hammingK = 1000, rescoreK = 200 } = opts;
  const { dim, n, vecs, scales } = shard.vec;
  const words = Math.ceil(dim / WORD);
  const qb = querySignBits(q);
  const dist = new Uint16Array(n);
  for (let i = 0; i < n; i++) {
    let d = 0;
    for (let w = 0; w < words; w++) d += popcount((shard.bits[i * words + w] ^ qb[w]) >>> 0);
    dist[i] = d;
  }
  const order = Array.from({ length: n }, (_, i) => i).sort((a, b) => dist[a] - dist[b] || a - b).slice(0, hammingK);
  const hits: FlatHit[] = order.map((idx) => {
    let s = 0;
    const o = idx * dim;
    for (let j = 0; j < dim; j++) s += q[j] * vecs[o + j];
    return { idx, score: s * scales[idx] };
  });
  hits.sort((a, b) => b.score - a.score || a.idx - b.idx);
  return hits.slice(0, rescoreK);
}

// ---- builders (tests and tooling; mirror the CI shard writer) ----
export function buildVec(rows: Float32Array[]): Uint8Array {
  const n = rows.length;
  const dim = rows[0].length;
  const head = new TextEncoder().encode(JSON.stringify({ dim, n, dtype: 'int8' }));
  const out = new Uint8Array(4 + head.length + n * dim + n * 4);
  const dv = new DataView(out.buffer);
  dv.setUint32(0, head.length, true);
  out.set(head, 4);
  const start = 4 + head.length;
  rows.forEach((r, i) => {
    let max = 0;
    for (const x of r) max = Math.max(max, Math.abs(x));
    const scale = max / 127 || 1;
    for (let j = 0; j < dim; j++) dv.setInt8(start + i * dim + j, Math.round(r[j] / scale));
    dv.setFloat32(start + n * dim + i * 4, scale, true);
  });
  return out;
}

export function buildBits(rows: Float32Array[]): Uint8Array {
  const words = Math.ceil(rows[0].length / WORD);
  const out = new Uint8Array(rows.length * words * 4);
  const dv = new DataView(out.buffer);
  rows.forEach((r, i) => querySignBits(r).forEach((w, k) => dv.setUint32((i * words + k) * 4, w, true)));
  return out;
}
