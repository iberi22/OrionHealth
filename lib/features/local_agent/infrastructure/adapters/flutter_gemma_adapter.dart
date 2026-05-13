import 'dart:async';

import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/local_model_descriptor.dart';
import '../../domain/services/llm_adapter.dart';

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
  Stream<int> installModel({
    required ModelType modelType,
    required String url,
    String? authToken,
    String? modelId,
  }) {
    final controller = StreamController<int>.broadcast();
    final builder = FlutterGemma.installModel(modelType: modelType)
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
  Future<bool> isModelInstalled(String modelId) =>
      FlutterGemma.isModelInstalled(modelId);

  /// List all installed model file identifiers.
  Future<List<String>> listInstalledModels() =>
      FlutterGemma.listInstalledModels();

  /// Uninstall (delete) a model from disk.
  Future<void> uninstallModel(String modelId) async {
    await FlutterGemma.uninstallModel(modelId);
    if (_activeModel != null) {
      final active = _activeSpec;
      if (active != null && active.name == modelId) {
        _activeModel = null;
      }
    }
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
