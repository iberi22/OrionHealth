import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/network/incentives/presentation/pages/incentives_page.dart';
import 'package:orionhealth_health/features/network/incentives/application/incentive_cubit.dart';
import '../../../../../core/golden_test_utils.dart';

class MockIncentiveCubit extends Mock implements IncentiveCubit {}

void main() {
  late MockIncentiveCubit mockIncentiveCubit;

  setUp(() async {
    mockIncentiveCubit = MockIncentiveCubit();

    await GetIt.I.reset();
    GetIt.I.registerSingleton<IncentiveCubit>(mockIncentiveCubit);

    when(() => mockIncentiveCubit.loadIncentiveData(any())).thenAnswer((_) async {});
    when(() => mockIncentiveCubit.state).thenReturn(const IncentiveState());
    when(() => mockIncentiveCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockIncentiveCubit.close()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('Incentives Page Golden Tests', () {
    testWidgets('Incentives Page - Initial', (tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(const IncentivesPage(userId: 'test-user')));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(IncentivesPage),
        matchesGoldenFile("goldens/incentives_page.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
