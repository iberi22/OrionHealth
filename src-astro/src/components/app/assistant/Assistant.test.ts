import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { flushSync, mount, unmount } from 'svelte';
import { setServices } from '../../../lib/contracts/services';
import { createMockServices } from '../../../lib/contracts/mock';
import Assistant from './Assistant.svelte';

let app: Record<string, any> | null = null;
let mockServices: ReturnType<typeof createMockServices>;

beforeEach(() => {
  mockServices = createMockServices(0);
  setServices(mockServices);
});

afterEach(() => {
  if (app) unmount(app);
  app = null;
  document.body.innerHTML = '';
  vi.restoreAllMocks();
});

describe('Assistant', () => {
  it('renders the assistant area', () => {
    app = mount(Assistant, { target: document.body });
    flushSync();

    expect(document.querySelector('[data-testid="area-assistant"]')).not.toBeNull();
    expect(document.body.textContent).toContain('Asistente');
  });

  it('disables personal data toggle when locked', () => {
    vi.spyOn(mockServices.vault, 'state').mockReturnValue('locked');

    app = mount(Assistant, { target: document.body });
    flushSync();

    const checkbox = document.querySelector('input[type="checkbox"]') as HTMLInputElement;
    expect(checkbox.disabled).toBe(true);
    expect(document.body.textContent).toContain('Desbloquea para usar tus datos');
  });

  it('enables personal data toggle when unlocked', () => {
    vi.spyOn(mockServices.vault, 'state').mockReturnValue('unlocked');

    app = mount(Assistant, { target: document.body });
    flushSync();

    const checkbox = document.querySelector('input[type="checkbox"]') as HTMLInputElement;
    expect(checkbox.disabled).toBe(false);
  });

  it('submits a question and renders the answer card', async () => {
    const askSpy = vi.spyOn(mockServices.rag, 'ask').mockResolvedValue({
      question: 'Test Q',
      answer: 'Test A',
      mode: 'extractive',
      citations: [{ source: 'kb', id: '123', title: 'Test Citation', snippet: 'Test snippet' }],
      usedPersonalData: false
    });

    app = mount(Assistant, { target: document.body });
    flushSync();

    const input = document.querySelector('input[type="text"]') as HTMLInputElement;
    const button = document.querySelector('button[type="submit"]') as HTMLButtonElement;

    input.value = 'Test Q';
    input.dispatchEvent(new Event('input'));
    flushSync();

    button.click();

    // flush the event handlers
    flushSync();

    // wait for promise to resolve, which triggers state change
    await Promise.resolve();
    // wait for Svelte 5 tick
    await new Promise(r => setTimeout(r, 0));
    flushSync();

    expect(askSpy).toHaveBeenCalledWith('Test Q', { includePersonal: false });

    const answerCard = document.querySelector('.answer-card');
    expect(answerCard).not.toBeNull();
    expect(answerCard?.textContent).toContain('Test Q');
    expect(answerCard?.textContent).toContain('Test A');
    expect(answerCard?.textContent).toContain('Extractivo');
    expect(answerCard?.textContent).toContain('Test Citation');

    const citationLink = document.querySelector('.citations a') as HTMLAnchorElement;
    expect(citationLink.getAttribute('href')).toBe('/kb#123');
  });
});
