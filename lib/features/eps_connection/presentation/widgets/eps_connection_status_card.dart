import 'package:flutter/material.dart';
import '../../domain/entities/eps_connection.dart';
import '../../../../core/widgets/glassmorphic_card.dart';

class EpsConnectionStatusCard extends StatelessWidget {
  final EPSConnection connection;
  final VoidCallback onDisconnect;

  const EpsConnectionStatusCard({
    super.key,
    required this.connection,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withValues(alpha: 0.2),
          child: const Icon(Icons.link, color: Colors.green),
        ),
        title: Text(
          connection.provider.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient ID: ${connection.patientId}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              'Connected: ${connection.connectedAt.toString().substring(0, 16)}',
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.link_off, color: Colors.redAccent),
          onPressed: onDisconnect,
        ),
      ),
    );
  }
}
