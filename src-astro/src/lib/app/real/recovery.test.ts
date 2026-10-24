import { describe, expect, it, vi } from 'vitest';
import { randomBytes } from '../../crypto/index';
import { createInvite, inviteUrl } from '../../family/invite';
import { RecoveryError } from '../../family/recovery';
import { formatCode, newRecoveryCode } from '../../vault/recoveryCode';
import { FakeKernel, FakeNetwork } from './kernel.fake';
import { createRecoveryService, type RecoverySession } from './recovery';

function stub(memberId: string | null, mrs: Uint8Array = randomBytes(32)) {
  const importMrs = vi.fn<RecoverySession['importMrs']>(async () => {});
  const session: RecoverySession = {
    withMrs: async (fn) => fn(mrs),
    importMrs,
    memberId: () => memberId,
    displayName: () => 'Ana',
  };
  return { session, importMrs, mrs };
}

async function setup() {
  const net = new FakeNetwork();
  const ck = randomBytes(32);
  const mk = async () => {
    const k = await FakeKernel.create({ network: net });
    k.addCircleKey(0, ck);
    return k;
  };
  const [ana, rosa, bruno, carla, anaNew] = [await mk(), await mk(), await mk(), await mk(), await mk()];
  FakeKernel.introduce(ana, rosa, bruno, carla, anaNew);
  const anaId = ana.memberId();
  const a = stub(anaId);
  const n = stub(anaId);
  const svc = {
    ana: createRecoveryService(ana, a.session),
    rosa: createRecoveryService(rosa, stub(rosa.memberId()).session),
    bruno: createRecoveryService(bruno, stub(bruno.memberId()).session),
    carla: createRecoveryService(carla, stub(carla.memberId()).session),
    anaNew: createRecoveryService(anaNew, n.session),
  };
  const policy = { threshold: 2, trustees: [rosa.memberId(), bruno.memberId(), carla.memberId()] };
  return { svc, policy, mrs: a.mrs, importMrs: n.importMrs, anaId };
}

const invite = () => inviteUrl(createInvite('circle-1'));

describe('RecoveryService', () => {
  it('round-trips the policy and returns null before one is set', async () => {
    const { svc, policy } = await setup();
    expect(await svc.ana.policy()).toBeNull();
    await svc.ana.setPolicy(policy);
    expect(await svc.ana.policy()).toEqual(policy);
    expect(await svc.rosa.policy()).toBeNull();
  });

  it('rejects threshold 1 of 3', async () => {
    const { svc, policy } = await setup();
    await expect(svc.ana.setPolicy({ ...policy, threshold: 1 })).rejects.toBeInstanceOf(RecoveryError);
    expect(await svc.ana.policy()).toBeNull();
  });

  it('does not recover with one approval of 2-of-3, and recovers the exact MRS with two', async () => {
    const { svc, policy, mrs, importMrs, anaId } = await setup();
    await svc.ana.setPolicy(policy);

    const { sas } = await svc.anaNew.startRecovery(invite());
    expect(sas).toMatch(/^\d{3} \d{3}$/);
    expect(svc.anaNew.progress()).toMatchObject({ step: 'awaiting-approvals', approvals: 0 });

    const pending = await svc.rosa.pendingRequests();
    expect(pending).toHaveLength(1);
    expect(pending[0]!.member.memberId).toBe(anaId);

    await svc.rosa.approve(pending[0]!.requestId);
    expect(await svc.rosa.pendingRequests()).toHaveLength(0);
    await vi.waitFor(() => expect(svc.anaNew.progress()).toMatchObject({ step: 'awaiting-approvals', approvals: 1, threshold: 2 }));
    expect(importMrs).not.toHaveBeenCalled();

    await svc.bruno.approve((await svc.bruno.pendingRequests())[0]!.requestId);
    await vi.waitFor(() => expect(svc.anaNew.progress().step).toBe('done'));
    expect(importMrs).toHaveBeenCalledTimes(1);
    expect(Array.from(importMrs.mock.calls[0]![0])).toEqual(Array.from(mrs));
  });

  it('recovers with the recovery code', async () => {
    const { svc, mrs, importMrs } = await setup();
    const code = await formatCode(newRecoveryCode());
    await svc.ana.publishCodeBlob(code);
    await svc.anaNew.recoverWithCode(code);
    expect(svc.anaNew.progress().step).toBe('done');
    expect(Array.from(importMrs.mock.calls[0]![0])).toEqual(Array.from(mrs));
  });

  it('fails with a wrong code and imports nothing', async () => {
    const { svc, importMrs } = await setup();
    await svc.ana.publishCodeBlob(await formatCode(newRecoveryCode()));
    const seen: string[] = [];
    svc.anaNew.onProgress((p) => seen.push(p.step));
    await svc.anaNew.recoverWithCode(await formatCode(newRecoveryCode()));
    expect(svc.anaNew.progress().step).toBe('failed');
    expect(svc.anaNew.progress().error).toBeTruthy();
    expect(seen).toContain('failed');
    expect(importMrs).not.toHaveBeenCalled();
  });

  it('fails when no code blob exists', async () => {
    const { svc } = await setup();
    await svc.anaNew.recoverWithCode(await formatCode(newRecoveryCode()));
    expect(svc.anaNew.progress().step).toBe('failed');
  });
});
