#!/usr/bin/env dart
/// Validates SNOMED CT codes in the medical_standards package.
/// Checks for:
/// - Duplicate codes
/// - Valid format (numeric string)

import 'dart:io';

void main() async {
  final snomedCodes = <String, Set<String>>{};
  final issues = <String>[];

  // SNOMED CT codes are 6-18 digit numeric strings
  final snomedPattern = RegExp(r'^\d{6,18}$');

  final file = File('lib/snomed/snomed.dart');
  if (!await file.exists()) {
    print('ERROR: lib/snomed/snomed.dart not found');
    exit(1);
  }

  final content = await file.readAsString();

  // Extract all code values using regex
  final codePattern = RegExp(r"code:\s*'([^']+)'");
  final matches = codePattern.allMatches(content);

  for (final match in matches) {
    final code = match.group(1)!;

    // Validate format
    if (!snomedPattern.hasMatch(code)) {
      issues.add('Invalid SNOMED CT format: $code (expected 6-18 digit numeric string)');
    }

    // Check for duplicates
    final existing = snomedCodes[code];
    if (existing != null) {
      issues.add('DUPLICATE SNOMED CT code: $code (found in ${existing.join(", ")})');
    } else {
      snomedCodes[code] = {'lib/snomed/snomed.dart'};
    }
  }

  if (issues.isEmpty) {
    print('✓ All SNOMED CT codes are valid and unique');
    print('  Total unique codes: ${snomedCodes.length}');
    exit(0);
  } else {
    print('✗ Found ${issues.length} SNOMED CT validation issues:');
    for (final issue in issues) {
      print('  - $issue');
    }
    exit(1);
  }
}
