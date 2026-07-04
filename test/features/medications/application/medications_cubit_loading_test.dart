import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/medications/application/medications_cubit.dart';
import 'package:orionhealth_health/features/medications/domain/repositories/medication_repository.dart';
import 'package:orionhealth_health/features/medications/application/medications_state.dart';

class MockMedicationRepository extends Mock implements MedicationRepository {}

void main() {
  late MedicationsCubit cubit;
  late MockMedicationRepository mockRepository;

  setUp(() {
    mockRepository = MockMedicationRepository();
    cubit = MedicationsCubit(mockRepository);
  });

  test('initial state is MedicationsInitial', () {
    expect(cubit.state, isA<MedicationsInitial>());
  });
}
