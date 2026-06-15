// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import '../../domain/entities/allergy.dart';

/// Data transfer object for [Allergy] with JSON serialization.
///
/// The domain entity also serves as an Isar collection; this DTO
/// provides an alternative serialization path (e.g. for API payloads).
class AllergyDto {
  final int? id;
  final String allergen;
  final String? severity;
  final String? reaction;
  final String? notes;
  final DateTime recordedAt;
  final String? source;

  const AllergyDto({
    this.id,
    required this.allergen,
    this.severity,
    this.reaction,
    this.notes,
    required this.recordedAt,
    this.source,
  });

  factory AllergyDto.fromEntity(Allergy entity) => AllergyDto(
        id: entity.id,
        allergen: entity.allergen,
        severity: entity.severity,
        reaction: entity.reaction,
        notes: entity.notes,
        recordedAt: entity.recordedAt,
        source: entity.source,
      );

  Allergy toEntity() => Allergy(
        id: id,
        allergen: allergen,
        severity: severity,
        reaction: reaction,
        notes: notes,
        recordedAt: recordedAt,
        source: source,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'allergen': allergen,
        if (severity != null) 'severity': severity,
        if (reaction != null) 'reaction': reaction,
        if (notes != null) 'notes': notes,
        'recordedAt': recordedAt.toIso8601String(),
        if (source != null) 'source': source,
      };

  factory AllergyDto.fromJson(Map<String, dynamic> json) => AllergyDto(
        id: json['id'] as int?,
        allergen: json['allergen'] as String,
        severity: json['severity'] as String?,
        reaction: json['reaction'] as String?,
        notes: json['notes'] as String?,
        recordedAt: DateTime.parse(json['recordedAt'] as String),
        source: json['source'] as String?,
      );
}
