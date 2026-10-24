// Frozen contract (wave 2) between the real services and the vault/family libraries.
// Services (records, family, grants, health, recovery, assist) depend only on this interface;
// kernel.impl.ts implements it over vault/* and family/*, kernel.fake.ts in memory for tests.
// Spec: docs/architecture/web-vault-family-health.md.

import type { CircleState, Category, Envelope, PersonalCategory } from '../../contracts/types';
import type { MemberBundle } from '../../vault/keyring';

export class KernelError extends Error {
  constructor(
    public code: 'LOCKED' | 'NO_KEY' | 'NO_CIRCLE' | 'INVALID' | 'ID_CONFLICT',
    message: string,
  ) {
    super(message);
    this.name = 'KernelError';
  }
}

/** Categories sealed with the circle key CK instead of a personal CEK (spec §4). */
export const CIRCLE_KEYED: readonly Category[] = ['circle', 'grant', 'membership', 'recovery', 'alert'];

export interface SealRequest {
  category: Category;
  /** Defaults to my memberId. A different owner requires a write grant from that owner (spec §6). */
  owner?: string;
  plaintext: unknown;
  /** Defaults to the current circle id, or "local" without a circle. */
  circle?: string;
}

export interface Kernel {
  /** Throw KernelError('LOCKED') while the vault is locked. */
  memberId(): string;
  deviceId(): string;
  bundle(): MemberBundle;

  /**
   * Personal category of `owner` (default me): my CEK, or a CEK received through a grant.
   * My own CEK is created on first use with keyring.rotateCategory (so the first epoch is 1) and the
   * updated bundle is re-sealed and re-published by the implementation.
   */
  categoryKey(category: PersonalCategory, opts?: { owner?: string; epoch?: number }): Promise<{ key: CryptoKey; epoch: number }>;
  /** Circle key CK of the given epoch (default newest). Throws NO_CIRCLE without a circle. */
  circleKey(epoch?: number): Promise<{ key: CryptoKey; epoch: number }>;
  /** Registers a CEK unwrapped from a grant so open() can decrypt `owner`'s envelopes. */
  addForeignKey(owner: string, category: PersonalCategory, epoch: number, raw: Uint8Array): void;
  /** Registers a circle key epoch (creation, approval, rotation). */
  addCircleKey(epoch: number, raw: Uint8Array): void;

  circle(): Promise<CircleState | null>;
  /** Signing SPKI of a circle member (or me); null if unknown. */
  signPubOf(memberId: string): Promise<string | null>;
  boxPubOf(memberId: string): Promise<string | null>;

  /** Encrypts with the right key (CEK or CK by category), signs with my key, stamps hlc/device. Does not publish. */
  seal(req: SealRequest): Promise<Envelope>;
  /** Decrypts an envelope; throws NO_KEY when this member holds no key for it. */
  open(env: Envelope): Promise<unknown>;
  /** Validates (spec §5), stores immutably by id and replicates to the circle. */
  publish(env: Envelope): Promise<void>;
  envelopes(filter?: { owner?: string; category?: Category }): Promise<Envelope[]>;
  /** Fires for every accepted envelope, local or remote. */
  onEnvelope(cb: (env: Envelope) => void): () => void;
  /** Fires after lock; by then no CEK, CK, MRS or bundle is referenced by the kernel. */
  onLock(cb: () => void): () => void;
}
