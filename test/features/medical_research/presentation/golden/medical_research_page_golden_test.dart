import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/medical_research/application/medical_research_cubit.dart';
import 'package:orionhealth_health/features/medical_research/presentation/pages/medical_research_page.dart';
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

  testWidgets('MedicalResearchPage golden test - loading state', (tester) async {
    setupGoldenTest(tester);
    when(() => mockCubit.state).thenReturn(const MedicalResearchState(
      status: MedicalResearchStatus.loading,
      loadingMessage: 'Cargando...',
    ));

    await tester.pumpWidget(
      wrapWithMaterial(const MedicalResearchPage()),
    );
    await tester.pump();

    await expectLater(
      find.byType(MedicalResearchPage),
      matchesGoldenFile('goldens/medical_research_loading.png'),
    );
    resetGoldenTest(tester);
  });
}
