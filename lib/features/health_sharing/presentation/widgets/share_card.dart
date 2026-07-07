import 'package:flutter/material.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../domain/entities/shared_health_package.dart';

class ShareCard extends StatelessWidget {
  final TransferMethod method;
  final Set<DataCategory> categories;
  final bool isSharing;
  final double progress;
  final String? statusMessage;
  final VoidCallback onShare;
  final VoidCallback onCancel;

  const ShareCard({
    super.key,
    required this.method,
    required this.categories,
    this.isSharing = false,
    this.progress = 0,
    this.statusMessage,
    required this.onShare,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _buildMethodIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Compartir vía ${method.displayName}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${categories.length} categorías seleccionadas',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isSharing) ...[
              Text(
                statusMessage ?? 'Transferiendo...',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
            ] else ...[
              const Divider(color: Colors.white24),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: categories.isEmpty ? null : onShare,
                  icon: const Icon(Icons.share),
                  label: const Text('Compartir Ahora'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMethodIcon() {
    IconData iconData;
    switch (method) {
      case TransferMethod.nfc:
        iconData = Icons.nfc;
        break;
      case TransferMethod.ble:
        iconData = Icons.bluetooth;
        break;
      case TransferMethod.wifi:
        iconData = Icons.wifi;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: Colors.white, size: 28),
    );
  }
}
