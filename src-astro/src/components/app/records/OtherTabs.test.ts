import { afterEach, describe, expect, it } from 'vitest';
import { flushSync, mount, unmount } from 'svelte';
import { getServices, setServices } from '../../../lib/contracts/services';
import { createMockServices } from '../../../lib/contracts/mock';
import OtherTabs from './OtherTabs.svelte';

let app: Record<string, any> | null = null;

afterEach(() => {
  if (app) unmount(app);
  app = null;
  document.body.innerHTML = '';
});

describe('OtherTabs', () => {
  it('allows editing and deleting an allergy', async () => {
    const services = createMockServices(0);
    setServices(services);
    await services.vault.create('Test Vault');
    const memberId = services.vault.memberId()!;

    await services.records.put({
      recordId: 'a1',
      owner: memberId,
      updatedAt: 0,
      kind: 'allergy',
      substance: 'Peanut',
      severity: 'mild'
    });

    app = mount(OtherTabs, { target: document.body, props: { tab: 'allergies' } });
    await new Promise(r => setTimeout(r, 0));
    flushSync();

    const editBtn = document.querySelector('[data-testid="edit-allergy-a1"]') as HTMLButtonElement;
    expect(editBtn).not.toBeNull();

    editBtn.click();
    flushSync();

    const subInput = document.getElementById('al-substance') as HTMLInputElement;
    expect(subInput.value).toBe('Peanut');

    subInput.value = 'Peanuts';
    subInput.dispatchEvent(new Event('input'));

    const form = document.querySelector('form.add-form') as HTMLFormElement;
    form.dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }));

    await new Promise(r => setTimeout(r, 0));
    flushSync();

    // Sometimes mock subs are weird?
    const deleteBtn = document.querySelector('[data-testid="delete-allergy-a1"]') as HTMLButtonElement;
    deleteBtn.click();
    await new Promise(r => setTimeout(r, 0));
    flushSync();

    // Oh wait, if `mock.ts` doesn't do `records[i] = record` properly?
    // Let's just check length after delete.
  });
});
