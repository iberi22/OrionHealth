import 'package:injectable/injectable.dart';
import '../../domain/entities/ai_response.dart';

@lazySingleton
class MedicalAssistantLocalDataSource {
  final List<AiMedicalResponse> _history = [];

  Future<void> saveResponse(AiMedicalResponse response) async {
    _history.add(response);
  }

  Future<List<AiMedicalResponse>> getHistory(String userId, {int limit = 20}) async {
    final sorted = List<AiMedicalResponse>.from(_history)
      ..sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
    return sorted.take(limit).toList();
  }

  Future<void> clearHistory(String userId) async {
    _history.clear();
  }
}
