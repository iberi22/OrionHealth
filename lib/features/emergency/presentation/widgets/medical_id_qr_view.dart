/// FEAT-022: QR code display widget
///
/// Renders the Medical ID QR string as a text widget.
/// In production: integrate with qr_flutter package for actual QR rendering.
/// MVP: show the encoded string with copy-to-clipboard (for manual sharing).
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/medical_id.dart';
import '../../infrastructure/services/qr_generator_service.dart';

class MedicalIdQrView extends StatelessWidget {
  final MedicalIdEntity medicalId;
  const MedicalIdQrView({super.key, required this.medicalId});

  @override
  Widget build(BuildContext context) {
    final qr = QrGeneratorService().generate(medicalId);
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('QR Médico',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // Visual placeholder — real QR rendered with qr_flutter in production
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2),
              ),
              alignment: Alignment.center,
              child: const Text('QR', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 12),
            SelectableText(
              qr,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text('Copiar'),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: qr));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('QR copiado al portapapeles')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
