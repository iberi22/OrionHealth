import 'package:flutter/material.dart';
import '../../domain/entities/medical_insight.dart';

/// Compact card widget for displaying lab result insights
class LabResultCard extends StatelessWidget {
  final MedicalInsight insight;

  const LabResultCard({
    super.key,
    required this.insight,
  });

  @override
  Widget build(BuildContext context) {
    final evidence = insight.evidence;
    final value = _extractValue(evidence);
    final unit = _extractUnit(evidence);
    final reference = evidence?['reference'] as String?;

    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _backgroundColor(insight.severity),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _severityColor(insight.severity).withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _LabIcon(severity: insight.severity),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  insight.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (value != null) ...[
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _severityColor(insight.severity),
                    ),
                  ),
                  if (unit != null)
                    TextSpan(
                      text: ' $unit',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ] else ...[
            Text(
              insight.severityLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _severityColor(insight.severity),
              ),
            ),
          ],
          const Spacer(),
          if (reference != null)
            Text(
              'Ref: $reference',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  String? _extractValue(Map<String, dynamic>? evidence) {
    if (evidence == null) return null;
    final v = evidence['value'];
    if (v is num) return v.toString();
    return null;
  }

  String? _extractUnit(Map<String, dynamic>? evidence) {
    if (evidence == null) return null;
    return evidence['unit'] as String?;
  }

  Color _backgroundColor(InsightSeverity severity) {
    switch (severity) {
      case InsightSeverity.critical:
        return Colors.red.shade50;
      case InsightSeverity.alert:
        return Colors.orange.shade50;
      case InsightSeverity.warning:
        return Colors.amber.shade50;
      case InsightSeverity.info:
        return Colors.blue.shade50;
    }
  }

  Color _severityColor(InsightSeverity severity) {
    switch (severity) {
      case InsightSeverity.critical:
        return Colors.red;
      case InsightSeverity.alert:
        return Colors.orange;
      case InsightSeverity.warning:
        return Colors.amber.shade700;
      case InsightSeverity.info:
        return Colors.blue;
    }
  }
}

class _LabIcon extends StatelessWidget {
  final InsightSeverity severity;

  const _LabIcon({required this.severity});

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
        icon = Icons.science;
        color = Colors.amber.shade700;
      case InsightSeverity.info:
        icon = Icons.science_outlined;
        color = Colors.blue;
    }

    return Icon(icon, color: color, size: 16);
  }
}
