import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { flushSync, mount, unmount } from 'svelte';
import { setServices } from '../../../lib/contracts/services';
import { createMockServices } from '../../../lib/contracts/mock';
import Settings from './Settings.svelte';
import * as routes from '../routes';

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
  localStorage.clear();
});

describe('Settings', () => {
  it('renders the settings area', () => {
    app = mount(Settings, { target: document.body });
    flushSync();

    expect(document.querySelector('[data-testid="area-settings"]')).not.toBeNull();
    expect(document.body.textContent).toContain('Ajustes');
    expect(document.body.textContent).toContain('Seguridad');
  });

  it('updates auto-lock minutes', () => {
    const setSpy = vi.spyOn(mockServices.vault, 'setAutoLockMinutes');

    app = mount(Settings, { target: document.body });
    flushSync();

    const select = document.querySelector('#autolock') as HTMLSelectElement;
    // update it then trigger Svelte change
    select.value = '15';
    select.dispatchEvent(new Event('change', { bubbles: true }));
    flushSync();

    expect(setSpy).toHaveBeenCalledWith(15);
  });

  it('locks vault and navigates to lock screen', () => {
    const lockSpy = vi.spyOn(mockServices.vault, 'lock');
    const navSpy = vi.spyOn(routes, 'navigate').mockImplementation(() => {});

    app = mount(Settings, { target: document.body });
    flushSync();

    const lockBtn = document.querySelector('.danger-btn') as HTMLButtonElement;
    lockBtn.click();
    flushSync();

    expect(lockSpy).toHaveBeenCalled();
    expect(navSpy).toHaveBeenCalledWith('/app/lock');
  });

  it('navigates to onboarding on "Cómo funciona" click', () => {
    const navSpy = vi.spyOn(routes, 'navigate').mockImplementation(() => {});

    app = mount(Settings, { target: document.body });
    flushSync();

    const onboardBtn = [...document.querySelectorAll('button')].find((b) => b.textContent?.includes('Cómo funciona')) as HTMLButtonElement;
    onboardBtn.click();
    flushSync();

    expect(navSpy).toHaveBeenCalledWith('/app/onboarding');
  });

  it('updates theme in localStorage', () => {
    app = mount(Settings, { target: document.body });
    flushSync();

    const themeSelect = document.querySelector('#theme') as HTMLSelectElement;
    themeSelect.value = 'dark';
    themeSelect.dispatchEvent(new Event('change', { bubbles: true }));
    flushSync();

    expect(localStorage.getItem('oh-theme')).toBe('dark');
    expect(document.documentElement.getAttribute('data-theme')).toBe('dark');
  });

  it('downloads the encrypted recovery file', async () => {
    const recoveryFile = vi.spyOn(mockServices.recovery, 'recoveryFile').mockResolvedValue({ filename: 'orion-recovery.json', content: '{"v":1}' });
    const createUrl = vi.fn().mockReturnValue('blob:x');
    const revokeUrl = vi.fn();
    Object.assign(URL, { createObjectURL: createUrl, revokeObjectURL: revokeUrl });
    const click = vi.spyOn(HTMLAnchorElement.prototype, 'click').mockImplementation(() => {});
    app = mount(Settings, { target: document.body });
    flushSync();
    const button = [...document.querySelectorAll('button')].find((b) => b.textContent?.includes('Descargar archivo de recuperación'))!;
    button.click();
    await vi.waitFor(() => expect(click).toHaveBeenCalled());
    expect(recoveryFile).toHaveBeenCalled();
    expect(createUrl).toHaveBeenCalled();
  });
});
