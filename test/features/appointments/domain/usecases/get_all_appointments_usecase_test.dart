import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:orionhealth_health/features/appointments/domain/usecases/get_all_appointments_usecase.dart';

class MockAppointmentRepository extends Mock implements AppointmentRepository {}

void main() {
  late GetAllAppointmentsUseCase useCase;
  late MockAppointmentRepository mockRepository;

  setUp(() {
    mockRepository = MockAppointmentRepository();
    useCase = GetAllAppointmentsUseCase(mockRepository);
  });

  final tAppointments = [
    Appointment(
      doctorName: 'Dr. Smith',
      specialty: 'Cardio',
      dateTime: DateTime(2023, 10, 10),
      status: AppointmentStatus.upcoming,
    ),
  ];

  test('should get all appointments from the repository', () async {
    // arrange
    when(() => mockRepository.getAllAppointments())
        .thenAnswer((_) async => tAppointments);
    // act
    final result = await useCase();
    // assert
    expect(result, tAppointments);
    verify(() => mockRepository.getAllAppointments());
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return empty list when repository returns empty', () async {
    // arrange
    when(() => mockRepository.getAllAppointments())
        .thenAnswer((_) async => []);
    // act
    final result = await useCase();
    // assert
    expect(result, []);
    verify(() => mockRepository.getAllAppointments());
  });

  test('should throw exception when repository fails', () async {
    // arrange
    when(() => mockRepository.getAllAppointments())
        .thenThrow(Exception('DB Error'));
    // act
    final call = useCase();
    // assert
    expect(() => call, throwsException);
    verify(() => mockRepository.getAllAppointments());
  });
}
