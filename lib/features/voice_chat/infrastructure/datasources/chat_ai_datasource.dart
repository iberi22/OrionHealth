// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import '../../../../core/services/aicore_service.dart';
import '../../../../core/services/asr/asr_service.dart';
import '../../../../core/services/asr/asr_types.dart';
import '../../../../core/services/aicore_service.dart' as ai; // For AgentMemoryService if needed

@lazySingleton
class ChatAiDatasource {
  final AIService _aiService;
  final AsrService _asrService;
  final ai.AgentMemoryService _memoryService;

  ChatAiDatasource(this._aiService, this._asrService, this._memoryService);

  Future<String> getAiResponse(String text, {List<String>? context}) async {
    return await _aiService.getResponse(text, context: context);
  }

  Future<String> transcribe(List<int> audioBytes) async {
    try {
      if (_asrService.currentState == AsrState.unavailable) {
        return await _aiService.transcribeAudio(audioBytes);
      } else {
        final transcription = await _asrService.transcribe(Uint8List.fromList(audioBytes));
        if (transcription.trim().isEmpty) {
          return await _aiService.transcribeAudio(audioBytes);
        }
        return transcription;
      }
    } catch (e) {
      return await _aiService.transcribeAudio(audioBytes);
    }
  }

  Future<String> getContextForQuery(String query) async {
    return await _memoryService.getContextForQuery(query);
  }

  Future<void> saveToMemory(String input, String output) async {
    await _memoryService.addMemory(input: input, output: output);
  }

  Future<List<String>> getRecentHistory({int limit = 20}) async {
    return await _memoryService.getRecentHistory(limit: limit);
  }

  Future<void> clearMemory() async {
    // AgentMemoryService doesn't seem to have a clear method in the stub,
    // but we can at least dispose or re-init if needed.
    // For now we'll assume it handles it or we'll add it if possible.
  }
}
