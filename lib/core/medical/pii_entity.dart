// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2025 OrionHealth

class PiiEntity {
  final String label;
  final String text;
  final int start;
  final int end;
  final double confidence;

  PiiEntity({
    required this.label,
    required this.text,
    required this.start,
    required this.end,
    required this.confidence,
  });

  @override
  String toString() {
    return 'PiiEntity(label: $label, text: $text, start: $start, end: $end, confidence: $confidence)';
  }
}

class PiiResult {
  final List<PiiEntity> entities;
  final String originalText;
  final String scrubbedText;

  PiiResult({
    required this.entities,
    required this.originalText,
    required this.scrubbedText,
  });

  Map<String, List<PiiEntity>> categorize() {
    final Map<String, List<PiiEntity>> categories = {};
    for (final entity in entities) {
      categories.putIfAbsent(entity.label, () => []).add(entity);
    }
    return categories;
  }
}
