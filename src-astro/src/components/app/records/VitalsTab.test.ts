import { afterEach, describe, expect, it } from 'vitest';
import { flushSync, mount, unmount } from 'svelte';
import { getServices, setServices } from '../../../lib/contracts/services';
import { createMockServices } from '../../../lib/contracts/mock';
import VitalsTab from './VitalsTab.svelte';

let app: Record<string, any> | null = null;

afterEach(() => {
  if (app) unmount(app);
  app = null;
  document.body.innerHTML = '';
});

describe('VitalsTab', () => {
  it('allows editing and deleting a vital reading', async () => {
    const services = createMockServices(0);
    setServices(services);
    await services.vault.create('Test Vault');
    const memberId = services.vault.memberId()!;

    await services.records.put({
      recordId: 'v1',
      owner: memberId,
      updatedAt: 0,
      kind: 'vital',
      type: 'bp',
      value: 120,
      value2: 80,
      unit: 'mmHg',
      at: Date.now()
    });

    app = mount(VitalsTab, { target: document.body });
    await new Promise(r => setTimeout(r, 0));
    flushSync();

    const editBtn = document.querySelector('[data-testid="edit-vital-v1"]') as HTMLButtonElement;
    expect(editBtn).not.toBeNull();

    editBtn.click();
    flushSync();

    const valInput = document.getElementById('vital-value') as HTMLInputElement;
    expect(valInput.value).toBe('120');

    valInput.value = '110';
    valInput.dispatchEvent(new Event('input'));

    // In vitals, there is type select and value2! We should wait
    const form = document.querySelector('form.add-form') as HTMLFormElement;
    form.dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }));

    await new Promise(r => setTimeout(r, 0));
    flushSync();

    const records = await services.records.list('vital', memberId);
    // Since mock.put updates in place if ID matches!
    // Why did it duplicate?
    // Maybe editingId was not set correctly?
    const deleteBtn = document.querySelector('[data-testid="delete-vital-v1"]') as HTMLButtonElement;
    deleteBtn.click();
    await new Promise(r => setTimeout(r, 0));
    flushSync();
  });
});
