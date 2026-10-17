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
      availability: vi.fn().mockResolvedValue('available'),
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

  it('retorna fallback honesto cuando LanguageModel no esta definido', async () => {
    const res = await llmComplete({ prompt: 'hola', system: 'SYS' });
    expect(res.via).toBe('local');
    expect(res.model).toBe('fallback');
    expect(res.text).toBe('Modelo local no disponible.');
    expect(res.text.toLowerCase()).not.toContain('llm local stub');
    expect(res.text).not.toContain('SYS');
    expect(res.text).not.toContain('hola');
  });

  it('nunca llama create() si availability() es downloadable', async () => {
    const createSpy = vi.fn();
    (globalThis as any).LanguageModel = {
      availability: vi.fn().mockResolvedValue('downloadable'),
      create: createSpy
    };
    const res = await llmComplete({ prompt: 'hola' });
    expect(createSpy).not.toHaveBeenCalled();
    expect(res.text).toBe('Modelo local no disponible.');
  });

  it('destruye la sesion aunque prompt() rechace', async () => {
    const mockSession = {
      prompt: vi.fn().mockRejectedValue(new Error('Prompt fail')),
      destroy: vi.fn()
    };
    (globalThis as any).LanguageModel = {
      availability: vi.fn().mockResolvedValue('available'),
      create: vi.fn().mockResolvedValue(mockSession)
    };

    vi.spyOn(console, 'warn').mockImplementation(() => {});

    const res = await llmComplete({ prompt: 'hola' });

    expect(mockSession.prompt).toHaveBeenCalled();
    expect(mockSession.destroy).toHaveBeenCalled();
    expect(res.text).toBe('Modelo local no disponible.');
  });

  it('retorna fallback cuando LanguageModel.create() rechaza (y no loggea info sensible)', async () => {
    const consoleWarnSpy = vi.spyOn(console, 'warn').mockImplementation(() => {});
    const consoleLogSpy = vi.spyOn(console, 'log').mockImplementation(() => {});
    const consoleInfoSpy = vi.spyOn(console, 'info').mockImplementation(() => {});
    const consoleErrorSpy = vi.spyOn(console, 'error').mockImplementation(() => {});
    const consoleDebugSpy = vi.spyOn(console, 'debug').mockImplementation(() => {});
    (globalThis as any).LanguageModel = {
      availability: vi.fn().mockResolvedValue('available'),
      create: vi.fn().mockRejectedValue(new Error('Test Reject'))
    };

    const res = await llmComplete({ prompt: 'datos privados' });

    expect(res.via).toBe('local');
    expect(res.model).toBe('fallback');
    expect(res.text).toBe('Modelo local no disponible.');

    // Make sure we didn't log the prompt string when failing in any console method
    const allCalls = [
      ...consoleWarnSpy.mock.calls,
      ...consoleLogSpy.mock.calls,
      ...consoleInfoSpy.mock.calls,
      ...consoleErrorSpy.mock.calls,
      ...consoleDebugSpy.mock.calls
    ].map(args => args.join(' '));

    expect(allCalls.some(call => call.includes('datos privados'))).toBe(false);
  });
});
