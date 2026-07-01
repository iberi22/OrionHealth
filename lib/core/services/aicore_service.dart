// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

enum AicoreStatus { available, downloadable, unavailable, downloading }

class AicoreService {
  static const _channel = MethodChannel('com.orionhealth/aicore');

  bool _initialized = false;
  bool _useFullModel = false;

  static Future<void> setupEventListeners({
    void Function(int progress)? onDownloadProgress,
    void Function(String token)? onToken,
    void Function()? onComplete,
    void Function(String error)? onError,
  }) async {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onDownloadProgress':
          onDownloadProgress?.call(call.arguments['progress'] as int);
          break;
        case 'onToken':
          onToken?.call(call.arguments['token'] as String);
          break;
        case 'onComplete':
          onComplete?.call();
          break;
        case 'onError':
          onError?.call(call.arguments['error'] as String);
          break;
      }
    });
  }

  Future<bool> initialize({bool useFullModel = false}) async {
    try {
      _useFullModel = useFullModel;
      final result = await _channel.invokeMethod('initialize', {
        'useFullModel': useFullModel,
      });
      _initialized = result == true;
      return _initialized;
    } catch (e) {
      return false;
    }
  }

  Future<AicoreStatus> checkAvailability() async {
    try {
      final status = await _channel.invokeMethod<String>('checkAvailability');
      return AicoreStatus.values.firstWhere(
        (s) => s.name == status,
        orElse: () => AicoreStatus.unavailable,
      );
    } catch (e) {
      return AicoreStatus.unavailable;
    }
  }

  Future<bool> downloadModel() async {
    try {
      final result = await _channel.invokeMethod<bool>('downloadModel');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<String> generateContent(String prompt) async {
    try {
      final result = await _channel.invokeMethod<String>('generateContent', {
        'prompt': prompt,
      });
      return result ?? '';
    } catch (e) {
      throw Exception('Generation failed: $e');
    }
  }

  Future<void> generateContentStream(String prompt) async {
    await _channel.invokeMethod('generateContentStream', {'prompt': prompt});
  }

  Future<bool> warmup() async {
    try {
      final result = await _channel.invokeMethod<bool>('warmup');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  bool get isInitialized => _initialized;
  bool get usesFullModel => _useFullModel;
}

/// Stub — pending real AIService implementation
@lazySingleton
class AIService {
  final _stateController = StreamController<AIServiceState>.broadcast();

  AIServiceState _state = AIServiceState.loading;
  AIServiceState get currentState => _state;
  Stream<AIServiceState> get stateStream => _stateController.stream;

  Future<void> initialize() async {
    _state = AIServiceState.ready;
    _stateController.add(_state);
  }

  Future<String> getResponse(String input, {List<String>? context}) async {
    return 'Respuesta simulada';
  }

  Future<String> transcribeAudio(List<int> audioBytes) async {
    return 'Transcripción simulada';
  }

  void dispose() {
    _stateController.close();
  }
}

enum AIServiceState { loading, ready, error }

/// Stub — AgentMemoryService for xavier integration
@lazySingleton
class AgentMemoryService {
  Future<void> initialize() async {}

  Future<List<MemoryNode>> searchMemories({
    required String query,
    int limit = 5,
    double minScore = 0.6,
  }) async {
    return [];
  }

  Future<List<String>> getRecentHistory({int limit = 20}) async {
    return [];
  }

  Future<int> getMemoryCount() async {
    return 0;
  }

  Future<String> getContextForQuery(String query) async {
    return '';
  }

  Future<void> addMemory({
    required String input,
    required String output,
  }) async {}

  void dispose() {}
}

class MemoryNode {
  final String userInput;
  final String aiResponse;

  MemoryNode({required this.userInput, required this.aiResponse});
}
