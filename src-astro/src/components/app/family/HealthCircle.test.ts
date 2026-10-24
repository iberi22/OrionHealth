import { afterEach, describe, expect, it } from 'vitest';
import { flushSync, mount, unmount } from 'svelte';
import { setServices } from '../../../lib/contracts/services';
import { createMockServices } from '../../../lib/contracts/mock';
import HealthCircle from './HealthCircle.svelte';

let app: Record<string, any> | null = null;
afterEach(() => {
  if (app) unmount(app);
  app = null;
  document.body.innerHTML = '';
});

describe('HealthCircle area', () => {
  it('mounts the area and shows mock data', async () => {
    const srv = createMockServices(Date.now());
    await srv.vault.create('Ana'); // unlock and get memberId
    setServices(srv);

    app = mount(HealthCircle, { target: document.body });

    // Wait for the async load in onMount
    await new Promise((r) => setTimeout(r, 50));
    flushSync();

    const area = document.querySelector('[data-testid="area-family-health"]');
    expect(area).not.toBeNull();

    // Check if the mock initiative "30 días con menos azúcar" is rendered
    expect(area?.textContent).toContain('30 días con menos azúcar');

    // Check if habits section is rendered
    expect(area?.textContent).toContain('Mis Hábitos');
    // Check if the mock habit "Agua" is rendered
    expect(area?.textContent).toContain('Agua');
  });
});
