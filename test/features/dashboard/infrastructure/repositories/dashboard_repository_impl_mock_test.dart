import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/dashboard/infrastructure/datasources/dashboard_remote_datasource.dart';
import 'package:orionhealth_health/features/dashboard/infrastructure/repositories/dashboard_repository_impl.dart';
import 'package:orionhealth_health/features/medications/domain/repositories/medication_repository.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';
import 'package:orionhealth_health/features/reports/domain/repositories/report_repository.dart';

class MockDashboardRemoteDataSource extends Mock implements DashboardRemoteDataSource {}
class MockMedicationRepository extends Mock implements MedicationRepository {}
class MockVitalSignRepository extends Mock implements VitalSignRepository {}
class MockReportRepository extends Mock implements ReportRepository {}

void main() {
  late DashboardRepositoryImpl repository;
  late MockDashboardRemoteDataSource mockRemoteDataSource;
  late MockVitalSignRepository mockVitRepo;
  late MockMedicationRepository mockMedRepo;
  late MockReportRepository mockReportRepo;

  setUp(() {
    mockRemoteDataSource = MockDashboardRemoteDataSource();
    mockVitRepo = MockVitalSignRepository();
    mockMedRepo = MockMedicationRepository();
    mockReportRepo = MockReportRepository();
    repository = DashboardRepositoryImpl(
      mockRemoteDataSource,
      mockVitRepo,
      mockMedRepo,
      mockReportRepo,
    );
  });

  test('repository can be instantiated', () {
    expect(repository, isNotNull);
  });
}
