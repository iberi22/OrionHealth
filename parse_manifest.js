import fs from 'fs';
const data = fs.readFileSync('dist/server/manifest.json', 'utf8'); // or similar
console.log(data.slice(0, 100));
