import fs from 'node:fs/promises';
import path from 'node:path';

const wranglerConfigPath = path.join(process.cwd(), 'dist', 'server', 'wrangler.json');

function readArg(flag) {
  const i = process.argv.indexOf(flag);
  return i === -1 ? null : process.argv[i + 1] ?? null;
}
const target = readArg('--target') || 'production';
const workerNameOverride = readArg('--name');

function extractHostname(v) {
  if (!v || typeof v !== 'string') return null;
  try { const u = v.includes('://') ? new URL(v) : new URL(`https://${v}`); return u.hostname.replace(/\.$/, '').toLowerCase(); } catch { return v.replace(/^[a-z]+:\/\//i, '').split('/')[0].replace(/\.$/, '').toLowerCase(); }
}
function normalizeProductionRoutes(config) {
  const candidates = new Set();
  for (const r of config.routes ?? []) { const h = extractHostname(r?.pattern); if (h) candidates.add(h); }
  const publicSiteUrl = extractHostname(config?.vars?.PUBLIC_SITE_URL);
  if (publicSiteUrl) {
    candidates.add(publicSiteUrl);
    if (publicSiteUrl.split('.').length === 2 && !publicSiteUrl.startsWith('www.')) candidates.add(`www.${publicSiteUrl}`);
  }
  const zone = publicSiteUrl?.replace(/^www\./, '') ?? null;
  return [...candidates].sort().map(h => ({ pattern: `${h}/*`, zone_name: zone }));
}

async function main() {
  if (!['production', 'preview'].includes(target)) throw new Error(`Unsupported target "${target}"`);
  const raw = await fs.readFile(wranglerConfigPath, 'utf8');
  const config = JSON.parse(raw);
  delete config.legacy_env;
  if (workerNameOverride) config.name = workerNameOverride;
  if (target === 'preview') {
    delete config.route; delete config.routes; config.workers_dev = true;
  } else {
    const prodRoutes = normalizeProductionRoutes(config);
    if (prodRoutes.length === 0) {
      delete config.routes;
      config.workers_dev = true;
    } else {
      config.routes = prodRoutes;
      config.workers_dev = false;
    }
    config.vars = { ...(config.vars ?? {}), PUBLIC_API_BASE_URL: config.vars?.PUBLIC_API_BASE_URL ?? '/api' };
  }
  if (config.assets?.directory) config.assets.directory = config.assets.directory.replace(/\\/g, '/');
  if (Array.isArray(config.compatibility_flags) && config.compatibility_flags.includes('nodejs_compat_v2')) delete config.no_bundle;
  await fs.writeFile(wranglerConfigPath, `${JSON.stringify(config, null, 2)}\n`);
  const routes = Array.isArray(config.routes) ? config.routes.map(r => r.pattern).join(', ') : 'none';
  console.log(`[normalize-wrangler-config] target=${target} name=${config.name} publicSite=${config?.vars?.PUBLIC_SITE_URL ?? 'unset'} routes=${routes}`);
}
main().catch(e => { console.error('[normalize-wrangler-config] Failed'); console.error(e); process.exitCode = 1; });
