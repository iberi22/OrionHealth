import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orionhealth_health/features/network/governance/presentation/pages/governance_page.dart';
import 'package:orionhealth_health/features/network/governance/application/governance_cubit.dart';
import '../../../../../core/golden_test_utils.dart';

class MockGovernanceCubit extends Mock implements GovernanceCubit {}

void main() {
  late MockGovernanceCubit mockGovernanceCubit;

  setUp(() async {
    mockGovernanceCubit = MockGovernanceCubit();

    await GetIt.I.reset();
    GetIt.I.registerSingleton<GovernanceCubit>(mockGovernanceCubit);

    when(() => mockGovernanceCubit.loadProposals()).thenAnswer((_) async {});
    when(() => mockGovernanceCubit.state).thenReturn(const GovernanceState(proposals: []));
    when(() => mockGovernanceCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockGovernanceCubit.close()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('Governance Page Golden Tests', () {
    testWidgets('Governance Page - Initial', (tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(
        BlocProvider<GovernanceCubit>.value(
          value: mockGovernanceCubit,
          child: wrapWithMaterial(const GovernancePage()),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(GovernancePage),
        matchesGoldenFile("goldens/governance_page.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
