import { describe, it, expect, beforeEach } from 'vitest';
import { handleMessage, type SignalingState, MAX_PAYLOAD_SIZE, MAX_TOPICS_PER_CONNECTION, MAX_CONNECTIONS_PER_TOPIC } from './protocol';

class MockWebSocket {
  sent: string[] = [];
  isClosed = false;
  closeCode?: number;
  closeReason?: string;
  attachment: any = {};

  // Implemented minimum WebSocket properties to satisfy type checks
  accept() {}
  addEventListener() {}
  removeEventListener() {}
  dispatchEvent(): boolean { return true; }
  readyState: number = 1;
  url: string = '';
  protocol: string = '';
  extensions: string = '';
  binaryType: 'blob' | 'arraybuffer' = 'arraybuffer';
  onclose: ((this: WebSocket, ev: CloseEvent) => any) | null = null;
  onerror: ((this: WebSocket, ev: Event) => any) | null = null;
  onmessage: ((this: WebSocket, ev: MessageEvent) => any) | null = null;
  onopen: ((this: WebSocket, ev: Event) => any) | null = null;
  bufferedAmount: number = 0;

  send(msg: string) {
    this.sent.push(msg);
  }

  close(code?: number, reason?: string) {
    this.isClosed = true;
    this.closeCode = code;
    this.closeReason = reason;
  }

  deserializeAttachment() {
    return this.attachment;
  }

  serializeAttachment(att: any) {
    this.attachment = att;
  }
}

describe('Signaling Protocol', () => {
  let state: SignalingState;
  let ws1: MockWebSocket;
  let ws2: MockWebSocket;

  beforeEach(() => {
    state = {
      topics: new Map(),
      connections: new Map()
    };
    ws1 = new MockWebSocket();
    ws2 = new MockWebSocket();
    state.connections.set(ws1 as unknown as WebSocket, new Set());
    state.connections.set(ws2 as unknown as WebSocket, new Set());
  });

  it('handles subscribe and updates attachment', () => {
    handleMessage(state, ws1 as unknown as WebSocket, JSON.stringify({ type: 'subscribe', topics: ['room1', 'room2'] }));

    expect(state.topics.get('room1')?.has(ws1 as unknown as WebSocket)).toBe(true);
    expect(state.topics.get('room2')?.has(ws1 as unknown as WebSocket)).toBe(true);
    expect(state.connections.get(ws1 as unknown as WebSocket)?.has('room1')).toBe(true);
    expect(state.connections.get(ws1 as unknown as WebSocket)?.has('room2')).toBe(true);

    expect(ws1.attachment.topics).toContain('room1');
    expect(ws1.attachment.topics).toContain('room2');
  });

  it('handles unsubscribe and updates attachment', () => {
    handleMessage(state, ws1 as unknown as WebSocket, JSON.stringify({ type: 'subscribe', topics: ['room1', 'room2'] }));
    handleMessage(state, ws1 as unknown as WebSocket, JSON.stringify({ type: 'unsubscribe', topics: ['room1'] }));

    expect(state.topics.has('room1')).toBe(false);
    expect(state.topics.get('room2')?.has(ws1 as unknown as WebSocket)).toBe(true);
    expect(state.connections.get(ws1 as unknown as WebSocket)?.has('room1')).toBe(false);

    expect(ws1.attachment.topics).not.toContain('room1');
    expect(ws1.attachment.topics).toContain('room2');
  });

  it('handles publish and broadcasts to OTHER subscribers only', () => {
    handleMessage(state, ws1 as unknown as WebSocket, JSON.stringify({ type: 'subscribe', topics: ['room1'] }));
    handleMessage(state, ws2 as unknown as WebSocket, JSON.stringify({ type: 'subscribe', topics: ['room1'] }));

    handleMessage(state, ws1 as unknown as WebSocket, JSON.stringify({ type: 'publish', topic: 'room1', data: 'hello' }));

    const expectedMsg = JSON.stringify({ type: 'publish', topic: 'room1', data: 'hello', clients: 2 });

    expect(ws1.sent).not.toContain(expectedMsg);
    expect(ws2.sent).toContain(expectedMsg);
  });

  it('enforces max payload size', () => {
    const largeMsg = 'a'.repeat(MAX_PAYLOAD_SIZE + 1);
    handleMessage(state, ws1 as unknown as WebSocket, largeMsg);

    expect(ws1.isClosed).toBe(true);
    expect(ws1.closeCode).toBe(1009);
  });

  it('enforces max topics per connection', () => {
    const topics = Array.from({ length: MAX_TOPICS_PER_CONNECTION + 5 }, (_, i) => `topic${i}`);

    handleMessage(state, ws1 as unknown as WebSocket, JSON.stringify({ type: 'subscribe', topics }));

    const ws1Topics = state.connections.get(ws1 as unknown as WebSocket)!;
    expect(ws1Topics.size).toBe(MAX_TOPICS_PER_CONNECTION);
  });

  it('enforces max connections per topic', () => {
    const wss = Array.from({ length: MAX_CONNECTIONS_PER_TOPIC + 5 }, () => new MockWebSocket());
    for (const ws of wss) {
      state.connections.set(ws as unknown as WebSocket, new Set());
      handleMessage(state, ws as unknown as WebSocket, JSON.stringify({ type: 'subscribe', topics: ['hot-topic'] }));
    }

    const topicSubs = state.topics.get('hot-topic')!;
    expect(topicSubs.size).toBe(MAX_CONNECTIONS_PER_TOPIC);
  });

  it('ignores invalid JSON', () => {
    handleMessage(state, ws1 as unknown as WebSocket, 'invalid-json');
    expect(ws1.sent.length).toBe(0);
    expect(ws1.isClosed).toBe(false);
  });

  it('ignores ping and pong messages (handled natively by DO auto-responses)', () => {
    handleMessage(state, ws1 as unknown as WebSocket, JSON.stringify({ type: 'ping' }));
    handleMessage(state, ws1 as unknown as WebSocket, JSON.stringify({ type: 'pong' }));
    expect(ws1.sent.length).toBe(0);
    expect(ws1.isClosed).toBe(false);
  });

  it('ignores valid JSON without correct type', () => {
    handleMessage(state, ws1 as unknown as WebSocket, JSON.stringify({ unknown: 'message' }));
    expect(ws1.sent.length).toBe(0);
  });
});
