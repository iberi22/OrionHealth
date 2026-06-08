// SPDX-License-Identifier: Apache-2.0
// Ported from OpenMed (https://github.com/maziyarpanahi/openmed)

import 'pii_entity.dart';
import 'pii_labels.dart';

typedef PiiValidator = bool Function(String text);

class PiiPattern {
  final RegExp pattern;
  final String entityType;
  final int priority;
  final double baseScore;
  final double contextBoost;
  final List<String> contextWords;
  final PiiValidator? validator;

  PiiPattern({
    required String pattern,
    required this.entityType,
    this.priority = 0,
    this.baseScore = 0.5,
    this.contextBoost = 0.35,
    this.contextWords = const [],
    this.validator,
    bool caseSensitive = false,
    bool multiLine = false,
  }) : pattern = RegExp(pattern, caseSensitive: caseSensitive, multiLine: multiLine);
}

class PiiDetector {
  static bool validateSsn(String ssnText) {
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

  static bool validateLuhn(String numberText) {
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

  static bool validateNpi(String npiText) {
    final digits = npiText.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 10) return false;

    const prefix = "80840";
    final fullNumber = prefix + digits;

    int sum = 0;
    bool alternate = false;
    for (int i = fullNumber.length - 1; i >= 0; i--) {
      int n = int.parse(fullNumber[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  static bool validatePhoneUs(String phoneText) {
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

  static final List<PiiPattern> defaultPatterns = [
    // Dates
    PiiPattern(
      pattern: r'\b\d{4}-\d{2}-\d{2}\b',
      entityType: PiiLabels.date,
      priority: 10,
      baseScore: 0.6,
      contextWords: ['dob', 'birth', 'born', 'date of birth', 'birthdate', 'deceased', 'died', 'admitted', 'discharged'],
    ),
    PiiPattern(
      pattern: r'\b\d{1,2}/\d{1,2}/\d{2,4}\b',
      entityType: PiiLabels.date,
      priority: 9,
      baseScore: 0.6,
      contextWords: ['dob', 'birth', 'born', 'date of birth', 'birthdate', 'deceased', 'died', 'admitted', 'discharged'],
    ),
    PiiPattern(
      pattern: r'\b\d{1,2}-\d{1,2}-\d{2,4}\b',
      entityType: PiiLabels.date,
      priority: 9,
      baseScore: 0.6,
      contextWords: ['dob', 'birth', 'born', 'date of birth', 'birthdate', 'deceased', 'died', 'admitted', 'discharged'],
    ),
    PiiPattern(
      pattern: r'\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]* \d{1,2},? \d{4}\b',
      entityType: PiiLabels.date,
      priority: 8,
      baseScore: 0.7,
      contextWords: ['dob', 'birth', 'born', 'date of birth', 'birthdate', 'deceased', 'died', 'admitted', 'discharged'],
    ),
    PiiPattern(
      pattern: r'\b\d{1,2} (?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]* \d{4}\b',
      entityType: PiiLabels.date,
      priority: 8,
      baseScore: 0.7,
      contextWords: ['dob', 'birth', 'born', 'date of birth', 'birthdate', 'deceased', 'died', 'admitted', 'discharged'],
    ),

    // SSN
    PiiPattern(
      pattern: r'\b\d{3}-\d{2}-\d{4}\b',
      entityType: PiiLabels.ssn,
      priority: 10,
      baseScore: 0.3,
      contextWords: ['ssn', 'social security', 'social security number', 'ss#', 'ss number'],
      contextBoost: 0.55,
      validator: validateSsn,
    ),
    PiiPattern(
      pattern: r'\b\d{3}\s\d{2}\s\d{4}\b',
      entityType: PiiLabels.ssn,
      priority: 9,
      baseScore: 0.3,
      contextWords: ['ssn', 'social security', 'social security number', 'ss#', 'ss number'],
      contextBoost: 0.55,
      validator: validateSsn,
    ),

    // Phone numbers
    PiiPattern(
      pattern: r'\b\(\d{3}\)\s*\d{3}[-.\s]?\d{4}\b',
      entityType: PiiLabels.phoneNumber,
      priority: 9,
      baseScore: 0.6,
      contextWords: ['phone', 'tel', 'telephone', 'cell', 'mobile', 'fax', 'call', 'contact'],
      validator: validatePhoneUs,
    ),
    PiiPattern(
      pattern: r'\b\d{3}[-.\s]\d{3}[-.\s]\d{4}\b',
      entityType: PiiLabels.phoneNumber,
      priority: 8,
      baseScore: 0.5,
      contextWords: ['phone', 'tel', 'telephone', 'cell', 'mobile', 'fax', 'call', 'contact'],
      contextBoost: 0.35,
      validator: validatePhoneUs,
    ),
    PiiPattern(
      pattern: r'\b\d{10}\b',
      entityType: PiiLabels.phoneNumber,
      priority: 5,
      baseScore: 0.2,
      contextWords: ['phone', 'tel', 'telephone', 'cell', 'mobile', 'fax', 'call', 'contact'],
      contextBoost: 0.5,
      validator: validatePhoneUs,
    ),

    // NPI
    PiiPattern(
      pattern: r'\b\d{10}\b',
      entityType: PiiLabels.npi,
      priority: 6,
      baseScore: 0.15,
      contextWords: ['npi', 'national provider', 'provider number', 'provider id', 'provider identifier'],
      contextBoost: 0.65,
      validator: validateNpi,
    ),

    // Email
    PiiPattern(
      pattern: r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
      entityType: PiiLabels.email,
      priority: 10,
      baseScore: 0.9,
      contextWords: ['email', 'e-mail', 'contact', 'mail'],
      contextBoost: 0.1,
    ),

    // ZIP codes
    PiiPattern(
      pattern: r'\b\d{5}(?:-\d{4})?\b',
      entityType: PiiLabels.postcode,
      priority: 7,
      baseScore: 0.4,
      contextWords: ['zip', 'zipcode', 'zip code', 'postal', 'postal code'],
      contextBoost: 0.45,
    ),

    // Credit card
    PiiPattern(
      pattern: r'\b\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}\b',
      entityType: PiiLabels.creditCard,
      priority: 8,
      baseScore: 0.4,
      contextWords: ['card', 'credit', 'debit', 'visa', 'mastercard', 'amex', 'discover', 'payment'],
      contextBoost: 0.4,
      validator: validateLuhn,
    ),

    // Medical record numbers
    PiiPattern(
      pattern: r'\b(?:MRN|mrn)[:\s#]*\d{6,10}\b',
      entityType: PiiLabels.medicalRecordNumber,
      priority: 9,
      baseScore: 0.8,
      contextWords: ['medical record', 'patient id', 'patient number', 'record number'],
      contextBoost: 0.15,
    ),
    PiiPattern(
      pattern: r'\b[A-Z]{2,3}\d{6,9}\b',
      entityType: PiiLabels.medicalRecordNumber,
      priority: 5,
      baseScore: 0.3,
      contextWords: ['mrn', 'medical record', 'patient id', 'patient number', 'record number'],
      contextBoost: 0.5,
    ),

    // Street addresses
    PiiPattern(
      pattern: r'\b\d{1,5}\s+[A-Z][a-z]+(?:\s+[A-Z][a-z]+)*\s+(?:Street|St|Avenue|Ave|Road|Rd|Boulevard|Blvd|Lane|Ln|Drive|Dr|Court|Ct|Way)\b',
      entityType: PiiLabels.streetAddress,
      priority: 7,
      baseScore: 0.7,
      contextWords: ['address', 'street', 'resides', 'residence', 'lives at', 'located at'],
      contextBoost: 0.2,
    ),

    // URLs
    PiiPattern(
      pattern: r'\b(?:https?://)?(?:www\.)?[a-zA-Z0-9-]+\.[a-zA-Z]{2,}(?:/[^\s]*)?\b',
      entityType: PiiLabels.url,
      priority: 8,
      baseScore: 0.8,
      contextWords: ['url', 'website', 'link', 'webpage'],
      contextBoost: 0.15,
    ),

    // IP addresses
    PiiPattern(
      pattern: r'\b(?:\d{1,3}\.){3}\d{1,3}\b',
      entityType: PiiLabels.ipv4,
      priority: 7,
      baseScore: 0.6,
      contextWords: ['ip', 'ip address', 'address', 'server', 'host'],
      contextBoost: 0.3,
    ),
    PiiPattern(
      pattern: r'\b(?:[0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}\b',
      entityType: PiiLabels.ipv6,
      priority: 8,
      baseScore: 0.85,
      contextWords: ['ip', 'ipv6', 'ip address', 'address', 'server', 'host'],
      contextBoost: 0.15,
    ),

    // MAC addresses
    PiiPattern(
      pattern: r'\b(?:[0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}\b',
      entityType: PiiLabels.macAddress,
      priority: 8,
      baseScore: 0.75,
      contextWords: ['mac', 'mac address', 'hardware address'],
      contextBoost: 0.2,
    ),

    // UUID / Device ID
    PiiPattern(
      pattern: r'\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b',
      entityType: PiiLabels.deviceId,
      priority: 10,
      baseScore: 0.9,
      contextWords: ['device', 'id', 'uuid', 'identifier'],
    ),
  ];

  List<PiiEntity> detect(String text, {List<PiiPattern>? patterns}) {
    final activePatterns = patterns ?? defaultPatterns;
    final entities = <PiiEntity>[];

    final sortedPatterns = List<PiiPattern>.from(activePatterns)
      ..sort((a, b) => b.priority.compareTo(a.priority));

    for (final piiPattern in sortedPatterns) {
      final matches = piiPattern.pattern.allMatches(text);
      for (final match in matches) {
        bool overlaps = false;
        for (final existing in entities) {
          if (match.start < existing.end && match.end > existing.start) {
            overlaps = true;
            break;
          }
        }
        if (overlaps) continue;

        final matchedText = text.substring(match.start, match.end);
        double score = piiPattern.baseScore;

        if (piiPattern.contextWords.isNotEmpty) {
          if (_findContextWords(text, match.start, match.end, piiPattern.contextWords)) {
            score = (score + piiPattern.contextBoost).clamp(0.0, 1.0);
          }
        }

        bool validated = true;
        if (piiPattern.validator != null) {
          if (!piiPattern.validator!(matchedText)) {
            score *= 0.3;
            validated = false;
          }
        }

        // Only add if score is high enough
        if (score > 0.3) {
          entities.add(PiiEntity(
            type: piiPattern.entityType,
            text: matchedText,
            start: match.start,
            end: match.end,
            score: score,
          ));
        }
      }
    }

    return entities..sort((a, b) => a.start.compareTo(b.start));
  }

  bool _findContextWords(String text, int start, int end, List<String> contextWords, {int window = 100}) {
    final windowStart = (start - window).clamp(0, text.length);
    final windowEnd = (end + window).clamp(0, text.length);
    final contextText = text.substring(windowStart, windowEnd).toLowerCase();

    for (final word in contextWords) {
      final wordLower = word.toLowerCase();
      if (contextText.contains(wordLower)) {
        // Check word boundaries
        final regex = RegExp('\\b${RegExp.escape(wordLower)}\\b');
        if (regex.hasMatch(contextText)) {
          return true;
        }
      }
    }
    return false;
  }

  String mask(String text, {List<PiiPattern>? patterns, String Function(PiiEntity)? maskBuilder}) {
    final entities = detect(text, patterns: patterns);
    if (entities.isEmpty) return text;

    final buffer = StringBuffer();
    int lastEnd = 0;

    for (final entity in entities) {
      buffer.write(text.substring(lastEnd, entity.start));
      if (maskBuilder != null) {
        buffer.write(maskBuilder(entity));
      } else {
        buffer.write('[${entity.type.toUpperCase()}]');
      }
      lastEnd = entity.end;
    }

    buffer.write(text.substring(lastEnd));
    return buffer.toString();
  }
}
