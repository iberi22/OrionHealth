Plan for [orion-a.10] feat(family): circle replication over Yjs with envelope validation

I will implement the circle sync module as described in the requirements and spec §8.

1.  **Implement `src-astro/src/lib/family/sync.ts`**
    *   Import dependencies: `* as Y from 'yjs'`, types from `../contracts/types.ts` and `../crypto/index.ts`.
    *   Create `circleRoom(ck0: Uint8Array): Promise<string>`: Derives room name: `b64u(hmac(ck0, utf8("orion/v1/room"))).slice(0, 22)`.
    *   Create `transportPassword(ck0: Uint8Array): Promise<string>`: Derives password: `b64u(hkdf(ck0, new Uint8Array(0), "orion/v1/transport"))`.
    *   Implement `createCircleReplica` function:
        *   Accepts `{ circleId, ck0, validate: (env: Envelope) => Promise<boolean>, persist?: boolean, connect?: boolean }`.
        *   Initializes `Y.Doc`.
        *   Creates a `Y.Map<Envelope>` named `env`.
        *   Registers an observer on `env` to validate incoming envelopes. If `validate(env)` is false, it drops the envelope from the map and calls an `onRejected` callback (which we can expose via an `onEnvelope` event or just a callback). Since the spec says "reported once through an `onRejected` callback", I will add an `onRejected?: (env: Envelope) => void` to the replica options.
        *   Handles persistence via `y-indexeddb` if `persist` is true. Uses IndexedDB `orion-circle-${circleId}`.
        *   Handles connection via `y-webrtc` if `connect` is true, lazily importing `WebrtcProvider` and connecting to `import.meta.env.PUBLIC_SIGNALING_URL || 'wss://signal.orionhealth.swal.network'`.
        *   Returns an object with methods:
            *   `add(env: Envelope): void`: Adds to the Y.Map.
            *   `all(): Envelope[]`: Returns all envelopes from the map.
            *   `byOwner(): Record<string, Envelope[]>`: Returns envelopes grouped by owner.
            *   `onEnvelope(cb: (env: Envelope) => void): () => void`: Registers a listener for new valid envelopes.
            *   `destroy(): void`: Destroys the doc, provider, and persistence.

2.  **Implement `src-astro/src/lib/family/sync.test.ts`**
    *   Use `vitest` and `fake-indexeddb/auto`.
    *   Test `circleRoom` and `transportPassword` logic.
    *   Test `createCircleReplica`:
        *   Test adding an envelope and reading it back.
        *   Test syncing two docs manually (with `connect: false` and `Y.encodeStateAsUpdate` / `Y.applyUpdate`).
        *   Test validation hook dropping an invalid envelope during sync and keeping a valid one.
        *   Test `byOwner` grouping.
        *   Test persistence to indexeddb.

3. **Execute tests and lint**
   * Run `pnpm vitest run src/lib/family/sync.test.ts`.
   * Run `pnpm run check`.

4. **Complete Pre-Commit Steps**
   * Run the `pre_commit_instructions` tool to perform required tests, verification, review, and reflection.

5. **Submit PR**
   * Create PR against `feat/orion-web`.
