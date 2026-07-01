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
import '../datasources/home_local_datasource.dart';
import '../datasources/home_remote_datasource.dart';
import '../models/home_module_model.dart';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  final VitalSignRepository _vitalSignRepository;
  final AppointmentRepository _appointmentRepository;
  final MedicationRepository _medicationRepository;
  final HomeLocalDataSource _localDataSource;
  final HomeRemoteDataSource _remoteDataSource;

  HomeRepositoryImpl(
    this._vitalSignRepository,
    this._appointmentRepository,
    this._medicationRepository,
    this._localDataSource,
    this._remoteDataSource,
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
    // 1. Try local cache
    final cachedModules = await _localDataSource.getCachedHomeModules();
    if (cachedModules != null && cachedModules.isNotEmpty) {
      return cachedModules;
    }

    // 2. Try remote
    try {
      final remoteModules = await _remoteDataSource.getHomeModules();
      if (remoteModules.isNotEmpty) {
        await _localDataSource.cacheHomeModules(remoteModules);
        return remoteModules;
      }
    } catch (_) {
      // Fallback to defaults
    }

    // 3. Fallback to default modules
    final defaultModules = [
      HomeModuleModel(
        title: 'AI Assistant',
        iconCode: Icons.psychology.codePoint,
        iconFontFamily: Icons.psychology.fontFamily,
        iconFontPackage: Icons.psychology.fontPackage,
        color: Colors.blue,
        route: '/chat',
      ),
      HomeModuleModel(
        title: 'Salud',
        iconCode: Icons.favorite.codePoint,
        iconFontFamily: Icons.favorite.fontFamily,
        iconFontPackage: Icons.favorite.fontPackage,
        color: Colors.red,
        route: '/vitals',
      ),
      HomeModuleModel(
        title: 'Medicamentos',
        iconCode: Icons.medication.codePoint,
        iconFontFamily: Icons.medication.fontFamily,
        iconFontPackage: Icons.medication.fontPackage,
        color: Colors.orange,
        route: '/medications',
      ),
      HomeModuleModel(
        title: 'Línea de tiempo',
        iconCode: Icons.timeline.codePoint,
        iconFontFamily: Icons.timeline.fontFamily,
        iconFontPackage: Icons.timeline.fontPackage,
        color: Colors.teal,
        route: '/timeline',
      ),
    ];

    await _localDataSource.cacheHomeModules(defaultModules);
    return defaultModules;
  }
}
