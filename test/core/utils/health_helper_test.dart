import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:orionhealth_health/core/utils/health_helper.dart';

void main() {
  group('HealthHelper', () {
    test('createClient returns a Health instance (in test environment)', () {
      final client = HealthHelper.createClient();
      expect(client, isA<Health>());
    });
  });
}
