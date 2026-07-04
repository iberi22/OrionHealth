import 'package:flutter/material.dart';
import '../../domain/entities/network_health.dart';

class NetworkStatusCard extends StatelessWidget {
  final NetworkHealth health;

  const NetworkStatusCard({super.key, required this.health});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Network Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _StatusIndicator(status: health.status),
              ],
            ),
            const SizedBox(height: 16),
            _StatRow(label: 'Active Nodes', value: '${health.activeNodes}/${health.totalNodes}'),
            _StatRow(label: 'Average Latency', value: '${health.averageLatency.toStringAsFixed(1)} ms'),
            _StatRow(label: 'Uptime', value: '${health.uptimePercentage.toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final NetworkStatus status;

  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case NetworkStatus.healthy:
        color = Colors.green;
        label = 'Healthy';
        break;
      case NetworkStatus.congested:
        color = Colors.orange;
        label = 'Congested';
        break;
      case NetworkStatus.unstable:
        color = Colors.redAccent;
        label = 'Unstable';
        break;
      case NetworkStatus.down:
        color = Colors.red;
        label = 'Down';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
