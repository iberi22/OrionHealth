import { afterEach, describe, expect, it } from 'vitest';
import { flushSync, mount, unmount } from 'svelte';
import { getServices, setServices } from '../../../lib/contracts/services';
import { createMockServices } from '../../../lib/contracts/mock';
import MedicationsTab from './MedicationsTab.svelte';

let app: Record<string, any> | null = null;

afterEach(() => {
  if (app) unmount(app);
  app = null;
  document.body.innerHTML = '';
});

describe('MedicationsTab', () => {
  it('allows editing and deleting a medication', async () => {
    const services = createMockServices(0);
    setServices(services);
    await services.vault.create('Test Vault');
    const memberId = services.vault.memberId()!;

    await services.records.put({
      recordId: 'm1',
      owner: memberId,
      updatedAt: 0,
      kind: 'medication',
      name: 'Meds',
      dose: '1',
      schedule: 'Daily',
      active: true,
      takenLog: []
    });

    app = mount(MedicationsTab, { target: document.body });
    await new Promise(r => setTimeout(r, 0));
    flushSync();

    const editBtn = document.querySelector('[data-testid="edit-medication-m1"]') as HTMLButtonElement;
    expect(editBtn).not.toBeNull();

    editBtn.click();
    flushSync();

    const nameInput = document.getElementById('med-name') as HTMLInputElement;
    expect(nameInput.value).toBe('Meds');

    nameInput.value = 'Meds Updated';
    nameInput.dispatchEvent(new Event('input'));

    const form = document.querySelector('form.add-form') as HTMLFormElement;
    form.dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }));

    await new Promise(r => setTimeout(r, 0));
    flushSync();

    const records = await services.records.list('medication', memberId);
    expect(records.length).toBe(1);
    expect(records[0].name).toBe('Meds Updated');

    const deleteBtn = document.querySelector('[data-testid="delete-medication-m1"]') as HTMLButtonElement;
    deleteBtn.click();
    await new Promise(r => setTimeout(r, 0));
    flushSync();

    const updatedRecords = await services.records.list('medication', memberId);
    expect(updatedRecords.length).toBe(0);
  });
});
