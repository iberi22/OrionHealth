import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/email-citas/domain/entities/email_template.dart';

void main() {
  group('EmailTemplate', () {
    test('supports custom subject and body', () {
      final template = EmailTemplate(
        subject: 'Test Subject',
        body: 'Test Body',
      );
      expect(template.subject, 'Test Subject');
      expect(template.body, 'Test Body');
    });

    test('confirmation template has correct subject', () {
      expect(EmailTemplate.confirmation.subject, contains('Confirmaci'));
      expect(EmailTemplate.confirmation.subject, contains('{{specialty}}'));
    });

    test('reminder template has correct subject', () {
      expect(EmailTemplate.reminder.subject, contains('Recordatorio'));
      expect(EmailTemplate.reminder.subject, contains('{{specialty}}'));
    });

    test('templates are not equal when custom', () {
      final t1 = EmailTemplate(subject: 'A', body: 'B');
      final t2 = EmailTemplate(subject: 'C', body: 'D');
      expect(t1, isNot(equals(t2)));
      final t3 = EmailTemplate(subject: 'A', body: 'B');
      expect(t1, equals(t3));
    });
  });
}
