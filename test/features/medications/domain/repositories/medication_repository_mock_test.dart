import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/medications/domain/repositories/medication_repository.dart';

class MockMedicationRepository extends Mock implements MedicationRepository {}

void main() {
  late MockMedicationRepository mockRepository;

  setUp(() {
    mockRepository = MockMedicationRepository();
  });

  test('MockMedicationRepository can be instantiated', () {
    expect(mockRepository, isNotNull);
  });
}
