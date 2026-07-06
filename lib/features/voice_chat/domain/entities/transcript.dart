// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:equatable/equatable.dart';

class Transcript extends Equatable {
  final String text;
  final double confidence;
  final DateTime timestamp;

  const Transcript({
    required this.text,
    this.confidence = 1.0,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [text, confidence, timestamp];

  Transcript copyWith({
    String? text,
    double? confidence,
    DateTime? timestamp,
  }) {
    return Transcript(
      text: text ?? this.text,
      confidence: confidence ?? this.confidence,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
