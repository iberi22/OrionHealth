import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/medical_research/presentation/widgets/interaction_checker_widget.dart';
import 'package:orionhealth_health/features/medical_research/application/medical_research_cubit.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import '../../../../core/golden_test_utils.dart';

class MockMedicalResearchCubit extends Mock implements MedicalResearchCubit {}

void main() {
  late MockMedicalResearchCubit mockCubit;

  setUpAll(() {
    getIt.allowReassignment = true;
  });

  setUp(() {
    mockCubit = MockMedicalResearchCubit();
    getIt.registerSingleton<MedicalResearchCubit>(mockCubit);

    when(() => mockCubit.close()).thenAnswer((_) async => {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    getIt.reset();
  });

  testWidgets('InteractionCheckerWidget golden test', (tester) async {
    setupGoldenTest(tester);
    when(() => mockCubit.state).thenReturn(const MedicalResearchState());

    await tester.pumpWidget(
      wrapWithMaterial(
        BlocProvider<MedicalResearchCubit>.value(
          value: mockCubit,
          child: const Scaffold(body: InteractionCheckerWidget()),
        ),
      ),
    );
    await expectLater(
      find.byType(InteractionCheckerWidget),
      matchesGoldenFile('goldens/interaction_checker_widget.png'),
    );
    resetGoldenTest(tester);
  });
}
