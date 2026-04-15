import 'package:equatable/equatable.dart';
import 'medical_insight.dart';

/// Represents the complete AI-generated response to a medical query
class AiMedicalResponse extends Equatable {
  final String id;
  final String queryId;
  final String answer;
  final List<MedicalInsight> insights;
  final DateTime generatedAt;
  final String model;
  final double? confidence;
  final Map<String, dynamic>? metadata;

  const AiMedicalResponse({
    required this.id,
    required this.queryId,
    required this.answer,
    this.insights = const [],
    required this.generatedAt,
    this.model = 'medical-llm',
    this.confidence,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        queryId,
        answer,
        insights,
        generatedAt,
        model,
        confidence,
      ];

  AiMedicalResponse copyWith({
    String? id,
    String? queryId,
    String? answer,
    List<MedicalInsight>? insights,
    DateTime? generatedAt,
    String? model,
    double? confidence,
    Map<String, dynamic>? metadata,
  }) {
    return AiMedicalResponse(
      id: id ?? this.id,
      queryId: queryId ?? this.queryId,
      answer: answer ?? this.answer,
      insights: insights ?? this.insights,
      generatedAt: generatedAt ?? this.generatedAt,
      model: model ?? this.model,
      confidence: confidence ?? this.confidence,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get hasCriticalInsights =>
      insights.any((i) => i.severity == InsightSeverity.critical);

  bool get hasAlerts =>
      insights.any((i) => i.severity == InsightSeverity.alert);
}
