import 'package:flutter/material.dart';
import '../../domain/entities/medical_insight.dart';

/// Card widget for displaying a medical insight
class InsightCard extends StatelessWidget {
  final MedicalInsight insight;
  final VoidCallback? onTap;

  const InsightCard({
    super.key,
    required this.insight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _severityColor(insight.severity).withAlpha(77),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _SeverityIcon(severity: insight.severity),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _CategoryChip(category: insight.category),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                insight.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (insight.recommendations.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                ...insight.recommendations.take(2).map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline, 
                          size: 14, color: Colors.teal),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          rec,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
              if (insight.guidelineReference != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Ref: ${insight.guidelineReference}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _severityColor(InsightSeverity severity) {
    switch (severity) {
      case InsightSeverity.critical:
        return Colors.red;
      case InsightSeverity.alert:
        return Colors.orange;
      case InsightSeverity.warning:
        return Colors.amber;
      case InsightSeverity.info:
        return Colors.blue;
    }
  }
}

class _SeverityIcon extends StatelessWidget {
  final InsightSeverity severity;

  const _SeverityIcon({required this.severity});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (severity) {
      case InsightSeverity.critical:
        icon = Icons.error;
        color = Colors.red;
      case InsightSeverity.alert:
        icon = Icons.warning;
        color = Colors.orange;
      case InsightSeverity.warning:
        icon = Icons.info;
        color = Colors.amber;
      case InsightSeverity.info:
        icon = Icons.lightbulb_outline;
        color = Colors.blue;
    }

    return Icon(icon, color: color, size: 20);
  }
}

class _CategoryChip extends StatelessWidget {
  final InsightCategory category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _categoryColor(category).withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _categoryLabel(category),
        style: TextStyle(
          fontSize: 10,
          color: _categoryColor(category),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _categoryLabel(InsightCategory category) {
    switch (category) {
      case InsightCategory.labInterpretation:
        return 'Labs';
      case InsightCategory.vitalSignAnalysis:
        return 'Vitals';
      case InsightCategory.riskAssessment:
        return 'Risk';
      case InsightCategory.medicationInsight:
        return 'Meds';
      case InsightCategory.guidelineRecommendation:
        return 'Guidelines';
      case InsightCategory.generalGuidance:
        return 'General';
    }
  }

  Color _categoryColor(InsightCategory category) {
    switch (category) {
      case InsightCategory.labInterpretation:
        return Colors.purple;
      case InsightCategory.vitalSignAnalysis:
        return Colors.teal;
      case InsightCategory.riskAssessment:
        return Colors.deepOrange;
      case InsightCategory.medicationInsight:
        return Colors.blueGrey;
      case InsightCategory.guidelineRecommendation:
        return Colors.indigo;
      case InsightCategory.generalGuidance:
        return Colors.grey;
    }
  }
}
