import 'package:flutter/material.dart';
import '../../../../core/theme/cyber_theme.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas'),
      ),
      body: const Center(
        child: Text(
          'Página de Citas (Próximamente)',
          style: TextStyle(color: CyberTheme.primary),
        ),
      ),
    );
  }
}
