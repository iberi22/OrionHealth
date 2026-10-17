// llm.ts — capa agentica LLM SWAL
// Reusa ProviderRouter + Clavis + xavier-gpud de cores/swal-agent-runner/src/services/llm/
// El modelo de negocio no habla directo a OpenAI — pasa por este router con memoria RAG + on-device AI local.

import { xavierSearch } from './xavier';


export type LLMRequest = { prompt: string; system?: string; model?: string; useMemory?: boolean; tierId?: 'free'|'socio'|'socio-managed'; estimatedTokens?: number };
export type LLMResponse = { text: string; model: string; fromCache?: boolean; via?: 'local'|'cf' };

// API interna para feature detect
type BrowserPromptAPI = {
  create: () => Promise<{ prompt: (text: string) => Promise<string>; destroy: () => void }>;
  availability?: () => Promise<'unavailable' | 'downloadable' | 'downloading' | 'available'>;
  capabilities?: () => Promise<{ available: 'no' | 'after-download' | 'readily' }>;
};

function getLanguageModel(): BrowserPromptAPI | undefined {
  if (typeof globalThis !== 'undefined' && 'LanguageModel' in globalThis) {
    return (globalThis as any).LanguageModel;
  }
  if (typeof window !== 'undefined' && 'ai' in window && (window as any).ai?.languageModel) {
    return (window as any).ai.languageModel;
  }
  return undefined;
}

export async function llmComplete(req: LLMRequest): Promise<LLMResponse> {
  // RAG contextual
  let context = '';
  if (req.useMemory) {
    try {
      const mem = await xavierSearch(req.prompt, 3);
      context = (mem.memories ?? []).map((m: any) => m.content).join('\n---\n');
    } catch {
      // Ignorar fallo de RAG
    }
  }

  const system = req.system ? req.system + '\n' : '';
  const ctx = context ? `Context:\n${context}\n\n` : '';
  const fullPrompt = `${system}${ctx}${req.prompt}`;

  const lm = getLanguageModel();
  let available = false;
  if (lm) {
    try {
      if (typeof lm.availability === 'function') {
        const state = await lm.availability();
        available = state === 'available';
      } else if (typeof lm.capabilities === 'function') {
        const state = await lm.capabilities();
        available = state.available === 'readily';
      }
    } catch {
      available = false;
    }
  }

  if (available && lm) {
    try {
      const session = await lm.create();
      try {
        const text = await session.prompt(fullPrompt);
        return { text, model: 'browser-prompt-api', via: 'local' };
      } finally {
        if (typeof session.destroy === 'function') {
          session.destroy();
        }
      }
    } catch (e) {
      // Prompt privacy: NO logear el contenido del prompt
      console.warn('[llm] fallo en browser prompt API, usando fallback');
    }
  }

  return { text: 'Modelo local no disponible.', model: req.model ?? 'fallback', via: 'local' };
}
