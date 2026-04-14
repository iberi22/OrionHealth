import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/vital_sign.dart';
import '../../domain/repositories/vital_sign_repository.dart';

@LazySingleton(as: VitalSignRepository)
class VitalSignRepositoryImpl implements VitalSignRepository {
  final Isar _isar;

  VitalSignRepositoryImpl(this._isar);

  @override
  Future<List<VitalSign>> getAllVitals() {
    return _isar.vitalSigns.where().sortByTimestampDesc().findAll();
  }

  @override
  Future<List<VitalSign>> getVitalsByType(VitalType type) {
    return _isar.vitalSigns.filter().typeEqualTo(type).sortByTimestampDesc().findAll();
  }

  @override
  Future<void> saveVital(VitalSign vital) async {
    await _isar.writeTxn(() async {
      await _isar.vitalSigns.put(vital);
    });
  }

  @override
  Future<void> deleteVital(int id) async {
    await _isar.writeTxn(() async {
      await _isar.vitalSigns.delete(id);
    });
  }

  @override
  Stream<List<VitalSign>> watchVitals() {
    return _isar.vitalSigns.where().sortByTimestampDesc().watch(fireImmediately: true);
  }
}
