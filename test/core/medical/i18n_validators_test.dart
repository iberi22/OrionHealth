// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2025 OrionHealth

import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/medical/i18n_validators.dart';

void main() {
  final validator = I18nValidatorImpl();

  group('I18nValidatorImpl', () {
    test('BR (CPF) validation', () {
      expect(validator.validate('123.456.789-09', 'BR'), isTrue);
      expect(validator.validate('12345678909', 'BR'), isTrue);
      expect(validator.validate('111.111.111-11', 'BR'), isFalse);
      expect(validator.validate('123.456.789-00', 'BR'), isFalse);
      expect(validator.validate('123456789', 'BR'), isFalse);
    });

    test('ES (DNI) validation', () {
      expect(validator.validate('12345678Z', 'ES'), isTrue);
      expect(validator.validate('12345678 Z', 'ES'), isTrue);
      expect(validator.validate('12345678A', 'ES'), isFalse);
      expect(validator.validate('1234567Z', 'ES'), isFalse);
    });

    test('PE (DNI) validation', () {
      expect(validator.validate('12345678', 'PE'), isTrue);
      expect(validator.validate('12-34-56-78', 'PE'), isTrue);
      expect(validator.validate('1234567', 'PE'), isFalse);
      expect(validator.validate('123456789', 'PE'), isFalse);
    });

    test('MX (CURP) validation', () {
      // Example CURP: ABCD123456HABCDE01
      expect(validator.validate('ABCD123456HABCDE01', 'MX'), isTrue);
      expect(validator.validate('ABCD123456MABCDE01', 'MX'), isTrue);
      expect(validator.validate('ABCD123456XABCDE01', 'MX'), isFalse); // Invalid gender
      expect(validator.validate('ABCD12345HABCDE01', 'MX'), isFalse); // Too short
      expect(validator.validate('ABCD123456HABCDE0A', 'MX'), isFalse); // Last char must be digit
    });

    test('Unsupported country code', () {
      expect(validator.validate('123', 'ZZ'), isFalse);
    });
  });

  group('Direct function tests', () {
    test('validateCpf', () {
      expect(validateCpf('123.456.789-09'), isTrue);
      expect(validateCpf('111.111.111-11'), isFalse);
    });

    test('validateDniSpain', () {
      expect(validateDniSpain('12345678Z'), isTrue);
      expect(validateDniSpain('12345678A'), isFalse);
    });

    test('validateDniPeru', () {
      expect(validateDniPeru('12345678'), isTrue);
      expect(validateDniPeru('1234567'), isFalse);
    });

    test('validateCurp', () {
      expect(validateCurp('ABCD123456HABCDE01'), isTrue);
      expect(validateCurp('INVALID'), isFalse);
    });
  });
}
