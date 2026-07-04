import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/dashboard_preference.dart';

void main() {
  group('DashboardPreference', () {
    test('props are correct', () {
      final pref = DashboardPreference(key: 'key', value: 'value');
      expect(pref.key, 'key');
      expect(pref.value, 'value');
    });
  });
}
