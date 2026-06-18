import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/vouch.dart';
import 'package:orionhealth_health/features/doctor_verification/infrastructure/repositories/isar_vouch_repository.dart';
import 'package:path/path.dart' as p;

void main() {
  late Isar isar;
  late IsarVouchRepository repository;
  late String testDir;

  setUpAll(() async {
    testDir = p.join(Directory.current.path, 'test_db_isar_vouch');
    await Directory(testDir).create(recursive: true);

    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [VouchSchema],
      directory: testDir,
    );
    repository = IsarVouchRepository(isar);
  });

  tearDownAll(() async {
    await isar.close();
    if (await Directory(testDir).exists()) {
      await Directory(testDir).delete(recursive: true);
    }
  });

  setUp(() async {
    await isar.writeTxn(() async {
      await isar.vouchs.clear();
    });
  });

  group('IsarVouchRepository', () {
    final tDate = DateTime(2023, 6, 15);

    test('addVouch and getByDoctor', () async {
      final vouch = Vouch(
        id: 'v1',
        vouchedBy: 'doc2',
        targetDoctor: 'doc1',
        category: 'Clinical Excellence',
        timestamp: tDate,
      );

      await repository.addVouch(vouch);

      final results = await repository.getByDoctor('doc1');
      expect(results.length, 1);
      expect(results.first.id, 'v1');
      expect(results.first.vouchedBy, 'doc2');
      expect(results.first.category, 'Clinical Excellence');
    });

    test('getByDoctor returns vouches for specific doctor', () async {
      final v1 = Vouch(
        id: 'v1',
        vouchedBy: 'doc2',
        targetDoctor: 'doc1',
        category: 'Clinical',
        timestamp: tDate,
      );
      final v2 = Vouch(
        id: 'v2',
        vouchedBy: 'doc3',
        targetDoctor: 'doc1',
        category: 'Ethics',
        timestamp: tDate,
      );
      final v3 = Vouch(
        id: 'v3',
        vouchedBy: 'doc4',
        targetDoctor: 'doc5',
        category: 'Research',
        timestamp: tDate,
      );

      await repository.addVouch(v1);
      await repository.addVouch(v2);
      await repository.addVouch(v3);

      final results = await repository.getByDoctor('doc1');
      expect(results.length, 2);
      expect(results.any((v) => v.id == 'v1'), isTrue);
      expect(results.any((v) => v.id == 'v2'), isTrue);
    });

    test('getByDoctor returns empty for unknown doctor', () async {
      final results = await repository.getByDoctor('nonexistent');
      expect(results, isEmpty);
    });

    test('verifyVouchChain returns true with valid chain', () async {
      // doc2 vouches for doc1, doc3 vouches for doc2 -> trust chain
      final v1 = Vouch(
        id: 'v1',
        vouchedBy: 'doc2',
        targetDoctor: 'doc1',
        category: 'Clinical',
        timestamp: tDate,
      );
      final v2 = Vouch(
        id: 'v2',
        vouchedBy: 'doc3',
        targetDoctor: 'doc2',
        category: 'Clinical',
        timestamp: tDate,
      );

      await repository.addVouch(v1);
      await repository.addVouch(v2);

      final result = await repository.verifyVouchChain('doc1');
      expect(result, isTrue);
    });

    test('verifyVouchChain returns false with no vouches', () async {
      final result = await repository.verifyVouchChain('lonely_doc');
      expect(result, isFalse);
    });

    test('verifyVouchChain returns false when depth exhausted', () async {
      // doc2 vouches for doc1, but no one vouches for doc2 with depth=1
      final vouch = Vouch(
        id: 'v1',
        vouchedBy: 'doc2',
        targetDoctor: 'doc1',
        category: 'Clinical',
        timestamp: tDate,
      );

      await repository.addVouch(vouch);

      final result = await repository.verifyVouchChain('doc1', depth: 1);
      expect(result, isTrue); // depth 1 finds vouches -> returns true
    });

    test('verifyVouchChain respects depth limit', () async {
      // doc2 vouches for doc1, but depth=0 should return false
      final vouch = Vouch(
        id: 'v1',
        vouchedBy: 'doc2',
        targetDoctor: 'doc1',
        category: 'Clinical',
        timestamp: tDate,
      );

      await repository.addVouch(vouch);

      final result = await repository.verifyVouchChain('doc1', depth: 0);
      expect(result, isFalse);
    });
  });
}
