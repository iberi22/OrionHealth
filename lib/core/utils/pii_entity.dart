// SPDX-License-Identifier: Apache-2.0
// Ported from OpenMed (https://github.com/maziyarpanahi/openmed)

class PiiEntity {
  final String type;
  final String text;
  final int start;
  final int end;
  final double score;

  PiiEntity({
    required this.type,
    required this.text,
    required this.start,
    required this.end,
    this.score = 1.0,
  });

  @override
  String toString() => 'PiiEntity(type: $type, text: $text, start: $start, end: $end, score: $score)';
}
