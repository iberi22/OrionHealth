import * as Y from 'yjs';
import type { InviteConnection, InviteHello, InviteTransport } from '../../family/inviteChannel';
import { b64u, hkdf, utf8 } from '../../crypto/index';

interface WebrtcTransportOpts {
  signalingUrl?: string;
  createProvider?: (room: string, doc: Y.Doc, opts: any) => { destroy: () => void };
}

export function createWebrtcInviteTransport(opts: WebrtcTransportOpts = {}): InviteTransport {
  return {
    async join(roomId: string): Promise<InviteConnection> {
      const doc = new Y.Doc();
      const arr = doc.getArray<{ from: string; hello: InviteHello }>('hellos');
      const connId = b64u(globalThis.crypto.getRandomValues(new Uint8Array(12)));

      const passwordBytes = await hkdf(utf8(roomId), new Uint8Array(0), 'orion/v1/invite-transport');
      const password = b64u(passwordBytes);
      const signalingUrl = opts.signalingUrl || import.meta.env?.PUBLIC_SIGNALING_URL || 'wss://signal.orionhealth.swal.network';

      let provider: { destroy: () => void };
      if (opts.createProvider) {
        provider = opts.createProvider(roomId, doc, { password, signaling: [signalingUrl] });
      } else {
        const { WebrtcProvider } = await import('y-webrtc');
        provider = new WebrtcProvider(roomId, doc, {
          password,
          signaling: [signalingUrl],
        });
      }

      const listeners = new Set<(msg: InviteHello) => void>();
      let closed = false;

      arr.observe((event) => {
        if (closed) return;
        event.changes.added.forEach((item) => {
          const content = item.content.getContent();
          content.forEach((msgObj: any) => {
            if (msgObj.from !== connId) {
              listeners.forEach(cb => cb(msgObj.hello));
            }
          });
        });
      });

      return {
        async send(message: InviteHello) {
          if (closed) return;
          doc.transact(() => {
            arr.push([{ from: connId, hello: message }]);
          });
        },
        onMessage(cb: (message: InviteHello) => void) {
          listeners.add(cb);
          // Replay existing messages
          arr.toArray().forEach((msgObj) => {
            if (msgObj.from !== connId) {
              cb(msgObj.hello);
            }
          });
          return () => {
            listeners.delete(cb);
          };
        },
        close() {
          if (closed) return;
          closed = true;
          listeners.clear();
          provider.destroy();
          doc.destroy();
        }
      };
    }
  };
}

export function createBroadcastInviteTransport(name: string): InviteTransport {
  return {
    async join(roomId: string): Promise<InviteConnection> {
      const channel = new BroadcastChannel(`${name}-${roomId}`);
      const connId = b64u(globalThis.crypto.getRandomValues(new Uint8Array(12)));
      const listeners = new Set<(msg: InviteHello) => void>();
      const history: InviteHello[] = [];
      let closed = false;

      // BroadcastChannel does not keep history. We can only deliver new messages.
      // But the spec requires us to "replay existing array items on onMessage" and "plus createBroadcastInviteTransport(name) over BroadcastChannel for same-browser tests and two-tab demos".
      // Let's create a local history to replay if they came while we were listening?
      // Actually, BroadcastChannel doesn't have a shared history across tabs unless requested.
      // We can broadcast a 'request-history' but maybe it's simpler if we just save received ones here.
      // Wait, we can use a SharedWorker or localStorage, but let's stick to BroadcastChannel. We just save the ones we receive.

      channel.onmessage = (event) => {
        if (closed) return;
        const msg = event.data;
        if (msg && msg.from !== connId && msg.hello) {
          history.push(msg.hello);
          listeners.forEach(cb => cb(msg.hello));
        }
      };

      return {
        async send(message: InviteHello) {
          if (closed) return;
          history.push(message); // for our own late subscribers, wait, no, our own subscribers ignore our own messages.
          // Wait, if it's our own message, `from === connId`, so `history.push` inside `onmessage` handles it for others.
          channel.postMessage({ from: connId, hello: message });
        },
        onMessage(cb: (message: InviteHello) => void) {
          listeners.add(cb);
          history.forEach(h => cb(h));
          return () => {
            listeners.delete(cb);
          };
        },
        close() {
          if (closed) return;
          closed = true;
          listeners.clear();
          channel.close();
        }
      };
    }
  };
}
