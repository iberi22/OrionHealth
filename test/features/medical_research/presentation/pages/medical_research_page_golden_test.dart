import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/medical_research/application/medical_research_cubit.dart';
import 'package:orionhealth_health/features/medical_research/presentation/pages/medical_research_page.dart';

class MockMedicalResearchCubit extends Mock implements MedicalResearchCubit {}

void main() {
  late MockMedicalResearchCubit mockCubit;

  setUpAll(() {
    final getIt = GetIt.instance;
    mockCubit = MockMedicalResearchCubit();
    getIt.registerFactory<MedicalResearchCubit>(() => mockCubit);

    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  testWidgets('MedicalResearchPage Golden Test', (WidgetTester tester) async {
    when(() => mockCubit.state).thenReturn(const MedicalResearchState());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(
      const MaterialApp(
        home: MedicalResearchPage(),
      ),
    );

    await expectLater(
      find.byType(MedicalResearchPage),
      matchesGoldenFile("../../../../../golden/reference/medical_research_page.png"),
    );
  });
}
