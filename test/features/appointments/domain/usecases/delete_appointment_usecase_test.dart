import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:orionhealth_health/features/appointments/domain/usecases/delete_appointment_usecase.dart';

class MockAppointmentRepository extends Mock implements AppointmentRepository {}

void main() {
  late DeleteAppointmentUseCase useCase;
  late MockAppointmentRepository mockRepository;

  setUp(() {
    mockRepository = MockAppointmentRepository();
    useCase = DeleteAppointmentUseCase(mockRepository);
  });

  const tId = 1;

  test('should delete appointment from the repository', () async {
    // arrange
    when(() => mockRepository.deleteAppointment(any()))
        .thenAnswer((_) async => {});
    // act
    await useCase(tId);
    // assert
    verify(() => mockRepository.deleteAppointment(tId));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw exception when repository fails to delete', () async {
    // arrange
    when(() => mockRepository.deleteAppointment(any()))
        .thenThrow(Exception('Delete failed'));
    // act
    final call = useCase(tId);
    // assert
    expect(() => call, throwsException);
    verify(() => mockRepository.deleteAppointment(tId));
  });
}
