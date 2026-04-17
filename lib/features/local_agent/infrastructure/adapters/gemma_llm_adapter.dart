import 'package:injectable/injectable.dart';
import '../../domain/services/llm_adapter.dart';
import '../llama_inference_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

@LazySingleton(as: LlmAdapter)
@Named('gemma')
class GemmaLlmAdapter implements LlmAdapter {
  final LlamaInferenceService _llamaService;
  bool _isLoaded = false;

  GemmaLlmAdapter(this._llamaService);

  @override
  String get modelName => 'gemma-4-e2b';

  @override
  Future<bool> isAvailable() async {
    return true;
  }

  Future<void> _ensureModelLoaded() async {
    if (_isLoaded) return;

    // Request permissions for external storage on Android
    if (Platform.isAndroid) {
      await [
        Permission.storage,
        Permission.manageExternalStorage,
      ].request();
    }

    // Direct filesystem path as per user's location on their system.
    // On Android, we'll check common locations where the user might have copied the file.

    final List<String> possiblePaths = [
      '/sdcard/Download/gemma-4-E2B-it-uncensored-Q4_K_M.gguf',
      '/storage/emulated/0/Download/gemma-4-E2B-it-uncensored-Q4_K_M.gguf',
    ];

    // If running on Windows, also check the specific provided path
    if (Platform.isWindows) {
      possiblePaths.add('E:\\datasetsDrive\\models\\gemma-4-E2B-it-uncensored-Q4_K_M.gguf');
    }

    String? foundPath;
    for (final path in possiblePaths) {
      try {
        if (await File(path).exists()) {
          foundPath = path;
          break;
        }
      } catch (e) {
        print("Error checking path $path: $e");
      }
    }

    if (foundPath == null) {
      final directory = await getApplicationDocumentsDirectory();
      final modelPath = p.join(directory.path, 'models', 'gemma-4-E2B-it-uncensored-Q4_K_M.gguf');
      if (await File(modelPath).exists()) {
        foundPath = modelPath;
      }
    }

    if (foundPath != null) {
      await _llamaService.loadModel(foundPath);
      _isLoaded = true;
    } else {
      print("CRITICAL: GGUF model not found. AI agent will not function.");
    }
  }

  @override
  Future<String> generate(String prompt) async {
    await _ensureModelLoaded();
    return await _llamaService.generate(prompt);
  }
}
