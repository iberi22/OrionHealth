import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/email_citas/domain/repositories/email_repository.dart';
import 'package:orionhealth_health/features/email_citas/domain/usecases/email_citas_usecases.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';

class MockEmailRepository extends Mock implements EmailRepository {}

void main() {
  late MockEmailRepository mockRepo;
  late ConnectEmailProviderUseCase connectUseCase;
  late SyncEmailAppointmentsUseCase syncUseCase;

  setUp(() {
    mockRepo = MockEmailRepository();
    connectUseCase = ConnectEmailProviderUseCase(mockRepo);
    syncUseCase = SyncEmailAppointmentsUseCase(mockRepo);
  });

  group('ConnectEmailProviderUseCase', () {
    test('should call connectGmail when provider is Gmail', () async {
      when(() => mockRepo.connectGmail()).thenAnswer((_) async => true);

      final result = await connectUseCase('Gmail');

      expect(result, true);
      verify(() => mockRepo.connectGmail()).called(1);
    });

    test('should call connectOutlook when provider is Outlook', () async {
      when(() => mockRepo.connectOutlook()).thenAnswer((_) async => true);

      final result = await connectUseCase('Outlook');

      expect(result, true);
      verify(() => mockRepo.connectOutlook()).called(1);
    });

    test('should return false for unknown provider', () async {
      final result = await connectUseCase('Yahoo');

      expect(result, false);
    });

    test('should return false when Gmail connection fails', () async {
      when(() => mockRepo.connectGmail()).thenAnswer((_) async => false);

      final result = await connectUseCase('Gmail');

      expect(result, false);
    });
  });

  group('SyncEmailAppointmentsUseCase', () {
    test('should call fetchParsedAppointments', () async {
      when(() => mockRepo.fetchParsedAppointments(any(), any()))
          .thenAnswer((_) async => []);

      final result = await syncUseCase('Gmail', 'code123');

      expect(result, isEmpty);
      verify(() => mockRepo.fetchParsedAppointments('Gmail', 'code123')).called(1);
    });

    test('should return appointments from repository', () async {
      final appointments = [
        Appointment(id: '1', title: 'Cita', date: DateTime(2026)),

      ];
      when(() => mockRepo.fetchParsedAppointments(any(), any()))
          .thenAnswer((_) async => appointments);

      final result = await syncUseCase('Outlook', 'abc');

      expect(result.length, 1);
      expect(result.first.id, '1');
    });
  });
}
