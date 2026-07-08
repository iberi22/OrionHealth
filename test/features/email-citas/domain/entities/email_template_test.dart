import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/email_citas/domain/entities/email_template.dart';

void main() {
  group('EmailTemplate', () {
    test('should create instance with subject and body', () {
      const template = EmailTemplate(subject: 'Test', body: 'Hello');

      expect(template.subject, 'Test');
      expect(template.body, 'Hello');
    });

    test('should support equality', () {
      const a = EmailTemplate(subject: 'Sub', body: 'Body');
      const b = EmailTemplate(subject: 'Sub', body: 'Body');
      const c = EmailTemplate(subject: 'Other', body: 'Body');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('should have confirmation template', () {
      expect(EmailTemplate.confirmation.subject, contains('Confirmaci' + String.fromCharCode(243) + 'n'));
      expect(EmailTemplate.confirmation.body, contains('{{doctor}}'));
      expect(EmailTemplate.confirmation.body, contains('{{date}}'));
    });

    test('should have reminder template', () {
      expect(EmailTemplate.reminder.subject, contains('Recordatorio'));
      expect(EmailTemplate.reminder.body, contains('{{doctor}}'));
      expect(EmailTemplate.reminder.body, contains('{{time}}'));
    });

    test('should have correct hash code', () {
      const a = EmailTemplate(subject: 'Sub', body: 'Body');
      const b = EmailTemplate(subject: 'Sub', body: 'Body');

      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
