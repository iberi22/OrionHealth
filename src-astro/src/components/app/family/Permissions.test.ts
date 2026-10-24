import { afterEach, describe, expect, it } from 'vitest';
import { flushSync, mount, unmount } from 'svelte';
import { setServices } from '../../../lib/contracts/services';
import { createMockServices } from '../../../lib/contracts/mock';
import Permissions from './Permissions.svelte';

let app: Record<string, any> | null = null;
afterEach(() => {
  if (app) unmount(app);
  app = null;
  document.body.innerHTML = '';
});

describe('Permissions area', () => {
  it('mounts and renders the permissions area', async () => {
    setServices(createMockServices(0));
    app = mount(Permissions, { target: document.body });

    // Wait for async onMount (services.family.circle, etc) to resolve
    await new Promise((resolve) => setTimeout(resolve, 50));
    flushSync();

    const area = document.querySelector('[data-testid="area-family-permissions"]');
    expect(area).not.toBeNull();
    expect(area!.textContent).toContain('Permisos');
    expect(area!.textContent).toContain('Matriz de acceso');
    expect(area!.textContent).toContain('Otorgar acceso');
    expect(area!.textContent).toContain('Permisos otorgados');
    expect(area!.textContent).toContain('Compartido conmigo');
  });

  it('selects preset correctly', async () => {
    setServices(createMockServices(0));
    app = mount(Permissions, { target: document.body });

    await new Promise((resolve) => setTimeout(resolve, 50));
    flushSync();

    const select = document.querySelector('#preset-select') as HTMLSelectElement;
    expect(select).not.toBeNull();

    select.value = 'guardian';
    select.dispatchEvent(new Event('change'));
    flushSync();

    const warning = document.querySelector('.warning');
    expect(warning).not.toBeNull();
    expect(warning!.textContent).toContain('Incluye todas las categorías con permiso de escritura');
  });
});
