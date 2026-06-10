import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/activity_item.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:orionhealth_health/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:orionhealth_health/features/dashboard/infrastructure/repositories/dashboard_repository_impl.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';
import 'package:orionhealth_health/features/medications/domain/repositories/medication_repository.dart';
import 'package:orionhealth_health/features/reports/domain/repositories/report_repository.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';
import 'package:orionhealth_health/features/reports/domain/entities/report.dart';

class MockVitalSignRepository extends Mock implements VitalSignRepository {}
class MockMedicationRepository extends Mock implements MedicationRepository {}
class MockReportRepository extends Mock implements ReportRepository {}

void main() {
  late DashboardRepositoryImpl repository;
  late MockVitalSignRepository mockVitalSignRepository;
  late MockMedicationRepository mockMedicationRepository;
  late MockReportRepository mockReportRepository;

  setUp(() {
    mockVitalSignRepository = MockVitalSignRepository();
    mockMedicationRepository = MockMedicationRepository();
    mockReportRepository = MockReportRepository();
    repository = DashboardRepositoryImpl(
      mockVitalSignRepository,
      mockMedicationRepository,
      mockReportRepository,
    );
  });

  group('DashboardRepositoryImpl', () {
    test('getDashboardStats returns correct stats', () async {
      // arrange
      final now = DateTime.now();
      when(() => mockMedicationRepository.getAllMedications())
          .thenAnswer((_) async => [
                Medication(name: 'Med 1', dosage: '10mg', frequency: 'Daily', startDate: now),
              ]);
      when(() => mockReportRepository.getReports())
          .thenAnswer((_) async => [
                Report(title: 'Report 1', content: 'Content', generatedAt: now),
                Report(title: 'Report 2', content: 'Content', generatedAt: now),
              ]);
      when(() => mockVitalSignRepository.getLatestVitals())
          .thenAnswer((_) async => {
                VitalSignType.bloodPressureSystolic: VitalSign(
                  type: VitalSignType.bloodPressureSystolic,
                  value: 120,
                  unit: 'mmHg',
                  dateTime: now,
                ),
              });

      // act
      final result = await repository.getDashboardStats();

      // assert
      expect(result.totalMedications, 1);
      expect(result.reportsCount, 2);
      expect(result.lastVitalCheck, now);
    });

    test('getRecentActivity returns sorted activities', () async {
      // arrange
      final now = DateTime.now();
      final earlier = now.subtract(const Duration(hours: 1));

      when(() => mockVitalSignRepository.getLatestVitals())
          .thenAnswer((_) async => {
                VitalSignType.heartRate: VitalSign(
                  type: VitalSignType.heartRate,
                  value: 70,
                  unit: 'bpm',
                  dateTime: now,
                ),
              });
      when(() => mockMedicationRepository.getAllMedications())
          .thenAnswer((_) async => []);
      when(() => mockReportRepository.getReports())
          .thenAnswer((_) async => [
                Report(title: 'Older Report', content: 'Content', generatedAt: earlier),
              ]);

      // act
      final result = await repository.getRecentActivity();

      // assert
      expect(result.length, 2);
      expect(result[0].type, ActivityType.vitalCheck);
      expect(result[1].type, ActivityType.reportGenerated);
      expect(result[0].timestamp.isAfter(result[1].timestamp), true);
    });
  });
}
