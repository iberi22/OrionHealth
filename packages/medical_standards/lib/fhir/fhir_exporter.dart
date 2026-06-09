import 'fhir.dart';

/// Utility to export internal medical data to FHIR R4 resources.
class FhirExporter {
  /// Creates a FHIR Bundle from a list of resources.
  static Map<String, dynamic> createBundle({
    required String id,
    required List<Map<String, dynamic>> resources,
  }) {
    return FhirBundle(
      id: id,
      timestamp: DateTime.now(),
      entries: resources,
    ).toJson();
  }

  /// Maps observation data to a FHIR Observation resource.
  static Map<String, dynamic> createObservation({
    required String id,
    required String loincCode,
    required String display,
    required String value,
    required String unit,
    required DateTime date,
    String? note,
  }) {
    return FhirObservation(
      id: id,
      status: 'final',
      code: loincCode,
      codeDisplay: display,
      loincCode: loincCode,
      valueQuantity: double.tryParse(value),
      valueUnit: unit,
      effectiveDateTime: date,
      note: note,
    ).toJson();
  }

  /// Maps condition data to a FHIR Condition resource.
  static Map<String, dynamic> createCondition({
    required String id,
    required String code,
    required String display,
    String? icd10Code,
    required DateTime date,
    String? note,
  }) {
    return FhirCondition(
      id: id,
      code: code,
      codeDisplay: display,
      icd10Code: icd10Code,
      clinicalStatus: 'active',
      onsetDateTime: date,
      recordedDate: DateTime.now(),
      note: note,
    ).toJson();
  }

  /// Maps allergy data to a FHIR AllergyIntolerance resource.
  static Map<String, dynamic> createAllergy({
    required String id,
    required String code,
    required String display,
    required DateTime date,
    String? note,
  }) {
    return FhirAllergyIntolerance(
      id: id,
      code: code,
      codeDisplay: display,
      clinicalStatus: 'active',
      criticality: 'unable-to-assess',
      recordedDate: date,
      note: note,
    ).toJson();
  }

  /// Maps a medical concept (doctor note) to a FHIR DocumentReference (simplified).
  static Map<String, dynamic> createDocumentReference({
    required String id,
    required String author,
    required String type,
    required String content,
    required DateTime date,
  }) {
    return {
      'resourceType': 'DocumentReference',
      'id': id,
      'status': 'current',
      'docStatus': 'final',
      'type': {
        'text': type,
      },
      'date': date.toIso8601String(),
      'author': [
        {'display': author}
      ],
      'content': [
        {
          'attachment': {
            'contentType': 'text/plain',
            'data': content,
          }
        }
      ],
    };
  }
}
