import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/medical/pii_entity.dart';

void main() {
  group('PiiEntity', () {
    test('toJson/fromJson works correctly', () {
      const entity = PiiEntity(
        label: 'person',
        text: 'John Doe',
        confidence: 0.95,
        start: 0,
        end: 8,
        source: 'model',
      );

      final json = entity.toJson();
      final fromJson = PiiEntity.fromJson(json);

      expect(fromJson, entity);
    });

    test('overlaps detects overlapping spans', () {
      const e1 = PiiEntity(
        label: 'person',
        text: 'John',
        confidence: 0.9,
        start: 0,
        end: 4,
        source: 'model',
      );
      const e2 = PiiEntity(
        label: 'person',
        text: 'ohn',
        confidence: 0.8,
        start: 1,
        end: 4,
        source: 'model',
      );
      const e3 = PiiEntity(
        label: 'person',
        text: 'Doe',
        confidence: 0.9,
        start: 5,
        end: 8,
        source: 'model',
      );

      expect(e1.overlaps(e2), isTrue);
      expect(e1.overlaps(e3), isFalse);
    });

    test('merge combines overlapping entities', () {
      const originalText = 'John Doe is here';
      const e1 = PiiEntity(
        label: 'person',
        text: 'John',
        confidence: 0.9,
        start: 0,
        end: 4,
        source: 'model',
      );
      const e2 = PiiEntity(
        label: 'person',
        text: 'ohn Doe',
        confidence: 0.95,
        start: 1,
        end: 8,
        source: 'model',
      );

      final merged = e1.merge(e2, originalText);

      expect(merged.start, 0);
      expect(merged.end, 8);
      expect(merged.text, 'John Doe');
      expect(merged.confidence, 0.95);
    });
  });

  group('PiiMatch', () {
    test('toEntity converts match correctly', () {
      const match = PiiMatch(
        label: 'email',
        text: 'test@example.com',
        start: 10,
        end: 26,
      );

      final entity = match.toEntity(confidence: 1.0, source: 'regex');

      expect(entity.label, 'email');
      expect(entity.text, 'test@example.com');
      expect(entity.start, 10);
      expect(entity.end, 26);
      expect(entity.confidence, 1.0);
      expect(entity.source, 'regex');
    });
  });

  group('PiiResult', () {
    const originalText = 'My name is John Doe and my email is john@example.com';
    final entities = [
      const PiiEntity(
        label: 'person',
        text: 'John Doe',
        confidence: 0.9,
        start: 11,
        end: 19,
        source: 'model',
      ),
      const PiiEntity(
        label: 'email',
        text: 'john@example.com',
        confidence: 1.0,
        start: 36,
        end: 52,
        source: 'regex',
      ),
    ];

    test('scrubbedText replaces entities with labels', () {
      final result = PiiResult(entities: entities, originalText: originalText);
      expect(
        result.scrubbedText,
        'My name is [PERSON] and my email is [EMAIL]',
      );
    });

    test('sortedByPosition sorts by start index', () {
      final result = PiiResult(
        entities: entities.reversed.toList(),
        originalText: originalText,
      );
      final sorted = result.sortedByPosition();

      expect(sorted[0].start, 11);
      expect(sorted[1].start, 36);
    });

    test('mergeOverlapping merges overlapping entities', () {
      const text = 'Alice Smith';
      final overlapping = [
        const PiiEntity(
          label: 'person',
          text: 'Alice',
          confidence: 0.9,
          start: 0,
          end: 5,
          source: 'model',
        ),
        const PiiEntity(
          label: 'person',
          text: 'Alice Smith',
          confidence: 0.8,
          start: 0,
          end: 11,
          source: 'model',
        ),
      ];

      final result = PiiResult(entities: overlapping, originalText: text);
      final merged = result.mergeOverlapping();

      expect(merged.entities.length, 1);
      expect(merged.entities.first.text, 'Alice Smith');
      expect(merged.entities.first.confidence, 0.9);
    });

    test('toJson/fromJson works correctly', () {
      final result = PiiResult(entities: entities, originalText: originalText);
      final json = result.toJson();
      final fromJson = PiiResult.fromJson(json);

      expect(fromJson, result);
      expect(json['scrubbedText'], 'My name is [PERSON] and my email is [EMAIL]');
    });
  });
}
