import 'dart:async';

import 'package:flutter_gemma/flutter_gemma.dart' hide ModelType;
import 'package:flutter_gemma/flutter_gemma.dart' as gemma;
import 'package:injectable/injectable.dart';

import '../../domain/services/llm_adapter.dart';
import '../../domain/entities/local_model_descriptor.dart';


/// flutter_gemma adapter for on-device LLM inference.
///
/// Uses flutter_gemma Modern API (v0.12.6+).
/// Supports Gemma 3/4, Qwen3, DeepSeek R1, Phi-4 Mini, SmolLM.
///
/// ## Lifecycle
/// 1. [initialize] — once at app startup.
/// 2. [installModel] — download a model (streams progress %).
/// 3. [generate] — run inference on the active model.
@LazySingleton(as: LlmAdapter)
@Named('gemma')
@LazySingleton(as: LlmAdapter)
@Named('gemma')
class FlutterGemmaAdapter implements LlmAdapter {
  InferenceModel? _activeModel;
  bool _initialized = false;

  // ── LlmAdapter interface ──

  @override
  String get modelName {
    final spec = _activeSpec;
    if (spec == null) return 'none';
    return spec.name;
  }

  @override
  Future<bool> isAvailable() async {
    try {
      await _ensureInitialized();
      return FlutterGemma.hasActiveModel() && _activeModel != null;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> generate(String prompt) async {
    await _ensureInitialized();
    final model = await _resolveActiveModel();

    final session = await model.createSession(
      temperature: 0.7,
      topK: 40,
    );

    try {
      await session.addQueryChunk(Message.text(text: prompt, isUser: true));
      return await session.getResponse();
    } finally {
      await session.close();
    }
  }

  // ── Public API ──

  /// The active [ModelSpec], if any.
  ModelSpec? get _activeSpec =>
      FlutterGemmaPlugin.instance.modelManager.activeInferenceModel;

  /// Initialize flutter_gemma. Must be called once before any other method.
  Future<void> initialize({
    String? huggingFaceToken,
    int maxDownloadRetries = 10,
  }) async {
    await FlutterGemma.initialize(
      huggingFaceToken: huggingFaceToken,
      maxDownloadRetries: maxDownloadRetries,
    );
    _initialized = true;
  }

  /// Install a model from a network URL.
  ///
  /// Returns a stream of progress percentages (0–100).
  /// On completion the model becomes the active inference model.
  @override
  Stream<int> installModel({
    required String modelId,
    required String url,
    String? authToken,
  }) {
    final descriptor = kAvailableLocalModels.firstWhere(
      (m) => m.id == modelId,
      orElse: () => throw ArgumentError('Unknown model ID: $modelId'),
    );

    final controller = StreamController<int>.broadcast();
    final gemmaModelType = _mapModelType(descriptor.modelType);
    final builder = FlutterGemma.installModel(modelType: gemmaModelType)
        .fromNetwork(url, token: authToken)
        .withProgress((p) => controller.add(p));

    builder.install().then((_) {
      controller.close();
    }).catchError((Object e) {
      controller.addError(e);
    });

    return controller.stream;
  }

  /// Check whether a model (by its file identifier) is installed.
  @override
  Future<bool> isModelInstalled(String modelId) =>
      FlutterGemma.isModelInstalled(modelId);

  /// List all installed model file identifiers.
  @override
  Future<List<String>> listInstalledModels() =>
      FlutterGemma.listInstalledModels();

  /// Uninstall (delete) a model from disk.
  @override
  Future<void> uninstallModel(String modelId) async {
    await FlutterGemma.uninstallModel(modelId);
    if (_activeModel != null) {
      final active = _activeSpec;
      if (active != null && active.name == modelId) {
        _activeModel = null;
      }
    }
  }

  @override
  Future<void> cancelDownload(String modelId) async {
    // Note: flutter_gemma might not support per-model cancellation yet
    // but we signal it to the plugin if available.
    // For now we just implement the interface.
  }

  /// Force reload the active [InferenceModel] from the current spec.
  /// Useful after installing a new model or on error recovery.
  Future<void> reloadActiveModel({int maxTokens = 4096}) async {
    if (FlutterGemma.hasActiveModel()) {
      _activeModel = await FlutterGemma.getActiveModel(maxTokens: maxTokens);
    } else {
      _activeModel = null;
    }
  }

  // ── Private ──

  Future<void> _ensureInitialized() async {
    if (!_initialized) await initialize();
  }

  gemma.ModelType _mapModelType(ModelType type) {
    switch (type) {
      case ModelType.gemmaIt:
        return gemma.ModelType.gemmaIt;
      case ModelType.qwen:
        return gemma.ModelType.qwen;
      case ModelType.deepSeek:
        return gemma.ModelType.deepSeek;
      case ModelType.llama:
        return gemma.ModelType.llama;
    }
  }

  Future<InferenceModel> _resolveActiveModel() async {
    if (_activeModel != null) return _activeModel!;
    if (!FlutterGemma.hasActiveModel()) {
      throw StateError(
        'No active model. Install one first via installModel().',
      );
    }
    _activeModel = await FlutterGemma.getActiveModel(maxTokens: 4096);
    return _activeModel!;
  }
}
