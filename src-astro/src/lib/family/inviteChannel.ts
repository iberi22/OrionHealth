import { InviteError, computeSas, inviteRoom, type Invite } from './invite';

export interface InviteHello {
  signPub: string;
  boxPub: string;
  displayName: string;
  deviceId: string;
}

export interface InviteConnection {
  send(message: InviteHello): Promise<void>;
  onMessage(cb: (message: InviteHello) => void): () => void;
  close(): void;
}

export interface InviteTransport {
  join(roomId: string): Promise<InviteConnection>;
}

/** How long a side keeps the invite room open after the peer's hello arrived. */
export const CLOSE_GRACE_MS = 10_000;

export interface InviteResult {
  sas: string;
  peer: InviteHello;
}

export class InviteChannel {
  constructor(
    private transport: InviteTransport,
    private myHello: InviteHello
  ) {}

  async connect(invite: Invite, now = Date.now()): Promise<InviteResult> {
    if (now >= invite.e) {
      throw new InviteError('Invite has expired', 'INVITE_EXPIRED');
    }

    const roomId = await inviteRoom(invite.s);
    const conn = await this.transport.join(roomId);

    return new Promise<InviteResult>((resolve, reject) => {
      let timeoutId: ReturnType<typeof setTimeout>;
      let unsub: () => void;

      // After receiving the peer's hello we keep the connection open for a moment: the peer may not have
      // received ours yet, and closing at once can cut the sync that delivers it (both sides do this).
      const cleanup = (linger = false) => {
        clearTimeout(timeoutId);
        unsub?.();
        if (linger) setTimeout(() => conn.close(), CLOSE_GRACE_MS);
        else conn.close();
      };

      const remainingTime = invite.e - now;
      timeoutId = setTimeout(() => {
        cleanup();
        reject(new InviteError('Invite has expired', 'INVITE_EXPIRED'));
      }, remainingTime);

      unsub = conn.onMessage(async (peerHello) => {
        cleanup(true);
        try {
          const sas = await computeSas(invite.s, this.myHello.signPub, peerHello.signPub);
          resolve({ sas, peer: peerHello });
        } catch (e) {
          reject(e);
        }
      });

      conn.send(this.myHello).catch((e) => {
        cleanup();
        reject(e);
      });
    });
  }
}
