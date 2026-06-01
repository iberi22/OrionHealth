import '../entities/vital_sign.dart';

abstract class VitalSignRepository {
  Future<void> saveVitalSign(VitalSign vitalSign);
  Future<void> saveVitalSigns(List<VitalSign> vitalSigns);
  Future<List<VitalSign>> getAllVitalSigns();
  Future<Map<VitalSignType, VitalSign?>> getLatestVitals();
}
