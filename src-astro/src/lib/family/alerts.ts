import type { Alert, AlertRule, Medication, VitalReading } from '../contracts/types';

export function severityFor(rule: AlertRule, value: number): 'info' | 'warning' | 'critical' {
  if (rule.comparator === 'missed-for-hours') return 'warning';

  if (rule.vital === 'bp') {
    if (!rule.useValue2 && rule.comparator === '>') {
      if (value > 180) return 'critical';
      if (value > 160) return 'warning';
      return 'info';
    }
    if (rule.useValue2 && rule.comparator === '>') {
      if (value > 110) return 'critical';
      return 'info';
    }
  }

  if (rule.vital === 'glucose') {
    if (rule.comparator === '<') {
      if (value < 70) return 'critical';
    } else if (rule.comparator === '>') {
      if (value > 250) return 'warning';
    }
  }

  if (rule.vital === 'spo2' && rule.comparator === '<') {
    if (value < 92) return 'critical';
  }

  return 'info';
}

function vitalMessage(rule: AlertRule, reading: VitalReading, value: number): string {
  if (rule.vital === 'bp') {
    if (rule.useValue2) return `Presión diastólica ${value} mmHg (${rule.comparator} ${rule.threshold})`;
    return `Presión sistólica ${value} mmHg (${rule.comparator} ${rule.threshold})`;
  }
  if (rule.vital === 'glucose') return `Glucosa ${value} mg/dL (${rule.comparator} ${rule.threshold})`;
  if (rule.vital === 'spo2') return `SpO2 ${value}% (${rule.comparator} ${rule.threshold})`;
  return `${reading.type} ${value} ${reading.unit} (${rule.comparator} ${rule.threshold})`;
}

export function evaluateVital(rules: AlertRule[], reading: VitalReading, now: number): Alert[] {
  const alerts: Alert[] = [];

  for (const rule of rules) {
    if (!rule.enabled) continue;
    if (rule.comparator === 'missed-for-hours') continue;
    if (rule.vital !== reading.type) continue;
    if (rule.subject !== reading.owner) continue;

    const value = rule.useValue2 ? reading.value2 : reading.value;
    if (value === undefined) continue;

    let matched = false;
    if (rule.comparator === '>') matched = value > rule.threshold;
    else if (rule.comparator === '<') matched = value < rule.threshold;

    if (matched) {
      alerts.push({
        alertId: globalThis.crypto.randomUUID(),
        ruleId: rule.recordId,
        subject: rule.subject,
        at: now,
        severity: severityFor(rule, value),
        message: vitalMessage(rule, reading, value),
      });
    }
  }

  return alerts;
}

export function defaultRulesFor(subject: string, guardians: string[]): AlertRule[] {
  const defaults: Omit<AlertRule, 'recordId' | 'updatedAt'>[] = [
    {
      kind: 'alert-rule',
      owner: subject,
      subject,
      vital: 'bp',
      comparator: '>',
      threshold: 160,
      useValue2: false,
      notify: guardians,
      enabled: true,
    },
    {
      kind: 'alert-rule',
      owner: subject,
      subject,
      vital: 'bp',
      comparator: '>',
      threshold: 110,
      useValue2: true,
      notify: guardians,
      enabled: true,
    },
    {
      kind: 'alert-rule',
      owner: subject,
      subject,
      vital: 'glucose',
      comparator: '<',
      threshold: 70,
      notify: guardians,
      enabled: true,
    },
    {
      kind: 'alert-rule',
      owner: subject,
      subject,
      vital: 'glucose',
      comparator: '>',
      threshold: 250,
      notify: guardians,
      enabled: true,
    },
    {
      kind: 'alert-rule',
      owner: subject,
      subject,
      vital: 'spo2',
      comparator: '<',
      threshold: 92,
      notify: guardians,
      enabled: true,
    },
    {
      kind: 'alert-rule',
      owner: subject,
      subject,
      comparator: 'missed-for-hours',
      threshold: 24,
      notify: guardians,
      enabled: true,
    },
  ];

  const now = Date.now();
  return defaults.map((r) => ({
    ...r,
    recordId: globalThis.crypto.randomUUID(),
    updatedAt: now,
  }));
}

export function evaluateMissedMedication(rules: AlertRule[], medications: Medication[], now: number): Alert[] {
  const alerts: Alert[] = [];

  for (const rule of rules) {
    if (!rule.enabled || rule.comparator !== 'missed-for-hours') continue;

    const matchedMeds = medications.filter(
      (m) => m.owner === rule.subject && m.active && (!rule.medicationId || m.recordId === rule.medicationId)
    );

    for (const med of matchedMeds) {
      const lastTaken = med.takenLog && med.takenLog.length > 0 ? Math.max(...med.takenLog) : med.updatedAt;
      const msThreshold = rule.threshold * 3600000;

      if (now - lastTaken >= msThreshold) {
        alerts.push({
          alertId: globalThis.crypto.randomUUID(),
          ruleId: rule.recordId,
          subject: rule.subject,
          at: now,
          severity: severityFor(rule, 0),
          message: `Medicamento ${med.name} omitido por ${rule.threshold} horas`,
        });
      }
    }
  }

  return alerts;
}

export function dedupeAlerts(existing: Alert[], next: Alert[]): Alert[] {
  const getDedupKey = (a: Alert) => `${a.ruleId}:${a.subject}:${Math.floor(a.at / 3600000)}`;

  const existingKeys = new Set(existing.map(getDedupKey));
  const keptNext = next.filter((a) => !existingKeys.has(getDedupKey(a)));

  return [...existing, ...keptNext];
}
