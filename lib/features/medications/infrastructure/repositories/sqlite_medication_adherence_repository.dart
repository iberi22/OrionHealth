import 'package:injectable/injectable.dart';
import '../../domain/entities/medication_adherence.dart';
import '../../domain/repositories/medication_adherence_repository.dart';
import '../datasources/adherence_sqlite_datasource.dart';

@LazySingleton(as: MedicationAdherenceRepository)
class SqliteMedicationAdherenceRepository implements MedicationAdherenceRepository {
  final AdherenceSqliteDatasource _datasource;

  SqliteMedicationAdherenceRepository(this._datasource);

  @override
  Future<List<MedicationAdherence>> getAdherenceForMedication(int medicationId) async {
    final db = await _datasource.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AdherenceSqliteDatasource.tableAdherence,
      where: '${AdherenceSqliteDatasource.columnMedicationId} = ?',
      whereArgs: [medicationId],
      orderBy: '${AdherenceSqliteDatasource.columnScheduledTime} ASC',
    );

    return List.generate(maps.length, (i) => _fromMap(maps[i]));
  }

  @override
  Future<List<MedicationAdherence>> getAdherenceForDateRange(DateTime start, DateTime end) async {
    final db = await _datasource.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AdherenceSqliteDatasource.tableAdherence,
      where: '${AdherenceSqliteDatasource.columnScheduledTime} BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: '${AdherenceSqliteDatasource.columnScheduledTime} ASC',
    );

    return List.generate(maps.length, (i) => _fromMap(maps[i]));
  }

  @override
  Future<void> saveAdherence(MedicationAdherence adherence) async {
    final db = await _datasource.database;
    if (adherence.id == null) {
      await db.insert(
        AdherenceSqliteDatasource.tableAdherence,
        _toMap(adherence),
      );
    } else {
      await db.update(
        AdherenceSqliteDatasource.tableAdherence,
        _toMap(adherence),
        where: '${AdherenceSqliteDatasource.columnId} = ?',
        whereArgs: [adherence.id],
      );
    }
  }

  @override
  Future<void> deleteAdherence(int id) async {
    final db = await _datasource.database;
    await db.delete(
      AdherenceSqliteDatasource.tableAdherence,
      where: '${AdherenceSqliteDatasource.columnId} = ?',
      whereArgs: [id],
    );
  }

  MedicationAdherence _fromMap(Map<String, dynamic> map) {
    return MedicationAdherence(
      id: map[AdherenceSqliteDatasource.columnId],
      medicationId: map[AdherenceSqliteDatasource.columnMedicationId],
      scheduledTime: DateTime.parse(map[AdherenceSqliteDatasource.columnScheduledTime]),
      takenTime: map[AdherenceSqliteDatasource.columnTakenTime] != null
          ? DateTime.parse(map[AdherenceSqliteDatasource.columnTakenTime])
          : null,
      status: AdherenceStatus.values.firstWhere(
        (e) => e.name == map[AdherenceSqliteDatasource.columnStatus],
      ),
      notes: map[AdherenceSqliteDatasource.columnNotes],
    );
  }

  Map<String, dynamic> _toMap(MedicationAdherence adherence) {
    return {
      AdherenceSqliteDatasource.columnMedicationId: adherence.medicationId,
      AdherenceSqliteDatasource.columnScheduledTime: adherence.scheduledTime.toIso8601String(),
      AdherenceSqliteDatasource.columnTakenTime: adherence.takenTime?.toIso8601String(),
      AdherenceSqliteDatasource.columnStatus: adherence.status.name,
      AdherenceSqliteDatasource.columnNotes: adherence.notes,
    };
  }
}
