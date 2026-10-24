import { afterEach, describe, expect, it } from 'vitest';
import { flushSync, mount, unmount } from 'svelte';
import { setServices } from '../../../lib/contracts/services';
import { createMockServices } from '../../../lib/contracts/mock';
import Recovery from './Recovery.svelte';

let app: Record<string, any> | null = null;
afterEach(() => {
  if (app) unmount(app);
  app = null;
  document.body.innerHTML = '';
});

describe('Recovery area', () => {
  it('mounts the recovery component', () => {
    setServices(createMockServices(0));
    app = mount(Recovery, { target: document.body });
    flushSync();
    expect(document.querySelector('[data-testid="area-recovery"]')).not.toBeNull();
  });

  it('shows tabs when unlocked', async () => {
    const services = createMockServices(0);
    setServices(services);

    // Make sure it's unlocked for this test.
    await services.vault.create('Test');

    app = mount(Recovery, { target: document.body });
    flushSync();
    expect(document.body.textContent).toContain('Mi plan');
    expect(document.body.textContent).toContain('Solicitudes');
    expect(document.body.textContent).toContain('Recuperar en este dispositivo');
  });

  // More tests will be added/refined later.
});
