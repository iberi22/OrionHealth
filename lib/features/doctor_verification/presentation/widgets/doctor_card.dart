import 'package:flutter/material.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../domain/entities/doctor_profile.dart';

class DoctorCard extends StatelessWidget {
  final DoctorProfile doctor;
  final double rating;
  final VoidCallback onTap;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.rating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: CyberTheme.primary.withValues(alpha: 0.2),
          child: const Icon(Icons.person, color: CyberTheme.primary),
        ),
        title: Text(
          doctor.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(doctor.specialty),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                children: [
                  Icon(
                    doctor.verified ? Icons.verified : Icons.warning_amber_rounded,
                    size: 14,
                    color: doctor.verified ? Colors.greenAccent : Colors.orangeAccent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    doctor.verified ? 'Verificado' : 'Sin verificar',
                    style: TextStyle(
                      fontSize: 12,
                      color: doctor.verified ? Colors.greenAccent : Colors.orangeAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 12, color: Colors.amber),
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: onTap,
      ),
    );
  }
}
