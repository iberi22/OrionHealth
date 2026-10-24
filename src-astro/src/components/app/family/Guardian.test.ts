import { afterEach, describe, expect, it } from 'vitest';
import { flushSync, mount, unmount } from 'svelte';
import { setServices } from '../../../lib/contracts/services';
import { createMockServices } from '../../../lib/contracts/mock';
import Guardian from './Guardian.svelte';

let app: Record<string, any> | null = null;
afterEach(() => {
  if (app) unmount(app);
  app = null;
  document.body.innerHTML = '';
});

describe('Guardian area', () => {
  it('shows empty state when not guarding anyone', async () => {
    const services = createMockServices(0);
    // Override guardedSummaries to return empty
    services.family.guardedSummaries = async () => [];
    setServices(services);

    app = mount(Guardian, { target: document.body });

    // Wait for promise
    await new Promise(resolve => setTimeout(resolve, 0));
    flushSync();

    const area = document.querySelector('[data-testid="area-family-guardian"]');
    expect(area).not.toBeNull();
    expect(area!.textContent).toContain('Actualmente no eres acudiente');
    expect(area!.textContent).toContain('Permisos');
  });

  it('renders guarded member panel when there are summaries', async () => {
    const services = createMockServices(0);
    setServices(services);

    // Unlock to get memberId for AlertRulesEditor
    await services.vault.create('Test');

    app = mount(Guardian, { target: document.body });

    await new Promise(resolve => setTimeout(resolve, 0));
    flushSync();

    const area = document.querySelector('[data-testid="area-family-guardian"]');
    expect(area).not.toBeNull();
    // Rosa is the one we guard in mock data
    expect(area!.textContent).toContain('Rosa');
    // Check for vitals
    expect(area!.textContent).toContain('bp: 165 mmHg');
    // Adherence
    expect(area!.textContent).toContain('86%');
    // Categories
    expect(area!.textContent).toContain('emergency, conditions');
    // Alerts
    expect(area!.textContent).toContain('Presión sistólica 165');
  });

  it('can acknowledge an alert', async () => {
    const services = createMockServices(0);
    setServices(services);
    await services.vault.create('Test');

    app = mount(Guardian, { target: document.body });

    await new Promise(resolve => setTimeout(resolve, 0));
    flushSync();

    // Find the acknowledge button (it should say "Confirmar")
    const buttons = Array.from(document.body.querySelectorAll('button'));
    const ackBtn = buttons.find(b => b.textContent?.includes('Confirmar'));
    expect(ackBtn).not.toBeUndefined();

    // Click acknowledge
    ackBtn!.click();

    await new Promise(resolve => setTimeout(resolve, 0));
    flushSync();

    // Alert should be gone
    const area = document.querySelector('[data-testid="area-family-guardian"]');
    expect(area!.textContent).not.toContain('Presión sistólica 165');
    expect(area!.textContent).toContain('No hay alertas activas');
  });
});
