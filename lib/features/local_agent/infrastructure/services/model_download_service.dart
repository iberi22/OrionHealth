import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ModelInfo {
  final String filename;
  final int size;
  final DateTime lastModified;
  final String? parameters;

  ModelInfo({
    required this.filename,
    required this.size,
    required this.lastModified,
    this.parameters,
  });
}

@lazySingleton
class ModelDownloadService {
  final Dio _dio = Dio();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    final modelsPath = p.join(directory.path, 'models');
    final dir = Directory(modelsPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return modelsPath;
  }

  Future<void> downloadModel(
    String hfUrl,
    void Function(double progress, String speed, int downloadedMB, int totalMB) callback,
  ) async {
    final fileName = hfUrl.split('/').last;
    final path = p.join(await _localPath, fileName);

    int lastDownloaded = 0;
    DateTime lastTime = DateTime.now();

    await _dio.download(
      hfUrl,
      path,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          final progress = received / total;
          final downloadedMB = received ~/ (1024 * 1024);
          final totalMB = total ~/ (1024 * 1024);

          final now = DateTime.now();
          final duration = now.difference(lastTime).inMilliseconds;
          if (duration >= 500) { // Update speed every 500ms
            final bytesSinceLast = received - lastDownloaded;
            final speedKBps = (bytesSinceLast / 1024) / (duration / 1000);
            final speedMBps = speedKBps / 1024;
            final speedString = "${speedMBps.toStringAsFixed(2)} MB/s";

            callback(progress, speedString, downloadedMB, totalMB);

            lastDownloaded = received;
            lastTime = now;
          } else if (received == total) {
             callback(progress, "Done", downloadedMB, totalMB);
          }
        }
      },
      options: Options(
        followRedirects: true,
        maxRedirects: 5,
      ),
    );
  }

  Future<List<ModelInfo>> listDownloadedModels() async {
    final path = await _localPath;
    final dir = Directory(path);
    if (!await dir.exists()) return [];

    final List<ModelInfo> models = [];
    await for (final entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.gguf')) {
        final stat = await entity.stat();
        models.add(ModelInfo(
          filename: p.basename(entity.path),
          size: stat.size,
          lastModified: stat.modified,
          parameters: _guessParameters(p.basename(entity.path)),
        ));
      }
    }
    return models;
  }

  String? _guessParameters(String filename) {
    if (filename.contains('2b')) return '2B';
    if (filename.contains('7b')) return '7B';
    if (filename.contains('13b')) return '13B';
    return null;
  }

  Future<void> deleteModel(String filename) async {
    final path = p.join(await _localPath, filename);
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<ModelInfo?> getModelInfo(String filename) async {
    final path = p.join(await _localPath, filename);
    final file = File(path);
    if (await file.exists()) {
      final stat = await file.stat();
      return ModelInfo(
        filename: filename,
        size: stat.size,
        lastModified: stat.modified,
        parameters: _guessParameters(filename),
      );
    }
    return null;
  }
}
