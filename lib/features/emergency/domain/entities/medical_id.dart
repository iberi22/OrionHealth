/// FEAT-022: Emergency Data — Medical ID
///
/// Critical health information accessible in case of emergency.
/// Lock-screen friendly: shows ONLY critical fields by default.
/// Owner can edit full information via /emergency/edit.
///
/// Privacy:
/// - NEVER includes SSN, address, photo, insurance numbers
/// - All data stored locally (Isar mobile, SharedPreferences web)
/// - Shared only via QR (first responder scan) or explicit BLE/NFC
library;

import 'emergency_contact.dart';
import 'medical_condition.dart';

class MedicalIdEntity {
  final String userId;
  final String fullName;
  final DateTime dateOfBirth;
  final BloodType bloodType;
  final List<String> allergies; // critical allergies
  final List<String> currentMedications; // names only, no doses
  final List<MedicalCondition> chronicConditions;
  final EmergencyContact primaryContact;
  final EmergencyContact? secondaryContact;
  final OrganDonor organDonor;
  final String? dnrDirective; // Do Not Resuscitate
  final String? insuranceProvider; // provider name only
  final String? primaryPhysicianName;
  final String? primaryPhysicianPhone;
  final String? notes; // free text for first responders
  final DateTime lastUpdated;

  const MedicalIdEntity({
    required this.userId,
    required this.fullName,
    required this.dateOfBirth,
    required this.bloodType,
    this.allergies = const [],
    this.currentMedications = const [],
    this.chronicConditions = const [],
    required this.primaryContact,
    this.secondaryContact,
    this.organDonor = OrganDonor.unknown,
    this.dnrDirective,
    this.insuranceProvider,
    this.primaryPhysicianName,
    this.primaryPhysicianPhone,
    this.notes,
    required this.lastUpdated,
  });

  int get age {
    final now = DateTime.now();
    var age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  /// Critical fields for first responder (lock screen display).
  /// Returned as ordered list to render without keys leaking.
  List<String> toCriticalCard() => [
        fullName,
        '${bloodType.displayName} • $age años',
        if (allergies.isNotEmpty) 'Alergias: ${allergies.join(", ")}',
        'ICE: ${primaryContact.name} (${primaryContact.phone})',
      ];

  MedicalIdEntity copyWith({
    String? userId,
    String? fullName,
    DateTime? dateOfBirth,
    BloodType? bloodType,
    List<String>? allergies,
    List<String>? currentMedications,
    List<MedicalCondition>? chronicConditions,
    EmergencyContact? primaryContact,
    EmergencyContact? secondaryContact,
    OrganDonor? organDonor,
    String? dnrDirective,
    String? insuranceProvider,
    String? primaryPhysicianName,
    String? primaryPhysicianPhone,
    String? notes,
    DateTime? lastUpdated,
  }) =>
      MedicalIdEntity(
        userId: userId ?? this.userId,
        fullName: fullName ?? this.fullName,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        bloodType: bloodType ?? this.bloodType,
        allergies: allergies ?? this.allergies,
        currentMedications: currentMedications ?? this.currentMedications,
        chronicConditions: chronicConditions ?? this.chronicConditions,
        primaryContact: primaryContact ?? this.primaryContact,
        secondaryContact: secondaryContact ?? this.secondaryContact,
        organDonor: organDonor ?? this.organDonor,
        dnrDirective: dnrDirective ?? this.dnrDirective,
        insuranceProvider: insuranceProvider ?? this.insuranceProvider,
        primaryPhysicianName: primaryPhysicianName ?? this.primaryPhysicianName,
        primaryPhysicianPhone: primaryPhysicianPhone ?? this.primaryPhysicianPhone,
        notes: notes ?? this.notes,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'full_name': fullName,
        'date_of_birth': dateOfBirth.toIso8601String(),
        'blood_type': bloodType.code,
        'allergies': allergies,
        'current_medications': currentMedications,
        'chronic_conditions': chronicConditions.map((c) => c.toJson()).toList(),
        'primary_contact': primaryContact.toJson(),
        'secondary_contact': secondaryContact?.toJson(),
        'organ_donor': organDonor.name,
        'dnr_directive': dnrDirective,
        'insurance_provider': insuranceProvider,
        'primary_physician_name': primaryPhysicianName,
        'primary_physician_phone': primaryPhysicianPhone,
        'notes': notes,
        'last_updated': lastUpdated.toIso8601String(),
      };

  factory MedicalIdEntity.fromJson(Map<String, dynamic> json) => MedicalIdEntity(
        userId: json['user_id'] as String,
        fullName: json['full_name'] as String,
        dateOfBirth: DateTime.parse(json['date_of_birth'] as String),
        bloodType: BloodType.fromCode(json['blood_type'] as String),
        allergies: List<String>.from(json['allergies'] as List? ?? const []),
        currentMedications: List<String>.from(
            json['current_medications'] as List? ?? const []),
        chronicConditions: (json['chronic_conditions'] as List? ?? const [])
            .map((c) => MedicalCondition.fromJson(c as Map<String, dynamic>))
            .toList(),
        primaryContact: EmergencyContact.fromJson(
            json['primary_contact'] as Map<String, dynamic>),
        secondaryContact: json['secondary_contact'] != null
            ? EmergencyContact.fromJson(
                json['secondary_contact'] as Map<String, dynamic>)
            : null,
        organDonor: OrganDonor.values.firstWhere(
          (e) => e.name == json['organ_donor'],
          orElse: () => OrganDonor.unknown,
        ),
        dnrDirective: json['dnr_directive'] as String?,
        insuranceProvider: json['insurance_provider'] as String?,
        primaryPhysicianName: json['primary_physician_name'] as String?,
        primaryPhysicianPhone: json['primary_physician_phone'] as String?,
        notes: json['notes'] as String?,
        lastUpdated: DateTime.parse(json['last_updated'] as String),
      );
}

/// Blood type with both canonical code and display label.
enum BloodType {
  aPositive('A+', 'A Positivo'),
  aNegative('A-', 'A Negativo'),
  bPositive('B+', 'B Positivo'),
  bNegative('B-', 'B Negativo'),
  abPositive('AB+', 'AB Positivo'),
  abNegative('AB-', 'AB Negativo'),
  oPositive('O+', 'O Positivo'),
  oNegative('O-', 'O Negativo'),
  unknown('?', 'Desconocido');

  final String code;
  final String displayName;
  const BloodType(this.code, this.displayName);

  static BloodType fromCode(String code) => values.firstWhere(
        (e) => e.code == code,
        orElse: () => unknown,
      );
}

enum OrganDonor { yes, no, unknown }
