import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';

/// Wrapper for GenerativeModel to allow mocking in unit tests.
@lazySingleton
class GeminiModelWrapper {
  final GenerativeModel _model;

  GeminiModelWrapper(this._model);

  Future<String?> generateContent(String prompt) async {
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text;
  }
}
