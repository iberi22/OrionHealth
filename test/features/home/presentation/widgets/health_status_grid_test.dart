import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orionhealth_health/features/home/application/home_cubit.dart';
import 'package:orionhealth_health/features/home/application/home_state.dart';
import 'package:orionhealth_health/features/home/presentation/widgets/health_status_grid.dart';
import 'package:orionhealth_health/features/home/domain/entities/home_health_summary.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';

class MockHomeCubit extends Mock implements HomeCubit {}

void main() {
  late MockHomeCubit mockHomeCubit;

  setUp(() {
    mockHomeCubit = MockHomeCubit();
    when(() => mockHomeCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<HomeCubit>.value(
          value: mockHomeCubit,
          child: const HealthStatusGrid(),
        ),
      ),
    );
  }

  testWidgets('displays vital signs when data is available', (tester) async {
    final vitals = [
      VitalSign(
        type: VitalSignType.heartRate,
        value: 72,
        dateTime: DateTime.now(),
      ),
      VitalSign(
        type: VitalSignType.temperature,
        value: 36.6,
        dateTime: DateTime.now(),
      ),
      VitalSign(
        type: VitalSignType.steps,
        value: 5000,
        dateTime: DateTime.now(),
      ),
      VitalSign(
        type: VitalSignType.spO2,
        value: 98,
        dateTime: DateTime.now(),
      ),
    ];

    when(() => mockHomeCubit.state).thenReturn(HomeState(
      status: HomeStatus.loaded,
      healthSummary: HomeHealthSummary(
        latestVitals: vitals,
        upcomingAppointments: const [],
        medicationCount: 0,
      ),
    ));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('72 bpm'), findsOneWidget);
    expect(find.text('36.6°C'), findsOneWidget);
    expect(find.text('5000 steps'), findsOneWidget);
    expect(find.text('98%'), findsOneWidget);
  });

  testWidgets('displays -- when data is missing', (tester) async {
    when(() => mockHomeCubit.state).thenReturn(const HomeState(
      status: HomeStatus.loaded,
      healthSummary: HomeHealthSummary(
        latestVitals: [],
        upcomingAppointments: [],
        medicationCount: 0,
      ),
    ));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('--'), findsNWidgets(4));
  });
}
