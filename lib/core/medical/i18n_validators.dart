// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2025 OrionHealth

/// Interface for international ID validators.
abstract class I18nValidator {
  /// Validates the [input] based on the provided [countryCode].
  /// [countryCode] should be an ISO 3166-1 alpha-2 code (e.g., 'BR', 'ES', 'PE', 'MX').
  bool validate(String input, String countryCode);
}

/// Implementation of international ID validators.
class I18nValidatorImpl implements I18nValidator {
  @override
  bool validate(String input, String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'BR':
        return validateCpf(input);
      case 'ES':
        return validateDniSpain(input);
      case 'PE':
        return validateDniPeru(input);
      case 'MX':
        return validateCurp(input);
      default:
        return false;
    }
  }
}

const String _dniLetters = "TRWAGMYFPDXBNJZSQVHLCKE";

/// Validates Brazilian CPF (Cadastro de Pessoas Físicas).
/// Ported from OpenMed validate_portuguese_cpf.
bool validateCpf(String text) {
  final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length != 11) return false;

  // Reject all same digits (e.g., 111.111.111-11)
  if (RegExp(r'^(\d)\1{10}$').hasMatch(digits)) return false;

  final numbers = digits.split('').map(int.parse).toList();

  // First check digit
  int firstSum = 0;
  for (int i = 0; i < 9; i++) {
    firstSum += numbers[i] * (10 - i);
  }
  int firstCheck = (firstSum * 10) % 11;
  if (firstCheck == 10) firstCheck = 0;

  if (numbers[9] != firstCheck) return false;

  // Second check digit
  int secondSum = 0;
  for (int i = 0; i < 10; i++) {
    secondSum += numbers[i] * (11 - i);
  }
  int secondCheck = (secondSum * 10) % 11;
  if (secondCheck == 10) secondCheck = 0;

  return numbers[10] == secondCheck;
}

/// Validates Spanish DNI (Documento Nacional de Identidad).
/// Ported from OpenMed validate_spanish_dni.
bool validateDniSpain(String text) {
  final cleaned = text.replaceAll(RegExp(r'\s'), '').toUpperCase();
  if (cleaned.length != 9) return false;

  final match = RegExp(r'^(\d{8})([A-Z])$').firstMatch(cleaned);
  if (match == null) return false;

  final numberStr = match.group(1)!;
  final letter = match.group(2)!;
  final number = int.parse(numberStr);

  return letter == _dniLetters[number % 23];
}

/// Validates Peruvian DNI (Documento Nacional de Identidad).
/// Requirement: 8 digits.
bool validateDniPeru(String text) {
  final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
  return digits.length == 8;
}

/// Validates Mexican CURP (Clave Única de Registro de Población).
/// Requirement: 18 characters, format validation.
bool validateCurp(String text) {
  final cleaned = text.replaceAll(RegExp(r'\s'), '').toUpperCase();
  if (cleaned.length != 18) return false;

  // Official CURP format:
  // 4 letters (name/surname initials)
  // 6 digits (birth date YYMMDD)
  // 1 letter (Gender H/M)
  // 2 letters (State code)
  // 3 letters (consonants)
  // 2 chars (homonym and check digit)
  final pattern = RegExp(r'^[A-Z]{4}\d{6}[HM][A-Z]{5}[A-Z0-9]\d$');
  return pattern.hasMatch(cleaned);
}
