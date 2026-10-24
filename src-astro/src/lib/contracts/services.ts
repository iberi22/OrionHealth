// Service facade the UI talks to. UI code imports only these interfaces and `getServices()`;
// it never imports lib/vault, lib/family, lib/kb or lib/rag directly. The real implementation
// is wired in lib/app/real.ts; lib/contracts/mock.ts is the in-memory demo used by tests,
// screenshots and the UI until the wiring lands.

import type {
  AccessPreset,
  Alert,
  AlertRule,
  CircleRecord,
  CircleState,
  Grant,
  GuardedSummary,
  HealthRecord,
  KbEntry,
  KbHit,
  KbSystem,
  Member,
  PersonalCategory,
  RagAnswer,
  RecoveryProgress,
  TrusteePolicy,
} from './types';

export type VaultState = 'unsupported' | 'empty' | 'locked' | 'unlocked';

export interface VaultCapabilities {
  webauthn: boolean;
  /** Confirmed only after a passkey ceremony; before that it is a best guess. */
  prf: boolean | 'unknown';
  indexedDb: boolean;
}

export interface VaultService {
  capabilities(): Promise<VaultCapabilities>;
  state(): VaultState;
  onState(cb: (s: VaultState) => void): () => void;
  /** Registers a passkey (user verification required) and creates the vault. Returns the recovery code once. */
  create(displayName: string): Promise<{ memberId: string; recoveryCode: string }>;
  /** Asks the device for fingerprint / face / pattern / PIN. */
  unlock(): Promise<void>;
  lock(): void;
  /** Minutes of inactivity (or hidden tab) before auto-lock. */
  setAutoLockMinutes(minutes: number): void;
  memberId(): string | null;
  displayName(): string | null;
}

export interface RecordsService {
  list<K extends HealthRecord['kind']>(kind: K, owner?: string): Promise<Extract<HealthRecord, { kind: K }>[]>;
  put(record: HealthRecord): Promise<void>;
  remove(kind: HealthRecord['kind'], recordId: string): Promise<void>;
  onChange(cb: () => void): () => void;
}

export interface InviteTicket {
  url: string;
  expiresAt: number;
}

export interface PendingJoin {
  requestId: string;
  displayName: string;
  sas: string;
}

export interface FamilyService {
  circle(): Promise<CircleState | null>;
  createCircle(name: string): Promise<CircleState>;
  createInvite(): Promise<InviteTicket>;
  /** Joiner side: returns the SAS to compare on both screens. */
  join(inviteUrl: string, displayName: string): Promise<{ sas: string }>;
  pendingJoins(): Promise<PendingJoin[]>;
  approveJoin(requestId: string, sasMatches: boolean): Promise<void>;
  removeMember(memberId: string): Promise<void>;
  addDependent(displayName: string): Promise<Member>;

  grantsGiven(): Promise<Grant[]>;
  grantsReceived(): Promise<Grant[]>;
  grant(to: string, preset: AccessPreset, custom?: { categories: PersonalCategory[]; access: 'read' | 'write' }, expiresAt?: number): Promise<void>;
  revoke(grantId: string): Promise<void>;
  setGuardian(guardianId: string): Promise<void>;
  guardedSummaries(): Promise<GuardedSummary[]>;
  onChange(cb: () => void): () => void;
}

export interface HealthCircleService {
  list<K extends CircleRecord['kind']>(kind: K): Promise<Extract<CircleRecord, { kind: K }>[]>;
  put(record: CircleRecord): Promise<void>;
  alertRules(subject?: string): Promise<AlertRule[]>;
  putAlertRule(rule: AlertRule): Promise<void>;
  alerts(): Promise<Alert[]>;
  acknowledge(alertId: string): Promise<void>;
  onChange(cb: () => void): () => void;
}

/** Trustee side: a recovery request with its real provenance (spec §9.3). */
export interface PendingRecovery {
  requestId: string;
  /** Member whose access is CLAIMED. The trustee must confirm it out of band (call / in person) with the SAS. */
  member: Member;
  /** Temporary identity of the requesting device (hash of its temporary signing key) and its device id. */
  requester: { id: string; deviceId: string };
  /** Admin who verified the requesting device with a SAS and vouched for the request. */
  vouchedBy: Member;
  /** SAS shown on the requesting device; read it back with the member before approving. */
  sas: string;
  at: number;
  expiresAt: number;
}

/** Admin side: a device that opened a recovery invitation and waits for the SAS comparison. */
export interface PendingRecoveryJoin {
  requestId: string;
  member: Member;
  sas: string;
  at: number;
}

export interface RecoveryService {
  policy(): Promise<TrusteePolicy | null>;
  setPolicy(policy: TrusteePolicy): Promise<void>;
  /** Trustee side: requests vouched by an admin for a member whose share I hold, not yet answered by me. */
  pendingRequests(): Promise<PendingRecovery[]>;
  /**
   * Trustee side. With sasMatches=false the request is declined (hidden on this device). With true, the request must be
   * bound to an admin-vouched recovery invitation and the trustee re-authenticates with their passkey before the
   * share is re-wrapped to the requesting device.
   */
  approve(requestId: string, sasMatches: boolean): Promise<void>;
  /** Admin side: invitation link for a brand-new device of `memberId` (not me). */
  createRecoveryInvite(memberId: string): Promise<InviteTicket>;
  pendingRecoveryJoins(): Promise<PendingRecoveryJoin[]>;
  /** Admin side: after comparing the SAS, vouches for the device (pending device-add) and hands it the circle key. */
  approveRecoveryJoin(requestId: string, sasMatches: boolean): Promise<void>;
  /** New-device side; works on an EMPTY vault. Returns the SAS to compare with the admin. */
  startRecovery(inviteUrl: string): Promise<{ sas: string }>;
  /** `file` is the content of orion-recovery.json; needed on an empty device that did not join through an invitation. */
  recoverWithCode(code: string, file?: string): Promise<void>;
  /** The encrypted orion-recovery.json for the unlocked member (code-wrapped MRS + sealed bundle). */
  recoveryFile(): Promise<{ filename: string; content: string }>;
  progress(): RecoveryProgress;
  onProgress(cb: (p: RecoveryProgress) => void): () => void;
}

export interface KbService {
  search(query: string, opts?: { systems?: KbSystem[]; limit?: number }): Promise<KbHit[]>;
  get(id: string): Promise<KbEntry | null>;
}

export interface RagService {
  /** Uses personal data only when the vault is unlocked and includePersonal is true; never leaves the device. */
  ask(question: string, opts?: { includePersonal?: boolean }): Promise<RagAnswer>;
  localLlmAvailable(): Promise<boolean>;
}

export interface Services {
  vault: VaultService;
  records: RecordsService;
  family: FamilyService;
  health: HealthCircleService;
  recovery: RecoveryService;
  kb: KbService;
  rag: RagService;
}

let current: Services | null = null;

export function setServices(s: Services): void {
  current = s;
}

export function getServices(): Services {
  if (!current) throw new Error('services not initialised: call setServices() first');
  return current;
}
