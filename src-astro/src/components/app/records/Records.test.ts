import { afterEach, describe, expect, it } from 'vitest';
import { flushSync, mount, unmount, tick } from 'svelte';
import { setServices } from '../../../lib/contracts/services';
import { createMockServices } from '../../../lib/contracts/mock';
import Records from './Records.svelte';

let app: Record<string, any> | null = null;

afterEach(() => {
  if (app) unmount(app);
  app = null;
  document.body.innerHTML = '';
});

describe('Records area', () => {
  it('mounts the records area and shows conditions by default', () => {
    setServices(createMockServices(0));
    app = mount(Records, { target: document.body });
    flushSync();

    const area = document.querySelector('[data-testid="area-records"]');
    expect(area).not.toBeNull();

    // Check if default tab is active
    const activeTabBtn = document.querySelector('.tab-btn.active');
    expect(activeTabBtn?.textContent?.trim()).toBe('Condiciones');

    // Check if conditions tab content is rendered (h2 should be present)
    const header = document.querySelector('.header h2');
    expect(header?.textContent).toBe('Condiciones médicas');
  });

  it('switches to medications tab when clicked', () => {
    setServices(createMockServices(0));
    app = mount(Records, { target: document.body });
    flushSync();

    const tabs = Array.from(document.querySelectorAll('.tab-btn'));
    const medsTab = tabs.find(t => t.textContent?.trim() === 'Medicamentos') as HTMLButtonElement;

    medsTab.click();
    flushSync();

    expect(medsTab.classList.contains('active')).toBe(true);

    const header = document.querySelector('.header h2');
    expect(header?.textContent).toBe('Medicamentos');
  });

  it('switches to vitals tab when clicked', () => {
    setServices(createMockServices(0));
    app = mount(Records, { target: document.body });
    flushSync();

    const tabs = Array.from(document.querySelectorAll('.tab-btn'));
    const vitalsTab = tabs.find(t => t.textContent?.trim() === 'Signos vitales') as HTMLButtonElement;

    vitalsTab.click();
    flushSync();

    const header = document.querySelector('.header h2');
    expect(header?.textContent).toContain('Signos vitales');
  });
});
