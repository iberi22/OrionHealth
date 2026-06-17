import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../domain/entities/second_opinion.dart';
import '../domain/repositories/second_opinion_repository.dart';

class SecondOpinionState {
  final List<SecondOpinionRequest> requests;
  final Map<String, List<SecondOpinionResponse>> responses; // requestId -> responses
  final bool isLoading;
  final String? error;

  SecondOpinionState({
    this.requests = const [],
    this.responses = const {},
    this.isLoading = false,
    this.error,
  });

  SecondOpinionState copyWith({
    List<SecondOpinionRequest>? requests,
    Map<String, List<SecondOpinionResponse>>? responses,
    bool? isLoading,
    String? error,
  }) {
    return SecondOpinionState(
      requests: requests ?? this.requests,
      responses: responses ?? this.responses,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@injectable
class SecondOpinionCubit extends Cubit<SecondOpinionState> {
  final SecondOpinionRepository _repository;

  SecondOpinionCubit(this._repository) : super(SecondOpinionState());

  Future<void> loadRequests(String patientId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final requests = await _repository.getRequestsForPatient(patientId);
      emit(state.copyWith(requests: requests, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> submitRequest(SecondOpinionRequest request) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _repository.saveRequest(request);
      await loadRequests(request.patientId);
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> loadResponses(String requestId) async {
    try {
      final responses = await _repository.getResponsesForRequest(requestId);
      final newResponses = Map<String, List<SecondOpinionResponse>>.from(state.responses);
      newResponses[requestId] = responses;
      emit(state.copyWith(responses: newResponses));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
