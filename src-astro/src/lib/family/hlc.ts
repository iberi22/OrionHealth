export interface Hlc {
  now(): string;
  tick(): string;
  receive(remote: string): string;
}

function formatHlc(ms: number, counter: number, deviceId: string): string {
  const msStr = ms.toString().padStart(13, '0');
  const counterStr = counter.toString().padStart(4, '0');
  return `${msStr}-${counterStr}-${deviceId}`;
}

export function createHlc(deviceId: string, nowFn: () => number = Date.now): Hlc {
  let ms = nowFn();
  let counter = 0;

  const hlc: Hlc = {
    now: () => formatHlc(ms, counter, deviceId),
    tick: () => {
      const now = nowFn();
      if (now > ms) {
        ms = now;
        counter = 0;
      } else {
        // clock went backwards or tick in same ms
        counter++;
      }
      return formatHlc(ms, counter, deviceId);
    },
    receive: (remote: string) => {
      // "<ms>-<counter>-<deviceId>"; the device id may itself contain dashes.
      const m = /^(\d+)-(\d+)-(.+)$/.exec(remote);
      if (!m) {
        throw new Error('Invalid HLC format');
      }
      const remoteMs = parseInt(m[1]!, 10);
      const remoteCounter = parseInt(m[2]!, 10);

      const now = nowFn();

      if (now > ms && now > remoteMs) {
        ms = now;
        counter = 0;
      } else if (ms === remoteMs) {
        counter = Math.max(counter, remoteCounter) + 1;
      } else if (ms > remoteMs) {
        counter++;
      } else {
        ms = remoteMs;
        counter = remoteCounter + 1;
      }

      return formatHlc(ms, counter, deviceId);
    }
  };

  return hlc;
}

export function compareHlc(a: string, b: string): number {
  if (a === b) return 0;
  return a < b ? -1 : 1;
}
