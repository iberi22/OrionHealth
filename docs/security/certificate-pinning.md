# Certificate Pinning in OrionHealth

OrionHealth uses certificate pinning (SHA-256 fingerprint of the certificate DER) to prevent Man-in-the-Middle (MitM) attacks. This ensures that the app only communicates with servers presenting a pre-verified certificate.

## Implementation Details

The implementation is located in `lib/core/network/http_client.dart` and integrated via `lib/core/di/network_module.dart`.

### Features
- **Forced HTTPS**: All external connections are forced to use HTTPS. Non-HTTPS requests are rejected by an interceptor.
- **SHA-256 Pinning**: The app verifies the SHA-256 fingerprint of the server's certificate.
- **Strict SSL**: Self-signed or invalid certificates are rejected by default, and pinning adds an extra layer of validation for critical endpoints.

## Pinned Domains and Fingerprints

| Domain | Fingerprint (SHA-256) | Notes |
|--------|-----------------------|-------|
| `api.orionhealth.app` | `REPLACE_WITH_PROD_PIN` | Production API (Update before release) |
| `ai.orionhealth.app` | `REPLACE_WITH_PROD_PIN` | AI Endpoints (Update before release) |
| `rxnav.nlm.nih.gov` | `bQPSf/wNwflh1ow7wbZNGpY22c5wGmfYpMBmiPL0uBU=` | NIH RxNorm API |
| `api.fda.gov` | `JjztvG35nefJZYq1xBvCEymtwk9Oi6Bzm40BWj4NpOA=` | FDA OpenData |
| `eutils.ncbi.nlm.nih.gov` | `yf0n/vkGMQzZEeZOzWgSUAtuNOhhbxJDRe9grC+FT9U=` | PubMed API |

## How to Obtain Fingerprints

To obtain the SHA-256 fingerprint of a server's certificate, use the following command:

```bash
openssl s_client -servername <DOMAIN> -connect <DOMAIN>:443 </dev/null 2>/dev/null | \
sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | \
openssl x509 -outform der | \
openssl dgst -sha256 -binary | \
openssl enc -base64
```

## Certificate Rotation

When certificates are rotated on the server, the app **must** be updated with the new fingerprints. Failure to do so will result in connection failures.

It is recommended to pin the **Intermediate CA** or include **Backup Pins** to prevent service interruption during rotation.

1. Obtain the new fingerprint using the command above.
2. Update the `_allowedPins` map in `lib/core/network/http_client.dart`.
3. Release a new version of the app.
