import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { llmComplete } from './llm';

describe('llm via browser prompt api', () => {
  beforeEach(() => {
    // Reset globalThis.LanguageModel before each test
    delete (globalThis as any).LanguageModel;
    delete (globalThis as any).window;
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it('usa browser prompt api si esta disponible y create() tiene exito', async () => {
    const mockSession = {
      prompt: vi.fn().mockResolvedValue('fake response local AI'),
      destroy: vi.fn()
    };
    (globalThis as any).LanguageModel = {
      create: vi.fn().mockResolvedValue(mockSession)
    };

    const res = await llmComplete({ prompt: 'hola' });

    expect(res.via).toBe('local');
    expect(res.model).toBe('browser-prompt-api');
    expect(res.text).toBe('fake response local AI');
    expect((globalThis as any).LanguageModel.create).toHaveBeenCalled();
    expect(mockSession.prompt).toHaveBeenCalledWith('hola');
    expect(mockSession.destroy).toHaveBeenCalled();
  });

  it('retorna fallback cuando LanguageModel no esta definido (no contiene texto de billing)', async () => {
    // No mock injected -> getLanguageModel returns undefined
    const res = await llmComplete({ prompt: 'hola' });

    expect(res.via).toBe('local');
    expect(res.model).toBe('stub'); // fallback uses requested model or 'stub'
    expect(res.text).toContain('LLM local stub');
    expect(res.text.toLowerCase()).not.toContain('billing');
    expect(res.text.toLowerCase()).not.toContain('credito');
  });

  it('retorna fallback cuando LanguageModel.create() rechaza (y no loggea info sensible)', async () => {
    const consoleWarnSpy = vi.spyOn(console, 'warn').mockImplementation(() => {});
    (globalThis as any).LanguageModel = {
      create: vi.fn().mockRejectedValue(new Error('Test Reject'))
    };

    const res = await llmComplete({ prompt: 'datos privados' });

    expect(res.via).toBe('local');
    expect(res.model).toBe('stub');
    expect(res.text).toContain('LLM local stub');

    // Make sure we didn't log the prompt string when failing
    const warnCalls = consoleWarnSpy.mock.calls.map(args => args.join(' '));
    expect(warnCalls.some(call => call.includes('datos privados'))).toBe(false);
  });
});
