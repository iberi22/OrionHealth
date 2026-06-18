import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/activity_item.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:orionhealth_health/features/dashboard/data/repositories/dashboard_repository_impl.dart';
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
    final now = DateTime.now();

    group('getDashboardStats', () {
      test('returns correct stats when data is available', () async {
        // arrange
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

      test('returns zero stats and null date when repositories are empty', () async {
        // arrange
        when(() => mockMedicationRepository.getAllMedications()).thenAnswer((_) async => []);
        when(() => mockReportRepository.getReports()).thenAnswer((_) async => []);
        when(() => mockVitalSignRepository.getLatestVitals()).thenAnswer((_) async => {});

        // act
        final result = await repository.getDashboardStats();

        // assert
        expect(result.totalMedications, 0);
        expect(result.reportsCount, 0);
        expect(result.lastVitalCheck, isNull);
      });

      test('lastVitalCheck correctly identifies the latest vital date', () async {
        // arrange
        final older = now.subtract(const Duration(days: 1));
        when(() => mockMedicationRepository.getAllMedications()).thenAnswer((_) async => []);
        when(() => mockReportRepository.getReports()).thenAnswer((_) async => []);
        when(() => mockVitalSignRepository.getLatestVitals())
            .thenAnswer((_) async => {
                  VitalSignType.bloodPressureSystolic: VitalSign(
                    type: VitalSignType.bloodPressureSystolic,
                    value: 120,
                    unit: 'mmHg',
                    dateTime: older,
                  ),
                  VitalSignType.heartRate: VitalSign(
                    type: VitalSignType.heartRate,
                    value: 70,
                    unit: 'bpm',
                    dateTime: now,
                  ),
                });

        // act
        final result = await repository.getDashboardStats();

        // assert
        expect(result.lastVitalCheck, now);
      });
    });

    group('getRecentActivity', () {
      test('returns sorted activities and limits to 5 items', () async {
        // arrange
        final t1 = now;
        final t2 = now.subtract(const Duration(minutes: 10));
        final t3 = now.subtract(const Duration(minutes: 20));
        final t4 = now.subtract(const Duration(minutes: 30));
        final t5 = now.subtract(const Duration(minutes: 40));
        final t6 = now.subtract(const Duration(minutes: 50));

        when(() => mockVitalSignRepository.getLatestVitals())
            .thenAnswer((_) async => {
                  VitalSignType.heartRate: VitalSign(
                    type: VitalSignType.heartRate,
                    value: 70,
                    unit: 'bpm',
                    dateTime: t1,
                  ),
                });
        when(() => mockMedicationRepository.getAllMedications())
            .thenAnswer((_) async => [
                  Medication(id: 1, name: 'Med 1', dosage: '10mg', frequency: 'Daily', startDate: now),
                  Medication(id: 2, name: 'Med 2', dosage: '10mg', frequency: 'Daily', startDate: now),
                ]);
        when(() => mockReportRepository.getReports())
            .thenAnswer((_) async => [
                  Report(title: 'Report 1', content: 'Content', generatedAt: t2),
                  Report(title: 'Report 2', content: 'Content', generatedAt: t3),
                  Report(title: 'Report 3', content: 'Content', generatedAt: t4),
                  Report(title: 'Report 4', content: 'Content', generatedAt: t5),
                  Report(title: 'Report 5', content: 'Content', generatedAt: t6),
                ]);

        // act
        final result = await repository.getRecentActivity();

        // assert
        expect(result.length, 5);
        expect(result[0].timestamp, t1);
        expect(result[1].title, 'Informe: Report 1');
        expect(result[0].timestamp.isAfter(result[1].timestamp), true);
      });

      test('returns empty list when no data is available', () async {
        // arrange
        when(() => mockVitalSignRepository.getLatestVitals()).thenAnswer((_) async => {});
        when(() => mockMedicationRepository.getAllMedications()).thenAnswer((_) async => []);
        when(() => mockReportRepository.getReports()).thenAnswer((_) async => []);

        // act
        final result = await repository.getRecentActivity();

        // assert
        expect(result, isEmpty);
      });

      test('handles reports without generatedAt date', () async {
        // arrange
        when(() => mockVitalSignRepository.getLatestVitals()).thenAnswer((_) async => {});
        when(() => mockMedicationRepository.getAllMedications()).thenAnswer((_) async => []);
        when(() => mockReportRepository.getReports())
            .thenAnswer((_) async => [
                  Report(title: 'Report 1', content: 'Content', generatedAt: null),
                ]);

        // act
        final result = await repository.getRecentActivity();

        // assert
        expect(result.length, 1);
        expect(result[0].type, ActivityType.reportGenerated);
      });
    });
  });
}
