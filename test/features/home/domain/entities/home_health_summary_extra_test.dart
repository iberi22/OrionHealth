import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/home/domain/entities/home_health_summary.dart';

void main() {
  group('HomeHealthSummary', () {
    test('supports value equality', () {
      final summary1 = HomeHealthSummary(
        latestVitals: [],
        upcomingAppointments: [],
        medicationCount: 5, summaryText: "",
      );
      final summary2 = HomeHealthSummary(
        latestVitals: [],
        upcomingAppointments: [],
        medicationCount: 5, summaryText: "",
      );

      expect(summary1, equals(summary2));
    });

    test('props are correct', () {
      final summary = HomeHealthSummary(
        latestVitals: [],
        upcomingAppointments: [],
        medicationCount: 10, summaryText: "",
      );

      expect(summary.props, [[], [], 10, ""]);
    });
  });
}
