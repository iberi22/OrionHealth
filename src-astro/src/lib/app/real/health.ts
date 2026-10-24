import type { Kernel } from './kernel';
import type { RecordsService, HealthCircleService } from '../../contracts/services';
import type {
  Alert,
  AlertRule,
  CircleRecord,
  VitalReading
} from '../../contracts/types';
import { evaluateVital, dedupeAlerts } from '../../family/alerts';

export function createHealthService(kernel: Kernel, records: RecordsService): HealthCircleService {
  let localAlerts: Alert[] = [];
  const subs = new Set<() => void>();
  const seenVitals = new Set<string>();

  function notify() {
    subs.forEach(cb => cb());
  }

  // Evaluate a vital against rules and update alerts
  async function handleVital(vital: VitalReading) {
    if (seenVitals.has(vital.recordId)) return;
    seenVitals.add(vital.recordId);

    try {
      const rules = await service.alertRules();
      const newAlerts = evaluateVital(rules, vital, Date.now());
      if (newAlerts.length > 0) {
        localAlerts = dedupeAlerts(localAlerts, newAlerts);
        notify();
      }
    } catch (err) {
      console.error('Error evaluating vital', err);
    }
  }

  // Listen to remote envelopes for vitals
  kernel.onEnvelope(async (env) => {
    if (env.category === 'vitals') {
      try {
        const record = await kernel.open(env) as any;
        if (record && record.kind === 'vital') {
          await handleVital(record as VitalReading);
        }
      } catch (err) {
        // May fail if we don't have keys, which is expected for non-guardians
      }
    }
  });

  // Listen to local vital writes via RecordsService
  records.onChange(async () => {
    try {
      const vitals = await records.list('vital');
      for (const vital of vitals) {
        await handleVital(vital);
      }
    } catch (err) {
      console.error('Error listing local vitals', err);
    }
  });

  const service: HealthCircleService = {
    async list<K extends CircleRecord['kind']>(kind: K): Promise<Extract<CircleRecord, { kind: K }>[]> {
      const envs = await kernel.envelopes({ category: 'circle' });
      const results: CircleRecord[] = [];
      for (const env of envs) {
        try {
          const rec = await kernel.open(env) as CircleRecord;
          if (rec.kind === kind) results.push(rec);
        } catch (e) {
          // ignore unopenable envelopes
        }
      }
      return results as Extract<CircleRecord, { kind: K }>[];
    },

    async put(record: CircleRecord): Promise<void> {
      const env = await kernel.seal({
        category: 'circle',
        plaintext: record,
      });
      await kernel.publish(env);
    },

    async alertRules(subject?: string): Promise<AlertRule[]> {
      const envs = await kernel.envelopes({ category: 'alert' });
      const rules: AlertRule[] = [];
      for (const env of envs) {
        try {
          const rule = await kernel.open(env) as AlertRule;
          if (!subject || rule.subject === subject) {
            rules.push(rule);
          }
        } catch (e) {
          // ignore unopenable envelopes
        }
      }
      return rules;
    },

    async putAlertRule(rule: AlertRule): Promise<void> {
      const env = await kernel.seal({
        category: 'alert',
        plaintext: rule,
      });
      await kernel.publish(env);
    },

    async alerts(): Promise<Alert[]> {
      return localAlerts;
    },

    async acknowledge(alertId: string): Promise<void> {
      let changed = false;
      localAlerts = localAlerts.map(a => {
        if (a.alertId === alertId && !a.acknowledgedBy) {
          changed = true;
          return { ...a, acknowledgedBy: kernel.memberId() };
        }
        return a;
      });
      if (changed) notify();
    },

    onChange(cb: () => void) {
      subs.add(cb);
      return () => subs.delete(cb);
    }
  };

  return service;
}
