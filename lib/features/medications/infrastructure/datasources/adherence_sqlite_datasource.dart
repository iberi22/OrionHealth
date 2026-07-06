import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AdherenceSqliteDatasource {
  static const String _databaseName = 'medication_adherence.db';
  static const int _databaseVersion = 1;

  static const String tableAdherence = 'medication_adherence';
  static const String columnId = 'id';
  static const String columnMedicationId = 'medication_id';
  static const String columnScheduledTime = 'scheduled_time';
  static const String columnTakenTime = 'taken_time';
  static const String columnStatus = 'status';
  static const String columnNotes = 'notes';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableAdherence (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnMedicationId INTEGER NOT NULL,
        $columnScheduledTime TEXT NOT NULL,
        $columnTakenTime TEXT,
        $columnStatus TEXT NOT NULL,
        $columnNotes TEXT
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_medication_id ON $tableAdherence ($columnMedicationId)
    ''');

    await db.execute('''
      CREATE INDEX idx_scheduled_time ON $tableAdherence ($columnScheduledTime)
    ''');
  }
}
