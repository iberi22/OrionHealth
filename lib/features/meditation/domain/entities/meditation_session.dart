// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:equatable/equatable.dart';
import 'meditation_category.dart';

class MeditationSession extends Equatable {
  final String id;
  final String scriptId;
  final MeditationCategory category;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int elapsedSeconds;
  final int completedSteps;
  final bool completed;

  const MeditationSession({
    required this.id,
    required this.scriptId,
    required this.category,
    required this.startedAt,
    this.completedAt,
    this.elapsedSeconds = 0,
    this.completedSteps = 0,
    this.completed = false,
  });

  @override
  List<Object?> get props => [
        id,
        scriptId,
        category,
        startedAt,
        completedAt,
        elapsedSeconds,
        completedSteps,
        completed
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'scriptId': scriptId,
        'category': category.name,
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'elapsedSeconds': elapsedSeconds,
        'completedSteps': completedSteps,
        'completed': completed,
      };

  static MeditationSession fromJson(Map<String, dynamic> json) =>
      MeditationSession(
        id: json['id'] as String,
        scriptId: json['scriptId'] as String,
        category: MeditationCategory.values.byName(json['category'] as String),
        startedAt: DateTime.parse(json['startedAt'] as String),
        completedAt: json['completedAt'] == null
            ? null
            : DateTime.parse(json['completedAt'] as String),
        elapsedSeconds: (json['elapsedSeconds'] as num?)?.toInt() ?? 0,
        completedSteps: (json['completedSteps'] as num?)?.toInt() ?? 0,
        completed: json['completed'] as bool? ?? false,
      );
}
