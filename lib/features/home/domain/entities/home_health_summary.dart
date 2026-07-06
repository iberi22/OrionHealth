// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:equatable/equatable.dart';
import '../../../vitals/domain/entities/vital_sign.dart';
import '../../../appointments/domain/entities/appointment.dart';

class HomeHealthSummary extends Equatable {
  final List<VitalSign> latestVitals;
  final List<Appointment> upcomingAppointments;
  final int medicationCount;
  final String summaryText;

  const HomeHealthSummary({
    required this.latestVitals,
    required this.upcomingAppointments,
    required this.medicationCount,
    required this.summaryText,
  });

  @override
  List<Object?> get props => [
    latestVitals,
    upcomingAppointments,
    medicationCount,
    summaryText,
  ];
}
