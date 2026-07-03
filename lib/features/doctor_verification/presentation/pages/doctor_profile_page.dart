import 'package:flutter/material.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../domain/entities/doctor_profile.dart';
import 'doctor_verification_card.dart';

class DoctorProfilePage extends StatelessWidget {
  final DoctorProfile doctor;

  const DoctorProfilePage({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PERFIL MÉDICO'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: CyberTheme.primary,
              child: Icon(Icons.person, size: 80, color: Colors.black),
            ),
            const SizedBox(height: 24),
            Text(
              doctor.fullName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              doctor.specialty,
              style: const TextStyle(fontSize: 18, color: CyberTheme.secondary),
            ),
            const SizedBox(height: 32),
            DoctorVerificationCard(doctor: doctor),
          ],
        ),
      ),
    );
  }
}
