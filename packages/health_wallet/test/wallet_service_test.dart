import 'dart:io';
import 'package:test/test.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:mocktail/mocktail.dart';
import 'package:health_wallet/health_wallet.dart';

class MockEncryptionService extends Mock implements EncryptionService {}

void main() {
  late Isar isar;
  late WalletService walletService;
  late MockEncryptionService mockEncryption;
  late String testDir;

  setUpAll(() async {
    testDir = p.join(Directory.current.path, 'test_db_wallet');
    await Directory(testDir).create(recursive: true);

    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [
        HealthRecordSchema,
        LabResultSchema,
        VitalSignSchema,
        MedicationEntrySchema,
        MedicalDocumentSchema,
        MedicalEventSchema,
        MedicalConceptSchema,
      ],
      directory: testDir,
    );
  });

  tearDownAll(() async {
    await isar.close();
    if (await Directory(testDir).exists()) {
      await Directory(testDir).delete(recursive: true);
    }
  });

  setUp(() async {
    mockEncryption = MockEncryptionService();
    walletService = WalletService(isar, mockEncryption);
    await isar.writeTxn(() async {
      await isar.labResults.clear();
      await isar.vitalSigns.clear();
      await isar.medicationEntrys.clear();
      await isar.medicalEvents.clear();
      await isar.medicalDocuments.clear();
      await isar.healthRecords.clear();
    });
  });

  group('WalletService - LabResults', () {
    test('add and retrieve lab results', () async {
      final lab = LabResult(
        remoteId: 'lab1',
        loincCode: '2339-0',
        testName: 'Glucose',
        resultValue: '100',
        unit: 'mg/dL',
        referenceRangeLow: 70,
        referenceRangeHigh: 99,
        collectedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await walletService.addLabResult(lab);

      final results = await walletService.getLabsByLoinc('2339-0');
      expect(results.length, 1);
      expect(results.first.remoteId, 'lab1');
    });

    test('getRecentLabs filters correctly', () async {
      final now = DateTime.now();
      final oldLab = LabResult(
        remoteId: 'old',
        loincCode: '1',
        testName: 'Old',
        resultValue: '0',
        unit: 'u',
        referenceRangeLow: 0,
        referenceRangeHigh: 10,
        collectedAt: now.subtract(const Duration(days: 40)),
        createdAt: now,
        updatedAt: now,
      );
      final newLab = LabResult(
        remoteId: 'new',
        loincCode: '1',
        testName: 'New',
        resultValue: '0',
        unit: 'u',
        referenceRangeLow: 0,
        referenceRangeHigh: 10,
        collectedAt: now.subtract(const Duration(days: 5)),
        createdAt: now,
        updatedAt: now,
      );

      await walletService.addLabResult(oldLab);
      await walletService.addLabResult(newLab);

      final recent = await walletService.getRecentLabs(days: 30);
      expect(recent.length, 1);
      expect(recent.first.remoteId, 'new');
    });

    test('updateLabSyncStatus', () async {
      final lab = LabResult(
        remoteId: 'lab1',
        loincCode: '1',
        testName: 'T',
        resultValue: '0',
        unit: 'u',
        referenceRangeLow: 0,
        referenceRangeHigh: 1,
        collectedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
      );

      await walletService.addLabResult(lab);
      await walletService.updateLabSyncStatus('lab1', SyncStatus.synced);

      final updated = await walletService.getLabsByLoinc('1');
      expect(updated.first.syncStatus, SyncStatus.synced);
    });

    test('getPendingSyncLabs', () async {
       final lab = LabResult(
        remoteId: 'lab1',
        loincCode: '1',
        testName: 'T',
        resultValue: '0',
        unit: 'u',
        referenceRangeLow: 0,
        referenceRangeHigh: 1,
        collectedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
      );
      await walletService.addLabResult(lab);

      final pending = await walletService.getPendingSyncLabs();
      expect(pending.length, 1);
    });
  });

  group('WalletService - Vitals', () {
    test('add and retrieve vitals', () async {
      final vital = VitalSign(
        remoteId: 'v1',
        loincCode: '8867-4',
        componentName: 'Heart Rate',
        value: '72',
        unit: 'bpm',
        recordedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await walletService.addVitalSign(vital);

      final results = await walletService.getVitalsByLoinc('8867-4');
      expect(results.length, 1);
      expect(results.first.remoteId, 'v1');
    });

    test('getVitalsRange', () async {
      final now = DateTime.now();
      final v1 = VitalSign(
        remoteId: 'v1',
        loincCode: '1',
        componentName: 'N',
        value: '1',
        unit: 'u',
        recordedAt: now.subtract(const Duration(days: 10)),
        createdAt: now,
        updatedAt: now,
      );
      final v2 = VitalSign(
        remoteId: 'v2',
        loincCode: '1',
        componentName: 'N',
        value: '2',
        unit: 'u',
        recordedAt: now.subtract(const Duration(days: 5)),
        createdAt: now,
        updatedAt: now,
      );

      await walletService.addVitalSign(v1);
      await walletService.addVitalSign(v2);

      final range = await walletService.getVitalsRange(
        loincCode: '1',
        from: now.subtract(const Duration(days: 7)),
        to: now,
      );
      expect(range.length, 1);
      expect(range.first.remoteId, 'v2');
    });
  });

  group('WalletService - Medications', () {
    test('add and retrieve medications', () async {
      final med = MedicationEntry(
        remoteId: 'm1',
        medicationName: 'Aspirin',
        dosage: '100',
        dosageUnit: 'mg',
        rxNormCode: '1191',
        frequency: 'Daily',
        route: 'oral',
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await walletService.addMedication(med);

      final results = await walletService.getMedicationsByRxNorm('1191');
      expect(results.length, 1);
      expect(results.first.medicationName, 'Aspirin');
    });

    test('getActiveMedications', () async {
      final med1 = MedicationEntry(
        remoteId: 'm1',
        medicationName: 'Active',
        dosage: '100',
        dosageUnit: 'mg',
        rxNormCode: '1',
        frequency: 'Daily',
        route: 'oral',
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final med2 = MedicationEntry(
        remoteId: 'm2',
        medicationName: 'Inactive',
        dosage: '100',
        dosageUnit: 'mg',
        rxNormCode: '2',
        frequency: 'Daily',
        route: 'oral',
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await walletService.addMedication(med1);
      await walletService.addMedication(med2);

      final active = await walletService.getActiveMedications();
      expect(active.length, 1);
      expect(active.first.medicationName, 'Active');
    });
  });

  group('WalletService - Medical Events', () {
    test('add and retrieve events', () async {
      final event = MedicalEvent(
        remoteId: 'e1',
        eventType: EventType.appointment,
        description: 'Checkup',
        eventDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await walletService.addMedicalEvent(event);

      final results = await walletService.getEventsByType(EventType.appointment);
      expect(results.length, 1);
      expect(results.first.description, 'Checkup');
    });

    test('getTimeline', () async {
      final now = DateTime.now();
      final e1 = MedicalEvent(
        remoteId: 'e1',
        eventType: EventType.procedure,
        description: 'E1',
        eventDate: now.subtract(const Duration(days: 2)),
        createdAt: now,
        updatedAt: now,
      );

      await walletService.addMedicalEvent(e1);

      final timeline = await walletService.getTimeline();
      expect(timeline.length, 1);
    });
  });

  group('WalletService - Documents', () {
    test('add and retrieve documents', () async {
      final doc = MedicalDocument(
        remoteId: 'd1',
        title: 'Report',
        documentType: DocumentType.prescription,
        filePath: '/path/p1.pdf',
        mimeType: 'application/pdf',
        documentDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await walletService.addDocument(doc);

      final results = await walletService.getDocumentsByType(DocumentType.prescription);
      expect(results.length, 1);
      expect(results.first.title, 'Report');
    });
  });

  group('WalletService - HealthRecord', () {
    test('save and retrieve health record', () async {
      final record = HealthRecord(
        remoteId: 'hr1',
        patientId: 'p1',
        firstName: 'John',
        lastName: 'Doe',
        dateOfBirth: '1990-01-01',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await walletService.saveHealthRecord(record);

      final retrieved = await walletService.getHealthRecord();
      expect(retrieved, isNotNull);
      expect(retrieved!.firstName, 'John');
    });
  });

  group('WalletService - Auxiliary', () {
    test('getDataStatistics', () async {
      await walletService.addLabResult(LabResult(
        remoteId: 'l1', loincCode: '1', testName: 'T', resultValue: '0', unit: 'u',
        referenceRangeLow: 0, referenceRangeHigh: 1, collectedAt: DateTime.now(),
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ));

      final stats = await walletService.getDataStatistics();
      expect(stats['labs'], 1);
      expect(stats['vitals'], 0);
    });

    test('exportAllData', () async {
      await walletService.addLabResult(LabResult(
        remoteId: 'l1', loincCode: '1', testName: 'T', resultValue: '0', unit: 'u',
        referenceRangeLow: 0, referenceRangeHigh: 1, collectedAt: DateTime.now(),
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ));

      final export = await walletService.exportAllData();
      expect(export['labs'], isA<List>());
      expect((export['labs'] as List).length, 1);
      expect(export['version'], '1.1');
    });

    test('exportToFhir returns a valid-looking bundle', () async {
      await walletService.saveHealthRecord(HealthRecord(
        remoteId: 'hr1', patientId: 'p1', firstName: 'J', lastName: 'D', dateOfBirth: '1990-01-01',
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ));

      final fhir = await walletService.exportToFhir();
      expect(fhir, contains('"resourceType": "Bundle"'));
      expect(fhir, contains('"resourceType": "Patient"'));
    });

    test('cleanup methods', () async {
      final now = DateTime.now();
      await walletService.addLabResult(LabResult(
        remoteId: 'old', loincCode: '1', testName: 'T', resultValue: '0', unit: 'u',
        referenceRangeLow: 0, referenceRangeHigh: 1,
        collectedAt: now.subtract(const Duration(days: 10)),
        createdAt: now, updatedAt: now,
      ));

      final deleted = await walletService.deleteLabsOlderThan(5);
      expect(deleted, 1);

      final labs = await walletService.getLabsByLoinc('1');
      expect(labs.isEmpty, true);
    });
  });
}
