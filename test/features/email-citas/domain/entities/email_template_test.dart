import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/email-citas/domain/entities/email_template.dart';

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
      expect(EmailTemplate.confirmation.subject, contains('Confirmación'));
      expect(EmailTemplate.confirmation.subject, contains('{{specialty}}'));
      expect(EmailTemplate.confirmation.body, contains('{{doctor}}'));
      expect(EmailTemplate.confirmation.body, contains('{{specialty}}'));
      expect(EmailTemplate.confirmation.body, contains('{{date}}'));
      expect(EmailTemplate.confirmation.body, contains('{{time}}'));
      expect(EmailTemplate.confirmation.body, contains('{{notes}}'));
    });

    test('should have reminder template', () {
      expect(EmailTemplate.reminder.subject, contains('Recordatorio'));
      expect(EmailTemplate.reminder.subject, contains('{{specialty}}'));
      expect(EmailTemplate.reminder.body, contains('{{doctor}}'));
      expect(EmailTemplate.reminder.body, contains('{{specialty}}'));
      expect(EmailTemplate.reminder.body, contains('{{time}}'));
      expect(EmailTemplate.reminder.body, contains('{{location}}'));
    });

    test('should have correct hash code', () {
      const a = EmailTemplate(subject: 'Sub', body: 'Body');
      const b = EmailTemplate(subject: 'Sub', body: 'Body');

      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
