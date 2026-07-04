import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/medications/application/bloc/medication_bloc.dart';
import 'package:orionhealth_health/features/medications/domain/repositories/medication_repository.dart';

class MockMedicationRepository extends Mock implements MedicationRepository {}

void main() {
  late MedicationBloc bloc;
  late MockMedicationRepository mockRepository;

  setUp(() {
    mockRepository = MockMedicationRepository();
    bloc = MedicationBloc(mockRepository);
  });

  test('initial state is MedicationInitial', () {
    expect(bloc.state, isA<MedicationInitial>());
  });
}
