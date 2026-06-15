import 'dart:async';
import 'dart:io';
import 'package:crypto/crypto.dart' as crypto;
import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:orion/utils/error_handler.dart';
import 'asr_model_manifest.dart';

/// Manages on-device ASR models: manifest loading, install, verify, remove.
class OnDeviceAsrModelManager {
  OnDeviceAsrModelManager._internal() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 5),
      ),
    );
  }
  static final OnDeviceAsrModelManager _instance =
      OnDeviceAsrModelManager._internal();
  factory OnDeviceAsrModelManager() => _instance;

  late Dio _dio;
  Directory? _baseDir;
  AsrModelManifest _manifest = AsrModelManifest.empty();

  void debugSetBaseDirForTesting(Directory dir) {
    _baseDir = dir;
  }

  void debugSetDioForTesting(Dio dio) {
    _dio = dio;
  }

  Future<void> initialize() async {
    if (_baseDir == null) {
      final support = await getApplicationSupportDirectory();
      _baseDir = Directory(p.join(support.path, 'asr'));
    }
    if (!await _baseDir!.exists()) {
      await _baseDir!.create(recursive: true);
    }
    if (_manifest.models.isEmpty) {
      await _loadBundledManifest();
    }
  }

  AsrModelManifest get manifest => _manifest;

  Future<String> _modelDir(String modelKey) async {
    await initialize();
    return p.join(_baseDir!.path, 'models', modelKey);
  }

  Future<String> _localPathFor(String modelKey, String remoteUrl) async {
    final dir = await _modelDir(modelKey);
    final fileName = p.basename(Uri.parse(remoteUrl).path);
    return p.join(dir, fileName);
  }

  Future<void> _loadBundledManifest() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/asr/manifest.json');
      _manifest = AsrModelManifest.parse(jsonStr);
    } catch (e) {
      ErrorHandler.handleError(
        e,
        null,
        context: 'ASR Model Manifest: load bundled manifest',
        showToUser: false,
      );
      _manifest = AsrModelManifest.empty();
    }
  }

  Future<bool> isInstalled(String modelKey) async {
    final model =
        _manifest.models
            .where((m) => m.key == modelKey)
            .cast<AsrModelEntry?>()
            .firstOrNull;
    if (model == null) return false;
    for (final f in model.files) {
      final path = await _localPathFor(model.key, f.url);
      final file = File(path);
      if (!await file.exists()) return false;
      if (f.md5.isNotEmpty && f.md5.length == 32) {
        final ok = await _verifyMd5(file, f.md5);
        if (!ok) return false;
      } else if (f.sizeBytes > 0) {
        final stat = await file.stat();
        if (stat.size != f.sizeBytes) return false;
      }
    }
    return true;
  }

  Future<void> installModel(
    AsrModelEntry model, {
    void Function(double progress)? onProgress,
  }) async {
    final total = model.files.length;
    var done = 0;
    for (final f in model.files) {
      await _downloadFile(
        model.key,
        f,
        onProgress: (p) {
          if (onProgress != null) {
            onProgress((done + p) / total);
          }
        },
      );
      done += 1;
      onProgress?.call(done / total);
    }
  }

  Future<void> removeModel(String modelKey) async {
    final dir = Directory(await _modelDir(modelKey));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<String?> getLocalPath(String modelKey, String remoteUrl) async {
    final filePath = await _localPathFor(modelKey, remoteUrl);
    return (await File(filePath).exists()) ? filePath : null;
  }

  Future<List<String>> listInstalled() async {
    await initialize();
    final modelsDir = Directory(p.join(_baseDir!.path, 'models'));
    if (!await modelsDir.exists()) return [];
    final entries = await modelsDir.list().toList();
    return entries
        .whereType<Directory>()
        .map((e) => p.basename(e.path))
        .toList();
  }

  Future<void> _downloadFile(
    String modelKey,
    AsrFileMeta meta, {
    void Function(double progress)? onProgress,
  }) async {
    final savePath = await _localPathFor(modelKey, meta.url);
    final dir = Directory(p.dirname(savePath));
    if (!await dir.exists()) await dir.create(recursive: true);

    final f = File(savePath);
    if (await f.exists()) {
      if (meta.md5.isNotEmpty && meta.md5.length == 32) {
        final ok = await _verifyMd5(f, meta.md5);
        if (ok) return;
      } else {
        if (meta.sizeBytes > 0) {
          final stat = await f.stat();
          if (stat.size == meta.sizeBytes) return;
        }
      }
    }

    await _dio.download(
      meta.url,
      savePath,
      onReceiveProgress: (received, total) {
        if (onProgress != null && total > 0) {
          onProgress(received / total);
        }
      },
      options: Options(responseType: ResponseType.bytes, followRedirects: true),
    );

    if (meta.md5.isNotEmpty && meta.md5.length == 32) {
      final ok = await _verifyMd5(File(savePath), meta.md5);
      if (!ok) {
        try {
          await File(savePath).delete();
        } catch (_) {}
        throw Exception('Checksum mismatch for ${p.basename(savePath)}');
      }
    }
  }

  Future<bool> _verifyMd5(File file, String expectedMd5LowerHex) async {
    final stream = file.openRead();
    final hash = await crypto.md5.bind(stream).first;
    final digest = hash.toString();
    return digest.toLowerCase() == expectedMd5LowerHex.toLowerCase();
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (it.moveNext()) return it.current;
    return null;
  }
}
