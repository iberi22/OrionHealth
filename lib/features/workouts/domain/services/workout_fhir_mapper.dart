import '../entities/workout_session.dart';

/// FHIR R4 activity Observation using the ecosystem's canonical LOINC codes.
Map<String, dynamic> workoutToObservation(WorkoutSession session) => {
  'resourceType': 'Observation',
  'id': session.recordId,
  'status': 'final',
  'category': [
    {
      'coding': [
        {
          'system':
              'http://terminology.hl7.org/CodeSystem/observation-category',
          'code': 'activity',
        },
      ],
    },
  ],
  'code': _loinc('73985-4', 'Physical activity panel'),
  'subject': {
    'identifier': {
      'system': 'urn:swal:health:subject',
      'value': session.subject,
    },
  },
  'effectivePeriod': {
    'start': session.startedAt.toUtc().toIso8601String(),
    'end': session.endedAt.toUtc().toIso8601String(),
  },
  'component': [
    {
      'code': _loinc('55411-3', 'Exercise duration'),
      'valueQuantity': {
        'value': session.duration.inMilliseconds / 1000,
        'unit': 's',
        'system': 'http://unitsofmeasure.org',
        'code': 's',
      },
    },
    if (session.energyKcal != null)
      {
        'code': _loinc('41981-2', 'Energy expenditure'),
        'valueQuantity': {
          'value': session.energyKcal,
          'unit': 'kcal',
          'system': 'http://unitsofmeasure.org',
          'code': 'kcal',
        },
      },
  ],
  if (session.notes != null && session.notes!.isNotEmpty)
    'note': [
      {'text': session.notes},
    ],
};

Map<String, dynamic> _loinc(String code, String display) => {
  'coding': [
    {'system': 'http://loinc.org', 'code': code, 'display': display},
  ],
};
