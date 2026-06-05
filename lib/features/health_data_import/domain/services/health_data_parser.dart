import 'dart:convert';
import '../../../vitals/domain/entities/vital_sign.dart';

class HealthDataParser {
  /// Parses a CSV string into a list of [VitalSign] entities.
  /// Expected format: type,value,unit,dateTime
  List<VitalSign> parseCsv(String csvData) {
    final List<VitalSign> results = [];
    final lines = csvData.trim().split('\n');

    if (lines.isEmpty) return [];

    // Skip header if it exists
    int startIndex = 0;
    if (lines[0].toLowerCase().contains('type') && lines[0].contains('value')) {
      startIndex = 1;
    }

    for (int i = startIndex; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final parts = _splitCsvLine(line);
      if (parts.length < 4) continue;

      try {
        final typeStr = parts[0];
        final valueStr = parts[1];
        final unitStr = parts[2];
        final dateStr = parts[3];

        final type = _mapStringToVitalSignType(typeStr);
        final value = double.tryParse(valueStr);
        final dateTime = DateTime.tryParse(dateStr);

        if (type != null && value != null && dateTime != null) {
          results.add(VitalSign(
            type: type,
            value: value,
            unit: _sanitizeString(unitStr),
            dateTime: dateTime,
            source: 'CSV_IMPORT',
          ));
        }
      } catch (_) {
        // Skip malformed rows
      }
    }
    return results;
  }

  /// Splits a CSV line robustly, handling quoted values and escaped quotes.
  List<String> _splitCsvLine(String line) {
    final List<String> result = [];
    bool inQuotes = false;
    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          // Escaped quote
          buffer.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        result.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    result.add(buffer.toString().trim());
    return result;
  }

  /// Parses a JSON string into a list of [VitalSign] entities.
  List<VitalSign> parseJson(String jsonData) {
    try {
      final decoded = jsonDecode(jsonData);
      if (decoded is! List) return [];

      final List<VitalSign> results = [];
      for (final item in decoded) {
        if (item is! Map<String, dynamic>) continue;

        final typeStr = item['type'] as String?;
        final value = (item['value'] as num?)?.toDouble();
        final unit = item['unit'] as String?;
        final dateStr = item['dateTime'] as String?;

        if (typeStr != null && value != null && dateStr != null) {
          final type = _mapStringToVitalSignType(typeStr);
          final dateTime = DateTime.tryParse(dateStr);

          if (type != null && dateTime != null) {
            results.add(VitalSign(
              type: type,
              value: value,
              unit: _sanitizeString(unit ?? ''),
              dateTime: dateTime,
              source: 'JSON_IMPORT',
            ));
          }
        }
      }
      return results;
    } catch (_) {
      return [];
    }
  }

  /// Parses FHIR Observation resources from a JSON string into [VitalSign] entities.
  List<VitalSign> parseFhir(String fhirData) {
    try {
      final decoded = jsonDecode(fhirData);
      if (decoded is! Map<String, dynamic>) return [];

      if (decoded['resourceType'] == 'Bundle') {
        final entries = decoded['entry'] as List?;
        if (entries == null) return [];

        final List<VitalSign> results = [];
        for (final entry in entries) {
          final resource = entry['resource'] as Map<String, dynamic>?;
          if (resource != null && resource['resourceType'] == 'Observation') {
            results.addAll(_mapFhirObservation(resource));
          }
        }
        return results;
      } else if (decoded['resourceType'] == 'Observation') {
        return _mapFhirObservation(decoded);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Internal FHIR mapping logic to avoid dependency on Data layer.
  List<VitalSign> _mapFhirObservation(Map<String, dynamic> json) {
    final code = json['code'];
    final codings = code?['coding'] as List?;
    if (codings == null) return [];

    final effectiveDateTimeStr = json['effectiveDateTime'] as String?;
    final dateTime = effectiveDateTimeStr != null ? DateTime.tryParse(effectiveDateTimeStr) : DateTime.now();
    if (dateTime == null) return [];

    final List<VitalSign> vitals = [];

    if (json['valueQuantity'] != null) {
      final type = _mapLoincToVitalType(codings);
      if (type != null) {
        vitals.add(VitalSign(
          type: type,
          value: (json['valueQuantity']['value'] as num).toDouble(),
          dateTime: dateTime,
          unit: json['valueQuantity']['unit'] as String?,
          source: 'FHIR_IMPORT',
        ));
      }
    }

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
              source: 'FHIR_IMPORT',
            ));
          }
        }
      }
    }

    return vitals;
  }

  VitalSignType? _mapLoincToVitalType(List codings) {
    for (final coding in codings) {
      if (coding['system'] == 'http://loinc.org') {
        final code = coding['code'] as String?;
        switch (code) {
          case '8867-4': return VitalSignType.heartRate;
          case '8310-5': return VitalSignType.temperature;
          case '8480-6': return VitalSignType.bloodPressureSystolic;
          case '8462-4': return VitalSignType.bloodPressureDiastolic;
          case '2708-6': return VitalSignType.spO2;
          case '59408-5': return VitalSignType.oxygenSaturation;
          case '15074-8': return VitalSignType.bloodGlucose;
        }
      }
    }
    return null;
  }

  /// Sanitizes input strings by trimming and removing potentially harmful characters.
  String _sanitizeString(String input) {
    return input.trim().replaceAll(RegExp(r'[<>{}\[\]\\"]'), '');
  }

  /// Maps a string to a [VitalSignType].
  VitalSignType? _mapStringToVitalSignType(String typeStr) {
    final normalized = typeStr.toLowerCase().replaceAll(' ', '');
    switch (normalized) {
      case 'heartrate':
      case 'bpm':
        return VitalSignType.heartRate;
      case 'temperature':
      case 'temp':
        return VitalSignType.temperature;
      case 'bloodpressuresystolic':
      case 'systolic':
        return VitalSignType.bloodPressureSystolic;
      case 'bloodpressurediastolic':
      case 'diastolic':
        return VitalSignType.bloodPressureDiastolic;
      case 'spo2':
        return VitalSignType.spO2;
      case 'steps':
        return VitalSignType.steps;
      case 'sleep':
        return VitalSignType.sleep;
      case 'bloodglucose':
      case 'glucose':
        return VitalSignType.bloodGlucose;
      case 'oxygensaturation':
        return VitalSignType.oxygenSaturation;
      default:
        return null;
    }
  }

  /// Validates if a [VitalSign] has reasonable values, considering units.
  bool isValid(VitalSign vital) {
    final value = vital.value;
    final unit = vital.unit?.toLowerCase();

    switch (vital.type) {
      case VitalSignType.heartRate:
        return value > 0 && value < 300;
      case VitalSignType.temperature:
        if (unit == 'f') {
          return value > 68 && value < 122; // Fahrenheit equivalent of 20-50 C
        }
        return value > 20 && value < 50; // Celsius
      case VitalSignType.bloodPressureSystolic:
        return value > 40 && value < 300;
      case VitalSignType.bloodPressureDiastolic:
        return value > 20 && value < 200;
      case VitalSignType.spO2:
      case VitalSignType.oxygenSaturation:
        return value >= 0 && value <= 100;
      default:
        return value >= 0;
    }
  }
}
