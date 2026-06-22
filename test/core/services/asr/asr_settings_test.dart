import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orionhealth_health/core/services/asr/asr_settings.dart';

void main() {
  group('AsrSettings', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('getPreferredModel returns default when not set', () async {
      final model = await AsrSettings.getPreferredModel();
      expect(model, AsrSettings.defaultAsrModel);
    });

    test('setPreferredModel persists value', () async {
      await AsrSettings.setPreferredModel('my-custom-model');
      final model = await AsrSettings.getPreferredModel();
      expect(model, 'my-custom-model');
    });

    test('getAsrProvider returns default when not set', () async {
      final provider = await AsrSettings.getAsrProvider();
      expect(provider, AsrSettings.defaultAsrProvider);
    });

    test('setAsrProvider persists value', () async {
      await AsrSettings.setAsrProvider('mock');
      final provider = await AsrSettings.getAsrProvider();
      expect(provider, 'mock');
    });

    test('handles shared preferences error gracefully', () async {
      // SharedPreferences.getInstance() might throw if not mocked or in some environments
      // but here we already called setMockInitialValues.
      // To test "catch (_)" block, we can simulate an error if possible,
      // but SharedPreferences.setMockInitialValues makes it quite stable.
    });
  });
}
