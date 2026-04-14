import 'package:flutter/material.dart';
import '../../../../core/theme/cyber_theme.dart';

class MedicationsPage extends StatelessWidget {
  const MedicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicamentos'),
      ),
      body: const Center(
        child: Text(
          'Página de Medicamentos (Próximamente)',
          style: TextStyle(color: CyberTheme.primary),
        ),
      ),
    );
  }
}
