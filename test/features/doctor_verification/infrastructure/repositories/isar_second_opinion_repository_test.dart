import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/second_opinion.dart';
import 'package:orionhealth_health/features/doctor_verification/infrastructure/repositories/isar_second_opinion_repository.dart';
import 'package:path/path.dart' as p;

void main() {
  late Isar isar;
  late IsarSecondOpinionRepository repository;
  late String testDir;

  setUpAll(() async {
    testDir = p.join(Directory.current.path, 'test_db_isar_second_opinion');
    await Directory(testDir).create(recursive: true);

    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [SecondOpinionRequestSchema, SecondOpinionResponseSchema],
      directory: testDir,
    );
    repository = IsarSecondOpinionRepository(isar);
  });

  tearDownAll(() async {
    await isar.close();
    if (await Directory(testDir).exists()) {
      await Directory(testDir).delete(recursive: true);
    }
  });

  setUp(() async {
    await isar.writeTxn(() async {
      await isar.secondOpinionRequests.clear();
      await isar.secondOpinionResponses.clear();
    });
  });

  group('IsarSecondOpinionRepository', () {
    final tDate = DateTime(2023, 6, 15);

    test('saveRequest and getRequest', () async {
      final request = SecondOpinionRequest(
        id: 'req1',
        patientId: 'p1',
        primaryDoctorId: 'doc1',
        symptoms: 'Chest pain and shortness of breath',
        documents: ['doc1.pdf', 'ecg.png'],
        createdAt: tDate,
      );

      await repository.saveRequest(request);

      final result = await repository.getRequest('req1');
      expect(result, isNotNull);
      expect(result!.id, 'req1');
      expect(result.patientId, 'p1');
      expect(result.primaryDoctorId, 'doc1');
      expect(result.symptoms, 'Chest pain and shortness of breath');
      expect(result.documents, ['doc1.pdf', 'ecg.png']);
    });

    test('getRequest returns null for unknown id', () async {
      final result = await repository.getRequest('nonexistent');
      expect(result, isNull);
    });

    test('saveResponse and getResponsesForRequest', () async {
      final request = SecondOpinionRequest(
        id: 'req2',
        patientId: 'p1',
        symptoms: 'Headache',
        createdAt: tDate,
      );

      await repository.saveRequest(request);

      final response = SecondOpinionResponse(
        id: 'res1',
        requestId: 'req2',
        reviewerDoctorId: 'doc2',
        recommendation: 'MRI recommended',
        confidence: 0.85,
        respondedAt: tDate,
      );

      await repository.saveResponse(response);

      final results = await repository.getResponsesForRequest('req2');
      expect(results.length, 1);
      expect(results.first.id, 'res1');
      expect(results.first.recommendation, 'MRI recommended');
      expect(results.first.confidence, 0.85);
    });

    test('getResponsesForRequest returns empty for unknown request', () async {
      final results = await repository.getResponsesForRequest('nonexistent');
      expect(results, isEmpty);
    });

    test('getRequestsForPatient returns patient requests', () async {
      final req1 = SecondOpinionRequest(
        id: 'req1',
        patientId: 'p1',
        symptoms: 'Fever',
        createdAt: tDate,
      );
      final req2 = SecondOpinionRequest(
        id: 'req2',
        patientId: 'p1',
        symptoms: 'Cough',
        createdAt: tDate,
      );
      final req3 = SecondOpinionRequest(
        id: 'req3',
        patientId: 'p2',
        symptoms: 'Fatigue',
        createdAt: tDate,
      );

      await repository.saveRequest(req1);
      await repository.saveRequest(req2);
      await repository.saveRequest(req3);

      final results = await repository.getRequestsForPatient('p1');
      expect(results.length, 2);
      expect(results.any((r) => r.id == 'req1'), isTrue);
      expect(results.any((r) => r.id == 'req2'), isTrue);
    });

    test('getRequestsForPatient returns empty for unknown patient', () async {
      final results = await repository.getRequestsForPatient('nonexistent');
      expect(results, isEmpty);
    });

    test('multiple responses for same request', () async {
      final request = SecondOpinionRequest(
        id: 'req3',
        patientId: 'p1',
        symptoms: 'Abdominal pain',
        createdAt: tDate,
      );
      await repository.saveRequest(request);

      final res1 = SecondOpinionResponse(
        id: 'res1',
        requestId: 'req3',
        reviewerDoctorId: 'doc2',
        recommendation: 'Ultrasound',
        confidence: 0.7,
        respondedAt: tDate,
      );
      final res2 = SecondOpinionResponse(
        id: 'res2',
        requestId: 'req3',
        reviewerDoctorId: 'doc3',
        recommendation: 'CT Scan',
        confidence: 0.9,
        respondedAt: tDate,
      );

      await repository.saveResponse(res1);
      await repository.saveResponse(res2);

      final results = await repository.getResponsesForRequest('req3');
      expect(results.length, 2);
    });
  });
}
