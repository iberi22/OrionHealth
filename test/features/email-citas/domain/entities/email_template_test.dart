import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/email-citas/domain/entities/email_template.dart';

void main() {
  group('EmailTemplate', () {
    test('confirmation template has correct subject', () {
      expect(EmailTemplate.confirmation.subject, contains('Confirmación de Cita'));
    });

    test('reminder template has correct subject', () {
      expect(EmailTemplate.reminder.subject, contains('Recordatorio de Cita'));
    });

    test('templates have expected properties', () {
      const template = EmailTemplate(subject: 'Sub', body: 'Body');
      expect(template.subject, 'Sub');
      expect(template.body, 'Body');
    });

    test('different templates are not equal', () {
      const template1 = EmailTemplate(subject: 'Sub 1', body: 'Body 1');
      const template2 = EmailTemplate(subject: 'Sub 2', body: 'Body 2');

      expect(template1.subject, isNot(template2.subject));
      expect(template1.body, isNot(template2.body));
    });
  });
}
