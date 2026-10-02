import 'package:health_contract/health_contract.dart';

/// Compile to JS and run under Node to verify the archive web implementation.
void main() {
  final record = Envelope.fromJson({
    'schema': 'swal.health/v1/dietary-profile',
    'id': '01J00000000000000000000000',
    'subject': 'subj_01J00000000000000000000000',
    'createdAt': '2026-10-02T18:00:00Z',
    'source': {'app': 'orionhealth', 'version': '1.0.0'},
    'gosDataset': '1.0.0+sha256:${'a' * 64}',
    'data': {
      'allergens': ['gos:allergen/peanut'],
      'diets': <String>[],
      'targets': <String, dynamic>{},
      'expiresAt': '2026-11-02T18:00:00Z',
    },
  });
  final link = encodeDeepLink([record], 'https://orionhealth.example/import');
  if (toFile(decodeDeepLink(link)) != toFile([record])) {
    throw StateError('Web gzip round-trip failed');
  }
  print('Web gzip round-trip passed');
}
