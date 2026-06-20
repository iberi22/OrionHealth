import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../application/bloc/doctor_verification_bloc.dart';
import '../widgets/doctor_card.dart';
import 'doctor_detail_page.dart';

class DoctorListPage extends StatelessWidget {
  const DoctorListPage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget content = Scaffold(
      appBar: AppBar(
        title: const Text(
          'VERIFICACIÓN MÉDICA',
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<DoctorVerificationBloc, DoctorVerificationState>(
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
                  child: DoctorCard(
                    doctor: doctor,
                    rating: rating,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DoctorDetailPage(doctor: doctor),
                        ),
                      ).then((_) {
                        if (context.mounted) {
                          context.read<DoctorVerificationBloc>().add(const LoadDoctors());
                        }
                      });
                    },
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
    );

    try {
      context.read<DoctorVerificationBloc>();
      return content;
    } catch (_) {
      return BlocProvider(
        create: (_) => getIt<DoctorVerificationBloc>()..add(const LoadDoctors()),
        child: content,
      );
    }
  }
}
