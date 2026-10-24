import type { CircleState, MembershipEvent, MembershipEventKind } from '../contracts/types';
import { canonical, sign } from '../crypto/index';

export async function signEvent(ev: Omit<MembershipEvent, 'sig'>, signPkcs8: string): Promise<MembershipEvent> {
  const sig = await sign(signPkcs8, canonical(ev, ['sig']));
  return { ...ev, sig };
}

export type VerifyFn = (ev: MembershipEvent) => Promise<boolean>;

export async function reduceMembership(
  circleId: string,
  events: MembershipEvent[],
  verifyFn: VerifyFn
): Promise<{ state: CircleState | null; rejected: { id: string; reason: string }[] }> {
  // Sort events by HLC then ID for compareHlc-compatible order
  const sorted = [...events].sort((a, b) => {
    if (a.hlc < b.hlc) return -1;
    if (a.hlc > b.hlc) return 1;
    if (a.id < b.id) return -1;
    if (a.id > b.id) return 1;
    return 0;
  });

  const rejected: { id: string; reason: string }[] = [];
  let state: CircleState | null = null;

  for (const ev of sorted) {
    if (ev.circle !== circleId) {
      rejected.push({ id: ev.id, reason: 'wrong-circle' });
      continue;
    }

    if (!(await verifyFn(ev))) {
      rejected.push({ id: ev.id, reason: 'invalid-signature' });
      continue;
    }

    if (ev.kind === 'create') {
      if (state) {
        rejected.push({ id: ev.id, reason: 'already-created' });
        continue;
      }
      if (!ev.signPub || !ev.boxPub || !ev.displayName || !ev.deviceId) {
        rejected.push({ id: ev.id, reason: 'missing-create-fields' });
        continue;
      }

      state = {
        circleId,
        name: 'Family Health', // Default name, or from somewhere?
        epoch: 1,
        members: {
          [ev.actor]: {
            memberId: ev.actor,
            displayName: ev.displayName,
            role: 'admin',
            signPub: ev.signPub,
            boxPub: ev.boxPub,
            devices: [ev.deviceId],
            guardianOf: [],
            dependent: false,
            removed: false
          }
        }
      };
      continue;
    }

    if (!state) {
      rejected.push({ id: ev.id, reason: 'circle-not-created' });
      continue;
    }

    const actor = state.members[ev.actor];
    if (!actor && ev.kind !== 'join-request') {
      rejected.push({ id: ev.id, reason: 'unknown-actor' });
      continue;
    }

    if (actor?.removed) {
      rejected.push({ id: ev.id, reason: 'actor-removed' });
      continue;
    }

    if (ev.kind === 'join-request') {
      // Valid event, but adds nothing until approved
      continue;
    } else if (ev.kind === 'approve') {
      if (!actor || actor.role !== 'admin') {
        rejected.push({ id: ev.id, reason: 'not-admin' });
        continue;
      }
      if (!ev.subject) {
        rejected.push({ id: ev.id, reason: 'missing-subject' });
        continue;
      }
      if (state.members[ev.subject]) {
        rejected.push({ id: ev.id, reason: 'already-member' });
        continue;
      }

      const isDependent = !ev.deviceId;

      if (!ev.signPub || !ev.boxPub || !ev.displayName) {
        rejected.push({ id: ev.id, reason: 'missing-approve-fields' });
        continue;
      }

      state.members[ev.subject] = {
        memberId: ev.subject,
        displayName: ev.displayName,
        role: ev.role || 'member',
        signPub: ev.signPub,
        boxPub: ev.boxPub,
        devices: isDependent ? [] : [ev.deviceId!],
        guardianOf: [],
        dependent: isDependent,
        removed: false
      };
    } else if (ev.kind === 'role') {
       if (!actor || actor.role !== 'admin') {
         rejected.push({ id: ev.id, reason: 'not-admin' });
         continue;
       }
       if (!ev.subject || !state.members[ev.subject] || !ev.role) {
         rejected.push({ id: ev.id, reason: 'invalid-role-target' });
         continue;
       }
       state.members[ev.subject].role = ev.role;
    } else if (ev.kind === 'guardian') {
      if (!ev.ref || !state.members[ev.ref] || !ev.subject || !state.members[ev.subject]) {
        rejected.push({ id: ev.id, reason: 'invalid-guardian-target' });
        continue;
      }
      const subjectMember = state.members[ev.subject];
      if (ev.actor !== ev.subject && (!subjectMember.dependent || actor.role !== 'admin')) {
         rejected.push({ id: ev.id, reason: 'not-authorized' });
         continue;
      }

      const guardian = state.members[ev.ref];
      if (!guardian.guardianOf.includes(ev.subject)) {
        guardian.guardianOf.push(ev.subject);
      }
    } else if (ev.kind === 'remove') {
      if (!actor || actor.role !== 'admin') {
         rejected.push({ id: ev.id, reason: 'not-admin' });
         continue;
      }
      if (!ev.subject || !state.members[ev.subject]) {
         rejected.push({ id: ev.id, reason: 'invalid-remove-target' });
         continue;
      }
      state.members[ev.subject].removed = true;
      state.epoch++;
    } else if (ev.kind === 'device-add') {
      if (!ev.subject || !state.members[ev.subject]) {
         rejected.push({ id: ev.id, reason: 'invalid-target' });
         continue;
      }
      if (ev.actor !== ev.subject && (!actor || actor.role !== 'admin')) {
        rejected.push({ id: ev.id, reason: 'not-authorized' });
        continue;
      }
      if (!ev.deviceId) {
         rejected.push({ id: ev.id, reason: 'missing-device' });
         continue;
      }
      if (!state.members[ev.subject].devices.includes(ev.deviceId)) {
        state.members[ev.subject].devices.push(ev.deviceId);
      }
    } else if (ev.kind === 'device-revoke') {
       if (!ev.subject || !state.members[ev.subject]) {
         rejected.push({ id: ev.id, reason: 'invalid-target' });
         continue;
      }
      if (ev.actor !== ev.subject && (!actor || actor.role !== 'admin')) {
        rejected.push({ id: ev.id, reason: 'not-authorized' });
        continue;
      }
      if (!ev.deviceId) {
         rejected.push({ id: ev.id, reason: 'missing-device' });
         continue;
      }
      state.members[ev.subject].devices = state.members[ev.subject].devices.filter(d => d !== ev.deviceId);
    }
  }

  return { state, rejected };
}

export function canActorDo(state: CircleState | null, actorId: string, kind: MembershipEventKind): boolean {
  if (!state) return kind === 'create' || kind === 'join-request';
  const actor = state.members[actorId];
  if (!actor || actor.removed) return kind === 'join-request';

  if (actor.role === 'admin') {
    return true; // Admins can do anything
  }

  return ['join-request', 'device-add', 'device-revoke', 'guardian'].includes(kind);
}
