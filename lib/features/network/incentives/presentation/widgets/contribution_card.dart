// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orionhealth_health/core/widgets/glassmorphic_card.dart';
import 'package:orionhealth_health/core/theme/cyber_theme.dart';
import '../../domain/entities/contribution.dart';

class ContributionCard extends StatelessWidget {
  final Contribution contribution;

  const ContributionCard({
    super.key,
    required this.contribution,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getTypeColor(contribution.type).withAlpha(40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getTypeIcon(contribution.type),
                color: _getTypeColor(contribution.type),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTypeName(contribution.type),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy HH:mm').format(contribution.timestamp),
                    style: TextStyle(
                      color: Colors.white.withAlpha(150),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '+${contribution.rewardPoints}',
              style: const TextStyle(
                color: CyberTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(ContributionType type) {
    switch (type) {
      case ContributionType.storage:
        return Icons.storage;
      case ContributionType.dataSharing:
        return Icons.share;
      case ContributionType.validation:
        return Icons.verified_user;
    }
  }

  Color _getTypeColor(ContributionType type) {
    switch (type) {
      case ContributionType.storage:
        return Colors.blue;
      case ContributionType.dataSharing:
        return Colors.green;
      case ContributionType.validation:
        return Colors.orange;
    }
  }

  String _getTypeName(ContributionType type) {
    switch (type) {
      case ContributionType.storage:
        return 'Almacenamiento';
      case ContributionType.dataSharing:
        return 'Compartir Datos';
      case ContributionType.validation:
        return 'Validación';
    }
  }
}
