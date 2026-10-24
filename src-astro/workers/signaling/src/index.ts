import { handleMessage, type SignalingState, IDLE_TIMEOUT_MS } from './protocol';

export interface Env {
  SIGNALING_ROOM: DurableObjectNamespace;
  ORIGIN_ALLOWLIST?: string;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    if (env.ORIGIN_ALLOWLIST) {
      const origin = request.headers.get('Origin') || '';
      const allowedOrigins = env.ORIGIN_ALLOWLIST.split(',').map(s => s.trim());
      if (!allowedOrigins.includes(origin)) {
        return new Response('Forbidden', { status: 403 });
      }
    }

    const upgradeHeader = request.headers.get('Upgrade');
    if (!upgradeHeader || upgradeHeader !== 'websocket') {
      return new Response('Expected Upgrade: websocket', { status: 426 });
    }

    const url = new URL(request.url);
    const roomName = url.pathname;
    const prefix = roomName === '/' ? 'global' : roomName.substring(1).split('-')[0];
    const id = env.SIGNALING_ROOM.idFromName(prefix);
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

    this.stateDO.setWebSocketAutoResponse(
      new WebSocketRequestResponsePair(
        JSON.stringify({ type: 'ping' }),
        JSON.stringify({ type: 'pong' })
      )
    );

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

    if (this.stateDO.getWebSockets().length === 1) {
      this.stateDO.storage.setAlarm(Date.now() + 60000);
    }

    return new Response(null, {
      status: 101,
      webSocket: client,
    });
  }

  async webSocketMessage(ws: WebSocket, message: string | ArrayBuffer) {
    const attachment = ws.deserializeAttachment() || {};
    const now = Date.now();

    // Rate limit
    const timestamps = Array.isArray(attachment.msgTimestamps) ? attachment.msgTimestamps as number[] : [];
    const recent = timestamps.filter(t => now - t < 1000);
    recent.push(now);
    attachment.msgTimestamps = recent;

    if (recent.length > 50) {
      ws.close(1008, 'Rate limit exceeded');
      this.cleanupWebSocket(ws);
      return;
    }

    attachment.lastActive = now;
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
      this.stateDO.storage.setAlarm(Date.now() + 60000);
    }
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
