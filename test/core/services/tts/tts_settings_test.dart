import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orionhealth_health/core/services/tts/tts_settings.dart';

void main() {
  group('TTSSettings', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('getPreferredVoice returns default when not set', () async {
      final voice = await TTSSettings.getPreferredVoice();
      expect(voice, TTSSettings.defaultTtsVoice);
    });

    test('setPreferredVoice persists value', () async {
      await TTSSettings.setPreferredVoice('en-US');
      final voice = await TTSSettings.getPreferredVoice();
      expect(voice, 'en-US');
    });
  });
}
