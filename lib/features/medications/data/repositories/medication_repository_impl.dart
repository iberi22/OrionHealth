import '../../domain/entities/medication.dart';
import '../../domain/repositories/medication_repository.dart';
import '../datasources/medication_local_datasource.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationLocalDataSource _localDataSource;
  MedicationRepositoryImpl(this._localDataSource);

  @override
  Future<List<Medication>> getAllMedications() => _localDataSource.getAllMedications();
  @override
  Future<void> saveMedication(Medication medication) => _localDataSource.saveMedication(medication);
  @override
  Future<void> deleteMedication(int id) => _localDataSource.deleteMedication(id);
}
