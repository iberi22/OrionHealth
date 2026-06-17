import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/home/application/home_cubit.dart';
import 'package:orionhealth_health/features/home/application/home_state.dart';
import 'package:orionhealth_health/features/home/domain/entities/home_health_summary.dart';
import 'package:orionhealth_health/features/home/domain/entities/home_module.dart';
import 'package:orionhealth_health/features/home/domain/repositories/home_repository.dart';
import 'package:orionhealth_health/features/home/domain/usecases/get_health_summary_usecase.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';

class MockGetHealthSummaryUseCase extends Mock implements GetHealthSummaryUseCase {}
class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late HomeCubit cubit;
  late MockGetHealthSummaryUseCase mockUseCase;
  late MockHomeRepository mockRepository;

  setUp(() {
    mockUseCase = MockGetHealthSummaryUseCase();
    mockRepository = MockHomeRepository();
    cubit = HomeCubit(mockUseCase, mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  final tSummary = HomeHealthSummary(
    latestVitals: [
      VitalSign(
        type: VitalSignType.heartRate,
        value: 72,
        dateTime: DateTime(2026, 6, 17),
        unit: 'bpm',
      ),
    ],
    upcomingAppointments: [],
    medicationCount: 3,
  );

  final tModules = [
    const HomeModule(
      title: 'Medications',
      icon: Icons.medication,
      color: Colors.blue,
      route: '/medications',
    ),
  ];

  group('HomeCubit', () {
    test('initial state should be HomeState with status initial', () {
      expect(cubit.state.status, HomeStatus.initial);
      expect(cubit.state.healthSummary, isNull);
      expect(cubit.state.modules, isEmpty);
      expect(cubit.state.errorMessage, isNull);
    });

    test('emits [loading, loaded] when loadDashboard succeeds', () async {
      when(() => mockUseCase()).thenAnswer((_) async => tSummary);
      when(() => mockRepository.getHomeModules()).thenAnswer((_) async => tModules);

      final expectedStates = [
        const HomeState(status: HomeStatus.loading),
        HomeState(
          status: HomeStatus.loaded,
          healthSummary: tSummary,
          modules: tModules,
        ),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.loadDashboard();
    });

    test('emits [loading, error] when loadDashboard fails', () async {
      when(() => mockUseCase()).thenThrow(Exception('Network error'));

      final expectedStates = [
        const HomeState(status: HomeStatus.loading),
        const HomeState(
          status: HomeStatus.error,
          errorMessage: 'Exception: Network error',
        ),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.loadDashboard();
    });

    test('emits [loading, error] when getHomeModules fails', () async {
      when(() => mockUseCase()).thenAnswer((_) async => tSummary);
      when(() => mockRepository.getHomeModules()).thenThrow(Exception('Modules error'));

      final expectedStates = [
        const HomeState(status: HomeStatus.loading),
        const HomeState(
          status: HomeStatus.error,
          errorMessage: 'Exception: Modules error',
        ),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.loadDashboard();
    });

    test('refresh calls loadDashboard', () async {
      when(() => mockUseCase()).thenAnswer((_) async => tSummary);
      when(() => mockRepository.getHomeModules()).thenAnswer((_) async => tModules);

      await cubit.refresh();

      verify(() => mockUseCase()).called(1);
      verify(() => mockRepository.getHomeModules()).called(1);
    });

    test('state copyWith preserves unchanged values', () {
      const initial = HomeState(status: HomeStatus.loading);
      final updated = initial.copyWith(healthSummary: tSummary);

      expect(updated.status, HomeStatus.loading);
      expect(updated.healthSummary, tSummary);
      expect(updated.modules, isEmpty);
      expect(updated.errorMessage, isNull);
    });
  });
}
