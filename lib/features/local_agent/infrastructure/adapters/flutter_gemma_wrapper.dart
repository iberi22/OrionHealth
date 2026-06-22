import 'dart:async';
import 'package:flutter_gemma/flutter_gemma.dart' hide ModelType;
import 'package:flutter_gemma/flutter_gemma.dart' as gemma;
import 'package:injectable/injectable.dart';

/// Wrapper around FlutterGemma static methods to allow mocking in unit tests.
@lazySingleton
class FlutterGemmaWrapper {
  Future<void> initialize({
    String? huggingFaceToken,
    int maxDownloadRetries = 10,
  }) {
    return FlutterGemma.initialize(
      huggingFaceToken: huggingFaceToken,
      maxDownloadRetries: maxDownloadRetries,
    );
  }

  bool hasActiveModel() {
    return FlutterGemma.hasActiveModel();
  }

  Future<InferenceModel> getActiveModel({int maxTokens = 4096}) {
    return FlutterGemma.getActiveModel(maxTokens: maxTokens);
  }

  Future<bool> isModelInstalled(String modelId) async {
    // Note: The plugin seems to have inconsistent static vs instance methods
    // based on the adapter code. Let's stick to what's used.
    return FlutterGemma.isModelInstalled(modelId);
  }

  Future<List<String>> listInstalledModels() {
    return FlutterGemma.listInstalledModels();
  }

  Future<void> uninstallModel(String modelId) {
    return FlutterGemma.uninstallModel(modelId);
  }

  InferenceInstallationBuilder installModel(gemma.ModelType modelType) {
    return FlutterGemma.installModel(modelType: modelType);
  }

  ModelSpec? get activeInferenceModel =>
      FlutterGemmaPlugin.instance.modelManager.activeInferenceModel;
}
