/// FHIR R4 resource builders.
///
/// FHIR (Fast Healthcare Interoperability Resources) is a standard
/// for exchanging healthcare information electronically.

/// FHIR Resource Type
enum FhirResourceType {
  patient,
  observation,
  condition,
  medicationRequest,
  allergyIntolerance,
  diagnosticReport,
  documentReference,
}

/// FHIR Observation status
enum FhirObservationStatus {
  registered,
  preliminary,
  final_,
  amended,
  corrected,
  cancelled,
  enteredInError,
  unknown,
}

/// FHIR Observation builder
class FhirObservation {
  final String id;
  final String status;
  final String code;
  final String codeDisplay;
  final String? loincCode;
  final double? valueQuantity;
  final String? valueUnit;
  final DateTime effectiveDateTime;
  final String? subjectReference;
  final String? encounterReference;
  final String? interpretation;
  final String? note;

  FhirObservation({
    required this.id,
    required this.status,
    required this.code,
    required this.codeDisplay,
    this.loincCode,
    this.valueQuantity,
    this.valueUnit,
    required this.effectiveDateTime,
    this.subjectReference,
    this.encounterReference,
    this.interpretation,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'resourceType': 'Observation',
    'id': id,
    'status': status,
    'code': {
      'coding': [
        {
          'system': 'http://loinc.org',
          'code': loincCode ?? code,
          'display': codeDisplay,
        }
      ],
      'text': codeDisplay,
    },
    if (valueQuantity != null)
      'valueQuantity': {
        'value': valueQuantity,
        'unit': valueUnit,
      },
    'effectiveDateTime': effectiveDateTime.toIso8601String(),
    if (subjectReference != null) 'subject': {'reference': subjectReference},
    if (encounterReference != null) 'encounter': {'reference': encounterReference},
    if (interpretation != null)
      'interpretation': [
        {'text': interpretation}
      ],
    if (note != null)
      'note': [
        {'text': note}
      ],
  };
}

/// FHIR Appointment status
enum FhirAppointmentStatus {
  proposed,
  pending,
  booked,
  arrived,
  fulfilled,
  cancelled,
  noshow,
  enteredInError,
  checkedIn,
  waitlist,
}

/// FHIR Appointment builder
class FhirAppointment {
  final String id;
  final String status;
  final DateTime start;
  final DateTime? end;
  final String description;
  final String? participantActorDisplay;

  FhirAppointment({
    required this.id,
    required this.status,
    required this.start,
    this.end,
    required this.description,
    this.participantActorDisplay,
  });

  Map<String, dynamic> toJson() => {
        'resourceType': 'Appointment',
        'id': id,
        'status': status,
        'start': start.toIso8601String(),
        if (end != null) 'end': end!.toIso8601String(),
        'description': description,
        if (participantActorDisplay != null)
          'participant': [
            {
              'actor': {'display': participantActorDisplay},
              'status': 'accepted'
            }
          ],
      };
}

/// FHIR Condition builder
class FhirCondition {
  final String id;
  final String code;
  final String codeDisplay;
  final String? icd10Code;
  final String clinicalStatus;
  final DateTime onsetDateTime;
  final DateTime recordedDate;
  final String? note;

  FhirCondition({
    required this.id,
    required this.code,
    required this.codeDisplay,
    this.icd10Code,
    required this.clinicalStatus,
    required this.onsetDateTime,
    required this.recordedDate,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'resourceType': 'Condition',
    'id': id,
    'code': {
      'coding': [
        {
          'system': 'http://snomed.org/sct',
          'code': code,
          'display': codeDisplay,
        },
        if (icd10Code != null)
          {
            'system': 'http://hl7.org/fhir/sid/icd-10',
            'code': icd10Code,
            'display': codeDisplay,
          },
      ],
      'text': codeDisplay,
    },
    'clinicalStatus': {
      'coding': [
        {
          'system': 'http://terminology.hl7.org/CodeSystem/condition-clinical',
          'code': clinicalStatus,
        }
      ],
    },
    'onsetDateTime': onsetDateTime.toIso8601String(),
    'recordedDate': recordedDate.toIso8601String(),
    if (note != null)
      'note': [
        {'text': note}
      ],
  };
}

/// FHIR Bundle builder for exchanging patient data
class FhirBundle {
  final String id;
  final String type;
  final DateTime timestamp;
  final List<Map<String, dynamic>> entries;

  FhirBundle({
    required this.id,
    this.type = 'collection',
    required this.timestamp,
    this.entries = const [],
  });

  Map<String, dynamic> toJson() => {
    'resourceType': 'Bundle',
    'id': id,
    'type': type,
    'timestamp': timestamp.toIso8601String(),
    'entry': entries.map((e) => {'resource': e}).toList(),
  };

  String toJsonString() => _prettyJson(toJson());

  static String _prettyJson(Map<String, dynamic> map) {
    final buffer = StringBuffer();
    _writeJson(buffer, map, 0);
    return buffer.toString();
  }

  static void _writeJson(StringBuffer buffer, dynamic value, int indent) {
    final prefix = '  ' * indent;
    if (value is Map) {
      buffer.writeln('{');
      final entries = value.entries.toList();
      for (var i = 0; i < entries.length; i++) {
        buffer.write('$prefix  "${entries[i].key}": ');
        _writeJson(buffer, entries[i].value, indent + 1);
        if (i < entries.length - 1) buffer.write(',');
        buffer.writeln();
      }
      buffer.write('$prefix}');
    } else if (value is List) {
      buffer.writeln('[');
      for (var i = 0; i < value.length; i++) {
        buffer.write('$prefix  ');
        _writeJson(buffer, value[i], indent + 1);
        if (i < value.length - 1) buffer.write(',');
        buffer.writeln();
      }
      buffer.write('$prefix]');
    } else if (value is String) {
      buffer.write('"$value"');
    } else if (value == null) {
      buffer.write('null');
    } else {
      buffer.write(value.toString());
    }
  }
}

/// FHIR AllergyIntolerance builder
class FhirAllergyIntolerance {
  final String id;
  final String code;
  final String codeDisplay;
  final String clinicalStatus;
  final String criticality;
  final DateTime recordedDate;
  final String? note;

  FhirAllergyIntolerance({
    required this.id,
    required this.code,
    required this.codeDisplay,
    required this.clinicalStatus,
    required this.criticality,
    required this.recordedDate,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'resourceType': 'AllergyIntolerance',
    'id': id,
    'code': {
      'coding': [
        {
          'system': 'http://snomed.org/sct',
          'code': code,
          'display': codeDisplay,
        }
      ],
      'text': codeDisplay,
    },
    'clinicalStatus': {
      'coding': [
        {
          'system': 'http://terminology.hl7.org/CodeSystem/allergyintolerance-clinical',
          'code': clinicalStatus,
        }
      ],
    },
    'criticality': criticality,
    'recordedDate': recordedDate.toIso8601String(),
    if (note != null)
      'note': [
        {'text': note}
      ],
  };
}
