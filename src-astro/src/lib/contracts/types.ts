// Shared data contracts of the web vault and family health circle.
// Spec: docs/architecture/web-vault-family-health.md (sections in comments).

export type PersonalCategory =
  | 'emergency'
  | 'conditions'
  | 'medications'
  | 'allergies'
  | 'vitals'
  | 'documents'
  | 'habits'
  | 'nutrition'
  | 'mental'
  | 'appointments';

export type ProtocolCategory = 'circle' | 'bundle' | 'grant' | 'membership' | 'recovery' | 'alert';

export type Category = PersonalCategory | ProtocolCategory;

export const PERSONAL_CATEGORIES: readonly PersonalCategory[] = [
  'emergency',
  'conditions',
  'medications',
  'allergies',
  'vitals',
  'documents',
  'habits',
  'nutrition',
  'mental',
  'appointments',
];

/** §5 — the only shape that is stored or replicated. All binary fields are base64url. */
export interface Envelope {
  v: 1;
  id: string;
  circle: string;
  owner: string;
  author: string;
  device: string;
  category: Category;
  epoch: number;
  hlc: string;
  nonce: string;
  ct: string;
  sig: string;
}

export type Access = 'read' | 'write';

/** §6 */
export interface Grant {
  v: 1;
  id: string;
  circle: string;
  from: string;
  to: string;
  category: Category;
  epoch: number;
  access: Access;
  expiresAt?: number;
  ephPub: string;
  wrapped: string;
  sig: string;
}

export type AccessPreset = 'guardian' | 'caregiver' | 'emergency-only' | 'custom';

export const PRESET_CATEGORIES: Record<Exclude<AccessPreset, 'custom'>, { categories: readonly PersonalCategory[]; access: Access }> = {
  guardian: { categories: PERSONAL_CATEGORIES, access: 'write' },
  caregiver: { categories: ['emergency', 'medications', 'allergies', 'vitals', 'appointments'], access: 'read' },
  'emergency-only': { categories: ['emergency'], access: 'read' },
};

export type Role = 'admin' | 'member';

/** §7 */
export type MembershipEventKind =
  | 'create'
  | 'invite'
  | 'join-request'
  | 'approve'
  | 'role'
  | 'guardian'
  | 'remove'
  | 'revoke'
  | 'device-add'
  | 'device-revoke';

export interface MembershipEvent {
  v: 1;
  id: string;
  circle: string;
  kind: MembershipEventKind;
  actor: string;
  /** Target member of the event (new member, guarded member, removed member...). */
  subject?: string;
  role?: Role;
  /** guardian: memberId of the guardian; revoke: grant id. */
  ref?: string;
  /** Public keys (SPKI b64url) carried by join-request / approve / device-add. */
  signPub?: string;
  boxPub?: string;
  deviceId?: string;
  displayName?: string;
  hlc: string;
  sig: string;
}

export interface Member {
  memberId: string;
  displayName: string;
  role: Role;
  signPub: string;
  boxPub: string;
  devices: string[];
  /** memberIds this member is guardian of. */
  guardianOf: string[];
  /** True for a profile owned by another member (child, elder without phone). */
  dependent: boolean;
  removed: boolean;
}

export interface CircleState {
  circleId: string;
  name: string;
  epoch: number;
  members: Record<string, Member>;
}

/** §9 */
export interface TrusteePolicy {
  threshold: number;
  trustees: string[];
}

export type RecoveryStep =
  | 'idle'
  | 'awaiting-invite'
  | 'awaiting-approvals'
  | 'combining'
  | 'register-passkey'
  | 'done'
  | 'failed';

export interface RecoveryProgress {
  step: RecoveryStep;
  approvals: number;
  threshold: number;
  error?: string;
}

// ---------- Personal records (plaintext shapes, only ever in memory) ----------

export interface RecordBase {
  recordId: string;
  owner: string;
  updatedAt: number;
  deleted?: boolean;
}

export interface MedicalId extends RecordBase {
  kind: 'medical-id';
  fullName: string;
  birthDate?: string;
  bloodType?: string;
  allergies: string[];
  conditions: string[];
  medications: string[];
  emergencyContacts: { name: string; phone: string; relation?: string }[];
  organDonor?: boolean;
  notes?: string;
}

export interface Condition extends RecordBase {
  kind: 'condition';
  name: string;
  icd10?: string;
  since?: string;
  notes?: string;
}

export interface Medication extends RecordBase {
  kind: 'medication';
  name: string;
  rxnorm?: string;
  dose: string;
  schedule: string;
  active: boolean;
  takenLog?: number[];
}

export interface Allergy extends RecordBase {
  kind: 'allergy';
  substance: string;
  reaction?: string;
  severity: 'mild' | 'moderate' | 'severe';
}

export type VitalType = 'bp' | 'glucose' | 'weight' | 'spo2' | 'hr' | 'temp' | 'steps' | 'sleep';

export interface VitalReading extends RecordBase {
  kind: 'vital';
  type: VitalType;
  value: number;
  /** Diastolic for bp. */
  value2?: number;
  unit: string;
  at: number;
  loinc?: string;
}

export interface HealthDocument extends RecordBase {
  kind: 'document';
  title: string;
  mime: string;
  /** Encrypted with the same CEK as the envelope; never a URL. */
  dataB64: string;
  at: number;
}

export interface Appointment extends RecordBase {
  kind: 'appointment';
  title: string;
  at: number;
  place?: string;
  notes?: string;
}

export interface Habit extends RecordBase {
  kind: 'habit';
  name: string;
  target: number;
  unit: string;
  checkins: { at: number; value: number }[];
  shareSummaryWithCircle: boolean;
}

export interface MealLog extends RecordBase {
  kind: 'meal';
  at: number;
  description: string;
  tags: string[];
}

export interface MoodLog extends RecordBase {
  kind: 'mood';
  at: number;
  score: 1 | 2 | 3 | 4 | 5;
  note?: string;
}

export type HealthRecord =
  | MedicalId
  | Condition
  | Medication
  | Allergy
  | VitalReading
  | HealthDocument
  | Appointment
  | Habit
  | MealLog
  | MoodLog;

export const RECORD_CATEGORY: Record<HealthRecord['kind'], PersonalCategory> = {
  'medical-id': 'emergency',
  condition: 'conditions',
  medication: 'medications',
  allergy: 'allergies',
  vital: 'vitals',
  document: 'documents',
  appointment: 'appointments',
  habit: 'habits',
  meal: 'nutrition',
  mood: 'mental',
};

// ---------- Family health area (§10) ----------

export interface Initiative extends RecordBase {
  kind: 'initiative';
  title: string;
  description: string;
  metric: string;
  target: number;
  startsAt: number;
  endsAt: number;
  participants: string[];
  createdBy: string;
}

export interface CheckIn extends RecordBase {
  kind: 'checkin';
  initiativeId: string;
  member: string;
  at: number;
  value: number;
  message?: string;
}

export interface CircleNote extends RecordBase {
  kind: 'note';
  member: string;
  at: number;
  text: string;
  initiativeId?: string;
}

export type CircleRecord = Initiative | CheckIn | CircleNote;

export type AlertComparator = '>' | '<' | 'missed-for-hours';

export interface AlertRule extends RecordBase {
  kind: 'alert-rule';
  /** Member whose data the rule watches. */
  subject: string;
  vital?: VitalType;
  comparator: AlertComparator;
  threshold: number;
  /** For bp: compare the diastolic value. */
  useValue2?: boolean;
  /** medicationId for 'missed-for-hours'. */
  medicationId?: string;
  notify: string[];
  enabled: boolean;
}

export interface Alert {
  alertId: string;
  ruleId: string;
  subject: string;
  at: number;
  message: string;
  severity: 'info' | 'warning' | 'critical';
  acknowledgedBy?: string;
}

/** What a guardian sees of each guarded member, only from decrypted granted data. */
export interface GuardedSummary {
  member: Member;
  latestVitals: VitalReading[];
  adherence7d?: number;
  openAlerts: Alert[];
  grantedCategories: PersonalCategory[];
}

// ---------- Knowledge base and RAG ----------

export type KbSystem = 'icd10' | 'loinc' | 'rxnorm' | 'snomed' | 'guideline' | 'interaction' | 'symptom';

export interface KbEntry {
  id: string;
  system: KbSystem;
  code: string;
  title: string;
  body: string;
  related?: string[];
}

export interface KbHit {
  entry: KbEntry;
  score: number;
}

export interface Citation {
  source: 'kb' | 'vault';
  id: string;
  title: string;
  snippet: string;
}

export interface RagAnswer {
  question: string;
  answer: string;
  mode: 'extractive' | 'local-llm';
  citations: Citation[];
  usedPersonalData: boolean;
}
