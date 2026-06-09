import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/medical/anonymizer_engine.dart';

void main() {
  group('AnonymizerEngine', () {
    test('should produce surrogate for phone', () {
      final engine = AnonymizerEngine();
      final result = engine.surrogate('+1 (213) 555-1234', 'PHONE');
      expect(result, matches(r'^\+\d \(\d{3}\) \d{3}-\d{4}$'));
      expect(result, isNot(contains('555')));
    });

    test('should produce surrogate for EMAIL with domain preserved', () {
      final engine = AnonymizerEngine();
      final result = engine.surrogate('john.doe@hospital.org', 'EMAIL');
      expect(result, endsWith('@hospital.org'));
      expect(result, isNot(contains('john.doe')));
    });

    test('should produce surrogate for SSN with last 4 preserved', () {
      final engine = AnonymizerEngine();
      final result = engine.surrogate('123-45-6789', 'SSN');
      expect(result, matches(r'^\d{3}-\d{2}-6789$'));
    });

    test('should produce surrogate for CREDIT_CARD with last 4 preserved', () {
      final engine = AnonymizerEngine();
      final result = engine.surrogate('4532-1488-0343-6467', 'CREDIT_CARD');
      expect(result, matches(r'^\d{4}-\d{1,10}-6467$'));
    });

    test('should produce surrogate for PERSON name', () {
      final engine = AnonymizerEngine();
      final result = engine.surrogate('Michael Johnson', 'PERSON');
      expect(result.contains(' '), isTrue);
    });

    test('should produce surrogate for DATE with same format', () {
      final engine = AnonymizerEngine();
      final result = engine.surrogate('2020-05-15', 'DATE');
      expect(result, matches(r'^\d{4}-\d{2}-\d{2}$'));
    });

    test('should produce surrogate for AGE', () {
      final engine = AnonymizerEngine();
      final result = engine.surrogate('45', 'AGE');
      expect(int.tryParse(result), isNotNull);
    });

    test('should produce surrogate for LOCATION', () {
      final engine = AnonymizerEngine();
      final result = engine.surrogate('Oakland', 'LOCATION');
      expect(result.isNotEmpty, isTrue);
    });

    test('deterministic mode should return same surrogate for same input', () {
      final engine = AnonymizerEngine(consistent: true);
      final a = engine.surrogate('test@example.com', 'EMAIL');
      final b = engine.surrogate('test@example.com', 'EMAIL');
      expect(a, equals(b));
    });

    test('deterministic mode should return different surrogates for different inputs', () {
      final engine = AnonymizerEngine(consistent: true);
      final a = engine.surrogate('alice@example.com', 'EMAIL');
      final b = engine.surrogate('bob@example.com', 'EMAIL');
      expect(a, isNot(equals(b)));
    });

    test('surrogate for unknown label should preserve format', () {
      final engine = AnonymizerEngine();
      final result = engine.surrogate('ABC-1234', 'UNKNOWN_LABEL');
      expect(result, matches(r'^[A-Z]{3}-\d{4}$'));
    });

    test('registerGenerator should override built-in', () {
      final engine = AnonymizerEngine();
      engine.registerGenerator('EMAIL', (original, rng) => 'overridden@test.com');
      final result = engine.surrogate('test@example.com', 'EMAIL');
      expect(result, 'overridden@test.com');
    });
  });
}
