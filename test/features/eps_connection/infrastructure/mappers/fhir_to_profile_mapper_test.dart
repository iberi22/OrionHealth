import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/mappers/fhir_to_profile_mapper.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/services/local_fhir_engine.dart';

void main() {
  group('FhirToProfileMapper', () {
    // ─── HELPER: Build a realistic FHIR Patient ──────────
    Map<String, dynamic> _buildPatient({
      String? name,
      String? birthDate,
      String? gender,
      double? weight,
      double? height,
    }) {
      final patient = <String, dynamic>{
        'resourceType': 'Patient',
        'id': 'pac-001',
      };

      if (name != null) {
        final parts = name.split(' ');
        patient['name'] = [
          {
            'use': 'official',
            'family': parts.last,
            'given': parts.length > 1 ? parts.sublist(0, parts.length - 1) : [name],
          }
        ];
      }

      if (birthDate != null) {
        patient['birthDate'] = birthDate;
      }

      if (gender != null) {
        patient['gender'] = gender;
      }

      final extensions = <Map<String, dynamic>>[];
      if (weight != null) {
        extensions.add({
          'url': 'http://hl7.org/fhir/StructureDefinition/bodyWeight',
          'valueQuantity': {'value': weight, 'unit': 'kg'},
        });
      }
      if (height != null) {
        extensions.add({
          'url': 'http://hl7.org/fhir/StructureDefinition/bodyHeight',
          'valueQuantity': {'value': height, 'unit': 'cm'},
        });
      }
      if (extensions.isNotEmpty) {
        patient['extension'] = extensions;
      }

      return patient;
    }

    // ─── HELPER: Build a realistic FHIR RDA Composition ──
    Map<String, dynamic> _buildRda({
      List<String>? conditions,
      List<String>? allergies,
      List<String>? familyHistory,
    }) {
      final sections = <Map<String, dynamic>>[];

      if (conditions != null && conditions.isNotEmpty) {
        sections.add({
          'title': 'Diagnósticos principales',
          'entry': conditions.map((c) => {
            'code': {
              'coding': [
                {'display': c}
              ]
            }
          }).toList(),
        });
      }

      if (allergies != null && allergies.isNotEmpty) {
        sections.add({
          'title': 'Alergias e Intolerancias',
          'entry': allergies.map((a) => {
            'code': {
              'coding': [
                {'display': a}
              ]
            }
          }).toList(),
        });
      }

      if (familyHistory != null && familyHistory.isNotEmpty) {
        sections.add({
          'title': 'Antecedentes Familiares',
          'entry': familyHistory.map((f) => {
            'text': {'div': f}
          }).toList(),
        });
      }

      return {
        'resourceType': 'Composition',
        'id': 'rda-001',
        'section': sections,
      };
    }

    // ─── HELPER: Build MedicationDispense bundle ─────────
    List<Map<String, dynamic>> _buildMedications(List<String> names) {
      return names.map((name) => {
        'medicationCodeableConcept': {
          'coding': [
            {'display': name, 'code': 'MED-${names.indexOf(name)}'}
          ],
          'text': name,
        }
      }).toList();
    }

    // ─── TESTS ──────────────────────────────────────────

    test('extrae nombre completo del paciente FHIR', () {
      final patient = _buildPatient(name: 'Sebastián Belalcázar');
      final data = PatientClinicalData(patient: patient);
      final profile = FhirToProfileMapper.transform(
        fhirData: data,
        epsConnectedId: 'EPS025',
        patientDocumentId: '123456789',
      );

      expect(profile.name, 'Sebastián Belalcázar');
    });

    test('extrae fecha de nacimiento del paciente FHIR', () {
      final patient = _buildPatient(
        name: 'Test User',
        birthDate: '1990-05-15',
      );
      final data = PatientClinicalData(patient: patient);
      final profile = FhirToProfileMapper.transform(
        fhirData: data,
        epsConnectedId: 'EPS025',
        patientDocumentId: '123456789',
      );

      expect(profile.birthDate, DateTime(1990, 5, 15));
    });

    test('extrae sexo M del paciente FHIR', () {
      final patient = _buildPatient(name: 'Test', gender: 'male');
      final data = PatientClinicalData(patient: patient);
      final profile = FhirToProfileMapper.transform(
        fhirData: data,
        epsConnectedId: 'EPS025',
        patientDocumentId: '123',
      );

      expect(profile.sex, 'M');
    });

    test('extrae sexo F del paciente FHIR', () {
      final patient = _buildPatient(name: 'Test', gender: 'female');
      final data = PatientClinicalData(patient: patient);
      final profile = FhirToProfileMapper.transform(
        fhirData: data,
        epsConnectedId: 'EPS025',
        patientDocumentId: '123',
      );

      expect(profile.sex, 'F');
    });

    test('extrae sexo O (other) del paciente FHIR', () {
      final patient = _buildPatient(name: 'Test', gender: 'other');
      final data = PatientClinicalData(patient: patient);
      final profile = FhirToProfileMapper.transform(
        fhirData: data,
        epsConnectedId: 'EPS025',
        patientDocumentId: '123',
      );

      expect(profile.sex, 'O');
    });

    test('retorna null para sexo unknown', () {
      final patient = _buildPatient(name: 'Test', gender: 'unknown');
      final data = PatientClinicalData(patient: patient);
      final profile = FhirToProfileMapper.transform(
        fhirData: data,
        epsConnectedId: 'EPS025',
        patientDocumentId: '123',
      );

      expect(profile.sex, isNull);
    });

    test('extrae peso de extensiones FHIR', () {
      final patient = _buildPatient(
        name: 'Test',
        weight: 75.5,
        height: 170.0,
      );
      final data = PatientClinicalData(patient: patient);
      final profile = FhirToProfileMapper.transform(
        fhirData: data,
        epsConnectedId: 'EPS025',
        patientDocumentId: '123',
      );

      expect(profile.weightKg, 75.5);
      expect(profile.heightCm, 170.0);
    });

    test('extrae condiciones/diagnósticos del RDA', () {
      final patient = _buildPatient(name: 'Test User');
      final rda = _buildRda(conditions: [
        'Hipertensión esencial',
        'Diabetes mellitus tipo 2',
        'Obesidad grado I',
      ]);
      final data = PatientClinicalData(patient: patient, rda: rda);
      final profile = FhirToProfileMapper.transform(
        fhirData: data,
        epsConnectedId: 'EPS025',
        patientDocumentId: '123',
      );

      expect(profile.conditions.length, greaterThanOrEqualTo(3));
      expect(profile.conditions.any((c) => c.contains('Hipertensión')), true);
      expect(profile.conditions.any((c) => c.contains('Diabetes')), true);
    });

    test('extrae alergias del RDA', () {
      final patient = _buildPatient(name: 'Test');
      final rda = _buildRda(allergies: [
        'Penicilina',
        'Sulfa',
        'Ibuprofeno',
      ]);
      final data = PatientClinicalData(patient: patient, rda: rda);
      final profile = FhirToProfileMapper.transform(
        fhirData: data,
        epsConnectedId: 'EPS025',
        patientDocumentId: '123',
      );

      expect(profile.allergies.length, 3);
      expect(profile.allergies.contains('Penicilina'), true);
    });

    test('extrae medicamentos del bundle FHIR', () {
      final patient = _buildPatient(name: 'Test');
      final medications = _buildMedications([
        'Losartán 50mg',
        'Metformina 850mg',
        'Atorvastatina 20mg',
      ]);
      final data = PatientClinicalData(
        patient: patient,
        medications: medications,
      );
      final profile = FhirToProfileMapper.transform(
        fhirData: data,
        epsConnectedId: 'EPS025',
        patientDocumentId: '123',
      );

      expect(profile.medications.length, 3);
      expect(profile.medications.contains('Losartán 50mg'), true);
      expect(profile.medications.contains('Metformina 850mg'), true);
    });

    test('extrae antecedentes familiares del RDA', () {
      final patient = _buildPatient(name: 'Test');
      final rda = _buildRda(familyHistory: [
        'Madre: Diabetes tipo 2',
        'Padre: Hipertensión',
      ]);
      final data = PatientClinicalData(patient: patient, rda: rda);
      final profile = FhirToProfileMapper.transform(
        fhirData: data,
        epsConnectedId: 'EPS025',
        patientDocumentId: '123',
      );

      expect(profile.familyHistory.length, 2);
    });

    test('marca isEpsConnected=true y guarda patientDocumentId', () {
      final patient = _buildPatient(name: 'Test');
      final data = PatientClinicalData(patient: patient);
      final profile = FhirToProfileMapper.transform(
        fhirData: data,
        epsConnectedId: 'EPS025',
        patientDocumentId: '987654321',
      );

      expect(profile.isEpsConnected, true);
      expect(profile.epsPatientId, '987654321');
    });

    test('calcula paso inicial 5 cuando todos los datos están', () {
      final patient = _buildPatient(
        name: 'Completo',
        birthDate: '1985-03-20',
        gender: 'male',
      );
      final rda = _buildRda(conditions: ['Asma']);
      final medications = _buildMedications(['Salbutamol']);
      final data = PatientClinicalData(
        patient: patient,
        rda: rda,
        medications: medications,
      );
      final profile = FhirToProfileMapper.transform(
        fhirData: data,
        epsConnectedId: 'EPS025',
        patientDocumentId: '123',
      );

      // Todos los datos → paso 5 (Privacy, solo falta consentimiento)
      expect(profile.onboardingStep, 5);
    });

    test('calcula paso inicial 1 cuando falta nombre', () {
      final data = PatientClinicalData();
      final profile = FhirToProfileMapper.transform(
        fhirData: data,
        epsConnectedId: 'EPS025',
        patientDocumentId: '123',
      );

      expect(profile.onboardingStep, 1); // Falta BasicInfo
    });

    test('calcula paso inicial 2 cuando tiene BasicInfo pero no condiciones', () {
      final patient = _buildPatient(
        name: 'Test',
        birthDate: '1990-01-01',
        gender: 'female',
      );
      final data = PatientClinicalData(patient: patient);
      final profile = FhirToProfileMapper.transform(
        fhirData: data,
        epsConnectedId: 'EPS025',
        patientDocumentId: '123',
      );

      // Tiene datos básicos pero no condiciones → paso 2
      expect(profile.onboardingStep, 2);
    });

    test('data vacía retorna perfil mínimo con campos nulos', () {
      final data = PatientClinicalData();
      final profile = FhirToProfileMapper.transform(
        fhirData: data,
        epsConnectedId: 'EPS025',
        patientDocumentId: '123',
      );

      expect(profile.name, isNull);
      expect(profile.birthDate, isNull);
      expect(profile.sex, isNull);
      expect(profile.conditions, isEmpty);
      expect(profile.medications, isEmpty);
      expect(profile.allergies, isEmpty);
      expect(profile.familyHistory, isEmpty);
      expect(profile.isEpsConnected, true); // La conexión EPS existe
    });

    test('maneja patient.name sin given names', () {
      final patient = <String, dynamic>{
        'resourceType': 'Patient',
        'name': [
          {'use': 'official', 'family': 'Belalcázar'}
        ],
      };
      final data = PatientClinicalData(patient: patient);
      final profile = FhirToProfileMapper.transform(
        fhirData: data,
        epsConnectedId: 'EPS025',
        patientDocumentId: '123',
      );

      expect(profile.name, 'Belalcázar');
    });

    test('maneja patient sin name completamente', () {
      final patient = <String, dynamic>{
        'resourceType': 'Patient',
        'id': 'test',
        // no 'name' field at all
      };
      final data = PatientClinicalData(patient: patient);
      final profile = FhirToProfileMapper.transform(
        fhirData: data,
        epsConnectedId: 'EPS025',
        patientDocumentId: '123',
      );

      expect(profile.name, isNull);
    });

    test('deduplica condiciones en el perfil', () {
      final patient = _buildPatient(name: 'Test');
      final rda = _buildRda(conditions: [
        'Diabetes tipo 2',
        'Diabetes tipo 2', // Duplicado
        'Hipertensión',
      ]);
      final data = PatientClinicalData(patient: patient, rda: rda);
      final profile = FhirToProfileMapper.transform(
        fhirData: data,
        epsConnectedId: 'EPS025',
        patientDocumentId: '123',
      );

      expect(profile.conditions.length, 2);
      expect(profile.conditions.contains('Diabetes tipo 2'), true);
    });

    test('medicamentos vacíos retornan lista vacía', () {
      final patient = _buildPatient(name: 'Test');
      final data = PatientClinicalData(
        patient: patient,
        medications: [],
      );
      final profile = FhirToProfileMapper.transform(
        fhirData: data,
        epsConnectedId: 'EPS025',
        patientDocumentId: '123',
      );

      expect(profile.medications, isEmpty);
    });
  });
}
