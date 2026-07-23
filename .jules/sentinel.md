## 2024-07-23 - Prevent IDOR in Patient FHIR Endpoints
**Vulnerability:** The `/api/fhir/patient/:id` endpoint lacked an authorization check, allowing any authenticated user to retrieve arbitrary patient records by guessing the `:id` parameter (Insecure Direct Object Reference).
**Learning:** In patient-facing FHIR gateway architectures, trusting the `:id` path parameter blindly is dangerous. The backend must cross-reference the requested resource ID against the authorized context embedded in the session/token (e.g., `req.session.tokenData.patient`).
**Prevention:** Always implement an explicit equality check (`id === tokenData.patient`) or rely strictly on the `/api/fhir/Patient/$me` logical endpoint pattern if the upstream FHIR server supports it. Ensure all new parameterized endpoints have explicit ownership validation.

## 2024-07-23 - Secure Express Session Secrets
**Vulnerability:** The `express-session` middleware was configured with a guessable, hardcoded fallback secret (`'ihce-gateway-secret'`).
**Learning:** Hardcoded session secrets allow attackers to forge session cookies and impersonate arbitrary users, bypassing authentication entirely. Relying solely on `process.env` without a secure cryptographic fallback is risky for local development or misconfigured environments.
**Prevention:** Always use `require('crypto').randomBytes(32).toString('hex')` as the default fallback for session secrets if `process.env.SESSION_SECRET` is undefined, ensuring session forgery remains mathematically impossible even if the environment variable is forgotten.
