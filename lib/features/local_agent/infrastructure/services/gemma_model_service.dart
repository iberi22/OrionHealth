import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GemmaModelService {
  static const String MODEL_NAME = 'gemma-2b-it-q4';

  Future<bool> checkRequirements() async {
    // Requisitos: RAM >= 4GB y Storage >= 2GB libres.
    return true;
  }

  Future<bool> isModelDownloaded() async {
    try {
      return await FlutterGemma.isModelInstalled(MODEL_NAME);
    } catch (e) {
      return false;
    }
  }

  Stream<double> downloadModel() async* {
    await FlutterGemma.installModel(modelType: ModelType.gemmaIt).install();
    yield 1.0;
  }
}
