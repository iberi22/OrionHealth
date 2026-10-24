1. **Understand the problem**:
   - The validation of an envelope currently evaluates if a `Grant` is expired by comparing `grant.expiresAt > ctx.now`.
   - The task states: "Grant expiry is evaluated against the envelope time (`hlc` ms) instead of `now`".
   - The HLC string format is `<ms>-<counter>-<deviceId>`, so we need to extract the `ms` portion from `env.hlc` and use that for the check.
   - The task also states: "an author marked `removed` in the circle state is rejected with reason `author-removed`". Currently, in `validate.ts`, if `member.removed` is true, the reason returned is `author-not-member`. This needs to be changed to `author-removed`.

2. **Modify `src-astro/src/lib/family/validate.ts`**:
   - In `validateEnvelope`, we need to parse the `ms` from `env.hlc`.
   - The regex `/^(\d+)-/` can be used to extract the `ms` from the `hlc` string, similar to how it's done in `src-astro/src/lib/family/hlc.ts`. Let's use `parseInt(env.hlc.split('-')[0], 10)` to extract it.
   - Change the grant expiry check from `(g.expiresAt === undefined || g.expiresAt > ctx.now)` to `(g.expiresAt === undefined || g.expiresAt > envelopeMs)`.
   - Update the member check from:
     ```typescript
     if (!member || member.removed) {
       return { ok: false, reason: 'author-not-member' };
     }
     ```
     to:
     ```typescript
     if (!member) {
       return { ok: false, reason: 'author-not-member' };
     }
     if (member.removed) {
       return { ok: false, reason: 'author-removed' };
     }
     ```

3. **Modify `src-astro/src/lib/family/validate.test.ts`**:
   - Add a test or update existing tests to verify that `author-removed` is returned when `member.removed` is true.
   - Add a test to verify that the grant expiry uses the `hlc` time, not `now`. (Wait, the existing `rejects expired grant` test uses `now: 200`, `expiresAt: 100`, and `hlc: '0-0-d'`, which evaluates to `ms=0`. Currently, `0 < 100` so it would be valid at `hlc` time! Let's check.)
   - Currently, `rejects expired grant` test has:
     - `expiresAt: 100`
     - `hlc: '0-0-d'` -> `ms = 0`
     - `now: 200`
     If we change to use `hlc` time, the grant *will* be valid because `100 > 0`. We will need to update the test to make the `hlc` time greater than `100`, e.g., `hlc: '150-0-d'`. Or, we add a specific test for the `hlc` evaluation.
   - Let's update `rejects expired grant` test to have `envBase.hlc = '150-0-d'` so that it's expired at the time of the envelope, and we can keep `ctx.now = 0` or anything to prove it's using the envelope time.
   - Let's create a new test `accepts grant valid at hlc time but expired now` to ensure it uses `hlc`.
   - Let's update `rejects author not member at hlc` to `author-not-member` (already exists, but we should make sure the member is undefined, not removed).
   - Add a new test `rejects removed author`.

4. **Pre-commit and Mutation Check**:
   - Run vitest `pnpm vitest run src/lib/family/validate.test.ts`.
   - Verify 0 errors with `pnpm run check`.
   - Perform mutation check: Revert the mitigation (e.g., skip signature check or change `envelopeMs` back to `ctx.now`), run tests, ensure it fails, restore code.
   - Note the mutation and test failures in PR body.

5. **Submit**:
   - Commit and submit using `default_api:submit`.
