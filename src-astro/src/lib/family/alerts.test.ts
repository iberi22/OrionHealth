import { describe, it, expect } from 'vitest';
import {
  evaluateVital,
  evaluateMissedMedication,
  severityFor,
  dedupeAlerts,
  defaultRulesFor
} from './alerts';
import type { AlertRule, VitalReading, Medication, Alert } from '../contracts/types';

describe('alerts rules engine', () => {
  const now = 1700000000000;

  describe('severityFor', () => {
    it('returns correct severity for BP systolic', () => {
      const rule = { vital: 'bp', comparator: '>', useValue2: false } as AlertRule;
      expect(severityFor(rule, 185)).toBe('critical');
      expect(severityFor(rule, 165)).toBe('warning');
      expect(severityFor(rule, 150)).toBe('info');
    });

    it('returns correct severity for BP diastolic', () => {
      const rule = { vital: 'bp', comparator: '>', useValue2: true } as AlertRule;
      expect(severityFor(rule, 115)).toBe('critical');
      expect(severityFor(rule, 100)).toBe('info');
    });

    it('returns correct severity for Glucose', () => {
      const ruleLow = { vital: 'glucose', comparator: '<' } as AlertRule;
      expect(severityFor(ruleLow, 65)).toBe('critical');
      expect(severityFor(ruleLow, 80)).toBe('info');

      const ruleHigh = { vital: 'glucose', comparator: '>' } as AlertRule;
      expect(severityFor(ruleHigh, 260)).toBe('warning');
      expect(severityFor(ruleHigh, 150)).toBe('info');
    });

    it('returns correct severity for SpO2', () => {
      const rule = { vital: 'spo2', comparator: '<' } as AlertRule;
      expect(severityFor(rule, 90)).toBe('critical');
      expect(severityFor(rule, 95)).toBe('info');
    });

    it('returns warning for missed-for-hours', () => {
      const rule = { comparator: 'missed-for-hours' } as AlertRule;
      expect(severityFor(rule, 0)).toBe('warning');
    });
  });

  describe('evaluateVital', () => {
    const rules: AlertRule[] = [
      {
        recordId: 'rule-bp-sys',
        kind: 'alert-rule',
        owner: 'subject-1',
        subject: 'subject-1',
        vital: 'bp',
        comparator: '>',
        threshold: 160,
        useValue2: false,
        notify: [],
        enabled: true,
        updatedAt: now,
      },
      {
        recordId: 'rule-bp-dia',
        kind: 'alert-rule',
        owner: 'subject-1',
        subject: 'subject-1',
        vital: 'bp',
        comparator: '>',
        threshold: 110,
        useValue2: true,
        notify: [],
        enabled: true,
        updatedAt: now,
      },
      {
        recordId: 'rule-disabled',
        kind: 'alert-rule',
        owner: 'subject-1',
        subject: 'subject-1',
        vital: 'bp',
        comparator: '>',
        threshold: 160,
        useValue2: false,
        notify: [],
        enabled: false,
        updatedAt: now,
      }
    ];

    it('produces warning alert for systolic BP > 160', () => {
      const reading: VitalReading = {
        recordId: 'v1',
        kind: 'vital',
        owner: 'subject-1',
        type: 'bp',
        value: 165,
        value2: 80,
        unit: 'mmHg',
        at: now,
        updatedAt: now,
      };

      const alerts = evaluateVital(rules, reading, now);
      expect(alerts).toHaveLength(1);
      expect(alerts[0].ruleId).toBe('rule-bp-sys');
      expect(alerts[0].severity).toBe('warning');
      expect(alerts[0].message).toContain('165');
    });

    it('produces critical alert for systolic BP > 180', () => {
      const reading: VitalReading = {
        recordId: 'v2',
        kind: 'vital',
        owner: 'subject-1',
        type: 'bp',
        value: 185,
        value2: 80,
        unit: 'mmHg',
        at: now,
        updatedAt: now,
      };

      const alerts = evaluateVital(rules, reading, now);
      expect(alerts).toHaveLength(1);
      expect(alerts[0].severity).toBe('critical');
    });

    it('produces critical alert for diastolic BP > 110', () => {
      const reading: VitalReading = {
        recordId: 'v3',
        kind: 'vital',
        owner: 'subject-1',
        type: 'bp',
        value: 120,
        value2: 115,
        unit: 'mmHg',
        at: now,
        updatedAt: now,
      };

      const alerts = evaluateVital(rules, reading, now);
      // It won't match systolic rule because value is 120 (< 160)
      expect(alerts).toHaveLength(1);
      expect(alerts[0].ruleId).toBe('rule-bp-dia');
      expect(alerts[0].severity).toBe('critical');
    });

    it('produces no alerts for disabled rules', () => {
      const reading: VitalReading = {
        recordId: 'v4',
        kind: 'vital',
        owner: 'subject-1',
        type: 'bp',
        value: 170, // this would trigger rule-disabled if it was enabled
        unit: 'mmHg',
        at: now,
        updatedAt: now,
      };

      const disabledOnlyRules = [rules[2]];
      const alerts = evaluateVital(disabledOnlyRules, reading, now);
      expect(alerts).toHaveLength(0);
    });

    it('produces no alerts for wrong subject', () => {
      const reading: VitalReading = {
        recordId: 'v5',
        kind: 'vital',
        owner: 'subject-2', // Different subject
        type: 'bp',
        value: 185,
        unit: 'mmHg',
        at: now,
        updatedAt: now,
      };

      const alerts = evaluateVital(rules, reading, now);
      expect(alerts).toHaveLength(0);
    });
  });

  describe('evaluateMissedMedication', () => {
    const rules: AlertRule[] = [
      {
        recordId: 'rule-med',
        kind: 'alert-rule',
        owner: 'subject-1',
        subject: 'subject-1',
        comparator: 'missed-for-hours',
        threshold: 24,
        notify: [],
        enabled: true,
        updatedAt: now,
      }
    ];

    it('produces warning alert if takenLog is empty and older than threshold', () => {
      const medications: Medication[] = [{
        recordId: 'm1',
        kind: 'medication',
        owner: 'subject-1',
        name: 'Aspirin',
        dose: '100mg',
        schedule: 'daily',
        active: true,
        takenLog: [],
        updatedAt: now - 25 * 3600000, // Created 25 hours ago
      }];

      const alerts = evaluateMissedMedication(rules, medications, now);
      expect(alerts).toHaveLength(1);
      expect(alerts[0].severity).toBe('warning');
      expect(alerts[0].message).toContain('Aspirin');
      expect(alerts[0].message).toContain('24');
    });

    it('produces no alert for recent takenLog', () => {
      const medications: Medication[] = [{
        recordId: 'm2',
        kind: 'medication',
        owner: 'subject-1',
        name: 'Aspirin',
        dose: '100mg',
        schedule: 'daily',
        active: true,
        takenLog: [now - 10 * 3600000], // Taken 10 hours ago
        updatedAt: now - 30 * 3600000,
      }];

      const alerts = evaluateMissedMedication(rules, medications, now);
      expect(alerts).toHaveLength(0);
    });

    it('produces warning alert for old takenLog', () => {
      const medications: Medication[] = [{
        recordId: 'm3',
        kind: 'medication',
        owner: 'subject-1',
        name: 'Aspirin',
        dose: '100mg',
        schedule: 'daily',
        active: true,
        takenLog: [now - 48 * 3600000], // Taken 48 hours ago
        updatedAt: now - 60 * 3600000,
      }];

      const alerts = evaluateMissedMedication(rules, medications, now);
      expect(alerts).toHaveLength(1);
      expect(alerts[0].severity).toBe('warning');
    });

    it('ignores inactive medications', () => {
      const medications: Medication[] = [{
        recordId: 'm4',
        kind: 'medication',
        owner: 'subject-1',
        name: 'Aspirin',
        dose: '100mg',
        schedule: 'daily',
        active: false,
        takenLog: [now - 48 * 3600000],
        updatedAt: now - 60 * 3600000,
      }];

      const alerts = evaluateMissedMedication(rules, medications, now);
      expect(alerts).toHaveLength(0);
    });
  });

  describe('dedupeAlerts', () => {
    it('dedupes identical alerts in the same hour bucket', () => {
      const existing: Alert[] = [
        {
          alertId: 'a1',
          ruleId: 'r1',
          subject: 's1',
          at: 3600000 * 10, // Hour 10
          severity: 'warning',
          message: 'msg',
        }
      ];

      const next: Alert[] = [
        {
          alertId: 'a2',
          ruleId: 'r1',
          subject: 's1',
          at: 3600000 * 10 + 1000, // Still Hour 10
          severity: 'critical', // Next alert for the same rule/subject/hour
          message: 'msg2',
        },
        {
          alertId: 'a3',
          ruleId: 'r1',
          subject: 's1',
          at: 3600000 * 11, // Hour 11
          severity: 'warning',
          message: 'msg3',
        }
      ];

      const combined = dedupeAlerts(existing, next);
      expect(combined).toHaveLength(2);
      expect(combined.map(a => a.alertId)).toContain('a1');
      expect(combined.map(a => a.alertId)).toContain('a3');
      expect(combined.map(a => a.alertId)).not.toContain('a2');
    });
  });

  describe('defaultRulesFor', () => {
    it('returns 6 correctly configured rules', () => {
      const guardians = ['g1', 'g2'];
      const defaults = defaultRulesFor('subject-1', guardians);

      expect(defaults).toHaveLength(6);

      // Basic validation
      for (const rule of defaults) {
        expect(rule.subject).toBe('subject-1');
        expect(rule.notify).toEqual(guardians);
        expect(rule.enabled).toBe(true);
        expect(rule.recordId).toBeDefined();
        expect(rule.updatedAt).toBeDefined();
      }

      const bpSys = defaults.find(r => r.vital === 'bp' && !r.useValue2);
      expect(bpSys?.threshold).toBe(160);
      expect(bpSys?.comparator).toBe('>');

      const bpDia = defaults.find(r => r.vital === 'bp' && r.useValue2);
      expect(bpDia?.threshold).toBe(110);
      expect(bpDia?.comparator).toBe('>');

      const glucLow = defaults.find(r => r.vital === 'glucose' && r.comparator === '<');
      expect(glucLow?.threshold).toBe(70);

      const glucHigh = defaults.find(r => r.vital === 'glucose' && r.comparator === '>');
      expect(glucHigh?.threshold).toBe(250);

      const spo2 = defaults.find(r => r.vital === 'spo2');
      expect(spo2?.threshold).toBe(92);
      expect(spo2?.comparator).toBe('<');

      const missedMed = defaults.find(r => r.comparator === 'missed-for-hours');
      expect(missedMed?.threshold).toBe(24);
    });
  });
});