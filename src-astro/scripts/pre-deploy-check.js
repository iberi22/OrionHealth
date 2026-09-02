import fs from 'node:fs/promises';
import path from 'node:path';

const repoRoot = process.cwd();
async function mustExist(p, name, failures) {
  try { await fs.access(p); console.log(`OK ${name}`); return true; } catch { console.error(`FAIL missing ${name}: ${p}`); failures.count++; return false; }
}
async function main() {
  const failures = { count: 0 };
  console.log('[pre-deploy-check] template checks');
  await mustExist(path.join(repoRoot, 'dist', 'server', 'wrangler.json'), 'dist/server/wrangler.json', failures);
  // SSR no genera dist/client/index.html — verificar dist/client existe y tiene assets
  try { await fs.access(path.join(repoRoot, 'dist', 'client')); console.log('OK dist/client (SSR)'); } catch { console.error('FAIL missing dist/client'); failures.count++; }
  // wrangler.json debe tener bindings SWAL_D1/SWAL_KV/SWAL_R2/AI si billing socio
  try {
    const w = JSON.parse(await fs.readFile(path.join(repoRoot, 'dist', 'server', 'wrangler.json'), 'utf8'));
    const has = (k) => !!w[k] || !!w.d1_databases?.some(d=>d.binding===k) || !!w.kv_namespaces?.some(d=>d.binding===k) || !!w.r2_buckets?.some(d=>d.binding===k);
    if (!has('SWAL_D1')) console.warn('WARN SWAL_D1 binding no encontrado en wrangler.json (billing socio requiere D1)');
    if (!has('SWAL_KV')) console.warn('WARN SWAL_KV binding no encontrado');
    if (!w.ai) console.warn('WARN AI binding no encontrado');
    console.log(`OK wrangler.json bindings check`);
  } catch (e) { console.error('FAIL wrangler.json parse', e); failures.count++; }
  // public assets: manifest + _astro
  await mustExist(path.join(repoRoot, 'public', 'manifest.json'), 'public/manifest.json', failures);
  // AUI whitelist check: src/lib/aui.ts debe existir
  await mustExist(path.join(repoRoot, 'src', 'lib', 'aui.ts'), 'src/lib/aui.ts', failures);
  await mustExist(path.join(repoRoot, 'src', 'lib', 'billing.ts'), 'src/lib/billing.ts', failures);
  if (failures.count>0) { console.error(`[pre-deploy-check] ${failures.count} FAIL`); process.exitCode=1; } else console.log('[pre-deploy-check] all OK');
}
main();
