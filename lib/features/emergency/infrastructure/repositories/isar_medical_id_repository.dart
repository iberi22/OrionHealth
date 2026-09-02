/// FEAT-022: Isar implementation of MedicalIdRepository
///
/// Mobile/Android/iOS storage. Uses Isar collection with explicit
/// schema (no codegen — store as JSON string in single field).
library;

import 'dart:async';
import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/medical_id.dart';
import '../../domain/repositories/medical_id_repository.dart';
part 'isar_medical_id_repository.g.dart';

/// Isar collection wrapper for MedicalIdEntity.
/// Stored as JSON string to avoid build_runner codegen.
@collection
class MedicalIdRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String userId;

  late String jsonData; // serialized MedicalIdEntity
  late DateTime savedAt;

  MedicalIdRecord();

  MedicalIdRecord.create({
    required this.userId,
    required this.jsonData,
    required this.savedAt,
  });
}

@LazySingleton(as: MedicalIdRepository)
class IsarMedicalIdRepository implements MedicalIdRepository {
  final Isar _isar;

  IsarMedicalIdRepository(this._isar);

  @override
  Future<MedicalIdEntity?> getByUser(String userId) async {
    final record =
        await _isar.medicalIdRecords.filter().userIdEqualTo(userId).findFirst();
    if (record == null) return null;
    return MedicalIdEntity.fromJson(
        json.decode(record.jsonData) as Map<String, dynamic>);
  }

  @override
  Future<void> save(MedicalIdEntity medicalId) async {
    final record = MedicalIdRecord.create(
      userId: medicalId.userId,
      jsonData: json.encode(medicalId.toJson()),
      savedAt: DateTime.now(),
    );
    await _isar.writeTxn(() async {
      await _isar.medicalIdRecords.put(record);
    });
  }

  @override
  Future<void> delete(String userId) async {
    await _isar.writeTxn(() async {
      await _isar.medicalIdRecords.filter().userIdEqualTo(userId).deleteAll();
    });
  }

  @override
  Future<List<String>> getCriticalFields(String userId) async {
    final id = await getByUser(userId);
    return id?.toCriticalCard() ?? const [];
  }
}
