import 'package:flutter/material.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';

class MissionSection extends StatelessWidget {
  const MissionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMissionHeader(),
        const SizedBox(height: 24),
        _buildMissionStatement(),
        const SizedBox(height: 24),
        _buildValuesSection(),
        const SizedBox(height: 24),
        _buildWhatWeDoSection(),
      ],
    );
  }

  Widget _buildMissionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NUESTRA MISIÓN',
          style: TextStyle(
            color: CyberTheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'SALUD HUMANA COMO PRIORIDAD NÚMERO UNO',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'SpaceGrotesk',
          ),
        ),
      ],
    );
  }

  Widget _buildMissionStatement() {
    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Creemos que la salud es el activo más valioso de la humanidad. OrionHealth nace con la visión de poner la tecnología más avanzada al servicio del bienestar individual, garantizando la privacidad y el empoderamiento del paciente.',
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ),
    );
  }

  Widget _buildValuesSection() {
    final values = [
      'Cada persona merece acceso a su historial médico completo',
      'La privacidad médica es un derecho fundamental',
      'La IA médica debe estar al servicio de la salud, no de corporaciones',
      'Los datos de salud empoderan a las personas para tomar mejores decisiones',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Creemos que:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...values.map((value) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline, color: CyberTheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildWhatWeDoSection() {
    final activities = [
      'Almacenamos datos médicos de forma segura y encriptada en tu dispositivo',
      'Permitimos que modelos de IA analicen tu información para ayudarte',
      'Buscamos información médica actualizada de fuentes científicas confiables',
      'Conectamos personas con estándares de medicina mundial',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lo que hacemos:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...activities.map((activity) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.bolt, color: CyberTheme.secondary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      activity,
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
