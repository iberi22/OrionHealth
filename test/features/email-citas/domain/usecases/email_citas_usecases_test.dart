import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/features/email-citas/domain/repositories/email_repository.dart';
import 'package:orionhealth_health/features/email-citas/domain/usecases/email_citas_usecases.dart';

class MockEmailRepository extends Mock implements EmailRepository {}

void main() {
  late MockEmailRepository mockRepository;
  late ConnectEmailProviderUseCase connectUseCase;
  late SyncEmailAppointmentsUseCase syncUseCase;

  setUp(() {
    mockRepository = MockEmailRepository();
    connectUseCase = ConnectEmailProviderUseCase(mockRepository);
    syncUseCase = SyncEmailAppointmentsUseCase(mockRepository);
  });

  group('ConnectEmailProviderUseCase', () {
    test('should connect Gmail when provider is Gmail', () async {
      when(() => mockRepository.connectGmail()).thenAnswer((_) async => true);

      final result = await connectUseCase('Gmail');

      expect(result, true);
      verify(() => mockRepository.connectGmail()).called(1);
    });

    test('should connect Outlook when provider is Outlook', () async {
      when(() => mockRepository.connectOutlook()).thenAnswer((_) async => true);

      final result = await connectUseCase('Outlook');

      expect(result, true);
      verify(() => mockRepository.connectOutlook()).called(1);
    });

    test('should return false for unknown provider', () async {
      final result = await connectUseCase('Yahoo');

      expect(result, false);
    });
  });

  group('SyncEmailAppointmentsUseCase', () {
    test('should fetch parsed appointments from repository', () async {
      final tAppointments = [
        Appointment(
          doctorName: 'Dr. House',
          specialty: 'Diagnostic',
          dateTime: DateTime.now(),
          status: AppointmentStatus.upcoming,
        ),
      ];
      when(() => mockRepository.fetchParsedAppointments(any(), any()))
          .thenAnswer((_) async => tAppointments);

      final result = await syncUseCase('Gmail', 'auth_code');

      expect(result, tAppointments);
      verify(() => mockRepository.fetchParsedAppointments('Gmail', 'auth_code'))
          .called(1);
    });
  });
}
