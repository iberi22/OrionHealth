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
import '../datasources/health_summary_datasource.dart';
import '../models/home_module_model.dart';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  final VitalSignRepository _vitalSignRepository;
  final AppointmentRepository _appointmentRepository;
  final MedicationRepository _medicationRepository;
  final HomeLocalDataSource _localDataSource;
  final HomeRemoteDataSource _remoteDataSource;
  final HealthSummaryDatasource _healthSummaryDatasource;

  HomeRepositoryImpl(
    this._vitalSignRepository,
    this._appointmentRepository,
    this._medicationRepository,
    this._localDataSource,
    this._remoteDataSource,
    this._healthSummaryDatasource,
  );

  @override
  Future<HomeHealthSummary> getHealthSummary() async {
    final latestVitalsMap = await _vitalSignRepository.getLatestVitals();

    final vitalsList = latestVitalsMap.values
        .where((v) => v != null)
        .toList();

    final appointments = await _appointmentRepository.getAppointments();
    final upcomingAppointments = appointments
        .where((a) => a.dateTime.isAfter(DateTime.now()))
        .toList();

    final medications = await _medicationRepository.getAllMedications();

    // Fetch textual summary from infrastructure datasource
    String summaryText = '';
    try {
      summaryText = await _healthSummaryDatasource.getHealthSummary();
      await _localDataSource.cacheHealthSummary(summaryText);
    } catch (_) {
      summaryText = await _localDataSource.getHealthSummary();
    }

    return HomeHealthSummary(
      latestVitals: vitalsList.cast(),
      upcomingAppointments: upcomingAppointments,
      medicationCount: medications.length,
      summaryText: summaryText,
    );
  }

  @override
  Future<List<HomeModule>> getHomeModules() async {
    // 1. Try local cache
    final cachedModules = await _localDataSource.getHomeModules();
    if (cachedModules.isNotEmpty) {
      return cachedModules;
    }

    // 2. Try remote
    try {
      final remoteModules = await _remoteDataSource.getHomeModules();
      if (remoteModules.isNotEmpty) {
        await _localDataSource.cacheHomeModules(
          remoteModules.map((m) => HomeModuleModel.fromEntity(m)).toList(),
        );
        return remoteModules;
      }
    } catch (_) {
      // Fallback to defaults
    }

    // 3. Fallback to default modules
    final defaultModules = [
      const HomeModuleModel(
        title: 'AI Assistant',
        iconCode: 0xe4f7, // Icons.psychology.codePoint
        iconFontFamily: 'MaterialIcons',
        color: Colors.blue,
        route: '/chat',
      ),
      const HomeModuleModel(
        title: 'Salud',
        iconCode: 0xe25b, // Icons.favorite.codePoint
        iconFontFamily: 'MaterialIcons',
        color: Colors.red,
        route: '/vitals',
      ),
      const HomeModuleModel(
        title: 'Medicamentos',
        iconCode: 0xe3d9, // Icons.medication.codePoint
        iconFontFamily: 'MaterialIcons',
        color: Colors.orange,
        route: '/medications',
      ),
      const HomeModuleModel(
        title: 'Línea de tiempo',
        iconCode: 0xe651, // Icons.timeline.codePoint
        iconFontFamily: 'MaterialIcons',
        color: Colors.teal,
        route: '/timeline',
      ),
      const HomeModuleModel(
        title: 'Meditación',
        iconCode: 0xe5d0, // Icons.spa.codePoint
        iconFontFamily: 'MaterialIcons',
        color: Colors.purple,
        route: '/meditation',
      ),
      const HomeModuleModel(
        title: 'Informes',
        iconCode: 0xe097, // Icons.assessment.codePoint
        iconFontFamily: 'MaterialIcons',
        color: Colors.green,
        route: '/reports',
      ),
    ];

    await _localDataSource.cacheHomeModules(defaultModules);
    return defaultModules;
  }
}
