# Security Policy

## Reporting a Vulnerability

We take the security of OrionHealth and the privacy of our users seriously. If you believe you have found a security vulnerability, please report it to us by opening a private GitHub issue or contacting the maintainers directly.

## Security Guarantees

- **Local-First**: Your medical data never leaves your device unencrypted.
- **On-Device AI**: LLM inference is performed locally using ONNX runtime. No data is sent to external AI providers unless explicitly configured by the user (e.g., Gemini API).
- **Encryption**: We use AES-256-GCM for data at rest and in transit (P2P sharing).
- **Authentication**: Local access is protected by PIN and biometrics.

## Best Practices for Users

- Keep your device OS updated.
- Use a strong, unique PIN for OrionHealth.
- Regularly back up your encrypted data.
