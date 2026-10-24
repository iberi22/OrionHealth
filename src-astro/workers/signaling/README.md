# orionhealth-signal

A standalone Cloudflare Worker that implements the y-webrtc signaling protocol on a Durable Object. It is used to bootstrap WebRTC mesh connections between peer devices in a circle.

## Protocol

This signaling server supports the standard `y-webrtc` signaling messages:
- `subscribe`: Clients send an array of opaque topic strings they wish to join.
- `unsubscribe`: Clients send an array of topics they wish to leave.
- `publish`: Clients broadcast arbitrary messages to all other connected peers in a given topic.
- `ping` / `pong`: Used to keep the WebSocket connection alive and detect dropped peers.

The server never stores or reads the contents of the payload messages.

## Limits

- Max 64 KB per message.
- Max 50 topics per connection.
- Max 100 connections per topic.
- Idle close after 60 seconds without a message.

## Manual Deploy

Deploying this worker must be done manually by an authorized repository owner with the necessary Cloudflare credentials.

```bash
cd workers/signaling
npx wrangler deploy
```
