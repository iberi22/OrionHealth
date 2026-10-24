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

      const cleanup = () => {
        clearTimeout(timeoutId);
        unsub?.();
        conn.close();
      };

      const remainingTime = invite.e - now;
      timeoutId = setTimeout(() => {
        cleanup();
        reject(new InviteError('Invite has expired', 'INVITE_EXPIRED'));
      }, remainingTime);

      unsub = conn.onMessage(async (peerHello) => {
        cleanup();
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
