export const WEBLLM_MODEL_ID = 'Qwen2.5-1.5B-Instruct-q4f16_1-MLC';
export const MIN_DEVICE_MEMORY_GB = 4;
export const MIN_MAX_BUFFER_SIZE = 1024 ** 3;

export interface WebLlmCaps {
  gpu: boolean;
  deviceMemory: number;
  maxBufferSize: number;
}

export function checkWebLlm(c: WebLlmCaps): boolean {
  return c.gpu && c.deviceMemory >= MIN_DEVICE_MEMORY_GB && c.maxBufferSize >= MIN_MAX_BUFFER_SIZE;
}

/** Reads browser capabilities; maxBufferSize comes from the WebGPU adapter limits. */
export async function detectWebLlmCaps(nav: any = (globalThis as any).navigator): Promise<WebLlmCaps> {
  const none = { gpu: false, deviceMemory: 0, maxBufferSize: 0 };
  if (!nav?.gpu) return none;
  try {
    const adapter = await nav.gpu.requestAdapter();
    return {
      gpu: !!adapter,
      deviceMemory: nav.deviceMemory ?? 0,
      maxBufferSize: adapter?.limits?.maxBufferSize ?? 0,
    };
  } catch {
    return none;
  }
}

/** Minimal local typing of the parts of @mlc-ai/web-llm that we use. */
export interface WebLlmEngine {
  chat: {
    completions: {
      create(req: {
        messages: { role: 'system' | 'user'; content: string }[];
        temperature?: number;
      }): Promise<{ choices: { message: { content: string | null } }[] }>;
    };
  };
}
export interface WebLlmModule {
  CreateMLCEngine(
    model: string,
    cfg?: { initProgressCallback?: (p: { progress: number; text: string }) => void },
  ): Promise<WebLlmEngine>;
}
export type WebLlmLoader = () => Promise<WebLlmModule>;

/** Loaded lazily, only once the user opts in. */
export const defaultWebLlmLoader: WebLlmLoader = () => import('@mlc-ai/web-llm') as unknown as Promise<WebLlmModule>;

export async function generateWithWebLlm(
  system: string,
  user: string,
  loader: WebLlmLoader = defaultWebLlmLoader,
  onProgress?: (p: { progress: number; text: string }) => void,
): Promise<string> {
  const mod = await loader();
  const engine = await mod.CreateMLCEngine(WEBLLM_MODEL_ID, { initProgressCallback: onProgress });
  const r = await engine.chat.completions.create({
    messages: [
      { role: 'system', content: system },
      { role: 'user', content: user },
    ],
    temperature: 0.1,
  });
  return r.choices[0]?.message.content ?? '';
}
