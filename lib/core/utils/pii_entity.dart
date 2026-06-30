// SPDX-License-Identifier: Apache-2.0
// Ported from OpenMed (https://github.com/maziyarpanahi/openmed)

import 'package:equatable/equatable.dart';

class PiiEntity extends Equatable {
  final String type;
  final String text;
  final int start;
  final int end;
  final double score;

  const PiiEntity({
    required this.type,
    required this.text,
    required this.start,
    required this.end,
    this.score = 1.0,
  });

  factory PiiEntity.fromJson(Map<String, dynamic> json) {
    return PiiEntity(
      type: json['type'] as String,
      text: json['text'] as String,
      start: json['start'] as int,
      end: json['end'] as int,
      score: (json['score'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'text': text,
      'start': start,
      'end': end,
      'score': score,
    };
  }

  @override
  List<Object?> get props => [type, text, start, end, score];

  @override
  String toString() =>
      'PiiEntity(type: $type, text: $text, start: $start, end: $end, score: $score)';
}
