// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../application/home_cubit.dart';
import '../../application/home_state.dart';
import '../../../vitals/domain/entities/vital_sign.dart';

class HealthStatusGrid extends StatelessWidget {
  const HealthStatusGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final vitals = state.healthSummary?.latestVitals ?? [];

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildVitalCard(
              context,
              'Ritmo Cardíaco',
              _getVitalValue(vitals, VitalSignType.heartRate),
              Icons.favorite,
              Colors.redAccent,
            ),
            _buildVitalCard(
              context,
              'Temperatura',
              _getVitalValue(vitals, VitalSignType.temperature),
              Icons.thermostat,
              Colors.blueAccent,
            ),
            _buildVitalCard(
              context,
              'Pasos',
              _getVitalValue(vitals, VitalSignType.steps),
              Icons.directions_walk,
              Colors.orangeAccent,
            ),
            _buildVitalCard(
              context,
              'Saturación O2',
              _getVitalValue(vitals, VitalSignType.spO2) ?? _getVitalValue(vitals, VitalSignType.oxygenSaturation),
              Icons.opacity,
              Colors.cyanAccent,
            ),
          ],
        );
      },
    );
  }

  String? _getVitalValue(List<VitalSign> vitals, VitalSignType type) {
    try {
      final vital = vitals.firstWhere((v) => v.type == type);
      return vital.formattedValue;
    } catch (_) {
      return null;
    }
  }

  Widget _buildVitalCard(
    BuildContext context,
    String label,
    String? value,
    IconData icon,
    Color color,
  ) {
    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value ?? '--',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
