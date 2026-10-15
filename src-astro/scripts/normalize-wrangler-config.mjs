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
// Rutas de produccion. Respeta el custom domain declarado en wrangler.toml:
// para un custom domain el formato canonico es { pattern = "host", custom_domain = true }
// (hostname exacto, SIN sufijo /* y SIN zone_name; la zona se resuelve en el deploy).
// Idempotente: volver a correrlo no pierde el custom domain, y si PUBLIC_SITE_URL
// es un subdominio lo reintroduce aunque las rutas se hayan borrado antes
// (p.ej. `--target preview` seguido de `--target production`).
function normalizeProductionRoutes(config) {
  const out = [];
  const seen = new Set();
  for (const r of config.routes ?? []) {
    const host = extractHostname(r?.pattern);
    if (!host || seen.has(host)) continue;
    seen.add(host);
    if (r?.custom_domain) { out.push({ pattern: host, custom_domain: true }); continue; }
    const zone = r?.zone_name ?? null;
    out.push(zone ? { pattern: `${host}/*`, zone_name: zone } : { pattern: `${host}/*` });
  }
  const publicSiteUrl = extractHostname(config?.vars?.PUBLIC_SITE_URL);
  // Recupera el dominio publico como custom domain de Workers. Nunca deduce una
  // zona (zone_name) ni agrega www: solo se usan zonas declaradas explicitamente.
  if (publicSiteUrl && !seen.has(publicSiteUrl)) out.push({ pattern: publicSiteUrl, custom_domain: true });
  return out;
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
    } else {
      config.routes = prodRoutes;
    }
    // workers_dev explicito (wrangler.toml) manda: orionhealth-web lo mantiene
    // true para que orionhealth-web.iberi22.workers.dev siga respondiendo como
    // fallback/health-check ademas del custom domain.
    if (typeof config.workers_dev !== 'boolean') config.workers_dev = prodRoutes.length === 0;
    config.vars = { ...(config.vars ?? {}), PUBLIC_API_BASE_URL: config.vars?.PUBLIC_API_BASE_URL ?? '/api' };
  }
  if (config.assets?.directory) config.assets.directory = config.assets.directory.replace(/\\/g, '/');
  if (Array.isArray(config.compatibility_flags) && config.compatibility_flags.includes('nodejs_compat_v2')) delete config.no_bundle;
  await fs.writeFile(wranglerConfigPath, `${JSON.stringify(config, null, 2)}\n`);
  const routes = Array.isArray(config.routes) ? config.routes.map(r => `${r.pattern}${r.custom_domain ? ' (custom_domain)' : ''}`).join(', ') : 'none';
  console.log(`[normalize-wrangler-config] target=${target} name=${config.name} publicSite=${config?.vars?.PUBLIC_SITE_URL ?? 'unset'} workers_dev=${config.workers_dev} routes=${routes}`);
}
main().catch(e => { console.error('[normalize-wrangler-config] Failed'); console.error(e); process.exitCode = 1; });
