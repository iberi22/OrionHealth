import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../domain/entities/vouch.dart';
import '../domain/repositories/vouch_repository.dart';

class VouchState {
  final List<Vouch> vouches;
  final bool isLoading;
  final String? error;

  VouchState({
    this.vouches = const [],
    this.isLoading = false,
    this.error,
  });

  VouchState copyWith({
    List<Vouch>? vouches,
    bool? isLoading,
    String? error,
  }) {
    return VouchState(
      vouches: vouches ?? this.vouches,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@injectable
class VouchCubit extends Cubit<VouchState> {
  final VouchRepository _vouchRepository;

  VouchCubit(this._vouchRepository) : super(VouchState());

  Future<void> loadVouches(String doctorId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final vouches = await _vouchRepository.getByDoctor(doctorId);
      emit(state.copyWith(vouches: vouches, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> addVouch(Vouch vouch) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _vouchRepository.addVouch(vouch);
      await loadVouches(vouch.targetDoctor);
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }
}
