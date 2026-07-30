## 2025-07-19 - Hardcoded API Key and secrets found
**Vulnerability:** Found hardcoded sandbox API key `sandboxApiKey = '9ffb7a49797e459bab116c6f2029cae6'` in `IhceApiClient`. Found hardcoded client secret `_sandboxClientSecret = 'fhir-secret'`. Also found a hardcoded `_sessionKey = 'orion_ble_session_static_key_v1'` and salt `'orion_health_salt_v1'` in `EncryptionService`.
**Learning:** Hardcoding credentials in source code (especially dart/flutter which can be decompiled) is a critical security vulnerability and violates best practices, allowing attackers to extract credentials and compromise external systems. Hardcoding encryption keys renders the encryption useless against targeted attacks.
**Prevention:** Use `--dart-define` for build-time environment variables in Flutter and retrieve using `String.fromEnvironment`. Or use a `.env` file via `flutter_dotenv` package.
## 2024-07-23 - Prevent IDOR in Patient FHIR Endpoints
**Vulnerability:** The `/api/fhir/patient/:id` endpoint lacked an authorization check, allowing any authenticated user to retrieve arbitrary patient records by guessing the `:id` parameter (Insecure Direct Object Reference).
**Learning:** In patient-facing FHIR gateway architectures, trusting the `:id` path parameter blindly is dangerous. The backend must cross-reference the requested resource ID against the authorized context embedded in the session/token (e.g., `req.session.tokenData.patient`).
**Prevention:** Always implement an explicit equality check (`id === tokenData.patient`) or rely strictly on the `/api/fhir/Patient/$me` logical endpoint pattern if the upstream FHIR server supports it. Ensure all new parameterized endpoints have explicit ownership validation.

## 2024-07-23 - Secure Express Session Secrets
**Vulnerability:** The `express-session` middleware was configured with a guessable, hardcoded fallback secret (`'ihce-gateway-secret'`).
**Learning:** Hardcoded session secrets allow attackers to forge session cookies and impersonate arbitrary users, bypassing authentication entirely. Relying solely on `process.env` without a secure cryptographic fallback is risky for local development or misconfigured environments.
**Prevention:** Always use `require('crypto').randomBytes(32).toString('hex')` as the default fallback for session secrets if `process.env.SESSION_SECRET` is undefined, ensuring session forgery remains mathematically impossible even if the environment variable is forgotten.
