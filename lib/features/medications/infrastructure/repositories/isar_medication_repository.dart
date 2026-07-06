import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:medical_standards/medical_standards.dart' as standards;
import '../../domain/entities/medication.dart';
import '../../domain/repositories/medication_repository.dart';
import '../services/pharmacy_api_service.dart';

@LazySingleton(as: MedicationRepository)
class IsarMedicationRepository implements MedicationRepository {
  final Isar _isar;
  final PharmacyApiService _apiService;

  IsarMedicationRepository(this._isar, this._apiService);

  @override
  Future<List<Medication>> getAllMedications() async {
    return await _isar.medications.where().findAll();
  }

  @override
  Future<void> saveMedication(Medication medication) async {
    await _isar.writeTxn(() async {
      await _isar.medications.put(medication);
    });
  }

  @override
  Future<void> deleteMedication(int id) async {
    await _isar.writeTxn(() async {
      await _isar.medications.delete(id);
    });
  }

  @override
  Future<List<Medication>> searchMedications(String query) async {
    final Map<String, Medication> mergedResults = {};

    // 1. Search locally in medical_standards catalog
    final localResults = standards.MedicationCatalog.all
        .where((m) =>
            m.displayName.toLowerCase().contains(query.toLowerCase()) ||
            (m.genericName?.toLowerCase().contains(query.toLowerCase()) ?? false))
        .map((m) => Medication(
              name: m.displayName,
              rxNormCode: m.code,
              drugClass: m.drugClass,
              genericName: m.genericName,
              startDate: DateTime.now(),
            ));

    for (var m in localResults) {
      if (m.rxNormCode != null) mergedResults[m.rxNormCode!] = m;
    }

    if (mergedResults.length >= 5) {
      return mergedResults.values.toList();
    }

    // 2. Search in Isar cache (previously searched medications)
    final cachedResults = await _isar.medications
        .filter()
        .nameContains(query, caseSensitive: false)
        .or()
        .genericNameContains(query, caseSensitive: false)
        .findAll();

    for (var m in cachedResults) {
      if (m.rxNormCode != null) mergedResults[m.rxNormCode!] = m;
    }

    // 3. Fallback to API if online or if merged results are few
    if (mergedResults.length < 5) {
      final apiResults = await _apiService.searchMedications(query);
      for (var m in apiResults) {
        if (m.rxNormCode != null && !mergedResults.containsKey(m.rxNormCode)) {
          mergedResults[m.rxNormCode!] = m;
        }
      }
    }

    return mergedResults.values.toList();
  }

  @override
  Future<Medication?> getMedicationDetails(String code) async {
    // 1. Check local catalog
    final localMed = standards.MedicationCatalog.findByCode(code);
    if (localMed != null) {
      return Medication(
        name: localMed.displayName,
        rxNormCode: localMed.code,
        drugClass: localMed.drugClass,
        genericName: localMed.genericName,
        startDate: DateTime.now(),
      );
    }

    // 2. Check Isar cache
    final cachedMed = await _isar.medications.filter().rxNormCodeEqualTo(code).findFirst();
    if (cachedMed != null) {
      return cachedMed;
    }

    // 3. Fetch from API
    return await _apiService.getMedicationDetails(code);
  }
}
