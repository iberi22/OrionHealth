import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../domain/entities/did.dart';
import '../domain/entities/verifiable_credential.dart';
import '../domain/repositories/ssi_repository.dart';
import 'ssi_state.dart';

@injectable
class SsiCubit extends Cubit<SsiState> {
  final SsiRepository _repository;

  SsiCubit(this._repository) : super(SsiInitial());

  Future<void> loadDids() async {
    emit(SsiLoading());
    try {
      final dids = await _repository.getDids();
      emit(SsiDidsLoaded(dids));
    } catch (e) {
      emit(SsiError(e.toString()));
    }
  }

  Future<void> loadCredentials() async {
    emit(SsiLoading());
    try {
      final credentials = await _repository.getCredentials();
      emit(SsiCredentialsLoaded(credentials));
    } catch (e) {
      emit(SsiError(e.toString()));
    }
  }

  Future<void> saveCredential(VerifiableCredential credential) async {
    try {
      await _repository.saveCredential(credential);
      await loadCredentials();
    } catch (e) {
      emit(SsiError(e.toString()));
    }
  }

  Future<void> deleteCredential(String credentialId) async {
    try {
      await _repository.deleteCredential(credentialId);
      await loadCredentials();
    } catch (e) {
      emit(SsiError(e.toString()));
    }
  }
}
