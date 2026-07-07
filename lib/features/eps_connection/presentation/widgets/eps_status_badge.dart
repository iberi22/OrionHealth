import 'package:flutter/material.dart';

enum EpsStatus { connected, disconnected, error }

class EpsStatusBadge extends StatelessWidget {
  final EpsStatus status;

  const EpsStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      EpsStatus.connected => Colors.green,
      EpsStatus.disconnected => Colors.grey,
      EpsStatus.error => Colors.red,
    };

    final icon = switch (status) {
      EpsStatus.connected => Icons.check_circle,
      EpsStatus.disconnected => Icons.info_outline,
      EpsStatus.error => Icons.error_outline,
    };

    final label = switch (status) {
      EpsStatus.connected => 'CONECTADO',
      EpsStatus.disconnected => 'DESCONECTADO',
      EpsStatus.error => 'ERROR',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
