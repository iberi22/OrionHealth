import 'package:flutter/material.dart';
import '../../../../core/theme/cyber_theme.dart';

class VitalSignsPage extends StatelessWidget {
  const VitalSignsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signos Vitales'),
      ),
      body: const Center(
        child: Text(
          'Página de Signos Vitales (Próximamente)',
          style: TextStyle(color: CyberTheme.primary),
        ),
      ),
    );
  }
}
