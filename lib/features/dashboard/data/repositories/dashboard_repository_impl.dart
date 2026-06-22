import 'package:injectable/injectable.dart';
import '../../domain/entities/activity_item.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_datasource.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../../../vitals/domain/repositories/vital_sign_repository.dart';
import '../../../medications/domain/repositories/medication_repository.dart';
import '../../../reports/domain/repositories/report_repository.dart';

/// Data-layer implementation of [DashboardRepository].
///
/// Aggregates data from multiple feature repos and data sources to compute
/// dashboard stats and recent activity items.
@LazySingleton(as: DashboardRepository)
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardLocalDataSource _localDataSource;
  final DashboardRemoteDataSource _remoteDataSource;
  final VitalSignRepository _vitalSignRepository;
  final MedicationRepository _medicationRepository;
  final ReportRepository _reportRepository;

  DashboardRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._vitalSignRepository,
    this._medicationRepository,
    this._reportRepository,
  );

  @override
  Future<DashboardStats> getDashboardStats() async {
    // We could combine local/remote data with aggregated data
    // For now, prioritising aggregated data from local feature repositories
    final medications = await _medicationRepository.getAllMedications();
    final reports = await _reportRepository.getReports();
    final latestVitals = await _vitalSignRepository.getLatestVitals();

    DateTime? lastVitalDate;
    latestVitals.forEach((_, vital) {
      if (vital != null) {
        if (lastVitalDate == null || vital.dateTime.isAfter(lastVitalDate!)) {
          lastVitalDate = vital.dateTime;
        }
      }
    });

    return DashboardStats(
      totalMedications: medications.length,
      reportsCount: reports.length,
      lastVitalCheck: lastVitalDate,
    );
  }

  @override
  Future<List<ActivityItem>> getRecentActivity() async {
    final activities = <ActivityItem>[];

    final latestVitals = await _vitalSignRepository.getLatestVitals();
    latestVitals.forEach((type, vital) {
      if (vital != null) {
        activities.add(ActivityItem(
          id: 'vital_${vital.id}',
          title: 'Chequeo de ${type.toString().split('.').last}',
          timestamp: vital.dateTime,
          type: ActivityType.vitalCheck,
        ));
      }
    });

    final medications = await _medicationRepository.getAllMedications();
    for (var med in medications) {
      // Assuming for now the most recent medication added is "activity"
      // In a real app we'd have a 'MedicationHistory' or similar.
      activities.add(ActivityItem(
        id: 'med_${med.id}',
        title: 'Medicamento: ${med.name}',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        type: ActivityType.medicationTaken,
      ));
    }

    final reports = await _reportRepository.getReports();
    for (var report in reports) {
      activities.add(ActivityItem(
        id: 'report_${report.id}',
        title: 'Informe: ${report.title ?? "Sin título"}',
        timestamp: report.generatedAt ?? DateTime.now(),
        type: ActivityType.reportGenerated,
      ));
    }

    // Also could fetch remote activities
    try {
      final remoteActivities = await _remoteDataSource.getRemoteRecentActivity();
      activities.addAll(remoteActivities.map((e) => e.toEntity()));
    } catch (_) {
      // Ignore remote errors to maintain offline-first functionality
    }

    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return activities.take(10).toList();
  }
}
