import '../../../user_profile/domain/entities/user_profile.dart';
import '../../../medications/domain/entities/medication.dart';
import '../../../allergies/domain/entities/allergy.dart';
import '../../../vitals/domain/entities/vital_sign.dart';

class FhirMapper {
  /// Maps FHIR Patient resource to UserProfile
  static UserProfile mapPatient(Map<String, dynamic> json, UserProfile existingProfile) {
    final name = _extractPatientName(json);
    final birthDateStr = json['birthDate'] as String?;
    final birthDate = birthDateStr != null ? DateTime.tryParse(birthDateStr) : null;
    final gender = json['gender'] as String?;

    final telecom = json['telecom'] as List?;
    String? email;
    String? phone;

    if (telecom != null) {
      for (final item in telecom) {
        if (item['system'] == 'email') {
          email = item['value'];
        } else if (item['system'] == 'phone') {
          phone = item['value'];
        }
      }
    }

    return existingProfile.copyWith(
      name: name ?? existingProfile.name,
      birthDate: birthDate ?? existingProfile.birthDate,
      sex: gender ?? existingProfile.sex,
      email: email ?? existingProfile.email,
      phoneNumber: phone ?? existingProfile.phoneNumber,
      uniqueId: json['id'] as String?,
    );
  }

  static String? _extractPatientName(Map<String, dynamic> json) {
    final names = json['name'] as List?;
    if (names == null || names.isEmpty) return null;

    // Try to find official name first
    final official = names.cast<Map<String, dynamic>>().firstWhere(
      (n) => n['use'] == 'official',
      orElse: () => names.first as Map<String, dynamic>,
    );

    if (official['text'] != null) return official['text'] as String;

    final given = (official['given'] as List?)?.join(' ') ?? '';
    final family = official['family'] as String? ?? '';

    final full = '$given $family'.trim();
    return full.isNotEmpty ? full : null;
  }

  /// Maps FHIR MedicationStatement or MedicationRequest to Medication
  static Medication? mapMedicationStatement(Map<String, dynamic> json) {
    final medicationCodeableConcept = json['medicationCodeableConcept'];
    final medicationReference = json['medicationReference'];

    String? name;
    if (medicationCodeableConcept != null) {
      name = medicationCodeableConcept['text'] as String? ??
             (medicationCodeableConcept['coding'] as List?)?.first['display'] as String?;
    } else if (medicationReference != null) {
      name = medicationReference['display'] as String?;
    }

    if (name == null) return null;

    final effectiveDateTimeStr = json['effectiveDateTime'] as String? ??
                                json['effectivePeriod']?['start'] as String? ??
                                json['authoredOn'] as String?; // For MedicationRequest
    final startDate = effectiveDateTimeStr != null ? DateTime.tryParse(effectiveDateTimeStr) : DateTime.now();

    return Medication(
      name: name,
      isActive: json['status'] == 'active' || json['status'] == 'completed',
      startDate: startDate ?? DateTime.now(),
      notes: json['note'] != null ? (json['note'] as List).map((n) => n['text']).join('\n') : null,
    );
  }

  /// Maps FHIR AllergyIntolerance to Allergy
  static Allergy? mapAllergyIntolerance(Map<String, dynamic> json) {
    final code = json['code'];
    String? allergen = code?['text'] as String? ??
                    (code?['coding'] as List?)?.first['display'] as String?;

    // Fallback to substance in reactions if code is missing
    if (allergen == null) {
      final reactions = json['reaction'] as List?;
      if (reactions != null && reactions.isNotEmpty) {
        final substance = reactions.first['substance'];
        allergen = substance?['text'] as String? ??
                  (substance?['coding'] as List?)?.first['display'] as String?;
      }
    }

    if (allergen == null) return null;

    final criticality = json['criticality'] as String?;
    AllergySeverity severity;
    switch (criticality) {
      case 'low':
        severity = AllergySeverity.mild;
        break;
      case 'high':
      case 'unable-to-assess':
        severity = AllergySeverity.severe;
        break;
      default:
        severity = AllergySeverity.moderate;
    }

    return Allergy(
      allergen: allergen,
      severity: severity,
      notes: json['note'] != null ? (json['note'] as List).map((n) => n['text']).join('\n') : null,
    );
  }

  /// Extracts ICD-10 codes from FHIR Condition
  static String? mapConditionCode(Map<String, dynamic> json) {
    final code = json['code'];
    if (code == null) return null;

    final codings = code['coding'] as List?;
    if (codings != null) {
      for (final coding in codings) {
        if (coding['system'] == 'http://hl7.org/fhir/sid/icd-10') {
          return coding['code'] as String?;
        }
      }
      // Fallback to first available code
      if (codings.isNotEmpty) {
        return codings.first['code'] as String?;
      }
    }

    // Fallback to display text
    return code['text'] as String?;
  }

  /// Maps FHIR Observation to VitalSign
  static List<VitalSign> mapObservation(Map<String, dynamic> json) {
    final code = json['code'];
    final codings = code?['coding'] as List?;
    if (codings == null && json['component'] == null) return [];

    final effectiveDateTimeStr = json['effectiveDateTime'] as String? ?? json['issued'] as String?;
    final dateTime = effectiveDateTimeStr != null ? DateTime.tryParse(effectiveDateTimeStr) : DateTime.now();
    if (dateTime == null) return [];

    final List<VitalSign> vitals = [];

    // Handle single value observations
    if (json['valueQuantity'] != null && codings != null) {
      final type = _mapLoincToVitalType(codings);
      if (type != null) {
        vitals.add(VitalSign(
          type: type,
          value: (json['valueQuantity']['value'] as num).toDouble(),
          dateTime: dateTime,
          unit: json['valueQuantity']['unit'] as String?,
          source: 'FHIR',
        ));
      }
    }

    // Handle components (e.g. Blood Pressure)
    final components = json['component'] as List?;
    if (components != null) {
      for (final comp in components) {
        final compCodings = comp['code']?['coding'] as List?;
        if (compCodings != null && comp['valueQuantity'] != null) {
          final type = _mapLoincToVitalType(compCodings);
          if (type != null) {
            vitals.add(VitalSign(
              type: type,
              value: (comp['valueQuantity']['value'] as num).toDouble(),
              dateTime: dateTime,
              unit: comp['valueQuantity']['unit'] as String?,
              source: 'FHIR',
            ));
          }
        }
      }
    }

    return vitals;
  }

  static VitalSignType? _mapLoincToVitalType(List codings) {
    for (final coding in codings) {
      final code = coding['code'] as String?;
      final display = (coding['display'] as String?)?.toLowerCase() ?? '';

      if (coding['system'] == 'http://loinc.org') {
        switch (code) {
          case '8867-4': return VitalSignType.heartRate;
          case '8310-5': return VitalSignType.temperature;
          case '8480-6': return VitalSignType.bloodPressureSystolic;
          case '8462-4': return VitalSignType.bloodPressureDiastolic;
          case '2708-6': return VitalSignType.spO2;
          case '59408-5': return VitalSignType.oxygenSaturation;
          case '15074-8': return VitalSignType.bloodGlucose;
          case '60621-0': return VitalSignType.steps;
          case '93832-4': return VitalSignType.sleep;
        }
      }

      // Fallback to display name matching
      if (display.contains('heart rate')) return VitalSignType.heartRate;
      if (display.contains('temperature')) return VitalSignType.temperature;
      if (display.contains('systolic')) return VitalSignType.bloodPressureSystolic;
      if (display.contains('diastolic')) return VitalSignType.bloodPressureDiastolic;
      if (display.contains('oxygen saturation') || display.contains('spo2')) return VitalSignType.spO2;
      if (display.contains('glucose')) return VitalSignType.bloodGlucose;
      if (display.contains('steps')) return VitalSignType.steps;
      if (display.contains('sleep')) return VitalSignType.sleep;
    }
    return null;
  }
}
