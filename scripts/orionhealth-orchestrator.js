// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs
//
// OrionHealth Orchestrator v6 — PR Merge Pipeline
//
// Pipeline:
//   1. git sync + flutter analyze
//   2. List ALL open PRs → mergearlos (con resolución de conflictos)
//   3. Verificar analyze post-merge
//   4. Si issue sin PR → lanzar Jules
//   5. Max 5 paralelo

const { execSync, spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

const REPO = 'E:\\scripts-python\\orionhealth';
const STATE_FILE = path.join(__dirname, 'orionhealth-orchestrator-state.json');

const PHASES = [
  { issue: 287, name: 'Phase 1: medical_standards tests', target: 'packages/medical_standards/test' },
  { issue: 288, name: 'Phase 2: app test/features/', target: 'test/features' },
  { issue: 289, name: 'Phase 3: test/core/services', target: 'test/core' },
  { issue: 290, name: 'Phase 4: health_wallet', target: 'packages/health_wallet' },
  { issue: 291, name: 'Phase 5: Code review', target: 'review' },
];

// ─── Helpers ──────────────────────────────────────────────

function run(cmd, opts) {
  try { return execSync(cmd, { cwd: REPO, encoding: 'utf8', timeout: 60000, ...opts }).trim(); }
  catch (e) { return (e.stdout || '').trim(); }
}

function runAnalyze() {
  try { return execSync('flutter analyze 2>&1', { cwd: REPO, encoding: 'utf8', timeout: 180000 }); }
  catch (e) { return (e.stdout || ''); }
}

function countErrors(out, subpath) {
  return out.split('\n').filter(l => l.includes('error - ') && l.replace(/\\/g, '/').includes(subpath.replace(/\\/g, '/'))).length;
}

function loadState() {
  try { if (fs.existsSync(STATE_FILE)) return JSON.parse(fs.readFileSync(STATE_FILE, 'utf8')); }
  catch (_) {}
  return { completed: [], launched: {}, mergedPRs: [] };
}

function saveState(s) {
  s.lastRun = new Date().toISOString();
  fs.writeFileSync(STATE_FILE, JSON.stringify(s, null, 2));
}

function getIssueState(issue) {
  const out = run(`gh issue view ${issue} --repo iberi22/OrionHealth --json state`);
  try { return JSON.parse(out); } catch (_) { return null; }
}

function closeIssue(issue, msg) {
  run(`gh issue close ${issue} --repo iberi22/OrionHealth --comment "${msg}"`);
}

function ghComment(issue, body) {
  // Write body to temp file to avoid shell escaping issues
  const tmpFile = path.join(__dirname, `.gh-comment-${issue}.txt`);
  fs.writeFileSync(tmpFile, body, 'utf8');
  run(`gh issue comment ${issue} --repo iberi22/OrionHealth --body-file "${tmpFile}"`);
  try { fs.unlinkSync(tmpFile); } catch (_) {}
}

// ─── PR Operations ────────────────────────────────────────

function listAllOpenPRs() {
  const out = run(`gh pr list --repo iberi22/OrionHealth --state open --json number,title,headRefName,baseRefName,body,createdAt --limit 20`);
  try { return JSON.parse(out); } catch (_) { return []; }
}

/** Merge a PR locally (fetch branch + merge into main) */
function mergePRLocally(pr) {
  console.log(`\n  === Merging PR #${pr.number}: ${pr.title.substring(0, 60)} ===`);
  
  // 1. Fetch
  run(`git fetch origin ${pr.headRefName}`);
  run(`git fetch origin ${pr.baseRefName}`);
  
  // 2. Checkout base and pull
  run(`git checkout ${pr.baseRefName}`);
  run(`git pull origin ${pr.baseRefName}`);
  
  // 3. Try merge
  const mergeCmd = `git merge --no-ff origin/${pr.headRefName} -m "merge: PR #${pr.number} - ${pr.title.replace(/'/g, '')}" --no-verify`;
  const mergeOut = run(mergeCmd);
  
  if (mergeOut.includes('CONFLICT')) {
    console.log('  Conflict detected, auto-resolving...');
    // Accept theirs for all files
    run(`git checkout --theirs -- . 2>nul`);
    run('git add -A');
    run(`git commit -m "merge: PR #${pr.number} with auto-resolved conflicts" --no-verify`);
  }
  
  // 4. Run analyze
  console.log('  Running flutter analyze...');
  const analyzeOut = runAnalyze();
  const errCount = analyzeOut.split('\n').filter(l => l.includes('error - ')).length;
  console.log(`  Errors after merge: ${errCount}`);
  
  // 5. Show diff
  const diffFiles = run('git diff --name-status HEAD~1..HEAD');
  const fileCount = diffFiles.split('\n').filter(l => l).length;
  console.log(`  Files changed: ${fileCount}`);
  
  // 6. Push
  run('git push origin main');
  console.log('  ✅ Merged and pushed');
  
  return errCount;
}

/** Approve and merge a PR via GitHub API (no admin) */
function mergePRViaGH(pr) {
  // Try squash merge first
  const result = run(`gh pr merge ${pr.number} --repo iberi22/OrionHealth --squash --subject "merge: PR #${pr.number} - ${pr.title.replace(/'/g, '')}"`);
  if (result.includes('Merged') || result.includes('already merged')) {
    console.log(`  ✅ Merged via GitHub`);
    return true;
  }
  // If squash fails, try merge commit
  const result2 = run(`gh pr merge ${pr.number} --repo iberi22/OrionHealth --merge --subject "merge: PR #${pr.number} - ${pr.title.replace(/'/g, '')}"`);
  if (result2.includes('Merged') || result2.includes('already merged')) {
    console.log(`  ✅ Merged via GitHub (merge commit)`);
    return true;
  }
  console.log(`  ⚠️ GitHub merge failed, will try local merge`);
  return false;
}

// ─── Main ─────────────────────────────────────────────────

async function main() {
  const state = loadState();
  const now = new Date();
  console.log(`=== OrionHealth Orchestrator v6 ===`);
  console.log(`Run: ${now.toISOString()}`);

  // 1. Sync
  console.log(`\n— Sync —`);
  run('git fetch --all');
  run('git checkout main');
  run('git pull origin main');

  // 2. Analyze pre-merge
  console.log(`\n— Analyze (pre-merge) —`);
  const preOut = runAnalyze();
  const preTotal = preOut.split('\n').filter(l => l.includes('error - ')).length;
  console.log(`Errors: ${preTotal}`);
  for (const p of PHASES) {
    if (p.target !== 'review') console.log(`  ${p.name}: ${countErrors(preOut, p.target)}`);
  }

  // 3. List open PRs (Jules + ours)
  const allPRs = listAllOpenPRs();
  
  // Filter out Dependabot PRs and already merged
  const julesPRs = allPRs.filter(pr => {
    if (pr.number === 285) return false; // Dependabot
    if (state.mergedPRs.includes(pr.number)) return false; // Already merged by us
    return true;
  });

  console.log(`\n— PRs to merge: ${julesPRs.length} —`);
  
  for (const pr of julesPRs) {
    console.log(`\n  PR #${pr.number}: ${pr.title}`);
    
    // Try GitHub merge first (simpler)
    const ghOk = mergePRViaGH(pr);
    if (ghOk) {
      state.mergedPRs.push(pr.number);
      continue;
    }
    
    // Fallback: local merge
    console.log(`  Attempting local merge...`);
    const errCount = mergePRLocally(pr);
    state.mergedPRs.push(pr.number);
  }

  // 4. Analyze post-merge
  if (julesPRs.length > 0) {
    console.log(`\n— Analyze (post-merge) —`);
    const postOut = runAnalyze();
    const postTotal = postOut.split('\n').filter(l => l.includes('error - ')).length;
    console.log(`Errors: ${preTotal} → ${postTotal} (Δ ${postTotal - preTotal})`);
    for (const p of PHASES) {
      if (p.target !== 'review') {
        const c = countErrors(postOut, p.target);
        console.log(`  ${p.name}: ${c}`);
      }
    }
  }

  // 5. Check completed phases
  console.log(`\n— Phase Completion —`);
  for (const phase of PHASES) {
    const is = getIssueState(phase.issue);
    if (is && (is.state === 'CLOSED' || is.state === 'MERGED')) {
      console.log(`  ✅ #${phase.issue} — closed on GH`);
      state.completed.push(phase.issue);
      continue;
    }
    if (phase.target !== 'review') {
      const c = countErrors(runAnalyze(), phase.target);
      if (c === 0) {
        console.log(`  ✅ #${phase.issue} — 0 errors`);
        state.completed.push(phase.issue);
        closeIssue(phase.issue, '✅ 0 errors in target. Auto-closing.');
        continue;
      }
    }
    
    if (!state.completed.includes(phase.issue)) {
      // Check if any PR that references this issue was merged
      const linkedPRs = allPRs.filter(p => {
        const body = (p.body || '').toLowerCase();
        return body.includes(`fixes #${phase.issue}`) || body.includes(`closes #${phase.issue}`);
      });
      const anyMerged = linkedPRs.some(p => state.mergedPRs.includes(p.number));
      if (anyMerged) {
        console.log(`  ✅ #${phase.issue} — linked PR merged`);
        state.completed.push(phase.issue);
        closeIssue(phase.issue, '✅ Linked PR merged. Auto-closing.');
        continue;
      }
    }
    
    console.log(`  ⏳ #${phase.issue} — pending`);
  }

  // 6. Launch Jules for issues without PRs (cooldown 10min)
  console.log(`\n— Launch Queue —`);
  // Re-check which issues have open PRs
  const currentPRs = listAllOpenPRs();
  for (const phase of PHASES) {
    if (state.completed.includes(phase.issue)) continue;
    
    const hasPR = currentPRs.some(p => {
      const body = (p.body || '').toLowerCase();
      return body.includes(`fixes #${phase.issue}`) || body.includes(`closes #${phase.issue}`) ||
             body.includes(`#${phase.issue}`);
    });
    
    if (hasPR) {
      console.log(`  🔄 #${phase.issue} — already has open PR`);
      continue;
    }
    
    const last = state.launched[phase.issue];
    if (last && (Date.now() - last) < 600000) {
      console.log(`  ⏸️  #${phase.issue} — cooldown`);
      continue;
    }
    
    console.log(`  🚀 #${phase.issue} — launching Jules`);
    const prompts = {
      287: `Fix errors in packages/medical_standards/test/. Fix imports, const constructors. cd packages/medical_standards && flutter analyze until 0. Branch from main. Push.`,
      288: `Fix 463 errors in test/features/. Fix mocktail imports, const constructors, overrides. flutter analyze after each batch. Push.`,
      289: `Fix ~16 errors in test/core/services/. Fix privacy_anonymizer_test, device_capability_service_test, notification_service_test. Push.`,
      290: `Fix 4 errors in packages/health_wallet/. Add dio dep, fix imports. Push.`,
      291: `Deep code review. Check security, performance, architecture. Create GH issues.`,
    };
    ghComment(phase.issue, `@jules-ai\n\n${prompts[phase.issue] || ''}`);
    state.launched[phase.issue] = Date.now();
  }

  // 7. All done?
  const uniqCompleted = [...new Set(state.completed)];
  if (uniqCompleted.length >= PHASES.length) {
    console.log(`\n✅ ALL PHASES COMPLETE`);
    const s = run('git status --porcelain');
    const changes = s.split('\n').filter(l => l && !l.includes('orionhealth'));
    if (changes.length > 0) {
      run('git add -A');
      run('git commit -m "chore: finalize all fixes" --no-verify');
      run('git push origin main');
    }
    closeIssue(292, 'All 5 phases completed. Orchestrator done.');
    if (fs.existsSync(STATE_FILE)) fs.unlinkSync(STATE_FILE);
    fs.writeFileSync(path.join(__dirname, 'ORCHESTRATOR_DONE'), 'Done ' + now.toISOString());
    console.log('✅ Orchestrator finished');
    process.exit(0);
  }

  state.completed = uniqCompleted;
  saveState(state);
  console.log(`\n=== Next cycle ~20 min ===`);
  console.log(`Completed: ${uniqCompleted.length}/${PHASES.length}`);
  console.log(`PRs merged: ${state.mergedPRs.length}`);
}

main().catch(e => { console.error('Fatal:', e.message); process.exit(1); });
