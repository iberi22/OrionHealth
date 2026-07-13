import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:carp_themes_package/carp_themes_package.dart';
import "package:orionhealth_health/features/clinical_assessments/domain/repositories/i_assessment_repository.dart";
import 'package:orionhealth_health/features/clinical_assessments/presentation/consent_screen.dart';
import '../../../../core/golden_test_utils.dart';
import '../../helpers/carp_test_utils.dart';

class MockAssessmentRepository extends Mock implements IAssessmentRepository {}

void main() {
  late MockAssessmentRepository mockRepository;

  setUp(() {
    mockRepository = MockAssessmentRepository();
  });

  group('ConsentScreen Golden Tests', () {
    testWidgets('ConsentScreen renders correctly', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(createCarpTestApp(
        ConsentScreen(repository: mockRepository),
      ));
      await tester.pump();

      await expectLater(
        find.byType(ConsentScreen),
        matchesGoldenFile("goldens/consent_screen.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
