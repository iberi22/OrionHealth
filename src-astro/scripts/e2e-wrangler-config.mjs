import fs from 'fs';

const configPath = 'dist/server/wrangler.json';
const outPath = 'dist/server/wrangler.e2e.json';

const config = JSON.parse(fs.readFileSync(configPath, 'utf-8'));
if (config.ai) {
  delete config.ai;
}

fs.writeFileSync(outPath, JSON.stringify(config, null, 2));
