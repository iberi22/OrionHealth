import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../meditation_service.dart';
import 'meditation_state.dart';

@injectable
class MeditationCubit extends Cubit<MeditationState> {
  final MeditationServiceV2 _meditationService;

  MeditationCubit(this._meditationService) : super(MeditationInitial());

  Future<void> loadMeditationData() async {
    emit(MeditationLoading());
    try {
      await _meditationService.initialize();
      final scripts = _meditationService.scripts;
      final progress = await _meditationService.getProgress();
      emit(MeditationLoaded(scripts: scripts, progress: progress));
    } catch (e) {
      emit(MeditationError(e.toString()));
    }
  }
}
