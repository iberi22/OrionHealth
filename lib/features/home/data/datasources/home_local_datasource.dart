import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';

@lazySingleton
class HomeLocalDataSource {
  final Isar _isar;
  HomeLocalDataSource(this._isar);

  Future<void> saveIndexingStatus(bool completed) async {
    // Store indexing completion status
  }

  Future<bool> getIndexingStatus() async => false;
}
