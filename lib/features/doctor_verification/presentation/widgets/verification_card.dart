import 'package:flutter/material.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../domain/entities/doctor_profile.dart';
import '../../domain/entities/verification_status.dart';

class VerificationCard extends StatelessWidget {
  final DoctorProfile doctor;
  final VerificationStatus status;
  final VoidCallback? onVerify;

  const VerificationCard({
    super.key,
    required this.doctor,
    required this.status,
    this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        doctor.specialty,
                        style: TextStyle(
                          fontSize: 14,
                          color: CyberTheme.secondary.withValues(alpha: 0.8),
                        ),
                      ),
                      Text(
                        'ID: ${doctor.id}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),
            const SizedBox(height: 16),
            if (status != VerificationStatus.verified)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('verify_button'),
                  onPressed: onVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: status == VerificationStatus.rejected
                        ? Colors.orangeAccent
                        : CyberTheme.primary,
                    foregroundColor: Colors.black,
                  ),
                  child: Text(
                    status == VerificationStatus.rejected
                        ? 'REINTENTAR VERIFICACIÓN'
                        : 'VERIFICAR AHORA',
                  ),
                ),
              ),
            if (status == VerificationStatus.verified)
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Perfil verificado correctamente',
                    style: TextStyle(color: Colors.greenAccent, fontSize: 12),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case VerificationStatus.pending:
        color = Colors.orangeAccent;
        text = 'PENDIENTE DE VERIFICACIÓN';
        icon = Icons.hourglass_empty;
        break;
      case VerificationStatus.verified:
        color = Colors.greenAccent;
        text = 'MÉDICO VERIFICADO';
        icon = Icons.verified;
        break;
      case VerificationStatus.rejected:
        color = Colors.redAccent;
        text = 'VERIFICACIÓN RECHAZADA';
        icon = Icons.error_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
