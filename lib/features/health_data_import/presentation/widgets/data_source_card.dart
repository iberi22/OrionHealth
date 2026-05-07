import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../application/health_import_state.dart';

class DataSourceCard extends StatelessWidget {
  final HealthDataSource source;
  final bool isAvailable;
  final DateTime? lastSync;
  final VoidCallback? onImport;

  const DataSourceCard({
    super.key,
    required this.source,
    required this.isAvailable,
    this.lastSync,
    this.onImport,
  });

  IconData get _sourceIcon {
    switch (source) {
      case HealthDataSource.googleFit:
        return Icons.fitness_center;
      case HealthDataSource.appleHealth:
        return Icons.favorite;
      case HealthDataSource.samsungHealth:
        return Icons.health_and_safety;
    }
  }

  Color get _sourceColor {
    switch (source) {
      case HealthDataSource.googleFit:
        return const Color(0xFF4285F4);
      case HealthDataSource.appleHealth:
        return const Color(0xFFFF2D55);
      case HealthDataSource.samsungHealth:
        return const Color(0xFF1428A0);
    }
  }

  String get _lastSyncText {
    if (lastSync == null) return 'Never synced';
    final diff = DateTime.now().difference(lastSync!);
    if (diff.inMinutes < 60) return 'Last sync: ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Last sync: ${diff.inHours}h ago';
    return 'Last sync: ${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _sourceColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_sourceIcon, color: _sourceColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isAvailable ? AppColors.primary : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isAvailable ? 'Available' : 'Not available',
                            style: TextStyle(
                              color: isAvailable ? AppColors.primary : Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _lastSyncText,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isAvailable ? onImport : null,
                icon: const Icon(Icons.sync, size: 18),
                label: const Text('Import Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAvailable
                      ? AppColors.primary
                      : Colors.grey.withValues(alpha: 0.3),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
