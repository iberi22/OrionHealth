import { afterEach, describe, expect, it } from 'vitest';
import { flushSync, mount, unmount } from 'svelte';
import { setServices } from '../../../lib/contracts/services';
import { createMockServices } from '../../../lib/contracts/mock';
import Emergency from './Emergency.svelte';

let app: Record<string, any> | null = null;

afterEach(() => {
  if (app) unmount(app);
  app = null;
  document.body.innerHTML = '';
});

describe('Emergency area', () => {
  it('mounts and shows the area-emergency test id', async () => {
    setServices(createMockServices(0));
    app = mount(Emergency, { target: document.body });

    // Initial render might have loading state, but testid should be present
    flushSync();
    expect(document.querySelector('[data-testid="area-emergency"]')).not.toBeNull();
  });

  it('renders a medical ID summary from mock data', async () => {
    const mock = createMockServices(0);
    setServices(mock);
    app = mount(Emergency, { target: document.body });

    // Await promise ticks for loadData to complete
    await new Promise(resolve => setTimeout(resolve, 10));
    flushSync();

    const html = document.body.innerHTML;
    // Mock contains "Ana Demo" as fullName
    expect(html).toContain('Ana Demo');
    expect(html).toContain('O+'); // Blood type
    expect(html).toContain('Penicilina'); // Allergy
  });

  it('can enter emergency mode', async () => {
    const mock = createMockServices(0);
    setServices(mock);
    app = mount(Emergency, { target: document.body });

    await new Promise(resolve => setTimeout(resolve, 10));
    flushSync();

    const emergencyBtn = document.querySelector('.emergency-btn') as HTMLButtonElement;
    expect(emergencyBtn).not.toBeNull();

    // Click emergency mode
    emergencyBtn.click();
    flushSync();

    const html = document.body.innerHTML;
    // Warning text should be visible
    expect(html).toContain('Cualquiera que escanee este código verá estos datos.');
    // Large text pre should be visible with summary
    expect(html).toContain('Nombre: Ana Demo');
  });

  it('can enter edit mode', async () => {
    const mock = createMockServices(0);
    setServices(mock);
    app = mount(Emergency, { target: document.body });

    await new Promise(resolve => setTimeout(resolve, 10));
    flushSync();

    const editBtn = document.querySelector('.edit-btn') as HTMLButtonElement;
    expect(editBtn).not.toBeNull();

    editBtn.click();
    flushSync();

    // Should show form
    const form = document.querySelector('.medical-id-form');
    expect(form).not.toBeNull();
  });
});
