import { afterEach, describe, expect, it, vi } from 'vitest';
import { flushSync, mount, unmount } from 'svelte';
import { setServices } from '../../../lib/contracts/services';
import { createMockServices } from '../../../lib/contracts/mock';
import RestoreWizard from './RestoreWizard.svelte';
import * as routes from '../routes';

let app: Record<string, any> | null = null;
afterEach(() => {
  if (app) unmount(app);
  app = null;
  document.body.innerHTML = '';
});

describe('RestoreWizard', () => {
  it('navigates to /app instead of reloading on done', async () => {
    const services = createMockServices(0);
    let progressCallback: (p: any) => void = () => {};
    vi.spyOn(services.recovery, 'onProgress').mockImplementation((cb) => {
      progressCallback = cb;
      return () => {};
    });
    setServices(services);

    const navigateSpy = vi.spyOn(routes, 'navigate').mockImplementation(() => {});

    app = mount(RestoreWizard, { target: document.body });
    flushSync();

    progressCallback({ step: 'done', approvals: 0, threshold: 0 });
    flushSync();

    const btn = Array.from(document.querySelectorAll('button')).find(b => b.textContent?.includes('Ir al inicio'));
    expect(btn).toBeDefined();
    btn?.click();
    flushSync();

    expect(navigateSpy).toHaveBeenCalledWith('/app');
  });

  it('allows entering code when awaiting approvals', async () => {
    const services = createMockServices(0);
    let progressCallback: (p: any) => void = () => {};
    vi.spyOn(services.recovery, 'onProgress').mockImplementation((cb) => {
      progressCallback = cb;
      return () => {};
    });
    const recoverWithCodeSpy = vi.spyOn(services.recovery, 'recoverWithCode').mockResolvedValue();
    setServices(services);

    app = mount(RestoreWizard, { target: document.body });
    flushSync();

    progressCallback({ step: 'awaiting-approvals', approvals: 0, threshold: 2 });
    flushSync();

    const textarea = document.querySelector('textarea');
    expect(textarea).toBeDefined();
    if (textarea) {
      textarea.value = '1234-5678';
      textarea.dispatchEvent(new Event('input'));
    }
    flushSync();

    const btn = Array.from(document.querySelectorAll('button')).find(b => b.textContent?.includes('Tengo mi código'));
    expect(btn).toBeDefined();
    expect((btn as HTMLButtonElement).disabled).toBe(false);
    btn?.click();
    flushSync();

    expect(recoverWithCodeSpy).toHaveBeenCalledWith('12345678', undefined);
  });
});
