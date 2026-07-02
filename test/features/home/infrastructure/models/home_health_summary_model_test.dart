import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/home/domain/entities/home_health_summary.dart';
import 'package:orionhealth_health/features/home/infrastructure/models/home_health_summary_model.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';

void main() {
  group('HomeHealthSummaryModel', () {
    final tVitals = [
      VitalSign(
        type: VitalSignType.heartRate,
        value: 72,
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

    test('fromEntity creates a model with the same properties', () {
      final entity = HomeHealthSummary(
        latestVitals: tVitals,
        upcomingAppointments: tAppointments,
        medicationCount: 5,
      );

      final model = HomeHealthSummaryModel.fromEntity(entity);

      expect(model.latestVitals, entity.latestVitals);
      expect(model.upcomingAppointments, entity.upcomingAppointments);
      expect(model.medicationCount, entity.medicationCount);
    });

    test('fromEntity preserves equality', () {
      final entity1 = HomeHealthSummary(
        latestVitals: tVitals,
        upcomingAppointments: tAppointments,
        medicationCount: 5,
      );
      final entity2 = HomeHealthSummary(
        latestVitals: tVitals,
        upcomingAppointments: tAppointments,
        medicationCount: 5,
      );

      final model1 = HomeHealthSummaryModel.fromEntity(entity1);
      final model2 = HomeHealthSummaryModel.fromEntity(entity2);

      expect(model1.latestVitals, model2.latestVitals);
      expect(model1.upcomingAppointments, model2.upcomingAppointments);
      expect(model1.medicationCount, model2.medicationCount);
    });

    test('fromEntity with empty lists', () {
      final entity = HomeHealthSummary(
        latestVitals: [],
        upcomingAppointments: [],
        medicationCount: 0,
      );

      final model = HomeHealthSummaryModel.fromEntity(entity);

      expect(model.latestVitals, isEmpty);
      expect(model.upcomingAppointments, isEmpty);
      expect(model.medicationCount, 0);
    });
  });
}
