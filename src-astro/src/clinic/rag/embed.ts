export interface TensorLike { data: ArrayLike<number | bigint>; dims?: number[] }
export interface EmbedBackend {
  tokenizer: (texts: string[], opts?: Record<string, unknown>) => { attention_mask: TensorLike } | Promise<{ attention_mask: TensorLike }>;
  model: (inputs: { attention_mask: TensorLike }) => Promise<{ last_hidden_state: { data: ArrayLike<number>; dims: number[] } }>;
}
export type EmbedLoader = () => Promise<EmbedBackend>;

/** Reads a file saved by the installer in OPFS (null when absent). */
export type ModelFileReader = (name: string) => Promise<Uint8Array | null>;

/** Real loader: transformers.js reading the model the installer saved in OPFS (never the network). */
export function transformersLoader(readFile: ModelFileReader): EmbedLoader {
  return async () => {
    const t = (await import('@huggingface/transformers')) as unknown as {
      env: Record<string, unknown>;
      AutoTokenizer: { from_pretrained(id: string): Promise<EmbedBackend['tokenizer']> };
      AutoModel: { from_pretrained(id: string, o: Record<string, unknown>): Promise<EmbedBackend['model']> };
    };
    t.env.allowRemoteModels = false;
    t.env.allowLocalModels = false;
    t.env.useBrowserCache = false;
    t.env.useCustomCache = true;
    t.env.customCache = {
      async match(key: string) {
        const bytes = await readFile(key.split('/').pop() ?? key);
        return bytes ? new Response(bytes as BodyInit) : undefined;
      },
      async put() { /* read-only */ },
    };
    const tokenizer = await t.AutoTokenizer.from_pretrained('me5s-q8');
    const model = await t.AutoModel.from_pretrained('me5s-q8', { dtype: 'q8' });
    return { tokenizer, model };
  };
}

/** Mean pool over the attention mask (flat [batch*seq]) then L2-normalise. */
export function meanPoolNormalize(data: ArrayLike<number>, dims: number[], mask: ArrayLike<number | bigint>): Float32Array[] {
  const [b, s, d] = dims;
  const out: Float32Array[] = [];
  for (let i = 0; i < b; i++) {
    const v = new Float32Array(d);
    let cnt = 0;
    for (let t = 0; t < s; t++) {
      if (Number(mask[i * s + t]) === 0) continue;
      cnt++;
      for (let j = 0; j < d; j++) v[j] += data[(i * s + t) * d + j];
    }
    let norm = 0;
    for (let j = 0; j < d; j++) { v[j] /= cnt || 1; norm += v[j] * v[j]; }
    norm = Math.sqrt(norm) || 1;
    for (let j = 0; j < d; j++) v[j] /= norm;
    out.push(v);
  }
  return out;
}

export function createEmbedder(loader: EmbedLoader) {
  let backend: Promise<EmbedBackend> | null = null;
  async function run(texts: string[]): Promise<Float32Array[]> {
    backend ??= loader();
    let be: EmbedBackend;
    try { be = await backend; } catch (e) { backend = null; throw e; }
    const inputs = await be.tokenizer(texts, { padding: true, truncation: true, max_length: 512 });
    const { last_hidden_state } = await be.model(inputs);
    return meanPoolNormalize(last_hidden_state.data, last_hidden_state.dims, inputs.attention_mask.data);
  }
  return {
    async embedQuery(q: string) { return (await run([`query: ${q}`]))[0]; },
    embedPassages(p: string[]) { return run(p.map((x) => `passage: ${x}`)); },
  };
}
