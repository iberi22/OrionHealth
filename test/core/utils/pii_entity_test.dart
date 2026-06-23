import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/utils/pii_entity.dart';

void main() {
  group('PiiEntity (Utils)', () {
    test('should create PiiEntity instance with correct values', () {
      final entity = PiiEntity(
        type: 'person',
        text: 'John Doe',
        start: 0,
        end: 8,
        score: 0.95,
      );

      expect(entity.type, 'person');
      expect(entity.text, 'John Doe');
      expect(entity.start, 0);
      expect(entity.end, 8);
      expect(entity.score, 0.95);
    });

    test('should use default score when not provided', () {
      final entity = PiiEntity(
        type: 'email',
        text: 'test@example.com',
        start: 10,
        end: 26,
      );

      expect(entity.score, 1.0);
    });

    test('should support equality', () {
      final e1 = PiiEntity(
        type: 'person',
        text: 'Alice',
        start: 0,
        end: 5,
        score: 0.9,
      );
      final e2 = PiiEntity(
        type: 'person',
        text: 'Alice',
        start: 0,
        end: 5,
        score: 0.9,
      );
      final e3 = PiiEntity(
        type: 'person',
        text: 'Bob',
        start: 0,
        end: 3,
        score: 0.9,
      );

      expect(e1, equals(e2));
      expect(e1, isNot(equals(e3)));
      expect(e1.hashCode, equals(e2.hashCode));
    });

    test('should serialize to JSON correctly', () {
      final entity = PiiEntity(
        type: 'phone',
        text: '555-0199',
        start: 5,
        end: 13,
        score: 0.8,
      );

      final json = entity.toJson();

      expect(json['type'], 'phone');
      expect(json['text'], '555-0199');
      expect(json['start'], 5);
      expect(json['end'], 13);
      expect(json['score'], 0.8);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'type': 'address',
        'text': '123 Main St',
        'start': 20,
        'end': 31,
        'score': 0.75,
      };

      final entity = PiiEntity.fromJson(json);

      expect(entity.type, 'address');
      expect(entity.text, '123 Main St');
      expect(entity.start, 20);
      expect(entity.end, 31);
      expect(entity.score, 0.75);
    });

    test('should handle missing score in JSON by using default', () {
      final json = {
        'type': 'ssn',
        'text': '000-00-0000',
        'start': 0,
        'end': 11,
      };

      final entity = PiiEntity.fromJson(json);

      expect(entity.score, 1.0);
    });

    test('should round-trip JSON serialization', () {
      final original = PiiEntity(
        type: 'date',
        text: '2024-05-20',
        start: 100,
        end: 110,
        score: 0.99,
      );

      final json = original.toJson();
      final fromJson = PiiEntity.fromJson(json);

      expect(fromJson, equals(original));
    });

    test('toString returns correct format', () {
      final entity = PiiEntity(
        type: 't',
        text: 'v',
        start: 1,
        end: 2,
        score: 0.5,
      );
      expect(entity.toString(), 'PiiEntity(type: t, text: v, start: 1, end: 2, score: 0.5)');
    });
  });
}
