import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';

class SharedHealthPackage {
  final UserProfile? profile;
  final List<Allergy> allergies;
  final List<Medication> medications;
  final List<VitalSign> vitals;
  final List<Appointment> appointments;
  final DateTime sharedAt;

  SharedHealthPackage({
    this.profile,
    this.allergies = const [],
    this.medications = const [],
    this.vitals = const [],
    this.appointments = const [],
    DateTime? sharedAt,
  }) : sharedAt = sharedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'profile': profile != null ? {
        'name': profile!.name,
        'age': profile!.age,
        'weight': profile!.weight,
        'height': profile!.height,
        'bloodType': profile!.bloodType,
        'uniqueId': profile!.uniqueId,
        'email': profile!.email,
        'phoneNumber': profile!.phoneNumber,
      } : null,
      'allergies': allergies.map((e) => {
        'name': e.name,
        'severity': e.severity.name,
        'reaction': e.reaction,
        'confirmedDate': e.confirmedDate?.toIso8601String(),
        'notes': e.notes,
        'isCritical': e.isCritical,
      }).toList(),
      'medications': medications.map((e) => {
        'name': e.name,
        'dosage': e.dosage,
        'frequency': e.frequency,
        'startDate': e.startDate.toIso8601String(),
        'isActive': e.isActive,
        'notes': e.notes,
      }).toList(),
      'vitals': vitals.map((e) => {
        'type': e.type.name,
        'value': e.value,
        'unit': e.unit,
        'recordedAt': e.recordedAt?.toIso8601String(),
        'source': e.source,
        'notes': e.notes,
      }).toList(),
      'appointments': appointments.map((e) => {
        'doctorName': e.doctorName,
        'specialty': e.specialty,
        'dateTime': e.dateTime?.toIso8601String(),
        'status': e.status.name,
        'type': e.type.name,
        'location': e.location,
        'notes': e.notes,
        'durationMinutes': e.durationMinutes,
      }).toList(),
      'sharedAt': sharedAt.toIso8601String(),
    };
  }

  factory SharedHealthPackage.fromJson(Map<String, dynamic> json) {
    return SharedHealthPackage(
      profile: json['profile'] != null ? UserProfile(
        name: json['profile']['name'],
        age: json['profile']['age'],
        weight: json['profile']['weight']?.toDouble(),
        height: json['profile']['height']?.toDouble(),
        bloodType: json['profile']['bloodType'],
        uniqueId: json['profile']['uniqueId'],
        email: json['profile']['email'],
        phoneNumber: json['profile']['phoneNumber'],
      ) : null,
      allergies: (json['allergies'] as List? ?? []).map((e) => Allergy(
        name: e['name'],
        severity: AllergySeverity.values.byName(e['severity']),
        reaction: e['reaction'],
        confirmedDate: e['confirmedDate'] != null ? DateTime.parse(e['confirmedDate']) : null,
        notes: e['notes'],
        isCritical: e['isCritical'] ?? false,
      )).toList(),
      medications: (json['medications'] as List? ?? []).map((e) => Medication(
        name: e['name'],
        dosage: e['dosage'],
        frequency: e['frequency'],
        startDate: DateTime.parse(e['startDate']),
        isActive: e['isActive'] ?? true,
        notes: e['notes'],
      )).toList(),
      vitals: (json['vitals'] as List? ?? []).map((e) => VitalSign(
        type: VitalSignType.values.byName(e['type']),
        value: e['value']?.toDouble(),
        unit: e['unit'],
        recordedAt: e['recordedAt'] != null ? DateTime.parse(e['recordedAt']) : null,
        source: e['source'],
        notes: e['notes'],
      )).toList(),
      appointments: (json['appointments'] as List? ?? []).map((e) => Appointment(
        doctorName: e['doctorName'],
        specialty: e['specialty'],
        dateTime: e['dateTime'] != null ? DateTime.parse(e['dateTime']) : null,
        status: AppointmentStatus.values.byName(e['status']),
        type: AppointmentType.values.byName(e['type']),
        location: e['location'],
        notes: e['notes'],
        durationMinutes: e['durationMinutes'],
      )).toList(),
      sharedAt: DateTime.parse(json['sharedAt']),
    );
  }
}
