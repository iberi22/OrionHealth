import { handleMessage, type SignalingState, IDLE_TIMEOUT_MS } from './protocol';

export interface Env {
  SIGNALING_ROOM: DurableObjectNamespace;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const upgradeHeader = request.headers.get('Upgrade');
    if (!upgradeHeader || upgradeHeader !== 'websocket') {
      return new Response('Expected Upgrade: websocket', { status: 426 });
    }

    const url = new URL(request.url);
    const roomName = url.pathname === '/' ? 'global' : url.pathname;
    const id = env.SIGNALING_ROOM.idFromName(roomName);
    const room = env.SIGNALING_ROOM.get(id);

    return room.fetch(request);
  }
};

export class SignalingRoom {
  private state: SignalingState;

  constructor(private stateDO: DurableObjectState, private env: Env) {
    this.state = {
      topics: new Map(),
      connections: new Map()
    };

    // Reconstruct state from hibernated websockets if waking up
    const websockets = this.stateDO.getWebSockets();
    for (const ws of websockets) {
      const attachment = ws.deserializeAttachment();
      if (attachment && Array.isArray(attachment.topics)) {
        const topicsSet = new Set<string>(attachment.topics);
        this.state.connections.set(ws, topicsSet);
        for (const topic of topicsSet) {
          let topicSubs = this.state.topics.get(topic);
          if (!topicSubs) {
            topicSubs = new Set();
            this.state.topics.set(topic, topicSubs);
          }
          topicSubs.add(ws);
        }
      } else {
        this.state.connections.set(ws, new Set());
      }
    }
  }

  async fetch(request: Request): Promise<Response> {
    const upgradeHeader = request.headers.get('Upgrade');
    if (!upgradeHeader || upgradeHeader !== 'websocket') {
      return new Response('Expected Upgrade: websocket', { status: 426 });
    }

    const pair = new WebSocketPair();
    const [client, server] = Object.values(pair);

    this.stateDO.acceptWebSocket(server);

    this.state.connections.set(server, new Set());

    server.serializeAttachment({ lastActive: Date.now(), topics: [] });

    this.scheduleIdleCheck();

    return new Response(null, {
      status: 101,
      webSocket: client,
    });
  }

  async webSocketMessage(ws: WebSocket, message: string | ArrayBuffer) {
    const attachment = ws.deserializeAttachment() || {};
    attachment.lastActive = Date.now();
    ws.serializeAttachment(attachment);

    let msgStr: string;
    if (typeof message === 'string') {
      msgStr = message;
    } else {
      msgStr = new TextDecoder().decode(message);
    }

    handleMessage(this.state, ws, msgStr);
  }

  async webSocketClose(ws: WebSocket, code: number, reason: string, wasClean: boolean) {
    this.cleanupWebSocket(ws);
  }

  async webSocketError(ws: WebSocket, error: unknown) {
    this.cleanupWebSocket(ws);
  }

  async alarm() {
    const now = Date.now();
    for (const ws of this.stateDO.getWebSockets()) {
      const attachment = ws.deserializeAttachment();
      if (attachment && typeof attachment.lastActive === 'number') {
        if (now - attachment.lastActive >= IDLE_TIMEOUT_MS) {
          ws.close(1011, 'Idle timeout');
          this.cleanupWebSocket(ws);
        }
      }
    }

    if (this.stateDO.getWebSockets().length > 0) {
      this.scheduleIdleCheck();
    }
  }

  private scheduleIdleCheck() {
    this.stateDO.storage.setAlarm(Date.now() + 10000);
  }

  private cleanupWebSocket(ws: WebSocket) {
    const subs = this.state.connections.get(ws);
    if (subs) {
      for (const topic of subs) {
        const topicSubs = this.state.topics.get(topic);
        if (topicSubs) {
          topicSubs.delete(ws);
          if (topicSubs.size === 0) {
            this.state.topics.delete(topic);
          }
        }
      }
      this.state.connections.delete(ws);
    }
  }
}
