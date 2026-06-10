import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/oauth_repository.dart';
import '../../../user_profile/domain/repositories/user_profile_repository.dart';
import 'eps_connection_state.dart';

@injectable
class EpsConnectionCubit extends Cubit<EpsConnectionState> {
  final OAuthRepository _oauthRepository;
  final UserProfileRepository _userProfileRepository;

  EpsConnectionCubit(this._oauthRepository, this._userProfileRepository)
      : super(const EpsConnectionInitial()) {
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    final profile = await _userProfileRepository.getUserProfile();
    if (state is! EpsConnectionInitial) return;
    if (profile != null && profile.isEpsConnected && profile.epsPatientId != null) {
      emit(EpsConnectionConnected(profile.epsPatientId!));
    } else {
      emit(const EpsConnectionDisconnected());
    }
  }

  Future<void> connect() async {
    emit(const EpsConnectionLoading());
    try {
      final response = await _oauthRepository.login();
      if (response != null) {
        // En un flujo real de IHCE/FHIR, el patientId suele venir en los claims del token
        // o se obtiene llamando a un endpoint /Patient tras el login.
        // Aquí asumimos que viene en el tokenResponse.additionalParameters['patient']
        final patientId = response.authorizationAdditionalParameters?['patient'] as String?;

        if (patientId != null) {
          final profile = await _userProfileRepository.getUserProfile();
          if (profile != null) {
            final updatedProfile = profile.copyWith(
              isEpsConnected: true,
              epsPatientId: patientId,
            );
            await _userProfileRepository.saveUserProfile(updatedProfile);
            emit(EpsConnectionConnected(patientId));
          } else {
            emit(const EpsConnectionError('No se encontró el perfil de usuario local.'));
          }
        } else {
          emit(const EpsConnectionError('No se pudo obtener el ID del paciente desde IHCE.'));
        }
      } else {
        emit(const EpsConnectionDisconnected());
      }
    } catch (e) {
      emit(EpsConnectionError('Error al conectar con la EPS: ${e.toString()}'));
    }
  }

  Future<void> disconnect() async {
    emit(const EpsConnectionLoading());
    try {
      await _oauthRepository.logout();
      final profile = await _userProfileRepository.getUserProfile();
      if (profile != null) {
        final updatedProfile = profile.copyWith(
          isEpsConnected: false,
          epsPatientId: null,
        );
        await _userProfileRepository.saveUserProfile(updatedProfile);
      }
      emit(const EpsConnectionDisconnected());
    } catch (e) {
      emit(EpsConnectionError('Error al desconectar: ${e.toString()}'));
    }
  }
}
