#!/usr/bin/env node
/**
 * PR #112 Conflict Resolver
 * 
 * Strategy: Take E2EE additions from security-overhaul branch
 * while keeping base auth structure from main.
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const REPO_DIR = 'E:\\scripts-python\\orionhealth';

console.log('🔧 PR #112 Conflict Resolver\n');
console.log('Strategy: Take E2EE additions from security-overhaul branch\n');

// Files with conflicts
const conflictFiles = [
  'lib/features/auth/domain/auth_service.dart',
  'lib/features/auth/infrastructure/secure_storage_service.dart',
  'lib/features/auth/infrastructure/services/encryption_service.dart',
  'lib/features/ble_sharing/domain/ble_sharing_service.dart',
  'lib/features/health_sharing/infrastructure/ble_sharing_service.dart',
  'lib/features/health_sharing/infrastructure/wifi_direct_service.dart',
];

function resolveConflict(content) {
  // Pattern: <<<<<<< HEAD ... ======= ... >>>>>>> branch
  const parts = content.split(/^<<<<<<< HEAD/m);
  if (parts.length < 2) return content;
  
  let result = parts[0];
  
  for (let i = 1; i < parts.length; i++) {
    const chunk = parts[i];
    const sections = chunk.split(/^=======\s*$/m);
    
    if (sections.length >= 2) {
      const ourChange = sections[0];  // HEAD (main) changes
      const theirChange = sections[1].split(/^>>>>>>> /m)[0];  // security branch changes
      
      // Strategy: Take their (security) changes as they add E2EE
      // But keep our basic structure if theirs is empty
      const resolved = theirChange.trim() || ourChange.trim();
      result += resolved;
    } else {
      result += chunk;
    }
  }
  
  return result;
}

function processFile(filePath) {
  const fullPath = path.join(REPO_DIR, filePath);
  
  if (!fs.existsSync(fullPath)) {
    console.log(`❌ File not found: ${filePath}`);
    return false;
  }
  
  let content = fs.readFileSync(fullPath, 'utf8');
  
  if (!content.includes('<<<<<<< HEAD')) {
    console.log(`✅ No conflicts: ${filePath}`);
    return true;
  }
  
  console.log(`🔄 Resolving: ${filePath}`);
  
  const resolved = resolveConflict(content);
  fs.writeFileSync(fullPath, resolved);
  
  console.log(`✅ Resolved: ${filePath}`);
  return true;
}

// Process each file
console.log('Processing conflicts...\n');
let successCount = 0;
let failCount = 0;

for (const file of conflictFiles) {
  try {
    if (processFile(file)) {
      successCount++;
    } else {
      failCount++;
    }
  } catch (e) {
    console.log(`❌ Error: ${file} - ${e.message}`);
    failCount++;
  }
}

console.log(`\n📊 Results: ${successCount} resolved, ${failCount} failed`);

// If all resolved, add and commit
if (failCount === 0) {
  console.log('\n✅ All conflicts resolved!');
  console.log('Next steps:');
  console.log('1. flutter analyze');
  console.log('2. flutter test');
  console.log('3. git add -A');
  console.log('4. git commit -m "Merge PR #112: E2EE and SSI"');
  console.log('5. git push origin main');
} else {
  console.log('\n⚠️ Some conflicts could not be resolved');
  console.log('Manual resolution may be required');
}
