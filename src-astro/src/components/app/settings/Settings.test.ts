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

    const onboardBtn = document.querySelector('.secondary-btn') as HTMLButtonElement;
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
});
