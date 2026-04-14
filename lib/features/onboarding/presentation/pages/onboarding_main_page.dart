import 'package:flutter/material.dart';
import '../../../../core/theme/cyber_theme.dart';

class OnboardingMainPage extends StatelessWidget {
  const OnboardingMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.health_and_safety, size: 100, color: CyberTheme.primary),
            const SizedBox(height: 32),
            const Text(
              'Bienvenido a OrionHealth',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Tu asistente de salud privado y local.',
              style: TextStyle(fontSize: 18, color: CyberTheme.secondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 64),
            ElevatedButton(
              onPressed: () {
                // Future: Navigate to profile setup
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CyberTheme.primary,
                foregroundColor: CyberTheme.backgroundDark,
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text('Comenzar'),
            ),
          ],
        ),
      ),
    );
  }
}
