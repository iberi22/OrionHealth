import { afterEach, describe, expect, it } from 'vitest';
import { flushSync, mount, unmount } from 'svelte';
import { getServices, setServices } from '../../../lib/contracts/services';
import { createMockServices } from '../../../lib/contracts/mock';
import ConditionsTab from './ConditionsTab.svelte';

let app: Record<string, any> | null = null;

afterEach(() => {
  if (app) unmount(app);
  app = null;
  document.body.innerHTML = '';
});

describe('ConditionsTab', () => {
  it('allows editing and deleting a condition', async () => {
    const services = createMockServices(0);
    setServices(services);

    // In mock, vault is initially empty/locked. We need to create a vault first!
    await services.vault.create('Test Vault');
    const memberId = services.vault.memberId()!;

    await services.records.put({
      recordId: 'c1',
      owner: memberId,
      updatedAt: 0,
      kind: 'condition',
      name: 'Asthma'
    });

    app = mount(ConditionsTab, { target: document.body });
    await new Promise(r => setTimeout(r, 0)); // allow microtasks
    flushSync();

    const editBtn = document.querySelector('[data-testid="edit-condition-c1"]') as HTMLButtonElement;
    expect(editBtn).not.toBeNull();

    editBtn.click();
    flushSync();

    const nameInput = document.getElementById('cond-name') as HTMLInputElement;
    expect(nameInput.value).toBe('Asthma');

    nameInput.value = 'Asthma Updated';
    nameInput.dispatchEvent(new Event('input'));

    const form = document.querySelector('form.add-form') as HTMLFormElement;
    form.dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }));

    await new Promise(r => setTimeout(r, 0));
    flushSync();

    const records = await services.records.list('condition', memberId);
    expect(records.length).toBe(1);
    expect(records[0].name).toBe('Asthma Updated');

    const deleteBtn = document.querySelector('[data-testid="delete-condition-c1"]') as HTMLButtonElement;
    deleteBtn.click();
    await new Promise(r => setTimeout(r, 0));
    flushSync();

    const updatedRecords = await services.records.list('condition', memberId);
    expect(updatedRecords.length).toBe(0);
  });
});
