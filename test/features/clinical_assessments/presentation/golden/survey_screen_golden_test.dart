import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import "package:orionhealth_health/features/clinical_assessments/domain/repositories/i_assessment_repository.dart";
import 'package:orionhealth_health/features/clinical_assessments/presentation/survey_screen.dart';
import '../../../../core/golden_test_utils.dart';
import '../../helpers/carp_test_utils.dart';

class MockAssessmentRepository extends Mock implements IAssessmentRepository {}

void main() {
  late MockAssessmentRepository mockRepository;

  setUp(() {
    mockRepository = MockAssessmentRepository();
  });

  group('SurveyScreen Golden Tests', () {
    testWidgets('SurveyScreen renders correctly', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(createCarpTestApp(
        SurveyScreen(repository: mockRepository),
      ));
      await tester.pump();

      await expectLater(
        find.byType(SurveyScreen),
        matchesGoldenFile("goldens/survey_screen.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
