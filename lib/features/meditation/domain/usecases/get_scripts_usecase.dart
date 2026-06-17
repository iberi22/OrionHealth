import '../meditation_models.dart';
import '../meditation_service.dart';

class GetScriptsUseCase {
  final MeditationServiceV2 _service;

  GetScriptsUseCase(this._service);

  Future<List<MeditationScript>> execute() async {
    await _service.initialize();
    return _service.scripts;
  }
}
