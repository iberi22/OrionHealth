// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:equatable/equatable.dart';
import 'meditation_category.dart';

class MeditationPreferences extends Equatable {
  final MeditationCategory preferredCategory;
  final int preferredDurationMinutes;
  final bool ttsEnabled;
  final String? lastScriptId;

  const MeditationPreferences({
    this.preferredCategory = MeditationCategory.calm,
    this.preferredDurationMinutes = 5,
    this.ttsEnabled = true,
    this.lastScriptId,
  });

  @override
  List<Object?> get props =>
      [preferredCategory, preferredDurationMinutes, ttsEnabled, lastScriptId];

  MeditationPreferences copyWith({
    MeditationCategory? preferredCategory,
    int? preferredDurationMinutes,
    bool? ttsEnabled,
    String? lastScriptId,
  }) {
    return MeditationPreferences(
      preferredCategory: preferredCategory ?? this.preferredCategory,
      preferredDurationMinutes:
          preferredDurationMinutes ?? this.preferredDurationMinutes,
      ttsEnabled: ttsEnabled ?? this.ttsEnabled,
      lastScriptId: lastScriptId ?? this.lastScriptId,
    );
  }

  Map<String, dynamic> toJson() => {
        'preferredCategory': preferredCategory.name,
        'preferredDurationMinutes': preferredDurationMinutes,
        'ttsEnabled': ttsEnabled,
        'lastScriptId': lastScriptId,
      };

  static MeditationPreferences fromJson(Map<String, dynamic> json) =>
      MeditationPreferences(
        preferredCategory: MeditationCategory.values.byName(
          json['preferredCategory'] as String? ?? MeditationCategory.calm.name,
        ),
        preferredDurationMinutes:
            (json['preferredDurationMinutes'] as num?)?.toInt() ?? 5,
        ttsEnabled: json['ttsEnabled'] as bool? ?? true,
        lastScriptId: json['lastScriptId'] as String?,
      );
}
