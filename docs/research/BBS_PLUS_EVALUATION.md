# Evaluation: BBS+ Signatures and BLS12-381 in Dart

## Objective
Evaluate the feasibility of implementing "True ZKP" (Zero-Knowledge Proofs) using BBS+ signatures and BLS12-381 curve in the OrionHealth Flutter application without relying on native Rust FFI (aries-askar).

## Findings

### 1. Library Analysis: `package:cryptography` (v2.9.0)
The current project uses the `cryptography` package for Ed25519 signatures. A thorough investigation of the package source and available documentation reveals:
- **No BLS12-381 Support**: The package does not implement the BLS12-381 elliptic curve.
- **No Pairing-Friendly Curves**: BBS+ signatures require pairing-friendly curves (like BLS12-381), which are not currently part of the `cryptography` package's feature set.
- **Algorithm Focus**: The package primarily focuses on standard algorithms like Ed25519, X25519, AES-GCM, and SHA-2.

### 2. Ecosystem Search
- No mature, null-safe pure Dart implementations of BBS+ signatures or BLS12-381 were found on `pub.dev`.
- Existing implementations of pairing-friendly cryptography in the Dart ecosystem are either abandoned, not null-safe, or require native bindings that contradict the requirement of avoiding Rust FFI for the current CI/CD environment.

## Security Risk in Current PoC
The initial PoC for `AnonCredsService` used raw SHA256 hashes as commitments for hidden fields:
`commitment = sha256(claimValue)`

**Vulnerability**: A malicious verifier can perform a dictionary attack or brute-force common values (e.g., vaccine names, blood types, test results) to deanonymize hidden claims, as medical data often has a limited range of possible values.

## Proposed Mitigation: Salted Commitments
To significantly increase the cost of brute-force attacks while maintaining a pure Dart implementation, we are transitioning to **Salted Cryptographic Commitments**:

`commitment = sha256(claimKey + ":" + claimValue + ":" + randomSalt)`

### Improvements:
- **Entropy**: Each claim has a unique 32-byte salt generated at issuance.
- **Privacy**: Salts for hidden fields are never shared with the verifier.
- **Selective Disclosure**: The holder only reveals the salt for fields they choose to disclose.
- **Integrity**: The issuer signs the full set of commitments, ensuring the holder cannot swap values or salts.

## Future Path
Once the native build environment (Rust FFI) is stabilized, the system should migrate to `aries-askar` for true CL-signatures and ZKP predicates. Salted commitments serve as a robust intermediate security layer.
