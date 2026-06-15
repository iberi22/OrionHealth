import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/shared_health_package.dart';

@lazySingleton
class HealthSharingLocalDataSource {
  final Isar _isar;
  HealthSharingLocalDataSource(this._isar);

  Future<List<SharedHealthPackage>> getSentPackages() async => [];

  Future<List<SharedHealthPackage>> getReceivedPackages() async => [];

  Future<void> savePackage(SharedHealthPackage pkg) async {}
}
