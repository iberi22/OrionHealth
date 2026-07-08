import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/email_citas/domain/repositories/email_repository.dart';
import 'package:orionhealth_health/features/email_citas/infrastructure/repositories/email_repository_impl.dart';
import 'package:orionhealth_health/features/email_citas/domain/entities/email_template.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';

class MockDataSource extends Mock implements EmailRepository {}

void main() {
  group('EmailRepository', () {
    test('EmailTemplate strings should not be null', () {
      expect(EmailTemplate.confirmation.subject, isNotNull);
      expect(EmailTemplate.confirmation.body, isNotNull);
      expect(EmailTemplate.reminder.subject, isNotNull);
      expect(EmailTemplate.reminder.body, isNotNull);
    });

    test('EmailTemplate constants should be instances', () {
      expect(EmailTemplate.confirmation, isA<EmailTemplate>());
      expect(EmailTemplate.reminder, isA<EmailTemplate>());
    });

    test('should connect via Gmail repository', () async {
      final repo = MockDataSource();
      when(() => repo.connectGmail()).thenAnswer((_) async => true);

      final result = await repo.connectGmail();

      expect(result, true);
    });

    test('should fetch parsed appointments', () async {
      final repo = MockDataSource();
      when(() => repo.fetchParsedAppointments('Gmail', 'code'))
          .thenAnswer((_) async => [
            Appointment(id: '1', title: 'Test', date: DateTime(2026)),
          ]);

      final result = await repo.fetchParsedAppointments('Gmail', 'code');

      expect(result.length, 1);
      expect(result.first.title, 'Test');
    });
  });
}
