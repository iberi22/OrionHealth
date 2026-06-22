import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/features/email-citas/domain/entities/email_template.dart';
import 'package:orionhealth_health/features/email-citas/domain/services/email_service.dart';

void main() {
  late EmailService service;

  setUp(() {
    service = EmailService();
  });

  group('EmailService', () {
    final appointment = Appointment(
      doctorName: 'Dr. Smith',
      specialty: 'Cardiology',
      dateTime: DateTime(2023, 10, 27, 10, 0),
      notes: 'Clínica: Central Park. EPS: Sura',
      status: AppointmentStatus.upcoming,
    );

    test('interpolate correctly replaces placeholders', () {
      const template = 'Hello {{doctor}}, your {{specialty}} appointment is on {{date}} at {{time}}. Location: {{location}}. Notes: {{notes}}';
      final result = service.interpolate(template, appointment);

      expect(result, contains('Dr. Smith'));
      expect(result, contains('Cardiology'));
      expect(result, contains('27/10/2023'));
      expect(result, contains('10:00'));
      expect(result, contains('Central Park'));
      expect(result, contains('Clínica: Central Park. EPS: Sura'));
    });

    test('interpolate handles missing location in notes', () {
      final appointmentNoLocation = Appointment(
        doctorName: 'Dr. House',
        specialty: 'Diagnostic',
        dateTime: DateTime(2023, 10, 27, 10, 0),
        notes: 'Just some notes',
        status: AppointmentStatus.upcoming,
      );
      const template = 'Location: {{location}}';
      final result = service.interpolate(template, appointmentNoLocation);

      expect(result, 'Location: N/A');
    });

    test('isValidEmail returns true for valid emails', () {
      expect(service.isValidEmail('test@example.com'), true);
      expect(service.isValidEmail('user.name+tag@sub.domain.co'), true);
    });

    test('isValidEmail returns false for invalid emails', () {
      expect(service.isValidEmail('test@example'), false);
      expect(service.isValidEmail('testexample.com'), false);
      expect(service.isValidEmail('@example.com'), false);
    });

    test('sendEmail returns true for valid email', () async {
      const template = EmailTemplate(subject: 'Sub', body: 'Body');
      final result = await service.sendEmail('test@example.com', template, appointment);
      expect(result, true);
    });

    test('sendEmail returns false for invalid email', () async {
      const template = EmailTemplate(subject: 'Sub', body: 'Body');
      final result = await service.sendEmail('invalid-email', template, appointment);
      expect(result, false);
    });

    test('sendEmail returns false for fail@example.com', () async {
      const template = EmailTemplate(subject: 'Sub', body: 'Body');
      final result = await service.sendEmail('fail@example.com', template, appointment);
      expect(result, false);
    });
  });
}
