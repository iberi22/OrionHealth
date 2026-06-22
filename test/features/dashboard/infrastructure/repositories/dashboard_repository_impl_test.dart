import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/activity_item.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:orionhealth_health/features/dashboard/data/datasources/dashboard_local_datasource.dart';
import 'package:orionhealth_health/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';
import 'package:orionhealth_health/features/medications/domain/repositories/medication_repository.dart';
import 'package:orionhealth_health/features/reports/domain/repositories/report_repository.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';
import 'package:orionhealth_health/features/reports/domain/entities/report.dart';

class MockDashboardLocalDataSource extends Mock implements DashboardLocalDataSource {}
class MockDashboardRemoteDataSource extends Mock implements DashboardRemoteDataSource {}
class MockVitalSignRepository extends Mock implements VitalSignRepository {}
class MockMedicationRepository extends Mock implements MedicationRepository {}
class MockReportRepository extends Mock implements ReportRepository {}

void main() {
  late DashboardRepositoryImpl repository;
  late MockDashboardLocalDataSource mockLocalDataSource;
  late MockDashboardRemoteDataSource mockRemoteDataSource;
  late MockVitalSignRepository mockVitalSignRepository;
  late MockMedicationRepository mockMedicationRepository;
  late MockReportRepository mockReportRepository;

  setUp(() {
    mockLocalDataSource = MockDashboardLocalDataSource();
    mockRemoteDataSource = MockDashboardRemoteDataSource();
    mockVitalSignRepository = MockVitalSignRepository();
    mockMedicationRepository = MockMedicationRepository();
    mockReportRepository = MockReportRepository();
    repository = DashboardRepositoryImpl(
      mockLocalDataSource,
      mockRemoteDataSource,
      mockVitalSignRepository,
      mockMedicationRepository,
      mockReportRepository,
    );
  });

  group('getDashboardStats', () {
    test('should return aggregated stats from feature repositories', () async {
      // arrange
      final tMedications = [
        Medication(name: 'Med 1', startDate: DateTime(2023, 1, 1))..id = 1,
        Medication(name: 'Med 2', startDate: DateTime(2023, 1, 1))..id = 2,
      ];
      final tReports = [
        Report(title: 'Report 1')..id = 1,
      ];
      final tVitals = {
        VitalSignType.heartRate: VitalSign(
          type: VitalSignType.heartRate,
          value: 70,
          dateTime: DateTime(2023, 1, 1),
        ),
      };

      when(() => mockMedicationRepository.getAllMedications()).thenAnswer((_) async => tMedications);
      when(() => mockReportRepository.getReports()).thenAnswer((_) async => tReports);
      when(() => mockVitalSignRepository.getLatestVitals()).thenAnswer((_) async => tVitals);

      // act
      final result = await repository.getDashboardStats();

      // assert
      expect(result.totalMedications, 2);
      expect(result.reportsCount, 1);
      expect(result.lastVitalCheck, DateTime(2023, 1, 1));
    });
  });

  group('getRecentActivity', () {
    test('should return aggregated activities from all sources sorted by timestamp', () async {
      // arrange
      final now = DateTime.now();
      final tVitals = {
        VitalSignType.heartRate: VitalSign(
          type: VitalSignType.heartRate,
          value: 70,
          dateTime: now.subtract(const Duration(hours: 10)),
        )..id = 1,
      };
      final tMedications = [
        Medication(name: 'Med 1', startDate: now.subtract(const Duration(hours: 5)))..id = 1,
      ];
      final tReports = [
        Report(title: 'Report 1', generatedAt: now.subtract(const Duration(hours: 2)))..id = 1,
      ];

      when(() => mockVitalSignRepository.getLatestVitals()).thenAnswer((_) async => tVitals);
      when(() => mockMedicationRepository.getAllMedications()).thenAnswer((_) async => tMedications);
      when(() => mockReportRepository.getReports()).thenAnswer((_) async => tReports);
      when(() => mockRemoteDataSource.getRemoteRecentActivity()).thenAnswer((_) async => []);

      // act
      final result = await repository.getRecentActivity();

      // assert
      expect(result.length, 3);
      // Sorted by timestamp (most recent first): Report (-2h), Medication (-5h), Vital (-10h)
      expect(result[0].type, ActivityType.reportGenerated);
      expect(result[1].type, ActivityType.medicationTaken);
      expect(result[2].type, ActivityType.vitalCheck);
    });
  });
}
