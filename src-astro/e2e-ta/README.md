# tester-army/e2e Suite for OrionHealth Web

This directory contains the `@tester-army/e2e` suite for the Astro web frontend. It verifies the live deployment (`live` target) and optionally a local build (`local` target).

## Installation
Ensure you have `pnpm` installed and run from the `src-astro` directory:
\`\`\`bash
pnpm install
\`\`\`

## Build
To build the application, run:
\`\`\`bash
pnpm run build
\`\`\`

## Run Tests
*   **Local Target:** Runs against `pnpm run preview` on a random port. Ensure you have built the app first.
    \`\`\`bash
    pnpm run e2e:ta
    \`\`\`
*   **Live Target:** Runs against the deployed live URL (defaults to `https://orionhealth-web.iberi22.workers.dev`).
    \`\`\`bash
    pnpm run e2e:ta:live --target live
    \`\`\`

## Sandbox Test Run Results

| Journey                                                       | Local | Live  |
| ------------------------------------------------------------- | ----- | ----- |
| home opens with its main heading and primary call to action   | Fail  | Pass  |
| the AUI section renders                                       | Fail  | Pass  |
| PWA manifest and service worker are served                    | Fail  | Pass  |
| language or theme switch changes the UI                       | Fail  | Pass  |
| unknown route shows a not-found page or redirects home        | Fail  | Pass  |

*Note: The local target failed during the sandbox run due to a Cloudflare API token requirement error from Wrangler in the non-interactive environment.*

## Persona Charters for Bug Bash

1.  **The Tech-Savvy Patient:** I want to verify if the offline-first mode actually syncs my latest entered data when reconnecting so I can manage my health seamlessly on flights.
2.  **The Security Auditor:** I want to scrutinize the app's local-first architecture and make sure no PHI is ever stored in cloud workers or sent in error tracking.
3.  **The Elderly User:** I want to ensure the UI scale and color contrast meet accessibility standards since I struggle to read small text on my mobile screen.
4.  **The Impatient Professional:** I want to test how quickly the app loads its main interactive components and vital sign summaries under poor network conditions.
5.  **The International Traveler:** I want to check how the application behaves when switching time zones and attempting to load offline assets in different countries.
