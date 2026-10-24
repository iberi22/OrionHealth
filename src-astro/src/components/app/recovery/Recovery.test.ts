import { afterEach, describe, expect, it, vi } from 'vitest';
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


  it('renders pending requests and handles approval', async () => {
    const services = createMockServices(0);
    setServices(services);
    await services.vault.create('Test');

    let cb: () => void = () => {};
    vi.spyOn(services.family, 'onChange').mockImplementation((c) => {
      cb = c;
      return () => {};
    });

    const approveSpy = vi.spyOn(services.recovery, 'approve').mockResolvedValue();

    vi.spyOn(services.recovery, 'pendingRequests').mockResolvedValue([
      {
        requestId: 'req-1',
        member: { memberId: 'm1', displayName: 'Alice' } as any,
        requester: { id: 'req-id-1', deviceId: 'dev-1' },
        vouchedBy: { displayName: 'AdminBob' } as any,
        sas: '123456',
        at: Date.now(),
        expiresAt: Date.now() + 100000,
      },
      {
        requestId: 'req-2',
        member: { memberId: 'm1', displayName: 'Alice' } as any,
        requester: { id: 'req-id-2', deviceId: 'dev-2' },
        vouchedBy: { displayName: 'AdminCharlie' } as any,
        sas: '654321',
        at: Date.now(),
        expiresAt: Date.now() + 100000,
      }
    ]);

    app = mount(Recovery, { target: document.body });
    flushSync();
    
    // Switch to requests tab
    const reqTabBtn = Array.from(document.querySelectorAll('.tabs button')).find(b => b.textContent?.includes('Solicitudes')) as HTMLButtonElement;
    reqTabBtn.click();
    flushSync();

    // Trigger family onChange to load requests
    cb();
    // wait for promises because refresh() is async and uses await services.recovery.pendingRequests()
    await new Promise(r => setTimeout(r, 0));
    flushSync();

    expect(document.body.textContent).toContain('123456');
    expect(document.body.textContent).toContain('654321');
    expect(document.body.textContent).toContain('dev-1');
    
    // Warning for multiple requests
    expect(document.body.textContent).toContain('¡Atención! Hay múltiples solicitudes de recuperación activas para este miembro.');

    const checkboxes = document.querySelectorAll('input[type="checkbox"]');
    (checkboxes[0] as HTMLInputElement).click();
    flushSync();

    const approveBtns = Array.from(document.querySelectorAll('button')).filter(b => b.textContent?.includes('Aprobar con mi passkey'));
    (approveBtns[0] as HTMLButtonElement).click();
    flushSync();

    expect(approveSpy).toHaveBeenCalledWith('req-1', true);

    const rejectBtns = Array.from(document.querySelectorAll('button')).filter(b => b.textContent?.includes('Rechazar'));
    (rejectBtns[0] as HTMLButtonElement).click();
    flushSync();

    expect(approveSpy).toHaveBeenCalledWith('req-1', false);
  });

});
