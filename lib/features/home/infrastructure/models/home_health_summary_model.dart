// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import '../../domain/entities/home_health_summary.dart';

class HomeHealthSummaryModel extends HomeHealthSummary {
  const HomeHealthSummaryModel({
    required super.latestVitals,
    required super.upcomingAppointments,
    required super.medicationCount,
  });

  // Since HomeHealthSummary contains entities from other features,
  // serialization/deserialization might be complex if we want to include full objects.
  // For now, we'll implement a simple fromEntity.

  factory HomeHealthSummaryModel.fromEntity(HomeHealthSummary entity) {
    return HomeHealthSummaryModel(
      latestVitals: entity.latestVitals,
      upcomingAppointments: entity.upcomingAppointments,
      medicationCount: entity.medicationCount,
    );
  }
}
