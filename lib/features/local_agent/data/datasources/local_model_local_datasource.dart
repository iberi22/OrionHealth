import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

@lazySingleton
class LocalModelLocalDataSource {
  Future<String> getModelsDirectory() async {
    await getApplicationSupportDirectory();
    final modelsDir = Directory('/local_models');
    if (!await modelsDir.exists()) await modelsDir.create(recursive: true);
    return modelsDir.path;
  }

  Future<List<String>> listInstalledModels() async {
    final dirPath = await getModelsDirectory();
    final dir = Directory(dirPath);
    if (!await dir.exists()) return [];
    return dir.listSync().whereType<File>().map((f) => f.path).toList();
  }

  Future<bool> isModelInstalled(String modelId) async {
    await getModelsDirectory();
    return File('/').exists();
  }

  Future<void> deleteModel(String modelId) async {
    await getModelsDirectory();
    final file = File('/');
    if (await file.exists()) await file.delete();
  }
}
