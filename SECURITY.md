# Security Policy

## Privacy-First Commitment

OrionHealth is a **local-first, offline-first** health data application. Your health data never leaves your device unencrypted. We do not operate cloud servers, track users, or collect telemetry. This security policy reflects our commitment to keeping your health data under your control.

---

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 0.7.x   | :white_check_mark: |
| 0.6.x   | :white_check_mark: |
| 0.5.x   | :x:                |
| < 0.5   | :x:                |

**Current version**: 0.7.0 (beta)

Users are strongly encouraged to always use the latest beta release. Critical security fixes will be backported to the most recent minor version only.

---

## Reporting a Vulnerability

We take the security of OrionHealth seriously. If you believe you have found a security vulnerability, please report it to us as described below.

### Where to Report

**Please report security vulnerabilities via one of the following channels:**

1. **GitHub Private Vulnerability Report** (preferred):  
   Navigate to [https://github.com/iberi22/OrionHealth/security/advisories](https://github.com/iberi22/OrionHealth/security/advisories) and click "New draft security advisory"

2. **Email**: `security@southwest-ai-labs.com`

### What to Include

Please provide the following information in your report:

- Type of issue (e.g., buffer overflow, SQL injection, cross-site scripting, etc.)
- Full paths of source file(s) related to the manifestation of the issue
- The location of the affected source code (tag/branch/commit or direct URL)
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

### What NOT to Include

- **Do not** post security vulnerabilities publicly on GitHub Issues, Discussions, or other public forums
- **Do not** include real health data in your report — use synthetic or anonymized examples

---

## Disclosure Policy

We follow a **coordinated disclosure** process:

1. **Report received**: We acknowledge receipt within **48 hours**
2. **Investigation**: We investigate and validate the report within **7 days**
3. **Fix development**: We develop and test a fix
4. **Release**: We release a patched version
5. **Public disclosure**: We publish a security advisory **90 days after the fix is released**

### Timeline

- **0–48 hours**: Acknowledgment of receipt
- **7 days**: Initial triage and validation
- **90 days**: Standard disclosure deadline after fix release

### Scope

#### What is covered:
- OrionHealth Flutter application (core app and all features)
- Isar database encryption and data-at-rest protection
- Authentication and identity management
- BLE/NFC/WiFi Direct health data sharing
- On-device AI (LLM inference, RAG pipeline)
- Health wallet and offline storage

#### What is NOT covered:
- Third-party dependencies (report these to their respective maintainers)
- Cloud services operated by third parties (we have no cloud infrastructure)
- Physical device security (lost/stolen devices, screen lock)
- Social engineering attacks targeting users
- Operating system-level vulnerabilities

#### Out of scope (low risk / by design):
- User intentionally sharing their device or credentials (social engineering)
- Physical access to an unlocked device (device security is the user's responsibility)
- Side-channel attacks requiring specialized hardware and physical proximity

---

## PGP Key

We accept encrypted vulnerability reports via PGP. Our security team's PGP key is available on request. Please email `security@southwest-ai-labs.com` to request the current key fingerprint.

---

## Responsible Disclosure

We kindly ask that:

- You give us a **reasonable amount of time** (up to 90 days) to fix the issue before public disclosure
- You **do not** exploit the vulnerability or cause harm to users
- You **act in good faith** to help us improve security for all OrionHealth users

We commit to:

- Responding promptly and professionally to all reports
- Keeping you informed of progress toward a fix
- Giving you credit for the discovery (unless you prefer to remain anonymous)
- Releasing fixes as quickly as possible

---

## Security Features

OrionHealth includes these security features by design:

| Feature | Description |
|---------|-------------|
| **Local-first storage** | All data stored on-device using Isar database — no cloud uploads |
| **Encrypted at rest** | Sensitive health data encrypted using platform-native encryption |
| **Zero telemetry** | No analytics, no tracking, no data collection |
| **No external network calls** | App functions fully offline without internet access |
| **Prompt anonymizer** | PII removal before any cloud API calls (when enabled) |
| **On-device AI** | Local LLM inference means health data never leaves your device |
| **BLE/NFC encryption** | Health data sharing uses encrypted peer-to-peer connections |

---

## Security Update Process

1. **Discovery**: Vulnerability reported or discovered internally
2. **Triage**: Assess severity, impact, and affected versions
3. **Fix**: Develop patch in a private fork or branch
4. **Review**: Internal code review and testing
5. **Release**: Publish patched version with advisory
6. **Notification**: GitHub Security Advisory + release notes

Users will be notified via GitHub Releases and, for critical issues, through a security advisory on the repository.

---

## Comments, Questions, or Suggestions

If you have questions about this security policy, please open a discussion in [GitHub Discussions](https://github.com/iberi22/OrionHealth/discussions) or email `support@southwest-ai-labs.com`.

---

**Last updated**: 2026-05-03
