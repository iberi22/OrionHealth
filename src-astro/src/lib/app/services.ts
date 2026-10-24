// Chooses the service implementation for the SPA: the real, encrypted-at-rest services, or the
// in-memory demo (PUBLIC_SERVICES=mock, or a browser without IndexedDB / WebAuthn).
import type { Services } from '../contracts/services';

export async function loadServices(): Promise<Services & { demo: boolean }> {
  const forceMock = import.meta.env.PUBLIC_SERVICES === 'mock';
  if (forceMock || typeof indexedDB === 'undefined' || typeof PublicKeyCredential === 'undefined') {
    const { createMockServices } = await import('../contracts/mock');
    return { ...createMockServices(), demo: true };
  }
  const { createRealServices } = await import('./real');
  return createRealServices();
}
