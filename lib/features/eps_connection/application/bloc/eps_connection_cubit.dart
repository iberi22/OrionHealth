import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'eps_connection_state.dart';
import '../../domain/entities/eps_connection.dart';
import '../../domain/entities/eps_provider.dart';
import '../../domain/repositories/oauth_repository.dart';
import '../../../user_profile/domain/repositories/user_profile_repository.dart';

@injectable
class EpsConnectionCubit extends Cubit<EpsConnectionState> {
  final OAuthRepository _oauthRepository;
  final UserProfileRepository _userProfileRepository;

  EpsConnectionCubit(this._oauthRepository, this._userProfileRepository)
      : super(const EpsConnectionInitial()) {
    loadConnections();
  }

  Future<void> loadConnections() async {
    emit(const EpsConnectionLoading());
    try {
      final connectedIds = await _oauthRepository.getConnectedProviders();
      final List<EPSConnection> connections = [];

      for (final id in connectedIds) {
        final token = await _oauthRepository.getToken(id);
        final provider = await _oauthRepository.getProviderDetails(id);
        final patientId = await _oauthRepository.getPatientId(id);

        if (token != null && provider != null) {
          connections.add(EPSConnection(
            provider: provider,
            token: token,
            patientId: patientId ?? 'Unknown',
            connectedAt: DateTime.now(), // ideally persisted connectedAt too
          ));
        }
      }
      emit(EpsConnectionLoaded(connections));
    } catch (e) {
      emit(EpsConnectionError('Error loading connections: ${e.toString()}'));
    }
  }

  Future<void> connect(EPSProvider provider) async {
    emit(const EpsConnectionLoading());
    try {
      final result = await _oauthRepository.login(provider);
      if (result != null) {
        final patientId = result.patientId;

        final profile = await _userProfileRepository.getUserProfile();
        if (profile != null) {
          final updatedProfile = profile.copyWith(
            isEpsConnected: true,
            epsPatientId: patientId,
          );
          await _userProfileRepository.saveUserProfile(updatedProfile);
          await loadConnections();
        } else {
          emit(const EpsConnectionError('User profile not found.'));
        }
      } else {
        await loadConnections();
      }
    } catch (e) {
      emit(EpsConnectionError('Connection error: ${e.toString()}'));
    }
  }

  Future<void> disconnect(String providerId) async {
    emit(const EpsConnectionLoading());
    try {
      await _oauthRepository.logout(providerId);
      final profile = await _userProfileRepository.getUserProfile();
      if (profile != null) {
        // If it was the only connection or we want to clear the global flag
        final providers = await _oauthRepository.getConnectedProviders();
        if (providers.isEmpty) {
          final updatedProfile = profile.copyWith(
            isEpsConnected: false,
            epsPatientId: null,
          );
          await _userProfileRepository.saveUserProfile(updatedProfile);
        }
      }
      await loadConnections();
    } catch (e) {
      emit(EpsConnectionError('Disconnection error: ${e.toString()}'));
    }
  }
}
