import type { Kernel } from './kernel';
import type { RecordsService } from '../../contracts/services';
import type { HealthRecord, PersonalCategory } from '../../contracts/types';
import { RECORD_CATEGORY, PERSONAL_CATEGORIES } from '../../contracts/types';

export function createRecordsService(kernel: Kernel): RecordsService {
  return {
    async list<K extends HealthRecord['kind']>(kind: K, owner?: string): Promise<Extract<HealthRecord, { kind: K }>[]> {
      const category = RECORD_CATEGORY[kind];
      const envs = await kernel.envelopes({ category, owner });

      const recordsById = new Map<string, { hlc: string; record: any }>();

      for (const env of envs) {
        try {
          const record = await kernel.open(env) as any;
          if (record && record.recordId) {
            const existing = recordsById.get(record.recordId);
            if (!existing || env.hlc > existing.hlc) {
              recordsById.set(record.recordId, { hlc: env.hlc, record });
            }
          }
        } catch (e: any) {
          if (e.code === 'LOCKED') throw e;
          console.warn(e.code);
        }
      }

      const result: any[] = [];
      for (const { record } of recordsById.values()) {
        if (!record.deleted && record.kind === kind) {
          result.push(record);
        }
      }

      return result;
    },

    async put(record: HealthRecord): Promise<void> {
      const category = RECORD_CATEGORY[record.kind];
      const env = await kernel.seal({
        category,
        owner: record.owner,
        plaintext: record,
      });
      await kernel.publish(env);
    },

    async remove(kind: HealthRecord['kind'], recordId: string): Promise<void> {
      const category = RECORD_CATEGORY[kind];
      const envs = await kernel.envelopes({ category });

      // Find the owner of this record id. We might need to decrypt it to know if it's the right one.
      // But actually, we only need to look at envelopes we can open, to figure out who owns it.
      // Wait, what if we can't open it? Then we can't remove it anyway.
      let owner: string | undefined;
      for (const env of envs) {
        try {
          const record = await kernel.open(env) as any;
          if (record && record.recordId === recordId) {
            owner = env.owner;
            break;
          }
        } catch (e: any) {
          if (e.code === 'LOCKED') throw e;
          console.warn(e.code);
        }
      }

      if (!owner) {
        // Record not found or we don't have access to it, just return.
        // We can't publish a tombstone if we don't know the owner.
        // If we don't know the owner, maybe we assume it's our own record?
        // Let's assume the user can only delete records they know about.
        return;
      }

      const env = await kernel.seal({
        category,
        owner,
        plaintext: { recordId, deleted: true, updatedAt: Date.now() },
      });
      await kernel.publish(env);
    },

    onChange(cb: () => void): () => void {
      return kernel.onEnvelope((env) => {
        if (PERSONAL_CATEGORIES.includes(env.category as PersonalCategory)) {
          cb();
        }
      });
    },
  };
}
