import 'package:shared_preferences/shared_preferences.dart';

/// Stores and retrieves user ASR preferences.
class AsrSettings {
  static const _kPreferredModel = 'preferred_asr_model';
  static const _kAsrProvider = 'asr_provider'; // 'ondevice' or 'mock'

  static const String defaultAsrModel = 'sense-voice-small';
  static const String defaultAsrProvider = 'ondevice';

  static Future<String> getPreferredModel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kPreferredModel) ?? defaultAsrModel;
    } catch (_) {
      return defaultAsrModel;
    }
  }

  static Future<void> setPreferredModel(String modelKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPreferredModel, modelKey);
  }

  static Future<String> getAsrProvider() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kAsrProvider) ?? defaultAsrProvider;
    } catch (_) {
      return defaultAsrProvider;
    }
  }

  static Future<void> setAsrProvider(String provider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAsrProvider, provider);
  }
}
