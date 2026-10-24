import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../../auth/infrastructure/services/encryption_service.dart';
import '../../domain/entities/vital_sign.dart';
import '../../domain/repositories/vital_sign_repository.dart';

@LazySingleton(as: VitalSignRepository)
class VitalSignRepositoryImpl implements VitalSignRepository {
  final Isar _isar;
  final EncryptionService _encryptionService;

  VitalSignRepositoryImpl(this._isar, this._encryptionService);

  // VitalSign.value and .notes are @ignore (never stored in clear); they live
  // in encryptedValue / encryptedNotes. Without this the reading was lost.
  Future<void> _seal(VitalSign vitalSign) async {
    vitalSign.encryptedValue = await _encryptionService.encryptHealthData(
      vitalSign.value.toString(),
    );
    final notes = vitalSign.notes;
    if (notes != null) {
      vitalSign.encryptedNotes = await _encryptionService.encryptHealthData(
        notes,
      );
    }
  }

  Future<VitalSign> _open(VitalSign vitalSign) async {
    final encryptedValue = vitalSign.encryptedValue;
    if (encryptedValue != null) {
      vitalSign.value = double.parse(
        await _encryptionService.decryptHealthData(encryptedValue),
      );
    }
    final encryptedNotes = vitalSign.encryptedNotes;
    if (encryptedNotes != null) {
      vitalSign.notes = await _encryptionService.decryptHealthData(
        encryptedNotes,
      );
    }
    return vitalSign;
  }

  @override
  Future<void> saveVitalSign(VitalSign vitalSign) async {
    await _seal(vitalSign);
    await _isar.writeTxn(() async {
      await _isar.vitalSigns.put(vitalSign);
    });
  }

  @override
  Future<void> saveVitalSigns(List<VitalSign> vitalSigns) async {
    if (vitalSigns.isEmpty) return;
    for (final vitalSign in vitalSigns) {
      await _seal(vitalSign);
    }
    await _isar.writeTxn(() async {
      await _isar.vitalSigns.putAll(vitalSigns);
    });
  }

  @override
  Future<List<VitalSign>> getAllVitalSigns() async {
    final all = await _isar.vitalSigns.where().sortByDateTimeDesc().findAll();
    return [for (final v in all) await _open(v)];
  }

  @override
  Future<Map<VitalSignType, VitalSign?>> getLatestVitals() async {
    final Map<VitalSignType, VitalSign?> latestVitals = {};

    for (var type in VitalSignType.values) {
      final latest = await _isar.vitalSigns
          .filter()
          .typeEqualTo(type)
          .sortByDateTimeDesc()
          .findFirst();
      latestVitals[type] = latest == null ? null : await _open(latest);
    }

    return latestVitals;
  }
}
