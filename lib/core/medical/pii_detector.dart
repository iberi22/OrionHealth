// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2025 OrionHealth

import 'dart:math';
import 'pii_labels.dart';
import 'pii_entity.dart';

typedef PiiValidator = bool Function(String text);

class PiiPattern {
  final RegExp pattern;
  final String entityType;
  final int priority;
  final double baseScore;
  final double contextBoost;
  final List<String> contextWords;
  final PiiValidator? validator;
  final int? captureGroup;

  PiiPattern({
    required String pattern,
    required this.entityType,
    this.priority = 0,
    this.baseScore = 0.5,
    this.contextBoost = 0.35,
    this.contextWords = const [],
    this.validator,
    this.captureGroup,
    bool caseSensitive = false,
    bool multiLine = false,
  }) : pattern = RegExp(pattern, caseSensitive: caseSensitive, multiLine: multiLine);
}

/// Validation function for SSN
bool validateSsn(String ssnText) {
  final digits = ssnText.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length != 9) return false;

  final area = digits.substring(0, 3);
  final group = digits.substring(3, 5);
  final serial = digits.substring(5, 9);

  if (area == '000' || area == '666' || area.startsWith('9')) return false;
  if (group == '00') return false;
  if (serial == '0000') return false;

  return true;
}

/// Validation function for Luhn algorithm
bool validateLuhn(String numberText) {
  final digits = numberText.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length < 13) return false;

  int sum = 0;
  bool alternate = false;
  for (int i = digits.length - 1; i >= 0; i--) {
    int n = int.parse(digits[i]);
    if (alternate) {
      n *= 2;
      if (n > 9) n -= 9;
    }
    sum += n;
    alternate = !alternate;
  }
  return sum % 10 == 0;
}

/// Validation function for NPI
bool validateNpi(String npiText) {
  final digits = npiText.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length != 10) return false;

  // NPI uses Luhn with 80840 prefix
  final fullString = '80840$digits';
  int sum = 0;
  bool alternate = false;
  for (int i = fullString.length - 1; i >= 0; i--) {
    int n = int.parse(fullString[i]);
    if (alternate) {
      n *= 2;
      if (n > 9) n -= 9;
    }
    sum += n;
    alternate = !alternate;
  }
  return sum % 10 == 0;
}

/// Validation function for US phone numbers
bool validatePhoneUs(String phoneText) {
  final digits = phoneText.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length == 10) {
    final areaCode = digits.substring(0, 3);
    final exchange = digits.substring(3, 6);

    if (areaCode.startsWith('0') || areaCode.startsWith('1')) return false;
    if (exchange.startsWith('0')) return false;

    return true;
  } else if (digits.length == 11 && digits.startsWith('1')) {
    return validatePhoneUs(digits.substring(1));
  }
  return false;
}

final List<PiiPattern> defaultPiiPatterns = [
  // Dates
  PiiPattern(
    pattern: r'\b\d{4}-\d{2}-\d{2}\b',
    entityType: PiiLabel.date,
    priority: 10,
    baseScore: 0.6,
    contextBoost: 0.3,
    contextWords: ['dob', 'birth', 'born', 'date of birth', 'birthdate', 'deceased', 'died', 'admitted', 'discharged'],
  ),
  PiiPattern(
    pattern: r'\b\d{1,2}/\d{1,2}/\d{2,4}\b',
    entityType: PiiLabel.date,
    priority: 9,
    baseScore: 0.6,
    contextBoost: 0.3,
    contextWords: ['dob', 'birth', 'born', 'date of birth', 'birthdate', 'deceased', 'died', 'admitted', 'discharged'],
  ),
  PiiPattern(
    pattern: r'\b\d{1,2}-\d{1,2}-\d{2,4}\b',
    entityType: PiiLabel.date,
    priority: 9,
    baseScore: 0.6,
    contextBoost: 0.3,
    contextWords: ['dob', 'birth', 'born', 'date of birth', 'birthdate', 'deceased', 'died', 'admitted', 'discharged'],
  ),
  PiiPattern(
    pattern: r'\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]* \d{1,2},? \d{4}\b',
    entityType: PiiLabel.date,
    priority: 8,
    baseScore: 0.7,
    contextBoost: 0.25,
    contextWords: ['dob', 'birth', 'born', 'date of birth', 'birthdate', 'deceased', 'died', 'admitted', 'discharged'],
  ),
  PiiPattern(
    pattern: r'\b\d{1,2} (?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]* \d{4}\b',
    entityType: PiiLabel.date,
    priority: 8,
    baseScore: 0.7,
    contextBoost: 0.25,
    contextWords: ['dob', 'birth', 'born', 'date of birth', 'birthdate', 'deceased', 'died', 'admitted', 'discharged'],
  ),

  // SSN
  PiiPattern(
    pattern: r'\b\d{3}-\d{2}-\d{4}\b',
    entityType: PiiLabel.ssn,
    priority: 10,
    baseScore: 0.3,
    contextBoost: 0.55,
    contextWords: ['ssn', 'social security', 'social security number', 'ss#', 'ss number'],
    validator: validateSsn,
  ),
  PiiPattern(
    pattern: r'\b\d{3}\s\d{2}\s\d{4}\b',
    entityType: PiiLabel.ssn,
    priority: 9,
    baseScore: 0.3,
    contextBoost: 0.55,
    contextWords: ['ssn', 'social security', 'social security number', 'ss#', 'ss number'],
    validator: validateSsn,
  ),

  // Phone
  PiiPattern(
    // Note: no leading \b because '(' is not a word character
    pattern: r'\(\d{3}\)\s*\d{3}[-.\s]?\d{4}\b',
    entityType: PiiLabel.phoneNumber,
    priority: 9,
    baseScore: 0.6,
    contextBoost: 0.3,
    contextWords: ['phone', 'tel', 'telephone', 'cell', 'mobile', 'fax', 'call', 'contact'],
    validator: validatePhoneUs,
  ),
  PiiPattern(
    pattern: r'\b\d{3}[-.\s]\d{3}[-.\s]\d{4}\b',
    entityType: PiiLabel.phoneNumber,
    priority: 8,
    baseScore: 0.5,
    contextBoost: 0.35,
    contextWords: ['phone', 'tel', 'telephone', 'cell', 'mobile', 'fax', 'call', 'contact'],
    validator: validatePhoneUs,
  ),
  PiiPattern(
    pattern: r'\b\d{10}\b',
    entityType: PiiLabel.phoneNumber,
    priority: 5,
    baseScore: 0.2,
    contextBoost: 0.5,
    contextWords: ['phone', 'tel', 'telephone', 'cell', 'mobile', 'fax', 'call', 'contact'],
    validator: validatePhoneUs,
  ),

  // NPI
  PiiPattern(
    pattern: r'\b\d{10}\b',
    entityType: PiiLabel.npi,
    priority: 6,
    baseScore: 0.15,
    contextBoost: 0.65,
    contextWords: ['npi', 'national provider', 'provider number', 'provider id', 'provider identifier'],
    validator: validateNpi,
  ),
  PiiPattern(
    pattern: r'\bNPI\s*:?[\t ]*(\d{10})\b',
    entityType: PiiLabel.npi,
    priority: 14,
    captureGroup: 1,
    baseScore: 0.94,
    contextBoost: 0.03,
    contextWords: ['npi', 'national provider', 'provider number', 'provider id', 'provider identifier'],
  ),

  // Email
  PiiPattern(
    pattern: r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
    entityType: PiiLabel.email,
    priority: 10,
    baseScore: 0.9,
    contextBoost: 0.1,
    contextWords: ['email', 'e-mail', 'contact', 'mail'],
  ),

  // Zip codes
  PiiPattern(
    pattern: r'\b\d{5}(?:-\d{4})?\b',
    entityType: PiiLabel.postcode,
    priority: 7,
    baseScore: 0.4,
    contextBoost: 0.45,
    contextWords: ['zip', 'zipcode', 'zip code', 'postal', 'postal code'],
  ),

  // Credit card
  PiiPattern(
    pattern: r'\b\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}\b',
    entityType: PiiLabel.creditCard,
    priority: 8,
    baseScore: 0.4,
    contextBoost: 0.4,
    contextWords: ['card', 'credit', 'debit', 'visa', 'mastercard', 'amex', 'discover', 'payment'],
    validator: validateLuhn,
  ),

  // MRN
  PiiPattern(
    pattern: r'\b(?:MRN|mrn)[:\s#]*\d{6,10}\b',
    entityType: PiiLabel.mrn,
    priority: 9,
    baseScore: 0.8,
    contextBoost: 0.15,
    contextWords: ['medical record', 'patient id', 'patient number', 'record number'],
  ),
  PiiPattern(
    pattern: r'\b[A-Z]{2,3}\d{6,9}\b',
    entityType: PiiLabel.mrn,
    priority: 5,
    baseScore: 0.3,
    contextBoost: 0.5,
    contextWords: ['mrn', 'medical record', 'patient id', 'patient number', 'record number'],
  ),

  // Street Address
  PiiPattern(
    pattern: r'\b\d{1,5}\s+[A-Z][a-z]+(?:\s+[A-Z][a-z]+)*\s+(?:Street|St|Avenue|Ave|Road|Rd|Boulevard|Blvd|Lane|Ln|Drive|Dr|Court|Ct|Way)\b',
    entityType: PiiLabel.streetAddress,
    priority: 7,
    baseScore: 0.7,
    contextBoost: 0.2,
    contextWords: ['address', 'street', 'resides', 'residence', 'lives at', 'located at'],
  ),

  // URLs
  PiiPattern(
    pattern: r'\b(?:https?://)?(?:www\.)?[a-zA-Z0-9-]+\.[a-zA-Z]{2,}(?:/[^\s]*)?\b',
    entityType: PiiLabel.url,
    priority: 8,
    baseScore: 0.8,
    contextBoost: 0.15,
    contextWords: ['url', 'website', 'link', 'webpage'],
  ),

  // IP Addresses
  PiiPattern(
    pattern: r'\b(?:\d{1,3}\.){3}\d{1,3}\b',
    entityType: PiiLabel.ipv4,
    priority: 7,
    baseScore: 0.6,
    contextBoost: 0.3,
    contextWords: ['ip', 'ip address', 'address', 'server', 'host'],
  ),
  PiiPattern(
    pattern: r'\b(?:[0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}\b',
    entityType: PiiLabel.ipv6,
    priority: 8,
    baseScore: 0.85,
    contextBoost: 0.15,
    contextWords: ['ip', 'ipv6', 'ip address', 'address', 'server', 'host'],
  ),

  // MAC Addresses
  PiiPattern(
    pattern: r'\b(?:[0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}\b',
    entityType: PiiLabel.macAddress,
    priority: 8,
    baseScore: 0.75,
    contextBoost: 0.2,
    contextWords: ['mac', 'mac address', 'hardware address'],
  ),

  // Patient names (ported from OpenMedKit Swift)
  PiiPattern(
    pattern: r"\bPatient(?:\s+Name)?:\s*([A-Z][A-Za-z]+(?:[-'][A-Za-z]+)*,\s*[A-Z][A-Za-z]+(?:[-'][A-Za-z]+)*(?:[ \t]+(?:[A-Z]\.|[A-Z][A-Za-z]+(?:[-'][A-Za-z]+)*))*)" ,
    entityType: PiiLabel.fullName,
    priority: 15,
    captureGroup: 1,
    baseScore: 0.97,
    contextBoost: 0.02,
    contextWords: ["patient", "name"],
  ),
  PiiPattern(
    pattern: r"\bPatient:\s*([A-Z][A-Za-z]+(?:\s+[A-Z][A-Za-z]+)+)\b",
    entityType: PiiLabel.fullName,
    priority: 14,
    captureGroup: 1,
    baseScore: 0.96,
    contextBoost: 0.02,
    contextWords: ["patient", "name"],
  ),

  // Insurance ID
  PiiPattern(
    pattern: r'\bInsurance ID:\s*([A-Z0-9][A-Z0-9-]{4,})\b',
    entityType: PiiLabel.insuranceId,
    priority: 14,
    captureGroup: 1,
    baseScore: 0.95,
    contextBoost: 0.03,
    contextWords: ["insurance", "policy", "coverage", "payer"],
  ),

  // Driver License
  PiiPattern(
    pattern: r'\bDriver License:\s*([A-Z0-9][A-Z0-9-]{4,})\b',
    entityType: PiiLabel.driverLicense,
    priority: 14,
    captureGroup: 1,
    baseScore: 0.95,
    contextBoost: 0.03,
    contextWords: ["driver license", "license", "dl"],
  ),

  // Passport
  PiiPattern(
    pattern: r'\bPassport:\s*([A-Z0-9][A-Z0-9-]{4,})\b',
    entityType: PiiLabel.passportNumber,
    priority: 14,
    captureGroup: 1,
    baseScore: 0.95,
    contextBoost: 0.03,
    contextWords: ["passport", "travel document"],
  ),

  // Employer
  PiiPattern(
    pattern: r'\bEmployer:\s*([^,\n]+)',
    entityType: PiiLabel.organization,
    priority: 14,
    captureGroup: 1,
    baseScore: 0.93,
    contextBoost: 0.03,
    contextWords: ["employer", "company", "organization", "work"],
  ),

  // Account Number
  PiiPattern(
    pattern: r'\bBank Account:\s*([A-Z0-9][A-Z0-9-]{5,})\b',
    entityType: PiiLabel.accountNumber,
    priority: 14,
    captureGroup: 1,
    baseScore: 0.95,
    contextBoost: 0.03,
    contextWords: ["bank account", "account", "banking"],
  ),

  // Encounter Number
  PiiPattern(
    pattern: r'\bEncounter\s*#?:\s*([A-Z0-9][A-Z0-9-]{4,})\b',
    entityType: PiiLabel.encounterNumber,
    priority: 14,
    captureGroup: 1,
    baseScore: 0.95,
    contextBoost: 0.03,
    contextWords: ["encounter", "visit", "case"],
  ),

  // Routing Number
  PiiPattern(
    pattern: r'\bRouting:\s*(\d{9})\b',
    entityType: PiiLabel.routingNumber,
    priority: 14,
    captureGroup: 1,
    baseScore: 0.94,
    contextBoost: 0.03,
    contextWords: ["routing", "aba", "bank"],
  ),

  // Passwords / API Keys
  PiiPattern(
    pattern: r'\b(?:password|passwd|pwd|secret|key|api_key)[:\s]*([A-Za-z0-9@#$%^&+=]{8,})\b',
    entityType: PiiLabel.password,
    priority: 5,
    captureGroup: 1,
    baseScore: 0.3,
    contextBoost: 0.5,
    contextWords: ['password', 'secret', 'key', 'token'],
  ),

  // UUID / Device ID
  PiiPattern(
    pattern: r'\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b',
    entityType: 'UUID',
    priority: 8,
    baseScore: 0.85,
    contextBoost: 0.15,
    contextWords: ['device', 'id', 'uuid', 'identifier'],
  ),
];

class PiiDetector {
  final List<PiiPattern> patterns;
  final int contextWindow;

  PiiDetector({
    List<PiiPattern>? patterns,
    this.contextWindow = 100,
  }) : patterns = patterns ?? defaultPiiPatterns;

  PiiResult detectPii(String text) {
    if (text.isEmpty) {
      return PiiResult(entities: [], originalText: text);
    }

    final List<PiiEntity> entities = [];

    // Sort patterns by priority (highest first)
    final sortedPatterns = List<PiiPattern>.from(patterns)
      ..sort((a, b) => b.priority.compareTo(a.priority));

    for (final piiPattern in sortedPatterns) {
      final matches = piiPattern.pattern.allMatches(text);
      for (final match in matches) {
        int start = match.start;
        int end = match.end;
        String matchedText = text.substring(start, end);

        if (piiPattern.captureGroup != null && piiPattern.captureGroup! <= match.groupCount) {
          final group = match.group(piiPattern.captureGroup!);
          if (group != null) {
            start = match.start + match.group(0)!.indexOf(group);
            end = start + group.length;
            matchedText = group;
          }
        }

        // Check for overlap with existing higher-priority units
        bool overlaps = false;
        for (final existing in entities) {
          if (start < existing.end && end > existing.start) {
            overlaps = true;
            break;
          }
        }
        if (overlaps) continue;

        double score = piiPattern.baseScore;

        // Context boosting
        if (piiPattern.contextWords.isNotEmpty) {
          if (findContextWords(text, start, end, piiPattern.contextWords)) {
            score = min(1.0, score + piiPattern.contextBoost);
          }
        }

        // Validation
        if (piiPattern.validator != null) {
          if (!piiPattern.validator!(matchedText)) {
            score *= 0.3;
          }
        }

        entities.add(PiiEntity(
          label: piiPattern.entityType,
          text: matchedText,
          start: start,
          end: end,
          confidence: score,
          source: 'regex',
        ));
      }
    }

    // Sort entities by start position
    entities.sort((a, b) => a.start.compareTo(b.start));

    // Resolve overlaps (redundant but safe)
    final resolvedEntities = _mergeOverlapping(entities);

    return PiiResult(
      entities: resolvedEntities,
      originalText: text,
    );
  }

  bool findContextWords(String text, int start, int end, List<String> contextWords) {
    if (contextWords.isEmpty) return false;

    final windowStart = max(0, start - contextWindow);
    final windowEnd = min(text.length, end + contextWindow);
    final contextText = text.substring(windowStart, windowEnd).toLowerCase();

    for (final word in contextWords) {
      final wordLower = word.toLowerCase();
      // Use regex for word boundaries
      final contextRegex = RegExp('\\b${RegExp.escape(wordLower)}\\b');
      if (contextRegex.hasMatch(contextText)) {
        return true;
      }
    }
    return false;
  }

  List<PiiEntity> _mergeOverlapping(List<PiiEntity> entities) {
    if (entities.isEmpty) return [];

    final List<PiiEntity> merged = [];
    // entities is already sorted by start in detectPii

    for (final entity in entities) {
      if (merged.isEmpty) {
        merged.add(entity);
        continue;
      }

      final last = merged.last;
      if (entity.start < last.end) {
        // Overlap detected. Keep the one with higher confidence, or longer text if equal.
        if (entity.confidence > last.confidence) {
          merged.removeLast();
          merged.add(entity);
        } else if (entity.confidence == last.confidence) {
          if (entity.text.length > last.text.length) {
            merged.removeLast();
            merged.add(entity);
          }
        }
        // Else keep last
      } else {
        merged.add(entity);
      }
    }
    return merged;
  }

  /// Port of BIOES-to-entity decoding logic (simplified for regex-based engine)
  /// In this pure regex version, we mostly deal with whole entities, but this
  /// method can be used for future ML-based token merging.
  List<PiiEntity> decodeEntities(List<PiiEntity> tokenEntities, String originalText) {
    // For regex, tokenEntities ARE the final entities, but we ensure they are
    // format-preserved and repaired.
    return _repairEntitySpans(tokenEntities, originalText);
  }

  List<PiiEntity> _repairEntitySpans(List<PiiEntity> entities, String text) {
    return entities.map((entity) {
      int start = entity.start;
      int end = entity.end;

      // Trim whitespace
      final sub = text.substring(start, end);
      final trimmed = sub.trim();
      if (trimmed.length < sub.length) {
        final offset = sub.indexOf(trimmed);
        start += offset;
        end = start + trimmed.length;
      }

      return PiiEntity(
        label: entity.label,
        text: text.substring(start, end),
        start: start,
        end: end,
        confidence: entity.confidence,
        source: entity.source,
      );
    }).toList();
  }
}
