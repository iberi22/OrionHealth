import 'package:shared_preferences/shared_preferences.dart';

/// Stores and retrieves user TTS preferences.
class TTSSettings {
  static const _kPreferredVoice = 'preferred_tts_voice';
  static const String defaultTtsVoice = 'es-ES';

  /// Returns the preferred voice or defaults to the default voice.
  static Future<String> getPreferredVoice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kPreferredVoice) ?? defaultTtsVoice;
    } catch (_) {
      return defaultTtsVoice;
    }
  }

  /// Sets the preferred voice.
  static Future<void> setPreferredVoice(String voiceKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPreferredVoice, voiceKey);
  }
}
