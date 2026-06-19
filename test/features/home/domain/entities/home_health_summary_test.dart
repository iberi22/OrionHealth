import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/home/domain/entities/home_health_summary.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';

void main() {
  group('HomeHealthSummary', () {
    final tVitals = [
      VitalSign(
        type: VitalSignType.heartRate,
        value: 70,
        dateTime: DateTime(2025, 1, 1),
      ),
    ];
    final tAppointments = [
      Appointment(
        doctorName: 'Dr. Smith',
        specialty: 'Cardiology',
        dateTime: DateTime(2025, 1, 10),
        status: AppointmentStatus.upcoming,
      ),
    ];

    test('should support value equality', () {
      final summary1 = HomeHealthSummary(
        latestVitals: tVitals,
        upcomingAppointments: tAppointments,
        medicationCount: 5,
      );
      final summary2 = HomeHealthSummary(
        latestVitals: tVitals,
        upcomingAppointments: tAppointments,
        medicationCount: 5,
      );

      expect(summary1, equals(summary2));
    });

    test('should have correct props', () {
      final summary = HomeHealthSummary(
        latestVitals: tVitals,
        upcomingAppointments: tAppointments,
        medicationCount: 5,
      );

      expect(summary.props, [tVitals, tAppointments, 5]);
    });
  });
}
