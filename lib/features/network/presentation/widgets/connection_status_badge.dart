import 'package:flutter/material.dart';
import '../../../../core/utils/connectivity_manager.dart';

class ConnectionStatusBadge extends StatelessWidget {
  final ConnectivityStatus? initialStatus;
  final Stream<ConnectivityStatus>? statusStream;

  const ConnectionStatusBadge({
    super.key,
    this.initialStatus,
    this.statusStream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityStatus>(
      stream: statusStream ?? ConnectivityManager().statusStream,
      initialData: initialStatus ?? ConnectivityManager().currentStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? ConnectivityStatus.unknown;
        final isOnline = status == ConnectivityStatus.connected;
        final isUnknown = status == ConnectivityStatus.unknown;

        final color = isUnknown
            ? Colors.grey
            : (isOnline ? Colors.green : Colors.red);

        final icon = isUnknown
            ? Icons.help_outline
            : (isOnline ? Icons.wifi : Icons.wifi_off);

        final label = isUnknown
            ? 'UNKNOWN'
            : (isOnline ? 'ONLINE' : 'OFFLINE');

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
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
