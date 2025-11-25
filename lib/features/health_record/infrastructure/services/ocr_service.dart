import 'package:injectable/injectable.dart';

abstract class OcrService {
  Future<String> extractText(String filePath);
}

@LazySingleton(as: OcrService)
class OcrServiceStub implements OcrService {
  @override
  Future<String> extractText(String filePath) async {
    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));
    return "Texto extraído simulado del archivo: $filePath\n\nPacienta presenta niveles normales de glucosa...";
  }
}
