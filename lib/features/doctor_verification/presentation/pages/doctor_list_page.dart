import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../application/doctor_verification_cubit.dart';
import '../../application/doctor_verification_state.dart';
import 'doctor_detail_page.dart';

class DoctorListPage extends StatelessWidget {
  const DoctorListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DoctorVerificationCubit>()..loadDoctors(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'VERIFICACIÓN MÉDICA',
            style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocBuilder<DoctorVerificationCubit, DoctorVerificationState>(
          builder: (context, state) {
            if (state is DoctorVerificationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DoctorVerificationLoaded) {
              if (state.doctors.isEmpty) {
                return const Center(
                  child: Text(
                    'No se encontraron médicos.',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.doctors.length,
                itemBuilder: (context, index) {
                  final doctor = state.doctors[index];
                  final rating = state.averageRatings[doctor.id] ?? 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GlassmorphicCard(
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
                            Row(
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
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DoctorDetailPage(doctor: doctor),
                            ),
                          ).then((_) {
                            context.read<DoctorVerificationCubit>().loadDoctors();
                          });
                        },
                      ),
                    ),
                  );
                },
              );
            } else if (state is DoctorVerificationError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.redAccent)));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
