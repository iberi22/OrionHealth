// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/home_health_summary.dart';
import '../../domain/entities/home_module.dart';
import '../../domain/repositories/home_repository.dart';
import '../../../vitals/domain/repositories/vital_sign_repository.dart';
import '../../../appointments/domain/repositories/appointment_repository.dart';
import '../../../medications/domain/repositories/medication_repository.dart';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  final VitalSignRepository _vitalSignRepository;
  final AppointmentRepository _appointmentRepository;
  final MedicationRepository _medicationRepository;

  HomeRepositoryImpl(
    this._vitalSignRepository,
    this._appointmentRepository,
    this._medicationRepository,
  );

  @override
  Future<HomeHealthSummary> getHealthSummary() async {
    final latestVitalsMap = await _vitalSignRepository.getLatestVitals();

    final vitalsList = latestVitalsMap.values
        .where((v) => v != null)
        .toList();

    final appointments = await _appointmentRepository.getAllAppointments();
    final upcomingAppointments = appointments
        .where((a) => a.dateTime.isAfter(DateTime.now()))
        .toList();

    final medications = await _medicationRepository.getAllMedications();

    return HomeHealthSummary(
      latestVitals: vitalsList.cast(),
      upcomingAppointments: upcomingAppointments,
      medicationCount: medications.length,
    );
  }

  @override
  Future<List<HomeModule>> getHomeModules() async {
    return const [
      HomeModule(
        title: 'AI Assistant',
        icon: Icons.psychology,
        color: Colors.blue,
        route: '/chat',
      ),
      HomeModule(
        title: 'Salud',
        icon: Icons.favorite,
        color: Colors.red,
        route: '/vitals',
      ),
      HomeModule(
        title: 'Medicamentos',
        icon: Icons.medication,
        color: Colors.orange,
        route: '/medications',
      ),
      HomeModule(
        title: 'Línea de tiempo',
        icon: Icons.timeline,
        color: Colors.teal,
        route: '/timeline',
      ),
    ];
  }
}
