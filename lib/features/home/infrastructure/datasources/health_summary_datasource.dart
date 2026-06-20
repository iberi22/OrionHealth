// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:injectable/injectable.dart';

// Placeholder for health summary datasource if needed in the future
@injectable
class HealthSummaryDatasource {
  HealthSummaryDatasource();

  /// Fetches a summary of the patient's health data.
  ///
  /// Currently a placeholder that returns a static mock summary.
  Future<String> getHealthSummary() async {
    return 'Resumen de salud: El paciente presenta signos vitales estables y sigue su tratamiento para la hipertensión.';
  }
}
