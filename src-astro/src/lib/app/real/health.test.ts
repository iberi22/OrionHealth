import { describe, it, expect, vi, beforeEach } from 'vitest';
import { FakeKernel, FakeNetwork } from './kernel.fake';
import { createHealthService } from './health';
import type { RecordsService, HealthCircleService } from '../../contracts/services';
import type { AlertRule, Initiative, VitalReading } from '../../contracts/types';
import { b64u, randomBytes } from '../../crypto';

describe('HealthCircleService', () => {
  let net: FakeNetwork;
  let kernel: FakeKernel;
  let health: HealthCircleService;
  let recordsMock: RecordsService;
  let onRecordsChangeCb: () => void;

  beforeEach(async () => {
    net = new FakeNetwork();
    kernel = await FakeKernel.create({ network: net });

    // Simulate a circle by setting circle state and generating a circle key
    const circleId = b64u(randomBytes(16));
    kernel.circleState = {
      circleId,
      name: 'Test Circle',
      epoch: 1,
      members: {}
    };
    kernel.addCircleKey(1, randomBytes(32));

    recordsMock = {
      list: vi.fn().mockResolvedValue([]),
      put: vi.fn(),
      remove: vi.fn(),
      onChange: vi.fn().mockImplementation((cb) => {
        onRecordsChangeCb = cb;
        return () => {};
      })
    } as unknown as RecordsService;

    health = createHealthService(kernel, recordsMock);
  });

  it('puts and lists circle records', async () => {
    const initiative: Initiative = {
      kind: 'initiative',
      recordId: 'init-1',
      owner: kernel.memberId(),
      updatedAt: Date.now(),
      title: 'Walk 8k steps',
      description: 'Daily',
      metric: 'steps',
      target: 8000,
      startsAt: Date.now(),
      endsAt: Date.now() + 86400000,
      participants: [kernel.memberId()],
      createdBy: kernel.memberId()
    };

    await health.put(initiative);

    const records = await health.list('initiative');
    expect(records).toHaveLength(1);
    expect(records[0].recordId).toBe('init-1');
    expect(records[0].title).toBe('Walk 8k steps');
  });

  it('puts and lists alert rules', async () => {
    const rule: AlertRule = {
      kind: 'alert-rule',
      recordId: 'rule-1',
      owner: kernel.memberId(),
      updatedAt: Date.now(),
      subject: kernel.memberId(),
      vital: 'bp',
      comparator: '>',
      threshold: 160,
      notify: [],
      enabled: true
    };

    await health.putAlertRule(rule);

    const rulesAll = await health.alertRules();
    expect(rulesAll).toHaveLength(1);
    expect(rulesAll[0].recordId).toBe('rule-1');

    const rulesMine = await health.alertRules(kernel.memberId());
    expect(rulesMine).toHaveLength(1);

    const rulesOther = await health.alertRules('other-id');
    expect(rulesOther).toHaveLength(0);
  });

  it('notifies on putAlertRule and returns only the newest version of an edited rule', async () => {
    const rule: AlertRule = {
      kind: 'alert-rule',
      recordId: 'rule-edit',
      owner: kernel.memberId(),
      updatedAt: Date.now(),
      subject: kernel.memberId(),
      vital: 'bp',
      comparator: '>',
      threshold: 160,
      notify: [kernel.memberId()],
      enabled: true,
    };
    const onChange = vi.fn();
    health.onChange(onChange);
    await health.putAlertRule(rule);
    await health.putAlertRule({ ...rule, enabled: false, threshold: 150 });
    expect(onChange).toHaveBeenCalled();
    const rules = await health.alertRules(kernel.memberId());
    expect(rules).toHaveLength(1);
    expect(rules[0]).toMatchObject({ enabled: false, threshold: 150 });
  });

  it('evaluates vitals and generates alerts via onEnvelope', async () => {
    const rule: AlertRule = {
      kind: 'alert-rule',
      recordId: 'rule-1',
      owner: kernel.memberId(),
      updatedAt: Date.now(),
      subject: kernel.memberId(),
      vital: 'bp',
      comparator: '>',
      threshold: 160,
      useValue2: false,
      notify: [],
      enabled: true
    };
    await health.putAlertRule(rule);

    const onChange = vi.fn();
    health.onChange(onChange);

    const vital: VitalReading = {
      kind: 'vital',
      recordId: 'vital-1',
      owner: kernel.memberId(),
      updatedAt: Date.now(),
      type: 'bp',
      value: 170, // > 160
      value2: 90,
      unit: 'mmHg',
      at: Date.now()
    };

    const env = await kernel.seal({
      category: 'vitals',
      plaintext: vital
    });

    await kernel.publish(env);
    await new Promise(r => setTimeout(r, 10));

    const alerts = await health.alerts();
    expect(alerts).toHaveLength(1);
    expect(alerts[0].ruleId).toBe('rule-1');
    expect(alerts[0].severity).toBe('warning');
    expect(alerts[0].acknowledgedBy).toBeUndefined();
    expect(onChange).toHaveBeenCalled();
  });

  it('evaluates vitals and generates alerts via local records.onChange', async () => {
    const rule: AlertRule = {
      kind: 'alert-rule',
      recordId: 'rule-local',
      owner: kernel.memberId(),
      updatedAt: Date.now(),
      subject: kernel.memberId(),
      vital: 'bp',
      comparator: '>',
      threshold: 160,
      useValue2: false,
      notify: [],
      enabled: true
    };
    await health.putAlertRule(rule);

    const onChange = vi.fn();
    health.onChange(onChange);

    const vital: VitalReading = {
      kind: 'vital',
      recordId: 'vital-local',
      owner: kernel.memberId(),
      updatedAt: Date.now(),
      type: 'bp',
      value: 185, // > 180 (critical)
      value2: 90,
      unit: 'mmHg',
      at: Date.now()
    };

    (recordsMock.list as any).mockResolvedValue([vital]);
    onRecordsChangeCb(); // Trigger local change

    await new Promise(r => setTimeout(r, 10));

    const alerts = await health.alerts();
    expect(alerts).toHaveLength(1);
    expect(alerts[0].ruleId).toBe('rule-local');
    expect(alerts[0].severity).toBe('critical');
    expect(onChange).toHaveBeenCalled();
  });

  it('acknowledges an alert', async () => {
    const rule: AlertRule = {
      kind: 'alert-rule',
      recordId: 'rule-2',
      owner: kernel.memberId(),
      updatedAt: Date.now(),
      subject: kernel.memberId(),
      vital: 'glucose',
      comparator: '<',
      threshold: 70,
      notify: [],
      enabled: true
    };
    await health.putAlertRule(rule);

    const vital: VitalReading = {
      kind: 'vital',
      recordId: 'vital-2',
      owner: kernel.memberId(),
      updatedAt: Date.now(),
      type: 'glucose',
      value: 50,
      unit: 'mg/dL',
      at: Date.now()
    };

    const env = await kernel.seal({
      category: 'vitals',
      plaintext: vital
    });

    await kernel.publish(env);
    await new Promise(r => setTimeout(r, 10));

    let alerts = await health.alerts();
    expect(alerts).toHaveLength(1);
    const alertId = alerts[0].alertId;

    await health.acknowledge(alertId);

    alerts = await health.alerts();
    expect(alerts[0].acknowledgedBy).toBe(kernel.memberId());
  });
});
