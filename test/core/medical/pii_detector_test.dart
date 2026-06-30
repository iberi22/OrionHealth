// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2025 OrionHealth

import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/medical/pii_detector.dart';
import 'package:orionhealth_health/core/medical/pii_labels.dart';

void main() {
  late PiiDetector detector;

  setUp(() {
    detector = PiiDetector();
  });

  test('detects ssn', () {
    final result = detector.detectPii('My ssn is 123-45-6789');
    expect(result.entities.any((e) => e.label == PiiLabel.ssn), isTrue);
  });

  test('detects email', () {
    final result = detector.detectPii('Contact me at test@example.com');
    expect(result.entities.any((e) => e.label == PiiLabel.email), isTrue);
  });

  test('detects credit card with Luhn', () {
    // 4111-1111-1111-1111 is a valid Visa card (Luhn-wise)
    final result = detector.detectPii('Card: 4111-1111-1111-1111');
    expect(result.entities.any((e) => e.label == PiiLabel.creditCard), isTrue);
  });

  test('context boosting', () {
    final result = detector.detectPii('ssn: 123-45-6789');
    final entity = result.entities.firstWhere((e) => e.label == PiiLabel.ssn);
    expect(entity.confidence, greaterThan(0.5)); // base 0.3 + boost 0.55 = 0.85
  });

  test('no false positive on non-PII number (low confidence)', () {
    final result = detector.detectPii('The total is 123-45-6789');
    // Without ssn context, score should be low
    final entity = result.entities.firstWhere((e) => e.label == PiiLabel.ssn);
    expect(entity.confidence, lessThan(0.5)); // base 0.3
  });

  test('detects multiple PII types', () {
    final text = 'Patient Jane Doe (DOB: 01/01/1980) called from 555-123-4567 regarding her ssn 999-00-1111';
    final result = detector.detectPii(text);

    final labels = result.entities.map((e) => e.label).toSet();
    expect(labels.contains(PiiLabel.date), isTrue);
    expect(labels.contains(PiiLabel.phoneNumber), isTrue);
    // ssn 999-00-1111 starts with 9, so it should fail validation and have low confidence
    final ssn = result.entities.firstWhere((e) => e.label == PiiLabel.ssn);
    expect(ssn.confidence, lessThan(0.5));
  });

  test('scrubbing works', () {
    final result = detector.detectPii('Email me at test@example.com');
    expect(result.scrubbedText, contains('[email]'));
    expect(result.scrubbedText, isNot(contains('test@example.com')));
  });

  test('handles empty text', () {
    final result = detector.detectPii('');
    expect(result.entities, isEmpty);
    expect(result.scrubbedText, '');
  });
}
