import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/license_registry.dart';

@lazySingleton
class LicenseRegistryLocalDataSource {
  final Isar isar;

  LicenseRegistryLocalDataSource(this.isar);

  @postConstruct
  Future<void> load() async {
    try {
      final count = await isar.licenseRegistryLocals.count();
      if (count > 0) return;

      final String response = await rootBundle.loadString('assets/data/license_registry.json');
      final data = json.decode(response) as Map<String, dynamic>;

      await isar.writeTxn(() async {
        for (final entry in data.entries) {
          final registry = LicenseRegistryLocal(
            countryCode: entry.key,
            hashes: List<String>.from(entry.value),
          );
          await isar.licenseRegistryLocals.put(registry);
        }
      });
    } catch (e) {
      // Log error or handle silently if assets not found
    }
  }

  Future<List<String>> getHashesForCountry(String countryCode) async {
    final registry = await isar.licenseRegistryLocals
        .filter()
        .countryCodeEqualTo(countryCode)
        .findFirst();
    return registry?.hashes ?? [];
  }
}
