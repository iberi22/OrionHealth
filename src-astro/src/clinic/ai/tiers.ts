import { applyGrounding, withTimeout, GENERATION_TIMEOUT_MS } from './grounding';
import { systemPrompt, userPrompt } from './prompts';
import { checkPromptApi, generateWithPromptApi, type PromptApiState } from './prompt-api';
import { checkWebLlm, detectWebLlmCaps, generateWithWebLlm } from './webllm';
import { isAiEnabled, type KillSwitchStorage } from './kill-switch';
import type { Answer, Passage, UiLang } from './types';

export interface PromptApiTier {
  availability(): Promise<PromptApiState | string>;
  generate(system: string, user: string): Promise<string>;
}
export interface WebLlmTier {
  capable: boolean;
  generate(system: string, user: string): Promise<string>;
}

export interface AnswerRequest {
  question: string;
  passages: Passage[];
  uiLang: UiLang;
  /** Explicit user opt-in, required for every generative tier. */
  aiOptIn?: boolean;
  /** User opted in to the WebLLM download. */
  webllmOptIn?: boolean;
  /** Storage backing the global AI kill switch (defaults to localStorage). */
  killSwitchStorage?: KillSwitchStorage | null;
  promptApi?: PromptApiTier;
  webllm?: WebLlmTier;
  timeoutMs?: number;
}

/** Real browser-backed tiers, for production wiring. */
export async function browserTiers(
  uiLang: UiLang,
  killSwitchStorage?: KillSwitchStorage | null,
): Promise<Pick<AnswerRequest, 'promptApi' | 'webllm'>> {
  // AI off: never probe the GPU (requestAdapter) at all.
  const caps = isAiEnabled(killSwitchStorage)
    ? await detectWebLlmCaps()
    : { gpu: false, deviceMemory: 0, maxBufferSize: 0 };
  return {
    promptApi: {
      availability: () => checkPromptApi(uiLang),
      generate: (s, u) => generateWithPromptApi(s, u, uiLang),
    },
    webllm: { capable: checkWebLlm(caps), generate: (s, u) => generateWithWebLlm(s, u) },
  };
}

/** Prompt API -> WebLLM -> retrieval-only. */
export async function answerQuestion(req: AnswerRequest): Promise<Answer> {
  if (!isAiEnabled(req.killSwitchStorage) || req.aiOptIn !== true) {
    return { kind: 'retrieval-only', reason: 'user-off' };
  }
  const system = systemPrompt(req.uiLang);
  const user = userPrompt(req.question, req.passages);
  let tier: 'prompt-api' | 'webllm' | null = null;
  let run: (() => Promise<string>) | null = null;

  try {
    if (req.promptApi && (await req.promptApi.availability()) === 'available') {
      tier = 'prompt-api';
      run = () => req.promptApi!.generate(system, user);
    }
  } catch {
    /* try next tier */
  }
  if (!run && req.webllm?.capable) {
    if (!req.webllmOptIn) return { kind: 'retrieval-only', reason: 'user-off' };
    tier = 'webllm';
    run = () => req.webllm!.generate(system, user);
  }
  if (!run || !tier) return { kind: 'retrieval-only', reason: 'no-model' };

  let raw: string;
  try {
    raw = await withTimeout(run(), req.timeoutMs ?? GENERATION_TIMEOUT_MS);
  } catch (e) {
    return { kind: 'retrieval-only', reason: (e as Error).message === 'timeout' ? 'timeout' : 'model-error' };
  }
  const a = applyGrounding(raw, req.passages);
  return a.kind === 'generated' ? { ...a, tier } : a;
}
