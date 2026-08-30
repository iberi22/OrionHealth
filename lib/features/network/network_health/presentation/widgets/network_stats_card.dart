import 'package:flutter/material.dart';
import '../../domain/entities/network_health.dart';

class NetworkStatsCard extends StatelessWidget {
  final NetworkHealth health;

  const NetworkStatsCard({
    super.key,
    required this.health,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Text(
                    'Network Health',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _StatusBadge(status: health.status),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Nodes',
                    value: '${health.activeNodes}/${health.totalNodes}',
                    icon: Icons.hub,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Latency',
                    value: '${health.averageLatency.toStringAsFixed(1)}ms',
                    icon: Icons.speed,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Uptime',
                    value: '${health.uptimePercentage}%',
                    icon: Icons.timer,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final NetworkStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor()),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: _getStatusColor(),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case NetworkStatus.healthy:
        return Colors.green;
      case NetworkStatus.congested:
        return Colors.orange;
      case NetworkStatus.unstable:
        return Colors.yellow;
      case NetworkStatus.down:
        return Colors.red;
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueGrey),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
