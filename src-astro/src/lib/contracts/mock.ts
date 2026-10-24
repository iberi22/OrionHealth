// In-memory demo implementation of the service facade. No crypto, no persistence, no PHI:
// a fictional family used by UI tests, screenshots and the UI until lib/app/real.ts is wired.

import type { Services, VaultState } from './services';
import type {
  Alert,
  AlertRule,
  CircleRecord,
  CircleState,
  Grant,
  HealthRecord,
  KbEntry,
  Member,
  PersonalCategory,
  RecoveryProgress,
  TrusteePolicy,
} from './types';
import { PRESET_CATEGORIES } from './types';

const DAY = 86_400_000;

function emitter() {
  const subs = new Set<() => void>();
  return {
    on(cb: () => void) {
      subs.add(cb);
      return () => subs.delete(cb);
    },
    emit() {
      subs.forEach((cb) => cb());
    },
  };
}

function member(memberId: string, displayName: string, extra: Partial<Member> = {}): Member {
  return {
    memberId,
    displayName,
    role: 'member',
    signPub: `sign-${memberId}`,
    boxPub: `box-${memberId}`,
    devices: [`dev-${memberId}`],
    guardianOf: [],
    dependent: false,
    removed: false,
    ...extra,
  };
}

export function createMockServices(now: number = Date.now()): Services {
  const me = 'm-ana';
  let vaultState: VaultState = 'locked';
  const vaultSubs = new Set<(s: VaultState) => void>();
  const setVault = (s: VaultState) => {
    vaultState = s;
    vaultSubs.forEach((cb) => cb(s));
  };

  const circle: CircleState = {
    circleId: 'c-demo',
    name: 'Familia Demo',
    epoch: 0,
    members: {
      'm-ana': member('m-ana', 'Ana', { role: 'admin', guardianOf: ['m-rosa'] }),
      'm-rosa': member('m-rosa', 'Rosa (mamá)'),
      'm-luis': member('m-luis', 'Luis'),
    },
  };

  const records: HealthRecord[] = [
    {
      kind: 'medical-id', recordId: 'mid-ana', owner: me, updatedAt: now,
      fullName: 'Ana Demo', bloodType: 'O+', allergies: ['Penicilina'], conditions: [], medications: [],
      emergencyContacts: [{ name: 'Luis Demo', phone: '+57 300 000 0000', relation: 'Hermano' }],
    },
    { kind: 'allergy', recordId: 'al-1', owner: me, updatedAt: now, substance: 'Penicilina', severity: 'severe', reaction: 'Urticaria' },
    { kind: 'medication', recordId: 'med-rosa-1', owner: 'm-rosa', updatedAt: now, name: 'Losartán', dose: '50 mg', schedule: '08:00', active: true, takenLog: [now - DAY, now - 2 * DAY] },
    { kind: 'condition', recordId: 'cond-rosa-1', owner: 'm-rosa', updatedAt: now, name: 'Hipertensión esencial', icd10: 'I10' },
    { kind: 'vital', recordId: 'v-1', owner: 'm-rosa', updatedAt: now, type: 'bp', value: 165, value2: 95, unit: 'mmHg', at: now - 3_600_000 },
    { kind: 'vital', recordId: 'v-2', owner: 'm-rosa', updatedAt: now, type: 'glucose', value: 104, unit: 'mg/dL', at: now - 7_200_000 },
    { kind: 'vital', recordId: 'v-3', owner: me, updatedAt: now, type: 'steps', value: 7420, unit: 'steps', at: now - 1_800_000 },
    { kind: 'habit', recordId: 'h-1', owner: me, updatedAt: now, name: 'Agua', target: 8, unit: 'vasos', checkins: [{ at: now - 600_000, value: 5 }], shareSummaryWithCircle: true },
  ];
  const recSubs = emitter();

  const circleRecords: CircleRecord[] = [
    {
      kind: 'initiative', recordId: 'ini-1', owner: me, updatedAt: now, title: '30 días con menos azúcar',
      description: 'Cambiamos bebidas azucaradas por agua o infusiones.', metric: 'días sin azúcar', target: 30,
      startsAt: now - 5 * DAY, endsAt: now + 25 * DAY, participants: ['m-ana', 'm-rosa', 'm-luis'], createdBy: me,
    },
    { kind: 'checkin', recordId: 'ci-1', owner: 'm-rosa', updatedAt: now, initiativeId: 'ini-1', member: 'm-rosa', at: now - DAY, value: 1, message: '¡Hoy lo logré!' },
    { kind: 'note', recordId: 'n-1', owner: 'm-luis', updatedAt: now, member: 'm-luis', at: now - 2 * DAY, text: 'Mamá, mañana te acompaño a caminar.', initiativeId: 'ini-1' },
  ];
  const rules: AlertRule[] = [
    { kind: 'alert-rule', recordId: 'r-1', owner: 'm-rosa', updatedAt: now, subject: 'm-rosa', vital: 'bp', comparator: '>', threshold: 160, notify: ['m-ana'], enabled: true },
  ];
  const alerts: Alert[] = [
    { alertId: 'a-1', ruleId: 'r-1', subject: 'm-rosa', at: now - 3_600_000, message: 'Presión sistólica 165 mmHg (> 160)', severity: 'warning' },
  ];
  const healthSubs = emitter();

  const grants: Grant[] = PRESET_CATEGORIES.guardian.categories.map((category, i) => ({
    v: 1, id: `g-${i}`, circle: circle.circleId, from: 'm-rosa', to: me, category, epoch: 0, access: 'write',
    ephPub: 'demo', wrapped: 'demo', sig: 'demo',
  }));
  const famSubs = emitter();

  let policy: TrusteePolicy | null = { threshold: 2, trustees: ['m-rosa', 'm-luis'] };
  let progress: RecoveryProgress = { step: 'idle', approvals: 0, threshold: 2 };
  const progSubs = new Set<(p: RecoveryProgress) => void>();

  const kb: KbEntry[] = [
    { id: 'icd10:I10', system: 'icd10', code: 'I10', title: 'Hipertensión esencial (primaria)', body: 'Presión arterial elevada sin causa secundaria identificada.' },
    { id: 'loinc:8480-6', system: 'loinc', code: '8480-6', title: 'Presión arterial sistólica', body: 'Medición de la presión sistólica en mmHg.' },
    { id: 'rxnorm:52175', system: 'rxnorm', code: '52175', title: 'Losartán', body: 'Antagonista del receptor de angiotensina II usado en hipertensión.' },
  ];

  const ownRecords = (owner?: string) => records.filter((r) => !r.deleted && (owner ? r.owner === owner : true));

  return {
    vault: {
      async capabilities() {
        return { webauthn: true, prf: true, indexedDb: true };
      },
      state: () => vaultState,
      onState(cb) {
        vaultSubs.add(cb);
        return () => vaultSubs.delete(cb);
      },
      async create() {
        setVault('unlocked');
        return { memberId: me, recoveryCode: 'demo demo demo demo demo demo demo demo demo demo demo demo demo demo demo demo demo demo demo demo demo demo demo demo' };
      },
      async unlock() {
        setVault('unlocked');
      },
      lock() {
        setVault('locked');
      },
      setAutoLockMinutes() {},
      memberId: () => (vaultState === 'unlocked' ? me : null),
      displayName: () => (vaultState === 'unlocked' ? 'Ana' : null),
    },
    records: {
      async list(kind, owner) {
        return ownRecords(owner).filter((r) => r.kind === kind) as never;
      },
      async put(record) {
        const i = records.findIndex((r) => r.recordId === record.recordId);
        if (i >= 0) records[i] = record;
        else records.push(record);
        recSubs.emit();
      },
      async remove(_kind, recordId) {
        const r = records.find((x) => x.recordId === recordId);
        if (r) r.deleted = true;
        recSubs.emit();
      },
      onChange: recSubs.on,
    },
    family: {
      async circle() {
        return circle;
      },
      async createCircle(name) {
        circle.name = name;
        famSubs.emit();
        return circle;
      },
      async createInvite() {
        return { url: 'https://orionhealth.swal.network/app/join#demo-invite', expiresAt: now + DAY };
      },
      async join() {
        return { sas: '482 913' };
      },
      async pendingJoins() {
        return [{ requestId: 'j-1', displayName: 'Tío Carlos', sas: '482 913' }];
      },
      async approveJoin() {
        famSubs.emit();
      },
      async removeMember(memberId) {
        const m = circle.members[memberId];
        if (m) m.removed = true;
        famSubs.emit();
      },
      async addDependent(displayName) {
        const m = member(`m-${displayName.toLowerCase().replace(/\W+/g, '-')}`, displayName, { dependent: true, devices: [] });
        circle.members[m.memberId] = m;
        famSubs.emit();
        return m;
      },
      async grantsGiven() {
        return grants.filter((g) => g.from === me);
      },
      async grantsReceived() {
        return grants.filter((g) => g.to === me);
      },
      async grant(to, preset, custom) {
        const spec = preset === 'custom' ? custom : PRESET_CATEGORIES[preset];
        (spec?.categories ?? []).forEach((category: PersonalCategory) =>
          grants.push({ v: 1, id: `g-${grants.length}`, circle: circle.circleId, from: me, to, category, epoch: 0, access: spec!.access, ephPub: 'demo', wrapped: 'demo', sig: 'demo' }),
        );
        famSubs.emit();
      },
      async revoke(grantId) {
        const i = grants.findIndex((g) => g.id === grantId);
        if (i >= 0) grants.splice(i, 1);
        famSubs.emit();
      },
      async setGuardian() {
        famSubs.emit();
      },
      async guardedSummaries() {
        const rosa = circle.members['m-rosa']!;
        return [{
          member: rosa,
          latestVitals: records.filter((r): r is Extract<HealthRecord, { kind: 'vital' }> => r.kind === 'vital' && r.owner === rosa.memberId),
          adherence7d: 0.86,
          openAlerts: alerts.filter((a) => !a.acknowledgedBy),
          grantedCategories: [...PRESET_CATEGORIES.guardian.categories],
        }];
      },
      onChange: famSubs.on,
    },
    health: {
      async list(kind) {
        return circleRecords.filter((r) => !r.deleted && r.kind === kind) as never;
      },
      async put(record) {
        const i = circleRecords.findIndex((r) => r.recordId === record.recordId);
        if (i >= 0) circleRecords[i] = record;
        else circleRecords.push(record);
        healthSubs.emit();
      },
      async alertRules(subject) {
        return rules.filter((r) => (subject ? r.subject === subject : true));
      },
      async putAlertRule(rule) {
        const i = rules.findIndex((r) => r.recordId === rule.recordId);
        if (i >= 0) rules[i] = rule;
        else rules.push(rule);
        healthSubs.emit();
      },
      async alerts() {
        return alerts;
      },
      async acknowledge(alertId) {
        const a = alerts.find((x) => x.alertId === alertId);
        if (a) a.acknowledgedBy = me;
        healthSubs.emit();
      },
      onChange: healthSubs.on,
    },
    recovery: {
      async policy() {
        return policy;
      },
      async setPolicy(p) {
        policy = p;
      },
      async pendingRequests() {
        return [];
      },
      async approve() {},
      async startRecovery() {
        progress = { step: 'awaiting-approvals', approvals: 0, threshold: policy?.threshold ?? 2 };
        progSubs.forEach((cb) => cb(progress));
        return { sas: '105 377' };
      },
      async recoverWithCode() {
        progress = { step: 'done', approvals: 0, threshold: 0 };
        progSubs.forEach((cb) => cb(progress));
      },
      progress: () => progress,
      onProgress(cb) {
        progSubs.add(cb);
        return () => progSubs.delete(cb);
      },
    },
    kb: {
      async search(query, opts) {
        const q = query.toLowerCase();
        return kb
          .filter((e) => (!opts?.systems || opts.systems.includes(e.system)) && `${e.code} ${e.title} ${e.body}`.toLowerCase().includes(q))
          .slice(0, opts?.limit ?? 20)
          .map((entry) => ({ entry, score: 1 }));
      },
      async get(id) {
        return kb.find((e) => e.id === id) ?? null;
      },
    },
    rag: {
      async ask(question, opts) {
        const personal = !!opts?.includePersonal && vaultState === 'unlocked';
        return {
          question,
          answer: 'Respuesta de demostración: la hipertensión esencial (I10) se controla con medicación como losartán y seguimiento de la presión.',
          mode: 'extractive',
          citations: [{ source: 'kb', id: 'icd10:I10', title: 'Hipertensión esencial (primaria)', snippet: kb[0]!.body }],
          usedPersonalData: personal,
        };
      },
      async localLlmAvailable() {
        return false;
      },
    },
  };
}
