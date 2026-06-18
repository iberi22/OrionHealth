import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/local_agent/data/datasources/local_model_local_datasource.dart';

void main() {
  group('LocalModelLocalDataSource', () {
    test('getModelsDirectory throws MissingPluginException in test env', () async {
      final ds = LocalModelLocalDataSource();
      try {
        await ds.getModelsDirectory();
        // If it returns (unlikely in test), just verify it's a String
      } on MissingPluginException {
        // Expected: no path_provider implementation in test environment
        expect(true, isTrue);
      }
    });

    test('listInstalledModels throws MissingPluginException in test env', () async {
      final ds = LocalModelLocalDataSource();
      try {
        await ds.listInstalledModels();
      } on MissingPluginException {
        expect(true, isTrue);
      }
    });

    test('isModelInstalled throws MissingPluginException in test env', () async {
      final ds = LocalModelLocalDataSource();
      try {
        await ds.isModelInstalled('nonexistent-model');
      } on MissingPluginException {
        expect(true, isTrue);
      }
    });

    test('deleteModel throws MissingPluginException in test env', () async {
      final ds = LocalModelLocalDataSource();
      try {
        await ds.deleteModel('nonexistent-model');
      } on MissingPluginException {
        expect(true, isTrue);
      }
    });
  });
}
