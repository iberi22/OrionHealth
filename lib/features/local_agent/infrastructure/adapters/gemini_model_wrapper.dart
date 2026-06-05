import 'package:google_generative_ai/google_generative_ai.dart';

/// Wrapper for GenerativeModel to allow mocking in unit tests.
class GeminiModelWrapper {
  final GenerativeModel _model;

  GeminiModelWrapper(this._model);

  Future<String?> generateContent(String prompt) async {
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text;
  }
}
