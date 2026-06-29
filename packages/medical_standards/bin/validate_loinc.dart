#!/usr/bin/env dart
// ignore_for_file: dangling_library_doc_comments
/// Validates LOINC codes in the medical_standards package.
/// Checks for:
/// - Duplicate codes
/// - Valid format (4-6 digits)

import 'dart:io';

// ignore_for_file: avoid_print

void main() async {
  final loincCodes = <String, Set<String>>{};
  final issues = <String>[];

  // LOINC codes are typically 4-6 digits, sometimes with hyphen (e.g., 718-7)
  final loincPattern = RegExp(r'^\d{4,6}(-\d+)?$');

  final file = File('lib/loinc/loinc.dart');
  if (!await file.exists()) {
    print('ERROR: lib/loinc/loinc.dart not found');
    exit(1);
  }

  final content = await file.readAsString();

  // Extract all code values using regex
  final codePattern = RegExp(r"code:\s*'([^']+)'");
  final matches = codePattern.allMatches(content);

  for (final match in matches) {
    final code = match.group(1)!;

    // Validate format
    if (!loincPattern.hasMatch(code)) {
      issues.add('Invalid LOINC format: $code (expected 4-6 digits, optionally with hyphen)');
    }

    // Check for duplicates
    final existing = loincCodes[code];
    if (existing != null) {
      issues.add('DUPLICATE LOINC code: $code (found in ${existing.join(", ")})');
    } else {
      loincCodes[code] = {'lib/loinc/loinc.dart'};
    }
  }

  if (issues.isEmpty) {
    print('✓ All LOINC codes are valid and unique');
    print('  Total unique codes: ${loincCodes.length}');
    exit(0);
  } else {
    print('✗ Found ${issues.length} LOINC validation issues:');
    for (final issue in issues) {
      print('  - $issue');
    }
    exit(1);
  }
}
