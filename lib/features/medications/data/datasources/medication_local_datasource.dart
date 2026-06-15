import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/medication.dart';

@lazySingleton
class MedicationLocalDataSource {
  final Isar _isar;
  MedicationLocalDataSource(this._isar);

  Future<List<Medication>> getAllMedications() =>
      _isar.medications.where().findAll();

  Future<void> saveMedication(Medication m) =>
      _isar.writeTxn(() async => _isar.medications.put(m));

  Future<void> deleteMedication(int id) =>
      _isar.writeTxn(() async => _isar.medications.delete(id));
}
