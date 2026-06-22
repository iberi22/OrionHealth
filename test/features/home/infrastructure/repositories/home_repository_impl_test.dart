import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/home/infrastructure/repositories/home_repository_impl.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';
import 'package:orionhealth_health/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:orionhealth_health/features/medications/domain/repositories/medication_repository.dart';
import 'package:orionhealth_health/features/home/infrastructure/datasources/home_local_datasource.dart';
import 'package:orionhealth_health/features/home/infrastructure/datasources/home_remote_datasource.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';

class MockVitalSignRepository extends Mock implements VitalSignRepository {}
class MockAppointmentRepository extends Mock implements AppointmentRepository {}
class MockMedicationRepository extends Mock implements MedicationRepository {}
class MockHomeLocalDataSource extends Mock implements HomeLocalDataSource {}
class MockHomeRemoteDataSource extends Mock implements HomeRemoteDataSource {}

void main() {
  late HomeRepositoryImpl repository;
  late MockVitalSignRepository mockVitals;
  late MockAppointmentRepository mockAppointments;
  late MockMedicationRepository mockMeds;
  late MockHomeLocalDataSource mockLocal;
  late MockHomeRemoteDataSource mockRemote;

  setUp(() {
    mockVitals = MockVitalSignRepository();
    mockAppointments = MockAppointmentRepository();
    mockMeds = MockMedicationRepository();
    mockLocal = MockHomeLocalDataSource();
    mockRemote = MockHomeRemoteDataSource();

    repository = HomeRepositoryImpl(
      mockVitals,
      mockAppointments,
      mockMeds,
      mockLocal,
      mockRemote,
    );
  });

  group('HomeRepositoryImpl', () {
    test('getHealthSummary returns summarized data', () async {
      when(() => mockVitals.getLatestVitals()).thenAnswer((_) async => {
        VitalSignType.heartRate: VitalSign(type: VitalSignType.heartRate, value: 70, dateTime: DateTime.now())
      });
      when(() => mockAppointments.getAllAppointments()).thenAnswer((_) async => [
        Appointment(
          doctorName: 'Dr. Smith',
          specialty: 'Med',
          dateTime: DateTime.now().add(const Duration(days: 1)),
          status: AppointmentStatus.upcoming,
        )
      ]);
      when(() => mockMeds.getAllMedications()).thenAnswer((_) async => []);

      final result = await repository.getHealthSummary();

      expect(result.latestVitals, isNotEmpty);
      expect(result.upcomingAppointments, hasLength(1));
    });

    test('getHomeModules returns cached modules if available', () async {
      when(() => mockLocal.getCachedHomeModules()).thenAnswer((_) async => []);
      when(() => mockRemote.getHomeModules()).thenAnswer((_) async => []);

      final result = await repository.getHomeModules();
      expect(result, isNotEmpty); // Returns defaults if cache empty
    });
  });
}
