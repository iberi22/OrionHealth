import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:orionhealth_health/features/appointments/domain/usecases/save_appointment_usecase.dart';

class MockAppointmentRepository extends Mock implements AppointmentRepository {}

class AppointmentFake extends Fake implements Appointment {}

void main() {
  setUpAll(() {
    registerFallbackValue(AppointmentFake());
  });

  late SaveAppointmentUseCase useCase;
  late MockAppointmentRepository mockRepository;

  setUp(() {
    mockRepository = MockAppointmentRepository();
    useCase = SaveAppointmentUseCase(mockRepository);
  });

  final tAppointment = Appointment(
    doctorName: 'Dr. Smith',
    specialty: 'Cardio',
    dateTime: DateTime(2023, 10, 10),
    status: AppointmentStatus.upcoming,
  );

  test('should save appointment in the repository', () async {
    // arrange
    when(() => mockRepository.saveAppointment(any()))
        .thenAnswer((_) async => {});
    // act
    await useCase(tAppointment);
    // assert
    verify(() => mockRepository.saveAppointment(tAppointment));
    verifyNoMoreInteractions(mockRepository);
  });
}
