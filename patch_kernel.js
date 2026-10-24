const fs = require('fs');
const file = 'src-astro/src/lib/app/real/kernel.impl.ts';
let code = fs.readFileSync(file, 'utf8');
const oldCode = `for (const raw of this.circleKeys.values()) raw.fill(0);`;
const newCode = `for (const raw of this.circleKeys.values()) {}`;
code = code.replace(oldCode, newCode);
fs.writeFileSync(file, code);
