import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/vital_sign.dart';
import '../../domain/repositories/vital_sign_repository.dart';

@LazySingleton(as: VitalSignRepository)
class VitalSignRepositoryImpl implements VitalSignRepository {
  final Isar _isar;

  VitalSignRepositoryImpl(this._isar);

  @override
  Future<List<VitalSign>> getAllVitalSigns() async {
    return await _isar.vitalSigns.where().sortByRecordedAtDesc().findAll();
  }

  @override
  Future<List<VitalSign>> getVitalSignsByType(VitalSignType type) async {
    return await _isar.vitalSigns
        .filter()
        .typeEqualTo(type)
        .sortByRecordedAtDesc()
        .findAll();
  }

  @override
  Future<VitalSign?> getLatestByType(VitalSignType type) async {
    return await _isar.vitalSigns
        .filter()
        .typeEqualTo(type)
        .sortByRecordedAtDesc()
        .findFirst();
  }

  @override
  Future<Map<VitalSignType, VitalSign?>> getLatestVitals() async {
    final Map<VitalSignType, VitalSign?> result = {};
    for (final type in VitalSignType.values) {
      result[type] = await getLatestByType(type);
    }
    return result;
  }

  @override
  Future<VitalSign?> getVitalSignById(int id) async {
    return await _isar.vitalSigns.get(id);
  }

  @override
  Future<void> saveVitalSign(VitalSign vitalSign) async {
    await _isar.writeTxn(() async {
      await _isar.vitalSigns.put(vitalSign);
    });
  }

  @override
  Future<void> saveVitalSigns(List<VitalSign> vitalSigns) async {
    await _isar.writeTxn(() async {
      await _isar.vitalSigns.putAll(vitalSigns);
    });
  }

  @override
  Future<void> deleteVitalSign(int id) async {
    await _isar.writeTxn(() async {
      await _isar.vitalSigns.delete(id);
    });
  }
}
