# tester-army/e2e Suite for OrionHealth Web

This directory contains the `@tester-army/e2e` suite for the Astro web frontend. It verifies a local build of this checkout (`local` target) and the live deployment (`live` target).

## Installation

Ensure you have `pnpm` installed and run from the `src-astro` directory:

```bash
pnpm install
```

## Build

The `local` target builds the checkout itself (see `e2e:serve`), so an explicit build is optional:

```bash
pnpm run build
```

## Run Tests

*   **Local Target:** builds and serves this checkout with the Cloudflare adapter's local `workerd` preview on `127.0.0.1`. No prior build and no Cloudflare credentials are needed: `CLOUDFLARE_VITE_FORCE_LOCAL=true` keeps every binding local instead of opening a remote connection.
    ```bash
    pnpm run e2e:ta
    ```
*   **Live Target:** runs only against the deployed live URL (defaults to `https://orionhealth-web.iberi22.workers.dev`).
    ```bash
    pnpm run e2e:ta:live
    ```

## Sandbox Test Run Results

| Journey                                                      | Local | Live |
| ------------------------------------------------------------ | ----- | ---- |
| home opens with its main heading and primary call to action  | Pass  | Pass |
| the AUI section renders                                      | Pass  | Pass |
| PWA manifest and service worker are served as real assets     | Pass  | Pass |
| the document declares its locale, theme color and manifest   | Pass  | Pass |
| unknown route shows a not-found page or redirects home        | Pass  | Pass |

*Note: the earlier local column failed because `astro preview` was probed on `127.0.0.1` while it only listened on `localhost`, because the `AI` binding opened a remote connection that needs a Cloudflare token, and because the `preview` command can exit before readiness while the run never checked the PWA responses. The `local` target now builds, serves on `127.0.0.1`, forces local bindings and asserts the real response bodies.*

### Not supported: theme / language switching

This demo ships no runtime theme or language switch: `ProBadge.svelte` is a static billing badge, and `Layout.astro` hard-codes `<html lang="es">` plus a single `theme-color`. The suite therefore checks the declared metadata (locale, PWA theme color, manifest link) instead of a switch. A switching journey needs a real switcher in the app first.

## Persona Charters for Bug Bash

1.  **The Tech-Savvy Patient:** I want to verify if the offline-first mode actually syncs my latest entered data when reconnecting so I can manage my health seamlessly on flights.
2.  **The Security Auditor:** I want to scrutinize the app's local-first architecture and make sure no PHI is ever stored in cloud workers or sent in error tracking.
3.  **The Elderly User:** I want to ensure the UI scale and color contrast meet accessibility standards since I struggle to read small text on my mobile screen.
4.  **The Impatient Professional:** I want to test how quickly the app loads its main interactive components and vital sign summaries under poor network conditions.
5.  **The International Traveler:** I want to check how the application behaves when switching time zones and attempting to load offline assets in different countries.
