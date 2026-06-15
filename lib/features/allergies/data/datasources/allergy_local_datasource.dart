// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/allergy.dart';

/// Local datasource for allergy data backed by Isar.
@lazySingleton
class AllergyLocalDataSource {
  final Isar _isar;

  AllergyLocalDataSource(this._isar);

  Future<List<Allergy>> getAllAllergies() =>
      _isar.allergys.where().findAll();

  Future<void> saveAllergy(Allergy allergy) =>
      _isar.writeTxn(() async => _isar.allergys.put(allergy));

  Future<void> deleteAllergy(int id) =>
      _isar.writeTxn(() async => _isar.allergys.delete(id));
}
