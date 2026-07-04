// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/home/presentation/pages/home_page.dart';
import 'package:orionhealth_health/features/home/application/home_cubit.dart';
import 'package:orionhealth_health/features/home/application/home_state.dart';
import 'package:orionhealth_health/features/home/domain/entities/home_health_summary.dart';
import 'package:orionhealth_health/features/home/domain/entities/home_module.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import '../../../../core/golden_test_utils.dart';

class MockHomeCubit extends Mock implements HomeCubit {}

void main() {
  late MockHomeCubit mockHomeCubit;

  setUp(() {
    mockHomeCubit = MockHomeCubit();
    when(() => mockHomeCubit.loadDashboard()).thenAnswer((_) async {});
    when(() => mockHomeCubit.refresh()).thenAnswer((_) async {});
    when(() => mockHomeCubit.close()).thenAnswer((_) async {});
  });

  group('HomePage Golden Tests', () {
    testWidgets('HomePage Loading State', (tester) async {
      when(() => mockHomeCubit.state).thenReturn(
        const HomeState(status: HomeStatus.loading, modules: []),
      );
      when(() => mockHomeCubit.stream).thenAnswer(
        (_) => Stream.value(const HomeState(status: HomeStatus.loading, modules: [])),
      );

      setupGoldenTest(tester);

      await tester.pumpWidget(
        BlocProvider<HomeCubit>.value(
          value: mockHomeCubit,
          child: wrapWithMaterial(const HomePageView()),
        ),
      );

      await expectLater(
        find.byType(HomePageView),
        matchesGoldenFile('goldens/home_page_loading.png'),
      );

      resetGoldenTest(tester);
    });

    testWidgets('HomePage Loaded State', (tester) async {
      final mockModules = [
        const HomeModule(
          title: 'Historial',
          iconCode: 0xe88a, // history
          color: Colors.blue,
          route: '/history',
        ),
        const HomeModule(
          title: 'Medicamentos',
          iconCode: 0xe3d9, // medical_services
          color: Colors.green,
          route: '/medications',
        ),
      ];

      final mockVitals = [
        VitalSign(
          type: VitalSignType.heartRate,
          value: 72,
          dateTime: DateTime(2025, 1, 1, 10, 0),
        ),
        VitalSign(
          type: VitalSignType.temperature,
          value: 36.6,
          dateTime: DateTime(2025, 1, 1, 10, 0),
        ),
        VitalSign(
          type: VitalSignType.steps,
          value: 5432,
          dateTime: DateTime(2025, 1, 1, 10, 0),
        ),
        VitalSign(
          type: VitalSignType.spO2,
          value: 98,
          dateTime: DateTime(2025, 1, 1, 10, 0),
        ),
      ];

      final mockAppointments = [
        Appointment(
          id: 1,
          doctorName: 'Dr. Smith',
          specialty: 'Cardiology',
          dateTime: DateTime(2025, 2, 1, 15, 0),
          status: AppointmentStatus.upcoming,
        ),
      ];

      final loadedState = HomeState(
        status: HomeStatus.loaded,
        modules: mockModules,
        healthSummary: HomeHealthSummary(
          latestVitals: mockVitals,
          upcomingAppointments: mockAppointments,
          medicationCount: 3,
        ),
      );

      when(() => mockHomeCubit.state).thenReturn(loadedState);
      when(() => mockHomeCubit.stream).thenAnswer((_) => Stream.value(loadedState));

      setupGoldenTest(tester);

      await tester.pumpWidget(
        BlocProvider<HomeCubit>.value(
          value: mockHomeCubit,
          child: wrapWithMaterial(const HomePageView()),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(HomePageView),
        matchesGoldenFile('goldens/home_page_loaded.png'),
      );

      resetGoldenTest(tester);
    });
  });
}
