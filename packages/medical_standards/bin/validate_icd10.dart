#!/usr/bin/env dart
/// Validates ICD-10 codes in the medical_standards package.
/// Checks for:
/// - Duplicate codes
/// - Correct format (letter + 2+ digits, optionally with decimal)

import 'dart:io';

void main() async {
  final icd10Codes = <String, Set<String>>{};

  // Pattern: Letter + 2+ digits, optionally with decimal
  final icd10Pattern = RegExp(r'^[A-Z]\d{2}(\.\d+)?$');

  final issues = <String>[];

  // Read icd10.dart
  final file = File('lib/icd10/icd10.dart');
  if (!await file.exists()) {
    print('ERROR: lib/icd10/icd10.dart not found');
    exit(1);
  }

  final content = await file.readAsString();

  // Extract all code values using regex
  final codePattern = RegExp(r"code:\s*'([^']+)'");
  final matches = codePattern.allMatches(content);

  for (final match in matches) {
    final code = match.group(1)!;

    // Validate format
    if (!icd10Pattern.hasMatch(code)) {
      issues.add('Invalid ICD-10 format: $code');
    }

    // Check for duplicates
    final existing = icd10Codes[code];
    if (existing != null) {
      issues.add('DUPLICATE ICD-10 code: $code (found in ${existing.join(", ")})');
    } else {
      icd10Codes[code] = {'lib/icd10/icd10.dart'};
    }
  }

  if (issues.isEmpty) {
    print('✓ All ICD-10 codes are valid and unique');
    print('  Total unique codes: ${icd10Codes.length}');
    exit(0);
  } else {
    print('✗ Found ${issues.length} ICD-10 validation issues:');
    for (final issue in issues) {
      print('  - $issue');
    }
    exit(1);
  }
}
