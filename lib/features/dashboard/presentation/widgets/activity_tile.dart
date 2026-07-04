import 'package:flutter/material.dart';
import 'package:orionhealth_health/core/theme/cyber_theme.dart';
import 'package:orionhealth_health/core/widgets/glassmorphic_card.dart';

class ActivityTile extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;

  const ActivityTile({
    super.key,
    required this.title,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: CyberTheme.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: CyberTheme.secondary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(time, style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      ),
    );
  }
}
