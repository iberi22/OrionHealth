# Architecture Decision: Self-Sovereign Identity (SSI) for OrionHealth

## Context
OrionHealth requires a decentralized, privacy-first identity system to manage medical records as Verifiable Credentials (VCs). This system must support:
- **Local-First**: Works without constant cloud connection.
- **Privacy-First**: Selective disclosure (Zero-Knowledge Proofs) to share only necessary data.
- **Interoperability**: Adherence to W3C DID and VC standards.

## Options Research

| Option | Pros | Cons | Medical Fit |
|--------|------|------|-------------|
| **Hyperledger Indy/Aries** | Mature, AnonCreds support (ZKP), purpose-built for SSI. | High complexity, heavy SDKs for mobile. | ⭐⭐⭐⭐⭐ (Best for privacy) |
| **Sidetree Protocol (ION)** | Highly scalable, Layer 2 (Bitcoin), supports long-form DIDs for offline use. | Limited native support for AnonCreds/ZKP out of the box. | ⭐⭐⭐⭐ (Best for scalability) |
| **Cheqd DID Method** | Focus on data monetization and payment, built on Cosmos. | Token-dependent for some operations. | ⭐⭐⭐ (Best for ecosystem incentives) |
| **Elixxir Trust Triangle** | Extreme metadata privacy (mixnet), quantum-resistant. | Higher latency, newer ecosystem for SSI. | ⭐⭐⭐⭐ (Best for anonymity) |

## Recommendation: Hybrid Aries + Sidetree Approach

OrionHealth will adopt a **Hybrid SSI Architecture**:

1. **Identity (DID)**: Use **Sidetree-inspired DIDs** (supporting Long-Form DIDs). This allows users to generate and use their identity immediately and offline without waiting for blockchain anchoring.
2. **Credentials (VC)**: Implement **Hyperledger Aries with AnonCreds**. This is critical for medical data, as it allows "Selective Disclosure" (e.g., proving you are over 18 without revealing your birth date, or proving vaccination status without revealing other medical history).
3. **Storage**: **Local-First Vault**. Credentials are stored in the `health_wallet` (Isar + AES-256) and synced P2P via the existing BLE/NFC protocol.

### Implementation Strategy for Flutter
- Use **Aries Framework JavaScript (AFJ)** via a background worker or a **Rust-based SSI SDK** (like `aries-askar` or `vade`) via FFI to maintain high performance and local-first capabilities.
- Implement a **DID Resolver** port in Dart to handle Sidetree long-form resolution.

## Complexity Estimate
- **Complexity**: 🔴 HIGH
- **Effort**: 3-5 months for full production implementation.
- **Risk**: Native SDK integration (Rust/C) in Flutter can be challenging for cross-platform stability.

## Implementation Issues Created
1. **[SSI-1] DID Generation & Long-Form Resolution**: Implement offline DID generation using Sidetree logic.
2. **[SSI-2] Verifiable Credential Schema for Medical Records**: Define AnonCreds-compatible schemas for common medical data (vitals, lab results).
3. **[SSI-3] Selective Disclosure UI**: Create a "Share Preview" screen where users can select which fields to share via ZKP.
