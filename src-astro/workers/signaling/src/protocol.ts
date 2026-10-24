export const MAX_PAYLOAD_SIZE = 64 * 1024; // 64 KB
export const MAX_TOPICS_PER_CONNECTION = 50;
export const MAX_CONNECTIONS_PER_TOPIC = 100;
export const IDLE_TIMEOUT_MS = 60 * 1000; // 60 s

// In a real Durable Object with hibernation, we can't keep in-memory state reliable.
// The connections and topics mapping must be derived from webSocket attachments or we need to update attachments.
// Actually, since we need to track topics across DO hibernation, we should serialize the topics a connection is subscribed to on the connection attachment.
// Then `state.topics` and `state.connections` can be reconstructed when waking up or we can just iterate over all websockets from `stateDO.getWebSockets()`
// Wait, the `handleMessage` function signature given in the instructions is `handleMessage(state: SignalingState, conn: WebSocket, msg: string)`
// It expects `SignalingState` to have topics and connections.
// If the memory is evicted, DO wakes up and `SignalingRoom` constructor is called, we can rebuild `SignalingState` by reading `ws.deserializeAttachment()` from all websockets.
// For now, let's fix the publish logic to NOT send to the sender.

export interface SignalingState {
  topics: Map<string, Set<WebSocket>>;
  connections: Map<WebSocket, Set<string>>;
}

export interface SubscribeMessage {
  type: 'subscribe';
  topics: string[];
}

export interface UnsubscribeMessage {
  type: 'unsubscribe';
  topics: string[];
}

export interface PublishMessage {
  type: 'publish';
  topic: string;
  data?: any; // any other properties that y-webrtc passes
  [key: string]: any;
}

export interface PingMessage {
  type: 'ping';
}

export interface PongMessage {
  type: 'pong';
}

export type SignalingMessage = SubscribeMessage | UnsubscribeMessage | PublishMessage | PingMessage | PongMessage;

export function handleMessage(state: SignalingState, conn: WebSocket, msgStr: string) {
  if (msgStr.length > MAX_PAYLOAD_SIZE) {
    conn.close(1009, 'Message too large');
    return;
  }

  let msg: SignalingMessage;
  try {
    msg = JSON.parse(msgStr);
  } catch (e) {
    // Ignore invalid JSON
    return;
  }

  if (!msg || typeof msg.type !== 'string') {
    return;
  }

  switch (msg.type) {
    case 'ping':
    case 'pong':
      // Handled natively by Durable Object WebSocket auto-responses or explicitly ignored here
      break;
    case 'subscribe': {
      if (!Array.isArray(msg.topics)) return;
      let myTopics = state.connections.get(conn);
      if (!myTopics) {
        myTopics = new Set();
        state.connections.set(conn, myTopics);
      }

      for (const topic of msg.topics) {
        if (typeof topic !== 'string') continue;

        if (myTopics.size >= MAX_TOPICS_PER_CONNECTION && !myTopics.has(topic)) {
          // Exceeds max topics per connection
          continue;
        }

        let topicSubs = state.topics.get(topic);
        if (!topicSubs) {
          topicSubs = new Set();
          state.topics.set(topic, topicSubs);
        }

        if (topicSubs.size >= MAX_CONNECTIONS_PER_TOPIC && !topicSubs.has(conn)) {
          // Exceeds max connections per topic
          continue;
        }

        topicSubs.add(conn);
        myTopics.add(topic);
      }

      // Update attachment for DO hibernation survival
      const attachment = conn.deserializeAttachment() || {};
      attachment.topics = Array.from(myTopics);
      conn.serializeAttachment(attachment);
      break;
    }
    case 'unsubscribe': {
      if (!Array.isArray(msg.topics)) return;
      const myTopics = state.connections.get(conn);
      if (!myTopics) return;

      for (const topic of msg.topics) {
        if (typeof topic !== 'string') continue;

        const topicSubs = state.topics.get(topic);
        if (topicSubs) {
          topicSubs.delete(conn);
          if (topicSubs.size === 0) {
            state.topics.delete(topic);
          }
        }
        myTopics.delete(topic);
      }

      // Update attachment for DO hibernation survival
      const attachment = conn.deserializeAttachment() || {};
      attachment.topics = Array.from(myTopics);
      conn.serializeAttachment(attachment);
      break;
    }
    case 'publish': {
      if (typeof msg.topic !== 'string') return;

      const receivers = state.topics.get(msg.topic);
      if (receivers) {
        msg.clients = receivers.size;
        const outStr = JSON.stringify(msg);

        for (const receiver of receivers) {
          if (receiver === conn) continue; // Do not send back to sender
          try {
            receiver.send(outStr);
          } catch (e) {
            // Error sending, will be cleaned up on close
          }
        }
      }
      break;
    }
  }
}
