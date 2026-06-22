import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/features/network/incentives/presentation/pages/incentives_page.dart';
import 'package:orionhealth_health/features/network/incentives/application/incentive_cubit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'utils/video_recorder.dart';

class MockIncentiveCubit extends Mock implements IncentiveCubit {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockIncentiveCubit mockCubit;

  setUp(() {
    mockCubit = MockIncentiveCubit();
    getIt.registerSingleton<IncentiveCubit>(mockCubit);

    when(() => mockCubit.loadIncentiveData(any())).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    getIt.unregister<IncentiveCubit>();
  });

  group('Incentives Flow - E2E Tests', () {
    testWidgets('E2E: Contributions and Rewards', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const IncentiveState(
        status: IncentiveStatus.loaded,
        totalPoints: 1500,
        contributions: [],
      ));

      await tester.pumpWidget(const MaterialApp(home: IncentivesPage(userId: 'user1')));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'incentives', '01_dashboard');

      expect(find.text('1500'), findsOneWidget);
      expect(find.text('TOTAL DE PUNTOS'), findsOneWidget);
    });
  });
}
