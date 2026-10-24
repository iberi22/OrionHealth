# Web vault and family health circle (spec v1)

Status: accepted 2026-10-23 · Scope: `src-astro/` (orionhealth.swal.network) · Contracts: `src-astro/src/lib/contracts/`

This is the single spec for every task of the web unification initiative. Code that disagrees with it is wrong;
a change to the protocol changes this file first.

## 1. Goals and non-goals

- Every byte of personal health data at rest (IndexedDB) and in transit (mesh) is ciphertext.
- Opening the data always requires a device user-verification gesture (fingerprint, face, pattern or device PIN)
  through a WebAuthn passkey with the PRF extension. There is no password path.
- A family can form a **circle**. Each member decides, per category, who can read or write their data.
  A member can name a **guardian** (acudiente) with full access, e.g. an elderly parent sharing everything with a child.
- Every circle device keeps a **blind replica** (ciphertext) of every member's data. Losing a phone loses nothing
  if a quorum of trustees approves the recovery.
- Members interact: shared health initiatives, habits, check-ins, alerts to guardians.
- Non-goals for v1: server-side storage of health data, TURN relays, Flutter interop (planned: same format in
  `packages/health_contract`), forward secrecy of past data after a revocation.

## 2. Building blocks

| Need | Choice |
|---|---|
| Device unlock, KEK, non-extractable custody | `@swal/vault/web` (`createVaultClient`, passkey PRF only, `wrapBytes`/`unwrapBytes`) |
| AEAD | WebCrypto AES-256-GCM, 12-byte random nonce, 16-byte tag |
| KDF | WebCrypto HKDF-SHA-256 |
| Signatures | WebCrypto ECDSA P-256 / SHA-256, raw 64-byte `r‖s` |
| Key agreement | WebCrypto ECDH P-256 |
| Secret sharing | `shamir-secret-sharing` (audited, GF(2^8)) |
| Replication | `yjs` + `y-webrtc` + `y-indexeddb` |
| Search | `minisearch` |
| Encoding | base64url without padding everywhere (`lib/crypto/encoding.ts`) |

No other crypto dependency is allowed.

## 3. Keys

| Key | Size | Lives | Derivation / storage |
|---|---|---|---|
| KEK | AES-256 | memory only | `@swal/vault/web` from passkey PRF; dropped on lock |
| MRS (member root secret) | 32 B random | wrapped by KEK in IndexedDB | one per person, never leaves the device in clear |
| MBK (member bundle key) | AES-256 | memory | `HKDF(ikm=MRS, salt=memberId, info="orion/v1/bundle")` |
| Member signing key | ECDSA P-256 | PKCS8 inside the member bundle | generated once per person |
| Member box key | ECDH P-256 | PKCS8 inside the member bundle | generated once per person |
| CEK[category, epoch] | 32 B random | inside the member bundle | one per category per epoch |
| Circle key CK[epoch] | 32 B random | wrapped per member (grant to each member) | created by the circle admin |

**Member bundle**: JSON `{ v:1, memberId, signPkcs8, boxPkcs8, ceks:{[category]:{[epoch]:b64}} }`, sealed with MBK
(AAD `orion/v1/bundle|<memberId>`) and published to the circle as an envelope of category `bundle`. Because the
bundle is replicated as ciphertext, recovering the 32-byte MRS recovers everything.

`memberId` = base64url(SHA-256(SPKI of the **member** signing public key, from the bundle))[0..22]. It never depends
on the device: `deviceId` comes from the `@swal/vault` device identity, `memberId` from the bundle, so a member
recovered on a new phone keeps the same `memberId`. Personal CEKs are created on first use (`rotateCategory`, first
epoch = 1) and the re-sealed bundle is re-published.

Storage: the vault session uses its own IndexedDB database `orion-meta` (MRS, bundle blob, recovery blob, metadata);
the envelope store uses `orion-vault`. Two modules never open the same database with different schemas.

## 4. Categories

`emergency`, `conditions`, `medications`, `allergies`, `vitals`, `documents`, `habits`, `nutrition`, `mental`,
`appointments` (personal, CEK per member) · `circle` (shared, key = CK) · `bundle`, `grant`, `membership`,
`recovery`, `alert` (protocol).

## 5. Envelope (the only thing that is stored or replicated)

```ts
interface Envelope {
  v: 1;
  id: string;          // 16 random bytes, b64url
  circle: string;      // circleId or "local"
  owner: string;       // memberId whose data this is
  author: string;      // memberId that wrote it (owner, or a grantee with write access)
  device: string;      // deviceId of the author device
  category: Category;
  epoch: number;       // key epoch used
  hlc: string;         // hybrid logical clock "<ms>-<counter>-<device>"
  nonce: string;       // 12 B
  ct: string;          // AES-GCM(key, plaintext JSON, aad)
  sig: string;         // ECDSA over canonical bytes of all fields except sig, by author
}
```

- AAD = UTF-8 of `orion/v1|${circle}|${owner}|${author}|${category}|${epoch}|${id}`.
- Canonical bytes = UTF-8 of `JSON.stringify` with keys sorted, `sig` removed.
- A receiver **rejects** (and never stores) an envelope whose signature fails, whose author is not a member at
  `hlc`, or whose author ≠ owner without a valid, unexpired write grant for that category at `hlc`.
- Edits are new envelopes with the same logical `recordId` inside the plaintext; last-writer-wins by `hlc`.
  Deletion is a tombstone plaintext `{recordId, deleted:true}`.

## 6. Grants (who can see what)

```ts
interface Grant {
  v: 1; id: string; circle: string;
  from: string;            // owner memberId
  to: string;              // grantee memberId
  category: Category; epoch: number;
  access: 'read' | 'write';
  expiresAt?: number;      // ms epoch; absent = until revoked
  ephPub: string;          // ephemeral ECDH P-256 SPKI
  wrapped: string;         // AES-GCM(HKDF(ECDH(eph, granteeBox), info="orion/v1/grant"), CEK), nonce prefixed
  sig: string;             // by `from`
}
```

- Presets: **Guardian (acudiente de primer nivel)** = every personal category, `write`, alerts on, trustee for
  recovery. **Caregiver** = emergency, medications, allergies, vitals, appointments, `read`. **Emergency only** =
  emergency, `read`. Custom = any set.
- **Revoke** = owner rotates the CEK of that category (epoch+1), re-encrypts nothing old, re-grants the new epoch to
  remaining grantees and publishes a signed `revoke` membership event. Data already seen by the revoked member
  cannot be unseen; the UI says so before confirming.
- Dependent profiles (child, or an elder without a phone) are owned by the member who created them, who holds
  their keys; the dependent can later be **handed over** to their own device (keys transferred, creator becomes
  guardian).

## 7. Circle and membership

- `circleId` = 16 random bytes. Membership is an append-only log of signed events:
  `create`, `invite`, `join-request`, `approve`, `role`, `guardian`, `remove`, `device-add`, `device-revoke`.
- **Authentication of the log.** The genesis is pinned: the `create` event must be signed by the admin whose
  `signPub` the joiner obtained through the SAS channel (§7 invite) — the reducer receives that `genesisActor` and
  ignores any other `create`, whatever its `hlc`. Every event is verified against the `signPub` registered for its
  actor in the state reduced so far; `create`, `approve` and `join-request` require `actor`/`subject` ==
  `memberIdFromSpki(signPub)`. A verifier that does not see the state is not acceptable.
- Roles: `admin` (approve, remove, rotate CK), `member`. Relations: `guardianOf` (set by the guarded member, or by the
  owner of a dependent profile).
- The current state is a pure reducer over the log (`lib/family/membership.ts`): invalid events are ignored, not
  thrown, and a test proves that reordering valid events yields the same state.
- Removing a member rotates CK and every member re-grants personal categories without the removed member.

### Invite with short authentication string (SAS)

1. Admin creates `inviteSecret` (32 B) and shows a QR / link `https://orionhealth.swal.network/app/join#<b64url>`.
   The fragment never reaches a server.
2. Both devices join the temporary room `HKDF(inviteSecret, info="orion/v1/invite-room")` and exchange signing and
   box public keys.
3. Both screens show a 6-digit SAS = `HKDF(inviteSecret ‖ sort(pubA, pubB), info="orion/v1/sas") mod 10^6`.
   The admin taps "match" only if the numbers are equal.
4. Admin publishes `approve` and a grant of CK to the new member.

## 8. Replication (mesh)

- One Yjs doc per circle. Room = b64url(HMAC-SHA-256(CK₀, "orion/v1/room"))[0..22]; `y-webrtc` `password` =
  b64url(HKDF(CK₀, info="orion/v1/transport")). CK₀ (the first epoch) stays the room secret so removed members
  keep no access to future keys, only to an unreadable room; on removal the admin migrates the circle to a new
  room derived from the new CK and the old room is abandoned.
- Y.Map `env` keyed by envelope id is **transport only**. The replica is the validated envelope store: a remote
  envelope is validated (§5) and only then written to the store; nothing is ever deleted from the `Y.Map` by a peer
  reaction, remote deletes and overwrites are ignored, and the device re-publishes the last valid envelope for that
  id. Envelopes are immutable by id (an edit is a new envelope); the store rejects a different envelope under an
  existing id (`ID_CONFLICT`). No `y-indexeddb`: persistence is the store. Every device keeps **all** valid envelopes
  of the circle, including categories it cannot read. That is the blind replica.
- Visible to circle devices without keys: owner, author, category, epoch, size, timestamps. Not visible: content.
- Signaling: own Worker `orionhealth-signal` at `wss://signal.orionhealth.swal.network` (`src-astro/workers/signaling/`,
  Durable Object implementing the y-webrtc signaling protocol, topics opaque, `PUBLIC_SIGNALING_URL` overrides).
  It never sees envelopes. Deploy is a separate owner-approved step.
- Without peers online the app keeps working locally; sync resumes when two circle devices meet.

## 9. Recovery (losing a phone)

Every recovery payload is a `recovery` envelope sealed with CK. A receiver uses a payload only when its author is
bound to it; anything else is ignored, never thrown:

| `kind` | Accepted only when |
|---|---|
| `policy`, `share`, `code-blob` | `env.author === env.owner === payload.member` (a member speaks only for themself) |
| `device-add-pending` | `env.author` is a current, non-removed **admin**, `env.author !== payload.member`, the temporary identity's signature over the request verifies, and it has not expired |
| `approval` | `env.author === payload.trusteeId`, the trustee is in the member's own `policy`, and the request id matches |

Bundles used to restore are the newest `bundle` envelope with `env.author === env.owner === memberId`.
The member publishes the current sealed bundle when it sets a trustee policy or publishes its code blob, so a
bundle created before the circle existed is still in the replica.

### 9.1 Recovery code

- On onboarding the member gets a **recovery code**: 32 random bytes RC as 54 Crockford base32 characters (52 + 2
  checksum) in 14 groups of 4 (the last one of 2), see `vault/recoveryCode.ts`. It wraps MRS
  (`AES-GCM(HKDF(RC, salt=memberId, info="orion/v1/recovery-code"), MRS)`, AAD `orion/v1/recovery|<memberId>`); the
  wrapped blob is stored locally (`orion/recovery-blob`).
- Next to the code the user is always offered an encrypted file `orion-recovery.json`
  (`{v:1, kind:"orion-recovery", memberId, blob, bundle}`: the code-wrapped MRS and the MBK-sealed bundle; nothing in
  it is readable without the code). `RecoveryService.recoveryFile()` regenerates it with the current bundle, so the
  app can offer it again later (planned in Settings).
- As soon as the member belongs to a circle the device publishes a `code-blob` envelope with the same blob (and the
  current bundle). Decision D4 (2026-10-24): the blob lives **in the circle replica and in the user's file**; there
  is no server copy.
- Recovery by code: code + file on an empty device recovers the identity and keys (same `memberId`); code alone works
  on the same browser (local blob) or on a new device that joined the circle through a recovery invitation (§9.3),
  which gives it the replica. A bundle from the replica is preferred over the one in the file (it is newer).

### 9.2 Trustees

- In a circle the member picks **trustees** and a threshold k (default 2 of 3, minimum 2; a single guardian may be
  1-of-1 only with an explicit warning). MRS is split with `shamir-secret-sharing`; share *i* is wrapped to trustee
  *i*'s box key like a grant and published as a `share` payload addressed to that trustee.
- k−1 shares reveal nothing; a test proves k−1 shares fail and k succeed.

### 9.3 Recovery invitation and new-device flow

A brand-new device has no bundle, no CK and no replica, so it cannot sign as the member or read the circle. An admin
lets it in with a **recovery invitation** for one named member:

1. Admin (≠ the member being recovered) runs `createRecoveryInvite(memberId)` and shares the link
   `…/app/recovery#<b64url({c, s, e, m})>` (`m` = memberId; the fragment never reaches a server).
2. The new device creates a **temporary identity** (ECDSA sign pair + ECDH box pair; `tempId =
   memberIdFromSpki(tempSignPub)`) and signs the request
   `canonical({v:1, kind:"recovery-request", circle, member, requestId, tempSignPub, tempBoxPub, deviceId})`.
   It joins the invite room (§7) with its temporary keys as the hello and the signed request in the hello payload.
3. Both screens show the SAS of §7 (bound to the temporary signing key). The admin taps "match" only if equal.
4. The admin publishes `device-add-pending{requestId, member, temp:{id, signPub, boxPub, deviceId}, requestSig, sas,
   expiresAt}`: the pending `device-add` of that temporary identity for the claimed member, vouched by the admin
   (= `env.author`). It then hands over, signed by the admin and wrapped to `tempBoxPub`
   (info `orion/v1/circle-key`, AAD `orion/v1|<circle>|recovery-key|<tempId>|<epoch>`), every CK epoch and the pinned
   genesis, on `<inviteRoom>.recovery`.
5. The new device runs the kernel in **guest mode**: with the CK it can receive, validate, store, relay and open circle
   envelopes, but it has no identity, so it can never seal or sign. The temporary identity signs only the request.
6. Each trustee sees the request with its real provenance: the claimed member, the temporary identity, the admin who
   vouched and the SAS. The trustee verifies the SAS with the member by call or in person, then approves; approval
   requires a fresh passkey re-authentication (`VaultSession.reauth()`, WebAuthn assertion with user verification)
   and re-wraps the share to `tempBoxPub` (AAD `orion/v1/recovery-request|<member>|<requestId>|<tempBoxPub>`).
   A request that is not bound to a valid `device-add-pending` is rejected.
7. The new device combines k approvals (from trustees of the member's own policy) → MRS → opens the member's bundle
   from the replica → registers a **new** passkey (a stale `passkeyCredId` on the device is discarded first) →
   leaves guest mode keeping the circle and CK → publishes `device-add` for itself and `device-revoke` for the
   member's other devices.

Residual risks: an admin and k trustees who all skip the out-of-band SAS check can hand a member's MRS to an
impostor; several pending requests for the same member must be treated as suspicious by the UI. The device only
trusts the admin whose key it saw in the SAS channel; before combining it checks that this admin is an admin of
the reduced circle.

## 10. Family health area

All of it is envelopes, so it is encrypted, replicated and permissioned like the rest.

| Feature | Category | Who reads |
|---|---|---|
| Initiatives (e.g. "30 days less sugar", walk 8k steps): goal, dates, participants | `circle` | all members |
| Check-ins and encouragement on an initiative | `circle` | all members |
| Personal habits (water, sleep, steps, meals) | `habits`, `nutrition` | owner + grantees |
| Habit summary shared to the circle (opt-in, aggregated) | `circle` | all members |
| Health levels (BP, glucose, weight, SpO2, HR) | `vitals` | owner + grantees |
| Alert rules (e.g. systolic > 160, glucose < 70, missed medication 24 h) | `alert` | owner + guardians |
| Guardian dashboard: latest vitals, medication adherence, open alerts of each guarded member | — | guardian (decrypts locally) |

Alert rules are evaluated on the device that writes the vital (owner or guardian) and again on each guardian
device when it syncs, so an alert still fires if the elder's phone goes offline after writing.

## 11. Onboarding (web /app)

1. What OrionHealth is and the privacy model in three screens (on-device, encrypted, you decide who sees what).
2. Passkey check (PRF). Without PRF: read-only mode (docs, knowledge base, assistant over public data), no saving.
3. Create passkey → vault created.
4. Recovery code shown once; the user must type back 3 random words.
5. Basic profile and Medical ID (optional).
6. Family: create a circle, join with an invite, or skip (can be done later).
7. Short tour of the app areas. Re-openable from Settings → "How it works".

## 12. Required tests (merge gate for the initiative)

- IndexedDB raw scan after seeding demo data contains no plaintext marker (`tests/e2e/vault-at-rest.spec.ts`).
- Tampered envelope (any field) → rejected. Wrong AAD → decrypt fails.
- Write by a non-grantee or with an expired grant → rejected by the receiver.
- Membership reducer: invalid events ignored; permutation of valid events → same state.
- Recovery: k−1 shares fail, k shares succeed; recovery code round-trip; an approval for a request not vouched by an
  admin is refused (the "harvest" attack); a fresh empty device recovers with 2 of 3 and with code + file.
- Revocation: revoked member cannot decrypt epoch+1 envelopes.
- Lock: after `lock()` or tab hidden for the timeout, no CEK or MRS reachable from the services.

## 13. Open risks

- Membership backdating: `hlc` is chosen by the author, so a removed member could sign events dated before their
  removal. v1 accepts this risk (removal also rotates CK and migrates the room, so such events reach nobody new);
  a causal DAG (`prev` hashes) is the planned fix.

- Metadata in §8 is visible to every circle device.
- WebRTC without TURN fails on some NATs; two devices on the same Wi-Fi always sync.
- PRF support varies by browser; read-only fallback is the answer, not a password.
- Social recovery depends on trustees acting honestly; k ≥ 2 by default for that reason.
