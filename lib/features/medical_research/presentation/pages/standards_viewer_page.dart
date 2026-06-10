import 'package:flutter/material.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';

class StandardsViewerPage extends StatelessWidget {
  const StandardsViewerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('VISOR DE ESTÁNDARES'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildStandardCategory(
            context,
            'ICD-10',
            'Clasificación Internacional de Enfermedades',
            Icons.tag,
            '14,000+ códigos',
          ),
          const SizedBox(height: 12),
          _buildStandardCategory(
            context,
            'LOINC',
            'Observaciones de Laboratorio',
            Icons.biotech,
            '98,000+ códigos',
          ),
          const SizedBox(height: 12),
          _buildStandardCategory(
            context,
            'RxNorm',
            'Terminología de Medicamentos',
            Icons.medication,
            'Normas de prescripción',
          ),
          const SizedBox(height: 12),
          _buildStandardCategory(
            context,
            'SNOMED CT',
            'Terminología Clínica Sistematizada',
            Icons.account_tree,
            '350,000+ conceptos',
          ),
        ],
      ),
    );
  }

  Widget _buildStandardCategory(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    String stats,
  ) {
    return GlassmorphicCard(
      child: ListTile(
        leading: Icon(icon, color: CyberTheme.primary, size: 32),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Icon(Icons.chevron_right, color: Colors.white54),
            const SizedBox(height: 4),
            Text(
              stats,
              style: const TextStyle(color: CyberTheme.secondary, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
