import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../state/app_state_manager.dart' as am;
import 'voice_chat_state.dart';

@injectable
class VoiceChatCubit extends Cubit<VoiceChatState> {
  final am.AppStateManager _appStateManager;

  VoiceChatCubit(this._appStateManager) : super(const VoiceChatState()) {
    _appStateManager.addListener(_onStateChanged);
    _onStateChanged();
  }

  void _onStateChanged() {
    emit(state.copyWith(
      status: _mapStateToStatus(_appStateManager.voiceChatState.value),
      isRecording: _appStateManager.isRecording.value,
      isProcessing: _appStateManager.isProcessing.value,
    ));
  }

  VoiceChatStatus _mapStateToStatus(am.VoiceChatState state) {
    switch (state) {
      case am.VoiceChatState.idle:
        return VoiceChatStatus.idle;
      case am.VoiceChatState.listening:
        return VoiceChatStatus.listening;
      case am.VoiceChatState.processing:
        return VoiceChatStatus.processing;
      case am.VoiceChatState.speaking:
        return VoiceChatStatus.speaking;
      case am.VoiceChatState.error:
        return VoiceChatStatus.error;
    }
  }

  void startListening() {
    _appStateManager.updateVoiceChatState(am.VoiceChatState.listening);
    _appStateManager.updateRecordingState(true);
  }

  void stopListening() {
    _appStateManager.updateRecordingState(false);
    _appStateManager.updateVoiceChatState(am.VoiceChatState.processing);
  }

  @override
  Future<void> close() {
    _appStateManager.removeListener(_onStateChanged);
    return super.close();
  }
}
