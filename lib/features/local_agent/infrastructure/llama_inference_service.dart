import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class LlamaInferenceService {
  static const platform = MethodChannel('com.orionhealth/llama');

  Future<void> loadModel(String ggufPath) async {
    try {
      await platform.invokeMethod('loadModel', {'path': ggufPath});
    } on PlatformException catch (e) {
      print("Failed to load model: '${e.message}'.");
      rethrow;
    }
  }

  Future<void> freeModel() async {
    try {
      await platform.invokeMethod('freeModel');
    } on PlatformException catch (e) {
      print("Failed to free model: '${e.message}'.");
    }
  }

  Future<String> generate(String prompt, {
    int maxTokens = 2048,
    double temperature = 0.7,
  }) async {
    try {
      final String? result = await platform.invokeMethod('generate', {
        'prompt': prompt,
        'maxTokens': maxTokens,
        'temperature': temperature,
      });
      return result ?? '';
    } on PlatformException catch (e) {
      print("Failed to generate text: '${e.message}'.");
      return "Error: ${e.message}";
    }
  }
}
