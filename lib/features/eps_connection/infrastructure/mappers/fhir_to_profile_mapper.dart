import 'package:orionhealth_health/features/onboarding/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/services/local_fhir_engine.dart';

/// 🏥 FHIR → UserProfile Mapper
///
/// Transforma datos clínicos FHIR R4 del IHCE Minsalud en el modelo
/// UserProfile de OrionHealth para auto-poblar el onboarding.
///
/// Flujo:
/// 1. Paciente se loguea con su EPS (SURA, Sanitas, etc.)
/// 2. LocalFhirEngine.fetchAllPatientData() obtiene datos del IHCE
/// 3. FhirToProfileMapper.transform() convierte FHIR → UserProfile
/// 4. OnboardingCubit recibe el perfil pre-poblado
/// 5. El onboarding se salta los pasos ya completos o los muestra pre-llenados
class FhirToProfileMapper {
  /// Transforma PatientClinicalData del IHCE en un UserProfile de OrionHealth.
  ///
  /// Extrae del bundle FHIR:
  /// - Patient: nombre, fecha nacimiento, sexo, dirección, teléfono
  /// - Composition (RDA): condiciones/diagnósticos, alergias, antecedentes familiares
  /// - MedicationDispense: medicamentos activos
  /// - Immunization: vacunas
  /// - Organization (EAPB): EPS conectada
  static UserProfile transform({
    required PatientClinicalData fhirData,
    required String epsConnectedId,
    required String patientDocumentId,
  }) {
    final patient = fhirData.patient;
    final rda = fhirData.rda;
    final medications = fhirData.medications ?? [];
    final immunizations = fhirData.immunizations ?? [];
    final encounters = fhirData.encounterEncounters ?? [];

    final now = DateTime.now();

    return UserProfile(
      name: _extractPatientName(patient),
      birthDate: _extractBirthDate(patient),
      sex: _extractSex(patient),
      weightKg: _extractWeight(patient),
      heightCm: _extractHeight(patient),
      conditions: _extractConditions(rda),
      allergies: _extractAllergies(rda),
      medications: _extractMedicationNames(medications),
      familyHistory: _extractFamilyHistory(rda),
      privacyConsent: false, // Requiere confirmación explícita
      createdAt: now,
      updatedAt: now,
      onboardingStep: _calculateStartingStep(
        hasName: _extractPatientName(patient) != null,
        hasBirthDate: _extractBirthDate(patient) != null,
        hasSex: _extractSex(patient) != null,
        hasConditions: _extractConditions(rda).isNotEmpty,
        hasMedications: medications.isNotEmpty,
      ),
      onboardingCompleted: false,
      isEpsConnected: true,
      epsPatientId: patientDocumentId,
    );
  }

  /// Calcula en qué paso del onboarding empezar, basado en qué datos
  /// ya se obtuvieron de la EPS.
  ///
  /// Si todos los datos están → empieza en Privacy (paso 5),
  /// solo falta aceptar términos. Si faltan datos → empieza en
  /// el primer paso con datos faltantes.
  static int _calculateStartingStep({
    required bool hasName,
    required bool hasBirthDate,
    required bool hasSex,
    required bool hasConditions,
    required bool hasMedications,
  }) {
    // Paso 0: Welcome — siempre se muestra como resumen
    // Paso 1: BasicInfo — nombre, fecha nacimiento, sexo, peso, altura
    // Paso 2: Conditions — condiciones médicas
    // Paso 3: FamilyHistory — antecedentes familiares
    // Paso 4: Medications — medicamentos
    // Paso 5: Privacy — consentimiento
    // Paso 6: Complete — finalizado

    if (!hasName || !hasBirthDate || !hasSex) return 1; // Falta BasicInfo
    if (!hasConditions) return 2;                          // Falta Conditions
    if (!hasMedications) return 4;                         // Falta Medications
    return 5; // Todo completo → solo falta Privacy consent
  }

  // ─── FHIR Resource Extractors ──────────────────────────

  /// Extrae el nombre del paciente de un recurso FHIR Patient.
  ///
  /// FHIR Patient.name es una lista de HumanName:
  /// ```
  /// "name": [{
  ///   "use": "official",
  ///   "family": "Belalcazar",
  ///   "given": ["Sebastian"]
  /// }]
  /// ```
  static String? _extractPatientName(Map<String, dynamic>? patient) {
    if (patient == null) return null;
    final names = patient['name'] as List<dynamic>?;
    if (names == null || names.isEmpty) return null;

    // Buscar el nombre oficial primero
    Map<String, dynamic>? targetName;
    for (final n in names) {
      final name = n as Map<String, dynamic>;
      if (name['use'] == 'official') {
        targetName = name;
        break;
      }
    }
    targetName ??= names.first as Map<String, dynamic>;

    final given = targetName['given'] as List<dynamic>?;
    final family = targetName['family'] as String?;

    final givenStr = given?.join(' ') ?? '';
    final familyStr = family ?? '';

    if (givenStr.isEmpty && familyStr.isEmpty) return null;

    return '$givenStr $familyStr'.trim();
  }

  /// Extrae la fecha de nacimiento de un recurso FHIR Patient.
  ///
  /// FHIR Patient.birthDate: "1990-05-15"
  static DateTime? _extractBirthDate(Map<String, dynamic>? patient) {
    if (patient == null) return null;
    final birthDateStr = patient['birthDate'] as String?;
    if (birthDateStr == null) return null;
    return DateTime.tryParse(birthDateStr);
  }

  /// Extrae el sexo de un recurso FHIR Patient.
  ///
  /// FHIR Patient.gender: "male" | "female" | "other" | "unknown"
  static String? _extractSex(Map<String, dynamic>? patient) {
    if (patient == null) return null;
    final gender = patient['gender'] as String?;
    switch (gender?.toLowerCase()) {
      case 'male':
        return 'M';
      case 'female':
        return 'F';
      case 'other':
        return 'O';
      default:
        return null;
    }
  }

  /// Extrae el peso de observaciones FHIR (si están incluidas en el bundle).
  static double? _extractWeight(Map<String, dynamic>? patient) {
    if (patient == null) return null;
    // Buscar en extensiones o observations anidadas
    final extensions = patient['extension'] as List<dynamic>?;
    if (extensions == null) return null;

    for (final ext in extensions) {
      final e = ext as Map<String, dynamic>;
      if (e['url']?.toString().contains('weight') == true ||
          e['url']?.toString().contains('bodyWeight') == true) {
        final value = e['valueQuantity'];
        if (value != null) {
          final v = (value as Map<String, dynamic>)['value'];
          if (v is num) return v.toDouble();
        }
      }
    }
    return null;
  }

  /// Extrae la altura de observaciones FHIR.
  static double? _extractHeight(Map<String, dynamic>? patient) {
    if (patient == null) return null;
    final extensions = patient['extension'] as List<dynamic>?;
    if (extensions == null) return null;

    for (final ext in extensions) {
      final e = ext as Map<String, dynamic>;
      if (e['url']?.toString().contains('height') == true ||
          e['url']?.toString().contains('bodyHeight') == true) {
        final value = e['valueQuantity'];
        if (value != null) {
          final v = (value as Map<String, dynamic>)['value'];
          if (v is num) return v.toDouble();
        }
      }
    }
    return null;
  }

  /// Extrae condiciones/diagnósticos del RDA (Resumen Digital de Atención).
  ///
  /// FHIR Composition.section contiene:
  /// - "Diagnósticos principales"
  /// - "Antecedentes médicos"
  /// - "Alergias"
  static List<String> _extractConditions(Map<String, dynamic>? rda) {
    if (rda == null) return [];
    final sections = rda['section'] as List<dynamic>?;
    if (sections == null) return [];

    final conditions = <String>[];
    for (final section in sections) {
      final s = section as Map<String, dynamic>;
      final title = (s['title'] as String?)?.toLowerCase() ?? '';

      // Buscar secciones de diagnóstico o condiciones
      if (title.contains('diagnóstico') ||
          title.contains('diagnostico') ||
          title.contains('condición') ||
          title.contains('condicion') ||
          title.contains('problema') ||
          title.contains('antecedente médico') ||
          title.contains('antecedente medico')) {
        final entries = s['entry'] as List<dynamic>?;
        if (entries != null) {
          for (final entry in entries) {
            final e = entry as Map<String, dynamic>;
            final code = e['code'] as Map<String, dynamic>?;
            if (code != null) {
              final coding = code['coding'] as List<dynamic>?;
              if (coding != null && coding.isNotEmpty) {
                final display = (coding.first as Map<String, dynamic>)['display'] as String?;
                if (display != null) conditions.add(display);
              }
              final text = code['text'] as String?;
              if (text != null) conditions.add(text);
            }
          }
        }
      }
    }

    return conditions.toSet().toList(); // Deduplicar
  }

  /// Extrae alergias del RDA.
  static List<String> _extractAllergies(Map<String, dynamic>? rda) {
    if (rda == null) return [];
    final sections = rda['section'] as List<dynamic>?;
    if (sections == null) return [];

    for (final section in sections) {
      final s = section as Map<String, dynamic>;
      final title = (s['title'] as String?)?.toLowerCase() ?? '';

      if (title.contains('alergia') || title.contains('intolerancia')) {
        final entries = s['entry'] as List<dynamic>?;
        if (entries != null) {
          return entries.map((e) {
            final code = (e as Map<String, dynamic>)['code'] as Map<String, dynamic>?;
            final coding = code?['coding'] as List<dynamic>?;
            if (coding != null && coding.isNotEmpty) {
              final display = (coding.first as Map<String, dynamic>)['display'] as String?;
              if (display != null) return display;
            }
            return code?['text'] as String? ?? 'Alergia no especificada';
          }).toList();
        }
      }
    }
    return [];
  }

  /// Extrae nombres de medicamentos de MedicationDispense.
  static List<String> _extractMedicationNames(List<Map<String, dynamic>> medications) {
    if (medications.isEmpty) return [];

    return medications.map((med) {
      // MedicationDispense.medicationCodeableConcept
      final medication = med['medicationCodeableConcept'] as Map<String, dynamic>?;
      if (medication != null) {
        final coding = medication['coding'] as List<dynamic>?;
        if (coding != null && coding.isNotEmpty) {
          for (final c in coding) {
            final display = (c as Map<String, dynamic>)['display'] as String?;
            if (display != null && display.isNotEmpty) return display;
          }
        }
        final text = medication['text'] as String?;
        if (text != null) return text;
      }

      // MedicationDispense.medicationReference
      final ref = med['medicationReference'] as Map<String, dynamic>?;
      if (ref != null) {
        final display = ref['display'] as String?;
        if (display != null) return display;
      }

      return 'Medicamento';
    }).where((name) => name != 'Medicamento').toSet().toList();
  }

  /// Extrae antecedentes familiares del RDA.
  static List<String> _extractFamilyHistory(Map<String, dynamic>? rda) {
    if (rda == null) return [];
    final sections = rda['section'] as List<dynamic>?;
    if (sections == null) return [];

    for (final section in sections) {
      final s = section as Map<String, dynamic>;
      final title = (s['title'] as String?)?.toLowerCase() ?? '';

      if (title.contains('familiar') || title.contains('hereditario') || title.contains('antecedente familiar')) {
        final entries = s['entry'] as List<dynamic>?;
        if (entries != null) {
          return entries.map((e) {
            final text = (e as Map<String, dynamic>)['text'] as Map<String, dynamic>?;
            return text?['div'] as String? ?? 'Antecedente familiar';
          }).toList();
        }
      }
    }
    return [];
  }
}
