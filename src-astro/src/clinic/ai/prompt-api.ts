import type { UiLang } from './types';

export type PromptApiState = 'available' | 'downloadable' | 'downloading' | 'unavailable';

export interface LanguageModelLike {
  availability(opts: unknown): Promise<string>;
}

export async function checkPromptApi(
  uiLang: UiLang,
  lm: LanguageModelLike | undefined = (globalThis as { LanguageModel?: LanguageModelLike }).LanguageModel,
): Promise<PromptApiState> {
  if (!lm) return 'unavailable';
  try {
    const r = await lm.availability({
      expectedInputs: [{ type: 'text', languages: ['en', 'es'] }],
      expectedOutputs: [{ type: 'text', languages: [uiLang] }],
    });
    if (r === 'available' || r === 'downloadable' || r === 'downloading') return r;
  } catch {
    /* fall through */
  }
  return 'unavailable';
}

/** Runs one prompt with the browser model. Only call when state is 'available' (or after a user-gesture download). */
export async function generateWithPromptApi(system: string, user: string, uiLang: UiLang): Promise<string> {
  const LM = (globalThis as unknown as {
    LanguageModel: {
      create(o: unknown): Promise<{ prompt(p: string): Promise<string>; destroy?: () => void }>;
    };
  }).LanguageModel;
  const session = await LM.create({
    initialPrompts: [{ role: 'system', content: system }],
    expectedInputs: [{ type: 'text', languages: ['en', 'es'] }],
    expectedOutputs: [{ type: 'text', languages: [uiLang] }],
  });
  try {
    return await session.prompt(user);
  } finally {
    session.destroy?.();
  }
}
