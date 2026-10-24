// Chooses the service implementation for the SPA. Until lib/app/real.ts is wired (task "wire real
// services"), the app runs on the in-memory demo, so no data is ever persisted in clear.
import type { Services } from '../contracts/services';

export async function loadServices(): Promise<Services> {
  const { createMockServices } = await import('../contracts/mock');
  return createMockServices();
}
