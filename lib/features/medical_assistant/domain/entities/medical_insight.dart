import 'package:equatable/equatable.dart';

/// Severity level for medical insights
enum InsightSeverity { info, warning, alert, critical }

/// Category of medical insight
enum InsightCategory {
  labInterpretation,
  vitalSignAnalysis,
  riskAssessment,
  medicationInsight,
  guidelineRecommendation,
  generalGuidance,
  symptomAnalysis,
}

/// Represents a medical insight generated from analysis
class MedicalInsight extends Equatable {
  final String id;
  final String title;
  final String description;
  final InsightSeverity severity;
  final InsightCategory category;
  final String? guidelineReference;
  final List<String> recommendations;
  final DateTime generatedAt;
  final Map<String, dynamic>? evidence;

  const MedicalInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.category,
    this.guidelineReference,
    this.recommendations = const [],
    required this.generatedAt,
    this.evidence,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        severity,
        category,
        guidelineReference,
        recommendations,
        generatedAt,
      ];

  MedicalInsight copyWith({
    String? id,
    String? title,
    String? description,
    InsightSeverity? severity,
    InsightCategory? category,
    String? guidelineReference,
    List<String>? recommendations,
    DateTime? generatedAt,
    Map<String, dynamic>? evidence,
  }) {
    return MedicalInsight(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      category: category ?? this.category,
      guidelineReference: guidelineReference ?? this.guidelineReference,
      recommendations: recommendations ?? this.recommendations,
      generatedAt: generatedAt ?? this.generatedAt,
      evidence: evidence ?? this.evidence,
    );
  }

  String get severityLabel {
    switch (severity) {
      case InsightSeverity.info:
        return 'Informativo';
      case InsightSeverity.warning:
        return 'Advertencia';
      case InsightSeverity.alert:
        return 'Alerta';
      case InsightSeverity.critical:
        return 'Crítico';
    }
  }
}
