#!/usr/bin/env dart
/// Validates that all medications have RxNorm codes in the medical_standards package.
/// Checks for:
/// - All medications have a non-empty RxNorm code
/// - No duplicate RxNorm codes

import 'dart:io';

void main() async {
  final issues = <String>[];
  final rxnormCodes = <String, Set<String>>{};

  final file = File('lib/medications/medications.dart');
  if (!await file.exists()) {
    print('ERROR: lib/medications/medications.dart not found');
    exit(1);
  }

  final content = await file.readAsString();

  // Extract all MedicationReference entries
  // Match pattern: static const MedicationReference name = MedicationReference(
  //   code: 'XXX',
  //   ...
  // );
  final medPattern = RegExp(
    r"static\s+const\s+MedicationReference\s+(\w+)\s*=\s*MedicationReference\s*\(\s*code:\s*'([^']+)'",
    multiLine: true,
  );

  final matches = medPattern.allMatches(content);

  if (matches.isEmpty) {
    print('WARNING: No medications found in lib/medications/medications.dart');
    exit(0);
  }

  for (final match in matches) {
    final medName = match.group(1)!;
    final code = match.group(2)!;

    // Check if code is empty or whitespace
    if (code.trim().isEmpty) {
      issues.add('Medication "$medName" has empty RxNorm code');
      continue;
    }

    // Check for duplicates
    final existing = rxnormCodes[code];
    if (existing != null) {
      existing.add(medName);
      issues.add('DUPLICATE RxNorm code: $code (medications: ${existing.join(", ")})');
    } else {
      rxnormCodes[code] = {medName};
    }
  }

  if (issues.isEmpty) {
    print('✓ All medications have valid RxNorm codes');
    print('  Total unique medications: ${rxnormCodes.length}');
    print('  Total unique RxNorm codes: ${rxnormCodes.length}');
    exit(0);
  } else {
    print('✗ Found ${issues.length} medication validation issues:');
    for (final issue in issues) {
      print('  - $issue');
    }
    exit(1);
  }
}
