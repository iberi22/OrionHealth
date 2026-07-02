import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/home/domain/entities/home_health_summary.dart';
import 'package:orionhealth_health/features/home/domain/entities/home_module.dart';
import 'package:orionhealth_health/features/home/domain/repositories/home_repository.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:flutter/material.dart';

class MockHomeRepository extends Mock implements HomeRepository {}
class FakeHomeHealthSummary extends Fake implements HomeHealthSummary {}
class FakeHomeModule extends Fake implements HomeModule {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeHomeHealthSummary());
    registerFallbackValue(FakeHomeModule());
  });

  group('HomeRepository Interface', () {
    late MockHomeRepository mockRepository;

    setUp(() {
      mockRepository = MockHomeRepository();
    });

    test('getHealthSummary returns a HomeHealthSummary', () async {
      final tSummary = HomeHealthSummary(
        latestVitals: [
          VitalSign(
            type: VitalSignType.heartRate,
            value: 72,
            dateTime: DateTime(2025, 1, 1),
          ),
        ],
        upcomingAppointments: [
          Appointment(
            doctorName: 'Dr. Smith',
            specialty: 'Cardiology',
            dateTime: DateTime(2025, 1, 10),
            status: AppointmentStatus.upcoming,
          ),
        ],
        medicationCount: 3,
      );

      when(() => mockRepository.getHealthSummary())
          .thenAnswer((_) async => tSummary);

      final result = await mockRepository.getHealthSummary();

      expect(result, tSummary);
      expect(result.medicationCount, 3);
      expect(result.latestVitals.length, 1);
      expect(result.upcomingAppointments.length, 1);

      verify(() => mockRepository.getHealthSummary()).called(1);
    });

    test('getHomeModules returns a list of HomeModule', () async {
      final tModules = [
        HomeModule(
          title: 'Vitals',
          iconCode: 0xe8b8,
          color: const Color(0xFF4CAF50),
          route: '/vitals',
        ),
        HomeModule(
          title: 'Reports',
          iconCode: 0xe8b8,
          color: const Color(0xFF2196F3),
          route: '/reports',
        ),
      ];

      when(() => mockRepository.getHomeModules())
          .thenAnswer((_) async => tModules);

      final result = await mockRepository.getHomeModules();

      expect(result, tModules);
      expect(result.length, 2);
      expect(result[0].title, 'Vitals');
      expect(result[1].title, 'Reports');

      verify(() => mockRepository.getHomeModules()).called(1);
    });

    test('getHealthSummary throws on error', () async {
      when(() => mockRepository.getHealthSummary())
          .thenThrow(Exception('Network error'));

      expect(
        () async => await mockRepository.getHealthSummary(),
        throwsA(isA<Exception>()),
      );

      verify(() => mockRepository.getHealthSummary()).called(1);
    });
  });
}
