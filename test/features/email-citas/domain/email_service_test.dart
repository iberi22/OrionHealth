import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/email-citas/domain/services/email_service.dart';
import 'package:orionhealth_health/features/email-citas/domain/entities/email_template.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';

void main() {
  group('EmailService', () {
    late EmailService emailService;
    late Appointment appointment;

    setUp(() {
      emailService = EmailService();
      appointment = Appointment(
        doctorName: 'Juan Perez',
        specialty: 'Cardiología',
        dateTime: DateTime(2025, 5, 20, 10, 30),
        status: AppointmentStatus.upcoming,
        notes: 'Clínica: CardioCenter. EPS: Sura',
      );
    });

    test('interpolate correctly replaces placeholders in body', () {
      const template = 'Dr. {{doctor}}, Especialidad: {{specialty}}, Fecha: {{date}}, Hora: {{time}}, Lugar: {{location}}';
      final result = emailService.interpolate(template, appointment);

      expect(result, contains('Dr. Juan Perez'));
      expect(result, contains('Especialidad: Cardiología'));
      expect(result, contains('Fecha: 20/05/2025'));
      expect(result, contains('Hora: 10:30'));
      expect(result, contains('Lugar: CardioCenter'));
    });

    test('interpolate handles missing location in notes', () {
      appointment.notes = 'Some other notes';
      const template = 'Lugar: {{location}}';
      final result = emailService.interpolate(template, appointment);
      expect(result, contains('Lugar: N/A'));
    });

    test('isValidEmail validates email formats correctly', () {
      expect(emailService.isValidEmail('test@example.com'), isTrue);
      expect(emailService.isValidEmail('test.name+filter@example.co.uk'), isTrue);
      expect(emailService.isValidEmail('invalid-email'), isFalse);
      expect(emailService.isValidEmail('test@'), isFalse);
      expect(emailService.isValidEmail('@example.com'), isFalse);
    });

    test('sendEmail returns true for valid email and succeeds', () async {
      final result = await emailService.sendEmail(
        'patient@example.com',
        EmailTemplate.confirmation,
        appointment,
      );
      expect(result, isTrue);
    });

    test('sendEmail returns false for invalid email', () async {
      final result = await emailService.sendEmail(
        'invalid-email',
        EmailTemplate.confirmation,
        appointment,
      );
      expect(result, isFalse);
    });

    test('sendEmail returns false for failed send scenario', () async {
      final result = await emailService.sendEmail(
        'fail@example.com',
        EmailTemplate.confirmation,
        appointment,
      );
      expect(result, isFalse);
    });
  });
}
