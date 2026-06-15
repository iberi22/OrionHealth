import 'package:shared_preferences/shared_preferences.dart';
import 'package:orion/config/app_config.dart';

/// Stores and retrieves user ASR preferences.
class AsrSettings {
  static const _kPreferredModel = 'preferred_asr_model';
  static const _kAsrProvider = 'asr_provider'; // 'ondevice' or 'mock'

  static Future<String> getPreferredModel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kPreferredModel) ?? AppConfig.asrModel;
    } catch (_) {
      return AppConfig.asrModel;
    }
  }

  static Future<void> setPreferredModel(String modelKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPreferredModel, modelKey);
  }

  static Future<String> getAsrProvider() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kAsrProvider) ?? AppConfig.asrProvider;
    } catch (_) {
      return AppConfig.asrProvider;
    }
  }

  static Future<void> setAsrProvider(String provider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAsrProvider, provider);
  }
}
