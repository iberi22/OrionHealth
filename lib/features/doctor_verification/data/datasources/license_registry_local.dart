// TODO: migrate from data/ — moved to infrastructure/datasources/license_registry_local.dart
// This file is kept temporarily. Remove after verifying new imports work.

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class LicenseRegistryLocal {
  Map<String, List<String>> _registry = {};

  @postConstruct
  Future<void> load() async {
    try {
      final String response = await rootBundle.loadString('assets/data/license_registry.json');
      final data = json.decode(response) as Map<String, dynamic>;
      _registry = data.map((key, value) => MapEntry(key, List<String>.from(value)));
    } catch (e) {
      _registry = {};
    }
  }

  List<String> getHashesForCountry(String countryCode) {
    return _registry[countryCode] ?? [];
  }
}
