import 'package:injectable/injectable.dart';
import '../../domain/entities/activity_item.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../../vitals/domain/repositories/vital_sign_repository.dart';
import '../../../medications/domain/repositories/medication_repository.dart';
import '../../../reports/domain/repositories/report_repository.dart';

@LazySingleton(as: DashboardRepository)
class DashboardRepositoryImpl implements DashboardRepository {
  final VitalSignRepository _vitalSignRepository;
  final MedicationRepository _medicationRepository;
  final ReportRepository _reportRepository;

  DashboardRepositoryImpl(
    this._vitalSignRepository,
    this._medicationRepository,
    this._reportRepository,
  );

  @override
  Future<DashboardStats> getDashboardStats() async {
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
          id: 'vital_${vital.dateTime.millisecondsSinceEpoch}',
          title: 'Chequeo de ${type.toString().split('.').last}',
          timestamp: vital.dateTime,
          type: ActivityType.vitalCheck,
        ));
      }
    });

    final medications = await _medicationRepository.getAllMedications();
    for (var med in medications) {
      activities.add(ActivityItem(
        id: 'med_${med.id}',
        title: 'Medicamento: ${med.name}',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)), // Placeholder for real "taken" history
        type: ActivityType.medicationTaken,
      ));
    }

    final reports = await _reportRepository.getReports();
    for (var report in reports) {
      activities.add(ActivityItem(
        id: 'report_${report.id}',
        title: 'Informe: ${report.title}',
        timestamp: report.generatedAt ?? DateTime.now(),
        type: ActivityType.reportGenerated,
      ));
    }

    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return activities.take(5).toList();
  }
}
