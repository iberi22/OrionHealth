import 'package:flutter/material.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../domain/entities/doctor_profile.dart';
import '../widgets/verification_badge.dart';

class DoctorVerificationCard extends StatelessWidget {
  final DoctorProfile doctor;

  const DoctorVerificationCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.verified_user, color: CyberTheme.primary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ESTADO DE VERIFICACIÓN',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: CyberTheme.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          VerificationBadge(isVerified: doctor.verified),
          const SizedBox(height: 16),
          Text(
            doctor.verified
                ? 'Su perfil ha sido verificado exitosamente. Los pacientes pueden confiar en su identidad y credenciales.'
                : 'Su perfil aún no ha sido verificado. Complete el proceso de verificación para aumentar su visibilidad y confianza.',
            style: const TextStyle(color: Colors.white70),
          ),
          if (!doctor.verified) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            const Text(
              'FORMULARIO DE VERIFICACIÓN',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('license_number_field'),
              initialValue: doctor.licenseNumber,
              decoration: const InputDecoration(
                labelText: 'Número de Licencia',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('country_code_field'),
              initialValue: doctor.countryCode,
              decoration: const InputDecoration(
                labelText: 'País',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.public),
              ),
              readOnly: true,
            ),
          ],
        ],
      ),
    );
  }
}
