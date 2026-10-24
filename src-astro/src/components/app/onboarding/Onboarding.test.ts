import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { flushSync, mount, unmount } from 'svelte';
import { setServices } from '../../../lib/contracts/services';
import { createMockServices } from '../../../lib/contracts/mock';
import Onboarding from './Onboarding.svelte';
import * as routes from '../routes';

let app: Record<string, any> | null = null;
let services: ReturnType<typeof createMockServices>;

describe('Onboarding', () => {
  beforeEach(() => {
    services = createMockServices(0);
    setServices(services);
    vi.spyOn(routes, 'navigate').mockImplementation(() => {});
  });

  afterEach(() => {
    if (app) unmount(app);
    app = null;
    document.body.innerHTML = '';
    vi.restoreAllMocks();
  });

  it('shows read-only mode if prf is false', async () => {
    services.vault.capabilities = async () => ({ webauthn: true, prf: false, indexedDb: true });
    app = mount(Onboarding, { target: document.body });
    flushSync();

    for (let i = 0; i < 3; i++) {
      const btn = document.querySelector('button') as HTMLButtonElement;
      btn.click();
      await flushSync();
      await new Promise(r => setTimeout(r, 0));
    }

    expect(document.body.textContent).toContain('Modo de solo lectura');
    expect(document.body.textContent).toContain('Explorar la base médica');
  });

  it('proceeds through vault creation, recovery confirmation, profile, and family', async () => {
    app = mount(Onboarding, { target: document.body });
    flushSync();

    for (let i = 0; i < 3; i++) {
      const btn = document.querySelector('button') as HTMLButtonElement;
      btn.click();
      await flushSync();
      await new Promise(r => setTimeout(r, 0));
    }

    expect(document.body.textContent).toContain('Crear tu bóveda segura');

    const nameInput = document.querySelector('input#vault-name') as HTMLInputElement;
    nameInput.value = 'Test User';
    nameInput.dispatchEvent(new Event('input', { bubbles: true }));
    await flushSync();

    const createBtn = document.querySelector('button') as HTMLButtonElement;
    expect(createBtn.disabled).toBe(false);
    createBtn.click();

    await new Promise(r => setTimeout(r, 10)); // wait for async vault.create
    await flushSync();

    expect(document.body.textContent).toContain('Tu código de recuperación');

    // Recovery code confirmation
    const inputs = document.querySelectorAll('.inputs input');
    expect(inputs.length).toBe(3);
    inputs.forEach(input => {
      (input as HTMLInputElement).value = 'demo';
      input.dispatchEvent(new Event('input', { bubbles: true }));
    });
    await flushSync();

    const confirmBtn = Array.from(document.querySelectorAll('button')).find(b => b.textContent?.includes('Confirmar'));
    expect(confirmBtn).toBeDefined();
    confirmBtn!.click();
    await flushSync();

    // Basic profile step
    expect(document.body.textContent).toContain('Perfil básico');
    const fullNameInput = document.querySelector('input#full-name') as HTMLInputElement;
    fullNameInput.value = 'John Doe';
    fullNameInput.dispatchEvent(new Event('input', { bubbles: true }));
    await flushSync();

    const saveBtn = Array.from(document.querySelectorAll('button')).find(b => b.textContent?.includes('Guardar perfil'));
    saveBtn!.click();

    await new Promise(r => setTimeout(r, 10)); // wait for async records.put
    await flushSync();

    // Family step
    expect(document.body.textContent).toContain('Familia');
    const skipBtn = Array.from(document.querySelectorAll('button')).find(b => b.textContent?.includes('Omitir'));
    skipBtn!.click();
    await flushSync();

    // Tour step
    expect(document.body.textContent).toContain('¡Todo listo!');
    const finishBtn = Array.from(document.querySelectorAll('button')).find(b => b.textContent?.includes('Entrar'));
    finishBtn!.click();
    await flushSync();

    expect(routes.navigate).toHaveBeenCalledWith('/app');
  });

  it('NO_PASSKEY triggers read-only mode instead of a retry', async () => {
    app = mount(Onboarding, { target: document.body });
    flushSync();

    for (let i = 0; i < 3; i++) {
      const btn = document.querySelector('button') as HTMLButtonElement;
      btn.click();
      await flushSync();
      await new Promise(r => setTimeout(r, 0));
    }

    const nameInput = document.querySelector('input#vault-name') as HTMLInputElement;
    nameInput.value = 'Test User';
    nameInput.dispatchEvent(new Event('input', { bubbles: true }));
    await flushSync();

    services.vault.create = async () => {
      const e = new Error('cancelled');
      (e as any).code = 'NO_PASSKEY';
      throw e;
    };

    const createBtn = document.querySelector('button') as HTMLButtonElement;
    createBtn.click();

    await new Promise(r => setTimeout(r, 10)); // wait for async vault.create
    await flushSync();

    expect(document.body.textContent).toContain('Modo de solo lectura');
  });

  it('session CANCELLED error offers a retry instead of read-only', async () => {
    app = mount(Onboarding, { target: document.body });
    flushSync();

    for (let i = 0; i < 3; i++) {
      const btn = document.querySelector('button') as HTMLButtonElement;
      btn.click();
      await flushSync();
      await new Promise(r => setTimeout(r, 0));
    }

    const nameInput = document.querySelector('input#vault-name') as HTMLInputElement;
    nameInput.value = 'Test User';
    nameInput.dispatchEvent(new Event('input', { bubbles: true }));
    await flushSync();

    services.vault.create = async () => {
      const e = new Error('cancelled');
      (e as any).code = 'CANCELLED';
      throw e;
    };

    const createBtn = document.querySelector('button') as HTMLButtonElement;
    createBtn.click();

    await new Promise(r => setTimeout(r, 10)); // wait for async vault.create
    await flushSync();

    // Step should still be create-vault, not capability-check
    expect(document.body.textContent).toContain('Crear tu bóveda segura');
    expect(document.body.textContent).toContain('Creación cancelada. Inténtalo de nuevo.');
  });

  it('other error in passkey creation goes to read-only mode', async () => {
    app = mount(Onboarding, { target: document.body });
    flushSync();

    for (let i = 0; i < 3; i++) {
      const btn = document.querySelector('button') as HTMLButtonElement;
      btn.click();
      await flushSync();
      await new Promise(r => setTimeout(r, 0));
    }

    const nameInput = document.querySelector('input#vault-name') as HTMLInputElement;
    nameInput.value = 'Test User';
    nameInput.dispatchEvent(new Event('input', { bubbles: true }));
    await flushSync();

    services.vault.create = async () => {
      throw new Error('Some generic error');
    };

    const createBtn = document.querySelector('button') as HTMLButtonElement;
    createBtn.click();

    await new Promise(r => setTimeout(r, 10)); // wait for async vault.create
    await flushSync();

    expect(document.body.textContent).toContain('Modo de solo lectura');
  });
});
