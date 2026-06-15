import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/vital_sign.dart';

@lazySingleton
class VitalSignLocalDataSource {
  final Isar _isar;
  VitalSignLocalDataSource(this._isar);

  Future<List<VitalSign>> getAllVitalSigns() =>
      _isar.vitalSigns.where().sortByDateTimeDesc().findAll();

  Future<void> saveVitalSign(VitalSign v) =>
      _isar.writeTxn(() async => _isar.vitalSigns.put(v));

  Future<void> saveVitalSigns(List<VitalSign> vitals) async {
    if (vitals.isEmpty) return;
    await _isar.writeTxn(() async => _isar.vitalSigns.putAll(vitals));
  }

  Future<VitalSign?> getLatestByType(VitalSignType type) =>
      _isar.vitalSigns.filter().typeEqualTo(type).sortByDateTimeDesc().findFirst();
}
