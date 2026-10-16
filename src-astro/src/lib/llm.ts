// llm.ts — capa agentica LLM SWAL
// Reusa ProviderRouter + Clavis + xavier-gpud de cores/swal-agent-runner/src/services/llm/
// El modelo de negocio no habla directo a OpenAI — pasa por este router con memoria RAG + billing socio.

import { xavierSearch } from './xavier';


export type LLMRequest = { prompt: string; system?: string; model?: string; useMemory?: boolean; tierId?: 'free'|'socio'|'socio-managed'; estimatedTokens?: number };
export type LLMResponse = { text: string; model: string; fromCache?: boolean; via?: 'local'|'cf' };

// API interna para feature detect
type BrowserPromptAPI = {
  create: () => Promise<{ prompt: (text: string) => Promise<string>; destroy: () => void }>;
  availability: () => Promise<'readily' | 'after-download' | 'no'>;
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
  if (lm) {
    try {
      const session = await lm.create();
      const text = await session.prompt(fullPrompt);
      if (typeof session.destroy === 'function') {
        session.destroy();
      }
      return { text, model: 'browser-prompt-api', via: 'local' };
    } catch (e) {
      // Prompt privacy: NO logear el contenido del prompt
      console.warn('[llm] fallo en browser prompt API, usando fallback');
    }
  }

  console.log('[llm] complete fallback', { model: req.model ?? 'auto', via: 'local' });
  return { text: `${system}${ctx}LLM local stub (sin CF): implementa ProviderRouter en src/lib/llm.ts (ver swal-agent-runner llm-provider-manager.ts)`, model: req.model ?? 'stub', via: 'local' };
}
