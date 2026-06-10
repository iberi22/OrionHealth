import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glassmorphic_card.dart';

class MissionSection extends StatelessWidget {
  final String missionStatement;
  final List<String> values;
  final List<String> activities;

  const MissionSection({
    super.key,
    required this.missionStatement,
    required this.values,
    required this.activities,
  });

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
        const Text(
          'NUESTRA MISIÓN',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
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
          missionStatement,
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }

  Widget _buildValuesSection() {
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
                  const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildWhatWeDoSection() {
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
                  const Icon(Icons.bolt, color: AppColors.secondary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      activity,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
