import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/dashboard/data/repositories/dashboard_repository_impl.dart';
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
  late MockDashboardLocalDataSource mockLocal;
  late MockDashboardRemoteDataSource mockRemote;
  late MockVitalSignRepository mockVitals;
  late MockMedicationRepository mockMeds;
  late MockReportRepository mockReports;

  setUp(() {
    mockLocal = MockDashboardLocalDataSource();
    mockRemote = MockDashboardRemoteDataSource();
    mockVitals = MockVitalSignRepository();
    mockMeds = MockMedicationRepository();
    mockReports = MockReportRepository();

    repository = DashboardRepositoryImpl(
      mockLocal,
      mockRemote,
      mockVitals,
      mockMeds,
      mockReports,
    );
  });

  group('DashboardRepositoryImpl', () {
    test('getDashboardStats aggregates data from repositories', () async {
      when(() => mockMeds.getAllMedications()).thenAnswer((_) async => [
        Medication(
          name: 'Med 1',
          dosage: '1mg',
          startDate: DateTime(2024, 1, 1),
        ),
        Medication(
          name: 'Med 2',
          dosage: '2mg',
          startDate: DateTime(2024, 1, 1),
        ),
      ]);
      when(() => mockReports.getReports()).thenAnswer((_) async => [
        Report(title: 'Report 1'),
      ]);
      when(() => mockVitals.getLatestVitals()).thenAnswer((_) async => {
        VitalSignType.heartRate: VitalSign(
          type: VitalSignType.heartRate,
          value: 70,
          dateTime: DateTime(2024, 1, 1),
        ),
      });

      final stats = await repository.getDashboardStats();

      expect(stats.totalMedications, 2);
      expect(stats.reportsCount, 1);
      expect(stats.lastVitalCheck, DateTime(2024, 1, 1));
    });

    test('getRecentActivity returns combined activity list', () async {
       when(() => mockVitals.getLatestVitals()).thenAnswer((_) async => {});
       when(() => mockMeds.getAllMedications()).thenAnswer((_) async => []);
       when(() => mockReports.getReports()).thenAnswer((_) async => []);
       when(() => mockRemote.getRemoteRecentActivity()).thenAnswer((_) async => []);

       final activities = await repository.getRecentActivity();
       expect(activities, isA<List>());
    });
  });
}
