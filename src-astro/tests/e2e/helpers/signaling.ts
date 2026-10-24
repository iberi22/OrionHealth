import { spawn, type ChildProcess } from 'node:child_process';
import net from 'node:net';
import path from 'node:path';

const PORT = 4444;

function portOpen(): Promise<boolean> {
  return new Promise((resolve) => {
    const s = net.connect(PORT, '127.0.0.1');
    s.once('connect', () => { s.destroy(); resolve(true); });
    s.once('error', () => resolve(false));
  });
}

let started: ChildProcess | null = null;

/**
 * Makes sure a local y-webrtc signaling server listens on port 4444 (the app is built with
 * PUBLIC_SIGNALING_URL=ws://localhost:4444). Several workers/specs share one server: if the port is
 * already served this returns null. The spawned server is killed when this worker exits.
 */
export async function startSignaling(): Promise<ChildProcess | null> {
  if (await portOpen()) return started;
  const serverPath = path.resolve(process.cwd(), 'node_modules/y-webrtc/bin/server.js');
  const server = spawn('node', [serverPath], { env: { ...process.env, PORT: String(PORT) }, stdio: 'ignore' });
  started = server;
  process.once('exit', () => server.kill());
  for (let i = 0; i < 50; i++) {
    if (await portOpen()) return server;
    await new Promise((r) => setTimeout(r, 100));
  }
  server.kill();
  throw new Error('signaling server did not start on port 4444');
}
