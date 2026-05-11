import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/ssi/domain/repositories/ssi_repository.dart';
import 'package:orionhealth_health/features/ssi/infrastructure/repositories/isar_ssi_repository.dart';
import 'package:orionhealth_health/features/ssi/infrastructure/services/ssi_service_impl.dart';
import 'package:orionhealth_health/features/ssi/infrastructure/persistence/isar_did.dart';
import 'package:orionhealth_health/features/ssi/infrastructure/persistence/isar_credential.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  late Isar isar;
  late SsiRepository repository;
  late SsiServiceImpl service;
  late String testPath;

  setUpAll(() async {
    testPath = p.join(Directory.current.path, 'test_db_ssi');
    await Directory(testPath).create(recursive: true);

    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [IsarDidSchema, IsarCredentialSchema],
      directory: testPath,
    );
  });

  tearDownAll(() async {
    await isar.close();
    if (await Directory(testPath).exists()) {
      await Directory(testPath).delete(recursive: true);
    }
  });

  setUp(() async {
    await isar.writeTxn(() async {
      await isar.isarDids.clear();
      await isar.isarCredentials.clear();
    });
    repository = IsarSsiRepository(isar);
    service = SsiServiceImpl(repository);
  });

  test('SSI data persists across service restarts', () async {
    // 1. Create data in first session
    final did = await service.createDid();
    final vc = await service.issueCredential(
      schemaId: 'orion:schemas:VaccinationCredential:v1',
      subjectDid: did.activeDid,
      claims: {'vaccineName': 'COVID-19'},
    );

    // 2. Simulate "app restart" by creating new service instance with same Isar
    final newRepository = IsarSsiRepository(isar);
    final newService = SsiServiceImpl(newRepository);

    // 3. Verify data is still there
    final resolvedDoc = await newService.resolveDid(did.did);
    expect(resolvedDoc, isNotNull);
    expect(resolvedDoc!['id'], did.did);

    final credentials = await newRepository.getCredentials();
    expect(credentials.length, 1);
    expect(credentials.first.id, vc.id);
    expect(credentials.first.claims['vaccineName'], 'COVID-19');
  });

  test('revokeCredential persists removal', () async {
    final did = await service.createDid();
    final vc = await service.issueCredential(
      schemaId: 'orion:schemas:VaccinationCredential:v1',
      subjectDid: did.activeDid,
      claims: {'vaccineName': 'Flu'},
    );

    await service.revokeCredential(vc.id);

    // Restart
    final newRepository = IsarSsiRepository(isar);
    final credentials = await newRepository.getCredentials();
    expect(credentials, isEmpty);
  });
}
