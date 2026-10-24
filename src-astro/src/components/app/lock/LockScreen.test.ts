import { afterEach, describe, expect, it, vi } from 'vitest';
import { flushSync, mount, unmount } from 'svelte';
import { setServices } from '../../../lib/contracts/services';
import { createMockServices } from '../../../lib/contracts/mock';
import LockScreen from './LockScreen.svelte';

let app: Record<string, any> | null = null;
afterEach(() => {
  if (app) unmount(app);
  app = null;
  document.body.innerHTML = '';
});

describe('LockScreen', () => {
  it('mounts the lock screen', () => {
    setServices(createMockServices(0));
    app = mount(LockScreen, { target: document.body });
    flushSync();
    expect(document.querySelector('[data-testid="area-lock"]')).not.toBeNull();
  });

  it('calls vault.unlock() on button click', async () => {
    const services = createMockServices(0);
    const unlockSpy = vi.spyOn(services.vault, 'unlock').mockResolvedValue(undefined);
    setServices(services);

    app = mount(LockScreen, { target: document.body });
    flushSync();

    const unlockBtn = document.querySelector('.unlock-button') as HTMLButtonElement;
    unlockBtn.click();

    // vitest requires awaiting the next tick for async handlers
    await new Promise((resolve) => setTimeout(resolve, 0));

    expect(unlockSpy).toHaveBeenCalled();
    // In our test, window.dispatchEvent for popstate doesn't magically update window.location,
    // but the navigation call is part of success.
  });

  it('shows error on unlock failure', async () => {
    const services = createMockServices(0);
    vi.spyOn(services.vault, 'unlock').mockRejectedValue(new Error('Failed unlock'));
    setServices(services);

    app = mount(LockScreen, { target: document.body });
    flushSync();

    const unlockBtn = document.querySelector('.unlock-button') as HTMLButtonElement;
    unlockBtn.click();

    await new Promise((resolve) => setTimeout(resolve, 0));
    flushSync(); // ensure Svelte updates DOM with error

    const errorMsg = document.querySelector('.error-message');
    expect(errorMsg).not.toBeNull();
    expect(errorMsg?.textContent).toContain('No se pudo verificar tu identidad. Intenta de nuevo.');
  });
});
