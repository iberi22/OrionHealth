import '../entities/medical_query.dart';
import '../entities/ai_response.dart';

/// Abstract repository for medical assistant operations
abstract class MedicalAssistantRepository {
  /// Submit a medical query and get AI response
  Future<AiMedicalResponse> submitQuery(MedicalQuery query);

  /// Get conversation history for a user
  Future<List<AiMedicalResponse>> getHistory(String userId, {int limit = 20});

  /// Clear conversation history
  Future<void> clearHistory(String userId);

  /// Save a response to history
  Future<void> saveResponse(AiMedicalResponse response);
}
