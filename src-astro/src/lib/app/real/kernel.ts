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
export const CIRCLE_KEYED: readonly Category[] = ['circle', 'grant', 'membership', 'recovery', 'alert', 'bundle'];

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

  /**
   * Wraps a raw key that never leaves the kernel to a recipient box key with crypto.wrapTo(info, aad):
   * my personal CEK (`category`, default newest epoch) or the circle key (`circleEpoch`). Used to grant a
   * category (spec §6) and to hand CK to an approved member (spec §7).
   */
  wrapKeyFor(
    target: { category: PersonalCategory; epoch?: number } | { circleEpoch: number },
    recipientBoxPub: string,
    info: string,
    aad: Uint8Array,
  ): Promise<{ ephPub: string; wrapped: string; epoch: number }>;
  /** Unwraps with my box key (crypto.unwrapFrom) — e.g. a received grant or circle key. */
  unwrapForMe(ephPub: string, wrapped: string, info: string, aad: Uint8Array): Promise<Uint8Array>;
  /** Adds epoch+1 for one of my personal categories (revocation, spec §6) and re-publishes the bundle. */
  rotateCategory(category: PersonalCategory): Promise<number>;

  /**
   * Joins the kernel to a circle: its id and the genesis admin obtained through the SAS channel (spec §7).
   * Membership envelopes are reduced with this pinned genesis; without it circle() is null.
   */
  setCircle(circleId: string, genesis: { memberId: string; signPub: string }): Promise<void>;
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
  /** Fires for every accepted envelope, local or remote. A returned promise is awaited (errors ignored)
   *  before publish() resolves. */
  onEnvelope(cb: (env: Envelope) => void | Promise<void>): () => void;
  /** Fires after lock; by then no CEK, CK, MRS or bundle is referenced by the kernel. */
  onLock(cb: () => void): () => void;
}
