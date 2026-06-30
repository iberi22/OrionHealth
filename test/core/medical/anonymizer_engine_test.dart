import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/medical/anonymizer_engine.dart';

void main() {
  group('AnonymizerEngine', () {
    test('should produce surrogate for phone', () {
      final engine = AnonymizerEngine();
      final result = engine.surrogate('+1 (213) 555-1234', 'phone');
      expect(result, matches(r'^\+\d \(\d{3}\) \d{3}-\d{4}$'));
      expect(result, isNot(contains('555')));
    });

    test('should produce surrogate for email with domain preserved', () {
      final engine = AnonymizerEngine();
      final result = engine.surrogate('john.doe@hospital.org', 'email');
      expect(result, endsWith('@hospital.org'));
      expect(result, isNot(contains('john.doe')));
    });

    test('should produce surrogate for ssn with last 4 preserved', () {
      final engine = AnonymizerEngine();
      final result = engine.surrogate('123-45-6789', 'ssn');
      expect(result, matches(r'^\d{3}-\d{2}-6789$'));
    });

    test('should produce surrogate for creditCard with last 4 preserved', () {
      final engine = AnonymizerEngine();
      final result = engine.surrogate('4532-1488-0343-6467', 'creditCard');
      expect(result, matches(r'^\d{4}-\d{1,10}-6467$'));
    });

    test('should produce surrogate for person name', () {
      final engine = AnonymizerEngine();
      final result = engine.surrogate('Michael Johnson', 'person');
      expect(result.contains(' '), isTrue);
    });

    test('should produce surrogate for date with same format', () {
      final engine = AnonymizerEngine();
      final result = engine.surrogate('2020-05-15', 'date');
      expect(result, matches(r'^\d{4}-\d{2}-\d{2}$'));
    });

    test('should produce surrogate for age', () {
      final engine = AnonymizerEngine();
      final result = engine.surrogate('45', 'age');
      expect(int.tryParse(result), isNotNull);
    });

    test('should produce surrogate for location', () {
      final engine = AnonymizerEngine();
      final result = engine.surrogate('Oakland', 'location');
      expect(result.isNotEmpty, isTrue);
    });

    test('deterministic mode should return same surrogate for same input', () {
      final engine = AnonymizerEngine(consistent: true);
      final a = engine.surrogate('test@example.com', 'email');
      final b = engine.surrogate('test@example.com', 'email');
      expect(a, equals(b));
    });

    test('deterministic mode should return different surrogates for different inputs', () {
      final engine = AnonymizerEngine(consistent: true);
      final a = engine.surrogate('alice@example.com', 'email');
      final b = engine.surrogate('bob@example.com', 'email');
      expect(a, isNot(equals(b)));
    });

    test('surrogate for unknown label should preserve format', () {
      final engine = AnonymizerEngine();
      final result = engine.surrogate('ABC-1234', 'UNKNOWN_LABEL');
      expect(result, matches(r'^[A-Z]{3}-\d{4}$'));
    });

    test('registerGenerator should override built-in', () {
      final engine = AnonymizerEngine();
      engine.registerGenerator('email', (original, rng) => 'overridden@test.com');
      final result = engine.surrogate('test@example.com', 'email');
      expect(result, 'overridden@test.com');
    });
  });
}
