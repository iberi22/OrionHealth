import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../application/doctor_verification_cubit.dart';
import '../../application/doctor_verification_state.dart';
import '../../domain/entities/doctor_profile.dart';
import '../widgets/rating_dialog.dart';
import '../widgets/verification_badge.dart';

class DoctorDetailPage extends StatelessWidget {
  final DoctorProfile doctor;

  const DoctorDetailPage({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DoctorVerificationCubit>()..loadDoctors(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(doctor.fullName),
          backgroundColor: Colors.transparent,
        ),
        body: BlocConsumer<DoctorVerificationCubit, DoctorVerificationState>(
          listener: (context, state) {
            if (state is LicenseVerificationResultState) {
              final color = state.result == 'valid' ? Colors.green : Colors.red;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Verificación finalizada: ${state.result.toUpperCase()}'),
                  backgroundColor: color,
                ),
              );
            } else if (state is DoctorVerificationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildInfoSection(),
                  const SizedBox(height: 24),
                  _buildActions(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: CyberTheme.primary.withValues(alpha: 0.1),
            child: const Icon(Icons.person, size: 60, color: CyberTheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            doctor.fullName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            doctor.specialty,
            style: const TextStyle(fontSize: 18, color: CyberTheme.secondary),
          ),
          const SizedBox(height: 8),
          VerificationBadge(isVerified: doctor.verified),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.badge, 'Licencia', doctor.licenseNumber ?? 'N/A'),
            _buildInfoRow(Icons.business, 'Institución', doctor.institution ?? 'N/A'),
            _buildInfoRow(Icons.history, 'Experiencia', '${doctor.yearsOfExperience ?? 0} años'),
            _buildInfoRow(Icons.language, 'Idiomas', doctor.languages.join(', ')),
            _buildInfoRow(Icons.public, 'País', doctor.countryCode),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: CyberTheme.primary),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        if (!doctor.verified)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<DoctorVerificationCubit>().verifyDoctor(doctor);
              },
              icon: const Icon(Icons.security),
              label: const Text('VERIFICAR LICENCIA AHORA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CyberTheme.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => RatingDialog(
                  doctorId: doctor.id,
                  onSubmitted: (rating) {
                    context.read<DoctorVerificationCubit>().submitRating(rating);
                  },
                ),
              );
            },
            icon: const Icon(Icons.star_outline),
            label: const Text('DEJAR UNA RESEÑA'),
            style: OutlinedButton.styleFrom(
              foregroundColor: CyberTheme.secondary,
              side: const BorderSide(color: CyberTheme.secondary),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
