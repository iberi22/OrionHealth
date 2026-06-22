/// RDA Parser for IHCE Colombia
/// Maps FHIR Composition/Bundle to simplified patient summary
library;

class RdaParser {
  /// Parse a FHIR Bundle or Composition into a structured Digital Summary
  static Map<String, dynamic>? parse(Map<String, dynamic> fhirBundle) {
    if (fhirBundle['resourceType'] != 'Bundle') {
      // Might be a single Composition resource
      if (fhirBundle['resourceType'] == 'Composition') {
        return _parseComposition(fhirBundle);
      }
      return _createSyntheticComposition([{'resource': fhirBundle}]);
    }

    final entries = fhirBundle['entry'] as List<dynamic>?;
    if (entries == null || entries.isEmpty) return _createSyntheticComposition([]);

    // Find the Composition resource in the bundle
    Map<String, dynamic>? composition;
    for (final entry in entries) {
      final resource = entry['resource'] as Map<String, dynamic>?;
      if (resource?['resourceType'] == 'Composition') {
        composition = resource;
        break;
      }
    }

    if (composition == null) {
      // Fallback: Create a synthetic composition from entries if no Composition found
      return _createSyntheticComposition(entries);
    }
    return _parseComposition(composition, entries);
  }

  static Map<String, dynamic> _parseComposition(
    Map<String, dynamic> composition, [
    List<dynamic>? bundleEntries,
  ]) {
    final sections = <Map<String, dynamic>>[];

    final rawSections = composition['section'] as List<dynamic>?;
    if (rawSections != null) {
      for (final section in rawSections) {
        final sectionMap = section as Map<String, dynamic>;
        final coding = sectionMap['code']?['coding'] as List<dynamic>?;
        final entries = sectionMap['entry'] as List<dynamic>?;

        sections.add({
          'title': sectionMap['title'],
          'code': coding?.isNotEmpty == true ? coding!.first['code'] : null,
          'text': sectionMap['text']?['div'],
          'entries': entries
                  ?.map((e) => _resolveReference(e, bundleEntries, composition))
                  .where((e) => e != null)
                  .toList() ??
              [],
        });
      }
    }

    return {
      'id': composition['id'],
      'date': composition['date'],
      'title': composition['title'],
      'status': composition['status'],
      'type': composition['type']?['coding']?.isNotEmpty == true
          ? composition['type']!['coding']!.first['code']
          : null,
      'patient': _extractDisplay(composition['subject']),
      'author': composition['author']?.isNotEmpty == true
          ? _extractDisplay(composition['author']!.first)
          : 'Unknown',
      'sections': sections,
    };
  }

  /// Resolve a reference to its full resource in the bundle or source
  static Map<String, dynamic>? _resolveReference(
    dynamic reference,
    List<dynamic>? bundleEntries, [
    Map<String, dynamic>? sourceResource,
  ]) {
    if (reference == null) return null;

    final ref = reference as Map<String, dynamic>;
    final refStr = ref['reference'] as String?;
    if (refStr == null) return ref;

    // Handle contained resources (starting with #)
    if (refStr.startsWith('#') && sourceResource != null) {
      final id = refStr.substring(1);
      final contained = sourceResource['contained'] as List?;
      if (contained != null) {
        for (final res in contained) {
          final resMap = res as Map<String, dynamic>;
          if (resMap['id'] == id) return resMap;
        }
      }
    }

    if (bundleEntries == null) return ref;

    final resourceId = refStr.split('/').last;

    for (final entry in bundleEntries) {
      final entryMap = entry as Map<String, dynamic>;
      final resource = entryMap['resource'] as Map<String, dynamic>?;
      if (resource == null) continue;

      // Match by fullUrl, resourceType/id, or just id
      final fullUrl = entryMap['fullUrl'] as String?;
      final resType = resource['resourceType'] as String?;

      if (fullUrl == refStr) return resource;
      if (resType != null && resource['id'] == resourceId) return resource;
      if ('$resType/${resource['id']}' == refStr) return resource;
    }

    return ref; // Fallback to reference if not resolved
  }

  /// Extract a human-readable display from a reference
  static String? _extractDisplay(dynamic reference) {
    if (reference == null || reference is! Map) return 'Unknown';
    final ref = reference as Map;
    if (ref['display'] != null) return ref['display'] as String;
    if (ref['text'] != null) return ref['text'] as String;
    if (ref['reference'] != null) return ref['reference'] as String;

    final identifier = ref['identifier'] as Map<String, dynamic>?;
    if (identifier != null) {
      return identifier['value'] as String? ?? identifier['system'] as String?;
    }
    return 'Unknown';
  }

  static Map<String, dynamic> _createSyntheticComposition(List<dynamic> entries) {
    final sections = <Map<String, dynamic>>[];
    final resourcesBySection = <String, List<Map<String, dynamic>>>{};

    for (final entry in entries) {
      final resource = entry['resource'] as Map<String, dynamic>?;
      if (resource == null) continue;

      final type = resource['resourceType'] as String?;
      String? sectionTitle;
      switch (type) {
        case 'MedicationStatement':
        case 'MedicationRequest':
          sectionTitle = 'Medications';
          break;
        case 'AllergyIntolerance':
          sectionTitle = 'Allergies';
          break;
        case 'Condition':
          sectionTitle = 'Conditions';
          break;
        case 'Observation':
          sectionTitle = 'Observations';
          break;
      }

      if (sectionTitle != null) {
        resourcesBySection.putIfAbsent(sectionTitle, () => []).add(resource);
      }
    }

    resourcesBySection.forEach((title, resources) {
      sections.add({
        'title': title,
        'entries': resources,
      });
    });

    // Try to find patient name
    String? patientName;
    for (final entry in entries) {
      final resource = entry['resource'] as Map<String, dynamic>?;
      if (resource?['resourceType'] == 'Patient') {
        final names = resource!['name'] as List?;
        if (names != null && names.isNotEmpty) {
          final first = names.first;
          final given = (first['given'] as List?)?.join(' ') ?? '';
          final family = first['family'] as String? ?? '';
          patientName = '$given $family'.trim();
          if (patientName!.isEmpty) patientName = null;
        }
        break;
      }
    }

    return {
      'id': 'synthetic-${DateTime.now().millisecondsSinceEpoch}',
      'date': DateTime.now().toIso8601String(),
      'title': 'Synthetic Summary',
      'status': 'final',
      'patient': patientName,
      'sections': sections,
    };
  }
}
