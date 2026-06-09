// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2025 OrionHealth

import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/medical/pii_entity.dart';
import 'package:orionhealth_health/core/medical/quality_gates.dart';

void main() {
  group('QualityGateConfig', () {
    test('default values', () {
      const config = QualityGateConfig();
      expect(config.defaultMinConfidence, 0.7);
      expect(config.labelThresholds, isEmpty);
    });

    test('fromJson/toJson', () {
      final json = {
        'defaultMinConfidence': 0.8,
        'labelThresholds': {'PERSON': 0.9, 'EMAIL': 0.95},
      };
      final config = QualityGateConfig.fromJson(json);
      expect(config.defaultMinConfidence, 0.8);
      expect(config.labelThresholds['PERSON'], 0.9);
      expect(config.labelThresholds['EMAIL'], 0.95);

      expect(config.toJson(), json);
    });
  });

  group('QualityGate.validateSpans', () {
    const text = 'Hello John Doe, your email is john@example.com';

    test('valid spans', () {
      final entities = [
        const PiiEntity(
          label: 'PERSON',
          text: 'John Doe',
          confidence: 0.9,
          start: 6,
          end: 14,
          source: 'test',
        ),
        const PiiEntity(
          label: 'EMAIL',
          text: 'john@example.com',
          confidence: 1.0,
          start: 30,
          end: 46,
          source: 'test',
        ),
      ];

      final validated = QualityGate.validateSpans(entities, text);
      expect(validated[0].metadata?['span_valid'], isTrue);
      expect(validated[1].metadata?['span_valid'], isTrue);
    });

    test('inverted span', () {
      final entities = [
        const PiiEntity(
          label: 'PERSON',
          text: 'John Doe',
          confidence: 0.9,
          start: 14,
          end: 6,
          source: 'test',
        ),
      ];

      final validated = QualityGate.validateSpans(entities, text);
      expect(validated[0].metadata?['span_valid'], isFalse);
    });

    test('zero-length span', () {
      final entities = [
        const PiiEntity(
          label: 'PERSON',
          text: '',
          confidence: 0.9,
          start: 6,
          end: 6,
          source: 'test',
        ),
      ];

      final validated = QualityGate.validateSpans(entities, text);
      expect(validated[0].metadata?['span_valid'], isFalse);
    });

    test('out of bounds (negative)', () {
      final entities = [
        const PiiEntity(
          label: 'PERSON',
          text: 'Hello',
          confidence: 0.9,
          start: -5,
          end: 0,
          source: 'test',
        ),
      ];

      final validated = QualityGate.validateSpans(entities, text);
      expect(validated[0].metadata?['span_valid'], isFalse);
    });

    test('out of bounds (exceeds length)', () {
      final entities = [
        const PiiEntity(
          label: 'PERSON',
          text: '!',
          confidence: 0.9,
          start: 46,
          end: 47,
          source: 'test',
        ),
      ];

      final validated = QualityGate.validateSpans(entities, text);
      expect(validated[0].metadata?['span_valid'], isFalse);
    });

    test('text mismatch', () {
      final entities = [
        const PiiEntity(
          label: 'PERSON',
          text: 'Jane Doe',
          confidence: 0.9,
          start: 6,
          end: 14,
          source: 'test',
        ),
      ];

      final validated = QualityGate.validateSpans(entities, text);
      expect(validated[0].metadata?['span_valid'], isFalse);
    });

    test('whitespace-only mismatch (should be valid)', () {
      final entities = [
        const PiiEntity(
          label: 'PERSON',
          text: 'John  Doe', // extra space
          confidence: 0.9,
          start: 6,
          end: 14, // 'John Doe' in original text
          source: 'test',
        ),
      ];

      final validated = QualityGate.validateSpans(entities, text);
      expect(validated[0].metadata?['span_valid'], isTrue);
    });
  });

  group('QualityGate.detectOverlaps', () {
    test('detects overlaps', () {
      final entities = [
        const PiiEntity(
          label: 'PERSON',
          text: 'John Doe',
          confidence: 0.9,
          start: 6,
          end: 14,
          source: 'test',
        ),
        const PiiEntity(
          label: 'FIRST_NAME',
          text: 'John',
          confidence: 0.8,
          start: 6,
          end: 10,
          source: 'test',
        ),
        const PiiEntity(
          label: 'EMAIL',
          text: 'john@example.com',
          confidence: 1.0,
          start: 30,
          end: 46,
          source: 'test',
        ),
      ];

      final overlaps = QualityGate.detectOverlaps(entities);
      expect(overlaps, hasLength(1));
      expect(overlaps[0].$1.label, 'PERSON');
      expect(overlaps[0].$2.label, 'FIRST_NAME');
    });

    test('no overlaps', () {
      final entities = [
        const PiiEntity(
          label: 'PERSON',
          text: 'John',
          confidence: 0.9,
          start: 0,
          end: 4,
          source: 'test',
        ),
        const PiiEntity(
          label: 'PERSON',
          text: 'Doe',
          confidence: 0.9,
          start: 5,
          end: 8,
          source: 'test',
        ),
      ];

      final overlaps = QualityGate.detectOverlaps(entities);
      expect(overlaps, isEmpty);
    });
  });

  group('QualityGate.applyGates', () {
    final entities = [
      const PiiEntity(
        label: 'PERSON',
        text: 'John Doe',
        confidence: 0.65,
        start: 0,
        end: 8,
        source: 'test',
      ),
      const PiiEntity(
        label: 'EMAIL',
        text: 'john@example.com',
        confidence: 0.95,
        start: 20,
        end: 36,
        source: 'test',
      ),
    ];

    test('default confidence filtering', () {
      final filtered = QualityGate.applyGates(entities);
      expect(filtered, hasLength(1));
      expect(filtered[0].label, 'EMAIL');
    });

    test('custom default confidence filtering', () {
      final filtered = QualityGate.applyGates(
        entities,
        config: const QualityGateConfig(defaultMinConfidence: 0.6),
      );
      expect(filtered, hasLength(2));
    });

    test('per-label confidence filtering', () {
      final filtered = QualityGate.applyGates(
        entities,
        config: const QualityGateConfig(
          defaultMinConfidence: 0.8,
          labelThresholds: {'PERSON': 0.6},
        ),
      );
      expect(filtered, hasLength(2));
    });

    test('span validation filtering', () {
      final invalidEntities = [
        const PiiEntity(
          label: 'EMAIL',
          text: 'wrong',
          confidence: 0.95,
          start: 0,
          end: 5,
          source: 'test',
        ),
      ];
      const text = 'Valid text here';

      final filtered = QualityGate.applyGates(
        invalidEntities,
        text: text,
        dropInvalidSpans: true,
      );
      expect(filtered, isEmpty);

      final kept = QualityGate.applyGates(
        invalidEntities,
        text: text,
        dropInvalidSpans: false,
      );
      expect(kept, hasLength(1));
      expect(kept[0].metadata?['span_valid'], isFalse);
    });
  });
}
