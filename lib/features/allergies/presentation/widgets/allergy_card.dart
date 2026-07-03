import 'package:flutter/material.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../domain/entities/allergy.dart';

class AllergyCard extends StatelessWidget {
  final Allergy allergy;
  final bool isCritical;
  final VoidCallback? onTap;

  const AllergyCard({
    super.key,
    required this.allergy,
    this.isCritical = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: GlassmorphicCard(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: isCritical
                ? BoxDecoration(
                    border: Border.all(
                        color: Colors.red.withValues(alpha: 0.5), width: 2),
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.red.withValues(alpha: 0.05),
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      allergy.allergen ?? 'Desconocido',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    _buildSeverityBadge(allergy.severity),
                  ],
                ),
                if (allergy.notes != null && allergy.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    allergy.notes!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(AllergySeverity severity) {
    Color color;
    String label;

    switch (severity) {
      case AllergySeverity.mild:
        color = Colors.green;
        label = 'Leve';
        break;
      case AllergySeverity.moderate:
        color = Colors.yellow;
        label = 'Moderada';
        break;
      case AllergySeverity.severe:
        color = Colors.red;
        label = 'Severa';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
