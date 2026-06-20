import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/services/patient_context_indexer.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/vector_store_service.dart';
import 'package:orionhealth_health/features/health_record/domain/repositories/health_record_repository.dart';
import 'package:orionhealth_health/features/medications/domain/repositories/medication_repository.dart';
import 'package:orionhealth_health/features/allergies/domain/repositories/allergy_repository.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';
import 'package:orionhealth_health/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';
import 'package:orionhealth_health/features/health_record/domain/entities/medical_record.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';

class MockVectorStore extends Mock implements VectorStoreService {}
class MockHealthRecordRepo extends Mock implements HealthRecordRepository {}
class MockMedicationRepo extends Mock implements MedicationRepository {}
class MockAllergyRepo extends Mock implements AllergyRepository {}
class MockVitalRepo extends Mock implements VitalSignRepository {}
class MockAppointmentRepo extends Mock implements AppointmentRepository {}

// Abstract classes to help Mocktail with IsarCollection generics
abstract class IsarCollectionMedicalRecord extends IsarCollection<MedicalRecord> {}
abstract class IsarCollectionMedication extends IsarCollection<Medication> {}
abstract class IsarCollectionAllergy extends IsarCollection<Allergy> {}
abstract class IsarCollectionVitalSign extends IsarCollection<VitalSign> {}
abstract class IsarCollectionAppointment extends IsarCollection<Appointment> {}

class MockMedicalRecordCollection extends Mock implements IsarCollectionMedicalRecord {}
class MockMedicationCollection extends Mock implements IsarCollectionMedication {}
class MockAllergyCollection extends Mock implements IsarCollectionAllergy {}
class MockVitalSignCollection extends Mock implements IsarCollectionVitalSign {}
class MockAppointmentCollection extends Mock implements IsarCollectionAppointment {}

class MockIsar extends Mock implements Isar {
  @override
  Future<T> writeTxn<T>(Future<T> Function() callback, {bool silent = false}) {
    return callback();
  }
}

void main() {
  late PatientContextIndexer indexer;
  late MockIsar mockIsar;
  late MockVectorStore mockVectorStore;
  late MockHealthRecordRepo mockHealthRecordRepo;
  late MockMedicationRepo mockMedicationRepo;
  late MockAllergyRepo mockAllergyRepo;
  late MockVitalRepo mockVitalRepo;
  late MockAppointmentRepo mockAppointmentRepo;

  late MockMedicalRecordCollection mockMedicalRecordCollection;
  late MockMedicationCollection mockMedicationCollection;
  late MockAllergyCollection mockAllergyCollection;
  late MockVitalSignCollection mockVitalSignCollection;
  late MockAppointmentCollection mockAppointmentCollection;

  setUp(() {
    mockIsar = MockIsar();
    mockVectorStore = MockVectorStore();
    mockHealthRecordRepo = MockHealthRecordRepo();
    mockMedicationRepo = MockMedicationRepo();
    mockAllergyRepo = MockAllergyRepo();
    mockVitalRepo = MockVitalRepo();
    mockAppointmentRepo = MockAppointmentRepo();

    mockMedicalRecordCollection = MockMedicalRecordCollection();
    mockMedicationCollection = MockMedicationCollection();
    mockAllergyCollection = MockAllergyCollection();
    mockVitalSignCollection = MockVitalSignCollection();
    mockAppointmentCollection = MockAppointmentCollection();

    when(() => mockIsar.collection<MedicalRecord>()).thenReturn(mockMedicalRecordCollection);
    when(() => mockIsar.collection<Medication>()).thenReturn(mockMedicationCollection);
    when(() => mockIsar.collection<Allergy>()).thenReturn(mockAllergyCollection);
    when(() => mockIsar.collection<VitalSign>()).thenReturn(mockVitalSignCollection);
    when(() => mockIsar.collection<Appointment>()).thenReturn(mockAppointmentCollection);

    when(() => mockMedicalRecordCollection.watchLazy()).thenAnswer((_) => const Stream.empty());
    when(() => mockMedicationCollection.watchLazy()).thenAnswer((_) => const Stream.empty());
    when(() => mockAllergyCollection.watchLazy()).thenAnswer((_) => const Stream.empty());
    when(() => mockVitalSignCollection.watchLazy()).thenAnswer((_) => const Stream.empty());
    when(() => mockAppointmentCollection.watchLazy()).thenAnswer((_) => const Stream.empty());

    indexer = PatientContextIndexer(
      mockIsar,
      mockVectorStore,
      mockHealthRecordRepo,
      mockMedicationRepo,
      mockAllergyRepo,
      mockVitalRepo,
      mockAppointmentRepo,
    );
  });

  group('indexAll', () {
    test('calls repositories and adds documents to vector store', () async {
      // Setup mock data
      final records = [
        MedicalRecord(type: RecordType.prescription, summary: 'Test Summary'),
      ];
      final medications = [
        Medication(name: 'Test Med', startDate: DateTime.now(), isActive: true),
      ];
      final allergies = [
        Allergy(allergen: 'Pollen', severity: AllergySeverity.mild),
      ];
      final vitals = [
        VitalSign(type: VitalSignType.heartRate, value: 70, dateTime: DateTime.now()),
      ];
      final appointments = [
        Appointment(doctorName: 'Dr. Test', specialty: 'General', dateTime: DateTime.now(), status: AppointmentStatus.upcoming),
      ];

      when(() => mockHealthRecordRepo.getAllRecords()).thenAnswer((_) async => records);
      when(() => mockMedicationRepo.getAllMedications()).thenAnswer((_) async => medications);
      when(() => mockAllergyRepo.getAllergies()).thenAnswer((_) async => allergies);
      when(() => mockVitalRepo.getAllVitalSigns()).thenAnswer((_) async => vitals);
      when(() => mockAppointmentRepo.getAllAppointments()).thenAnswer((_) async => appointments);

      when(() => mockVectorStore.addDocument(any(), any(), any())).thenAnswer((_) async => {});

      // Execute
      await indexer.indexAll();

      // Verify
      verify(() => mockHealthRecordRepo.getAllRecords()).called(1);
      verify(() => mockMedicationRepo.getAllMedications()).called(1);
      verify(() => mockAllergyRepo.getAllergies()).called(1);
      verify(() => mockVitalRepo.getAllVitalSigns()).called(1);
      verify(() => mockAppointmentRepo.getAllAppointments()).called(1);

      // Verify vector store calls (one for each type)
      verify(() => mockVectorStore.addDocument(
        any(that: contains('medical_record')),
        any(that: contains('Registro Médico')),
        any(),
      )).called(1);
      verify(() => mockVectorStore.addDocument(
        any(that: contains('medication')),
        any(that: contains('Medicamento')),
        any(),
      )).called(1);
      verify(() => mockVectorStore.addDocument(
        any(that: contains('allergy')),
        any(that: contains('Alergia')),
        any(),
      )).called(1);
      verify(() => mockVectorStore.addDocument(
        any(that: contains('vital_sign')),
        any(that: contains('Signo Vital')),
        any(),
      )).called(1);
      verify(() => mockVectorStore.addDocument(
        any(that: contains('appointment')),
        any(that: contains('Cita')),
        any(),
      )).called(1);

      // Verify watchers are set up
      verify(() => mockMedicalRecordCollection.watchLazy()).called(1);
      verify(() => mockMedicationCollection.watchLazy()).called(1);
      verify(() => mockAllergyCollection.watchLazy()).called(1);
      verify(() => mockVitalSignCollection.watchLazy()).called(1);
      verify(() => mockAppointmentCollection.watchLazy()).called(1);
    });
  });
}
