import 'package:injectable/injectable.dart';
import '../../domain/services/llm_adapter.dart';

/// Mock LLM Adapter for testing and development
///
/// This adapter provides rule-based summarization without requiring
/// external API calls, useful for:
/// - Development without API keys
/// - Testing
/// - Privacy-first local-only mode
@Injectable(as: LlmAdapter)
class MockLlmAdapter implements LlmAdapter {
  @override
  String get modelName => 'mock-local';

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<String> generate(String prompt) async {
    // Simple rule-based summarization
    await Future.delayed(
        const Duration(milliseconds: 100)); // Simulate processing

    // Extract key information from prompt
    if (prompt.contains('Summarize')) {
      return _generateSummary(prompt);
    } else if (prompt.contains('user') || prompt.contains('health')) {
      return _generateHealthSummary(prompt);
    } else {
      return 'Summary: ${_truncate(prompt, 200)}';
    }
  }

  String _generateSummary(String content) {
    // Extract sentences
    final sentences = content
        .split(RegExp(r'[.!?]+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    if (sentences.isEmpty) {
      return 'No significant information to summarize.';
    }

    // Take first few sentences as summary
    final summaryParts = sentences.take(3).map((s) => s.trim()).toList();
    return summaryParts.join('. ') + '.';
  }

  String _generateHealthSummary(String content) {
    final keywords = [
      'health',
      'medical',
      'diagnosis',
      'treatment',
      'medication',
      'symptom'
    ];
    final relevantSentences = content
        .split(RegExp(r'[.!?]+'))
        .where((s) => keywords.any((k) => s.toLowerCase().contains(k)))
        .take(2)
        .toList();

    if (relevantSentences.isEmpty) {
      return 'Health data aggregation: ${_truncate(content, 150)}';
    }

    return 'Health Summary: ${relevantSentences.join('. ')}.';
  }

  String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
