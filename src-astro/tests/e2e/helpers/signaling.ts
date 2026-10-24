import { spawn, type ChildProcess } from 'node:child_process';
import path from 'node:path';

/**
 * Spawns a local y-webrtc signaling server on port 4444.
 * Resolves when the server is listening.
 * Returns the child process so it can be killed after tests.
 */
export async function startSignaling(): Promise<ChildProcess> {
  return new Promise((resolve, reject) => {
    const serverPath = path.resolve(process.cwd(), 'node_modules/y-webrtc/bin/server.js');

    const server = spawn('node', [serverPath], {
      env: { ...process.env, PORT: '4444' },
    });

    server.stdout.on('data', (data) => {
      const output = data.toString();
      if (output.includes('listening') || output.includes('running') || output.includes('4444')) {
        resolve(server);
      }
    });

    server.stderr.on('data', (data) => {
      // Ignore stderr unless it crashes
    });

    server.on('error', (err) => {
      reject(err);
    });

    server.on('exit', (code) => {
      if (code !== 0 && code !== null) {
        reject(new Error(`Signaling server exited with code ${code}`));
      }
    });

    // In case there is no stdout log but it starts successfully, add a fallback timeout
    setTimeout(() => {
        resolve(server);
    }, 2000);
  });
}
