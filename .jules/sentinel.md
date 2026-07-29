## 2024-07-29 - IDOR Vulnerability in FHIR Endpoint
**Vulnerability:** The `GET /api/fhir/patient/:id` endpoint in `backend/src/server.js` lacked authorization checks, allowing any authenticated user to retrieve sensitive patient records belonging to other users by modifying the `:id` parameter.
**Learning:** This occurred because the endpoint only verified that a valid `tokenData` existed in the session, but failed to cross-reference the requested `id` parameter with the authenticated user's ID (`tokenData.patient`).
**Prevention:** Always implement explicit authorization checks on endpoints that serve parameterized resources. Verify that the requested resource identifier matches the authenticated user's context or permissions.

## 2024-07-29 - Sensitive Data Exposure in Error Responses
**Vulnerability:** Multiple endpoints in `backend/src/server.js` (e.g., `/api/auth/ihce/callback`, `/api/fhir/patient/:id`, `/api/fhir/rda`, `/api/gmail/appointments`, `/api/outlook/appointments`) returned raw exception messages (`error.message` or `error.toString()`) directly to the client in HTTP 500 responses.
**Learning:** This pattern exposes internal system details, stack traces, or third-party service errors to potential attackers, which could aid in further exploitation.
**Prevention:** Implement secure error handling. Catch and log detailed errors on the server side (e.g., `console.error(error)`), but always return generic, non-descriptive error messages (e.g., 'An error occurred') to the client.