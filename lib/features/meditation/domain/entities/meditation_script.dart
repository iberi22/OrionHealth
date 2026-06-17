// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:equatable/equatable.dart';
import 'meditation_category.dart';

class MeditationScript extends Equatable {
  final String id;
  final String title;
  final MeditationCategory category;
  final int durationMinutes;
  final List<String> steps;
  final List<String> tags;

  const MeditationScript({
    required this.id,
    required this.title,
    required this.category,
    required this.durationMinutes,
    required this.steps,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [id, title, category, durationMinutes, steps, tags];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category.name,
        'durationMinutes': durationMinutes,
        'steps': steps,
        'tags': tags,
      };

  static MeditationScript fromJson(Map<String, dynamic> json) =>
      MeditationScript(
        id: json['id'] as String,
        title: json['title'] as String,
        category: MeditationCategory.values.byName(json['category'] as String),
        durationMinutes: (json['durationMinutes'] as num).toInt(),
        steps: (json['steps'] as List<dynamic>).cast<String>(),
        tags: ((json['tags'] as List<dynamic>?) ?? const []).cast<String>(),
      );
}
