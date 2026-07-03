import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/appointments/data/models/appointment_dto.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';

void main() {
  final tDateTime = DateTime(2023, 10, 10, 10, 0);
  final tAppointment = Appointment(
    id: 1,
    doctorName: 'Dr. Smith',
    specialty: 'Cardiology',
    dateTime: tDateTime,
    durationInMinutes: 45,
    notes: 'Checkup',
    status: AppointmentStatus.upcoming,
  );

  final tDto = AppointmentDto(
    id: 1,
    doctorName: 'Dr. Smith',
    specialty: 'Cardiology',
    dateTime: tDateTime,
    durationInMinutes: 45,
    notes: 'Checkup',
    status: 'upcoming',
  );

  final tJson = {
    'id': 1,
    'doctorName': 'Dr. Smith',
    'specialty': 'Cardiology',
    'dateTime': tDateTime.toIso8601String(),
    'durationInMinutes': 45,
    'recurrenceRule': null,
    'notes': 'Checkup',
    'source': null,
    'status': 'upcoming',
  };

  group('AppointmentDto', () {
    test('fromEntity should return a valid DTO', () {
      final result = AppointmentDto.fromEntity(tAppointment);
      expect(result.id, tDto.id);
      expect(result.doctorName, tDto.doctorName);
      expect(result.specialty, tDto.specialty);
      expect(result.dateTime, tDto.dateTime);
      expect(result.durationInMinutes, tDto.durationInMinutes);
      expect(result.notes, tDto.notes);
      expect(result.status, tDto.status);
    });

    test('toEntity should return a valid entity', () {
      final result = tDto.toEntity();
      expect(result.id, tAppointment.id);
      expect(result.doctorName, tAppointment.doctorName);
      expect(result.specialty, tAppointment.specialty);
      expect(result.dateTime, tAppointment.dateTime);
      expect(result.durationInMinutes, tAppointment.durationInMinutes);
      expect(result.notes, tAppointment.notes);
      expect(result.status, tAppointment.status);
    });

    test('fromJson should return a valid DTO', () {
      final result = AppointmentDto.fromJson(tJson);
      expect(result.id, tDto.id);
      expect(result.doctorName, tDto.doctorName);
      expect(result.specialty, tDto.specialty);
      expect(result.dateTime, tDto.dateTime);
      expect(result.durationInMinutes, tDto.durationInMinutes);
      expect(result.notes, tDto.notes);
      expect(result.status, tDto.status);
    });

    test('toJson should return a JSON map containing proper data', () {
      final result = tDto.toJson();
      expect(result, tJson);
    });

    test('toEntity should use default status if status is invalid', () {
      final dto = AppointmentDto(
        doctorName: 'Dr. Smith',
        specialty: 'Cardiology',
        dateTime: tDateTime,
        status: 'invalid_status',
      );
      final result = dto.toEntity();
      expect(result.status, AppointmentStatus.upcoming);
    });
  });
}
