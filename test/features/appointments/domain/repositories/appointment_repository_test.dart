import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/features/appointments/domain/repositories/appointment_repository.dart';

class MockAppointmentRepository extends Mock implements AppointmentRepository {}
class FakeAppointment extends Fake implements Appointment {}

void main() {
  late MockAppointmentRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeAppointment());
  });

  setUp(() {
    mockRepository = MockAppointmentRepository();
  });

  group('AppointmentRepository Interface', () {
    test('can be mocked and called', () async {
      final tAppointment = Appointment(
        doctorName: 'Dr. Smith',
        specialty: 'Cardiology',
        dateTime: DateTime.now(),
        status: AppointmentStatus.upcoming,
      );

      when(() => mockRepository.getAppointments()).thenAnswer((_) async => [tAppointment]);
      when(() => mockRepository.saveAppointment(any())).thenAnswer((_) async {});
      when(() => mockRepository.deleteAppointment(any())).thenAnswer((_) async {});

      final appointments = await mockRepository.getAppointments();
      await mockRepository.saveAppointment(tAppointment);
      await mockRepository.deleteAppointment(1);

      expect(appointments, [tAppointment]);

      verify(() => mockRepository.getAppointments()).called(1);
      verify(() => mockRepository.saveAppointment(tAppointment)).called(1);
      verify(() => mockRepository.deleteAppointment(1)).called(1);
    });
  });
}
