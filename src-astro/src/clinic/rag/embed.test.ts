import { describe, expect, it } from 'vitest';
import { meanPoolNormalize, createEmbedder } from './embed';

describe('embed', () => {
  it('mean pools with the mask and L2-normalises', () => {
    // batch 1, 3 tokens, dim 2; third token masked out
    const out = meanPoolNormalize(new Float32Array([3, 0, 1, 4, 99, 99]), [1, 3, 2], [1, 1, 0]);
    expect(out[0].length).toBe(2);
    const m = [2, 2];
    const n = Math.hypot(m[0], m[1]);
    expect(out[0][0]).toBeCloseTo(m[0] / n, 6);
    expect(out[0][1]).toBeCloseTo(m[1] / n, 6);
  });

  it('adds query:/passage: prefixes', async () => {
    const seen: string[][] = [];
    const embedder = createEmbedder(async () => ({
      tokenizer: (texts: string[]) => { seen.push(texts); return { attention_mask: { data: texts.flatMap(() => [1, 1]) } }; },
      model: async (inp: { attention_mask: { data: ArrayLike<number | bigint> } }) => ({
        last_hidden_state: { data: new Float32Array(inp.attention_mask.data.length * 2).fill(1), dims: [inp.attention_mask.data.length / 2, 2, 2] },
      }),
    }));
    await embedder.embedQuery('dolor');
    await embedder.embedPassages(['x']);
    expect(seen).toEqual([['query: dolor'], ['passage: x']]);
  });

  it('does not cache a rejected load', async () => {
    let calls = 0;
    const embedder = createEmbedder(async () => {
      if (++calls === 1) throw new Error('boom');
      return {
        tokenizer: () => ({ attention_mask: { data: [1] } }),
        model: async () => ({ last_hidden_state: { data: new Float32Array([1, 0]), dims: [1, 1, 2] } }),
      };
    });
    await expect(embedder.embedQuery('x')).rejects.toThrow('boom');
    expect((await embedder.embedQuery('x'))[0]).toBeCloseTo(1, 6);
    expect(calls).toBe(2);
  });
});
