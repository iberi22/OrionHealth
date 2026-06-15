// TODO: migrate from data/ — moved to infrastructure/services/rda_parser.dart
// This file is kept temporarily. Remove after verifying new imports work.

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
      return null;
    }

    final entries = fhirBundle['entry'] as List<dynamic>?;
    if (entries == null || entries.isEmpty) return null;

    // Find the Composition resource in the bundle
    Map<String, dynamic>? composition;
    for (final entry in entries) {
      final resource = entry['resource'] as Map<String, dynamic>?;
      if (resource?['resourceType'] == 'Composition') {
        composition = resource;
        break;
      }
    }

    if (composition == null) return null;
    return _parseComposition(composition, entries);
  }

  static Map<String, dynamic> _parseComposition(
    Map<String, dynamic> composition,
    [List<dynamic>? bundleEntries,
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
                  ?.map((e) => _resolveReference(e, bundleEntries))
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
      'type': composition['type']?['coding']?.first?['code'],
      'patient': composition['subject'] != null
          ? _extractDisplay(composition['subject'])
          : null,
      'author': composition['author']?.isNotEmpty == true
          ? _extractDisplay(composition['author']!.first)
          : null,
      'sections': sections,
    };
  }

  /// Resolve a reference to its full resource in the bundle
  static Map<String, dynamic>? _resolveReference(
    dynamic reference,
    List<dynamic>? bundleEntries,
  ) {
    if (reference == null) return null;

    final ref = reference as Map<String, dynamic>;
    final refStr = ref['reference'] as String?;
    if (refStr == null || bundleEntries == null) return ref;

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
    if (reference == null) return null;
    final ref = reference as Map<String, dynamic>;
    return ref['display'] as String? ?? ref['reference'] as String?;
  }
}
